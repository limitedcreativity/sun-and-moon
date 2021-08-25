module World exposing (World, fromState, shrinePosition, size)

import Dict exposing (Dict)
import Grid


type alias World =
    { enemies : List Grid.Position
    , guardians : List Grid.Position
    }


size : Int
size =
    Grid.size


shrinePosition : Grid.Position
shrinePosition =
    ( size // 2, size - 2 )


fromState : { isEnemy : unit -> Bool, isGuardian : unit -> Bool } -> { state | units : Dict Grid.Position unit } -> World
fromState { isEnemy, isGuardian } { units } =
    { enemies = units |> Dict.filter (\_ unit -> isEnemy unit) |> Dict.keys
    , guardians = units |> Dict.filter (\_ unit -> isGuardian unit) |> Dict.keys
    }
