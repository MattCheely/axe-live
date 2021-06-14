module ErrorPanel exposing (main)

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
import Css
    exposing
        ( absolute
        , auto
        , backgroundColor
        , backgroundImage
        , backgroundSize
        , borderStyle
        , bottom
        , color
        , cursor
        , fontFamily
        , fontSize
        , height
        , hex
        , int
        , left
        , marginBottom
        , marginLeft
        , marginTop
        , none
        , overflow
        , padding
        , pct
        , pointer
        , position
        , px
        , rgb
        , rgba
        , right
        , sansSerif
        , textAlign
        , top
        , transparent
        , url
        , width
        , zIndex
        )
import Dict
import Html.Styled.Attributes exposing (css, href, id, target)
import Html.Styled.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Encode as Encode
import Ports



-- MODEL


type alias Model =
    Result String A11yReport


type alias A11yReport =
    { problems : PageProblems
    , selectedElement : Maybe String
    , popoutOpen : Bool
    , axeRunning : Bool
    , uncheckedChanges : List MutationRecord
    }


type alias MutationRecord =
    -- TODO: Get rid of the one-field record
    { target : Value
    }


init : Value -> ( Model, Cmd Msg )
init flags =
    case decodeValue modelDecoder flags of
        Ok model ->
            ( Ok model, sendExternalState model )

        Err err ->
            ( Err ("I couldn't understand the output from axe. " ++ Decode.errorToString err)
            , Cmd.none
            )


modelDecoder : Decoder A11yReport
modelDecoder =
    Decode.map5 A11yReport
        (Decode.field "problems" problemsDecoder)
        (Decode.field "selectedElement" (Decode.nullable Decode.string))
        (Decode.oneOf
            [ Decode.field "popoutOpen" Decode.bool
            , Decode.succeed False
            ]
        )
        (Decode.field "axeRunning" Decode.bool)
        (Decode.field "uncheckedChanges" (Decode.list mutationRecordDecoder))


encodeModel : A11yReport -> Value
encodeModel model =
    Encode.object
        [ ( "selectedElement"
          , Maybe.map Encode.string model.selectedElement
                |> Maybe.withDefault Encode.null
          )
        , ( "problems", Axe.encodeProblems model.problems )
        , ( "problemElements"
          , Dict.keys model.problems
                |> Encode.list Encode.string
          )
        , ( "popoutOpen", Encode.bool model.popoutOpen )
        , ( "axeRunning", Encode.bool model.axeRunning )
        , ( "uncheckedChanges", Encode.list mutationRecordEncoder model.uncheckedChanges )
        ]


mutationRecordDecoder : Decoder MutationRecord
mutationRecordDecoder =
    Decode.map MutationRecord
        (Decode.field "target" Decode.value)


mutationRecordEncoder : MutationRecord -> Value
mutationRecordEncoder mutationRecord =
    Encode.object
        [ ( "target", mutationRecord.target ) ]


withProblems : PageProblems -> A11yReport -> A11yReport
withProblems problems model =
    let
        newSelection =
            case Maybe.andThen (\selected -> Dict.get selected problems) model.selectedElement of
                Just _ ->
                    model.selectedElement

                Nothing ->
                    Nothing
    in
    { model | problems = problems, selectedElement = newSelection }



-- MSG


type Msg
    = ElementSelected String
    | UnselectElement
    | PopOut
    | PopIn
    | DomChanged (List MutationRecord)
    | GotViolations PageProblems
    | DisplayError String
    | AxeRunning Bool


updateWrapper : Msg -> Model -> ( Model, Cmd Msg )
updateWrapper msg model =
    case Result.andThen (update msg) model of
        Ok ( report, cmd ) ->
            ( Ok report, cmd )

        Err errMsg ->
            ( Err errMsg, Cmd.none )


update : Msg -> A11yReport -> Result String ( A11yReport, Cmd Msg )
update msg model =
    case msg of
        ElementSelected selector ->
            let
                newModel =
                    { model | selectedElement = Just selector }
            in
            Ok ( newModel, sendExternalState newModel )

        UnselectElement ->
            let
                newModel =
                    { model | selectedElement = Nothing }
            in
            Ok ( newModel, sendExternalState newModel )

        PopOut ->
            let
                newModel =
                    { model | popoutOpen = True }
            in
            Ok ( newModel, sendExternalState newModel )

        PopIn ->
            let
                newModel =
                    { model | popoutOpen = False }
            in
            Ok ( newModel, sendExternalState newModel )

        DomChanged changes ->
            { model | uncheckedChanges = List.append changes model.uncheckedChanges }
                |> runChecksIfNeeded
                |> Ok

        AxeRunning axeRunning ->
            { model | axeRunning = axeRunning }
                |> runChecksIfNeeded
                |> Ok

        GotViolations problems ->
            let
                newModel =
                    model |> withProblems problems
            in
            Ok ( newModel, sendExternalState newModel )

        DisplayError error ->
            Err error


runChecksIfNeeded : A11yReport -> ( A11yReport, Cmd msg )
runChecksIfNeeded model =
    if model.axeRunning == False && not (List.isEmpty model.uncheckedChanges) then
        ( { model | uncheckedChanges = [] }
        , a11yCheck model.uncheckedChanges model.problems
        )

    else
        ( model, Cmd.none )



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
        , textAlign left
        ]


elementListStyle =
    css
        [ backgroundColor transparent
        , color colors.link
        , borderStyle none
        , fontSize (px 16)
        , cursor pointer
        , marginBottom (px 12)
        , textAlign left
        ]


headerStyle =
    css
        [ fontSize (px 24)
        ]


view : Model -> Html Msg
view model =
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
        (case model of
            Ok report ->
                reportView report

            Err errMsg ->
                [ h2 [ headerStyle ] [ text "Oops, something went wrong" ]
                , div [ css [ color (rgb 255 0 0) ] ] [ text errMsg ]
                , div [ css [ marginTop (px 20) ] ]
                    [ text "This is probably a bug in axe-live. Please check the issues on "
                    , a [ linkStyle, href "https://github.com/MattCheely/axe-live/issues" ] [ text "GitHub" ]
                    , text " to see if someone has already opened an issue. If not, please open a new one."
                    ]
                ]
        )


reportView : A11yReport -> List (Html Msg)
reportView model =
    [ if Dict.size model.problems /= 0 then
        case
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

      else
        h2 [] [ text "No problems found. Nice work!" ]
    , popOutIcon model.popoutOpen
    ]


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


sendExternalState : A11yReport -> Cmd msg
sendExternalState model =
    encodeModel model
        |> Ports.updateExternalState


a11yCheck : List MutationRecord -> PageProblems -> Cmd msg
a11yCheck mutations problems =
    Encode.object
        -- On a DOM change, check all the elements that changed for issues
        [ ( "elements", Encode.list identity (List.map .target mutations) )

        -- Also check all the elements that currently have problems,
        -- in case the changes fixed them
        , ( "selectors", Encode.list Encode.string (Dict.keys problems) )
        ]
        |> Ports.checkElements


handleDomChanges : Value -> Msg
handleDomChanges mutationInfo =
    case Decode.decodeValue (Decode.list mutationRecordDecoder) mutationInfo of
        Ok mutationRecords ->
            DomChanged mutationRecords

        Err decodeError ->
            DisplayError
                ("I could not parse a DOM mutation event. "
                    ++ Decode.errorToString decodeError
                )


handleViolationReport : Value -> Msg
handleViolationReport violationJson =
    case decodeValue problemsDecoder violationJson of
        Ok violations ->
            GotViolations violations

        Err err ->
            DisplayError
                ("I couldn't understand the output from axe. "
                    ++ Decode.errorToString err
                )



-- MAIN


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , update = updateWrapper
        , view = view >> toUnstyled
        , subscriptions =
            always
                (Sub.batch
                    [ Ports.elementSelected ElementSelected
                    , Ports.notifyChanges handleDomChanges
                    , Ports.violations handleViolationReport
                    , Ports.popIn (always PopIn)
                    , Ports.axeRunning AxeRunning
                    ]
                )
        }
