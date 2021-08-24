module Level exposing (Gate, Level, Spawn, Wave, decoder, positionAt)

import Enemy exposing (Enemy)
import Grid
import Json.Decode as Json
import World


type alias Level =
    { dayLengthInMs : Int
    , reward : Int
    , waves : List Wave
    }


type alias Wave =
    { startTime : Int
    , spawns : List Spawn
    }


type alias Spawn =
    { gate : Gate
    , enemy : Enemy
    }


type Gate
    = North
    | East
    | West


positionAt : Gate -> Grid.Position
positionAt gate =
    case gate of
        North ->
            ( World.size // 2, 0 )

        East ->
            ( World.size - 1, World.size // 2 )

        West ->
            ( 0, World.size // 2 )


decoder : Int -> Json.Decoder Level
decoder msPerTurn =
    Json.map3 Level
        (Json.field "lengthOfDay" Json.int)
        (Json.field "reward" Json.int)
        (Json.field "waves" (wavesDecoder msPerTurn))


wavesDecoder : Int -> Json.Decoder (List Wave)
wavesDecoder msPerTurn =
    Json.keyValuePairs spawnsDecoder
        |> Json.map
            (List.filterMap
                (\( roundStr, spawns ) ->
                    String.toInt roundStr
                        |> Maybe.map (\round -> round * msPerTurn)
                        |> Maybe.map (\startTime -> { startTime = startTime, spawns = spawns })
                )
            )


spawnsDecoder : Json.Decoder (List Spawn)
spawnsDecoder =
    Json.keyValuePairs enemyDecoder
        |> Json.map
            (List.filterMap
                (\( key, enemy ) ->
                    toGate key
                        |> Maybe.map (\gate -> { gate = gate, enemy = enemy })
                )
            )


toGate : String -> Maybe Gate
toGate str =
    case String.toLower str of
        "north" ->
            Just North

        "east" ->
            Just East

        "west" ->
            Just West

        _ ->
            Nothing


enemyDecoder : Json.Decoder Enemy
enemyDecoder =
    Json.string
        |> Json.andThen
            (\enemy ->
                case String.toLower enemy of
                    "warrior" ->
                        Json.succeed Enemy.rogue

                    _ ->
                        Json.fail ("Unknown enemy: " ++ enemy)
            )
