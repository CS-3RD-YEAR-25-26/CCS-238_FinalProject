port module Validation exposing (main)
-- A port module can communicate with JavaScript. Only main is exported.

-- Platform supplies the worker API for programs without a browser view.
import Platform


-- An incoming port wraps a unit-to-message function in a subscription.
port start : (() -> msg) -> Sub msg


-- An outgoing port turns a list of Elm strings into a command.
port report : List String -> Cmd msg


-- type introduces a custom type for the validation failures.
type Rejection
    -- Malformed is the first constructor. It carries no extra value.
    = Malformed
    -- The vertical bar introduces another constructor with no payload.
    | Negative


-- The type signature says the text check returns a Bool.
decimalText : String -> Bool
-- The input String is bound to the local name text.
decimalText text =
    -- let begins local bindings used by the Boolean expression after in.
    let
        -- digits names the String returned by the conditional expression.
        digits =
            -- if requires a Bool. String.startsWith checks for a minus prefix.
            if String.startsWith "-" text then
                -- String.dropLeft takes the count followed by the source
                -- String.
                String.dropLeft 1 text

            -- else supplies the other result of the expression, also a String.
            else
                -- This branch returns the parameter text itself.
                text

        -- width is a local name whose type Elm infers as Int.
        width =
            -- String.length returns the number of characters as an Int.
            String.length digits
    -- in ends the bindings and starts the expression that returns a Bool.
    in
    -- The <= comparisons produce Bool values, and && combines them.
    1 <= width && width <= 6
        -- String.all applies a character predicate written as a lambda.
        && String.all (\ch -> '0' <= ch && ch <= '9') digits


-- Result Rejection Int specifies the possible error and success types.
validateReading : String -> Result Rejection Int
-- input binds the String supplied by the caller.
validateReading input =
    -- An if expression selects the result. not flips the Boolean check.
    if not (decimalText input) then
        -- Err wraps the Malformed constructor as a Result error.
        Err Malformed

    -- The else branch must produce the same Result type.
    else
        -- Maybe requires a branch for parse failure after the guard.
        -- String.toInt returns Maybe Int. case matches its constructors.
        case String.toInt input of
            -- The Just pattern binds the Int carried inside the constructor.
            Just value ->
                -- A numeric comparison supplies the condition for another if.
                if value < 0 then
                    -- Err wraps Negative to indicate the parsed Int failed the
                    -- range check.
                    Err Negative

                -- This else branch handles the other outcome of the
                -- comparison.
                else
                    -- Ok wraps the parsed Int as a success value.
                    Ok value

            -- The Nothing pattern matches a parse result with no Int payload.
            Nothing ->
                -- The parse-failure branch also returns a Result error.
                Err Malformed


-- The formatter accepts the same Result type the validator returns.
showResult : Result Rejection Int -> String
-- result is the parameter bound to the Result being formatted.
showResult result =
    -- case checks the Result and its nested constructor patterns.
    case result of
        -- The Ok pattern binds its Int payload to value.
        Ok value ->
            -- String.fromInt converts the number before ++ joins the strings.
            "(accepted " ++ String.fromInt value ++ ")"

        -- This nested pattern matches Err containing Malformed specifically.
        Err Malformed ->
            -- The branch returns a String literal for that error case.
            "(malformed)"

        -- This nested pattern covers Err containing Negative.
        Err Negative ->
            -- A String literal completes the last case branch.
            "(negative)"


-- List String declares a list whose elements are formatted lines.
lines : List String
-- The definition binds the evaluated list to lines.
lines =
    -- The list uses quotes to keep even numeric-looking fixtures as Strings.
    [ "42", "0", "-0", "-3", "4.5", "#x10", "oops", ""
    -- The leading comma adds elements. The space inside " 7" is preserved.
    , " 7", "1/2", "999999", "1000000"
    -- The closing bracket finishes the fixture list before the pipeline.
    ]
        -- The |> operator feeds that list to List.map. The lambda formats
        -- input.
        |> List.map (\input -> "\"" ++ input ++ "\" -> "
            -- Function application passes the validation Result to showResult.
            ++ showResult (validateReading input)
           -- This parenthesis closes the lambda argument supplied to List.map.
           )


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
