module UI where

import Prelude

import Chart (linePlot', register)
import Effect (Effect)

chart1 :: Effect Unit
chart1 = linePlot' "chart1" "Chart 1" ["a", "b", "c", "d", "e"] [1, 2, 3, 4, 5]

chart2 :: Effect Unit
chart2 = linePlot' "chart2" "Chart 2" ["j", "k", "l", "m", "n"] [4, 5, 3, 2, 1]

chart3 :: Effect Unit
chart3 = linePlot' "chart3" "Chart 3" ["a", "b", "c", "d", "e"] [1, 2, 3, 4, 5]

chart4 :: Effect Unit
chart4 = linePlot' "chart4" "Chart 4" ["j", "k", "l", "m", "n"] [4, 5, 3, 2, 1]

main :: Effect Unit
main = do
  register
  chart1
  chart2
  chart3
  chart4