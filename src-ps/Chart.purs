module Chart (linePlot', register) where

import Prelude

import Data.Function.Uncurried (Fn4, runFn4)
import Effect (Effect)

foreign import register :: Effect Unit

foreign import linePlot :: forall a. Fn4 String String a (Array Int) (Effect Unit)

linePlot' :: forall a. String -> String -> a -> Array Int -> Effect Unit
linePlot' = runFn4 linePlot