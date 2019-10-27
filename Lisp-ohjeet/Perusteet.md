# AutoLISP-Perusteet

AutoLISP (myös Visual Lisp) on AutoDeskin kehittämä ohjelmointikieli AutoCADin toimintojen automatisoimiseen. Tämä tehostaa työtä poistamalla ihmiseltä aikaa vievää, tylsää ja toistuvaa työtä, jättäen aikaa tärkeämpään suunnitteluun.

AutoLISP on helposti lähestyttävä kieli, vaikka ulkonäkö on erikoinen: sulkuja, sulkuja ja sulkuja. Lisp on lyhenne sanoista List processing (listaprosessointi), mikä on kuvaavaa, sillä lispissä on vain yksi, monipuolinen tietorakenne: _lista_. Itse lisp-koodikin kirjoitetaan lispin ymmärtämässä listamuodossa.

---
## Visual Lisp-kehitysympäristö VLIDE

Jotta pääsemme alkuun, on hyvä avata AutoCADiin Visual lisp-kehitysympäristö. Tämä onnistuu, kun menee "Manage"-välilehdellä osioon "Applications" ja klikkaa "Visual LISP-editor", tai kirjoittaa CADin komentoriville VLIDE. Tästä avautuu ikkuna, jonka sisällä on ikkuna Visual LISP Console. Tähän kirjoittamalla voi kokeilla komentojen toimintaa. Vasemmasta yläkulmasta saa avattua uuden tiedoston, johon voi alkaa kirjoittaa lisp-koodia*. Kun etsii apua komennon löytämiseen, F1 avaa AutoCADin help-ikkunan, josta voi seikkailla AutoLISP-reference -osioon, jossa kerrotaan kaikkien AutoLISPin komentojen toiminnasta. Täältä on myös pienen harjoittelun jälkeen helppo löytää sopiva komento ohjelmoinnin avuksi.

Tässä oppaassa käytetään esimerkkeinä Visual Lisp -konsoliin syötettyjä komentoja. Konsoli odottaa komentoa, kun sen rivin alussa on `_$`. Tämän perään voi kirjoittaa komennon, ja konsoli suorittaa komennon kun painetaan `enter`. Komennon palauttama arvo ilmestyy kirjoitetun rivin alle. Esimerkkinä syötetään komento `(+ 10 5)` konsoliin, jolloin seuraavalle riville ilmestyy palautettu arvo `15` ja konsoli ilmoittaa odottavansa seuraavaa komentoa uudella rivillä taas merkein `_$`:
```lisp
_$ (+ 10 5)
15
_$
```

Konsoliin voi kirjoittaa useamman rivin ennen suoritusta, jos painaa `shift + enter` kun haluaa riviä. Esimerkeissä annan koodipätkiä, jotka voi myös itse kirjoittaa konsoliin. Nämä eivät välttämättä ole kaikkein käytännöllisimpiä esimerkkejä, mutta niistä näkee rivi riviltä, mitä lispissä tapahtuu.

#### Mitä tarkoittaa palauttaminen? Miten se toimii lispissä?
Palauttaminen tarkoittaa, että suoritettu komento/lause antaa kutsujalle jonkin arvon takaisin. Lispissä lause palauttaa aina sen viimeisimmän arvon. Tämän tarkoitus näkyy paremmin myöhemmissä esimerkeissä.

&lt;div style="page-break-after: always;"&gt;&lt;/div&gt;

---
## Lispin syntaksi eli kielioppi
AutoLISPin lauseet noudattavat yhtä kaavaa: `(komento parametri1 parametri2 ...)`. Sulkujen sisällä on ensin komento, ja sen jälkeen komennolle annetut parametrit, joilla komento suoritetaan. 
Esimerkkinä tähän on pluslasku 1 + 1: `(+ 1 1)`
```lisp
_$ (+ 1 1)
2
```
Mikäli halutaan plussata useampi luku, kirjoitetaan ne kaikki komennon "+" jälkeen sulkujen sisään: 1 + 2 + 3 on lispissä `(+ 1 2 3)`
```lisp
_$ (+ 1 2 3)
6
```
Jos haluamme yhdistää komentoja, jokaiselle komennolle on tehtävä omat sulut. Tämä voi aluksi hämätä laskutoimituksissa, mutta on ainakin helppo muistaa. Esimerkkinä lasku 10 / (1 + 1): `(/ 10 (+ 1 1))`
```lisp
_$ (/ 10 (+ 1 1))
5
```
---
## AutoCAD-komennot lispin kautta
AutoCAD-työskentelyssä tulee useasti eteen tilanteita, joissa syötetään monesti komentoja samoilla asetuksilla. Lisp tarjoaa mahdollisuuden tehdä omia komentoja, joilla voi yhdistellä olemassa olevat komennot paremmiksi omaan käyttöön. Esimerkiksi TEXT-komento kysyy tekstin korkeutta ja kulmaa, vaikka usein pitäisi vain saada teksti paikoilleen. Lisp-komennossa voidaan antaa nämä oletukset:
```lisp
(command "TEXT" (getpoint) 5.0 0.0)
```
Tästä saa tehtyä oman komennon kirjoittamalla siitä funktiomäärittelyn. Laitetaan halutun toiminnon ympärille `defun` ja annetaan komennolle nimi `c:teksti`:
```lisp
(defun c:teksti ()
  (command "TEXT" (getpoint) 5.0 0.0)
)
```
Tämän jälkeen AutoCAD ehdottaa komentoa "TEKSTI", joka viittaa yllä olevaan funktioon. `c:` laitetaan nimen eteen, että AutoCAD tunnistaa tämän olevan piirtotilassa käytettävä komento.

Käyttäjältä voi myös kysyä tiedot etukäteen, tallentaa ne muuttujaan, ja sitten käyttää niitä useassa komennossa. Alla esimerkkikomento "ALUE", joka kirjoittaa alueen nimen ja piirtää nelikulmion sen ympärille. Tekstin alkupistettä siirretään yksi oikealle ja alas, jotta se ei ole nelikulmion päällä. 
```lisp
(defun c:alue ()
  (setq teksti (getstring "Anna alueen nimi: "))
  (setq ekapiste (getpoint "Ensimmäinen piste: "))
  (setq tekstipiste (list (+ (car ekapiste) 1) (- (cadr ekapiste) 1)))
  (command "TEXT" "Justify" "TL" tekstipiste 5.0 0.0 teksti)
  (command "RECTANG" ekapiste)
  (princ)
)
```
Tallennus muuttujaan tapahtuu komennolla `setq`, jolle annetaan muuttujan nimi ja mitä tietoa tallennetaan - `(setq muuttuja tieto)`. 

&lt;div style="page-break-after: always;"&gt;&lt;/div&gt;

#### Getpoint, getstring, ...
Lispissä annetaan komennoille tietoa oikeassa tietotyypissä. Tämä onnistuu get-funktioilla.

* `getpoint` kysyy käyttäjältä pisteen. Palauttaa listan `'(x y z)`
* `getstring` kysyy tekstiä. Jos tekstiin haluaa välilyöntejä, kirjoitetaan teksti lainausmerkkeihin
* `getint` kysyy kokonaisluvun.
* `getreal` kysyy reaaliluvun.
* `getfiled` kysyy tiedoston. Palauttaa tiedostopolun merkkijonona.

`getpoint`, `getstring`, `getint` ja `getreal` toimivat joko sellaisenaan tai viestin kanssa. Viesti ilmestyy AutoCADin komentoriville.
```lisp
(getpoint)
(getpoint "Anna piste: ")
```
`getfiled` tarvitsee enemmän tietoja toimiakseen: otsikon, oletustiedostonimen, tiedostopäätteen/-päätteet, asetukset.
```lisp
(getfiled otsikko oletustiedostonimi tiedostopääte asetukset)
```
Asetuksissa on paljon vaihtoehtoja, jotka kannattaa katsoa AutoCADin dokumentaatiosta. Kaksi yleishyödyllisintä ovat 0 ja 1: 0 tarkoittaa olemassa olevan tiedoston hakua ja 1 uuden tiedoston luontia.
```lisp
(getfiled "Valitse tiedosto: " "vanha.txt" "*" 0)
(getfiled "Anna tiedostopolku: " "uusi.txt" "*" 1)
```