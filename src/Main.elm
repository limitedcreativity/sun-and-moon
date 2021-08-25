module Main exposing (main)

import Action exposing (Action)
import Browser
import Browser.Events
import Dict exposing (Dict)
import Enemy exposing (Enemy)
import Grid
import Guardian exposing (Guardian)
import Health
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as Json
import Level exposing (Level)
import Ports
import Process exposing (spawn)
import Queue exposing (Queue)
import Settings exposing (Settings)
import Shrine exposing (Shrine)
import Task
import Time
import Unit exposing (Unit, toGuardian)
import World


main : Program Flags (Result String Model) Msg
main =
    Browser.element
        { init = init
        , update = updateResult
        , view =
            \result ->
                case result of
                    Ok model ->
                        view model

                    Err reason ->
                        viewError reason
        , subscriptions = Result.map subscriptions >> Result.withDefault Sub.none
        }


updateResult : Msg -> Result String Model -> ( Result String Model, Cmd Msg )
updateResult msg result =
    case result of
        Ok model ->
            let
                ( newModel, cmd ) =
                    update msg model
            in
            ( Ok newModel, cmd )

        Err _ ->
            ( result, Cmd.none )


viewError : String -> Html msg
viewError reason =
    viewPage
        { title = "Something went wrong..."
        , description = reason
        , buttons = []
        }


viewPage options =
    Html.div [ Attr.class "page" ]
        [ Html.h1 [ Attr.class "page__title" ] [ Html.text options.title ]
        , Html.p [ Attr.class "page__description" ] [ Html.text options.description ]
        , Html.div []
            (List.map
                (\( label, msg ) -> Html.button [ Attr.class "page__button", Html.Events.onClick msg ] [ Html.text label ])
                options.buttons
            )
        ]



-- INIT


type alias Flags =
    Json.Value


type alias GameData =
    { units : Dict Grid.Position Unit
    , shrine : Shrine
    , phase : GamePhase
    , levels : Queue Level
    , timeElapsed : Float
    , playerGold : Int
    }


type GamePhase
    = DayPhase { selected : Maybe { guardian : Guardian, cost : Int } }
    | NightPhase { remainingWaves : List Level.Wave }


type alias Model =
    { scene : Scene
    , settings : Settings
    , offsets : Dict Int { x : Float, y : Float, scale : Float }
    }


type Scene
    = MainMenu
    | InGame GameData
    | PauseMenu GameData
    | GameWon
    | GameOver


init : Flags -> ( Result String Model, Cmd Msg )
init flags =
    case Json.decodeValue Settings.decoder flags of
        Ok settings ->
            ( Ok
                { settings = settings
                , scene = MainMenu
                , offsets = Dict.empty -- TODO: Move this to CSS
                }
            , Cmd.none
            )

        Err reason ->
            ( Err "Could not understand settings file."
            , Ports.log (Json.errorToString reason)
            )



-- UPDATE


type Msg
    = GotOffsets Json.Value
    | ClickedPlayGame
    | ClickedMainMenu
    | TileClicked ( Int, Int )
    | GuardianClicked { guardian : Guardian, cost : Int }
    | Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model_ =
    let
        updateGame : (GameData -> ( GameData, Cmd Msg )) -> ( Model, Cmd Msg )
        updateGame updater =
            case model_.scene of
                MainMenu ->
                    ( model_, Cmd.none )

                InGame data ->
                    let
                        ( gameData, cmd ) =
                            updater data
                    in
                    ( { model_ | scene = InGame gameData }, cmd )

                PauseMenu _ ->
                    ( model_, Cmd.none )

                GameWon ->
                    ( model_, Cmd.none )

                GameOver ->
                    ( model_, Cmd.none )
    in
    case msg of
        ClickedPlayGame ->
            let
                ( newGame, newGameCmd ) =
                    startNewGame model_
            in
            ( { model_ | scene = newGame }, newGameCmd )

        ClickedMainMenu ->
            ( { model_ | scene = MainMenu }, Cmd.none )

        GuardianClicked unit ->
            updateGame
                (\model ->
                    case model.phase of
                        DayPhase { selected } ->
                            if Just unit == selected then
                                ( { model | phase = DayPhase { selected = Nothing } }, Cmd.none )

                            else
                                ( { model | phase = DayPhase { selected = Just unit } }, Cmd.none )

                        NightPhase _ ->
                            ( model, Cmd.none )
                )

        TileClicked ( x, y ) ->
            updateGame
                (\data ->
                    case ( data.phase, isShrineTile x y ) of
                        ( DayPhase { selected }, False ) ->
                            case selected of
                                Just { guardian, cost } ->
                                    ( { data
                                        | phase = DayPhase { selected = Nothing }
                                        , units = Dict.insert ( x, y ) (Unit.guardian guardian) data.units
                                        , playerGold = data.playerGold - cost
                                      }
                                    , Ports.sendGuardianBuilt guardian
                                    )

                                Nothing ->
                                    ( data, Cmd.none )

                        _ ->
                            ( data, Cmd.none )
                )

        GotOffsets json ->
            ( case Json.decodeValue decoder json of
                Ok list ->
                    { model_ | offsets = Dict.fromList list }

                Err _ ->
                    model_
            , Cmd.none
            )

        Tick delta ->
            case model_.scene of
                InGame data ->
                    handleTick delta data model_

                _ ->
                    ( model_, Cmd.none )


handleTick : Float -> GameData -> Model -> ( Model, Cmd Msg )
handleTick delta data model =
    let
        newTimeElapsed =
            data.timeElapsed + delta

        newData =
            { data | timeElapsed = newTimeElapsed }

        level =
            Queue.current newData.levels
    in
    case newData.phase of
        DayPhase _ ->
            updateDayPhase
                { previousTimeElapsed = data.timeElapsed
                , level = Queue.current newData.levels
                , model = model
                , data = newData
                }

        NightPhase { remainingWaves } ->
            updateNightPhase
                { previousTimeElapsed = data.timeElapsed
                , remainingWaves = remainingWaves
                , model = model
                , data = newData
                }


updateDayPhase :
    { previousTimeElapsed : Float
    , level : Level
    , model : Model
    , data : GameData
    }
    -> ( Model, Cmd Msg )
updateDayPhase { previousTimeElapsed, level, data, model } =
    let
        withinNightDuration =
            toFloat level.dayLengthInMs - data.timeElapsed < toFloat model.settings.music.nightFadeDuration

        sendNightApproaches =
            withinNightDuration
                && floor previousTimeElapsed
                // model.settings.music.nightFadeDuration
                < floor data.timeElapsed
                // model.settings.music.nightFadeDuration
    in
    if toFloat level.dayLengthInMs <= data.timeElapsed then
        ( { model
            | scene =
                InGame
                    { data
                        | timeElapsed = 0
                        , phase = NightPhase { remainingWaves = level.waves }
                    }
          }
        , Ports.sendNightStarted
        )

    else if sendNightApproaches then
        ( { model | scene = InGame data }
        , Ports.sendNightApproaches
        )

    else
        ( { model | scene = InGame data }, Cmd.none )


updateNightPhase : { previousTimeElapsed : Float, remainingWaves : List Level.Wave, model : Model, data : GameData } -> ( Model, Cmd Msg )
updateNightPhase { previousTimeElapsed, remainingWaves, model, data } =
    let
        level =
            Queue.current data.levels

        enemies : List Enemy
        enemies =
            data.units
                |> Dict.values
                |> List.filterMap Unit.toEnemy

        { msPerTurn } =
            model.settings.gameplay

        shouldSimulateTurn : Bool
        shouldSimulateTurn =
            floor data.timeElapsed // msPerTurn > floor previousTimeElapsed // msPerTurn

        ( scene, cmd ) =
            case remainingWaves of
                [] ->
                    if List.isEmpty enemies then
                        if Queue.noMoreLeft data.levels then
                            ( GameWon
                            , Ports.sendGameWon
                            )

                        else
                            ( InGame
                                { data
                                    | timeElapsed = 0
                                    , phase = DayPhase { selected = Nothing }
                                    , levels = Queue.next data.levels
                                    , playerGold = level.reward + data.playerGold
                                }
                            , Cmd.batch
                                [ Ports.sendDayStarted
                                , Ports.sendLevelCompleted
                                ]
                            )

                    else
                        ( InGame data, Cmd.none )

                wave :: otherWaves ->
                    if toFloat wave.startTime < data.timeElapsed then
                        ( InGame
                            { data
                                | units = spawnEnemies wave.spawns
                                , phase = NightPhase { remainingWaves = otherWaves }
                            }
                        , Ports.sendEnemiesSpawned
                        )

                    else
                        ( InGame data, Cmd.none )

        spawnEnemies : List Level.Spawn -> Dict Grid.Position Unit
        spawnEnemies =
            List.foldl spawnEnemy data.units

        spawnEnemy : Level.Spawn -> Dict Grid.Position Unit -> Dict Grid.Position Unit
        spawnEnemy spawn units =
            let
                position =
                    Level.positionAt spawn.gate
            in
            case Dict.get position units of
                Just _ ->
                    units

                Nothing ->
                    Dict.insert position (Unit.enemy spawn.enemy) units
    in
    case scene of
        InGame newGameData ->
            if shouldSimulateTurn then
                simulateTurn newGameData cmd model

            else
                ( { model | scene = scene }, cmd )

        _ ->
            ( { model | scene = scene }, cmd )


simulateTurn : GameData -> Cmd Msg -> Model -> ( Model, Cmd Msg )
simulateTurn data cmd model =
    let
        { units, shrine } =
            Dict.foldl
                performAction
                { units = data.units, shrine = data.shrine }
                data.units

        performAction :
            Grid.Position
            -> Unit
            -> { units : Dict Grid.Position Unit, shrine : Shrine }
            -> { units : Dict Grid.Position Unit, shrine : Shrine }
        performAction position unit state =
            let
                action : Action
                action =
                    Unit.simulate model.settings.gameplay.units state position unit
            in
            case action of
                Action.MoveTo destination ->
                    { state
                        | units =
                            case Dict.get destination state.units of
                                Just _ ->
                                    state.units

                                Nothing ->
                                    state.units
                                        |> Dict.remove position
                                        |> Dict.insert destination unit
                    }

                Action.AttackTargetAt damage destination ->
                    if destination == World.shrinePosition then
                        { state | shrine = state.shrine |> Health.damage 1 }

                    else
                        { state
                            | units =
                                state.units
                                    |> Dict.update destination (Maybe.map (Unit.damage damage))
                                    |> Dict.filter (\_ unit_ -> not (Unit.isDead unit_))
                        }

                Action.HealTargetAt heal destination ->
                    { state
                        | units =
                            state.units
                                |> Dict.update destination (Maybe.map (Unit.heal heal))
                                |> Dict.filter (\_ unit_ -> not (Unit.isDead unit_))
                    }

                Action.DoNothing ->
                    state

        newGameData : GameData
        newGameData =
            { data | units = units, shrine = shrine }
    in
    if Health.isDead shrine then
        ( { model | scene = GameOver }, Cmd.batch [ cmd, Ports.sendGameOver ] )

    else
        ( { model | scene = InGame newGameData }, cmd )


startNewGame : Model -> ( Scene, Cmd Msg )
startNewGame model =
    ( InGame
        { units = Dict.empty
        , shrine = { health = Health.init model.settings.gameplay.shrine.health }
        , phase = DayPhase { selected = Nothing }
        , levels = model.settings.gameplay.levels
        , timeElapsed = 0
        , playerGold = model.settings.gameplay.startingGold
        }
    , Cmd.batch
        [ Ports.sendNewGameStarted
        , Ports.sendDayStarted
        ]
    )


isShrineTile : Int -> Int -> Bool
isShrineTile x y =
    ( x, y ) == World.shrinePosition


decoder : Json.Decoder (List ( Int, { x : Float, y : Float, scale : Float } ))
decoder =
    let
        recordDecoder : Json.Decoder { x : Float, y : Float, scale : Float }
        recordDecoder =
            Json.map3 (\x y scale -> { x = x, y = y, scale = scale })
                (Json.field "x" Json.float)
                (Json.field "y" Json.float)
                (Json.field "scale" Json.float)
    in
    Json.list
        (Json.map2 Tuple.pair
            (Json.index 0 Json.int)
            (Json.index 1 recordDecoder)
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.onGridResize GotOffsets
        , case model.scene of
            InGame _ ->
                Browser.Events.onAnimationFrameDelta Tick

            _ ->
                Sub.none
        ]



-- VIEW


view : Model -> Html Msg
view model =
    case model.scene of
        MainMenu ->
            viewMainMenu

        InGame data ->
            viewGame model data

        PauseMenu data ->
            viewGame model data

        GameWon ->
            viewGameWon

        GameOver ->
            viewGameOver


viewMainMenu : Html Msg
viewMainMenu =
    viewPage
        { title = "Sol Patrol"
        , description = "Protect thine shrine!"
        , buttons =
            [ ( "Play game", ClickedPlayGame )
            ]
        }


viewGameWon : Html Msg
viewGameWon =
    viewPage
        { title = "You won!"
        , description = "Way to be."
        , buttons =
            [ ( "Play again", ClickedPlayGame )
            , ( "Back to main menu", ClickedMainMenu )
            ]
        }


viewGameOver : Html Msg
viewGameOver =
    viewPage
        { title = "Game over..."
        , description = "The night reigns eternal"
        , buttons =
            [ ( "Play again", ClickedPlayGame )
            , ( "Back to main menu", ClickedMainMenu )
            ]
        }


viewGame : Model -> GameData -> Html Msg
viewGame model data =
    Html.div [ Attr.class "game" ]
        [ Html.div [ Attr.class "grid" ]
            (List.range 0 (World.size - 1)
                |> List.map
                    (\y ->
                        Html.div [ Attr.class "grid__row" ]
                            (List.range 0 (World.size - 1)
                                |> List.map
                                    (\x ->
                                        Html.button
                                            [ Attr.class "grid__button"
                                            , Html.Events.onClick (TileClicked ( x, y ))
                                            ]
                                            [ Html.div [ Attr.class "grid__dot" ] []
                                            ]
                                    )
                            )
                    )
            )
        , List.range 0 (World.size * World.size - 1)
            |> List.map
                (\i ->
                    viewPieceAtIndex i
                        model
                        [ Dict.get (fromIndex i) data.units
                            |> Maybe.map Unit.view
                            |> Maybe.withDefault (Html.text "")
                        ]
                )
            |> Html.div [ Attr.class "unit__group" ]
        , viewShrine model data
        , viewHud model data
        ]


fromIndex : Int -> Grid.Position
fromIndex index =
    ( modBy World.size index
    , index // World.size
    )


viewPieceAtIndex : Int -> Model -> List (Html msg) -> Html msg
viewPieceAtIndex i model =
    let
        { x, y, scale } =
            Dict.get i model.offsets
                |> Maybe.withDefault { x = 0, y = 0, scale = 1 }
    in
    Html.div
        [ Attr.class "unit"
        , Attr.style "top" (String.fromFloat y ++ "px")
        , Attr.style "left" (String.fromFloat x ++ "px")
        , Attr.style "transform" ("translate(-50%, -100%) scale(" ++ String.fromFloat scale ++ ")")
        ]


toIndex : Grid.Position -> Int
toIndex ( x, y ) =
    x + y * World.size


viewShrine : Model -> GameData -> Html msg
viewShrine model data =
    viewPieceAtIndex (toIndex World.shrinePosition)
        model
        [ Shrine.view data.shrine ]


viewHud : Model -> GameData -> Html Msg
viewHud model data =
    Html.div [ Attr.class "hud" ]
        [ viewCurrentWave model data
        , viewBuildMenu model data
        ]


viewBuildMenu : Model -> GameData -> Html Msg
viewBuildMenu { settings } data =
    Html.div [ Attr.class "hud__build" ]
        [ Html.div [ Attr.class "hud__coins" ]
            [ Html.text (String.fromInt data.playerGold) ]
        , Html.div [ Attr.class "hud__units" ]
            (List.map
                (case data.phase of
                    DayPhase { selected } ->
                        viewGuardianButton
                            { isLocked = \cost -> data.playerGold < cost
                            , settings = settings.gameplay.units.guardian
                            , selected = selected
                            }

                    NightPhase _ ->
                        viewGuardianButton
                            { isLocked = always True
                            , settings = settings.gameplay.units.guardian
                            , selected = Nothing
                            }
                )
                [ { toGuardian = Guardian.warrior
                  , cost = settings.gameplay.costs.warrior
                  }
                , { toGuardian = Guardian.archer
                  , cost = settings.gameplay.costs.archer
                  }
                , { toGuardian = Guardian.mage
                  , cost = settings.gameplay.costs.mage
                  }
                ]
            )
        ]


viewGuardianButton :
    { settings : Guardian.Settings
    , isLocked : Int -> Bool
    , selected : Maybe { cost : Int, guardian : Guardian }
    }
    ->
        { toGuardian : Guardian.Settings -> Guardian
        , cost : Int
        }
    -> Html Msg
viewGuardianButton { settings, isLocked, selected } { toGuardian, cost } =
    let
        guardian =
            toGuardian settings

        unitToBuy =
            { guardian = guardian, cost = cost }
    in
    Html.div
        [ Attr.class "hud__unit"
        , Attr.classList
            [ ( "hud__unit--selected", selected == Just unitToBuy )
            , ( "hud__unit--locked", isLocked cost )
            ]
        , if isLocked cost then
            Attr.disabled True

          else
            Html.Events.onClick (GuardianClicked unitToBuy)
        ]
        [ Guardian.viewPreview guardian.kind
        , Html.div [ Attr.class "hud__unit-cost" ] [ Html.text (String.fromInt cost) ]
        ]



-- HUD


viewCurrentWave : Model -> GameData -> Html Msg
viewCurrentWave model data =
    let
        level : Level
        level =
            Queue.current data.levels

        currentLevel =
            Queue.completed data.levels + 1

        remainingLevels =
            Queue.remaining data.levels
    in
    Html.div [ Attr.class "hud__wave" ]
        [ Html.div [ Attr.class "hud__day" ] [ "Day {{day}}" |> String.replace "{{day}}" (String.fromInt currentLevel) |> Html.text ]
        , Html.div [ Attr.class "hud__eclipse" ]
            [ case remainingLevels of
                0 ->
                    Html.text "The solar eclipse"

                1 ->
                    Html.text "The day before the solar eclipse"

                _ ->
                    "{{remainingLevels}} days until the solar eclipse" |> String.replace "{{remainingLevels}}" (String.fromInt remainingLevels) |> Html.text
            ]
        , case data.phase of
            DayPhase _ ->
                Html.progress [ Attr.value (String.fromFloat data.timeElapsed), Attr.max (String.fromInt level.dayLengthInMs) ] []

            NightPhase { remainingWaves } ->
                Html.text
                    ("Wave {{num}} of {{total}}"
                        |> String.replace "{{num}}" (String.fromInt (List.length level.waves - List.length remainingWaves))
                        |> String.replace "{{total}}" (String.fromInt (List.length level.waves))
                    )
        ]
