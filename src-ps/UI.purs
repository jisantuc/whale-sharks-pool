module UI where

import Prelude

import APIClient (fetchResults)
import Affjax (printError)
import Chart (Dataset, defaultDataset, linePlot', register)
import Data.Array as Array
import Data.Array.NonEmpty (NonEmptyArray, head, toArray)
import Data.Either (Either(..))
import Data.String.NonEmpty (toString)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import Model (Game(..), PlayerName, Result(..), Results(..), jsonDateToString)

game :: Result -> Game
game (Result { game: g }) = g

playerName :: Result -> PlayerName
playerName (Result { name }) = name

points :: Result -> Int
points (Result {points: ps}) = ps

dateString :: Result -> String
dateString (Result { date } ) = jsonDateToString date

toDataset :: PlayerName -> NonEmptyArray Result -> Dataset
toDataset n results = 
  defaultDataset { data = toArray $ points <$> results
                 , label = toString n }

toLabels :: Array Result -> Array String
toLabels results =
  Array.nub $ dateString <$> Array.sortBy (\(Result { date: date1 }) (Result { date: date2 }) -> compare date1 date2) results
  

-- chart1 :: Effect Unit
-- chart1 = linePlot' "chart1" "Chart 1" [ "a", "b", "c", "d", "e" ] [ 1, 2, 3, 4, 5 ]

-- chart2 :: Effect Unit
-- chart2 = linePlot' "chart2" "Chart 2" [ "j", "k", "l", "m", "n" ] [ 4, 5, 3, 2, 1 ]

-- chart3 :: Effect Unit
-- chart3 = linePlot' "chart3" "Chart 3" [ "a", "b", "c", "d", "e" ] [ 1, 2, 3, 4, 5 ]

-- chart4 :: Effect Unit
-- chart4 = linePlot' "chart4" "Chart 4" [ "j", "k", "l", "m", "n" ] [ 4, 5, 3, 2, 1 ]

plotRecentResults :: String -> Results -> (Result -> Boolean) -> Aff Unit
plotRecentResults elemId (Results d) cond =
  let
    grouped :: Array (NonEmptyArray Result)
    grouped = Array.groupAllBy (\x y -> compare (playerName x) (playerName y)) (Array.filter cond d)

    keyed :: Array (Tuple PlayerName (NonEmptyArray Result))
    keyed = (\g -> Tuple (playerName $ head g) g) <$> grouped

    datasets :: Array Dataset
    datasets = (\(Tuple n rs) -> toDataset n rs) <$> keyed
  in
    liftEffect $ linePlot' elemId (toLabels d) datasets

plotRecent9BallResults :: Results -> Aff Unit
plotRecent9BallResults results = plotRecentResults "chart1" results (\r -> game r == NineBall)

plotRecent8BallResults :: Results -> Aff Unit
plotRecent8BallResults results = plotRecentResults "chart2" results (\r -> game r == EightBall)

main :: Effect Unit
main = do
  register
  launchAff_ $ do
    resp <- fetchResults
    case resp of
      Left err -> error $ printError err
      Right results -> do
        plotRecent9BallResults results
        plotRecent8BallResults results
