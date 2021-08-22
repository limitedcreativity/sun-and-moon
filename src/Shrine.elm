module Shrine exposing (Shrine, view)

import Health exposing (Health)
import Svg exposing (Svg)
import Svg.Attributes as Attr


type alias Shrine =
    { health : Health
    }


view : Shrine -> Svg msg
view shrine =
    Svg.svg [ Attr.viewBox "0 0 50 60", Attr.width "100%" ]
        [ Health.viewHealthbar shrine.health
        , Svg.circle
            [ Attr.cx "25"
            , Attr.cy "35"
            , Attr.r "22"
            , Attr.fill "goldenrod"
            ]
            []
        , Svg.circle
            [ Attr.cx "25"
            , Attr.cy "31"
            , Attr.r "19"
            , Attr.fill "yellow"
            ]
            []
        ]
