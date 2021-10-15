module Test.ClientSpec where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (JsonDecodeError, decodeJson, parseJson)
import Data.Either (Either, isRight)
import Model (RawResults, Results)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldSatisfy)

knownResult :: Either JsonDecodeError Json
knownResult = parseJson """{"records": [{"id": "rec-bogus-id", "fields": {"Name": "bogus", "Opponent Skill": 2, "WinLoss": "W", "Date": "2021-08-27", "Points": 13, "Order": "4", "Game": "9 Ball", "Season Week": 1, "Session": "Fall 2021"}}]}"""

spec :: Spec Unit
spec = do
  describe "Decode known results" do
    it "Decodes a single-result known result successfully" $
      let
        result :: Either JsonDecodeError RawResults
        result = knownResult >>= decodeJson
      in result `shouldSatisfy` isRight