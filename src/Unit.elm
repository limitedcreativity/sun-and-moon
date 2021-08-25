module Unit exposing
    ( Settings
    , Unit, enemy, guardian
    , simulate
    , damage, isDead
    , view, toEnemy, toGuardian
    , heal
    )

{-|

@docs Settings
@docs Unit, enemy, guardian
@docs Action, simulate
@docs damage, isDead
@docs view, toEnemy, toGuardian

-}

import Action exposing (Action)
import Dict exposing (Dict)
import Enemy exposing (Enemy)
import Grid
import Guardian
import Health
import Shrine exposing (Shrine)
import Svg exposing (Svg)
import World exposing (World)


type alias Settings =
    { guardian : Guardian.Settings
    , enemy : Enemy.Settings
    }


type Unit
    = Guardian Guardian.Guardian
    | Enemy Enemy.Enemy



-- CREATE


guardian : Guardian.Guardian -> Unit
guardian =
    Guardian


enemy : Enemy.Enemy -> Unit
enemy =
    Enemy



-- UPDATE


simulate :
    { settings
        | guardian : Guardian.Settings
        , enemy : Enemy.Settings
    }
    ->
        { units : Dict Grid.Position Unit
        , shrine : Shrine
        }
    -> Grid.Position
    -> Unit
    -> Action
simulate settings state position unit =
    let
        world =
            toWorld state
    in
    case unit of
        Guardian g ->
            Guardian.simulate settings.guardian world position g

        Enemy e ->
            Enemy.simulate settings.enemy world position e


damage : Int -> Unit -> Unit
damage amount unit =
    case unit of
        Guardian g ->
            Guardian (Health.damage amount g)

        Enemy e ->
            Enemy (Health.damage amount e)


heal : Int -> Unit -> Unit
heal amount =
    damage (negate amount)


isDead : Unit -> Bool
isDead unit =
    case unit of
        Guardian g ->
            Health.isDead g

        Enemy e ->
            Health.isDead e



-- READ


view : Unit -> Svg msg
view unit =
    case unit of
        Guardian g ->
            Guardian.view g

        Enemy e ->
            Enemy.view e


toEnemy : Unit -> Maybe Enemy.Enemy
toEnemy unit =
    case unit of
        Enemy e ->
            Just e

        _ ->
            Nothing


toGuardian : Unit -> Maybe Guardian.Guardian
toGuardian unit =
    case unit of
        Guardian g ->
            Just g

        _ ->
            Nothing



-- INTERNALS


toWorld :
    { units : Dict Grid.Position Unit
    , shrine : Shrine
    }
    -> World
toWorld =
    World.fromState
        { isEnemy = isEnemy
        , isGuardian = isGuardian
        , isDamaged = isDamaged
        }


isEnemy : Unit -> Bool
isEnemy =
    toEnemy >> (/=) Nothing


isGuardian : Unit -> Bool
isGuardian =
    toGuardian >> (/=) Nothing


isDamaged : Unit -> Bool
isDamaged unit =
    case unit of
        Guardian { health } ->
            health.current < health.max

        Enemy { health } ->
            health.current < health.max
