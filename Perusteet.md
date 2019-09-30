# AutoLISP-Perusteet

AutoLISP (myös Visual Lisp) on AutoDeskin kehittämä ohjelmointikieli AutoCADin toimintojen automatisoimiseen. Tämä tehostaa työtä poistamalla ihmiseltä aikaa vievää, tylsää ja toistuvaa työtä, jättäen aikaa tärkeämpään suunnitteluun.

AutoLISP on helposti lähestyttävä kieli, vaikka ulkonäkö on erikoinen: sulkuja, sulkuja ja sulkuja. Lisp on lyhenne sanoista List processing (listaprosessointi), mikä on kuvaavaa, sillä lispissä on vain yksi, monipuolinen tietorakenne: lista. Itse lisp-koodikin kirjoitetaan lispin ymmärtämässä listamuodossa.

---
## Lispin syntaksi eli lausemuoto

AutoLISPin lauseet noudattavat yhtä kaavaa: `(komento parametri1 parametri2 ...)`. Sulkujen sisällä on ensin komento, ja sen jälkeen komennolle annetut parametrit, joilla komento suoritetaan. 
Esimerkkinä tähän on pluslasku 1 + 1:
```lisp
(+ 1 1)
```
joka palauttaa 2. Mikäli halutaan plussata useampi luku, kirjoitetaan ne kaikki komennon "+" jälkeen sulkujen sisään: 1 + 2 + 3 on lispissä
```lisp
(+ 1 2 3)
```
ja se palauttaa 6.
Jos haluamme yhdistää komentoja, jokaiselle komennolle on tehtävä omat sulut. Tämä voi aluksi hämätä laskutoimituksissa, mutta on ainakin helppo muistaa. Esimerkkinä lasku 10 / (1 + 1) :
```lisp
(/ 10 (+ 1 1))
```
joka palauttaa luvun 5. 

#### Mitä tarkoittaa palauttaminen? Miten se toimii lispissä?
Palauttaminen tarkoittaa, että suoritettu komento/lause antaa kutsujalle jonkin arvon takaisin. Lispissä lause palauttaa aina sen viimeisimmän arvon. Tämän tarkoitus näkyy paremmin myöhemmissä esimerkeissä.

---
## Visual Lisp-kehitysympäristö

Jotta pääsemme alkuun, on hyvä avata AutoCADiin Visual lisp-kehitysympäristö. Tämä onnistuu, kun menee "Manage"-välilehdellä osioon "Applications" ja klikkaa "Visual LISP-editor". Tästä avautuu ikkuna, jonka sisällä on ikkuna Visual LISP Console. Tähän kirjoittamalla voi kokeilla komentojen toimintaa. Vasemmasta yläkulmasta saa avattua uuden tiedoston, johon voi alkaa kirjoittaa lisp-koodia*. Kun etsii apua komennon löytämiseen, F1 avaa AutoCADin help-ikkunan, josta voi seikkailla AutoLISP-reference -osioon, jossa kerrotaan kaikkien AutoLISPin komentojen toiminnasta. Täältä on myös pienen harjoittelun jälkeen helppo löytää sopiva komento ohjelmoinnin avuksi.

*) Kehitysympäristö on melko ikääntynyt, joten vakavassa käytössä suosittelen käyttämään sitä vain testaukseen. Koodin muokkaukseen suosittelen tekstieditoreja kuten Visual Studio Code tai Notepad++. Visual Studio Codeen saa ladattua lisäosan, joka värittää AutoLisp-syntaksin oikein. Opintojakson tarpeisiin kehitysympäristö on kuitenkin riittävä.

---
## Tietotyypit ja lista

Tietotyyppi on tiedon tallennusmuoto, mikä määrittelee, miten ohjelma käsittelee tietoa. AutoLISPissä tietotyyppejä ovat:
 * kokonaisluku (englanniksi integer)
 * reaaliluku (real)
 * merkkijono / teksti (string)
 * symbolit ja muuttujat (symbol, variable)
 * lista (list)
 * tiedosto-osoitin (file descriptor)
 * valintajoukko (selection set)
 * kokonaisuustunniste / osanimi (entity name)
 * VLA-objekti (VLA-object)

Näiden lisäksi on nil, joka tarkoittaa tiedon puutetta*. Muilla kielillä tämä on usein null.

*) Tarkkaan ottaen nil tarkoittaa tyhjää listaa `'()`, mutta käytännössä tämä ei näy. 

---
### Luvut
Luvut ovat joko kokonaislukuja `5` tai reaalilukuja `5.0`. Lisp muuttaa kokonaisluvun automaattisesti reaaliluvuksi, jos yksi laskutoimituksen luvuista on reaaliluku. Jakolaskut kokonaisluvuilla eivät huomioi tuloksen desimaaleja lainkaan, mutta jos toiseen luvuista on merkattu desimaalit, lisp muuntaa tuloksenkin reaaliluvuksi.

Visual Lisp Console:
```lisp
_$ (/ 5 2)
2
_$ (/ 5 2.0)
2.5
_$ (/ 5.0 2)
2.5
```

---
### Merkkijono
Lisp ymmärtää koodin merkkijonoksi, jos sen ympäröi lainausmerkeillä. Esimerkissä alla on ensin kirjoitettu konsoliin merkkijono "tekstiä", jonka lisp ymmärtää merkkijonoksi ja palauttaa sen. Ilman lainausmerkkejä lisp ymmärtää kirjoitetun asian symboliksi, ja yrittää lukea symbolin arvoa, mutta koska sillä ei ole arvoa, lisp palauttaa nil. 

Visual Lisp Console:
```lisp
_$ "tekstiä"
"tekstiä"
_$ tekstiä
nil
```

---
### Symbolit ja muuttujat
Symbolit on lispin tapa käsitellä muuttujia ja funktioita. Symboliin tallennetaan muuttujan tai funktion sisältö. Koodaajalle se on kuitenkin käytännössä vain muuttujan tai funktion nimi. Lispissä nimi voi sisältää kirjainten lisäksi monia merkkejä, joista yleisimmin käytössä on vain ala- ja väliviivat. Asteriskilla `*` nimen ympärillä merkataan usein, että muuttuja on yhteinen kaikille eli globaali muuttuja (esim. `*globaali-muuttuja*`).

#### Muuttujat
Jotta tietoa voidaan käyttää myöhemmin ohjelmassa, voidaan se tallentaa muuttujaan. Toisin kui9n monessa muussa ohjelmointikielessä, lispissä ei tarvitse ilmoittaa muuttujan olemassaoloa ennen sen käyttöä, vaan muuttuja otetaan käyttöön automaattisesti kun se lisätään koodiin. Muuttujaan voi tallentaa mitä vain tietotyyppiä olevaa dataa. Muuttujaan asetetaan tietoa komennolla `setq`, joka palauttaa muuttujaan asetetun arvon. Muuttujaa voi asetuksen jälkeen käyttää myöhemmissä komennoissa.

Visual Lisp Console:
```lisp
_$ (setq numero 5)
5
_$ (+ numero 1)
6
_$ numero
5
_$ (setq tervehdys "Hei")
"Hei"
_$ tervehdys
"Hei"
_$ (strcat tervehdys " maailma!") 
"Hei maailma!"
```

#### Funktiot
Funktioilla voidaan kirjoittaa koodia itse nimettyihin komentoihin, joita voidaan myöhemmin käyttää samalla tavalla ohjelman osana. Tämä johtaa helpommin ymmärrettävään koodiin, sillä yksittäiselle funktiolle annettu nimi kertoo paljon enemmän kuin monta riviä erillistä koodia.
Funktio määritellään komennolla `defun` (lyhenne sanoista "define function").

Syötetään Visual Lisp -konsoliin alla oleva esimerkkifunktio, joka laskee kolmen luvun keskiarvon ja palauttaa reaaliluvun:
```lisp
(defun keskiarvo (eka toka kolmas)
  (/ (+ eka toka kolmas) 3.0)
)
```

Visual Lisp Console:
```lisp
_$ (defun keskiarvo (eka toka kolmas)
  (/ (+ eka toka kolmas) 3.0)
)
KESKIARVO
_$ (keskiarvo 3 4 5)
4.0
_$ (keskiarvo 1 4 9)
4.66667
```

Esimerkissä lisp-konsoli palauttaa funktion määrittelyn jälkeen funktion symbolin `KESKIARVO`. Tämän jälkeen keskiarvo-funktio on vapaasti käytettävissä kuten muut komennot. 

Mikäli funktio halutaan käyttöön AutoCADin piirtotilassa, laitetaan funktion nimen eteen `c:`:
```lisp
(defun c:heippa ()
  (princ "Hei maailma!")
  (princ)
)
```
Tämän jälkeen komentoa voi käyttää piirtotilassa kuten muita piirtokomentoja, kuten BLOCK tai LINE. Kun ylläolevan funktion kopioi lisp-konsoliin, piirtotilan komentoehdotuksiin ilmestyy "HEIPPA".

#### Funktion määrittelyn osat
Funktiomäärittelyn syntaksi koostuu nimen lisäksi neljästä osasta; nimi, argumentit, paikalliset muuttujat ja suoritettavat komennot: 
```lisp
(defun nimi (argumentti-1 argumentti-2  / paikalliset-muuttujat)
  (komento ...)
  ...
  (komento ...)
)
```
Argumentit on arvoja, joita funktio käyttää suoritukseen. Nämä annetaan funktiota kutsuvasta ohjelmasta funktion parametreina. Kutsun `(nimi arvo-1 arvo-2)` kohdalla arvo-1 kopioituu argumentti-1:een ja arvo-2 kopioituu argumentti-2:een. Tämän jälkeen funktio suorittaa komentonsa käyttäen argumentti-1:tä ja argumentti-2:ta.

Paikalliset muuttujat on muuttujia, joita funktiossa käytetään, mutta joiden arvon ei haluta säilyvän funktion ulkopuolella. Jos esimerkiksi asetamme muuttujaan `kokonimi` arvon `"Matti Meikäläinen"` funktion nimi sisällä, ja kerromme muuttujan olevan paikallinen, `kokonimi` unohtaa arvonsa heti kun poistutaan funktiosta.

Visual Lisp Console:
```lisp
_$ ; Funktio globaalilla muuttujalla:
(defun nimi-globaali (etunimi sukunimi)
  (setq kokonimi (strcat etunimi " " sukunimi))
)

; Funktio paikallisella muuttujalla:
(defun nimi-paikallinen (etunimi sukunimi / kokonimi)
  (setq kokonimi (strcat etunimi " " sukunimi))
)
NIMI-GLOBAALI
NIMI-PAIKALLINEN
_$ (nimi-paikallinen "Matti" "Meikäläinen")
"Matti Meikäläinen"
_$ kokonimi
nil
_$ (nimi-globaali "Matti" "Meikäläinen")
"Matti Meikäläinen"
_$ kokonimi
"Matti Meikäläinen"
```
---
### Lista
Lista on lispin pohjimmainen tietorakenne. Lista koostuu elementeistä, jotka voivat olla mitä vain tietotyyppiä. Listojen käsittelyyn AutoLISPissä on monia valmiita funktioita. Alla on vain pintaraapaisu.

Lista voidaan luoda monella tapaa. Yksi on käyttää komentoa `list`, joka ottaa annetut arvot ja kasaa niistä listan siinä järjestyksessä kuin ne on sille annettu:

Visual Lisp Console:
```lisp
_$ (setq lista-1 (list "a" 2 "c"))
("a" 2 "c")
```

Listaan voidaan lisätä jäseniä komennolla `cons` (tulee sanasta "construct"). Cons lisää jäsenen listan ensimmäiseksi:
```lisp
_$ (setq lista-2 (cons "jäsen" lista-1))
("jäsen" "a" 2 "c")
```

Listoja voidaan myös ketjuttaa toisiinsa komennolla `append`:
```lisp
_$ (setq koottu-lista (append lista-1 lista-2))
("a" 2 "c" "jäsen" "a" 2 "c")
```

Listan jäseniin pääsee käsiksi komennolla `nth`. Järjestysnumerot lähtevät nollasta. Jos palautetaan neljäs jäsen listalta, kutsutaan `(nth 3 koottu-lista)`. Listan voi kääntää komennolla `reverse`:
```lisp
_$ (nth 3 koottu-lista)
"jäsen"
_$ (reverse koottu-lista)
("c" 2 "a" "jäsen" "c" 2 "a")
```
---
## Tekstin kirjoittaminen AutoCADin command promptiin tai tiedostoon

Koodin sisältä voidaan käyttäjälle näyttää viestejä AutoCADin command promptissa eli komentorivillä. Tämä tapahtuu käyttämällä jotain komennoista _princ_, _prin1_ tai _print_. Kaikki näistä toimivat periaatteella (_komento_ _asia_). Tätä voit kokeilla command promptissa:
```lisp
(princ "moi")
(prin1 "moi")
(print "moi")
```

Samat komennot kirjoittavat dataa tiedostoon: `(komento asia avoin-tiedosto)`. Princ riisuu asiasta kaiken tietotyyppiin liittyvän tiedon, kun taas prin1 ja print säilyttävät lispin ymmärtämät muotoilut, jolloin tiedostosta voisi lukea suoraan dataa ohjelmaan. Pelkän tekstin kirjoittamiseen komento _write-line_ on parempi. `(write-line merkkijono avoin-tiedosto)` kirjoittaa merkkijonon tiedostoon ja vaihtaa seuraavalle riville. Tiedoston avaamisesta kerrotaan myöhemmin.