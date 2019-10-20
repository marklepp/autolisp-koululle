(defun attribuutit-tiedostosta (tiedostopolku / avoin-tiedosto otsikot arvot blokki ent)
  (if (not (findfile tiedostopolku))
    (progn (alert (strcat "Tiedostoa " tiedostopolku " ei löytynyt")) (princ))

    (progn
      (setq avoin-tiedosto (open tiedostopolku "r"))
      (setq otsikot (split (read-line avoin-tiedosto) ";"))
      (while (setq arvot (split (read-line avoin-tiedosto) ";"))
        (setq blokki (mapcar 'cons otsikot arvot))
        (if (setq ent (handent (vl-string-left-trim "'" (cdr (assoc "Handle" blokki)))))
          (vie-attribuutit ent blokki)
        )
      )
      (close avoin-tiedosto)
    )
  )
  (princ)
)


(defun tallenna-kaikki-blokit-tiedostoon (tiedostopolku / ss)
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (blokit-valintajoukosta-tiedostoon ss tiedostopolku)
  (princ)
)


(defun tallenna-listan-blokit-tiedostoon (tiedostopolku bl-nimilista / ss bl-nimi)
  (if (not bl-nimilista)
    (progn (alert "Blokkilista puuttuu") (princ))

    (foreach bl-nimi bl-nimilista
      (setq ss (valitse-blokit bl-nimi))
      (blokit-valintajoukosta-tiedostoon ss tiedostopolku)
      (setq ss nil)
    )
  )
  (princ)
)


(defun blokit-valintajoukosta-tiedostoon (ss tiedostopolku / i assoclista)
  (if ss
    (repeat (setq i (sslength ss))
      (setq 
        i (1- i)
        assoclista (blokin-tiedot (ssname ss i))
      )
      (attribuutit-tiedostoon tiedostopolku assoclista)
    )
  )
  (princ)
)


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

  (poimi-arvot-nimien-mukaan 
    otsikot assoclista 'kirjoitettavat 'assoclista)

  (setq sisalto
    (alusta-tuntemattomat-arvot-vanhoilla-riveilla
      assoclista sisalto)
  )

  (pura-assoclista-nimiin-ja-arvoihin 
    assoclista (reverse otsikot) kirjoitettavat 'otsikot 'kirjoitettavat)

  (setq sisalto (sandwich 
      (join (reverse otsikot) EROTIN)
      sisalto
      (join (reverse kirjoitettavat) EROTIN)
    )
  )

  (kirjoita-lista-tiedostoon 
    sisalto tiedostopolku "w")

  (princ)
)


(defun alusta-tuntemattomat-arvot-vanhoilla-riveilla (assoclista sisalto / rivi)
  (mapcar (function (lambda (rivi) 
      (repeat (length assoclista)
        (setq rivi (strcat rivi ";<>"))
      )
      rivi
    ))
    sisalto
  )
)


(defun sandwich (alkuun lista loppuun)
  (cons alkuun (reverse (cons loppuun (reverse lista))))
)


(defun pura-assoclista-nimiin-ja-arvoihin (<assoclista> <nimet> <arvot> <qnimet> <qarvot> / <assosiaatio>)
  "Cons assoclistan nimet ja arvot omiin muuttujiinsa. Ottaa olemassa olevat
  listat ja palauttaa nämä täydennettyinä qnimiin ja qarvoihin. Nimet ovat \"<>\"
  sisällä, jotta vältytään symbolikonfliktilta kutsujan kanssa."
  (foreach <assosiaatio> <assoclista>
    (setq <nimet> (cons (car <assosiaatio>) <nimet>)
          <arvot> (cons (cdr <assosiaatio>) <arvot>)
    )
  )
  (set <qnimet> <nimet>)
  (set <qarvot> <arvot>)
  (princ)
)


(defun poimi-arvot-nimien-mukaan (<nimet> <assoclista> <qpoimitut> <qassocloput> / <nimi> <assosiaatio> <poimitut>)
  "Poimii nimen perusteella assoclistan arvoja ja 
  lopulta palauttaa poimitut qpoimitut-muuttujaan. 
  qassocloput-muuttuja saa jäljelle jääneet assoclistan jäsenet. Nimet ovat \"<>\"
  sisällä, jotta vältytään symbolikonfliktilta kutsujan kanssa."
  (foreach <nimi> <nimet>
    (if (setq <assosiaatio> (assoc <nimi> <assoclista>))
      (setq <poimitut> (cons (cdr <assosiaatio>) <poimitut>)
            <assoclista> (vl-remove <assosiaatio> <assoclista>)
      )
      (setq <poimitut> (cons "<>" <poimitut>))
    )
  )
  (set <qpoimitut> <poimitut>)
  (set <qassocloput> <assoclista>)
  (princ)
)


(defun kirjoita-lista-tiedostoon (sisalto tiedostopolku mode / avoin-tiedosto rivi)
  (setq avoin-tiedosto (open tiedostopolku mode))
  (foreach rivi sisalto
    (write-line rivi avoin-tiedosto)
  )
  (close avoin-tiedosto)
  (princ)
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


(defun lista-tiedostoon (tiedostopolku lista / i avoin-tiedosto)
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


(defun hae-blokkien-nimet-listaan ( / ss i bl-nimi bl-nimet)
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (if ss
    (repeat (setq i (sslength ss))
      (setq 
        i (1- i)
        bl-nimi (cdr (assoc 2 (entget (ssname ss i))))
      )
      (if (not (member bl-nimi bl-nimet))
        (setq bl-nimet (cons bl-nimi bl-nimet))
      )
    )
  )
  bl-nimet
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