module AirtableClient (recentResults, fetchResults) where

import Affjax (Error)
import Client (fetchUrl)
import Data.Either (Either)
import Effect.Aff (Aff)
import Model (RawResults)

fetchResults :: String -> Aff (Either Error RawResults)
fetchResults token =
  let
    baseUrl = "https://api.airtable.com/v0/app9IJg37UKNWeN8g/Results"
  in
    fetchUrl token baseUrl

recentResults :: String -> Aff (Either Error RawResults)
recentResults token =
  let
    baseUrl = "https://api.airtable.com/v0/app9IJg37UKNWeN8g/Results?view=Recent"
  in
    fetchUrl token baseUrl
