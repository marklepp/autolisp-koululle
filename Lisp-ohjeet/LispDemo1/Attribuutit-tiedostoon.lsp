(defun c:tuo-att ( / tiedostopolku bl-nimet)
  (if (setq tiedostopolku (getfiled 
        "Mistä tiedostosta tuodaan tiedot?" 
        (strcat (vl-filename-base (getvar "dwgname")) ".csv")
        "csv"
        0
      ))
    (attribuutit-tiedostosta tiedostopolku)
    (princ "\n--Toiminto peruutettu--")
  )
  (princ)
)


(defun c:vie-att ( / tiedostopolku bl-nimet)
  (if (setq tiedostopolku (getfiled 
        "Millä nimellä haluat tallentaa tiedoston?" 
        (strcat (vl-filename-base (getvar "dwgname")) ".csv")
        "csv"
        1
      ))
    (progn
      (if (findfile tiedostopolku)
        (vl-file-delete tiedostopolku)
      )
      (tallenna-kaikki-blokit-tiedostoon tiedostopolku)
      (startapp "explorer" tiedostopolku)
    )
    (princ "\n--Toiminto peruutettu--")
  )
  (princ)
)


(defun attribuutit-tiedostosta (tiedostopolku / avoin-tiedosto otsikot arvot blokki ent)
  (defun *error* (msg)
    (if avoin-tiedosto (close avoin-tiedosto))
    (princ msg)
    (princ)
  )
  (if (not (findfile tiedostopolku))
    (progn (alert (strcat "Tiedostoa " tiedostopolku " ei löytynyt")) (princ))

    (progn
      (setq tiedostonimi (strcat (getvar "dwgprefix") (getvar "dwgname"))
            avoin-tiedosto (open tiedostopolku "r")
            otsikot (split (read-line avoin-tiedosto) ";"))
      (while (setq arvot (split (read-line avoin-tiedosto) ";"))
        (setq blokki (mapcar 'cons otsikot arvot))
        (if (and (equal tiedostonimi (cdr (assoc "Tiedostonimi" blokki)))
                 (setq ent (handent (vl-string-left-trim "'" (cdr (assoc "Handle" blokki))))))
          (vie-attribuutit ent blokki)
        )
      )
      (close avoin-tiedosto)
    )
  )
  (princ)
)


(defun tallenna-kaikki-blokit-tiedostoon (tiedostopolku / ss)
  (setq ss (ssget "X" '((0 . "INSERT") (66 . 1))))
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


(defun blokit-valintajoukosta-tiedostoon (ss tiedostopolku / vanhat-otsikot otsikot tiedot arvot)
  (if ss
    (progn
      (setq 
        vanhat-otsikot (lue-otsikot-tiedostosta tiedostopolku)
        tiedot (hae-blokkien-tiedot ss vanhat-otsikot)
        otsikot (car tiedot)
        arvot (cadr tiedot)
        arvot (tayta-tyhjat-arvot-listoihin otsikot arvot)
        arvot (muuta-listat-csv-riveiksi arvot ";")
        temp-tiedosto (strcat (getenv "TMP") "\\tempcsv.csv")
      )
      (if (and (kopioi-tayttaen-tyhjat-arvot-csv-tiedostossa 
                  ";" otsikot tiedostopolku temp-tiedosto)
               (kirjoita-lista-tiedostoon arvot temp-tiedosto "a")
               (if (findfile tiedostopolku) (vl-file-delete tiedostopolku) t)
               (vl-file-copy temp-tiedosto tiedostopolku nil)
          )
        (princ "\nTiedoston kirjoitus onnistui")
        (progn (alert "\nJokin meni pieleen tiedostoa kirjoittaessa, pysäytetään ohjelma") (exit))
      )
    )
  )
  (princ)
)


(defun kopioi-tayttaen-tyhjat-arvot-csv-tiedostossa (erotin otsikot alkutied lopputied / progress alkukoko rivi avoin-tiedosto tavoite kopiotiedosto rivilista)
  (if (and alkutied (findfile alkutied))
    (progn
      (setq progress 0
            alkukoko (vl-file-size alkutied)
            avoin-tiedosto (open alkutied "r")
            rivi (read-line avoin-tiedosto)
            alkukoko (- alkukoko (strlen rivi))
            vanhat-otsikot (split rivi erotin)
            tavoite (length otsikot)
            kopiotiedosto (open lopputied "w")
      )
      (write-line (join otsikot erotin) kopiotiedosto)
      (if (< (length vanhat-otsikot) tavoite)
        (progn
          (acet-ui-progress-init "Taytetaan tyhjia alueita" alkukoko)
          (while (setq rivi (read-line avoin-tiedosto))
            (setq progress (+ progress (strlen rivi))
                  rivilista (split rivi erotin)
                  rivilista (tayta-tyhjat-arvot-listaan tavoite rivilista)
            )
            (write-line (join rivilista erotin) kopiotiedosto)
            (acet-ui-progress-safe progress)
          )
          (acet-ui-progress-done)
        )
        (while (setq rivi (read-line avoin-tiedosto))
          (write-line rivi kopiotiedosto)
        )
      )
      (close avoin-tiedosto)
      (close kopiotiedosto)
      t
    )
    (if lopputied 
      (progn
        (setq kopiotiedosto (open lopputied "w"))
        (write-line (join otsikot erotin) kopiotiedosto)
        (close kopiotiedosto)
        t
      )
      nil
    )
  )
)


(defun muuta-listat-csv-riveiksi (listat erotin / progress rivi i valmiit)
  (setq progress 0)
  (acet-ui-progress-init "Muutetaan listoja tekstiksi" (length listat))
  (repeat (setq i (length listat))
    (setq
      i (1- i)
      rivi (join (nth i listat) erotin)
      valmiit (cons rivi valmiit)
      progress (1+ progress)
    )
    (acet-ui-progress-safe progress)
  )
  (acet-ui-progress-done)
  valmiit
)


(defun tayta-tyhjat-arvot-listoihin (otsikot arvot / i tavoite valmiit tarkistettava progress)
  (setq progress 0
        tavoite (length otsikot)
  )
  (acet-ui-progress-init "Tarkistetaan attribuuttilistojen pituudet" (length arvot))

  (repeat (setq i (length arvot))
    (setq 
      i (1- i)
      tarkistettava (nth i arvot)
      tarkistettava (tayta-tyhjat-arvot-listaan tavoite tarkistettava)
      valmiit (cons tarkistettava valmiit)
      progress (1+ progress)
    )
    (acet-ui-progress-safe progress)
  )
  (acet-ui-progress-done)
  valmiit
)


(defun tayta-tyhjat-arvot-listaan (tavoitepituus taytettava)
  (if (< (length taytettava) tavoitepituus)
    (progn
      (setq taytettava (reverse taytettava))
      (while (< (length taytettava) tavoitepituus)
        (setq taytettava (cons "<>" taytettava))
      )
      (setq taytettava (reverse taytettava))
    )
  )
  taytettava
)


(defun hae-blokkien-tiedot (ss otsikot / progress i assoclista jarjestetyt arvot)
  (setq progress 0
        tiedostonimi (cons "Tiedostonimi"  (strcat (getvar "dwgprefix") (getvar "dwgname")))
  )
  (acet-ui-progress-init "Haetaan blokkeja" (sslength ss))
  (repeat (setq i (sslength ss))
    (setq 
      i (1- i)
      assoclista (blokin-tiedot (ssname ss i))
      assoclista (cons tiedostonimi assoclista)
      jarjestetyt (attribuutit-tiedoston-jarjestykseen otsikot assoclista)
      otsikot (car jarjestetyt)
      arvot (cons (cadr jarjestetyt) arvot)
      progress (1+ progress)
    )
    (acet-ui-progress-safe progress)
  )
  (acet-ui-progress-done)
  (list otsikot (reverse arvot))
)


(defun lue-otsikot-tiedostosta (tiedostopolku / avoin-tiedosto rivi otsikot)
  (if (and tiedostopolku (findfile tiedostopolku))
    (progn 
      (setq avoin-tiedosto (open tiedostopolku "r"))
      (if (setq rivi (read-line avoin-tiedosto))
        (setq otsikot (split rivi ";"))
      )
      (close avoin-tiedosto)
    )
    (setq otsikot nil)
  )
  otsikot
)


(defun attribuutit-tiedoston-jarjestykseen (otsikot assoclista / kirjoitettavat)
  (poimi-arvot-nimien-mukaan
    otsikot assoclista 'kirjoitettavat 'assoclista)
  (pura-assoclista-nimiin-ja-arvoihin
    assoclista otsikot kirjoitettavat 'otsikot 'kirjoitettavat)
  (list otsikot kirjoitettavat)
)


(defun pura-assoclista-nimiin-ja-arvoihin (<assoclista> <nimet> <arvot> <qnimet> <qarvot> / <assosiaatio>)
  "Cons assoclistan nimet ja arvot omiin muuttujiinsa. Ottaa olemassa olevat
  listat ja palauttaa nämä täydennettyinä qnimiin ja qarvoihin. Nimet ovat \"<>\"
  sisällä, jotta vältytään symbolikonfliktilta kutsujan kanssa."
  (setq <nimet> (reverse <nimet>)
        <arvot> (reverse <arvot>)
  )
  (foreach <assosiaatio> <assoclista>
    (setq <nimet> (cons (car <assosiaatio>) <nimet>)
          <arvot> (cons (cdr <assosiaatio>) <arvot>)
    )
  )
  (set <qnimet> (reverse <nimet>))
  (set <qarvot> (reverse <arvot>))
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
  (set <qpoimitut> (reverse <poimitut>))
  (set <qassocloput> <assoclista>)
  (princ)
)


(defun kirjoita-lista-tiedostoon (sisalto tiedostopolku mode / progress avoin-tiedosto rivi)
  (if tiedostopolku
    (progn
      (setq progress 0)
      (acet-ui-progress-init "Tiedostoa kirjoitetaan" (length sisalto))
      (setq avoin-tiedosto (open tiedostopolku mode))
      (foreach rivi sisalto
        (write-line rivi avoin-tiedosto)
        (setq progress (1+ progress))
        (acet-ui-progress-safe progress)
      )
      (close avoin-tiedosto)
      (acet-ui-progress-done)
      t
    )
    nil
  )
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
  (setq ss (ssget "X" '((0 . "INSERT") (66 . 1))))
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
  (reverse bl-nimet)
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
;(startapp "explorer" (findfile "testi.csv"))