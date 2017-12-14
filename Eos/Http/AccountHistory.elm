module Eos.Http.AccountHistory
    exposing
        ( getControlledAccounts
        , getKeyAccounts
        , getTransaction
        , getTransactions
        )

{-|

@docs getControlledAccounts
@docs getKeyAccounts
@docs getTransaction
@docs getTransactions

-}

import Eos
import Eos.Decode as Decode
import Eos.Encode as Encode
import Eos.Http.Internal as Internal
import Http
import Json.Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


{-| -}
getControlledAccounts : Eos.BaseUrl -> Eos.AccountName -> Http.Request Eos.ControlledAccounts
getControlledAccounts baseUrl controllingAccount =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_controlled_accounts"
        , body =
            [ ( "controlling_account", Encode.accountName controllingAccount ) ]
                |> Encode.object
                |> Just
        , decoder = Decode.controlledAccounts
        }


{-| -}
getKeyAccounts : Eos.BaseUrl -> Eos.PublicKey -> Http.Request Eos.KeyAccounts
getKeyAccounts baseUrl publicKey =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_key_accounts"
        , body =
            [ ( "public_key", Encode.publicKey publicKey ) ]
                |> Encode.object
                |> Just
        , decoder = Decode.keyAccounts
        }


{-| -}
getTransaction :
    Eos.BaseUrl
    -> Eos.TransactionId
    -> Decoder msgData
    -> Http.Request (Eos.PushedTransaction msgData)
getTransaction baseUrl transactionId msgDataDecoder =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_transaction"
        , body =
            [ ( "transaction_id", Encode.transactionId transactionId ) ]
                |> Encode.object
                |> Just
        , decoder = Decode.pushedTransaction msgDataDecoder
        }


{-| -}
getTransactions :
    Eos.BaseUrl
    ->
        { accountName : Eos.AccountName
        , skipSeq : Maybe Int
        , numSeq : Maybe Int
        , msgDataDecoder : Decoder msgData
        }
    -> Http.Request (Eos.PushedTransactions msgData)
getTransactions baseUrl o =
    let
        skipSeq =
            o.skipSeq
                |> Maybe.map (\s -> [ ( "skip_seq", Encode.int s ) ])
                |> Maybe.withDefault []

        numSeq =
            o.numSeq
                |> Maybe.map (\s -> [ ( "num_seq", Encode.int s ) ])
                |> Maybe.withDefault []
    in
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_transactions"
        , body =
            [ [ ( "account_name", Encode.accountName o.accountName ) ]
            , skipSeq
            , numSeq
            ]
                |> List.concat
                |> Encode.object
                |> Just
        , decoder = Decode.pushedTransactions o.msgDataDecoder
        }



-- INTERNAL


pathSegments : String -> List String
pathSegments path =
    [ "v1", "account_history", path ]
