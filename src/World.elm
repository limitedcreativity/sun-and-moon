module World exposing (World, fromState, shrinePosition, size)

import Dict exposing (Dict)
import Grid


type alias World =
    { enemies : List Grid.Position
    , guardians : List Grid.Position
    , damagedEnemiesExceptFor : Grid.Position -> List Grid.Position
    , damagedGuardiansExceptFor : Grid.Position -> List Grid.Position
    }


size : Int
size =
    Grid.size


shrinePosition : Grid.Position
shrinePosition =
    ( size // 2, size - 2 )


fromState : { isEnemy : unit -> Bool, isGuardian : unit -> Bool, isDamaged : unit -> Bool } -> { state | units : Dict Grid.Position unit } -> World
fromState { isEnemy, isGuardian, isDamaged } { units } =
    { enemies = units |> Dict.filter (\_ unit -> isEnemy unit) |> Dict.keys
    , guardians = units |> Dict.filter (\_ unit -> isGuardian unit) |> Dict.keys
    , damagedEnemiesExceptFor = \pos -> units |> Dict.filter (\pos_ unit -> isEnemy unit && isDamaged unit && pos_ /= pos) |> Dict.keys
    , damagedGuardiansExceptFor = \pos -> units |> Dict.filter (\pos_ unit -> isGuardian unit && isDamaged unit && pos_ /= pos) |> Dict.keys
    }
