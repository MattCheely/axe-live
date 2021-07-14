module Style exposing (spin)

import Css exposing (animationDuration, animationName, deg, infinite, rotate, sec)
import Css.Animations as Animations exposing (keyframes, transform)


spin duration =
    Css.batch
        [ animationName
            (keyframes
                [ ( 100, [ transform [ rotate (deg -360) ] ] ) ]
            )
        , animationDuration (sec duration)
        , Css.property "animation-iteration-count" "infinite"
        ]
