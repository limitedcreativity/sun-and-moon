module Level exposing (Level, decoder)

import Enemy exposing (Enemy)
import Json.Decode as Json


type alias Level =
    { reward : Int
    , waves : List Wave
    }


type alias Wave =
    { round : Int
    , spawns : List Spawn
    }


type alias Spawn =
    { gate : Gate
    , enemies : List Enemy
    }


type Gate
    = North
    | East
    | West


decoder : Json.Decoder Level
decoder =
    Json.map2 Level
        (Json.field "reward" Json.int)
        (Json.field "waves" wavesDecoder)


wavesDecoder : Json.Decoder (List Wave)
wavesDecoder =
    Json.keyValuePairs spawnsDecoder
        |> Json.map
            (List.filterMap
                (\( roundStr, spawns ) -> String.toInt roundStr |> Maybe.map (\round -> { round = round, spawns = spawns }))
            )


spawnsDecoder : Json.Decoder (List Spawn)
spawnsDecoder =
    Json.keyValuePairs (Json.oneOf [ Json.list enemyDecoder, Json.succeed [] ])
        |> Json.map
            (List.filterMap
                (\( key, enemies ) ->
                    toGate key
                        |> Maybe.map (\gate -> { gate = gate, enemies = enemies })
                )
            )


toGate : String -> Maybe Gate
toGate str =
    case String.toUpper str of
        "NORTH" ->
            Just North

        "EAST" ->
            Just East

        "WEST" ->
            Just West

        _ ->
            Nothing


enemyDecoder : Json.Decoder Enemy
enemyDecoder =
    Json.string
        |> Json.andThen
            (\enemy ->
                case enemy of
                    "rogue" ->
                        Json.succeed Enemy.rogue

                    _ ->
                        Json.fail ("Unknown enemy: " ++ enemy)
            )
