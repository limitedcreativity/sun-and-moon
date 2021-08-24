port module Ports exposing
    ( log
    , onGridResize
    , sendDayStarted
    , sendEnemiesSpawned
    , sendGameOver
    , sendGameWon
    , sendGuardianBuilt
    , sendLevelCompleted
    , sendNewGameStarted
    , sendNightApproaches
    , sendNightStarted
    )

import Guardian exposing (Guardian)
import Json.Encode as Json


port onGridResize : (Json.Value -> msg) -> Sub msg


port outgoing : { tag : String, data : Json.Value } -> Cmd msg


sendGuardianBuilt : Guardian -> Cmd msg
sendGuardianBuilt guardian =
    playClip
        (case guardian.kind of
            Guardian.Warrior ->
                "onGuardianBuilt.warrior"

            Guardian.Archer ->
                "onGuardianBuilt.archer"

            Guardian.Mage ->
                "onGuardianBuilt.mage"
        )


sendGameWon : Cmd msg
sendGameWon =
    playClip "gameWon"


sendGameOver : Cmd msg
sendGameOver =
    playClip "gameOver"


sendNightStarted : Cmd msg
sendNightStarted =
    playClip "nightStarted"


sendEnemiesSpawned : Cmd msg
sendEnemiesSpawned =
    playClip "enemiesSpawned"


sendLevelCompleted : Cmd msg
sendLevelCompleted =
    playClip "levelCompleted"


playClip : String -> Cmd msg
playClip str =
    outgoing
        { tag = "playClip"
        , data = Json.string str
        }


log : String -> Cmd msg
log error =
    outgoing
        { tag = "log"
        , data = Json.string error
        }


sendNewGameStarted : Cmd msg
sendNewGameStarted =
    outgoing
        { tag = "newGameStarted"
        , data = Json.null
        }


sendDayStarted : Cmd msg
sendDayStarted =
    outgoing
        { tag = "dayStarted"
        , data = Json.null
        }


sendNightApproaches : Cmd msg
sendNightApproaches =
    outgoing
        { tag = "nightApproaches"
        , data = Json.null
        }
