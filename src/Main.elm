port module Main exposing (Model, Msg(..), init, main, update, view)

import Array
import Browser
import Html exposing (Html, a, div, h1, img, text)
import Html.Attributes exposing (attribute, class, href, src, target)
import Html.Events
import Json.Decode
import Json.Encode exposing (..)


port outbound : ( String, Value ) -> Cmd msg



---- MODEL ----


defaultAltitude =
    2000


type alias Position =
    { latitude : String
    , longitude : String
    , utmN : String
    , utmE : String
    , altitude : Int
    }


type alias Model =
    { position : Maybe Position
    }


init : ( Model, Cmd Msg )
init =
    ( { position = Nothing }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | MapClick String String String String
    | MapMove String String String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MapClick lat lon utmN utmE ->
            let
                cmd =
                    outbound ( "SetPosition", Json.Encode.array Json.Encode.string (Array.fromList [ lat, lon ]) )

                pos =
                    Position lat lon utmN utmE defaultAltitude
            in
            ( { model | position = Just pos }, cmd )

        MapMove lat lon utmN utmE ->
            let
                cmd =
                    Cmd.none

                pos =
                    Position lat lon utmN utmE defaultAltitude
            in
            ( { model | position = Just pos }, cmd )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "bg" ]
        [ h1 [] [ text "Please select a location:" ]
        , viewPositionLink model.position
        , Html.node "customleaflet-map"
            [ Html.Attributes.id "fmap"
            , Html.Attributes.class "crosshairs"
            , Html.Attributes.property "latitude" <| Json.Encode.string "65.111222"
            , Html.Attributes.property "longitude" <| Json.Encode.string "11.000000"
            , Html.Attributes.property "zoom" <| Json.Encode.string "5"
            , Html.Events.on "mapMove" <|
                Json.Decode.map4 MapMove (Json.Decode.at [ "target", "latitude" ] <| Json.Decode.string) (Json.Decode.at [ "target", "longitude" ] <| Json.Decode.string) (Json.Decode.at [ "target", "utmN" ] <| Json.Decode.string) (Json.Decode.at [ "target", "utmE" ] <| Json.Decode.string)
            ]
            []
        ]


viewPositionLink : Maybe Position -> Html Msg
viewPositionLink position =
    case position of
        Just pos ->
            a [ href ("http://kristoffer-dyrkorn.github.io/flightsimulator/?n=" ++ pos.utmN ++ "&e=" ++ pos.utmE), target "_blank" ]
                [ text ("Click this link to start the flightsim on this position " ++ pos.utmN ++ " - " ++ pos.utmE)
                ]

        Nothing ->
            text "Select a postion"



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
