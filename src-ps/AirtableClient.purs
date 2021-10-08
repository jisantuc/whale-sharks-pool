module AirtableClient where

import Prelude
import Affjax (Error(..), printError)
import Affjax as AX
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Core (Json, stringify)
import Data.Argonaut.Decode (class DecodeJson, JsonDecodeError, decodeJson, printJsonDecodeError)
import Data.Bifunctor (lmap)
import Data.Date (Date)
import Data.DateTime (date)
import Data.Either (Either(..))
import Data.Formatter.DateTime (unformat)
import Data.String.NonEmpty (unsafeFromString)
import Effect.Aff (Aff)
import Model (Game(..), JsonDate(..), Order(..), Result(..), Results, Session(..), WinLoss(..), dateFormat)
import Partial.Unsafe (unsafePartial)

showResult :: forall r. Either Error { body :: Json | r } -> String
showResult (Right v) = stringify v.body

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

mockResults :: Array Result
mockResults =
  [ Result
      { date: JsonDate exampleDate
      , name: unsafePartial $ unsafeFromString "Jones"
      , opponentSkill: 4
      , session: Fall2021
      , seasonWeek: 1
      , order: Three
      , points: 1
      , winLoss: Loss
      , game: NineBall
      }
  , Result
      { date: JsonDate exampleDate
      , name: unsafePartial $ unsafeFromString "Jones"
      , opponentSkill: 3
      , session: Fall2021
      , seasonWeek: 2
      , order: Two
      , points: 3
      , winLoss: Win
      , game: NineBall
      }
  ]

fetchResults :: String -> Aff (Either Error Results)
fetchResults token =
  let
    baseUrl = "https://api.airtable.com/v0/app9IJg37UKNWeN8g/Results"
  in
    fetchUrl token baseUrl