module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (attribute, src)
import Html.Events
import Json.Decode
import Json.Encode



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | MapClick String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MapClick lat lon ->
            let
                a =
                    Debug.log "aa" (lat ++ " - " ++ lon)
            in
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        , Html.node "customleaflet-map"
            [ Html.Attributes.id "fmap"
            , Html.Attributes.property "latitude" <| Json.Encode.string "65.111222"
            , Html.Attributes.property "longitude" <| Json.Encode.string "11.000000"
            , Html.Attributes.property "zoom" <| Json.Encode.string "5"
            , Html.Events.on "mapClick" <|
                Json.Decode.map2 MapClick (Json.Decode.at [ "target", "latitude" ] <| Json.Decode.string) (Json.Decode.at [ "target", "longitude" ] <| Json.Decode.string)
            ]
            []
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
