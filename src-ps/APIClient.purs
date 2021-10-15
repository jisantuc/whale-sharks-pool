module APIClient (fetchResults) where

import Affjax (Error)
import Client (fetchPublicUrl)
import Data.Either (Either)
import Effect.Aff (Aff)
import Model (Results)

fetchResults :: Aff (Either Error Results)
fetchResults = fetchPublicUrl "https://ec2qa7mfsa.execute-api.us-east-1.amazonaws.com/Production"
