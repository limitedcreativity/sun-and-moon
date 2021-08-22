module Unit exposing (Unit(..), view)

import Html.Attributes exposing (draggable)
import Svg exposing (Svg)
import Svg.Attributes as Attr


type Unit
    = Warrior
    | Archer
    | Mage


toStyle :
    Unit
    -> { color : String }
toStyle unit =
    case unit of
        Warrior ->
            { color = "red" }

        Archer ->
            { color = "green" }

        Mage ->
            { color = "blue" }


view : Unit -> Svg msg
view unit =
    let
        style =
            toStyle unit
    in
    Svg.svg [ Attr.viewBox "0 0 50 75", Attr.width "100%", draggable "false" ]
        [ --     Svg.rect
          --     [ Attr.x "0"
          --     , Attr.y "0"
          --     , Attr.width "50"
          --     , Attr.height "75"
          --     , Attr.fill "white"
          --     ]
          --     []
          -- ,
          Svg.circle
            [ Attr.cx "25"
            , Attr.cy "50"
            , Attr.r "20"
            , Attr.fill style.color
            ]
            []
        , Svg.circle
            [ Attr.cx "25"
            , Attr.cy "25"
            , Attr.r "20"
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
