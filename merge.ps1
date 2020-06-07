pushd "C:\Users\a\Desktop\work\SourceHanSerifJP"
$ttxCmd = "C:\Users\a\AppData\Local\Programs\Python\Python37\Scripts\ttx.exe"

foreach ($otf in (ls "00_otf/*.otf")) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($otf)
    $ttx = "02_ttx2/${name}.ttx"

    $xml = [xml](cat $ttx -Encoding UTF8)
    $newName = $xml.SelectNodes("/ttFont/name/namerecord[@nameID='1'][@langID='0x409']")[0].InnerText.Trim()
    $newName = $newName.Replace(" ", "")

    $otf2 = "03_otf2/${newName}.otf"
    & $ttxCmd -m $otf.FullName -o $otf2 $ttx
    echo $name
}
