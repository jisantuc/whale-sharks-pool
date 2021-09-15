module Model where

import Data.Argonaut.Core (toObject, toString)
import Data.Argonaut.Decode (class DecodeJson, JsonDecodeError(..), (.:))
import Data.Bifunctor (lmap)
import Data.Date (Date, day, month, year)
import Data.DateTime (date)
import Data.Either (Either(..), note)
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), unformat)
import Data.Generic.Rep (class Generic)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String.NonEmpty (NonEmptyString)
import Plotly (XYData)
import Prelude (bind, pure, show, ($), (<$>), (<<<), (<>), (>>=), class Show)

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
--         "Select": "W",
--         "Session": "Fall 2021"
--     },
--     "id": "recxsfweFmHAgWeXi"
-- }
data WinLoss
  = Win
  | Loss

instance decodeWinLoss :: DecodeJson WinLoss where
  decodeJson js = note (UnexpectedValue js) $ toString js >>= (case _ of
    "W" -> Just Win
    "L" -> Just Loss
    _ -> Nothing
  )

derive instance genericWinLoss :: Generic WinLoss _

instance showWinLoss :: Show WinLoss where
  show = genericShow

data Game
  = EightBall
  | NineBall

instance decodeGame :: DecodeJson Game where
  decodeJson js = note (UnexpectedValue js) $ toString js >>= (case _ of
    "8 Ball" -> Just EightBall
    "9 Ball" -> Just NineBall
    _ -> Nothing
  )

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

instance decodeResult :: DecodeJson Result where
  decodeJson js = case (toObject js) of
    Just obj -> do
      fields <- obj .: "fields"
      date <- fields .: "Date"
      name <- fields .: "Name"
      opponentSkill <- fields .: "Opponent Skill"
      session <- fields .: "Session"
      order <- fields .: "Order"
      points <- fields .: "Points"
      winLoss <- fields .: "Select"
      game <- fields .: "Game"
      seasonWeek <- fields .: "Season Week"
      pure $ Result { date, game, name, opponentSkill, order, points, seasonWeek, winLoss, session }
    Nothing -> Left $ UnexpectedValue js

derive instance genericResult :: Generic Result _

instance showResult :: Show Result where
  show = genericShow

toXYData :: Array Result -> XYData String
toXYData results =
  let
    xs :: Array String
    xs = (\(Result { date }) -> jsonDateToString date) <$> results
    ys :: Array Int
    ys = (\(Result { points }) -> points) <$> results
  in { x: xs, y: ys }