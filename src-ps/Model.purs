module Model where

import Data.Argonaut.Core (Json, fromString, toObject, toString)
import Data.Argonaut.Decode (class DecodeJson, JsonDecodeError(..), decodeJson, (.:))
import Data.Argonaut.Decode.Generic (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.Bifunctor (lmap)
import Data.Date (Date, day, month, year)
import Data.DateTime (DateTime(..), Hour, Millisecond, Minute, Second, Time(..), date)
import Data.Either (Either(..), note)
import Data.Enum (toEnum)
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), format, unformat)
import Data.Generic.Rep (class Generic)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..), fromJust)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Data.String.NonEmpty (NonEmptyString)
import Data.Traversable (traverse)
import Partial.Unsafe (unsafePartial)
import Prelude (class Show, bind, pure, show, ($), (<$>), (<<<), (<>), (>>=))

-- models for airtable response like:
-- |
-- {
--     "createdTime": "2021-09-14T16:26:44.000Z",
--     "fields": {
--         "Date": "2021-09-10",
--         "Game": "8 Ball",
--         "Name": "Jones",
--         "Opponent Skill": 3,
--         "Order": "2",
--         "Points": 3,
--         "Season Week": 2,
--         "WinLoss": "W",
--         "Session": "Fall 2021"
--     },
--     "id": "recxsfweFmHAgWeXi"
-- }
data WinLoss
  = Win
  | Loss

instance decodeWinLoss :: DecodeJson WinLoss where
  decodeJson js =
    note (UnexpectedValue js) $ toString js
      >>= ( case _ of
            "W" -> Just Win
            "L" -> Just Loss
            _ -> Nothing
        )

instance EncodeJson WinLoss where
  encodeJson Win = fromString "W"
  encodeJson Loss = fromString "L"

derive instance genericWinLoss :: Generic WinLoss _

instance showWinLoss :: Show WinLoss where
  show = genericShow

data Game
  = EightBall
  | NineBall

instance decodeGame :: DecodeJson Game where
  decodeJson js =
    note (UnexpectedValue js) $ toString js
      >>= ( case _ of
            "8 Ball" -> Just EightBall
            "9 Ball" -> Just NineBall
            _ -> Nothing
        )

instance EncodeJson Game where
  encodeJson EightBall = fromString "8 Ball"
  encodeJson NineBall = fromString "9 Ball"

derive instance genericGame :: Generic Game _

instance showGame :: Show Game where
  show = genericShow

type PlayerName
  = NonEmptyString

data Order
  = One
  | Two
  | Three
  | Four
  | Five

instance decodeOrder :: DecodeJson Order where
  decodeJson js =
    note (UnexpectedValue js) $ toString js
      >>= ( case _ of
            "1" -> Just One
            "2" -> Just Two
            "3" -> Just Three
            "4" -> Just Four
            "5" -> Just Five
            _ -> Nothing
        )

instance EncodeJson Order where
  encodeJson One = fromString "1"
  encodeJson Two = fromString "2"
  encodeJson Three = fromString "3"
  encodeJson Four = fromString "4"
  encodeJson Five = fromString "5"

derive instance genericOrder :: Generic Order _

instance showOrder :: Show Order where
  show = genericShow

data Session
  = Fall2021

instance decodeSession :: DecodeJson Session where
  decodeJson js =
    note (UnexpectedValue js) $ toString js
      >>= ( case _ of
            "Fall 2021" -> pure Fall2021
            _ -> Nothing
        )

instance EncodeJson Session where
  encodeJson Fall2021 = fromString "Fall 2021"

derive instance genericSession :: Generic Session _

instance showSession :: Show Session where
  show = genericShow

newtype JsonDate
  = JsonDate Date

derive newtype instance showJsonDate :: Show JsonDate

dateFormat :: Formatter
dateFormat =
  YearFull
    : (Placeholder "-")
    : MonthTwoDigits
    : (Placeholder "-")
    : DayOfMonthTwoDigits
    : Nil

jsonDateFromString :: String -> Either String JsonDate
jsonDateFromString s = (JsonDate <<< date <$> unformat dateFormat s)

jsonDateToString :: JsonDate -> String
jsonDateToString (JsonDate dt) =
  let
    y = year dt

    m = month dt

    d = day dt
  in
    show y <> "-" <> show m <> "-" <> show d

instance decodeJsonDate :: DecodeJson JsonDate where
  decodeJson js = case toString js of
    Just dateString -> lmap (\s -> TypeMismatch ("String should match YYYY-MM-DD format: " <> s)) $ jsonDateFromString dateString
    Nothing -> Left $ UnexpectedValue js

instance EncodeJson JsonDate where
  encodeJson (JsonDate date) =
    let
      hour :: Partial => Hour
      hour = fromJust (toEnum 0)

      minute :: Partial => Minute
      minute = fromJust (toEnum 0)

      second :: Partial => Second
      second = fromJust (toEnum 0)

      millisecond :: Partial => Millisecond
      millisecond = fromJust (toEnum 0)

      midnight = unsafePartial $ Time hour minute second millisecond
    in
      fromString $ format dateFormat (DateTime date midnight)

data Result
  = Result
    { date :: JsonDate
    , game :: Game
    , name :: PlayerName
    , opponentSkill :: Int
    , order :: Order
    , points :: Int
    , seasonWeek :: Int
    , winLoss :: WinLoss
    , session :: Session
    }

newtype RawResult = RawResult Result

instance DecodeJson RawResult where
  decodeJson js = case (toObject js) of
    Just obj -> do
      fields <- obj .: "fields"
      date <- fields .: "Date"
      name <- fields .: "Name"
      opponentSkill <- fields .: "Opponent Skill"
      session <- fields .: "Session"
      order <- fields .: "Order"
      points <- fields .: "Points"
      winLoss <- fields .: "WinLoss"
      game <- fields .: "Game"
      seasonWeek <- fields .: "Season Week"
      pure $ RawResult $ Result { date, game, name, opponentSkill, order, points, seasonWeek, winLoss, session }
    Nothing -> Left $ UnexpectedValue js

derive newtype instance Show RawResult

derive newtype instance EncodeJson RawResult

instance DecodeJson Result where
  decodeJson = genericDecodeJson

instance EncodeJson Result where
  encodeJson = genericEncodeJson

derive instance genericResult :: Generic Result _

instance Show Result where
  show = genericShow

newtype Results = Results (Array Result)

derive instance Newtype Results _

derive newtype instance Show Results

derive newtype instance EncodeJson Results

derive newtype instance DecodeJson Results

newtype RawResults = RawResults (Array RawResult)

derive newtype instance Show RawResults

derive newtype instance EncodeJson RawResults

instance DecodeJson RawResults where
  decodeJson js = case toObject js of
    Just obj -> do
      records :: Array Json <- obj .: "records"
      resultSet <- traverse decodeJson records
      pure $ RawResults resultSet
    Nothing -> Left $ UnexpectedValue js