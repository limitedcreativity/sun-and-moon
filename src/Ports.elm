port module Ports exposing (onGridResize, playClip)

import Json.Encode as Json
import Unit exposing (Unit)


port onGridResize : (Json.Value -> msg) -> Sub msg


port outgoing : { tag : String, data : Json.Value } -> Cmd msg


playClip : Unit -> Cmd msg
playClip unit =
    outgoing
        { tag = "playClip"
        , data =
            case unit of
                Unit.Warrior ->
                    Json.string "/clips/warrior-2.mp3"

                Unit.Archer ->
                    Json.string "/clips/archer-1.mp3"

                Unit.Mage ->
                    Json.string "/clips/mage-1.mp3"
        }
