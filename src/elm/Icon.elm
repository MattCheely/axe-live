module Icon exposing (externalLink, eye, eyeClosed, loopCircular)

{-| These are icons from the iconic icon library, translated to elm for use in
the project. License held by Matthew Cheely.
-}

import Accessibility.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (attribute)
import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes exposing (..)


strokeWidth =
    attribute "stroke-width"


strokeLinecap =
    attribute "stroke-linecap"


dataWidth =
    attribute "data-width"


dataHeight =
    attribute "data-height"


dataIcon =
    attribute "data-icon"


externalLink : Html msg
externalLink =
    svg
        [ class "iconic iconic-external-link"
        , width "100%"
        , height "100%"
        , viewBox "0 0 128 128"
        ]
        [ g
            [ class "iconic-metadata"
            ]
            [ Svg.title [] []
            ]
        , g
            [ class "iconic-external-link-lg iconic-container iconic-lg"
            , dataWidth "127"
            , dataHeight "128"
            , display "inline"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "8"
                , strokeLinecap "square"
                , d "M108 52v69c0 1.657-1.343 3-3 3h-98c-1.657 0-3-1.343-3-3v-98c0-1.657 1.343-3 3-3h68.917"
                , class "iconic-external-link-box iconic-property-accent iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "8"
                , strokeLinecap "square"
                , class "iconic-external-link-arrow iconic-external-link-arrow-steam iconic-property-stroke"
                , d "M116 12l-52.5 52.5"
                , fill "none"
                ]
                []
            , Svg.path
                [ d "M126.404.316l-24.937 5.369c-.81.174-.992.791-.406 1.376l19.879 19.879c.586.586 1.198.403 1.368-.407l5.255-25.064c.17-.811-.349-1.327-1.159-1.152z"
                , class "iconic-external-link-arrow iconic-external-link-arrow-head iconic-property-fill"
                ]
                []
            ]
        , g
            [ class "iconic-external-link-md iconic-container iconic-md"
            , dataWidth "32"
            , dataHeight "32"
            , display "none"
            , transform "scale(4)"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "3"
                , d "M27.5 15v15c0 .276-.224.5-.5.5h-25c-.276 0-.5-.224-.5-.5v-25c0-.276.224-.5.5-.5h16"
                , class "iconic-external-link-box iconic-property-accent iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "3"
                , strokeLinecap "square"
                , class "iconic-external-link-arrow iconic-external-link-arrow-stem iconic-property-stroke"
                , d "M28 4l-10 10"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-external-link-arrow iconic-external-link-arrow-head iconic-property-fill"
                , d "M32 0l-1 8-7-7z"
                ]
                []
            ]
        , g
            [ class "iconic-external-link-sm iconic-container iconic-sm"
            , dataWidth "16"
            , dataHeight "16"
            , display "none"
            , transform "scale(8)"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "2"
                , class "iconic-external-link-box iconic-property-accent iconic-property-stroke"
                , d "M13 8v7h-12v-12h7"
                , fill "none"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "2"
                , strokeLinecap "square"
                , class "iconic-external-link-arrow iconic-external-link-arrow-stem iconic-property-stroke"
                , d "M13 3l-4 4"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-external-link-arrow iconic-external-link-arrow-head iconic-property-fill"
                , d "M16 0v5l-5-5z"
                ]
                []
            ]
        ]


loopCircular : Html msg
loopCircular =
    svg
        [ class "iconic iconic-loop-circular"
        , width "100%"
        , height "100%"
        , viewBox "0 0 128 128"
        ]
        [ g
            [ class "iconic-metadata"
            ]
            [ Svg.title [] []
            ]
        , g
            [ class "iconic-loop-circular-lg iconic-container iconic-lg"
            , dataWidth "128"
            , dataHeight "107"
            , display "inline"
            , transform "translate(0 10)"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "8"
                , d "M15.016 64.04c-2.481-12.125-.341-24.984 5.992-35.621 6.117-10.272 15.904-18.169 27.257-21.93 17.781-5.89 37.853-1.118 51.09 12.118"
                , class "iconic-loop-circular-line iconic-loop-circular-line-left iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-left iconic-property-fill"
                , d "M14 77.963l14-24h-28z"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "8"
                , d "M112.984 43.886c2.481 12.125.341 24.984-5.992 35.621-6.117 10.272-15.904 18.169-27.257 21.93-17.781 5.89-37.853 1.118-51.09-12.118"
                , class "iconic-loop-circular-line iconic-loop-circular-line-right iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-right iconic-property-fill"
                , d "M114 29.963l-14 24h28z"
                ]
                []
            ]
        , g
            [ class "iconic-loop-circular-md iconic-container iconic-md"
            , dataWidth "32"
            , dataHeight "25"
            , display "none"
            , transform "scale(4) translate(0 3)"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "3"
                , d "M4.5 12.986c0-4.52 2.743-8.718 6.882-10.535 4.292-1.884 9.438-.908 12.75 2.403"
                , class "iconic-loop-circular-line iconic-loop-circular-line-left iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-left iconic-property-fill"
                , d "M4.5 18.986l-4.5-6h9z"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "3"
                , d "M27.5 12.986c0 4.52-2.743 8.718-6.882 10.535-4.292 1.884-9.438.908-12.75-2.403"
                , class "iconic-loop-circular-line iconic-loop-circular-line-right iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-right iconic-property-fill"
                , d "M27.5 6.986l4.5 6h-9z"
                ]
                []
            ]
        , g
            [ class "iconic-loop-circular-sm iconic-container iconic-sm"
            , dataWidth "16"
            , dataHeight "11"
            , display "none"
            , transform "scale(8) translate(0 2)"
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "2"
                , d "M3 5.962c0-4.361 5.45-6.621 8.536-3.535"
                , class "iconic-loop-circular-line iconic-loop-circular-line-left iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-left iconic-property-fill"
                , d "M3 8.962l-3-3h6z"
                ]
                []
            , Svg.path
                [ stroke "#000"
                , strokeWidth "2"
                , d "M13 5.962c0 4.361-5.45 6.621-8.536 3.535"
                , class "iconic-loop-circular-line iconic-loop-circular-line-right iconic-property-stroke"
                , fill "none"
                ]
                []
            , Svg.path
                [ class "iconic-loop-circular-arrowhead iconic-loop-circular-arrowhead-right iconic-property-fill"
                , d "M13 2.962l3 3h-6z"
                ]
                []
            ]
        ]


eye : Html msg
eye =
    svg
        [ version "1.1"
        , dataIcon "eye"
        , width "100%"
        , height "100%"
        , class "iconic iconic-eye"
        , viewBox "0 0 128 128"
        ]
        [ g []
            [ Svg.title [] []
            ]
        , g
            [ dataWidth "128"
            , dataHeight "76"
            , class "iconic-lg iconic-container"
            , display "inline"
            , transform "translate(0 26)"
            ]
            [ g
                [ class "iconic-eye-open"
                ]
                [ Svg.path
                    [ d "M64.5 0c-40.5 0-64.5 38-64.5 38s24 38 64.5 38c39.5 0 63.5-38 63.5-38s-24-38-63.5-38zm-.5 62c-13.255 0-24-10.745-24-24s10.745-24 24-24 24 10.745 24 24-10.745 24-24 24z"
                    , class "iconic-eye-open-eyeball iconic-property-fill"
                    ]
                    []
                , Svg.path
                    [ d "M72 34c-2.209 0-4-1.791-4-4 0-1.1.445-2.096 1.164-2.819-1.566-.749-3.313-1.181-5.164-1.181-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12c0-1.852-.432-3.598-1.181-5.164-.723.719-1.719 1.164-2.819 1.164z"
                    , class "iconic-eye-open-pupil iconic-property-fill"
                    ]
                    []
                ]
            ]
        , g
            [ dataWidth "128"
            , dataHeight "100"
            , class "iconic-lg iconic-container"
            , display "inline"
            , transform "translate(0 14)"
            ]
            [ g
                [ class "iconic-eye-closed"
                , display "none"
                ]
                [ Svg.path
                    [ stroke "#000"
                    , strokeWidth "8"
                    , strokeLinecap "square"
                    , class "iconic-eye-closed-strike iconic-property-stroke"
                    , fill "none"
                    , d "M21 93l86-86"
                    ]
                    []
                , Svg.path
                    [ d "M26.549 76.138c-17.076-11.15-26.549-26.138-26.549-26.138s24-38 64.5-38c8.034 0 15.414 1.588 22.094 4.093l-12.247 12.247c-3.133-1.499-6.641-2.34-10.346-2.34-13.255 0-24 10.745-24 24 0 3.705.841 7.213 2.34 10.346l-15.791 15.791zm74.999-52.372l-15.888 15.888c1.499 3.133 2.34 6.641 2.34 10.346 0 13.255-10.745 24-24 24-3.705 0-7.213-.841-10.346-2.34l-12.111 12.111c6.905 2.584 14.571 4.229 22.958 4.229 39.5 0 63.5-38 63.5-38s-9.53-15.074-26.452-26.235z"
                    , class "iconic-eye-closed-eyeball iconic-property-fill"
                    ]
                    []
                ]
            ]
        , g
            [ dataWidth "32"
            , dataHeight "20"
            , class "iconic-md iconic-container"
            , display "none"
            , transform "scale(4) translate(0 6)"
            ]
            [ g
                [ class "iconic-eye-open"
                ]
                [ Svg.path
                    [ d "M16.125 0c-10.125 0-16.125 10-16.125 10s6 10 16.125 10c9.875 0 15.875-10 15.875-10s-6-10-15.875-10zm-.125 17c-3.866 0-7-3.134-7-7s3.134-7 7-7 7 3.134 7 7-3.134 7-7 7z"
                    , class "iconic-eye-open-eyeball iconic-property-fill"
                    ]
                    []
                , Svg.path
                    [ d "M18.5 9c-.828 0-1.5-.672-1.5-1.5 0-.479.228-.9.577-1.175-.484-.208-1.017-.325-1.577-.325-2.209 0-4 1.791-4 4s1.791 4 4 4 4-1.791 4-4c0-.561-.117-1.093-.325-1.577-.275.349-.696.577-1.175.577z"
                    , class "iconic-eye-open-pupil iconic-property-fill"
                    ]
                    []
                ]
            ]
        , g
            [ dataWidth "32"
            , dataHeight "28"
            , class "iconic-md iconic-container"
            , display "none"
            , transform "scale(4) translate(0 2)"
            ]
            [ g
                [ class "iconic-eye-closed"
                , display "none"
                ]
                [ Svg.path
                    [ stroke "#000"
                    , strokeWidth "3"
                    , strokeLinecap "square"
                    , class "iconic-eye-closed-strike iconic-property-stroke"
                    , fill "none"
                    , d "M5 25l22-22"
                    ]
                    []
                , Svg.path
                    [ d "M0 14s6-10 16.125-10c1.523 0 2.953.239 4.284.641l-2.602 2.603c-.577-.154-1.181-.244-1.806-.244-3.866 0-7 3.134-7 7 0 .626.09 1.229.244 1.806l-4.016 4.016c-3.377-2.742-5.228-5.822-5.228-5.822zm26.791-5.842l-4.035 4.035c.154.577.244 1.181.244 1.806 0 3.866-3.134 7-7 7-.626 0-1.229-.09-1.806-.244l-2.567 2.567c1.391.424 2.893.677 4.499.677 9.875 0 15.875-10 15.875-10s-1.86-3.095-5.209-5.842z"
                    , class "iconic-eye-closed-eyeball iconic-property-fill"
                    ]
                    []
                ]
            ]
        , g
            [ dataWidth "16"
            , dataHeight "12"
            , class "iconic-sm iconic-container"
            , display "none"
            , transform "scale(8) translate(0 2)"
            ]
            [ g
                [ class "iconic-eye-open"
                ]
                [ Svg.path
                    [ d "M8.063 0c-5.063 0-8.063 6-8.063 6s3 6 8.063 6c4.938 0 7.938-6 7.938-6s-3-6-7.938-6zm-.063 10c-2.209 0-4-1.791-4-4s1.791-4 4-4 4 1.791 4 4-1.791 4-4 4z"
                    , class "iconic-eye-open-eyeball iconic-property-fill"
                    ]
                    []
                , Svg.path
                    [ d "M9 6c-.552 0-1-.448-1-1 0-.403.241-.745.584-.903-.186-.057-.379-.097-.584-.097-1.105 0-2 .895-2 2s.895 2 2 2 2-.895 2-2c0-.204-.04-.398-.097-.584-.159.343-.501.584-.903.584z"
                    , class "iconic-eye-open-pupil iconic-property-fill"
                    ]
                    []
                ]
            ]
        , g
            [ dataWidth "16"
            , dataHeight "16"
            , class "iconic-sm iconic-container"
            , display "none"
            , transform "scale(8)"
            ]
            [ g
                [ class "iconic-eye-closed"
                , display "none"
                ]
                [ Svg.path
                    [ stroke "#000"
                    , strokeWidth "2"
                    , strokeLinecap "square"
                    , class "iconic-eye-closed-strike iconic-property-stroke"
                    , fill "none"
                    , d "M2 14l12-12"
                    ]
                    []
                , Svg.path
                    [ d "M2.152 11.02c-1.395-1.507-2.152-3.02-2.152-3.02s3-6 8.063-6c.923 0 1.778.21 2.558.551l-1.598 1.598c-.329-.087-.667-.149-1.023-.149-2.209 0-4 1.791-4 4 0 .356.061.695.149 1.023l-1.996 1.996zm9.699-4.043c.087.329.149.667.149 1.023 0 2.209-1.791 4-4 4-.356 0-.695-.061-1.023-.149l-1.576 1.576c.808.353 1.697.573 2.662.573 4.938 0 7.938-6 7.938-6s-.761-1.518-2.144-3.028l-2.005 2.005z"
                    , class "iconic-eye-closed-eyeball iconic-property-fill"
                    ]
                    []
                ]
            ]
        ]


eyeClosed : Html msg
eyeClosed =
    svg
        [ version "1.1"
        , dataIcon "eye-closed"
        , width "100%"
        , height "100%"
        , class "iconic iconic-eye iconic-size-md iconic-eye-closed"
        , viewBox "0 0 32 32"
        ]
        [ g []
            [ Svg.title [] []
            ]
        , g
            [ dataWidth "32"
            , dataHeight "28"
            , class "iconic-container iconic-eye-closed"
            , transform "scale(1 1 ) translate(0 2 ) "
            ]
            [ Svg.path
                [ stroke "#000"
                , strokeWidth "3"
                , strokeLinecap "square"
                , class "iconic-eye-closed-strike iconic-property-stroke"
                , fill "none"
                , d "M5 25l22-22"
                ]
                []
            , Svg.path
                [ d "M0 14s6-10 16.125-10c1.523 0 2.953.239 4.284.641l-2.602 2.603c-.577-.154-1.181-.244-1.806-.244-3.866 0-7 3.134-7 7 0 .626.09 1.229.244 1.806l-4.016 4.016c-3.377-2.742-5.228-5.822-5.228-5.822zm26.791-5.842l-4.035 4.035c.154.577.244 1.181.244 1.806 0 3.866-3.134 7-7 7-.626 0-1.229-.09-1.806-.244l-2.567 2.567c1.391.424 2.893.677 4.499.677 9.875 0 15.875-10 15.875-10s-1.86-3.095-5.209-5.842z"
                , class "iconic-eye-closed-eyeball iconic-property-fill"
                ]
                []
            ]
        ]
