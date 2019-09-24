# AutoLISP-Perusteet

AutoLISP (myös Visual Lisp) on AutoDeskin kehittämä ohjelmointikieli AutoCADin toimintojen automatisoimiseen. Tämä tehostaa työtä poistamalla ihmiseltä aikaa vievää, tylsää ja toistuvaa työtä, jättäen aikaa tärkeämpään suunnitteluun.

AutoLISP on helposti lähestyttävä kieli, vaikka ulkonäkö on erikoinen: sulkuja, sulkuja ja sulkuja. Lisp on lyhenne sanoista List processing (listaprosessointi), mikä on kuvaavaa, sillä lispissä on vain yksi, monipuolinen tietorakenne: lista. Itse lisp-koodikin kirjoitetaan lispin ymmärtämässä listamuodossa.

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

## Visual Lisp-kehitysympäristö

Jotta pääsemme alkuun, on hyvä avata AutoCADiin Visual lisp-kehitysympäristö. Tämä onnistuu, kun menee "Manage"-välilehdellä osioon "Applications" ja klikkaa "Visual LISP-editor". Tästä avautuu ikkuna, jonka sisällä on ikkuna Visual LISP Console. Tähän kirjoittamalla voi kokeilla komentojen toimintaa. Vasemmasta yläkulmasta saa avattua uuden tiedoston, johon voi alkaa kirjoittaa lisp-koodia*. Kun etsii apua komennon löytämiseen, F1 avaa AutoCADin help-ikkunan, josta voi seikkailla AutoLISP-reference -osioon, jossa kerrotaan kaikkien AutoLISPin komentojen toiminnasta. Täältä on myös pienen harjoittelun jälkeen helppo löytää sopiva komento ohjelmoinnin avuksi.

*) Kehitysympäristö on melko ikääntynyt, joten vakavassa käytössä suosittelen käyttämään sitä vain testaukseen. Koodin muokkaukseen suosittelen tekstieditoreja kuten Visual Studio Code tai Notepad++. Visual Studio Codeen saa ladattua lisäosan, joka värittää AutoLisp-syntaksin oikein. Opintojakson tarpeisiin kehitysympäristö on kuitenkin riittävä.

## Tietotyypit ja lista

Tietotyyppi on tiedon tallennusmuoto, mikä määrittelee, miten ohjelma käsittelee tietoa. AutoLISPissä tietotyyppejä ovat:
 * kokonaisluku (englanniksi integer)
 * reaaliluku (real)
 * merkkijono / teksti (string)
 * symbolit ja muuttujat (symbol, variable)
 * tiedosto-osoitin (file descriptor)
 * lista (list)
 * valintajoukko (selection set)
 * kokonaisuustunniste / osanimi (entity name)
 * VLA-objekti (VLA-object)

Näiden lisäksi on nil, joka tarkoittaa tiedon puutetta*. Muilla kielillä tämä on usein null.

*) Tarkkaan ottaen nil tarkoittaa tyhjää listaa `'()`, mutta käytännössä tämä ei näy. 

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

### Merkkijono
Lisp ymmärtää koodin merkkijonoksi, jos sen ympäröi lainausmerkeillä. Esimerkissä alla on ensin kirjoitettu konsoliin merkkijono "tekstiä", jonka lisp ymmärtää merkkijonoksi ja palauttaa sen. Ilman lainausmerkkejä lisp ymmärtää kirjoitetun asian symboliksi, ja yrittää lukea symbolin arvoa, mutta koska sillä ei ole arvoa, lisp palauttaa nil. 

Visual Lisp Console:
```lisp
_$ "tekstiä"
"tekstiä"
_$ tekstiä
nil
```

## Tekstin kirjoittaminen AutoCADin command promptiin tai tiedostoon

Koodin sisältä voidaan käyttäjälle näyttää viestejä AutoCADin command promptissa eli komentorivillä. Tämä tapahtuu käyttämällä jotain komennoista _princ_, _prin1_ tai _print_. Kaikki näistä toimivat periaatteella (_komento_ _asia_). Tätä voit kokeilla command promptissa:
```lisp
(princ "moi")
(prin1 "moi")
(print "moi")
```

Samat komennot kirjoittavat dataa tiedostoon: `(komento asia avoin-tiedosto)`. Princ riisuu asiasta kaiken tietotyyppiin liittyvän tiedon, kun taas prin1 ja print säilyttävät lispin ymmärtämät muotoilut, jolloin tiedostosta voisi lukea suoraan dataa ohjelmaan. Pelkän tekstin kirjoittamiseen komento _write-line_ on parempi. `(write-line merkkijono avoin-tiedosto)` kirjoittaa merkkijonon tiedostoon ja vaihtaa seuraavalle riville. Tiedoston avaamisesta kerrotaan myöhemmin.