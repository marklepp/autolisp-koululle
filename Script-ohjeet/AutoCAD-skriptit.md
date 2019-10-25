# AutoCAD-skriptit
Toistuvia toimintoja on mahdollista automatisoida AutoCADissa. Yksinkertaisin tapa tähän on skriptit. Skripti on peräkkäin suoritettavia komentoja. AutoCADissa nämä ovat mitä vain komentoriville kirjoitettavia komentoja.

Skripti kirjoitetaan tiedostoon samalla tavalla kuin komennot kirjoitettaisiin AutoCADin komentoriville. Esimerkiksi LINE-komento kirjoitettaisiin skritpitiedostoon näin:

```
LINE
10,10
20,20


```
LINE-komento kysyy pisteitä yksi kerrallaan, ja komento pysäytetään yhdellä ylimääräisellä rivinvaihdolla. Skritpi tallennetaan sitten _.scr_-päätteiseen tiedostoon. 

Skripti vaihtaa komentoa myös välilyönnillä, joten kirjoittaessa kannattaa varoa ylimääräisiä välejä. Jos tarvitsee kirjoittaa tekstiä välilyönneillä, kirjoitetaan koko teksti lainausmerkkien sisään.