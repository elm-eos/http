module Eos.Http.Chain
    exposing
        ( getAccount
        , getBlock
        , getCode
        , getInfo
        , getTableRows
        )

{-|

@docs getAccount
@docs getBlock
@docs getCode
@docs getInfo
@docs getTableRows

-}

import Eos
import Eos.Decode as Decode
import Eos.Encode as Encode
import Eos.Http.Internal as Internal
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


-- abiJsonToBin


pathSegments : String -> List String
pathSegments path =
    [ "v1", "chain", path ]


{-| -}
getAccount : Eos.BaseUrl -> Eos.AccountName -> Http.Request Eos.Account
getAccount baseUrl accountName =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_account"
        , body =
            [ ( "account_name", Encode.accountName accountName ) ]
                |> Encode.object
                |> Just
        , decoder = Decode.account
        }


{-| -}
getBlock : Eos.BaseUrl -> Eos.BlockRef -> Http.Request Eos.Block
getBlock baseUrl blockRef =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_block"
        , body =
            Just <|
                Encode.object [ ( "block_num_or_id", Encode.blockRef blockRef ) ]
        , decoder = Decode.block
        }


{-| -}
getCode : Eos.BaseUrl -> Eos.AccountName -> Http.Request Eos.Code
getCode baseUrl accountName =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_code"
        , body =
            [ ( "account_name", Encode.accountName accountName ) ]
                |> Encode.object
                |> Just
        , decoder = Decode.code
        }


{-| -}
getInfo : Eos.BaseUrl -> Http.Request Eos.Info
getInfo baseUrl =
    Internal.http
        { baseUrl = baseUrl
        , method = "GET"
        , pathSegments = pathSegments "get_info"
        , body = Nothing
        , decoder = Decode.info
        }



-- getRequiredKeys


{-| -}
getTableRows :
    Eos.BaseUrl
    ->
        { scope : Eos.AccountName
        , code : Eos.AccountName
        , table : Eos.TableName
        , rowDecoder : Decoder row
        }
    -> Http.Request (Eos.TableRows row)
getTableRows baseUrl { scope, code, table, rowDecoder } =
    Internal.http
        { baseUrl = baseUrl
        , method = "POST"
        , pathSegments = pathSegments "get_table_rows"
        , body =
            [ ( "json", Encode.bool True )
            , ( "scope", Encode.accountName scope )
            , ( "code", Encode.accountName code )
            , ( "table", Encode.tableName table )
            ]
                |> Encode.object
                |> Just
        , decoder = Decode.tableRows rowDecoder
        }



-- pushTransaction
-- pushTransactions
