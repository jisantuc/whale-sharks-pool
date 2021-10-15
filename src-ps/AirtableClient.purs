module AirtableClient where

import Prelude
import Affjax (Error(..), printError)
import Affjax as AX
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, JsonDecodeError, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Data.Date (Date)
import Data.DateTime (date)
import Data.Either (Either(..))
import Data.Formatter.DateTime (unformat)
import Effect.Aff (Aff)
import Model (RawResults, dateFormat)
import Partial.Unsafe (unsafePartial)

showResult :: forall a. Show a => Either Error a -> String
showResult (Right v) = show v

showResult (Left e) = printError e

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

getDate :: Partial => forall e. Either e Date -> Date
getDate (Right d) = d

exampleDate :: Date
exampleDate = unsafePartial $ getDate $ date <$> unformat dateFormat "2021-08-27"

fetchResults :: String -> Aff (Either Error RawResults)
fetchResults token =
  let
    baseUrl = "https://api.airtable.com/v0/app9IJg37UKNWeN8g/Results"
  in
    fetchUrl token baseUrl
