module Http where

import Prelude
import AirtableClient as Client
import Data.Either (Either(..))
import HTTPure (Request, ResponseM, internalServerError, notFound, ok)
import HTTPure.Method (Method(..))
import Model (JsonBody(..))

router ::
  Request ->
  ResponseM
router { method: Get, path: [ "" ] } =
  Client.fetchResults "abcde"
    >>= ( case _ of
          Right resp -> ok (JsonBody resp)
          Left _ -> internalServerError "Something went wrong while retrieving airtable results"
      )

router _ = notFound
