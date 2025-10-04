#include <Array.au3>
#include <String.au3>

ConsoleWrite("Start" & @CRLF)


Local $titles = IniReadSection("winorganizer.ini", "Windows")

Global $bottomMargin = 35
Global $totalHeight = @DesktopHeight-$bottomMargin
Global $heightMargin = 50
Global $widthOverlap = 50
Const $positionsSize = 10

Global $winPositions[$positionsSize+1]
For $i = 1 To $positionsSize
	$winPositions[$i] = 0
Next

While 1
	; Get a list of all windows
	Local $winList = WinList()
	Local $winHandles[0]
	Local $count = 0

	; Loop through the list
	For $i = 1 To $winList[0][0]
		For $t = 1 To $titles[0][0]
			If StringInStr($winList[$i][0], $titles[$t][1]) > 0 Then
				$count += 1
				ReDim $winHandles[$count + 1] ; Resize array to hold new handle
				$winHandles[$count] = WinGetHandle($winList[$i][1], "")
			EndIf
		Next
	Next
	ConsoleWrite ("Found matches: " & $count & @CRLF)

	; Remove closed windows
	For $i = 1 To $positionsSize
		If _ArraySearch ( $winHandles, $winPositions[$i] ) = -1 Then
			$winPositions[$i] = 0
			ConsoleWrite("Window Closed" & @CRLF)
		EndIf
	Next


	; Add new windows to empty spaces in array
	For $i = 1 To $count
		Local $posIndex = _ArraySearch ( $winPositions, $winHandles[$i],1  )
		If  $posIndex = -1 Then
			$posIndex = _ArraySearch ( $winPositions, 0, 1 )
			if $posIndex = -1 Then
				ConsoleWrite("Empty space not found for new window"& @CRLF)
				ContinueLoop
			EndIf
			ConsoleWrite ("Adding window , " & $posIndex & @CRLF)
			$winPositions[$posIndex] = $winHandles[$i]
		EndIf
	Next

	; Get Last used position
	Local $maxPosition = -1
	For $i = 1 To $positionsSize
		If $winPositions[$i] <> 0 Then
			$maxPosition = $i
		EndIf
	Next

	ConsoleWrite ("Max position: " & $maxPosition & @CRLF)

	ConsoleWrite ("Titles:")
	For $i = 1 To $count
		ConsoleWrite (" " & WinGetTitle($winPositions[$i]))
	Next
	ConsoleWrite (@CRLF)


	;For $j = 1 To $count
	;    ConsoleWrite("Handle " & WinGetTitle($winHandles[$j]) & " → Title: " & $title & @CRLF)
	;Next

	If $count = 0 Then
		ConsoleWrite("No windows detected")
		MsgBox(0, "WinOrganizer Exiting", "No Layout windows found")
		ExitLoop
	EndIf

	Local $gridcount = $maxPosition
	If  $gridcount < 4 Then
		$gridcount = 4
	EndIf

	Global $widthStep = @DesktopWidth / $gridcount
	Global $rows = 2

	;_ArraySort($winHandles)

	Local $windowsPerRow = Int($gridcount / $rows)
	If Mod($gridcount, 2) = 1 Then
		$windowsPerRow += 1
	EndIf
	$widthStep = @DesktopWidth / $windowsPerRow
	Local $heightStep = $totalHeight / $rows
	Local $winHeight = $totalHeight / $rows



	For $j = 0 To $gridcount
		Local $currentRow = Int( $j / $windowsPerRow - 0.1)

		;ConsoleWrite("Row: " & $j  & ", " & $windowsPerRow & @CRLF)
		Local $rowIndex = $j -1
		if $j >= $windowsPerRow Then
			$rowIndex = $j - $currentRow*$windowsPerRow -1
		EndIf

		Local $posy =  $currentRow * $heightStep - ($currentRow * $heightMargin)
		Local $height = $winHeight + $heightMargin
		Local $width = $widthStep + $widthOverlap / ($count +1)
		Local $xPosAdjustment = $width / $windowsPerRow
		Local $posx = $rowIndex * $widthStep

		ConsoleWrite("Pos: " & $rowIndex  & ", " & $currentRow & ", " & $windowsPerRow & @CRLF)

		if $winPositions[$j] <> 0 Then
			WinMove($winPositions[$j], "",$posx , $posy,$width,$height)
			ConsoleWrite("Move To: " & $posx  & ", " & $posy & " row: " & $currentRow & @CRLF)
		EndIf
	Next
	;ExitLoop
	Sleep(1000)
WEnd
