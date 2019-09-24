# AutoLISP-Perusteet

AutoLISP on AutoDeskin kehittämä ohjelmointikieli AutoCADin toimintojen automatisoimiseen. AutoLISP on helposti lähestyttävä kieli, vaikka ulkonäkö on erikoinen: sulkuja, sulkuja ja sulkuja. Lisp on lyhenne sanoista List processing (listaprosessointi), mikä on kuvaavaa, sillä lispissä on vain yksi, monipuolinen tietorakenne: lista. Itse lisp-koodikin kirjoitetaan lispin ymmärtämässä listamuodossa.

AutoLISPin koodaus noudattaa yhtä kaavaa: (komento parametri1 parametri2 ...). Sulkujen sisällä on ensin komento, ja sen jälkeen komennolle annetut parametrit, joilla komento suoritetaan. 
Esimerkkinä tähän on pluslasku 1 + 1:
```(+ 1 1)```
joka palauttaa 2. Mikäli halutaan plussata useampi luku, kirjoitetaan ne kaikki komennon "+" jälkeen sulkujen sisään: 1 + 2 + 3 on lispissä
```(+ 1 2 3)```
ja se palauttaa 6.
Jos haluamme yhdistää komentoja, jokaiselle komennolle on tehtävä omat sulut. Tämä voi aluksi hämätä laskutoimituksissa, mutta on ainakin helppo muistaa. Esimerkkinä lasku 10 / (1 + 1) :
```(/ 10 (+ 1 1))```
joka palauttaa 5.
