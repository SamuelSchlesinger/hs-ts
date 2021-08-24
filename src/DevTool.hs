module DevTool where

import DevTool.Interface (Command(..), runCommand)
import Options.Applicative

main :: IO ()
main = customExecParser ps parser >>= runCommand
  where
    ps = prefs . mconcat $
      [ disambiguate
      , showHelpOnError
      , showHelpOnEmpty
      , columns 80
      ]

author :: String
author = "TODO: Replace with your name"

projectName :: String
projectName = "TODO: Replace with your project name"

currentYear :: String
currentYear = "TODO: Replace with current year"

parser :: ParserInfo Command
parser = flip info mods . hsubparser . mconcat $
  [ command "typescript" (info parseTypeScript (progDesc "Generate the typescript for the API"))
  , command "serve" (info parseServer (progDesc "Run the server"))
  ]
  where
    mods
      = header projectName
     <> footer
        ( "Copyright "
       <> currentYear
       <> " (c) "
       <> author
        )
     <> progDesc "Development Tools"
    parseTypeScript
      = pure TypeScript
    parseServer
      = Serve <$> portOption
    portOption
      = option auto
        ( long "port"
       <> short 'p'
       <> metavar "PORT"
       <> value 3001
       <> help "The port to run the server on"
        )
