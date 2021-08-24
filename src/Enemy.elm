module Enemy exposing
    ( Settings
    , Enemy, rogue
    , simulate
    , view
    , EnemyKind(..)
    )

{-|

@docs Settings
@docs Enemy, rogue
@docs simulate
@docs view

-}

import Action exposing (Action)
import Grid
import Health exposing (Health)
import Svg exposing (Svg)
import Svg.Attributes as Attr
import World exposing (World)


type alias Settings =
    { warrior : { health : Int, damage : Int }
    , archer : { health : Int, damage : Int, range : Int }
    , mage : { health : Int, damage : Int, range : Int }
    }


type alias Enemy =
    { kind : EnemyKind
    , health : Health
    }


type EnemyKind
    = Rogue


rogue : Enemy
rogue =
    { kind = Rogue
    , health = Health.init 5
    }



-- UPDATE


simulate :
    World
    -> Grid.Position
    -> Enemy
    -> Action
simulate world position unit =
    case unit.kind of
        Rogue ->
            simulateRogue world position


simulateRogue : World -> Grid.Position -> Action
simulateRogue world position =
    let
        nearestTarget =
            Grid.nearestTarget position (World.shrinePosition :: world.guardians)
    in
    case nearestTarget of
        Just target ->
            if Grid.isAdjacentTo target position then
                Action.AttackTargetAt target

            else
                Action.MoveTo (Grid.nextPositionTowards target position)

        Nothing ->
            Action.DoNothing



-- VIEW


toStyle : EnemyKind -> { skin : String, shirt : String }
toStyle kind =
    case kind of
        Rogue ->
            { skin = "teal"
            , shirt = "rebeccapurple"
            }


view : Enemy -> Svg msg
view unit =
    Svg.svg [ Attr.viewBox "0 0 50 75", Attr.width "100%" ]
        [ Health.viewHealthbar unit.health
        , viewEnemy unit.kind
        ]


viewEnemy : EnemyKind -> Svg msg
viewEnemy unitKind =
    let
        style =
            toStyle unitKind
    in
    Svg.g []
        [ Svg.circle
            [ Attr.cx "25"
            , Attr.cy "50"
            , Attr.r "20"
            , Attr.fill style.shirt
            ]
            []
        , Svg.circle
            [ Attr.cx "25"
            , Attr.cy "25"
            , Attr.r "18"
            , Attr.fill style.skin
            ]
            []
        , Svg.circle
            [ Attr.cx "20"
            , Attr.cy "24"
            , Attr.r "3"
            , Attr.fill "black"
            ]
            []
        , Svg.circle
            [ Attr.cx "30"
            , Attr.cy "24"
            , Attr.r "3"
            , Attr.fill "black"
            ]
            []
        ]