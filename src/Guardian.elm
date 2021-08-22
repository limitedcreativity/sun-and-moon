module Guardian exposing
    ( Guardian, warrior, archer, mage
    , simulate
    , view, viewPreview
    )

{-|

@docs Guardian, warrior, archer, mage
@docs simulate
@docs view, viewPreview

-}

import Action exposing (Action)
import Grid
import Health exposing (Health)
import Html.Attributes exposing (draggable)
import Svg exposing (Svg)
import Svg.Attributes as Attr
import World exposing (World)


type alias Guardian =
    { kind : GuardianKind
    , health : Health
    }


type GuardianKind
    = Warrior
    | Archer
    | Mage


warrior : Guardian
warrior =
    { kind = Warrior
    , health = Health.init 8
    }


archer : Guardian
archer =
    { kind = Archer
    , health = Health.init 6
    }


mage : Guardian
mage =
    { kind = Mage
    , health = Health.init 4
    }



-- UPDATE


simulate :
    World
    -> Grid.Position
    -> Guardian
    -> Action
simulate world position guardian =
    case guardian.kind of
        Warrior ->
            simulateWarrior world position

        Archer ->
            simulateArcher world position

        Mage ->
            Action.DoNothing


simulateWarrior : World -> Grid.Position -> Action
simulateWarrior world position =
    let
        nearestEnemy =
            Grid.nearestTarget position world.enemies
    in
    case nearestEnemy of
        Just enemy ->
            if Grid.isAdjacentTo enemy position then
                Action.AttackTargetAt enemy

            else
                Action.MoveTo (Grid.nextPositionTowards enemy position)

        Nothing ->
            Action.DoNothing


simulateArcher : World -> Grid.Position -> Action
simulateArcher world position =
    let
        nearestEnemy =
            Grid.nearestTarget position world.enemies
    in
    case nearestEnemy of
        Just enemy ->
            if Grid.withinRange 4 enemy position then
                Action.AttackTargetAt enemy

            else
                Action.MoveTo (Grid.nextPositionTowards enemy position)

        Nothing ->
            Action.DoNothing



-- VIEW


toStyle :
    GuardianKind
    -> { color : String }
toStyle kind =
    case kind of
        Warrior ->
            { color = "red" }

        Archer ->
            { color = "green" }

        Mage ->
            { color = "blue" }


view : Guardian -> Svg msg
view unit =
    Svg.svg [ Attr.viewBox "0 0 50 75", Attr.width "100%", draggable "false" ]
        [ Health.viewHealthbar unit.health
        , viewUnit unit.kind
        ]


viewPreview : GuardianKind -> Svg msg
viewPreview unitKind =
    Svg.svg
        [ Attr.viewBox "0 0 50 50"
        , Attr.width "100%"
        , draggable "false"
        ]
        [ viewUnit unitKind ]


viewUnit : GuardianKind -> Svg msg
viewUnit unitKind =
    let
        style =
            toStyle unitKind
    in
    Svg.g []
        [ Svg.circle
            [ Attr.cx "25"
            , Attr.cy "50"
            , Attr.r "20"
            , Attr.fill style.color
            ]
            []
        , Svg.circle
            [ Attr.cx "25"
            , Attr.cy "25"
            , Attr.r "18"
            , Attr.fill "tan"
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
