module Chart (linePlot', register, defaultDataset, Dataset) where

import Prelude
import Data.Function.Uncurried (Fn3, runFn3)
import Effect (Effect)

foreign import register :: Effect Unit

foreign import linePlot :: forall a. Fn3 String a (Array Dataset) (Effect Unit)

linePlot' :: forall a. String -> a -> Array Dataset -> Effect Unit
linePlot' = runFn3 linePlot

type Dataset
  = { label :: String
    , data :: Array Int
    , backgroundColor :: Array String
    , borderWidth :: Int
    }

defaultDataset :: Dataset
defaultDataset =
  { label: "no-data"
  , data: []
  , backgroundColor: [ "rgba(255, 99, 132, 0.2)" ]
  , borderWidth: 1
  }
