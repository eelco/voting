import Data.List (isSuffixOf)

import HAppS.Server hiding (result)
import HAppS.State (startSystemState, Proxy(..))

import Voting.State
import Voting.Model

main :: IO ()
main = do
    startSystemState (Proxy :: Proxy Votes)
    simpleHTTP (nullConf { port = 8008 })
        [ dir "result" [ flatten $ anyRequest $ result ]
        , flatten $ withData (\d -> [ method POST $ vote d ])
        , ext ["html", "css", "js"] $ fileServe ["view.html"] "Voting" 
        ]

ext :: [String] -> ServerPart Response -> ServerPart Response
ext types okay = uriRest filterExt
    where suffixTest = map (isSuffixOf . (:) '.') types
          filterExt uri | uri == "/" || null uri      = okay
                        | or $ map ($ uri) suffixTest = okay
                        | otherwise                   = 
                            anyRequest . notFound $ toResponse "404 Not Found"
