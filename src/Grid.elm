module Grid exposing
    ( Position
    , adjacentTargets
    , distanceFrom
    , isAdjacentTo
    , nearestTarget
    , nextPositionTowards
    , withinRange
    )


type alias Position =
    ( Int, Int )


nearestTarget : Position -> List Position -> Maybe Position
nearestTarget position targets =
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
