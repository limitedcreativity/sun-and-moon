module Grid exposing
    ( Position
    , adjacentTargets
    , distanceFrom
    , isAdjacentTo
    , nearestShootableTarget
    , nearestWalkableTarget
    , nextPositionTowards
    , size
    , withinRange
    )

import AStar
import Set exposing (Set)


size : Int
size =
    9


type alias Position =
    ( Int, Int )


nearestShootableTarget : Position -> List Position -> Maybe Position
nearestShootableTarget position targets =
    let
        findNearest : Position -> Maybe Position -> Maybe Position
        findNearest newPosition maybeExisting =
            case maybeExisting of
                Nothing ->
                    Just newPosition

                Just existingPosition ->
                    if distanceFrom existingPosition position > distanceFrom newPosition position then
                        Just newPosition

                    else
                        maybeExisting
    in
    List.foldl findNearest Nothing targets


adjacentTargets : Position -> List Position -> List Position
adjacentTargets position targets =
    List.filter (isAdjacentTo position) targets


nextPositionTowards : Position -> Position -> Position
nextPositionTowards target current =
    let
        ( tx, ty ) =
            target

        ( cx, cy ) =
            current
    in
    Tuple.mapBoth ((+) cx)
        ((+) cy)
        ( if tx < cx then
            -1

          else if tx > cx then
            1

          else
            0
        , if ty < cy then
            -1

          else if ty > cy then
            1

          else
            0
        )


distanceFrom : Position -> Position -> Int
distanceFrom ( p1x, p1y ) ( p2x, p2y ) =
    max
        (abs (p1x - p2x))
        (abs (p1y - p2y))


isAdjacentTo : Position -> Position -> Bool
isAdjacentTo =
    withinRange 1


withinRange : Int -> Position -> Position -> Bool
withinRange range ( p1x, p1y ) ( p2x, p2y ) =
    abs (p1x - p2x) <= range && abs (p1y - p2y) <= range


nearestWalkableTarget : { start : Position, obstacles : List Position, targets : List Position } -> Maybe Position
nearestWalkableTarget { start, obstacles, targets } =
    targets
        |> List.filterMap
            (\target ->
                AStar.findPath
                    AStar.pythagoreanCost
                    (adjacentExceptFor (Set.fromList obstacles |> Set.remove target))
                    start
                    target
            )
        |> List.sortBy (List.length >> negate)
        |> List.head
        |> Maybe.andThen List.head


adjacentExceptFor : Set Position -> Position -> Set Position
adjacentExceptFor obstacles position =
    Set.diff
        (adjacentTiles position)
        obstacles


adjacentTiles : Position -> Set Position
adjacentTiles ( x, y ) =
    Set.fromList
        [ ( x - 1, y - 1 )
        , ( x, y - 1 )
        , ( x + 1, y - 1 )
        , ( x - 1, y )
        , ( x + 1, y )
        , ( x - 1, y + 1 )
        , ( x, y + 1 )
        , ( x + 1, y + 1 )
        ]
        |> Set.filter isInBounds


isInBounds : Position -> Bool
isInBounds ( x, y ) =
    (x >= 0 && x < size) && (y >= 0 && y < size)
