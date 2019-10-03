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
import Accessibility.Styled.Style exposing (invisible)
import Axe exposing (ElementProblem, PageProblems, problemsDecoder)
import Browser
import Css exposing (..)
import Dict exposing (Dict)
import Html.Styled.Attributes exposing (css, href, id, target)
import Html.Styled.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Encode as Encode
import Ports



-- MODEL


type alias Model =
    { problems : PageProblems
    , selectedElement : Maybe String
    , externalPanel : Bool
    }


init : Value -> ( Model, Cmd Msg )
init flags =
    case decodeValue modelDecoder flags of
        Ok model ->
            ( model, flagProblems model.problems )

        Err err ->
            ( { problems = Dict.empty
              , selectedElement = Nothing
              , externalPanel = False
              }
            , Cmd.none
            )


modelDecoder : Decoder Model
modelDecoder =
    Decode.map3 Model
        (Decode.field "problems" problemsDecoder)
        (Decode.field "selectedElement" (Decode.nullable Decode.string))
        (Decode.oneOf
            [ Decode.field "externalPanel" Decode.bool
            , Decode.succeed False
            ]
        )


encodeModel : Model -> Value
encodeModel model =
    Encode.object
        [ ( "selectedElement"
          , Maybe.map Encode.string model.selectedElement
                |> Maybe.withDefault Encode.null
          )
        , ( "problems", Axe.encodeProblems model.problems )
        , ( "externalPanel", Encode.bool model.externalPanel )
        ]



-- MSG


type Msg
    = ElementSelected String
    | UnselectElement
    | PopOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ElementSelected selector ->
            ( { model | selectedElement = Just selector }
            , Ports.selectElement selector
            )

        UnselectElement ->
            ( { model | selectedElement = Nothing }
            , Ports.selectElement ""
            )

        PopOut ->
            ( model
            , popToWindow { model | externalPanel = True }
            )



-- VIEW


linkHex =
    "0077c8"


colors =
    { text = rgb 255 255 255
    , link = hex linkHex
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
        [ fontSize (px 24)
        ]


view : Model -> Html Msg
view model =
    if Dict.size model.problems /= 0 then
        div
            [ id "axe-live-panel"
            , css
                [ position absolute
                , top (px 0)
                , left (px 0)
                , right (px 0)
                , bottom (px 0)
                , backgroundColor (rgba 0 0 0 0.85)
                , color colors.text
                , padding (px 20)
                , overflow auto
                , zIndex (int 20000)
                , fontFamily sansSerif
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
            , popOutIcon model.externalPanel
            ]

    else
        text ""


popOutIcon : Bool -> Html Msg
popOutIcon isExternal =
    if not isExternal then
        button
            [ css
                [ position absolute
                , top (px 20)
                , right (px 20)
                , height (px 20)
                , width (px 20)
                , backgroundColor transparent
                , backgroundImage (url externalLink)
                , backgroundSize (pct 100)
                , color colors.link
                , borderStyle none
                , padding (px 0)
                , cursor pointer
                ]
            , onClick PopOut
            ]
            [ span invisible [ text "Open in external window" ] ]

    else
        text ""


errorElementListing : PageProblems -> Html Msg
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


elementSummary : ( String, List ElementProblem ) -> Html Msg
elementSummary ( selector, violations ) =
    div []
        [ button
            [ elementListStyle
            , onClick (ElementSelected selector)
            ]
            [ text selector ]
        ]


describeViolations : String -> List ElementProblem -> Html Msg
describeViolations selector violations =
    div []
        [ button [ linkStyle, onClick UnselectElement ] [ text "< Back" ]
        , h2 [ headerStyle ] [ text selector ]
        , div [] (List.map violationSummary violations)
        ]


violationSummary : ElementProblem -> Html Msg
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


{-| Iconic externalLink SVG - licencse held by Matt Cheely
-}
externalLink : String
externalLink =
    "\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' version='1.1' width='32' height='32' data-icon='external-link' viewBox='0 0 32 32'%3E%3Cpath fill='%23" ++ linkHex ++ "' d='M32 0l-8 1 2.438 2.438-9.5 9.5-1.063 1.063 2.125 2.125 1.063-1.063 9.5-9.5 2.438 2.438 1-8zm-30 3c-1.088 0-2 .912-2 2v25c0 1.088.912 2 2 2h25c1.088 0 2-.912 2-2v-15h-3v14h-23v-23h15v-3h-16z' /%3E%3C/svg%3E\""



-- PORTS


popToWindow : Model -> Cmd msg
popToWindow model =
    Ports.requestPopOut (encodeModel model)


flagProblems : PageProblems -> Cmd msg
flagProblems problems =
    Dict.keys problems
        |> Encode.list Encode.string
        |> Ports.flagErrorElements



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = always (Ports.elementSelected ElementSelected)
        }
