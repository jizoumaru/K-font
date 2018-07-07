Param($dir)

$fontforge = "C:\Program Files (x86)\FontForgeBuilds\fontforge.bat"
$ttx = "C:\Users\a\Desktop\FDK.2.5.65781-WIN\FDK\Tools\win\ttx.cmd"

foreach ($otf in $(ls ${dir}/*.otf))
{
    $otfPath = $(Resolve-Path ${otf})
    $ttfPath = "${otfPath}.ttf"

    & $fontforge -script .\convert.py "$otfPath" "$ttfPath"

    $otfTtx = "${otfPath}.ttx"
    $ttfTtx = "${ttfPath}.ttx"

    & "${ttx}" -t cmap -o "${otfTtx}" "${otfPath}"
    & "${ttx}" -t cmap -o "${ttfTtx}" "${ttfPath}"

    $correctedTtx = "$((Get-ChildItem ${otfPath}).DirectoryName)\$((Get-ChildItem ${otfPath}).BaseName).ttx"

    & "cscript" "correctCmap.vbs" "${ttfTtx}" "${otfTtx}" "${correctedTtx}"

    & "${ttx}" -m "${ttfPath}" "${correctedTtx}"
}
