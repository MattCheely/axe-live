port module Ports exposing (elementSelected, flagErrorElements, requestPopOut, selectElement)

import Json.Encode exposing (Value)


port selectElement : String -> Cmd msg


port flagErrorElements : Value -> Cmd msg


port requestPopOut : Value -> Cmd msg


port elementSelected : (String -> msg) -> Sub msg
