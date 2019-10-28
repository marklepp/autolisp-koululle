(vl-load-com)


(defun io-osoitteen-haku (tiedostopolku / titleblock drawnumb posluku io-blokit i io-blokin-tiedot possplit io-blokkien-hakutiedot avoin-tiedosto otsikot rivi arvot positio io-osoite ent blokki)
  (defun *error* (msg)
    (if avoin-tiedosto (close avoin-tiedosto))
    (princ msg)
    (princ)
  )
  (setq titleblock (ensimmaisen-blokin-attribuutit "Title_block_ENG")
        drawnumb (cdr (assoc "DRAW.NUMBER" titleblock))
        posluku (car (split drawnumb "-"))
        io-blokit (valitse-blokit "BJR_IO4")
  )
  (repeat (setq i (sslength io-blokit))
    (setq io-blokin-tiedot (blokin-tiedot (ssname io-blokit (setq i (1- i))))
          io-blokin-tiedot (list 
              (cons "Positio" (strcat (car (setq possplit (split (cdr (assoc "JR_POS" io-blokin-tiedot)) "."))) posluku))
              (cons "IO" (cadr possplit))
              (assoc "Handle" io-blokin-tiedot)
            )
          io-blokkien-hakutiedot (cons io-blokin-tiedot io-blokkien-hakutiedot)
    )     
  )
  (setq io-blokkien-hakutiedot (vl-sort io-blokkien-hakutiedot '(lambda (x y) (< (cdr (assoc "IO" x)) (cdr (assoc "IO" y))))))
  (setq avoin-tiedosto (open tiedostopolku "r")
        otsikot (read-line avoin-tiedosto)
        otsikot (split (read-line avoin-tiedosto) ";")
  )
  (while (and io-blokkien-hakutiedot 
              (setq arvot (split (read-line avoin-tiedosto) ";")))
    (setq rivi (mapcar 'cons otsikot arvot)
          positio (cdr (assoc "Positio" rivi))
          i 0
    )
    (while (and (< i (length io-blokkien-hakutiedot)) 
                (not (equal positio (cdr (assoc "Positio" (setq blokki (nth i io-blokkien-hakutiedot)))))))
      (setq i (1+ i))
    )
    (if (< i (length io-blokkien-hakutiedot))
      (progn
        (setq io-osoite (cons "JR_IO" (join (list (cdr (assoc "IBC" rivi)) (cdr (assoc "Slot" rivi)) (cdr (assoc "Kanava" rivi))) "."))
              ent (handent (vl-string-left-trim "'" (cdr (assoc "Handle" blokki))))
        )
        (vie-attribuutit ent (list io-osoite))
        (vl-remove blokki io-blokkien-hakutiedot)
      )
    )
  )
  (princ)
)


(defun join (lista erotin)
  (if (cdr lista)
    (strcat (car lista) erotin (join (cdr lista) erotin))
    (car lista)
  )
)


(defun split (rivi erotin / monesko lista)
  (if rivi
    (if (setq monesko (etsi-kirjain rivi erotin))
      (setq lista 
        (cons (substr rivi 1 (1- monesko)) 
          (split (substr rivi (1+ monesko)) erotin))
      )
      (cons rivi nil)
    )
    nil
  )
)


(defun etsi-kirjain (teksti kirjain / i)
  (if teksti
    (progn
      (setq i 0)
      (while (and (<= (setq i (1+ i)) (strlen teksti)) (not (equal kirjain (substr teksti i 1)))))
      (if (<= i (strlen teksti))
        i
        nil
      )
    )
    nil
  )
)


(defun blokin-tiedot (blokkientity / entdata handle bl-nimi koordinaatit x-koord y-koord attribuutit tiedot)
  "Ottaa blokin entitynimen, ja palauttaa listan,
  jossa on handle, blokin nimi, X- ja Y-koordinaatit 
  sekä blokin attribuutit"
  (if blokkientity
    (setq entdata (entget blokkientity)
          handle (cons "Handle" (strcat "'" (cdr (assoc 5 entdata))))
          bl-nimi (cons "Blokin nimi" (cdr (assoc 2 entdata)))
          koordinaatit (cdr (assoc 10 entdata))
          x-koord (cons "X" (rtos (car koordinaatit) 2 16))
          y-koord (cons "Y" (rtos (cadr koordinaatit) 2 16))
          attribuutit (hae-attribuutit blokkientity)
          tiedot 
            (cons handle
              (cons bl-nimi
                (cons x-koord
                  (cons y-koord
                    attribuutit))))
    )
    nil
  )
)


(defun valitse-blokit (bl-nimi) 
  "Ottaa blokin nimen merkkijonona ja palauttaa valintajoukon
  kaikista sen nimisistä blokeista"
  (ssget "X" (list '(0 . "INSERT") (cons 2 bl-nimi)))
)


(defun hae-attribuutit (entnimi / entdata tyyppi att-nimi att-arvo att-lista) 
  "Ottaa blokin entitynimen, hakee attribuutit, ja palauttaa
  ne assosiaatiolistana '((nimi . arvo) (nimi2 . arvo2) ...)"
  (if entnimi
    (progn
      (setq entnimi (entnext entnimi)
            entdata (entget entnimi)
            tyyppi (cdr (assoc 0 entdata))
      )

      (if (= tyyppi "ATTRIB")
        (setq att-nimi (cdr (assoc 2 entdata))
              att-arvo (cdr (assoc 1 entdata))
              att-lista 
                (cons (cons att-nimi att-arvo) 
                      (hae-attribuutit entnimi)
                )
        )
        nil ; ei attribuutti
      )
    )
    nil ; ei entityä
  )
)


(defun vie-attribuutit (entnimi assoclista / entdata att-nimi vanha-arvo vanha-att uusi-arvo uusi-att) 
  "Ottaa blokin entitynimen ja assosiaatiolistan attribuuteista, ja vie attribuutit blokkiin"
  (while (and (setq entnimi (entnext entnimi))
              (= "ATTRIB" (cdr (assoc 0 (setq entdata (entget entnimi)))))
         )
    (setq att-nimi (cdr (assoc 2 entdata))
          vanha-arvo (cdr (setq vanha-att (assoc 1 entdata)))
          uusi-arvo (cdr (assoc att-nimi assoclista))
          uusi-att (cons 1 uusi-arvo)
    )
    (if (and uusi-arvo (/= uusi-arvo vanha-arvo))
        (progn
          (princ (strcat "\nMuutetaan " att-nimi ": \"" vanha-arvo "\" -> \"" uusi-arvo "\""))
          (entmod (subst uusi-att vanha-att entdata))
          (entupd entnimi)
        )
    )
  )
  (princ)
)


(defun ensimmaisen-blokin-attribuutit ( bl-nimi / )
  (hae-attribuutit (hae-ensimmainen-blokki bl-nimi))
)


(defun hae-ensimmainen-blokki (bl-nimi / ss-blokit joukon-eka)
  "Ottaa blokin nimen merkkijonona, luo valintajoukon siitä 
  blokista, ja palauttaa joukon ensimmäisen jäsenen"
  (setq ss-blokit (valitse-blokit bl-nimi))

  (if ss-blokit
    (setq joukon-eka (ssname ss-blokit 0))
    (princ (strcat "Blokkia '" bl-nimi "' ei ole kuvassa\n"))
  )
  joukon-eka
)
(princ)