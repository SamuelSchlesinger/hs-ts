{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DataKinds #-}
module Web.Server where

import Web.API
import Servant
import Data.SOP.BasicFunctors (I(..))

server :: Server API
server
  =    health
  :<|> example
  :<|> redirect
  :<|> fileServer

health :: Handler NoContent
health =
  pure NoContent

type RedirectResponse = WithStatus 302 (Headers '[Header "Location" String] ())

redirect :: Handler (Union '[RedirectResponse])
redirect
  = pure
    ( inject @(WithStatus 302 (Headers '[Header "Location" String] ()))
      (I (WithStatus (addHeader "/index.html" ())))
    )

fileServer :: Server Raw
fileServer = serveDirectoryWebApp "."

example :: ExampleRequest -> Handler ExampleResponse
example exampleRequest = pure $ ExampleResponse
  { anotherField = someField exampleRequest <> "!!!"
  }
