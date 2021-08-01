module Style exposing (colors, edgePadding, elementButtonStyle, global, headerStyle, linkStyle, spin, textStyle)

{-| Shared and global CSS styles, color primitives, and other bits of style
that are more useful when centralized.
-}

import Css exposing (..)
import Css.Animations as Animations exposing (keyframes)
import Css.Global as Global exposing (body, class, everything)
import Html.Styled exposing (Html)
import Html.Styled.Attributes exposing (css)


global : Html msg
global =
    Global.global
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
    "72c3fa"


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
        , hover
            [ textDecoration underline
            ]
        ]


elementButtonStyle =
    css
        [ backgroundColor transparent
        , width (pct 100)
        , color colors.link
        , borderStyle none
        , fontSize (px 16)
        , cursor pointer
        , marginBottom (px 12)
        , textAlign left
        , hover
            [ textDecoration underline
            ]
        ]


headerStyle =
    css
        [ fontSize (px 24)
        , marginTop (px 0)
        , marginBottom (px 20)
        ]


edgePadding =
    padding (px 10)


spin duration =
    Css.batch
        [ animationName
            (keyframes
                [ ( 100, [ Animations.transform [ rotate (deg -360) ] ] ) ]
            )
        , animationDuration (sec duration)
        , Css.property "animation-iteration-count" "infinite"
        ]
