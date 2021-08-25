module Queue exposing (Queue, completed, current, fromList, next, noMoreLeft, remaining)

{-| Guaranteed to have one item, only has functions for progressing forward
-}


type Queue item
    = Queue
        { before : List item
        , current : item
        , after : List item
        }


fromList : List item -> Maybe (Queue item)
fromList items =
    case items of
        [] ->
            Nothing

        head :: tail ->
            Just (Queue { before = [], current = head, after = tail })


current : Queue item -> item
current (Queue data) =
    data.current


next : Queue item -> Queue item
next (Queue data) =
    case data.after of
        [] ->
            Queue data

        head :: tail ->
            Queue
                { before = data.current :: data.before
                , current = head
                , after = tail
                }


noMoreLeft : Queue item -> Bool
noMoreLeft =
    remaining >> (==) 0


completed : Queue item -> Int
completed (Queue data) =
    List.length data.before


remaining : Queue item -> Int
remaining (Queue data) =
    List.length data.after
