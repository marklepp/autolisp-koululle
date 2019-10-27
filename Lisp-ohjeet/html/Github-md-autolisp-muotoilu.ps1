$cssCommandClass = "pl-c1"
$commandsToBeFixed = @( "assoc"
  , "cddddr"
  , "command"
  , "close"
  , "entget"
  , "entmod"
  , "entnext"
  , "entupd"
  , "getpoint"
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
  , "+"
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
      $contentToBeFixed -replace "http://localhost:\d+/",
        ''
    Set-Content $_.FullName $contentToBeFixed
  }