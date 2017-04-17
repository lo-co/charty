module LineChartExample exposing (..)

import Array
import Charty.LineChart as LineChart
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Layout


type Msg
    = DatasetChange String


type alias Model =
    { input : String
    , inputOk : Bool
    , dataset : LineChart.Dataset
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
        dataset =
            sampleDataset
    in
        ( { input = encodeDataset dataset, inputOk = True, dataset = sampleDataset }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update (DatasetChange text) model =
    case Decode.decodeString datasetDecoder text of
        Result.Ok dataset ->
            ( { input = text, inputOk = True, dataset = dataset }, Cmd.none )

        _ ->
            ( { input = text, inputOk = False, dataset = model.dataset }, Cmd.none )


view : Model -> Html Msg
view model =
    Layout.twoColumns
        [ Html.p
            []
            [ Html.text "The dataset below will be displayed on the right upon validation." ]
        , Html.textarea
            [ Attributes.style
                [ ( "width", "100%" )
                , ( "flex-grow", "1" )
                , ( "font-size", "14px" )
                ]
            , Events.onInput DatasetChange
            ]
            [ Html.text model.input ]
        ]
        (LineChart.view LineChart.defaults model.dataset)


sampleDataset : LineChart.Dataset
sampleDataset =
    [ [ ( 100000, 3 ), ( 100001, 4 ), ( 100002, 3 ), ( 100003, 2 ), ( 100004, 1 ), ( 100005, 1 ), ( 100006, -1 ) ]
    , [ ( 100000, 1 ), ( 100001, 2.5 ), ( 100002, 3 ), ( 100003, 3.5 ), ( 100004, 3 ), ( 100005, 2 ), ( 100006, 0 ) ]
    , [ ( 100000, 2 ), ( 100001, 1.5 ), ( 100002, 0 ), ( 100003, 3 ), ( 100004, -0.5 ), ( 100005, -1.5 ), ( 100006, -2 ) ]
    ]


encodeDataset : LineChart.Dataset -> String
encodeDataset dataset =
    let
        entryEncoder =
            \( x, y ) -> Encode.array (Array.fromList [ Encode.float x, Encode.float y ])

        seriesEncoder =
            List.map entryEncoder >> Encode.list

        datasetEncoder =
            List.map seriesEncoder >> Encode.list
    in
        Encode.encode 4 (datasetEncoder dataset)


datasetDecoder : Decode.Decoder LineChart.Dataset
datasetDecoder =
    let
        arrayToTuple a =
            case Array.toList a of
                x :: y :: [] ->
                    Decode.succeed ( x, y )

                _ ->
                    Decode.fail "Failed to decode point"

        entryDecoder =
            Decode.array Decode.float |> Decode.andThen arrayToTuple
    in
        Decode.list <| Decode.list entryDecoder