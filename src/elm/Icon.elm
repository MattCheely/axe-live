module Icon exposing (alert, check, externalLink, eye, eyeClosed, loopCircular, maximize, minimize)

import Accessibility.Styled as Html exposing (Html)
import FeatherIcons exposing (withSize, withSizeUnit)
import Html.Styled exposing (fromUnstyled)


minimize : Html msg
minimize =
    icon FeatherIcons.minimize2


externalLink : Html msg
externalLink =
    icon FeatherIcons.externalLink


loopCircular : Html msg
loopCircular =
    icon FeatherIcons.refreshCw


alert : Html msg
alert =
    icon FeatherIcons.alertTriangle


eye : Html msg
eye =
    icon FeatherIcons.eye


eyeClosed : Html msg
eyeClosed =
    icon FeatherIcons.eyeOff


check : Html msg
check =
    icon FeatherIcons.check


maximize : Html msg
maximize =
    icon FeatherIcons.maximize2


icon : FeatherIcons.Icon -> Html msg
icon ico =
    ico
        |> withSize 100
        |> withSizeUnit "%"
        |> FeatherIcons.toHtml []
        |> fromUnstyled
