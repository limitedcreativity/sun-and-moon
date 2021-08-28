module Enemy exposing
    ( Settings
    , Enemy, rogue, archer, necromancer
    , simulate
    , view
    , EnemyKind(..)
    )

{-|

@docs Settings
@docs Enemy, rogue, archer, necromancer
@docs simulate
@docs view

-}

import Action exposing (Action)
import Grid
import Health exposing (Health)
import Simulate
import Svg exposing (Svg)
import Svg.Attributes as Attr
import World exposing (World)


type alias Settings =
    { warrior : { health : Int, damage : Int }
    , archer : { health : Int, damage : Int, range : Int }
    , mage : { health : Int, heal : Int, range : Int }
    }


type alias Enemy =
    { kind : EnemyKind
    , health : Health
    }


type EnemyKind
    = Rogue
    | Assassin
    | Necromancer


rogue : Settings -> Enemy
rogue settings =
    { kind = Rogue
    , health = Health.init settings.warrior.health
    }

assassin : Settings -> Enemy
assassin settings =
    { kind = Assassin
    , health = Health.init settings.archer.health
    }

necromancer : Settings -> Enemy
necromancer settings =
    { kind = Necromancer
    , health = Health.init settings.mage.health
    }


-- UPDATE


simulate :
    Settings
    -> World
    -> Grid.Position
    -> Enemy
    -> Action
simulate settings world position unit =
    let
        targets =
            World.shrinePosition :: world.guardians
    in
    case unit.kind of
        Rogue ->
            Simulate.warrior
                { world = world
                , position = position
                , targets = targets
                , damage = settings.warrior.damage
                }

        Assassin ->
            Simulate.archer
                { position = position
                , targets = targets
                , settings = settings.archer
                }

        Necromancer ->
            Simulate.mage
                { position = position
                , allies = world.damagedEnemiesExceptFor position
                , settings = settings.mage
                }



-- VIEW


toStyle : EnemyKind -> { skin : String, shirt : String }
toStyle kind =
    case kind of
        Rogue ->
            { skin = "teal"
            , shirt = "rebeccapurple"
            }

        Assassin ->
            { skin = "teal"
            , shirt = "darkgray"
            }

        Necromancer ->
            { skin = "teal"
            , shirt = "lime"
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
