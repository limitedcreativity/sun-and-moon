module Action exposing (Action(..))

import Grid


type Action
    = MoveTo Grid.Position
    | AttackTargetAt Grid.Position
    | DoNothing
