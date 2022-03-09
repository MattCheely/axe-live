module Style exposing (colors, edgePadding, elementButtonStyle, global, headerStyle, hiddenWhenMinimized, iconSize, linkStyle, spin, textStyle, visibleWhenMinimized)

{-| Shared and global CSS styles, color primitives, and other bits of style
that are more useful when centralized.
-}

import Css exposing (..)
import Css.Animations as Animations exposing (keyframes)
import Css.Global as Global exposing (body, class, everything)
import Css.Media as Media exposing (only, screen, withMedia)
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


hiddenWhenMinimized =
    withMedia [ only screen [ Media.maxWidth (px 300) ] ]
        [ display none ]


visibleWhenMinimized =
    withMedia [ only screen [ Media.maxWidth (px 300) ] ]
        [ display block ]


colors =
    { text = rgb 255 255 255
    , error = hex "fb595b"
    , success = hex "62a37e"
    , link = hex "72c3fa"
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
                [ ( 100, [ Animations.transform [ rotate (deg 360) ] ] ) ]
            )
        , animationDuration (sec duration)
        , Css.property "animation-iteration-count" "infinite"
        , Css.property "animation-timing-function" "linear"
        ]


iconSize =
    Css.batch [ height (px 20), width (px 20) ]
