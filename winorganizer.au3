#include <Array.au3>
#include <String.au3>

ConsoleWrite("Start" & @CRLF)


Local $titles = IniReadSection("winorganizer.ini", "Windows")

Global $bottomMargin = 35
Global $totalHeight = @DesktopHeight-$bottomMargin
Global $heightMargin = 50
Global $widthOverlap = 50
Global $winHandles[1]

While 1
	; Get a list of all windows
	Local $winList = WinList()
	ReDim $winHandles[1]
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

	;For $j = 1 To $count
	;    ConsoleWrite("Handle " & WinGetTitle($winHandles[$j]) & " → Title: " & $title & @CRLF)
	;Next

	If $count = 0 Then
		ConsoleWrite("No windows detected")
		MsgBox(0, "WinOrganizer Exiting", "No Layout windows found")
		ExitLoop
	EndIf

	Global $widthStep = @DesktopWidth / $count
	Global $rows = 2

	If $count < 3 Then
		For $j = 1 To $count
			WinMove($winHandles[$j], "", ( $j-1) * $widthStep,0,$widthStep,$totalHeight)
		Next
	Else
		Local $windowsPerRow = Int($count / $rows)
		If Mod($count, 2) = 1 Then
			$windowsPerRow += 1
		EndIf
		$widthStep = @DesktopWidth / $windowsPerRow
		Local $heightStep = $totalHeight / $rows
		Local $winHeight = $totalHeight / $rows

		For $j = 1 To $count
			Local $currentRow = Int( $j / $windowsPerRow - 0.1)
			Local $xPosAdjustment = $widthOverlap / $windowsPerRow
			;ConsoleWrite("Row: " & $j  & ", " & $windowsPerRow & @CRLF)
			Local $rowIndex = $j -1
			if $j >= $windowsPerRow Then
				$rowIndex = $j - $currentRow*$windowsPerRow -1
			EndIf
			Local $posx = ( $j-1 - ($currentRow * ($windowsPerRow))) * $widthStep - ($rowIndex * $xPosAdjustment)
			;ConsoleWrite("PosX: " & $posx  & ", " & $currentRow & ", " & $windowsPerRow & @CRLF)
			Local $posy =  $currentRow * $heightStep - ($currentRow * $heightMargin)
			Local $height = $winHeight + $heightMargin
			Local $width = $widthStep + $widthOverlap
			WinMove($winHandles[$j], "",$posx , $posy,$width,$height)
			ConsoleWrite("Move To: " & $posx  & ", " & $posy & " row: " & $currentRow & @CRLF)
		Next
	EndIf

	Sleep(1000)
WEnd
