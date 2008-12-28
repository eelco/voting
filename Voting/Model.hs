module Voting.Model where

import HAppS.Server hiding (result)

import Control.Monad
import Control.Applicative

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Rfc2822 (local_part, dot_atom_text, atext) -- email address parsing

import Voting.State

vote :: Vote -> Web String
vote (Vote (Left _))                = badRequest $ "Email address or vote is invalid"
vote (Vote (Right (email, ballot))) = do
    success <- webUpdate $ AddVote email ballot
    if success
        then ok "Thanks for voting!"
        else badRequest "Oh, you already voted."

result :: Web String
result = do
    winners <- webQuery Result
    ok $ "Winners: " ++ show winners

type Email = String
newtype Vote = Vote (Either String (Email, Ballot))

-- TODO: Clean this up, check if candidates are within range?
instance FromData Vote where
    fromData = do email <- look "email"
                  vote  <- look "vote"
                  return $ case parse validEmailParser "" email of
                    Left err -> Vote (Left $ show err)
                    Right _  -> 
                        case parseBallot vote of
                            Left err     -> Vote (Left $ show err)
                            Right ballot -> Vote (Right (email, ballot))

-- == Parsers

-- Every Monad is an Applicative.
instance Applicative (GenParser s a) where
    pure = return
    (<*>) = ap

-- Every MonadPlus is an Alternative.
instance Alternative (GenParser s a) where
    empty = mzero
    (<|>) = mplus

-- A bit more restrictive than addr_text, since we always want a tld, and of at least 2 chars
validEmailParser = (\somebody somewhere  -> concat [ somebody, "@", somewhere ])
  <$> local_part 
  <*  char '@'
  <*> domain
  where domain     = (\subs top -> concat $ subs ++ [top]) <$> many1 (try subdomain) <*> tld
        subdomain  = flip (++) "." <$> many1 atext <* char '.'
        tld        = (:)           <$> atext <*> many1 atext

-- Parse the ballot (copied from Condorcet demo)
parseBallot :: String -> Either ParseError Ballot
parseBallot input = parse ballot "" input where
  ballot :: Parser [[Int]]
  ballot = sepBy1 rank (char ',') <* eof
  rank :: Parser [Int]
  rank = sepBy1 number (char '=')
  number :: Parser Int
  number = read <$> many1 digit
