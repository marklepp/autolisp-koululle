$cssCommandClass = "pl-c1"
$commandsToBeFixed = @( "assoc"
  , "cadr"
  , "cddddr"
  , "command"
  , "close"
  , "entget"
  , "entmod"
  , "entnext"
  , "entupd"
  , "getfiled"
  , "getint"
  , "getpoint"
  , "getreal"
  , "getstring"
  , "nth"
  , "open"
  , "princ"
  , "read-line"
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
  , "write-line"
  , "1+"
  , "1-"
  , "+"
  , "-"
  , "/"
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
      $contentToBeFixed -replace "(<span class=`")$cssCommandClass(`">\d+`.?\d*</span>)",
        '$1pl-digits$2'
    $contentToBeFixed = 
      $contentToBeFixed -replace "(<style>)",
        '$1 .pl-digits{ color:forestgreen;} .pl-pds, .pl-s, .pl-s .pl-pse .pl-s1, .pl-sr, .pl-sr .pl-cce, .pl-sr .pl-sra, .pl-sr .pl-sre {color: firebrick;}'
    $contentToBeFixed = 
      $contentToBeFixed -replace "<p>&lt;(div style=`"page-break-after: always;`")&gt;&lt;(/div)&gt;</p>",
        '<$1><$2>'
    $contentToBeFixed = 
      $contentToBeFixed -replace "http://localhost:\d+/",
        ''
    $contentToBeFixed = 
      $contentToBeFixed -replace "(<title>)([^.]+)`.md - Grip(</title>)",
        '$1$2$3'
    $contentToBeFixed = 
      $contentToBeFixed -replace "<h3>\s*<span class=`"octicon octicon-book`">\s*</span>\s*[^.]+`.md\s*</h3>",
        ''
    $contentToBeFixed = 
      $contentToBeFixed -replace "/__/grip/[^/]*/",
        'grip/'
    Set-Content $_.FullName $contentToBeFixed
  }