module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (attribute, src)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
