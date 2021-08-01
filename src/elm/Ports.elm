port module Ports exposing
    ( axeRunning
    , checkElements
    , elementSelected
    , notifyChanges
    , popOut
    , updateExternalState
    , violations
    )

import Json.Encode exposing (Value)



-- Inbound


{-| notifies the main app of changes to the DOM
-}
port notifyChanges : (Value -> msg) -> Sub msg


{-| tells the main app if axe is running or not
-}
port axeRunning : (Bool -> msg) -> Sub msg


{-| reports violations from axe to the main app
-}
port violations : (Value -> msg) -> Sub msg


{-| lets the main app know that an element has been selected via DOM interaction
-}
port elementSelected : (String -> msg) -> Sub msg



-- Outbound


{-| tells external JS to check elements for a11y violations
-}
port checkElements : Value -> Cmd msg


{-| tells external JS to update state in the DOM (mostly styles)
-}
port updateExternalState : Value -> Cmd msg


{-| tells externa JS to move the display to an external window
-}
port popOut : () -> Cmd msg
