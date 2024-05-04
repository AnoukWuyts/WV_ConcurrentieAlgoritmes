lemma: lifo (xs++ys) = lifo xs >> lifo ys


inductie op xs

basisstap: lifo []++ys = lifo [] >> lifo ys

lifo []++ys
    [def ++]
lifo ys 
    [neutraal element >>]
return () >> lifo ys
    [def lifo]
lifo [] >> lifo ys
    

inductiestap:
    x = (a:as)
    InductieHypothese: lifo (as++ys) = lifo as >> lifo ys
    TB: lifo ((a:as)++ys) = lifo (a:as) >> lifo ys
    gevalsonderscheid op a
    a = Stop
        TB: lifo ((Stop:as)++ys) = lifo (Stop:as) >> lifo ys
        lifo ((Stop:as)++ys)
            [def ++]
        lifo (Stop:(as++ys))
            [def lifo]
        lifo (as++ys)
            [InductieHypothese]
        lifo as >> lifo ys
            [def lifo]
        lifo (Stop:as) >> lifo ys

    a = Fork b c
        TB: lifo (((Fork b c):as)++ys) = lifo ((Fork b c):as) >> lifo ys
        lifo (((Fork b c):as)++ys)
            [def ++]
        lifo  (Fork b c:(as++ys))
            [def lifo]
        lifo [b,c] ++ (as++ys)
            [associativiteit ++]
        lifo ([b,c] ++ as)++ys
            [InductieHypothese]
        lifo ([b,c] ++ as)>> lifo ys
            [def lifo]
        lifo (Fork a b:as) >>  lifo ys

    a = (Atom (Writer str c))
        TB: lifo (((Atom (Writer str c)):as)++ys) = lifo ((Atom (Writer str c)):as) >> lifo ys
        
        lifo (((Atom (Writer str c)):as)++ys)
            [def (++)]
        lifo (Atom (Writer str c):(as++ys))
            [stelling 2.1]
        write str >>  lifo (c:(as++ys))
            [def (++)]
        write str >>  lifo ((c:as)++ys)
            [InductieHypothese]
        write str >> (lifo (c:as) >> lifo ys)
            [associativiteit >>]
        (write str >> lifo (c:as)) >> lifo ys
            [stelling 2.1]
        lifo (Atom (write str c):as) >> lifo ys





