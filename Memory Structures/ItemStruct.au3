;----------------------------;
;                            ;
;        WRITTEN BY          ;
;        KENDAL WEN          ;
;                            ;
;  DETERMINE MODSTRUCTS OF   ;
;           ITEMS            ;
;                            ;
;----------------------------;

;#include-once
#include "GWA2.au3"
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GuiEdit.au3>

Opt("MustDeclareVars", False)
Opt("GUIOnEventMode",1)

#Region *CONSTANTS*
Global $boolRun  = False
Global Const $BAG_SLOT[4] = [20, 5, 10, 10]
Global Const $lastBag = 3
#EndRegion

#Region *GUI*
Global $Cl = GUICreate("ModStruct", 500, 254, 244, 193)
Global $GUIStart = GUICtrlCreateButton("START", 8, 40, 129, 25)
Global $txtName = GUICtrlCreateCombo("", 8, 8, 129, 25)
	GUICtrlSetData(-1, GetLoggedCharNames())
	GUICtrlCreateGroup("", 152, 2, 145, 207)
	GUICtrlCreateLabel("RUNS: ", 176, 18, 51, 17, $SS_CENTERIMAGE)
	GUICtrlCreateLabel("FAILS: ", 176, 50, 51, 17, $SS_CENTERIMAGE)
	GUICtrlCreateLabel("GOLDS: ", 176, 82, 51, 17, $SS_CENTERIMAGE)
	GUICtrlCreateLabel("SHELLS: ", 176, 114, 51, 17, $SS_CENTERIMAGE)
	GUICtrlCreateLabel("BONES: ", 176, 146, 51, 17, $SS_CENTERIMAGE)
	GUICtrlCreateLabel("EYES: ", 176, 178, 51, 17, $SS_CENTERIMAGE)
Global $GUIruns = GUICtrlCreateLabel("-", 224, 18, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIfails = GUICtrlCreateLabel("-", 224, 50, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIgolds = GUICtrlCreateLabel("-", 224, 82, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIshells = GUICtrlCreateLabel("-", 224, 114, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIbones = GUICtrlCreateLabel("-", 224, 146, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIeyes = GUICtrlCreateLabel("-", 224, 178, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIRendering = GUICtrlCreateCheckbox("Disable Rendering", 16, 72, 105, 17)
	GUICtrlCreateGroup("", 8, 88, 129, 121)
Global $GUIpShells = GUICtrlCreateCheckbox("Pick-Up Shells", 24, 104, 97, 17)
Global $GUIsShells = GUICtrlCreateCheckbox("Salvage Shells", 24, 133, 97, 17)
Global $GUIUpd = GUICtrlCreateLabel("", 112, 215, 350, 17, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUITime = GUICtrlCreateLabel("00:00:00", 24, 215, 68, 17,BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "Close")
GUICtrlSetOnEvent($GUIStart, "Init")
GUICtrlSetOnEvent($GUIRendering, "ToggleRendering")
GUICtrlSetOnEvent($GUIpShells, "TogglePickUp")
GUICtrlSetOnEvent($GUIsShells, "ToggleSalvage")

GUICtrlSetState($GUIRendering,$GUI_DISABLE)
GUICtrlSetState($GUIsShells,$GUI_DISABLE)

GUISetState(@SW_SHOW)
#EndRegion

#Region *MAIN*

While Not $boolRun
   Sleep(100)
WEnd

While $boolRun
   Local $char = GetAgentByID()
   Local $weapon = DllStructGetData($char, "WeaponType")
   Out1("weapon: ")
   Sleep(100)
   If $weapon = 1 Then
	  Out1("TRUE")
   Else
	  Out1("FALSE")
   EndIf
   Sleep(500)
WEnd

While Not $boolRun
   Sleep(100)
WEnd

#EndRegion

#Region *FUNCTIONS*

Func LogItems()
   Local $i, $j, $item
   For $i = 1 To 4
	  For $j = 1 To $BAG_SLOT[$i-1]
		 Local $item = GetItemBySlot($i, $j)
		 Out1($item)
		 Sleep(100)
		 Local $value = DllStructGetData($item, "value")
		 Out1($j)
		 Sleep(100)
		 Out1($value)
		 Sleep(1000)
		 FileWriteLine("Log.txt", $value & @CRLF)
		 FileWriteLine("Log.txt", "")
	  Next
   Next
EndFunc
#EndRegion

#region *UTILITY*

Func Init()
	$boolRun = Not $boolRun
	If $boolRun Then
		GUICtrlSetData($GUIStart, "Initializing")
		GUICtrlSetState($GUIStart, $GUI_DISABLE)
		GUICtrlSetState($txtName, $GUI_DISABLE)
		If GUICtrlRead($txtName) = "" Then
			If Initialize(ProcessExists("gw.exe"), True, True) = False Then
				MsgBox(0, "Error", "Guild Wars it not running.")
				Exit
			EndIf
		Else
			If Initialize(GUICtrlRead($txtName), True, True) = False Then
				MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
				Exit
			EndIf
		EndIf
		GUICtrlSetState($GUIStart, $GUI_ENABLE)
		GUICtrlSetData($GUIStart, "Pause")
		GUICtrlSetState($GUIRendering,$GUI_ENABLE)
	Else
		GUICtrlSetData($GUIStart, "BOT WILL HALT AFTER THIS RUN")
		GUICtrlSetState($GUIStart, $GUI_DISABLE)
	EndIf
EndFunc

Func GetPos(ByRef $agent,$coord) ; $coord = "X" or "Y"
	Return DllStructGetData($agent,$coord)
EndFunc

Func Close()
	Exit
EndFunc

Func RandomSleep($min,$max)
	Sleep(Random($min,$max,1))
EndFunc

Func Out1($text)
	If GUICtrlRead($GUIUpd) <> $text Then GUICtrlSetData($GUIUpd,$text)
EndFunc

Func UpdTimer()
	Local $time,$hours,$minutes,$secunds,$temp
	$time = Int(TimerDiff($timer)/1000)
	$hours = Int($time/3600)
	$minutes = Int(($time-($hours*3600))/60)
	$secunds = Mod(($time-($hours*3600)),60)
	If $minutes < 10 Then $minutes = "0" & $minutes
	If $secunds < 10 Then $secunds = "0" & $secunds
	If $hours < 10 Then $hours = "0" & $hours
	$temp = "" & $hours & ":" & $minutes & ":" & $secunds
	GUICtrlSetData($GUITime,$temp)
EndFunc

Func pingSleep($time = 0)
	Sleep(GetPing() + $time)
EndFunc

Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
 EndFunc

#endregion
