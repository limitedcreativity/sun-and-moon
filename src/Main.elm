module Main exposing (main)

import Browser
import Browser.Events
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes exposing (class, classList, style)
import Html.Events
import Json.Decode as Json
import Json.Encode
import Ports
import Unit exposing (Unit)


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
    ()


type alias Model =
    { offsets : Dict Int { x : Float, y : Float, scale : Float }
    , selectedUnit : Maybe Unit
    , units : Dict Int Unit
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { offsets = Dict.empty
      , selectedUnit = Nothing
      , units = Dict.fromList [ ( 0, Unit.Mage ) ]
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GotOffsets Json.Value
    | UnitClicked Unit
    | TileClicked ( Int, Int )


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UnitClicked unit ->
            if Just unit == model.selectedUnit then
                ( { model | selectedUnit = Nothing }, Cmd.none )

            else
                ( { model | selectedUnit = Just unit }, Cmd.none )

        TileClicked ( x, y ) ->
            case model.selectedUnit of
                Just unit ->
                    ( { model
                        | selectedUnit = Nothing
                        , units = Dict.insert (x + y * 8) unit model.units
                      }
                    , Ports.playClip unit
                    )

                Nothing ->
                    ( model, Cmd.none )

        GotOffsets json ->
            ( case Json.decodeValue decoder json of
                Ok list ->
                    { model | offsets = Dict.fromList list }

                Err _ ->
                    model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.onGridResize GotOffsets
        ]



-- VIEW


view : Model -> Html Msg
view model =
    Html.div [ class "game" ]
        [ Html.div [ class "grid" ]
            (List.range 0 7
                |> List.map
                    (\y ->
                        Html.div [ class "grid__row" ]
                            (List.range 0 7
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
        , List.range 0 63
            |> List.map
                (\i ->
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
                        (case Dict.get i model.units of
                            Just unit ->
                                [ Unit.view unit ]

                            Nothing ->
                                []
                        )
                )
            |> Html.div [ class "unit__group" ]
        , viewHud model
        ]


viewHud : Model -> Html Msg
viewHud model =
    Html.div [ class "hud" ]
        [ Html.div [ class "hud__coins" ] []
        , Html.div [ class "hud__units" ]
            (List.map (viewUnitButton model.selectedUnit)
                [ Unit.Warrior
                , Unit.Archer
                , Unit.Mage
                ]
            )
        ]


viewUnitButton : Maybe Unit.Unit -> Unit.Unit -> Html Msg
viewUnitButton selectedUnit unit =
    Html.div
        [ class "hud__unit"
        , classList
            [ ( "hud__unit--selected", selectedUnit == Just unit )
            ]
        , Html.Events.onClick (UnitClicked unit)
        ]
        [ Unit.view unit ]



-- INTERNALS
