module Action exposing (Action(..))

import Grid


type Action
    = MoveTo Grid.Position
    | AttackTargetAt Int Grid.Position
    | HealTargetAt Int Grid.Position
    | DoNothing
