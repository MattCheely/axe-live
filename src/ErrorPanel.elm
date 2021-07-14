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
        , borderBox
        , borderStyle
        , bottom
        , boxSizing
        , color
        , column
        , cursor
        , displayFlex
        , flexDirection
        , flexEnd
        , fontFamily
        , fontSize
        , height
        , hex
        , int
        , justifyContent
        , left
        , margin
        , margin4
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
import Css.Global exposing (body, class, everything, global)
import Dict
import Html.Styled.Attributes exposing (css, href, id, target, title)
import Html.Styled.Events exposing (onClick)
import Icon
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Encode as Encode
import Ports
import Style



-- MODEL


type alias Model =
    Result String A11yReport


type alias A11yReport =
    { problems : PageProblems
    , selectedElement : Maybe String
    , checkOnChange : Bool
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
    Decode.map6 A11yReport
        (Decode.field "problems" problemsDecoder)
        (Decode.field "selectedElement" (Decode.nullable Decode.string))
        (Decode.oneOf
            [ Decode.field "checkOnChange" Decode.bool
            , Decode.succeed True
            ]
        )
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
        , ( "checkOnChange", Encode.bool model.checkOnChange )
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
    | ToggleCheckOnChange
    | DomChanged (List MutationRecord)
    | RunAxe
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

        ToggleCheckOnChange ->
            let
                newModel =
                    { model | checkOnChange = not model.checkOnChange }
            in
            if newModel.checkOnChange then
                let
                    ( checkedModel, checkCmd ) =
                        runChecksIfNeeded newModel
                in
                Ok
                    ( checkedModel
                    , Cmd.batch
                        [ checkCmd
                        , sendExternalState checkedModel
                        ]
                    )

            else
                Ok ( newModel, sendExternalState newModel )

        DomChanged changes ->
            let
                newModel =
                    { model | uncheckedChanges = List.append changes model.uncheckedChanges }
            in
            if model.checkOnChange then
                newModel
                    |> runChecksIfNeeded
                    |> Ok

            else
                Ok ( newModel, Cmd.none )

        RunAxe ->
            model |> runChecksIfNeeded |> Ok

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


globalStyles : Html Msg
globalStyles =
    global
        [ everything
            [ boxSizing borderBox ]
        , body
            [ margin (px 0) ]
        , class "iconic-property-stroke"
            [ Css.property "stroke" "currentcolor" ]
        , class "iconic-property-fill"
            [ Css.property "fill" "currentcolor" ]
        ]


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
        , marginTop (px 0)
        , marginBottom (px 20)
        ]


edgePadding =
    padding (px 10)


view : Model -> Html Msg
view model =
    div
        [ id "axe-live-panel"
        , css
            [ displayFlex
            , flexDirection column
            , backgroundColor (rgba 0 0 0 0.85)
            , color colors.text
            , fontFamily sansSerif
            , height (pct 100)
            ]
        ]
        (globalStyles
            :: (case model of
                    Ok report ->
                        [ controlsView report, reportView report ]

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
        )


controlsView : A11yReport -> Html Msg
controlsView model =
    div
        [ css
            [ edgePadding
            , displayFlex
            , justifyContent flexEnd
            ]
        ]
        [ autoCheckControl model.checkOnChange
        , checkControl model.axeRunning
        , popOutControl model.popoutOpen
        , Debug.todo "Controls don't work in popout window"
        ]


reportView : A11yReport -> Html Msg
reportView model =
    div
        [ css
            [ overflow auto
            , edgePadding
            ]
        ]
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
        ]


autoCheckControl : Bool -> Html Msg
autoCheckControl autoCheckOn =
    if autoCheckOn then
        controlButton "Automatic checks enabled. Click to disable"
            Icon.eye
            ToggleCheckOnChange

    else
        controlButton "Automatic checks disabled. Click to enable"
            Icon.eyeClosed
            ToggleCheckOnChange


checkControl : Bool -> Html Msg
checkControl axeRunning =
    if axeRunning then
        controlButton "Accessibility checks are running"
            (div [ css [ Style.spin 1 ] ] [ Icon.loopCircular ])
            RunAxe

    else
        controlButton "Run accessibility checks now"
            Icon.loopCircular
            RunAxe


popOutControl : Bool -> Html Msg
popOutControl isExternal =
    if not isExternal then
        controlButton "Open in external window" Icon.externalLink PopOut

    else
        text ""


controlButton : String -> Html Msg -> Msg -> Html Msg
controlButton alt icon msg =
    button
        [ title alt
        , css
            [ height (px 20)
            , width (px 20)
            , backgroundColor transparent
            , backgroundSize (pct 100)
            , color colors.link
            , borderStyle none
            , padding (px 0)
            , margin4 (px 0) (px 0) (px 0) (px 10)
            , cursor pointer
            ]
        , onClick msg
        ]
        [ icon
        ]


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
