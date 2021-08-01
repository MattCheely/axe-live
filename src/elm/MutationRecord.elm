module MutationRecord exposing (MutationRecord, decoder)

{-| The mutation record module is just a light wrapper around the external
JS type. We only really need to access the target element in order to pass
it back out to JS land for axe to check
-}

import Json.Decode as Decode exposing (Decoder, Value)


type alias MutationRecord =
    { target : Value
    }


decoder : Decoder MutationRecord
decoder =
    Decode.map MutationRecord
        (Decode.field "target" Decode.value)
