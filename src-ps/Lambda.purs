module Lambda (handler) where

import Prelude

import Affjax (printError)
import AirtableClient (fetchResults)
import Control.Promise (Promise, fromAff)
import Data.Argonaut.Core (Json, stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFn2, mkEffectFn2)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, log)
import Effect.Exception (throw)
import Foreign.Object as Object
import Model (Results)
import Node.Process (lookupEnv)

unsafeFetchResults :: String -> Aff Results
unsafeFetchResults token =
  fetchResults token
    >>= case _ of
        Right results -> pure results
        Left e -> error (printError e) *> liftEffect (throw "failed to fetch results")

mainAff :: Aff Json
mainAff = do
  apiToken <- liftEffect $ lookupEnv "AIRTABLE_KEY"
  void $ traverse (const $ log "Key looked up") apiToken
  case apiToken of
    Just token ->
      let
        lambdaEncode results =
          encodeJson
            { isBase64Encoded: true
            , statusCode: 200
            , headers: Object.empty :: Object.Object String
            , body: stringify <<< encodeJson $ results
            }
      in
        lambdaEncode <$> unsafeFetchResults token
    Nothing -> liftEffect $ throw "No API token was available"

handler :: forall a b. EffectFn2 a b (Promise Json)
handler = mkEffectFn2 $ \_ _ -> fromAff mainAff
