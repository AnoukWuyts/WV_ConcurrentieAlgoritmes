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

lifo :: Monad m => [Action m] -> m ()
lifo [] = return ()
lifo (Stop:as) = lifo as
lifo (Fork a1 a2:as) = lifo ([a1,a2] ++ as)
lifo (Atom x:as) = do a' <- x
                      lifo (a':as)

lifoOneProcess :: Monad m => Action m -> m ()
lifoOneProcess p = lifo [p]

data Context m = Empty
               | LFork (Context m) (Action m)
               | RFork (Action m) (Context m)
               | Catom String (Context m)

deriving instance Eq (m (Action m)) => Eq (Context m)
deriving instance Ord (m (Action m)) => Ord (Context m)
deriving instance Show (m (Action m)) => Show (Context m)

instance Arbitrary (WriterT [Char] Identity ()) => Arbitrary (Context (WriterT [Char] Identity)) where
  arbitrary = sized goContext where
    goContext 0 = pure Empty
    goContext n = oneof
      [ pure Empty
      , LFork <$> goContext (n `div` 2) <*> goAction (n `div` 2)
      , RFork <$> goAction (n `div` 2) <*> goContext (n `div` 2)
      , Catom <$> arbitrary <*> goContext (n - 1)
      ]
    goAction 0 = pure Stop
    goAction n = oneof
      [ pure Stop
      , Fork <$> goAction (n `div` 2) <*> goAction (n `div` 2)
      , (\p k -> Atom (p >>= \() -> pure k)) <$> arbitrary <*> goAction (n `div` 2)]

insertInContext :: (Context M)->(Action M)->(Action M)
insertInContext Empty a = a
insertInContext (LFork context action) a = Fork (insertInContext context a) action
insertInContext (RFork action context) a = Fork action (insertInContext context a)
insertInContext (Catom str context) a = Atom (writer (insertInContext context a,str))

type M =(Writer String)

myWriter :: String->Action M -> M (Action M)
myWriter str action = writer (action,str)

myWrite :: String -> M ()
myWrite str = writer ((),str)

main = quickSpec [
  con "lifoOneProcess" (lifoOneProcess:: Action M-> M ()),
  con "stop" (Stop:: (Action M)),
  con "Fork" (Fork ::Action M->Action M->Action M),
  con "insertContext" (insertInContext::Context M->Action M-> Action M),
  con "Writer" (myWriter :: String->Action M -> M (Action M)),
  con "write" (myWrite :: String -> M ()),
  
  con "Atom" (Atom ::((M (Action M))->Action M)),
  con ">>" ((>>) ::  M ()-> M ()->M ()),
  monoType (Proxy :: Proxy (Action M)),
  monoType (Proxy :: Proxy (Context M)),
  monoType (Proxy :: Proxy (M ())),
  lists,
  withMaxTermSize 12
  ] 
