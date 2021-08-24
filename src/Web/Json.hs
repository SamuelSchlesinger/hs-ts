{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FlexibleContexts #-}
module Web.Json where

import GHC.Generics (Generic, Rep)
import qualified Data.Aeson as Aeson
import Data.Aeson (ToJSON, FromJSON)

newtype Json a = Json { unJson :: a }

instance (Generic a, Aeson.GToJSON' Aeson.Encoding Aeson.Zero (Rep a), Aeson.GToJSON' Aeson.Value Aeson.Zero (Rep a)) => ToJSON (Json a) where
  toEncoding = Aeson.genericToEncoding aesonOptions . unJson
  toJSON = Aeson.genericToJSON aesonOptions . unJson

instance (Generic a, Aeson.GFromJSON Aeson.Zero (Rep a)) => FromJSON (Json a) where 
  parseJSON val = Json <$> Aeson.genericParseJSON aesonOptions val

aesonOptions :: Aeson.Options
aesonOptions = Aeson.defaultOptions
