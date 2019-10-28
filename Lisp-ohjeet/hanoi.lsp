; Hanoin torni
; Pöydällä on kolme tappia A, B ja C, joista A:ssa on levyjä päällekäin kokojärjestyksessä.
; Tarkoitus on siirtää levyt samaan järjestykseen tappiin C.
; Säännöt: 
;  - Vain yhtä levyä saa siirtää kerrallaan
;  - Levyn päälle ei saa laittaa sitä suurempaa levyä
;
;       <|>        |         |
;      <<|>>       |         |
;     <<<|>>>      |         |
;    <<<<|>>>>     |         |
; -----------------------------------
;        A         B         C
; 
; Esimerkki (hanoi 4 "A" "B" "C")
(defun hanoi (montako-levya aloitustappi aputappi lopetustappi)
  (if (>= 0 montako-levya)
    (princ)
    (progn
      (hanoi (1- montako-levya) aloitustappi lopetustappi aputappi)
      (siirto aloitustappi lopetustappi)
      (hanoi (1- montako-levya) aputappi aloitustappi lopetustappi)
    )
  )
)
(defun siirto (mista mihin)
  (princ (strcat "Siirto " mista " -> " mihin "\n"))
  (princ)
)
; Ratkaisu toimii, koska jos osataan siirtää yksi vähemmän levyjä, voidaan siirtää ne suurimman päältä
; pois, siirtää alin levy oikeaan paikkaan ja sen jälkeen siirtää levyt taas suurimman päälle.
; Tämä logiikka toimii kun levyjä > 0, ja jos levyjä on 0, ei tehdä mitään.


;Loppu demokoodia, make it pretty!
; (ratkaise-hanoi 4)
(defun ratkaise-hanoi (montako-levya / oikea-siirto i maxpituus)
  (setq oikea-siirto siirto
        i 0
        maxpituus (strlen (itoa (expt 2 montako-levya)))
  )
  (defun siirto (mista mihin)
    (defun *error* (msg)
      (setq siirto oikea-siirto)
      (princ (strcat "asdf" msg))
      (princ)
    )
    (setq i (1+ i))
    (princ (strcat (toista " " (- maxpituus (strlen (itoa i)))) (itoa i) ". "))
    (oikea-siirto mista mihin)
  )
  (princ (strcat "Ratkaistaan hanoin torni " (itoa montako-levya) " levyllä\n"))
  (hanoi montako-levya "A" "B" "C")
  (princ "Hanoin torni ratkaistu!")
  (setq siirto oikea-siirto)
  (princ)
)


; Visualisointi
; (print-hanoi 4 500) 
(defun print-hanoi (montako-levya viive-ms / siirto i a b c)
  (defun siirto (mista mihin)
    (set mihin (cons (car (eval mista)) (eval mihin)))
    (set mista (cdr (eval mista)))
    
    (if (>= viive-ms 500) ;pienempi aika voi jökätä autocadin
      (princ (toista "\n" 30))
    )
    (princ (strcat "Siirto " (itoa (setq i (1+ i))) ":\n"))
    (princ (tornit-tekstiksi korkeus korkeus a b c))
    (princ "\n")
    
    (if (>= viive-ms 500) ;pienempi aika voi jökätä autocadin
        (command-s "delay" viive-ms)
    )
    (princ)
  );defun siirto
  (setq korkeus montako-levya
        i 0)
  (repeat montako-levya
    (setq a (cons montako-levya a)
          montako-levya (1- montako-levya))
  )
  (princ (strcat "Ratkaistaan hanoin torni " (itoa korkeus) " levyllä\n"))
  (princ (tornit-tekstiksi korkeus korkeus a b c))
  (princ "\n")
  (if (>= viive-ms 500) (command-s "delay" 3000))
  (hanoi korkeus 'a 'b 'c)
  (princ "\nHanoin torni ratkaistu!")
  (princ)
)


(defun tornit-tekstiksi (korkeus rivi a b c)
  (if (= rivi 0)
    (strcat (toista "-" (+ 8 (* 3 (1+ (* 2 korkeus))))) "\n"
            (toista " " (+ 3 korkeus)) "A" 
            (toista " " (+ 1 (* 2 korkeus))) "B"
            (toista " " (+ 1 (* 2 korkeus))) "C"
            (toista " " (+ 3 korkeus)) "\n"
    )
    (strcat
      "   "
      (levy-tekstiksi korkeus rivi a)
      " "
      (levy-tekstiksi korkeus rivi b)
      " "
      (levy-tekstiksi korkeus rivi c)
      "   "
      "\n"
      (tornit-tekstiksi korkeus (1- rivi) a b c)
    )
  )
)


(defun levy-tekstiksi (korkeus rivi kasa / tila)
  (if (<= rivi (length kasa))
    (strcat
      (setq tila (toista " " (- korkeus (setq eka (nth (1- rivi) (reverse kasa))))))
      (toista "<" eka)
      "|"
      (toista ">" eka)
      tila
    )
    (strcat 
      (setq tila (toista " " korkeus))
      "|"
      tila
    )
  )
)


(defun toista (teksti montako / tulos)
  (repeat montako
    (setq tulos (cons teksti tulos))
  )
  (apply 'strcat tulos)
)