{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BlockArguments #-}
module Web.Server.Static where

import WaiAppStatic.Storage.Embedded (EmbeddableEntry(..))
import System.Directory (listDirectory, doesDirectoryExist)
import qualified Data.ByteString.Lazy as BS
import Control.Monad.Trans.Writer.CPS (execWriterT, tell, WriterT)
import Control.Monad (forM_)
import Control.Monad.IO.Class (liftIO)
import System.FilePath (splitExtension)
import Data.String (fromString)
import Control.Exception (SomeException, Exception, handle, throwIO)
import System.FilePath.TH (fileRelativeToProject)

data DetailedException = DetailedException String SomeException
  deriving (Show)

instance Exception DetailedException

rethrow :: String -> IO a -> IO a
rethrow msg = handle (throwIO . DetailedException msg)

frontendBuildDirectory :: FilePath
frontendBuildDirectory = $(fileRelativeToProject "frontend/build") <> "/"

mkEmbedded :: IO [EmbeddableEntry]
mkEmbedded = rethrow frontendBuildDirectory (listDirectory frontendBuildDirectory) >>= execWriterT . go "" where
  go :: FilePath -> [FilePath] -> WriterT [EmbeddableEntry] IO ()
  go base files = forM_ files \file -> do
    let directoryToTest = frontendBuildDirectory <> base <> file
    liftIO (rethrow directoryToTest $ doesDirectoryExist directoryToTest) >>= \case
      True -> do
        let newDirectory = frontendBuildDirectory <> base <> file
        liftIO (rethrow newDirectory $ listDirectory newDirectory) >>= go (base <> file <> "/")
      False -> do
        let fileOfInterest = frontendBuildDirectory <> base <> file
        contents <- liftIO (rethrow fileOfInterest $ BS.readFile fileOfInterest)
        tell
          [ EmbeddableEntry
            { eLocation = fromString (base <> file)
            , eMimeType =
                case snd (splitExtension file) of
                  ".gif" -> "image/gif"
                  ".html" -> "text/html"
                  ".json" -> "text/json"
                  ".jpg" -> "image/jpeg"
                  ".jpeg" -> "image/jpeg"
                  ".png" -> "image/png"
                  ".svg" -> "image/svg+xml"
                  ".webp" -> "image/webp"
                  ".avif" -> "image/avif"
                  ".apng" -> "image/apng"
                  "" -> "application/octet-stream"
                  ".txt" -> "text/plain"
                  ".css" -> "text/css"
                  ".js" -> "text/javascript"
                  ".ico" -> "image/x-icon"
                  ".map" -> "application/json"
                  x -> error x
            , eContent  = Left ("", contents)
            }
          ]
