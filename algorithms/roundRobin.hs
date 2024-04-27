{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}


module RoundRobin where
import QuickSpec hiding (C)
import Control.Monad.Trans.Writer
import Data.Functor.Identity
import Test.QuickCheck

data Action m
 = Atom (m (Action m))
 | Fork (Action m) (Action m)
 | Stop

deriving instance Eq (m (Action m)) => Eq (Action m)
deriving instance Ord (m (Action m)) => Ord (Action m)
deriving instance Show (m (Action m)) => Show (Action m)
deriving instance (Arbitrary a, Arbitrary w) => Arbitrary (WriterT w Identity a)

instance (Arbitrary (m ()), Monad m) => Arbitrary (Action m) where
  arbitrary = sized go where
    go 0 = pure Stop
    go n = oneof
      [ pure Stop
      , Fork <$> go (n `div` 2) <*> go (n `div` 2)
      , (\p k -> Atom (p >>= \() -> pure k)) <$> arbitrary <*> go (n `div` 2)]

roundr :: Monad m => [Action m] -> m ()
roundr [] = return ()
roundr (Stop:as) = roundr as
roundr (Fork a1 a2:as) = roundr (as ++ [a1,a2])
roundr (Atom x:as) = do a' <- x
                        roundr (as ++ [a'])

type M =(Writer String)

myWriter :: String->Action M -> M (Action M)
myWriter str action = writer (action,str)

myWrite :: String -> M ()
myWrite str = writer ((),str)

main = quickSpec [
  con "roundr" (roundr :: [Action M] -> M ()),
  con "stop" (Stop:: (Action M)),
  con "Fork" (Fork ::Action M->Action M->Action M),
  con "Writer" (myWriter :: String->Action M -> M (Action M)),
  con "write" (myWrite :: String -> M ()),
  
  con "Atom" (Atom ::((M (Action M))->Action M)),
  con ">>" ((>>) ::  M ()-> M ()->M ()),
  monoType (Proxy :: Proxy (Action M)),
  monoType (Proxy :: Proxy (M ())),
  lists,
  withMaxTermSize 12
  ] 
