module Queue exposing (Queue, current, fromList, next, noMoreLeft)

{-| Guaranteed to have one item, only has functions for progressing forward
-}


type Queue item
    = Queue
        { current : item
        , after : List item
        }


fromList : List item -> Maybe (Queue item)
fromList items =
    case items of
        [] ->
            Nothing

        head :: tail ->
            Just (Queue { current = head, after = tail })


current : Queue item -> item
current (Queue data) =
    data.current


next : Queue item -> Queue item
next (Queue data) =
    case data.after of
        [] ->
            Queue data

        head :: tail ->
            Queue { current = head, after = tail }


noMoreLeft : Queue item -> Bool
noMoreLeft (Queue data) =
    List.isEmpty data.after
