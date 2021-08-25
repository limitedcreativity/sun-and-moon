module Settings exposing (Settings, decoder)

import Enemy
import Guardian
import Json.Decode as Json
import Level exposing (Level)
import Queue exposing (Queue)
import Shrine
import Unit


type alias Settings =
    { gameplay : GameplaySettings
    , music : MusicSettings
    }


decoder : Json.Decoder Settings
decoder =
    Json.map2 Settings
        (Json.field "gameplay" gameplaySettingsDecoder)
        (Json.field "music" musicSettingsDecoder)


type alias GameplaySettings =
    { msPerTurn : Int
    , levels : Queue Level
    , startingGold : Int
    , costs : Costs
    , shrine : Shrine.Settings
    , units : Unit.Settings
    }


gameplaySettingsDecoder : Json.Decoder GameplaySettings
gameplaySettingsDecoder =
    Json.field "turnSpeed" Json.int
        |> Json.andThen
            (\msPerTurn ->
                Json.map5 (GameplaySettings msPerTurn)
                    (Json.field "levels" (levelsDecoder msPerTurn))
                    (Json.field "startingGold" Json.int)
                    (Json.field "costs" costsDecoder)
                    (Json.field "shrine" shrineSettingsDecoder)
                    (Json.field "units" unitSettingsDecoder)
            )


shrineSettingsDecoder : Json.Decoder Shrine.Settings
shrineSettingsDecoder =
    Json.map Shrine.Settings
        (Json.field "health" Json.int)


type alias Costs =
    { warrior : Int
    , archer : Int
    , mage : Int
    }


costsDecoder : Json.Decoder Costs
costsDecoder =
    Json.map3 Costs
        (Json.field "warrior" Json.int)
        (Json.field "archer" Json.int)
        (Json.field "mage" Json.int)


levelsDecoder : Int -> Json.Decoder (Queue Level)
levelsDecoder msPerTurn =
    Json.list (Level.decoder msPerTurn)
        |> Json.map Queue.fromList
        |> Json.andThen (Maybe.map Json.succeed >> Maybe.withDefault (Json.fail "Levels list was empty"))


type alias MusicSettings =
    { nightFadeDuration : Int
    }


musicSettingsDecoder : Json.Decoder MusicSettings
musicSettingsDecoder =
    Json.map MusicSettings
        (Json.field "nightFadeDuration" Json.int)


unitSettingsDecoder : Json.Decoder Unit.Settings
unitSettingsDecoder =
    Json.map2 Unit.Settings
        (Json.field "guardian" guardianSettingsDecoder)
        (Json.field "enemy" enemySettingsDecoder)


guardianSettingsDecoder : Json.Decoder Guardian.Settings
guardianSettingsDecoder =
    Json.map3 Guardian.Settings
        (Json.field "warrior" warriorSettingsDecoder)
        (Json.field "archer" archerSettingsDecoder)
        (Json.field "mage" mageSettingsDecoder)


enemySettingsDecoder : Json.Decoder Enemy.Settings
enemySettingsDecoder =
    guardianSettingsDecoder


type alias WarriorSettings =
    { health : Int
    , damage : Int
    }


warriorSettingsDecoder : Json.Decoder WarriorSettings
warriorSettingsDecoder =
    Json.map2 WarriorSettings
        (Json.field "health" Json.int)
        (Json.field "damage" Json.int)


type alias ArcherSettings =
    { health : Int
    , damage : Int
    , range : Int
    }


archerSettingsDecoder : Json.Decoder ArcherSettings
archerSettingsDecoder =
    Json.map3 ArcherSettings
        (Json.field "health" Json.int)
        (Json.field "damage" Json.int)
        (Json.field "range" Json.int)


type alias MageSettings =
    { health : Int
    , damage : Int
    , range : Int
    }


mageSettingsDecoder : Json.Decoder MageSettings
mageSettingsDecoder =
    Json.map3 MageSettings
        (Json.field "health" Json.int)
        (Json.field "damage" Json.int)
        (Json.field "range" Json.int)
