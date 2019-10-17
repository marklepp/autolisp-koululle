(defun attribuutit-tiedostoon (tiedostopolku assoclista / i avoin-tiedosto otsikkorivi otsikot otsikko)
  "Ottaa tiedostopolun ja assosiaatiolistan, lukee ensimmäiseltä
  riviltä otsikot, ja sitten kirjoittaa assosiaatiolistan arvot 
  sopivien otsikoiden alle"
  (setq avoin-tiedosto (open avoin-tiedosto "r")
        otsikkorivi (read-line avoin-tiedosto))
  (close avoin-tiedosto)

  (setq otsikot (split otsikkorivi ";"))'

  (foreach otsikko otsikot
    (if (setq attribuutti (assoc otsikko assoclista))
      (progn
        (setq kirjoitettavat (cons (cdr attribuutti) kirjoitettavat))
        (vl-remove attribuutti assoclista)
      )
    )
    (setq kirjoitettavat (cons "<>" kirjoitettavat))
  )
  (setq otsikot (reverse otsikot))
  (foreach attribuutti assoclista
    (setq otsikot (cons (car attribuutti) otsikot)
          kirjoitettavat (cons (cdr attribuutti) kirjoitettavat)
    )
  )
  ;; tästä kesken!!

)


(defun split (rivi erotin / monesko lista)
  (if (setq monesko (etsi-kirjain rivi erotin))
    (setq lista 
      (cons (substr rivi 1 (1- monesko)) 
        (split (substr rivi (1+ monesko)) erotin))
    )
    (cons rivi nil)
  )
)


(defun etsi-kirjain (teksti kirjain / i)
  (setq i 0)
  (while (and (<= (setq i (1+ i)) (strlen teksti)) (not (equal kirjain (substr teksti i 1)))))
  (if (<= i (strlen teksti))
    i
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


(defun blokin-tiedot (blokkientity)
  "Ottaa blokin entitynimen, ja palauttaa listan,
  jossa on handle, blokin nimi, X- ja Y-koordinaatit 
  sekä blokin attribuutit"
  (setq entdata (entget blokkientity)
        handle (cons "Handle" (strcat "'" (cdr (assoc 5 entdata))))
        bl-nimi (cons "Blokin nimi" (cdr (assoc 2 entdata)))
        koordinaatit (cdr (assoc 10 entdata))
        x-koord (cons "X" (car koordinaatit))
        y-koord (cons "Y" (cadr koordinaatit))
        attribuutit (hae-attribuutit blokkientity)
        blokin-tiedot 
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

(printtaa-lista (ensimmaisen-blokin-attribuutit "Title_block_ENG"))
(printtaa-lista (ensimmaisen-blokin-tiedot "Title_block_ENG"))