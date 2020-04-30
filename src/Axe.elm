module Axe exposing (ElementProblem, PageProblems, encodeProblems, problemsDecoder)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias ElementProblem =
    { description : String
    , help : String
    , helpUrl : String
    , failureSummary : String
    }


type alias PageProblems =
    Dict String (List ElementProblem)


problemsDecoder : Decoder PageProblems
problemsDecoder =
    Decode.oneOf
        [ axeOutputDecoder
        , pageProblemsDecoder
        ]


axeOutputDecoder : Decoder PageProblems
axeOutputDecoder =
    Decode.list violationDecoder
        |> Decode.map problemsByNode


pageProblemsDecoder : Decoder PageProblems
pageProblemsDecoder =
    Decode.map2 (\selectors problem -> ( selectors, problem ))
        (Decode.field "target" Decode.string)
        (Decode.field "problems" (Decode.list problemDecoder))
        |> Decode.list
        |> Decode.map Dict.fromList


problemDecoder : Decoder ElementProblem
problemDecoder =
    Decode.map4 ElementProblem
        (Decode.field "description" Decode.string)
        (Decode.field "help" Decode.string)
        (Decode.field "helpUrl" Decode.string)
        (Decode.field "failureSummary" Decode.string)


encodeProblems : PageProblems -> Value
encodeProblems pageProblems =
    Dict.toList pageProblems
        |> Encode.list
            (\( target, problems ) ->
                Encode.object
                    [ ( "target", Encode.string target )
                    , ( "problems", Encode.list encodeProblem problems )
                    ]
            )


encodeProblem : ElementProblem -> Value
encodeProblem problem =
    Encode.object
        [ ( "description", Encode.string problem.description )
        , ( "help", Encode.string problem.help )
        , ( "helpUrl", Encode.string problem.helpUrl )
        , ( "failureSummary", Encode.string problem.failureSummary )
        ]


type alias Violation =
    { description : String
    , help : String
    , helpUrl : String
    , nodes : List Node
    }


type alias Node =
    { failureSummary : String
    , target : String
    }


violationDecoder : Decoder Violation
violationDecoder =
    Decode.map4 Violation
        (Decode.field "description" Decode.string)
        (Decode.field "help" Decode.string)
        (Decode.field "helpUrl" Decode.string)
        (Decode.field "nodes" (Decode.list nodeDecoder))


nodeDecoder : Decoder Node
nodeDecoder =
    Decode.map2 Node
        (Decode.field "failureSummary" Decode.string)
        (Decode.field "target" axeTargetDecoder)


axeTargetDecoder : Decoder String
axeTargetDecoder =
    Decode.list Decode.string
        |> Decode.andThen
            (\targetList ->
                case targetList of
                    target :: [] ->
                        Decode.succeed target

                    _ :: _ ->
                        Decode.fail twoValueTargetError

                    [] ->
                        Decode.fail "I couldn't find a target selector on this node!"
            )


twoValueTargetError : String
twoValueTargetError =
    """
I found two values in an axe node target! This has never happened before and
I'm not sure how to hanele it! Please open a ticket with an example!"""


problemsByNode : List Violation -> PageProblems
problemsByNode violations =
    List.foldl collectViolation Dict.empty violations


collectViolation : Violation -> PageProblems -> PageProblems
collectViolation violation violationsBySelector =
    violation.nodes
        |> List.foldl (addTargets violation) violationsBySelector


addTargets : Violation -> Node -> PageProblems -> PageProblems
addTargets violation node problemsByTarget =
    let
        problem =
            ElementProblem
                violation.description
                violation.help
                violation.helpUrl
                node.failureSummary
    in
    case Dict.get node.target problemsByTarget of
        Nothing ->
            Dict.insert node.target [ problem ] problemsByTarget

        Just problems ->
            Dict.insert node.target (problem :: problems) problemsByTarget
