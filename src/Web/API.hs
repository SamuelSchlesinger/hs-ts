{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
module Web.API
  ( API
  , renderedTypeScriptTypes
  , typeScriptTypes
  , api
  , ExampleRequest(..)
  , ExampleResponse(..)
  ) where

import Servant.API
import GHC.TypeLits (Symbol)
import Web.Json
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)
import Data.Proxy (Proxy(Proxy))
import Data.Aeson.TypeScript.TH (deriveTypeScript, TSDeclaration, formatTSDeclarations', FormattingOptions(..), ExportMode(ExportEach), SumTypeFormat(EnumWithType))
import Data.Aeson.TypeScript.Recursive (getTypeScriptDeclarationsRecursively)
import Network.HTTP.Media.MediaType ((//))

renderedTypeScriptTypes :: String
renderedTypeScriptTypes = formatTSDeclarations' typeScriptFormattingOptions typeScriptTypes where
  typeScriptFormattingOptions = FormattingOptions
    { numIndentSpaces = 2
    , interfaceNameModifier = id
    , typeNameModifier = id
    , exportMode = ExportEach
    , typeAlternativesFormat = EnumWithType
    }

typeScriptTypes :: [TSDeclaration]
typeScriptTypes = getTypeScriptDeclarationsRecursively (Proxy @(TypeScriptTypes API))

api :: Proxy API
api = Proxy

type family TypeScriptTypes xs where
  TypeScriptTypes EmptyAPI
    = ()
  TypeScriptTypes (NoContentVerb (method :: k))
    = ()
  TypeScriptTypes ((x :: Symbol) :> y)
    = TypeScriptTypes y
  TypeScriptTypes (ReqBody' mods contentTypes x :> y)
    = ( If (ContainsJSON contentTypes) x ()
      , TypeScriptTypes y
      )
  TypeScriptTypes (xs :<|> ys)
    = ( TypeScriptTypes xs
      , TypeScriptTypes ys
      )
  TypeScriptTypes (UVerb method contentTypes returnTypes)
    = If (ContainsJSON contentTypes) (UVerbTypeScript returnTypes) ()
  TypeScriptTypes (Verb method status contentTypes returnType)
    = If (ContainsJSON contentTypes) returnType ()
  TypeScriptTypes Raw
    = ()

type family UVerbTypeScript xs where
  UVerbTypeScript (WithStatus n x ': xs) = (x, UVerbTypeScript xs)
  UVerbTypeScript (x ': xs) = (x, UVerbTypeScript xs)

type family ContainsJSON xs where
  ContainsJSON '[]          = 'False
  ContainsJSON (JSON ': xs) = 'True
  ContainsJSON (x ': xs)    = ContainsJSON xs

data AllTypes

instance Accept AllTypes where
  contentType _ = "*" // "*"

instance MimeRender AllTypes () where
  mimeRender _ _ = ""

data ExampleRequest = ExampleRequest
  { someField :: String
  }
  deriving stock (Eq, Ord, Show, Read, Generic)
  deriving (ToJSON, FromJSON) via Json ExampleRequest

data ExampleResponse = ExampleResponse
  { anotherField :: String
  }
  deriving stock (Eq, Ord, Show, Read, Generic)
  deriving (ToJSON, FromJSON) via Json ExampleResponse

type API =
       "health" :> GetNoContent
  :<|> "example" :> ReqBody '[JSON] ExampleRequest :> Post '[JSON] ExampleResponse
  :<|> UVerb 'GET '[AllTypes] '[WithStatus 302 (Headers '[Header "Location" String] ())]
  :<|> Raw

$(deriveTypeScript aesonOptions ''ExampleRequest)
$(deriveTypeScript aesonOptions ''ExampleResponse)
