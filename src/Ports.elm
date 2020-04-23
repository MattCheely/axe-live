port module Ports exposing (checkElements, elementSelected, flagErrorElements, notifyChanges, requestPopOut, selectElement, violations)

import Json.Encode exposing (Value)


port violations : (Value -> msg) -> Sub msg


port selectElement : String -> Cmd msg


port flagErrorElements : Value -> Cmd msg


port requestPopOut : Value -> Cmd msg


port elementSelected : (String -> msg) -> Sub msg


port notifyChanges : (Value -> msg) -> Sub msg


port checkElements : Value -> Cmd msg
