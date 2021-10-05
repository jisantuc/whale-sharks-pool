module Main where

import Prelude
import Affjax (Error)
import AirtableClient (fetchResults)
import Control.Promise (Promise, fromAff)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Traversable (traverse)
import Dotenv (loadFile)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log, logShow)
import Effect.Uncurried (EffectFn2, mkEffectFn2)
import Node.Process (lookupEnv)

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
  launchAff_ mainAff

handler :: forall a b. EffectFn2 a b (Promise (Maybe (Either Error Unit)))
handler = mkEffectFn2 $ \_ _ -> fromAff mainAff

mainAff :: Aff (Maybe (Either Error Unit))
mainAff = do
  _ <- loadFile
  log "File loaded"
  apiToken <- liftEffect $ lookupEnv "AIRTABLE_KEY"
  void $ traverse (const $ log "Key looked up") apiToken
  traverse (\token -> fetchResults token >>= traverse logShow) apiToken
