pushd "C:\Users\a\Desktop\work\SourceHanSerifJP"
$work = Convert-Path "."

foreach ($ttx in (ls "01_ttx/*.ttx")) {
    echo $ttx.FullName
    $xml = [xml](cat $ttx.FullName -Encoding "UTF8")
    $asc = [int]::Parse($xml.ttFont.OS_2.sTypoAscender.value)
    $desc = [int]::Parse($xml.ttFont.OS_2.sTypoDescender.value)
    $xml.ttFont.OS_2.usWinAscent.value = $asc.ToString()
    $xml.ttFont.OS_2.usWinDescent.value = (-$desc).ToString()
    $xml.ttFont.hhea.ascent.value = $asc.ToString()
    $xml.ttFont.hhea.descent.value = $desc.ToString()
    $xml.ttFont.head.yMax.value = $asc.ToString()
    $xml.ttFont.head.yMin.value = $desc.ToString()

    $origSubfamily = $xml.SelectNodes("/ttFont/name/namerecord[@nameID='6'][@langID='0x409']")[0].InnerText.Trim()
    $origSubfamily = $origSubfamily.Substring($origSubfamily.LastIndexOf("-") + 1)

    $family = "K Serif ${origSubfamily}"
    $subfamily = "Regular"

    echo $origSubfamily

    # English Family name
    # ex. Source Han Sans JP
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='1'][@langID='0x409']")[0].InnerText = $family

    # English Subfamily name
    # ex. Regular
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='2'][@langID='0x409']")[0].InnerText = $subfamily

    # English Unique font identifier
    # ex. 2.001;ADBO;SourceHanSansJP-Regular;ADOBE
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='3'][@langID='0x409']")[0].InnerText = $family.Replace(" ", "") + "-" + $subfamily

    # English Full font name
    # ex. Source Han Sans JP
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='4'][@langID='0x409']")[0].InnerText = $family

    # English Version
    # ex. Version 2.001;hotconv 1.0.107;makeotfexe 2.5.65593
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='5'][@langID='0x409']")[0].InnerText = "Version 1.0"

    # English PostScript name
    # ex. SourceHanSansJP-Regular
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='6'][@langID='0x409']")[0].InnerText = $family.Replace(" ", "") + "-" + $subfamily

    remove $xml.SelectNodes("/ttFont/name/namerecord[@nameID='16'][@langID='0x409']")
    remove $xml.SelectNodes("/ttFont/name/namerecord[@nameID='17'][@langID='0x409']")

    # Japanese Family name
    # ex. åπÉmäpÉSÉVÉbÉN JP
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='1'][@langID='0x411']")[0].InnerText = $family

    # Japanese Subfamily name
    # ex. Regular
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='2'][@langID='0x411']")[0].InnerText = $subfamily

    # Japanese Full font name
    # ex. åπÉmäpÉSÉVÉbÉN JP
    $xml.SelectNodes("/ttFont/name/namerecord[@nameID='4'][@langID='0x411']")[0].InnerText = $family

    remove $xml.SelectNodes("/ttFont/name/namerecord[@nameID='16'][@langID='0x411']")
    remove $xml.SelectNodes("/ttFont/name/namerecord[@nameID='17'][@langID='0x411']")

    $writer = [System.Xml.XmlTextWriter]::new("${work}/02_ttx2/" + $ttx.Name, [System.Text.Encoding]::UTF8)
    $writer.Formatting = [System.Xml.Formatting]::Indented
    $xml.Save($writer)
    $writer.Close()
}

function remove ([System.Xml.XmlElement[]]$nodes) {
    if ($nodes.Length -eq 0) {
        return
    } else {
        [void]$nodes[0].ParentNode.RemoveChild($nodes[0])
    }
}

