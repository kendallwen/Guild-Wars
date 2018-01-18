;----------------------------;
;                            ;
;        WRITTEN BY          ;
;        KENDAL WEN          ;
;                            ;
;  INTERUPTS HEALING TOUCH   ;
;    CASTED BY GUARDIAN      ;
; SERPENTS AND TWISTED BARKS ;
;    IN URGOZ'S WARREN       ;
;                            ;
;----------------------------;


;include-once
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
Global Const $urgoz = 266
Global Const $wurm = 3753
Global Const $bark = 3745
Global Const $dshot = 5
Global Const $touch = 313
Global Const $me = -2
#EndRegion

#Region *VARIABLES*
Global $boolRUn = False
#EndRegion

#Region *GUI*
Global $Cl = GUICreate("Urgoz Wurm Rupter", 300, 150)
Global $GUIStart = GUICtrlCreateButton("START", 8, 40, 129, 25)
Global $txtName = GUICtrlCreateCombo("", 8, 8, 129, 25)
	GUICtrlSetData(-1, GetLoggedCharNames())
	GUICtrlCreateGroup("", 152, 2, 145, 110)
	GUICtrlCreateLabel("RUPTS: ", 176, 18, 51, 17, $SS_CENTERIMAGE)
Global $GUIrupts = GUICtrlCreateLabel("-", 224, 18, 50, 20, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUIRendering = GUICtrlCreateCheckbox("Disable Rendering", 16, 72, 105, 17)
Global $GUIUpd = GUICtrlCreateLabel("", 112, 115, 100, 17, BitOR($SS_CENTER,$SS_CENTERIMAGE))
Global $GUITime = GUICtrlCreateLabel("00:00:00", 24, 115, 68, 17,BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "Close")
GUICtrlSetOnEvent($GUIStart, "Init")
GUICtrlSetOnEvent($GUIRendering, "ToggleRendering")

GUICtrlSetState($GUIRendering,$GUI_DISABLE)

GUISetState(@SW_SHOW)
#EndRegion

#Region *MAIN*

While Not $boolRun
   Out1("NOT IN RIGHT PLACE")
   Sleep(100)
WEnd

While $boolRun
   Local $map = GetMapID()
   Local $rightPlace = ($map==$urgoz)
   While($rightPlace)
	  Out1("Time to start rupting")
	  Sleep(500)
	  $agent = GetWurmAndBark()
	  $model = DllStructGetData($agent, "playernumber")
	  If $model == $wurm Or $model == $bark Then
		 While Not GetIsDead($agent) And GetDistance($agent, $me) < 320
			Out1("Not Dead")
			Sleep(100)
			RuptSkill($agent)
		 WEnd
	  EndIf
	  Sleep(100)
   WEnd
WEnd

While Not $boolRun
   Out1("NOT IN RIGHT PLACE")
   Sleep(100)
WEnd

#EndRegion

#Region *FUNCTIONS*

; Interupt healing touch casted by guardian serpents and twisted barks
Func RuptSkill($agent)
   If GetDistance($agent, $me) > 180 Then Return False
   Local $char = GetAgentByID()
   Local $weapon = DllStructGetData($char, "WeaponType")
   If GetSkillbarSkillRecharge($dshot)==0 And $weapon==1 Then
	  If GetIsCasting($agent) And Not GetIsCasting($me) Then
		 $target = GetTarget($agent)
		 UseSkill($dshot, $target)
		 Out1("Rupted")
		 Return True
	  EndIf
   EndIf
   Return False
EndFunc

; Find guardian serpents and twisted barks within 180 units of the player
Func GetWurmAndBark()
   Local $agent, $i
   Local $count = 0
   For $i = 1 to GetMaxAgents()
	  $agent = GetAgentByID($i)
	  $model = DllStructGetData($agent, "playernumber")
	  If GetDistance($i, $me) < 180 And($model==$wurm Or $model == $bark) Then
		 Out1("Found rupt target")
		 Sleep(100)
		 ChangeTarget($agent)
		 Return $agent
	  EndIf
   Next
   Out1("No Rupt Target Found")
   Sleep(100)
   Return 0
EndFunc
#EndRegion

#region *UTILITY*

; Launch the bot
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

; Close the bot
Func Close()
	Exit
EndFunc

; Print text to the GUI
Func Out1($text)
	If GUICtrlRead($GUIUpd) <> $text Then GUICtrlSetData($GUIUpd,$text)
EndFunc
#EndRegion
