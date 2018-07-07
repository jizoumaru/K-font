Option Explicit

Call Main()

Sub Main()
	Dim ttfTtx
	ttfTtx = WScript.Arguments(0)
	
	Dim otfTtx
	otfTtx = WScript.Arguments(1)
	
	Dim destTtx
	destTtx = WScript.Arguments(2)
	
	Call WriteLine(ttfTtx)
	Call WriteLine(otfTtx)
	Call WriteLine(destTtx)
	Call CreateTtx(ttfTtx, otfTtx, destTtx)
End Sub

Sub CreateTtx(ttfTtx, otfTtx, destTtx)
	
	Dim ttfFormatMap
	Set ttfFormatMap = CreateCodeMap(ttfTtx)
	
	Dim otfFormatMap
	Set otfFormatMap = CreateCodeMap(otfTtx)
	
	Dim nameFormatMap
	Set nameFormatMap = CreateNameMap(ttfFormatMap, otfFormatMap)
	
	Dim dom
	Set dom = WScript.CreateObject("MSXML2.DOMDocument")

	Call dom.load(ttfTtx)
	
	Dim cmap
	Set cmap = dom.documentElement.selectSingleNode("/ttFont/cmap")
	
	Dim format
	For Each format In cmap.selectNodes("*[@platformID]")
		
		Dim map
		For Each map In format.selectNodes("*[@code]")
			
			Call format.removeChild(map)
		
		Next

		Dim platformID
		platformID = format.getAttribute("platformID")
		
		Dim formatName
		formatName = format.tagName & "_" & platformID

		Dim otfCodeMap
		Set otfCodeMap = otfFormatMap(formatName)
		
		Dim nameMap
		Set nameMap = nameFormatMap(formatName)
		
		Dim otfCode
		For Each otfCode In otfCodeMap.Keys
		
			Dim otfName
			otfName = otfCodeMap(otfCode)
			
			If nameMap.Exists(otfName) Then
			
				Dim ttfName
				ttfName = nameMap(otfName)
				
				Dim newMap
				Set newMap = dom.createNode(1, "map", "")
				
				Call newMap.setAttribute("code", otfCode)
				Call newMap.setAttribute("name", ttfName)
				
				Call format.appendChild(newMap)
				Call format.appendChild(dom.createTextNode(vbCrLf))
				
			End If
						
		Next
	Next

	Call dom.save(destTtx)

End Sub

Function CreateNameMap(ttfFormatMap, otfFormatMap)
	Dim formatMap
	Set formatMap = CreateObject("Scripting.Dictionary")
	
	Dim format
	For Each format In otfFormatMap.Keys
		
		Dim otfCodeMap
		Set otfCodeMap = otfFormatMap(format)

		Dim ttfCodeMap
		Set ttfCodeMap = ttfFormatMap(format)
		
		Dim nameMap
		Set nameMap = CreateObject("Scripting.Dictionary")
		
		Dim otfCode
		For Each otfCode In otfCodeMap.Keys
			
			If ttfCodeMap.Exists(otfCode) Then

				Dim otfName
				otfName = otfCodeMap(otfCode)

				Dim ttfName
				ttfName = ttfCodeMap(otfCode)
				
				nameMap(otfName) = ttfName

			End If
			
		Next
		
		Set formatMap(format) = nameMap
		
	Next
	
	Set CreateNameMap = formatMap
End Function

Function CreateCodeMap(ttx)
	Dim dom
	Set dom = CreateObject("MSXML2.DOMDocument")

	Call dom.load(ttx)
	
	Dim cmap
	Set cmap = dom.documentElement.selectSingleNode("/ttFont/cmap")
	
	Call WriteLine(Join(Array("tagName", "platformID", "platEncID", "language"), ","))

	Dim formatMap
	Set formatMap = CreateObject("Scripting.Dictionary")
	
	Dim format
	For Each format In cmap.selectNodes("*[@platformID]")
		
		Dim codeMap
		Set codeMap = CreateObject("Scripting.Dictionary")
		
		Dim map
		For Each map In format.selectNodes("*[@code]")
		
			Dim code
			code = map.getAttribute("code")
			
			Dim name
			name = map.getAttribute("name")
			
			codeMap(code) = name
		
		Next

		Dim platformID
		platformID = format.getAttribute("platformID")
		
		Dim platEncID
		platEncID = format.getAttribute("platEncID")
		
		Dim language
		language = format.getAttribute("language")
	
		If IsNull(language) Then
			language = ""
		End If

		Set formatMap(format.tagName & "_" & platformID) = codeMap
		
		Call WriteLine(Join(Array(format.tagName, platformID, platEncID, language), ","))
	
	Next
	
	Set CreateCodeMap = formatMap
End Function

Sub WriteLine(inValue)
	Call WScript.StdOut.WriteLine(inValue)
End Sub