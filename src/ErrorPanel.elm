port module ErrorPanel exposing (main)

import Accessibility.Styled as Html
    exposing
        ( Html
        , a
        , button
        , details
        , div
        , h2
        , span
        , summary
        , text
        , toUnstyled
        )
import Browser
import Css exposing (..)
import Dict exposing (Dict)
import Html.Styled.Attributes exposing (css, href, id, target)
import Html.Styled.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)



-- MODEL


type alias Model =
    { problems : Dict String (List Violation)
    , selectedElement : Maybe String
    }


type alias Violation =
    { help : String
    , helpUrl : String
    , failureSummary : String
    }


init : Value -> ( Model, Cmd Msg )
init flags =
    case decodeValue modelDecoder flags of
        Ok problems ->
            ( { problems = problems
              , selectedElement = Nothing
              }
            , Cmd.none
            )

        Err err ->
            ( { problems = Dict.empty, selectedElement = Nothing }, Cmd.none )


modelDecoder : Decoder (Dict String (List Violation))
modelDecoder =
    Decode.dict
        (Decode.list
            (Decode.map3 Violation
                (Decode.field "help" Decode.string)
                (Decode.field "helpUrl" Decode.string)
                (Decode.field "failureSummary" Decode.string)
            )
        )



-- MSG


type Msg
    = SelectedElement String
    | RequestSelection String
    | UnselectElement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedElement selector ->
            ( { model | selectedElement = Just selector }, Cmd.none )

        RequestSelection selector ->
            ( model, requestSelection selector )

        UnselectElement ->
            ( model, requestSelection "" )



-- VIEW


colors =
    { text = rgb 255 255 255
    , link = hex "0077c8"
    }


textStyle =
    css
        [ backgroundColor transparent
        , color colors.text
        , fontSize (px 16)
        ]


linkStyle =
    css
        [ backgroundColor transparent
        , color colors.link
        , borderStyle none
        , fontSize (px 16)
        , cursor pointer
        ]


elementListStyle =
    css
        [ backgroundColor transparent
        , color colors.link
        , borderStyle none
        , fontSize (px 16)
        , cursor pointer
        , marginBottom (px 12)
        ]


headerStyle =
    css
        [ backgroundColor transparent
        , color colors.text
        , fontSize (px 24)
        ]


view : Model -> Html Msg
view model =
    if Dict.size model.problems /= 0 then
        div
            [ id "axe-live-panel"
            , css
                [ position fixed
                , right (vw 10)
                , bottom (vh 0)
                , left (vw 10)
                , maxHeight (vh 90)
                , backgroundColor (rgba 0 0 0 0.85)
                , color colors.text
                , padding (px 20)
                , overflow auto
                , zIndex (int 20000)
                ]
            ]
            [ case
                model.selectedElement
                    |> Maybe.andThen
                        (\elem ->
                            Dict.get elem model.problems
                                |> Maybe.map (\violations -> ( elem, violations ))
                        )
              of
                Just ( selector, violations ) ->
                    describeViolations selector violations

                Nothing ->
                    errorElementListing model.problems
            ]

    else
        text ""


errorElementListing : Dict String (List Violation) -> Html Msg
errorElementListing elements =
    let
        count =
            Dict.size elements

        title =
            if count > 1 then
                String.fromInt count ++ " elements have issues"

            else
                "One element has issues"
    in
    div []
        [ h2 [ headerStyle ] [ text title ]
        , div [] (List.map elementSummary (Dict.toList elements))
        ]


elementSummary : ( String, List Violation ) -> Html Msg
elementSummary ( selector, violations ) =
    div []
        [ button
            [ elementListStyle
            , onClick (RequestSelection selector)
            ]
            [ text selector ]
        ]


describeViolations : String -> List Violation -> Html Msg
describeViolations selector violations =
    div []
        [ button [ linkStyle, onClick UnselectElement ] [ text "< Back" ]
        , h2 [ headerStyle ] [ text selector ]
        , div [] (List.map violationSummary violations)
        ]


violationSummary : Violation -> Html Msg
violationSummary violation =
    details
        [ css
            [ color (rgb 255 255 255)
            , cursor pointer
            , marginBottom (px 16)
            ]
        ]
        [ summary
            []
            [ span [ textStyle ] [ text violation.help ]
            , text " "
            , a
                [ linkStyle
                , href violation.helpUrl
                , target "blank"
                ]
                [ text "learn more.." ]
            ]
        , div [ css [ marginLeft (px 16) ] ]
            [ Html.pre [ textStyle ]
                [ text violation.failureSummary ]
            ]
        ]



-- PORTS


port requestSelection : String -> Cmd msg


port selectedElement : (String -> msg) -> Sub msg



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = always (selectedElement SelectedElement)
        }
