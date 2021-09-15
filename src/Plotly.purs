module Plotly where

import Prelude
import Data.Function.Uncurried (Fn2)
import Effect (Effect)

data Mode
  = Markers
  | Lines
  | LinesPlusMarkers

type XYData a
  = { x :: Array a
    , y :: Array Int
    }

foreign import linePlot :: forall a. Fn2 String (XYData a) (Effect Unit)

foreign import markersPlot :: forall a. Fn2 String (XYData a) (Effect Unit)

foreign import linesPlusMarkersPlot :: forall a. Fn2 String (XYData a) (Effect Unit)
