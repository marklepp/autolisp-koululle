(defun attribuutit-tiedostoon (tiedostopolku assoclista / i avoin-tiedosto sisalto otsikkorivi otsikot otsikko kirjoitettavat attribuutti)
  "Ottaa tiedostopolun ja assosiaatiolistan, lukee ensimmäiseltä
  riviltä otsikot, ja sitten kirjoittaa assosiaatiolistan arvot 
  sopivien otsikoiden alle"
  (setq sisalto (lue-tiedosto-listaan tiedostopolku)
        otsikkorivi (car sisalto)
        sisalto (cdr sisalto)
        EROTIN ";"
        otsikot (split otsikkorivi EROTIN)
  )
  (foreach otsikko otsikot
    (if (setq attribuutti (assoc otsikko assoclista))
      (progn
        (setq kirjoitettavat (cons (cdr attribuutti) kirjoitettavat))
        (setq assoclista (vl-remove attribuutti assoclista))
      )
      (setq kirjoitettavat (cons "<>" kirjoitettavat))
    )
  )
  (setq otsikot (reverse otsikot))
  (foreach attribuutti assoclista
    (setq otsikot (cons (car attribuutti) otsikot)
          kirjoitettavat (cons (cdr attribuutti) kirjoitettavat)
    )
  )
  (setq otsikot (join (reverse otsikot) EROTIN)
        kirjoitettavat (join (reverse kirjoitettavat) EROTIN)
        sisalto (cons otsikot (reverse (cons kirjoitettavat sisalto)))
  )

  (kirjoita-lista-tiedostoon sisalto tiedostopolku "w")

  (princ)
)


(defun kirjoita-lista-tiedostoon (sisalto tiedostopolku mode / avoin-tiedosto rivi)
  (setq avoin-tiedosto (open tiedostopolku mode))
  (foreach rivi sisalto
    (write-line rivi avoin-tiedosto)
  )
  (close avoin-tiedosto)
)


(defun lue-tiedosto-listaan (tiedostopolku / sisalto uusi-rivi avoin-tiedosto)
  (if (setq avoin-tiedosto (open tiedostopolku "r"))
    (progn
      (while (setq uusi-rivi (read-line avoin-tiedosto))
        (setq sisalto (cons uusi-rivi sisalto))
      )
      (close avoin-tiedosto)
    )
  )
  (reverse sisalto)
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

(defun lista-tiedostoon (tiedostopolku lista / i avoin-tiedosto lista)
  "Ottaa tiedostopolun ja listan, tallentaa arvot tiedoston seuraavalle 
  riville"
  (setq avoin-tiedosto (open tiedostopolku "a"))
  ; Otsikot
  (setq i 0)
  (repeat (1- (length lista))
    (princ (nth i lista) avoin-tiedosto)
    (princ ";")
    (setq i (1+ i))
  )
  (princ (nth i lista) avoin-tiedosto)
  (princ "\n" avoin-tiedosto)
  (close avoin-tiedosto)
)

(defun assosiaatiolista-tiedostoon (tiedostopolku assoclista / i avoin-tiedosto lista)
  "Ottaa tiedostopolun ja assosiaatiolistan, tallentaa nimet tiedoston 
  otsikoiksi ensimmäiselle riville ja arvot seuraavalle 
  riville"
  (setq avoin-tiedosto (open tiedostopolku "a"))
  ; Otsikot
  (setq i 0)
  (repeat (1- (length assoclista))
    (princ (car (nth i assoclista)) avoin-tiedosto)
    (princ ";")
    (setq i (1+ i))
  )
  (princ (car (nth i assoclista)) avoin-tiedosto)
  (princ "\n" avoin-tiedosto)

  ; Arvot
  (setq i 0)
  (repeat (1- (length assoclista))
    (princ (cdr (nth i assoclista)) avoin-tiedosto)
    (princ ";")
    (setq i (1+ i))
  )
  (princ (cdr (nth i assoclista)) avoin-tiedosto)
  (close avoin-tiedosto)
  (princ)
)


(defun blokin-tiedot (blokkientity / entdata handle bl-nimi koordinaatit x-koord y-koord attribuutit tiedot)
  "Ottaa blokin entitynimen, ja palauttaa listan,
  jossa on handle, blokin nimi, X- ja Y-koordinaatit 
  sekä blokin attribuutit"
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

; Demot/testit

(defun ensimmaisen-blokin-tiedot (bl-nimi / )
  (blokin-tiedot (hae-ensimmainen-blokki bl-nimi))
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


(defun printtaa-lista (lista / i)
  (princ "(\n")
  (setq i 0)
  (repeat (length lista)
    (princ "  ")
    (prin1 (nth i lista))
    (princ "\n")
    (setq i (1+ i))
  )
  (princ ")\n")
  (princ)
)

;(printtaa-lista (ensimmaisen-blokin-attribuutit "Title_block_ENG"))
;(printtaa-lista (ensimmaisen-blokin-tiedot "Title_block_ENG"))
;(attribuutit-tiedostoon "testi.csv" (ensimmaisen-blokin-tiedot "Title_block_ENG"))
;(attribuutit-tiedostoon "testi.csv" (ensimmaisen-blokin-tiedot "Title_block_ENG"))
;(startapp "explorer" (findfile "testi.csv"))