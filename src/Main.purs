module Main where

import Prelude

import Affjax (printError)
import AirtableClient (fetchResults)
import Control.Promise (Promise, fromAff)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, log)
import Effect.Exception (throw)
import Effect.Uncurried (EffectFn2, mkEffectFn2)
import Model (Results)
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

handler :: forall a b. EffectFn2 a b (Promise Json)
handler = mkEffectFn2 $ \_ _ -> fromAff mainAff

unsafeFetchResults :: String -> Aff Results
unsafeFetchResults token = fetchResults token >>= case _ of
  Right results -> pure results
  Left e -> error (printError e) *> liftEffect (throw "failed to fetch results")

mainAff :: Aff Json
mainAff = do
  apiToken <- liftEffect $ lookupEnv "AIRTABLE_KEY"
  void $ traverse (const $ log "Key looked up") apiToken
  case apiToken of
    Just token -> encodeJson <$> unsafeFetchResults token
    Nothing -> liftEffect $ throw "No API token was available"
