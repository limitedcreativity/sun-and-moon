module Main exposing (main)

import Action exposing (Action)
import Browser
import Dict exposing (Dict)
import Enemy exposing (Enemy)
import Grid
import Guardian exposing (Guardian)
import Health
import Html exposing (Html)
import Html.Attributes exposing (class, classList, style)
import Html.Events
import Json.Decode as Json
import Level exposing (Level)
import Ports
import Shrine exposing (Shrine)
import Time
import Unit exposing (Unit)
import World


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Flags =
    Json.Value


type alias Model =
    { levels : List Level
    , offsets : Dict Int { x : Float, y : Float, scale : Float }
    , selected : Maybe Guardian
    , units : Dict Grid.Position Unit
    , phase : Phase
    , shrine : Shrine
    }


type Phase
    = BuildPhase
    | BattlePhase
    | RoundVictory
    | GameOver


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { levels =
            flags
                |> Json.decodeValue (Json.field "levels" (Json.list Level.decoder))
                |> Result.withDefault []
      , offsets = Dict.empty
      , selected = Nothing
      , units =
            Dict.fromList
                [ ( ( 4, 0 ), Unit.enemy Enemy.rogue )
                , ( ( 0, 4 ), Unit.enemy Enemy.rogue )
                , ( ( 8, 4 ), Unit.enemy Enemy.rogue )
                ]
      , phase = BuildPhase
      , shrine = { health = Health.init 5 }
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GotOffsets Json.Value
    | GuardianClicked Guardian
    | TileClicked ( Int, Int )
    | ToggledPhase
    | SimulateTurn


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GuardianClicked unit ->
            if Just unit == model.selected then
                ( { model | selected = Nothing }, Cmd.none )

            else
                ( { model | selected = Just unit }, Cmd.none )

        TileClicked ( x, y ) ->
            case ( model.selected, isShrineTile x y ) of
                ( Just guardian, False ) ->
                    ( { model
                        | selected = Nothing
                        , units = Dict.insert ( x, y ) (Unit.guardian guardian) model.units
                      }
                    , Ports.playClip guardian
                    )

                _ ->
                    ( model, Cmd.none )

        GotOffsets json ->
            ( case Json.decodeValue decoder json of
                Ok list ->
                    { model | offsets = Dict.fromList list }

                Err _ ->
                    model
            , Cmd.none
            )

        ToggledPhase ->
            ( { model | phase = togglePhase model.phase }, Cmd.none )

        SimulateTurn ->
            let
                { units, shrine } =
                    Dict.foldl
                        performAction
                        { units = model.units, shrine = model.shrine }
                        model.units

                performAction :
                    Grid.Position
                    -> Unit
                    -> { units : Dict Grid.Position Unit, shrine : Shrine }
                    -> { units : Dict Grid.Position Unit, shrine : Shrine }
                performAction position unit state =
                    let
                        action : Action
                        action =
                            Unit.simulate state position unit
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

                        Action.AttackTargetAt destination ->
                            if destination == World.shrinePosition then
                                { state | shrine = state.shrine |> Health.damage 1 }

                            else
                                { state
                                    | units =
                                        state.units
                                            |> Dict.update destination (Maybe.map (Unit.damage 1))
                                            |> Dict.filter (\_ unit_ -> not (Unit.isDead unit_))
                                }

                        Action.DoNothing ->
                            state

                newModel : Model
                newModel =
                    { model | units = units, shrine = shrine }

                enemies : List Enemy
                enemies =
                    units
                        |> Dict.values
                        |> List.filterMap Unit.toEnemy
            in
            if Health.isDead shrine then
                ( { newModel | phase = GameOver }, Cmd.none )

            else if List.isEmpty enemies then
                ( { newModel | phase = RoundVictory }, Cmd.none )

            else
                ( newModel, Cmd.none )


isShrineTile : Int -> Int -> Bool
isShrineTile x y =
    ( x, y ) == World.shrinePosition


togglePhase : Phase -> Phase
togglePhase phase =
    case phase of
        BuildPhase ->
            BattlePhase

        BattlePhase ->
            BuildPhase

        _ ->
            BuildPhase


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
        , if model.phase == BattlePhase then
            Time.every 1000 (always SimulateTurn)

          else
            Sub.none
        ]



-- VIEW


view : Model -> Html Msg
view model =
    Html.div [ class "game" ]
        [ Html.div [ class "grid" ]
            (List.range 0 (World.size - 1)
                |> List.map
                    (\y ->
                        Html.div [ class "grid__row" ]
                            (List.range 0 (World.size - 1)
                                |> List.map
                                    (\x ->
                                        Html.button
                                            [ class "grid__button"
                                            , Html.Events.onClick (TileClicked ( x, y ))
                                            ]
                                            [ Html.div [ class "grid__dot" ] []
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
                        [ Dict.get (fromIndex i) model.units
                            |> Maybe.map Unit.view
                            |> Maybe.withDefault (Html.text "")
                        ]
                )
            |> Html.div [ class "unit__group" ]
        , viewShrine model
        , viewHud model
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
        [ class "unit"
        , style "top" (String.fromFloat y ++ "px")
        , style "left" (String.fromFloat x ++ "px")
        , style "transform" ("translate(-50%, -100%) scale(" ++ String.fromFloat scale ++ ")")
        ]


toIndex : Grid.Position -> Int
toIndex ( x, y ) =
    x + y * World.size


viewShrine : Model -> Html msg
viewShrine model =
    viewPieceAtIndex (toIndex World.shrinePosition)
        model
        [ Shrine.view model.shrine ]


viewHud : Model -> Html Msg
viewHud model =
    Html.div [ class "hud" ]
        [ viewCurrentWave model
        , viewBuildMenu model
        ]


viewBuildMenu : Model -> Html Msg
viewBuildMenu model =
    Html.div [ class "hud__build" ]
        [ Html.div [ class "hud__coins" ] []
        , case model.phase of
            BuildPhase ->
                Html.div [ class "hud__units" ]
                    (List.map (viewGuardianButton model.selected)
                        [ Guardian.warrior
                        , Guardian.archer
                        , Guardian.mage
                        ]
                    )

            BattlePhase ->
                Html.text "Defend the shrine!"

            RoundVictory ->
                Html.text "Victory!"

            GameOver ->
                Html.text "Game over..."
        , case model.phase of
            BuildPhase ->
                Html.button [ class "hud__start", Html.Events.onClick ToggledPhase ] [ Html.text "Begin round" ]

            _ ->
                Html.text ""
        ]


viewGuardianButton : Maybe Guardian -> Guardian -> Html Msg
viewGuardianButton selectedUnit unit =
    Html.div
        [ class "hud__unit"
        , classList
            [ ( "hud__unit--selected", selectedUnit == Just unit )
            ]
        , Html.Events.onClick (GuardianClicked unit)
        ]
        [ Guardian.viewPreview unit.kind ]



-- HUD


viewCurrentWave : Model -> Html Msg
viewCurrentWave model =
    Html.div [ class "hud__wave" ]
        [ Html.div [ class "hud__day" ] [ Html.text "Day 1" ]
        , Html.div [ class "hud__eclipse" ] [ Html.text "10 days until the solar eclipse" ]
        ]
