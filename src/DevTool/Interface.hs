{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
module DevTool.Interface
  ( runCommand
  , Command(..)
  ) where

import Web.API (renderedTypeScriptTypes, api)
import Web.Server (server)
import qualified Servant (serve)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Autohead (autohead)
import Network.Wai.Middleware.Cors (cors, simpleCorsResourcePolicy, CorsResourcePolicy(..))
import System.Directory (getHomeDirectory, setCurrentDirectory)

data Command =
    TypeScript
  | Serve Int

runCommand :: Command -> IO ()
runCommand = \case
  TypeScript -> typescript
  Serve n -> serve n

typescript :: IO ()
typescript = putStrLn renderedTypeScriptTypes

serve :: Int -> IO ()
serve n = do
  getHomeDirectory >>= setCurrentDirectory . (<> "/.devtool")
  run n . middleware $ Servant.serve api server
  where
    middleware = 
        logStdoutDev
      . autohead
      . cors ( const $ Just (simpleCorsResourcePolicy { corsRequestHeaders = ["Content-Type"] }) )
