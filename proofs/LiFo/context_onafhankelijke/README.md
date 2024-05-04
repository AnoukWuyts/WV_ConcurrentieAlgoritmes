Here you can find the proofs of each comparison of a context-independent specification for Lifo.
This are the following comparisons:

      1) lifoOneProcess (insertContext x (Fork stop y)) = lifoOneProcess (insertContext x y)
      2) lifoOneProcess (insertContext x (Fork y stop)) = lifoOneProcess (insertContext x y)
      3) lifoOneProcess(insertContext x (Atom (Writer [] y)))= lifoOneProcess(insertContext x y)
      
