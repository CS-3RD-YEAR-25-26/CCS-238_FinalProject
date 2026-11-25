port module Offset exposing (main)
-- A port module can communicate with JavaScript. Only main is exported.

-- Platform supplies the worker API for programs without a browser view.
import Platform


-- An incoming port wraps a unit-to-message function in a subscription.
port start : (() -> msg) -> Sub msg


-- An outgoing port turns a list of Elm strings into a command.
port report : List String -> Cmd msg


-- The arrows describe a curried function. Giving one Int returns a function.
makeOffset : Int -> Int -> Int
-- Each parameter name introduces a binding scoped to this function.
makeOffset offset reading =
    -- The + operator uses the captured offset and the current reading.
    offset + reading


-- Parentheses group Int -> Int as one function-valued argument.
underShadow : (Int -> Int) -> Int -> Int -> List String
-- The parameter offset has its own scope alongside the function add.
underShadow add offset reading =
    -- List brackets begin a list of strings. ++ joins the label and value.
    [ "caller-offset " ++ String.fromInt offset
    -- The comma separates list elements. The call to add uses its own scope.
    , "shadowed-call " ++ String.fromInt (add reading)
    -- The closing bracket completes the list of formatted results.
    ]


-- List Int describes a homogeneous list. The result type is String.
showList : List Int -> String
-- The name values binds the list passed to showList.
showList values =
    -- List.map converts each Int to String. String.join inserts spaces.
    "(" ++ String.join " " (List.map String.fromInt values) ++ ")"


-- List String fixes the type of every element of lines.
lines : List String
-- This definition binds the list produced by the expression below.
lines =
    -- let introduces local definitions for the result after in.
    let
        -- One argument gives a new function that retains the offset.
        -- Elm infers addThree has type Int -> Int from partial application.
        addThree =
            -- Supplying only 3 to makeOffset returns a function that retains
            -- 3.
            makeOffset 3

        -- Elm infers the type of this local binding from its list elements.
        readings =
            -- Brackets create a list of Int values. -2 is a negative literal.
            [ 0, 4, -2 ]
    -- in starts the expression that uses the local bindings.
    in
    -- List.map applies the same closure to each element of readings.
    [ "map " ++ showList (List.map addThree readings) ]
        -- Here ++ appends two lists. The closure keeps the offset it captured.
        ++ underShadow addThree 100 4
        -- The parentheses group a negative argument before applying
        -- makeOffset.
        ++ [ "second-closure " ++ String.fromInt (makeOffset (-2) 4)
           -- The empty list is valid input to map and yields an empty list.
           , "empty " ++ showList (List.map addThree [])
           -- This bracket closes the list appended to the earlier results.
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
