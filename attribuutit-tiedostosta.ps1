if (Test-Path skripti.scr -Leaf) {remove-item skripti.scr}
Get-ChildItem *.dwg | 
    foreach-object {
        (get-content (get-item attribuutit-tiedostosta.scr) -raw).
        replace("TIEDOSTONIMI", ('"' + $_.fullname + '"')) | 
            Add-content skripti.scr
    }