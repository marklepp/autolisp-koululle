if (Test-Path skripti.scr) {remove-item skripti.scr}
Get-ChildItem *.dwg | 
    foreach-object {
        (get-content (get-item zoom-extents.scr) -raw).
        replace("TIEDOSTONIMI", ('"' + $_.fullname + '"')) | 
            Add-content skripti.scr
    }