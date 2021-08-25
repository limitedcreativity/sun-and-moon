module Guardian exposing
    ( Settings
    , Guardian, warrior, archer, mage
    , simulate
    , view, viewPreview
    , GuardianKind(..)
    )

{-|

@docs Settings
@docs Guardian, warrior, archer, mage
@docs simulate
@docs view, viewPreview

-}

import Action exposing (Action)
import Grid
import Health exposing (Health)
import Html.Attributes exposing (draggable)
import Simulate
import Svg exposing (Svg)
import Svg.Attributes as Attr
import World exposing (World)


type alias Settings =
    { warrior : { health : Int, damage : Int }
    , archer : { health : Int, damage : Int, range : Int }
    , mage : { health : Int, heal : Int, range : Int }
    }


type alias Guardian =
    { kind : GuardianKind
    , health : Health
    }


type GuardianKind
    = Warrior
    | Archer
    | Mage


warrior : Settings -> Guardian
warrior settings =
    { kind = Warrior
    , health = Health.init settings.warrior.health
    }


archer : Settings -> Guardian
archer settings =
    { kind = Archer
    , health = Health.init settings.archer.health
    }


mage : Settings -> Guardian
mage settings =
    { kind = Mage
    , health = Health.init settings.mage.health
    }



-- UPDATE


simulate :
    Settings
    -> World
    -> Grid.Position
    -> Guardian
    -> Action
simulate settings world position guardian =
    case guardian.kind of
        Warrior ->
            Simulate.warrior
                { position = position
                , targets = world.enemies
                , world = world
                , damage = settings.warrior.damage
                }

        Archer ->
            Simulate.archer
                { position = position
                , targets = world.enemies
                , settings = settings.archer
                }

        Mage ->
            Simulate.mage
                { position = position
                , allies = world.guardians
                , settings = settings.mage
                }



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
