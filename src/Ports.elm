port module Ports exposing
    ( axeRunning
    , checkElements
    , elementSelected
    , notifyChanges
    , popIn
    , updateExternalState
    , violations
    )

import Json.Encode exposing (Value)



-- inbound


port violations : (Value -> msg) -> Sub msg


port elementSelected : (String -> msg) -> Sub msg


port notifyChanges : (Value -> msg) -> Sub msg


port popIn : (Value -> msg) -> Sub msg


port axeRunning : (Bool -> msg) -> Sub msg



-- outbound


port checkElements : Value -> Cmd msg


port updateExternalState : Value -> Cmd msg
