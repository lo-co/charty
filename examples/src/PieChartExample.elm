module PieChartExample exposing (..)

import Charty.PieChart as PieChart exposing (view)
import Html exposing (Html, div)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Layout


type Group
    = A
    | B
    | C
    | D


type Msg
    = Update Group Float


type alias Model =
    { groupA : Float
    , groupB : Float
    , groupC : Float
    , groupD : Float
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    let
        sampleDataset =
            { groupA = 25
            , groupB = 45
            , groupC = 10
            , groupD = 20
            }
    in
        ( sampleDataset, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update A val ->
            ( { model | groupA = val }, Cmd.none )

        Update B val ->
            ( { model | groupB = val }, Cmd.none )

        Update C val ->
            ( { model | groupC = val }, Cmd.none )

        Update D val ->
            ( { model | groupD = val }, Cmd.none )


view : Model -> Html Msg
view model =
    Layout.twoColumns
        [ groupSlider model A
        , groupSlider model B
        , groupSlider model C
        , groupSlider model D
        ]
        (PieChart.view (buildDataset model))


groupSlider : Model -> Group -> Html Msg
groupSlider model group =
    div
        [ Attributes.style [ ( "margin-top", "40px" ) ] ]
        [ Html.p [] [ Html.text (label group) ]
        , Html.input
            [ Attributes.type_ "range"
            , Attributes.style [ ( "width", "100%" ) ]
            , Attributes.value (currentValue model group |> toString)
            , Events.on "input" (Decode.map (Update group) eventDecoder)
            ]
            []
        ]


buildDataset : Model -> PieChart.Dataset
buildDataset model =
    [ ( label A, model.groupA )
    , ( label B, model.groupB )
    , ( label C, model.groupC )
    , ( label D, model.groupD )
    ]


label : Group -> String
label group =
    "Group " ++ (toString group)


currentValue : Model -> Group -> Float
currentValue model group =
    case group of
        A ->
            model.groupA

        B ->
            model.groupB

        C ->
            model.groupC

        D ->
            model.groupD


eventDecoder : Decode.Decoder Float
eventDecoder =
    let
        decodeFloat s =
            case String.toFloat s of
                Result.Ok i ->
                    Decode.succeed i

                Result.Err msg ->
                    Decode.fail msg
    in
        Events.targetValue
            |> Decode.andThen decodeFloat