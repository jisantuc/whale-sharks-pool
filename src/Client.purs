module Client where

import Prelude
import Data.Date (Date)
import Data.DateTime (date)
import Data.Either (Either(..))
import Data.Formatter.DateTime (unformat)
import Data.String.NonEmpty (unsafeFromString)
import Effect.Aff (Aff)
import Model (Game(..), JsonDate(..), Order(..), Result(..), Session(..), WinLoss(..), dateFormat)
import Partial.Unsafe (unsafePartial)

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

fetchResults :: String -> Aff (Array Result)
fetchResults _ = pure mockResults
