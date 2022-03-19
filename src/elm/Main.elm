module Main exposing (main)

{-| This is where the main axe-live behavior and user-interaction code lives.
This is in contrast to the TypeScript code, which primarily manages briding to
the axe library, watching for DOM changes, and doing DOM/CSSOM manipulation in
the application under test
-}

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
import Axe exposing (ElementProblem, PageProblems, problemsDecoder)
import Browser
import Css
    exposing
        ( auto
        , backgroundColor
        , borderStyle
        , color
        , column
        , cursor
        , display
        , displayFlex
        , flexDirection
        , flexEnd
        , fontFamily
        , height
        , justifyContent
        , lineHeight
        , margin
        , margin4
        , marginBottom
        , marginLeft
        , marginRight
        , marginTop
        , none
        , overflow
        , padding
        , pct
        , pointer
        , px
        , rgb
        , rgba
        , sansSerif
        , spaceBetween
        , transparent
        )
import Dict
import Html.Styled.Attributes exposing (css, href, id, target, title)
import Html.Styled.Events exposing (onBlur, onClick, onFocus, onMouseEnter, onMouseLeave)
import Icon
import Json.Decode as Decode exposing (Value, decodeValue)
import Json.Encode as Encode
import MutationRecord exposing (MutationRecord)
import Ports
import Style exposing (colors, edgePadding, elementButtonStyle, headerStyle, hiddenWhenMinimized, linkStyle, textStyle, visibleWhenMinimized)



-- MODEL


type alias Model =
    { interopError : Maybe String
    , a11yProblems : PageProblems
    , selectedElement : Maybe String
    , focusedElement : Maybe String
    , checkOnChange : Bool
    , axeRunning : Bool
    , uncheckedChanges : List MutationRecord
    }


{-| Add a list of a11y problems to the model, clearing the selected element if
it no longer has any problems
-}
withProblems : PageProblems -> Model -> Model
withProblems problems model =
    let
        newSelection =
            model.selectedElement
                |> Maybe.andThen (\selected -> Dict.get selected problems)
                |> Maybe.andThen (always model.selectedElement)
    in
    { model | a11yProblems = problems, selectedElement = newSelection }


selectedItemProblems : Model -> Maybe (List ElementProblem)
selectedItemProblems model =
    model.selectedElement
        |> Maybe.andThen
            (\selected ->
                Dict.get selected model.a11yProblems
            )


type alias Flags =
    { checkOnChange : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { interopError = Nothing
      , a11yProblems = Dict.empty
      , selectedElement = Nothing
      , focusedElement = Nothing
      , checkOnChange = flags.checkOnChange
      , axeRunning = True
      , uncheckedChanges = []
      }
    , runInitialChecks
    )


runInitialChecks : Cmd Msg
runInitialChecks =
    Ports.checkElements Encode.null



-- UPDATE


type Msg
    = ElementSelected String
    | UnselectElementClicked
    | PopOutClicked
    | ToggleAutoCheckClicked
    | RunAxeClicked
    | MinimizeClicked
    | MaximizeClicked
    | SelectorFocused String
    | SelectorUnfocused
    | GotDomChanges (List MutationRecord)
    | GotViolations PageProblems
    | GotAxeRunning Bool
    | ErrorEncountered String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ElementSelected selector ->
            let
                newModel =
                    { model
                        | selectedElement = Just selector
                        , focusedElement = Nothing
                    }
            in
            ( newModel
            , Cmd.batch
                [ sendExternalState newModel
                , Ports.setMinimized False
                ]
            )

        UnselectElementClicked ->
            let
                newModel =
                    { model | selectedElement = Nothing }
            in
            ( newModel, sendExternalState newModel )

        SelectorFocused selector ->
            let
                newModel =
                    { model | focusedElement = Just selector }
            in
            ( newModel, sendExternalState newModel )

        SelectorUnfocused ->
            let
                newModel =
                    { model | focusedElement = Nothing }
            in
            ( newModel, sendExternalState newModel )

        PopOutClicked ->
            ( model, popOut )

        MinimizeClicked ->
            ( model, Ports.setMinimized True )

        MaximizeClicked ->
            ( model, Ports.setMinimized False )

        ToggleAutoCheckClicked ->
            let
                newModel =
                    { model | checkOnChange = not model.checkOnChange }
            in
            if newModel.checkOnChange then
                runChecksIfNeeded newModel

            else
                ( newModel, sendExternalState newModel )

        GotDomChanges changes ->
            let
                newModel =
                    { model | uncheckedChanges = List.append changes model.uncheckedChanges }
            in
            if model.checkOnChange then
                runChecksIfNeeded newModel

            else
                ( newModel, Cmd.none )

        RunAxeClicked ->
            runChecksIfNeeded model

        GotAxeRunning axeRunning ->
            { model | axeRunning = axeRunning }
                |> runChecksIfNeeded

        GotViolations problems ->
            let
                newModel =
                    model |> withProblems problems
            in
            ( newModel, sendExternalState newModel )

        ErrorEncountered error ->
            ( { model | interopError = Just error }, Cmd.none )


{-| Requests a11y checks from JS if there are unchecked changes and axe is not
already running. TODO: Maybe it is possible we don't check everything if we
get our last changes while axe is running? Could fix by re-calling this when
we get violations.
-}
runChecksIfNeeded : Model -> ( Model, Cmd msg )
runChecksIfNeeded model =
    if model.axeRunning == False && not (List.isEmpty model.uncheckedChanges) then
        ( { model | uncheckedChanges = [] }
        , checkChanges model.uncheckedChanges model.a11yProblems
        )

    else
        ( model, Cmd.none )


{-| Sends any state that may need to trigger actions in JS
-}
sendExternalState : Model -> Cmd msg
sendExternalState model =
    Encode.object
        [ ( "selectedElement"
          , Maybe.map Encode.string model.selectedElement
                |> Maybe.withDefault Encode.null
          )
        , ( "focusedElement"
          , Maybe.map Encode.string model.focusedElement
                |> Maybe.withDefault Encode.null
          )
        , ( "problemElements"
          , Dict.keys model.a11yProblems
                |> Encode.list Encode.string
          )
        ]
        |> Ports.updateExternalState


{-| Tells JS to pop out the embedded frame into a separate window
-}
popOut : Cmd msg
popOut =
    Ports.popOut ()


{-| Tell JS to run axe against elements that need to be checked
-}
checkChanges : List MutationRecord -> PageProblems -> Cmd msg
checkChanges mutations problems =
    Encode.object
        -- On a DOM change, check all the elements that changed for issues
        [ ( "elements", Encode.list identity (List.map .target mutations) )

        -- Also check all the elements that currently have problems,
        -- in case the changes fixed them
        , ( "selectors", Encode.list Encode.string (Dict.keys problems) )
        ]
        |> Ports.checkElements



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.85)
            , color colors.text
            , fontFamily sansSerif
            ]
        ]
        [ div
            [ id "minimized-controls"
            , css
                [ display none
                , visibleWhenMinimized
                , height (pct 100)
                ]
            ]
            [ minimizedView model ]
        , div
            [ id "axe-live-panel"
            , css
                [ hiddenWhenMinimized
                , displayFlex
                , flexDirection column
                , height (pct 100)
                ]
            ]
            (Style.global
                :: (case model.interopError of
                        Nothing ->
                            [ controlsView model, reportView model ]

                        Just errMsg ->
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
        ]


titleView : Model -> Html Msg
titleView model =
    let
        problemCount =
            Dict.size model.a11yProblems

        heading =
            \content -> h2 [ css [ margin (px 0) ] ] [ text content ]
    in
    case model.selectedElement of
        Just selector ->
            div []
                [ button [ linkStyle, onClick UnselectElementClicked ] [ text "< Back" ]
                , h2 [ headerStyle ] [ text selector ]
                ]

        Nothing ->
            if problemCount == 1 then
                heading "1 element has issues"

            else if problemCount > 1 then
                heading (String.fromInt problemCount ++ " elements have issues")

            else if not model.axeRunning then
                heading "No problems found. Nice work!"

            else
                heading "Running Checks..."


controlsView : Model -> Html Msg
controlsView model =
    div
        [ css
            [ edgePadding
            , displayFlex
            , justifyContent spaceBetween
            ]
        ]
        [ titleView model
        , div
            [ css
                [ displayFlex
                , justifyContent flexEnd
                ]
            ]
            [ autoCheckControl model.checkOnChange
            , checkControl model
            , popOutControl
            , minimizeControl
            ]
        ]


reportView : Model -> Html Msg
reportView model =
    div
        [ css
            [ overflow auto
            , edgePadding
            ]
        ]
        [ if Dict.size model.a11yProblems > 0 then
            case selectedItemProblems model of
                Just violations ->
                    div [] (List.map violationSummary violations)

                Nothing ->
                    div [] (List.map elementSummary (Dict.toList model.a11yProblems))

          else
            text ""
        ]


minimizedView : Model -> Html Msg
minimizedView model =
    let
        problemCount =
            Dict.size model.a11yProblems

        countText =
            if problemCount > 99 then
                "99+"

            else
                problemCount
                    |> String.fromInt
    in
    div
        [ css
            [ height (pct 100)
            , padding (px 10)
            , displayFlex
            , justifyContent spaceBetween
            ]
        ]
        [ if problemCount > 0 then
            problemSummary countText

          else
            div [ css [ color Style.colors.success ] ]
                [ inlineIcon Icon.check ]
        , div []
            [ controlButton "maximize"
                "Expand error view."
                Icon.maximize
                MaximizeClicked
            ]
        ]


problemSummary : String -> Html Msg
problemSummary countText =
    div
        [ css
            [ displayFlex
            , color Style.colors.error
            , lineHeight (px 20)
            ]
        ]
        [ inlineIcon Icon.alert
        , text countText
        ]


inlineIcon icon =
    div [ css [ Style.iconSize, marginRight (px 5) ] ]
        [ icon ]


autoCheckControl : Bool -> Html Msg
autoCheckControl autoCheckOn =
    if autoCheckOn then
        controlButton "disable-auto-check"
            "Automatic checks enabled. Click to disable."
            Icon.eye
            ToggleAutoCheckClicked

    else
        controlButton "enable-auto-check"
            "Automatic checks disabled. Click to enable."
            Icon.eyeClosed
            ToggleAutoCheckClicked


checkControl : Model -> Html Msg
checkControl model =
    let
        ( message, icon ) =
            if model.axeRunning then
                ( "Accessibility checks are running."
                , div [ css [ Style.spin 1 ] ] [ Icon.loopCircular ]
                )

            else if not (List.isEmpty model.uncheckedChanges) then
                ( String.fromInt (List.length model.uncheckedChanges) ++ " unchecked changes. Click to check now."
                , Icon.loopCircular
                )

            else
                ( "Nothing to check.", Icon.check )
    in
    controlButton "run-checks" message icon RunAxeClicked


popOutControl : Html Msg
popOutControl =
    controlButton "popout-button"
        "Open in external window"
        Icon.externalLink
        PopOutClicked


minimizeControl : Html Msg
minimizeControl =
    controlButton "minimize-button"
        "Minimize error display"
        Icon.minimize
        MinimizeClicked


controlButton : String -> String -> Html Msg -> Msg -> Html Msg
controlButton idStr alt icon msg =
    button
        [ id idStr
        , title alt
        , css
            [ Style.iconSize
            , backgroundColor transparent
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


elementSummary : ( String, List ElementProblem ) -> Html Msg
elementSummary ( selector, violations ) =
    div []
        [ button
            [ elementButtonStyle
            , onClick (ElementSelected selector)
            , onMouseEnter (SelectorFocused selector)
            , onMouseLeave SelectorUnfocused
            , onFocus (SelectorFocused selector)
            , onBlur SelectorUnfocused
            ]
            [ text selector ]
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



-- SUBSCRIPTIONS


handleDomChanges : Value -> Msg
handleDomChanges mutationInfo =
    case Decode.decodeValue (Decode.list MutationRecord.decoder) mutationInfo of
        Ok mutationRecords ->
            GotDomChanges mutationRecords

        Err decodeError ->
            ErrorEncountered
                ("I could not parse a DOM mutation event. "
                    ++ Decode.errorToString decodeError
                )


handleViolationReport : Value -> Msg
handleViolationReport violationJson =
    case decodeValue problemsDecoder violationJson of
        Ok violations ->
            GotViolations violations

        Err err ->
            ErrorEncountered
                ("I couldn't understand the output from axe. "
                    ++ Decode.errorToString err
                )



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions =
            always
                (Sub.batch
                    [ Ports.elementSelected ElementSelected
                    , Ports.notifyChanges handleDomChanges
                    , Ports.violations handleViolationReport
                    , Ports.axeRunning GotAxeRunning
                    ]
                )
        }
