module Eos.Http.Internal exposing (..)

import Eos
import Erl
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


http :
    { method : String
    , baseUrl : Eos.BaseUrl
    , pathSegments : List String
    , body : Maybe Value
    , decoder : Decoder a
    }
    -> Http.Request a
http r =
    let
        url =
            r.baseUrl
                |> Erl.appendPathSegments r.pathSegments
                |> Erl.toString

        body =
            case r.body of
                Just value ->
                    -- Use stringBody instead of jsonBody.
                    -- Requests with Content-Type: application/json will be
                    -- pre-flighted by some browsers and currently Eos doesn't
                    -- support the OPTIONS method
                    Http.stringBody
                        "text/plain;charset=UTF-8"
                        (Encode.encode 0 value)

                Nothing ->
                    Http.emptyBody
    in
        Http.request
            { method = r.method
            , headers = []
            , url = url
            , body = body
            , expect = Http.expectJson r.decoder
            , timeout = Nothing
            , withCredentials = False
            }
