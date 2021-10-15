module Client (fetchUrl, fetchPublicUrl) where

import Prelude
import Affjax (Error(..))
import Affjax as AX
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, JsonDecodeError, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Effect.Aff (Aff)

adaptError :: JsonDecodeError -> Error
adaptError jsErr =
  RequestContentError
    ( "Request failed to produce a meaningful response: " <> printJsonDecodeError jsErr
    )

getDecodedBody :: forall a. DecodeJson a => AX.Response Json -> Either Error a
getDecodedBody =
  lmap adaptError
    <<< decodeJson
    <<< _.body

fetchUrl :: forall a. DecodeJson a => String -> String -> Aff (Either Error a)
fetchUrl token urlString = do
  result <-
    AX.request
      $ AX.defaultRequest
          { url = urlString
          , responseFormat = ResponseFormat.json
          , headers = [ RequestHeader "Authorization" $ "Bearer " <> token ]
          }
  pure $ result >>= getDecodedBody

fetchPublicUrl :: forall a. DecodeJson a => String -> Aff (Either Error a)
fetchPublicUrl urlString = do
  result <-
    AX.request
      $ AX.defaultRequest
          { url = urlString
          , responseFormat = ResponseFormat.json
          }
  pure $ result >>= getDecodedBody
