# AutoCAD-skriptit
Toistuvia toimintoja on mahdollista automatisoida AutoCADissa. Yksinkertaisin tapa tähän on skriptit. Skripti on lista peräkkäin suoritettavia komentoja. AutoCADissa nämä ovat mitä vain komentoriville kirjoitettavia komentoja.

Skripti kirjoitetaan tiedostoon samalla tavalla kuin komennot kirjoitettaisiin AutoCADin komentoriville. Esimerkiksi LINE-komento pisteestä (10, 10) pisteeseen (20, 20) kirjoitettaisiin skritpitiedostoon näin:

```
LINE
10,10
20,20


```
LINE-komento kysyy pisteitä yksi kerrallaan, ja komento pysäytetään yhdellä ylimääräisellä rivinvaihdolla. Skritpi tallennetaan sitten _.scr_-päätteiseen tiedostoon. 

Skripti vaihtaa komentoa myös välilyönnillä, joten kirjoittaessa kannattaa varoa ylimääräisiä välejä. Jos tarvitsee kirjoittaa tekstiä välilyönneillä, kirjoitetaan koko teksti lainausmerkkien sisään. Tämä on usein tarpeen tiedostonimissä, jos tiedostopolussa on välejä. Tiedostoja voi avata ja sulkea skriptissä. Tämä mahdollistaa samojen toimintojen suorittamisen usealle piirustukselle peräjälkeen. Skriptiin kirjoitetaan samat komennot joka tiedostolle:
```
open
"C:\testikansio\piirustus 1.dwg"
line
10,10
20,20

qsave
close
open
"C:\testikansio\piirustus 2.dwg"
line
10,10
20,20

qsave
close

```

## Kommentit
Skriptiin voi myös kirjoittaa kommentteja. Kommentti alkaa rivin alussa puolipisteellä ";". Tämä rivi jätetään huomiotta skriptissä. Näin voi kertoa, mitä skriptissä tapahtuu.
```
LINE
;eka piste
10,10
;toka piste
20,20
;sitten enter


```

## Lisp skriptissä
Mikäli käytössä on AutoCADin täysi versio, voi skriptiin kirjoittaa myös lisp-komentoja. Tämä tapahtuu kuten lispin kirjoitus yleensä, mutta ylimääräiset välilyönnit on huomioitava lisp-komentojen ulkopuolella. Sulkujen sisällä välejä saa olla vapaasti. Lisp-komennot ovat hyödyllisiä esimerkiksi, jos halutaan käyttää kuvasta riippuvaa tietoa jossain komennossa. Lisp-muuttujia voi käyttää skript-rivillä laittamalla niiden eteen huutomerkin "!". Mikäli halutaan viitata lisp-muuttujaan tekstivastauksen aikana, pitää asettaa AutoCADissa asetus TEXTEVAL 1. Tämän voi asettaa takaisin nollaan skriptin lopussa.
```
TEXTEVAl 1
(setq tiedostonimi (getvar "dwgname"))
TEXT
30,30
5
0
!tiedostonimi
TEXTEVAL 0

```