module Simulate exposing (warrior)

import Action exposing (Action)
import Grid
import World exposing (World)


warrior : { world : World, position : Grid.Position, targets : List Grid.Position, damage : Int } -> Action
warrior { world, position, targets, damage } =
    let
        nearbyTarget =
            targets
                |> List.filter (Grid.isAdjacentTo position)
                |> List.head

        nextMovePosition =
            Grid.nearestWalkableTarget
                { start = position
                , obstacles = World.shrinePosition :: world.enemies ++ world.guardians
                , targets = targets
                }
    in
    case ( nearbyTarget, nextMovePosition ) of
        ( Just target, _ ) ->
            Action.AttackTargetAt damage target

        ( _, Just pos ) ->
            Action.MoveTo pos

        _ ->
            Action.DoNothing