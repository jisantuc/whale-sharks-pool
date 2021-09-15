module Main where

import Prelude

import Client (fetchResults)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (log, logShow)

-- what's this app do?
-- - fetch data from Airtable
-- - grab the most recent three weeks (three latest dates)
-- - create an 8 ball chart
-- - create a 9 ball chart
-- - bundle out to an index.js
-- - render that with an index.html
-- - put it all on S3
main :: Effect Unit
main = do
  launchAff_ $ do
    responses <- fetchResults "bogusKey"
    logShow responses
    
