Get-ChildItem .\..\*.md | 
  ForEach-Object {
    grip $_.FullName --export --no-inline ((Get-Location).ToString() + "`\" + $_.BaseName + ".html")
  }
$cssCommandClass = "pl-c1"
$commandsToBeFixed = @( "assoc"
  , "cadr"
  , "cddddr"
  , "close"
  , "command"
  , "cond"
  , "entget"
  , "entmod"
  , "entnext"
  , "entupd"
  , "equal"
  , "foreach"
  , "getdist"
  , "getfiled"
  , "getint"
  , "getpoint"
  , "getreal"
  , "getstring"
  , "if"
  , "nth"
  , "open"
  , "princ"
  , "progn"
  , "read-line"
  , "repeat"
  , "reverse"
  , "ssget"
  , "sslength"
  , "ssname"
  , "strcat"
  , "subst"
  , "vlax-dump-object"
  , 'vlax-ename-&gt;vla-object'
  , "vlax-get-property"
  , "vlax-put-property"
  , "vl-load-com"
  , "while"
  , "write-line"
  , "1+"
  , "1-"
  , "+"
  , "-"
  , "*"
  , "/"
  , "&lt;"
  , "&lt;="
  , "&gt;"
  , "&gt;="
  , "="
  , "/="
)
Get-ChildItem *.html | 
  ForEach-Object {
    $contentToBeFixed = (Get-Content (Get-Item $_) -Raw)
    ForEach ($commandname in $commandsToBeFixed){
      $contentToBeFixed = 
        $contentToBeFixed -replace [regex]::Escape("`($commandname"), 
          "(<span class=`"$cssCommandClass`">$commandname</span>"
    }
    $contentToBeFixed = 
      $contentToBeFixed `
        -replace "(<span class=`")$cssCommandClass(`">\d+`.?\d*</span>)",
                  '$1pl-digits$2' `
        -replace "(<style>)",
                  '$1 .pl-k{color: #005cc5;} .pl-digits{ color:forestgreen;} .pl-pds, .pl-s, .pl-s .pl-pse .pl-s1, .pl-sr, .pl-sr .pl-cce, .pl-sr .pl-sra, .pl-sr .pl-sre {color: firebrick;}' `
        -replace "<p>&lt;(div style=`"page-break-after: always;`")&gt;&lt;(/div)&gt;</p>",
                  '<$1><$2>' `
        -replace "http://localhost:\d+/",
                  '' `
        -replace "(<title>)([^.]+)`.md - Grip(</title>)",
                  '$1$2$3' `
        -replace "<h3>\s*<span class=`"octicon octicon-book`">\s*</span>\s*[^.]+`.md\s*</h3>",
                  '' `
        -replace "/__/grip/[^/]*/",
                  'grip/'
    Set-Content $_.FullName $contentToBeFixed
  }