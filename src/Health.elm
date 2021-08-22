module Health exposing (Health, damage, init, isDead, viewHealthbar)

import Svg exposing (Svg)
import Svg.Attributes as Attr


type alias Health =
    { current : Int
    , max : Int
    }


init : Int -> Health
init value =
    { current = max 0 value
    , max = max 0 value
    }


damage :
    Int
    -> { unit | health : Health }
    -> { unit | health : Health }
damage amount ({ health } as unit) =
    { unit | health = { health | current = max 0 (health.current - amount) } }


isDead : { unit | health : Health } -> Bool
isDead unit =
    unit.health.current == 0


viewHealthbar : Health -> Svg msg
viewHealthbar health =
    Svg.g []
        [ Svg.rect [ Attr.x "5", Attr.y "0", Attr.width "40", Attr.height "4", Attr.stroke "black", Attr.strokeWidth "1", Attr.fill "white" ] []
        , Svg.rect [ Attr.x "5", Attr.y "0", Attr.width (String.fromInt (40 * health.current // health.max)), Attr.height "4", Attr.fill "mediumseagreen" ] []
        ]
