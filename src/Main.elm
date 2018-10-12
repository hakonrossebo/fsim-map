port module Main exposing (Model, Msg(..), init, main, update, view)

import Array
import Browser
import GeoJson
import Html exposing (Html, a, div, h1, h2, h3, img, input, li, p, span, text, ul)
import Html.Attributes exposing (attribute, class, href, max, min, src, target, type_, value)
import Html.Events exposing (onInput)
import Http exposing (get)
import Json.Decode
import Json.Encode exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


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
    , geoJson : WebData GeoJson.GeoJson
    , altitude : Int
    }


type alias GoeJsonPOIProperties =
    { name : String
    , featureType : String
    }


init : ( Model, Cmd Msg )
init =
    ( { position = Nothing
      , geoJson = RemoteData.NotAsked
      , altitude = 2500
      }
    , fetchGeoJson
    )


decodeGeoJsonPOIProperties : Json.Decode.Decoder GoeJsonPOIProperties
decodeGeoJsonPOIProperties =
    Json.Decode.map2 GoeJsonPOIProperties
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)



---- UPDATE ----


fetchGeoJson : Cmd Msg
fetchGeoJson =
    Http.get "./data/POI.json" GeoJson.decoder
        |> RemoteData.sendRequest
        |> Cmd.map GeoJsonResponse


type Msg
    = NoOp
    | MapClick String String String String
    | MapMove String String String String
    | GeoJsonResponse (WebData GeoJson.GeoJson)
    | POIClick GeoJson.FeatureObject
    | UpdateAltitude String


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

        GeoJsonResponse data ->
            ( { model | geoJson = data }
            , Cmd.none
            )

        POIClick feature ->
            let
                cmd =
                    case feature.geometry of
                        Just geo ->
                            case geo of
                                GeoJson.Point ( lat, lon, _ ) ->
                                    outbound ( "FlyTo", Json.Encode.array Json.Encode.string (Array.fromList [ String.fromFloat lat, String.fromFloat lon ]) )

                                _ ->
                                    Cmd.none

                        Nothing ->
                            Cmd.none
            in
            ( model, cmd )

        UpdateAltitude altitude ->
            case String.toInt altitude of
                Just alt ->
                    ( { model | altitude = alt }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "gridcontainer" ]
        [ h1 [ class "grid-header" ] [ text "Please select a location to start Flightsimulator over Norway:" ]
        , div [ class "grid-main" ]
            [ viewPositionLink model.position model.altitude
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
            , text "Tip: The airplane start at a northern direction. Select a location a bit south to see you location in front of you."
            , p [] [ text "Use mouse-wheel to zoom in/out.The crosshair is the current/selected location." ]
            ]
        , viewGeoJson model.geoJson
        , div [ class "grid-sidebar" ] []
        , div [ class "grid-footer" ]
            [ p []
                [ text "This is a frontend/starter page for "
                , a [ href "https://github.com/kristoffer-dyrkorn/flightsimulator" ] [ text "https://github.com/kristoffer-dyrkorn/flightsimulator" ]
                , text ". The purpose is to provide an easy way to navigate to a start position in the flight simulator."
                ]
            , p []
                [ text "Please contribute on:"
                , a [ href "https://github.com/hakonrossebo/fsim-map" ] [ text "https://github.com/hakonrossebo/fsim-map" ]
                ]
            ]
        ]


viewGeoJson : WebData GeoJson.GeoJson -> Html Msg
viewGeoJson webdata =
    case webdata of
        NotAsked ->
            text "Initialising."

        Loading ->
            text "Loading."

        Failure err ->
            text "Error: "

        Success data ->
            div [ class "grid-middle" ]
                [ h3 []
                    [ text "Points of interest"
                    ]
                , viewPOIData data
                ]


viewPOIData : GeoJson.GeoJson -> Html Msg
viewPOIData ( geoObject, _ ) =
    case geoObject of
        GeoJson.FeatureCollection featureList ->
            featureList
                |> List.map viewPOIListItem
                |> ul []

        _ ->
            text "No POI data"


viewPOIListItem : GeoJson.FeatureObject -> Html Msg
viewPOIListItem feature =
    case Json.Decode.decodeValue decodeGeoJsonPOIProperties feature.properties of
        Ok props ->
            li [ Html.Events.onClick (POIClick feature), class "poiLink" ] [ text props.name ]

        Err _ ->
            text ""


viewAltitudeSlider altitude =
    div []
        [ input
            [ type_ "range"
            , min "2000"
            , max "20000"
            , value <| String.fromInt altitude
            , onInput UpdateAltitude
            ]
            []
        , text <| "Altitude: " ++ String.fromInt altitude ++ " meters"
        ]


viewPositionLink : Maybe Position -> Int -> Html Msg
viewPositionLink position altitude =
    case position of
        Just pos ->
            span []
                [ a [ href ("http://kristoffer-dyrkorn.github.io/flightsimulator/?n=" ++ pos.utmN ++ "&e=" ++ pos.utmE ++ "&a=" ++ String.fromInt altitude), target "_blank" ]
                    [ text ("Click this link to start the flightsim on this position " ++ pos.utmN ++ " - " ++ pos.utmE)
                    ]
                , viewAltitudeSlider altitude
                , p
                    []
                    [ text "The link will open in a new browser tab."
                    ]
                ]

        Nothing ->
            text "Select a postion to get a link to start the flight simulator."



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
