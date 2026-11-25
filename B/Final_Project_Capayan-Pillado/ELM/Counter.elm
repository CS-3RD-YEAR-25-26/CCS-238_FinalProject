port module Counter exposing (main)
-- A port module can communicate with JavaScript. Only main is exported.

-- Platform supplies the worker API for programs without a browser view.
import Platform


-- An incoming port wraps a unit-to-message function in a subscription.
port start : (() -> msg) -> Sub msg


-- An outgoing port turns a list of Elm strings into a command.
port report : List String -> Cmd msg


-- type declares the alternatives that can represent a counter event.
type Event
    -- Increment is a constructor carrying an Int amount.
    = Increment Int
    -- Decrement is a separate constructor with the same payload type.
    | Decrement Int
    -- Reset has no payload and is itself a value of type Event.
    | Reset
    


-- This curried signature takes an Event and the current Int total.
step : Event -> Int -> Int
-- The definition gives names to the event and the current total.
step event total =
    -- Each constructor has its own pattern and returns a new total.
    -- case matches Event constructors. Elm checks all alternatives.
    case event of
        -- The Increment pattern binds the Int payload to amount.
        Increment amount ->
            -- The + expression returns a new Int from the two bound values.
            total + amount

        -- The Decrement pattern binds its Int payload to amount.
        Decrement amount ->
            -- The - expression returns the difference as the next total.
            total - amount

        -- The Reset constructor can be matched without binding a payload.
        Reset ->
            -- The reset branch returns the Int literal 0.
            0


-- The return type is a tuple containing an Int and a list of Ints.
replay : Int -> List Event -> ( Int, List Int )
-- initial and events bind the starting total and the event list.
replay initial events =
    -- let introduces helper definitions local to replay.
    let
        -- The tuple parameter pattern splits the accumulator into two names.
        advance event ( current, reversed ) =
            -- A nested let gives the new total a name inside advance.
            let
                -- next is inferred as Int from the application of step.
                next =
                    -- This applies step to the event, then to the old total.
                    step event current
            -- in begins the result of the nested let expression.
            in
            -- The tuple holds the new total and a list built by prepending
            -- with ::.
            ( next, next :: reversed )

        -- The tuple pattern names the two components returned by the fold.
        ( total, history ) =
            -- List.foldl processes events in order using the tuple as an
            -- accumulator.
            List.foldl advance ( initial, [] ) events
    -- in begins the result of replay's outer let expression.
    in
    -- List.reverse restores chronological order. A tuple holds the results.
    ( total, List.reverse history )


-- List Int is the input type, and String is the formatter's result type.
showList : List Int -> String
-- values binds the list supplied to the formatter.
showList values =
    -- List.map converts each Int to String. String.join inserts spaces.
    "(" ++ String.join " " (List.map String.fromInt values) ++ ")"


-- The input type is the total-and-history tuple returned by replay.
showReplay : ( Int, List Int ) -> String
-- The tuple pattern gives the total and history separate names.
showReplay ( total, history ) =
    -- The :: operator prepends the total before the list is formatted.
    showList (total :: history)


-- List String fixes the type of each output line.
lines : List String
-- The definition binds the list produced by the expression below.
lines =
    -- let introduces local definitions for the comparison cases.
    let
        -- snapshot holds an immutable Int computed once for the examples.
        snapshot =
            -- Increment constructs an Event before it is passed to step.
            step (Increment 3) 0

        -- The previous counter value is an explicit input.
        -- tick is a local function taking one explicit total parameter.
        tick total =
            -- The + expression returns the next value. The parameter is
            -- immutable.
            total + 1

        -- The name first binds the result of the first tick call.
        first =
            -- Applying tick to the Int literal 0 makes the initial result.
            tick 0
    -- in begins the list expression that uses the local bindings.
    in
    -- The empty list is inferred as List Event from replay's parameter.
    [ "empty " ++ showReplay (replay 0 [])
    -- The leading comma starts the next item. showReplay formats a tuple.
    , "replay " ++ showReplay
        -- Every constructor application in the list builds an Event value.
        (replay 0 [ Increment 3, Decrement 1, Reset, Decrement 2 ])
    -- The next item applies showList to a list of branch results.
    , "branch " ++ showList
        -- Both calls use the same immutable snapshot as their starting value.
        [ step (Increment 5) snapshot, step Reset snapshot, snapshot ]
    -- Each tick call takes an explicit Int. Reusing 0 gives the same result.
    , "pure-probe " ++ showList [ first, tick first, tick 0 ]
    -- The closing bracket completes the list of output strings.
    ]


-- Program's three unit types specify its flags, model, and messages.
main : Program () () ()
-- An equals sign defines the value main, the program entry point.
main =
    -- Platform.worker takes a record of callbacks and needs no view.
    Platform.worker
        -- The init lambda matches unit and returns a model and no command.
        { init = \() -> ( (), Cmd.none )
        -- The two unit patterns match the message and model. report sends
        -- lines.
        , update = \() () -> ( (), report lines )
        -- The subscription ignores the unit model. identity passes unit
        -- through.
        , subscriptions = \() -> start identity
        -- The closing brace ends the record passed to Platform.worker.
        }
