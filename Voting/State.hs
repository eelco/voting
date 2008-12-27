{-# LANGUAGE TemplateHaskell, FlexibleInstances, MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies, TypeSynonymInstances, DeriveDataTypeable, FlexibleContexts #-}
module Voting.State (AddVote(..), Result(..), Votes, Ballot, Candidate) where

import Control.Monad.State
import Control.Monad.Reader

import Data.Map

import Condorcet

import HAppS.State

type Email = String

type Votes = Map Email Ballot

instance Component Votes where
    type Dependencies Votes = End
    initialValue = empty

addVote :: Email -> Ballot -> Update Votes Bool
addVote email ballot = do 
    votes <- get
    let (exists, votes') = insertLookupWithKey (\_ _ old -> old) email ballot votes  
    put votes'
    return $ exists == Nothing
    
result :: Query Votes [Candidate]
result = ask >>= return . run . elems

$(mkMethods ''Votes ['addVote, 'result])
