# AutoLISP-Perusteet

AutoLISP (myös Visual Lisp) on AutoDeskin kehittämä ohjelmointikieli AutoCADin toimintojen automatisoimiseen. Tämä tehostaa työtä poistamalla ihmiseltä aikaa vievää, tylsää ja toistuvaa työtä, jättäen aikaa tärkeämpään suunnitteluun.

AutoLISP on helposti lähestyttävä kieli, vaikka ulkonäkö on erikoinen: sulkuja, sulkuja ja sulkuja. Lisp on lyhenne sanoista List processing (listaprosessointi), mikä on kuvaavaa, sillä lispissä on vain yksi, monipuolinen tietorakenne: lista. Itse lisp-koodikin kirjoitetaan lispin ymmärtämässä listamuodossa.

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

---
## Lispin syntaksi eli lausemuoto

AutoLISPin lauseet noudattavat yhtä kaavaa: `(komento parametri1 parametri2 ...)`. Sulkujen sisällä on ensin komento, ja sen jälkeen komennolle annetut parametrit, joilla komento suoritetaan. 
Esimerkkinä tähän on pluslasku 1 + 1: `(+ 1 1)`
```lisp
_$ (+ 1 1)
2
```
Mikäli halutaan plussata useampi luku, kirjoitetaan ne kaikki komennon "+" jälkeen sulkujen sisään: 1 + 2 + 3 on lispissä
```lisp
_$ (+ 1 2 3)
6
```
ja se palauttaa 6.
Jos haluamme yhdistää komentoja, jokaiselle komennolle on tehtävä omat sulut. Tämä voi aluksi hämätä laskutoimituksissa, mutta on ainakin helppo muistaa. Esimerkkinä lasku 10 / (1 + 1) :
```lisp
_$ (/ 10 (+ 1 1))
5
```
joka palauttaa luvun 5. 

---