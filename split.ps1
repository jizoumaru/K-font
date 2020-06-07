pushd "C:\Users\a\Desktop\work\SourceHanSerifJP"
$ttxCmd = "C:\Users\a\AppData\Local\Programs\Python\Python37\Scripts\ttx.exe"

foreach ($font in (ls "00_otf/*.otf")) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($font)
    $ttx = "01_ttx/${name}.ttx"
    & $ttxCmd -t "head" -t "hhea" -t "OS/2" -t "name" -o $ttx $font
    echo $name
}
