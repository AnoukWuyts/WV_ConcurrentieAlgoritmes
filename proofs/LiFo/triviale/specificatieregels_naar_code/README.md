Here you can find the proofs of each comparison of the trivial specification for Lifo from the specification to the code. 
These are the following:

      1) lifo [] = return ()
      2) lifo (Stop:as)=lifo as
      3) lifo (Fork a1 a2:as) = lifo ([a1,a2]++as)
      4) lifo (Atom w : zs)=  w >>= (\a' -> lifo (a':as))
