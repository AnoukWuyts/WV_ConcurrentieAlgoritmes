Here you can find the proofs of each comparison of the trivial specification for Round-robin from the specification to the code. 
These are the following:

      1) roundr [] = write []
      2) roundr(Stop:as)=roundr as
      3) roundr (Fork a1 a2:as) = roundr (as ++ [a1,a2])
      4) roundr (Atom (Writer str x) : zs) = write str >>' roundr (zs++[x])
