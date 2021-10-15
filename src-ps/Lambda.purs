module Lambda (handler) where

import Prelude

import Affjax (printError)
import AirtableClient (recentResults)
import Control.Promise (Promise, fromAff)
import Data.Argonaut.Core (Json, stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFn2, mkEffectFn2)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, log)
import Effect.Exception (throw)
import Foreign.Object as Object
import Model (RawResults)
import Node.Process (lookupEnv)

unsafeFetchResults :: String -> Aff RawResults
unsafeFetchResults token =
  recentResults token
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
            , headers: Object.fromFoldable [ Tuple "Access-Control-Allow-Origin" "*" ]
            , body: stringify <<< encodeJson $ results
            }
      in
        lambdaEncode <$> unsafeFetchResults token
    Nothing -> liftEffect $ throw "No API token was available"

handler :: forall a b. EffectFn2 a b (Promise Json)
handler = mkEffectFn2 $ \_ _ -> fromAff mainAff
