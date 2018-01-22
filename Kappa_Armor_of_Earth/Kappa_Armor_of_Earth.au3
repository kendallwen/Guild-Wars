;----------------------------;
;                            ;
;        WRITTEN BY          ;
;   KENDAL WEN AND CARROTS   ;
;                            ;
;  FARMS KAPPAS OUTSIDE OF   ;
;  GYALA HATCHERY FOR DEMON  ;
;          SHIELDS           ;
;                            ;
;----------------------------;

#include-once
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

 Global $array[30]

 ; Map IDs
 Global Const $Gyala_Hatchery = 224
 Global Const $Maishang_Hills = 199

 Global Const $offset = 1000 ;sleep time

 ;Bag and storage information
 Global Const $BAG_SLOT[4] = [20, 5, 10, 10]
 Global Const $lastStock = 3 ; num of last xunail tab to consider
 Global Const $lastBag = 3 ; numb of last bag to consider

 ; Item IDs
 Global Const $KappaShell = 850
 Global Const $boneID = 921
 Global Const $eyeID = 931
 Global Const $fangID = 932
 Global Const $clawID = 923
 Global Const $lockpickID = 22751
 Global Const $salvageKit = 2
 Global Const $IDKit = 6
 Global Const $materials[36] = [ _
	 921, 922, 923, 925, 926, 927, _
	 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, _
	 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, _
	 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
 Global Const $consumable[38] = [ _
	 22752, 22269, 28436, 31152, 31151, 31153, 35121, 28433, 26784, _
	 6370, 21488, 21489, 22191, 24862, 21492, 22644, 30855, 5585, _
	 24593, 6375, 22190, 6049, 910, 28435, 6369, 21809, 21810, 21813, _
	 6376, 6368, 29436, 21491, 28434, 21812, 35124, 37765, 22191, 22190]

 ;Item Values
 Global Const $RARITY_GOLD = 2624
 Global Const $RARITY_WHITE = 2621

 ; ==== Build ====
 Global Const $SkillBarTemplate = "OgVDI8MJTIAGDlCfVaDLByAulA"

 ;~ Skill IDs
 Global Const $SKILL_ID_MANTRA = 8
 Global Const $SKILL_ID_GLYPH = 198
 Global Const $SILL_ID_AOE = 165
 Global Const $SKILL_ID_STONE = 1375
 Global Const $SKILL_ID_OBBY = 218
 Global Const $SKILL_ID_ARCHANE_ECHO = 75
 Global Const $SKILL_ID_WASTREL_WORRY = 50
 Global Const $SKILL_ID_RAD_FIELD = 2414
 ; found here http://wiki.guildwars.com/wiki/Skill_template_format/Skill_list

 ; declare skill numbers to make the code WAY more readable (UseSkill($sf) is better than UseSkill(2))
 Global Const $mantra = 1
 Global Const $glyphOfElementalPower = 2
 Global Const $armorOfEarth = 3
 Global Const $stoneflesh = 4
 Global Const $obby = 5
 Global Const $echo = 6
 Global Const $wastrels = 7
 Global Const $radField = 8

 ; Store skills energy cost
 Global Const $skillCost[9] = [0, 10, 5, 10, 10, 25, 15, 5, 15]

#EndRegion

#Region *VARIABLES*

 ; Counters
 Global $ShellCount = 0
 Global $BoneCount = 0
 Global $EyeCount = 0
 Global $Profit = 0
 Global $Runs = 0
 Global $Fails = 0
 Global $timer

 ; Checkboxes
 Global $boolRun = False
 Global $RenderingEnabled = True
 Global $PickUpShells = False
 Global $SalvageShells = False

#EndREgion

#Region *GUI*

Global $C1 = GUICreate("Kappa Kappa", 306, 254, 244, 193)
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
Global $GUIUpd = GUICtrlCreateLabel("", 112, 215, 172, 17, BitOR($SS_CENTER,$SS_CENTERIMAGE))
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

#region *MAIN*

While Not $boolRun
	Sleep(100)
WEnd

$timer = TimerInit()
AdlibRegister("UpdTimer",1000)

While $boolRun
	ResignStart()
	UpdCounts()
	While 1
		If Not $boolRun Then
			GUICtrlSetData($GUIStart, "START")
			GUICtrlSetState($GUIStart, $GUI_ENABLE)
			While Not $boolRun
				Sleep(100)
			WEnd
		EndIf
		RandomSleep(500,1000)
		Switch Farm()
			Case 0
				$Runs += 1
				Out1("Run completed")
				UpdCounts()
				If Not Resign2() Then ResignStart()
				ContinueLoop
			Case 1
				$Runs += 1
				Out1("Inventory full")
				UpdCounts()
				ManageInventory()
				If Not Resign2() Then ResignStart()
				ExitLoop
			 Case 2
				$Runs += 1
				$Fails += 1
				Out1("You're dead")
				UpdCounts()
				If Not Resign2() Then ResignStart()
				ContinueLoop
		EndSwitch
	WEnd
WEnd

While Not $boolRun
	Sleep(1000)
WEnd

#endregion

#Region *FUNCTIONS*

; Wait for an outpost or explorable area to fully load
Func WaitForLoad()
	Local $load,$lMe,$loadtimer = TimerInit()
	InitMapLoad()
	Do
		Sleep(100)
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)
		If TimerDiff($loadtimer) > 40000 Then Return False
	Until $load = 2 And DllStructGetData($lMe, 'X') = 0 And DllStructGetData($lMe, 'Y') = 0
	$loadtimer = TimerInit()
	Do
		Sleep(100)
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)
		If TimerDiff($loadtimer) > 40000 Then Return False
	Until $load <> 2 And DllStructGetData($lMe, 'X') <> 0 And DllStructGetData($lMe, 'Y') <> 0
	Return True
EndFunc

; Map travel to Gyala Hatchery if not there already
Func ResignStart()
	If GetMapID() <> $Gyala_Hatchery Then
		Out1("Traveling to Gyala")
		TravelTo($Gyala_Hatchery)
	EndIf
	pingSleep()
	Out1("Ready")
EndFunc

; Zone into Maishang Hills
Func EnterArea()
   Out1("Exiting Gyala")
	MoveTo(687, 23241)
	Do
		Sleep(10)
	Until Move(4200, 25900)
	WaitForLoad()
	PingSleep(500)
EndFunc

; Map travel to Gyala Hatchery
Func LeaveArea()
	Do
		Sleep(10)
	Until Move(779, 1145)
	WaitForLoad()
EndFunc

; Farm the kappas in Gyala Hatchery. Return 0 if successful run, 1 if lacking inventory space,
; and 2 if the player died during the run
Func Farm() ; 0 = done / 1 = no free slots / 2 = dead
	If Not $RenderingEnabled Then ClearMemory()
	SwitchMode(1) ;HM for dat gold chance
	RndSleep(200)
	If Not RunToSpot() Then Return 2
	Out1("Pick-Up loots")
	Sleep(1000)
	Switch PickUpLoot()
		Case 0
			Return 2
		Case 1
			Return 1
	EndSwitch
	UpdCounts()
	Return 0
EndFunc

; Move to the initial farming spot. Return true if run was successful and false if player died
Func RunToSpot() ; false = dead
	EnterArea()
	PingSleep(1000)
	If GetIsDead(-2) Then Return False
	MoveTo(16876, -9483)
	TargetNearestEnemy()
	BallingGroups()
	If GetIsDead(-2) Then Return False
	Local $killtimer = timerinit()
	Do
		StayAlive()
		Kill()
	 Until GetIsDead(-2) or IsEverythingDead() or TimerDiff($killtimer) > 120000
	If IsEverythingDead() Return True
	Return False
 EndFunc

; Move around Maishang Hills to ball 3 kappa groups. Return false if the player dies.
Func BallingGroups()
	If GetIsDead(-2) Then Return False
	Out1("Str8 Ballin")
	TargetNearestEnemy()
	While GetDistance() >1600
		TargetNearestEnemy()
		sleep(100)
	WEnd
	UseSkillEx($mantra)
	UseSkillEx($glyphOfElementalPower)
	UseSkillEx($armorOfEarth)
	UseSkillEx($stoneflesh)
    If GetIsDead(-2) Then Return False
	While GetNumberOfFoesInRangeOfAgent(-2, 1000) < 7
		 Sleep(100)
		 StayAlive()
		 If GetIsDead(-2) Then Return False
	WEnd
	MoveAggroing(19476, -12338) ;get far group
	If GetIsDead(-2) Then Return False
    Local $ballTimer = timerinit()
	While Not(GetNumberOfFoesInRangeOfAgent(-2, 1000) > 10 Or TimerDiff($ballTimer) > 30000)
		 Sleep(100)
		 StayAlive()
		 If GetIsDead(-2) Then Return False
	 WEnd
    UseSkillEx($obby)
	MoveAggroing(19872, -10347)		;far aggro spot to ball
	If GetIsDead(-2) Then Return False
	Out1("AT FAR SPOT")
	Sleep(2000)
	MoveAggroing(19431, -10845)
	If GetIsDead(-2) Then Return False
EndFunc

; Kill kappas.
Func Kill() ;pew pew pew pew pew pe wp ewp ew pe wpew p ewp ewp ew
 Out1("Death to Twitch memes")

	StayAlive()
	If GetEffectTimeRemaining($SKILL_ID_STONE) > 6000 Then
			; Use rad field if possible
			If GetEffectTimeRemaining($SKILL_ID_STONE) > 8000 Then
				If IsRecharged($radField) Then
				   UseSkillEx($radField)
				EndIf
			EndIf
			StayAlive()

			; Use Obby to ball enemies
			If IsRecharged($obby) Then
			   UseSkillEx($obby)
			EndIf
			StayAlive()

			; Use echo if possible
			If GetEffectTimeRemaining($SKILL_ID_STONE) > 8500 And GetSkillbarSkillID($echo)==$SKILL_ID_ARCHANE_ECHO Then
				If IsRecharged($wastrels) And IsRecharged($echo) Then
					UseSkillEx($echo)
					TargetNearestEnemy()
					UseSkillEx($wastrels, -1)
				EndIf
			EndIf
			StayAlive()

			; Use wastrel if possible
			If IsRecharged($wastrels) Then
				TargetNextEnemy()
				If GetDistance() < 1000 Then
					UseSkillEx($wastrels, -1)
				EndIf
			EndIf

			StayAlive()

			; Use echoed wastrel if possible
			If IsRecharged($echo) And GetSkillbarSkillID($echo)==$SKILL_ID_WASTREL_WORRY Then
				TargetNextEnemy()
				If GetDistance() < 1000 Then
					UseSkillEx($echo, -1)
				EndIf
			EndIf

			StayAlive()
	EndIf
EndFunc

; Determine if enough kappas have died.
Func IsEverythingDead()
	If GetNumberOfFoesInRangeOfAgent(-2, 300) > 2 Then
		Return False
	Else
		Return True
	EndIf
EndFunc

;~ Description: Move to destX, destY, while staying alive vs Kappa
Func MoveAggroing($lDestX, $lDestY, $lRandom = 150)
	If GetIsDead(-2) Then Return
	If GetMapID() <> $Maishang_Hills Then Return

    $moveTimer = timerinit()
	Move($lDestX, $lDestY, $lRandom)

	Do
		Sleep(50)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return False
		StayAlive()
		Sleep(100)
		Move($lDestX, $lDestY, $lRandom)
	 Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1 Or TimerDiff($moveTimer) > 60000
	 If TimerDiff($moveTimer)>60000 Then Return False
	Return True
EndFunc

; Stay alive
Func StayAlive()
	If GetMapID() <> $Maishang_Hills Then Return
	If GetIsDead(-2) Then Return
	If IsRecharged($mantra) Then
	   UseSkillEx($mantra)
	EndIf
	UseEnchants()
	Return
 EndFunc

; Use enchantments to stay alive if stoneflesh has almost run out and skills are recharged.
 Func UseEnchants()
	If GetEffectTimeRemaining($SKILL_ID_STONE) < 7000 Then
	   UseSKillEx($glyphOfElementalPower)
	   UseSkillEx($armorOfEarth)
	   UseSkillEx($stoneflesh)
	EndIf
 EndFunc

; Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.
Func IsRecharged($lSkill)
	If GetSkillBarSkillRecharge($lSkill)==0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; Resign in Maishang Hills and map travel back to Gyala Hatchery when dead or the run is finished
Func Resign2()
	Local $timerResign = TimerInit()
	Out1("Resign")
	Resign()
    RndSleep(300)
		If TimerDiff($timerResign) >= 10000 Then
			Resign()
		EndIf
	Sleep(3000)
	ReturnToOutPost()
		If Not WaitForLoad() Then
			TravelTo($Gyala_Hatchery)
			WaitForLoad()
			Return False
		EndIf
	Return True
EndFunc

; Use a skill taking into effect the amount of time it takes to cast
Func UseSkillEx($aSkillSlot, $aTarget = -2) ; false = dead
	Local $tDeadlock = TimerInit()
	USESKILL($aSkillSlot, $aTarget)
	Do
		Sleep(50)
		If GetIsDead(-2) Then Return False
	Until GetSkillBarSkillRecharge($aSkillSlot) <> 0 Or TimerDiff($tDeadlock) > 6000
	Return True
EndFunc

; Determine the number of enemies within a certain range of an agent
Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $lAgent, $lCount = 0
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If GetDistance($lAgent,$aAgent) > $aRange Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
		If DllStructGetData($lAgent, 'Type') <> 0xDB Then ContinueLoop
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop ;foe
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop ;not dead
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc

#endregion

#Region *PICK-UP*

; pick up drops
Func PickUpLoot() ; 0 = dead / 1 = no free slots / 2 = done
	Local $i, $count = 0
	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return 0
		If freeSlot() = 3 Then Return 1
		If IsItem($i) Then Pick($i)
		pingSleep()
		If freeSlot() = 3 Then Return 1
	Next
	Return 2
EndFunc

; pick up an item
Func Pick($agentID)
	Local $lMe, $lBlockedTimer, $lBlockedCount = 0, $lItemExists = True
	Local $item = GetItemByAgentID($agentID)
	If CanPickup($item) Then
		Do
			SendChat("stuck", "/")
			If GetDistance($item) > 150 Then Move(DllStructGetData($item, 'X'), DllStructGetData($item, 'Y'), 1)
			PickUpItem($item)
			Do
				Sleep(3)
				$lMe = GetAgentByID(-2)
			Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
			$lBlockedTimer = TimerInit()
			Do
				Sleep(3)
				$lItemExists = IsDllStruct(GetAgentByID($agentID))
			Until Not $lItemExists Or TimerDiff($lBlockedTimer) > 6000
			If $lItemExists Then $lBlockedCount += 1
		Until Not $lItemExists Or $lBlockedCount > 5
	EndIf
	If Not $lItemExists Then Updcounts2(DllStructGetData($item,"ModelID"),DllStructGetData($item,"Quantity"))
EndFunc

; Determine if an agent is an item that the player can pick up
Func IsItem($agentdID))
	 $lAgent = GetAgentByID($agentID)
	 If GetDistance($lAgent) > 1300 Then Return False
	 If Not GetIsMovable($lAgent) Then Return False
	 If Not GetCanPickUp($lAgent) Then Return False
     Return True
EndFunc

; Determine if an item drop is worth picking up or not
Func CanPickUp($aItem)
	Local $i,$e = DllStructGetData($aItem, 'ExtraID')
	Local $m = DllStructGetData(($aItem), 'ModelID')
	Local $r = GetRarity($aItem)
	Local $t = DllStructGetData(($aItem), 'Type')
    If $m = $KappaShell And $PickUpShells Then Return True
	If $m = $lockpickID Then Return True
	If $m = $boneID Then Return True
	If $m = $eyeID Then Return True
	If $m = $fangID Then Return True
	If $m = $clawID Then Return True

	If $t = 20 And GetGoldCharacter() < 99000 Then
		$Profit += DllStructGetData($aItem,"Quantity")
		Return True	; gold coins if u got less than 99k
	EndIf
	If $r = $RARITY_GOLD Then Return True ;All rare items
	For $i = 0 To 37 Step 1
		If $m = $consumable[$i] Then Return True ; consumables
	Next
	Return False
EndFunc

#EndRegion

#region *INVENTORY*

; Manage inventory when full in Dragon's Throat
Func ManageInventory()
	If GetMapID() <> 274 Then
		Out1("Travelling to Dragon's Throat")
		TravelTo(274)
		PingSleep(500)
	EndIf
	GoToXunlai()
	GoToMerch()
	ManageKits()
	Sleep(1000)
	If lIdentify() Then
		If Not IsChestFull() Then Storage()
		If IsChestFull() And freeslot() < 2 Then Exit
	EndIf
	Sleep(1000)
	sellInventory()
	Sleep(1000)
	If salvage() Then
		If Not IsChestFull() Then Storage()
		If IsChestFull() And freeslot() < 2 Then Exit
	EndIf
	Sleep(1000)
	UpdCounts()
EndFunc

; Move to a destination while in an outpost
Func OPMove($lDestX, $lDestY, $lRandom = 150)
	Local $lMe, $lBlocked, $lAngle, $ChatStuckTimer = TimerInit(), $stuckTimer = TimerInit()
	Move($lDestX, $lDestY, $lRandom)
	Do
		Sleep(50)
		$lMe = GetAgentByID(-2)
		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			Else
				$lAngle += 40
				Move(DllStructGetData($lMe,'X')+100*Sin($lAngle), DllStructGetData($lMe,'Y')+100*Cos($lAngle),0)
			EndIf
		Else
			If $lBlocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
			EndIf
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1.5
	Return True
EndFunc

; Move to the xunlai chest
Func GoToXunlai()
	Local $xunlai = GetNearestAgentToCoords(-10824,6352)
	Out1("Go to Xunlai")
	OPMove(GetPos($xunlai,"X"),GetPos($xunlai,"Y"))
	PingSleep()
	GoNPC($xunlai)
	PingSleep(500)
EndFunc

; Move to the merchant
Func GoToMerch()
	Local $merch = GetNearestAgentToCoords(-10714,6915)
	Out1("Go to Merch")
	OPMove(GetPos($merch,"X"),GetPos($merch,"Y"))
	PingSleep()
	GoNPC($merch)
	PingSleep(500)
EndFunc

; Talk to the merchant
Func TalkToMerch()
	Local $merch = GetNearestAgentToCoords(-10714,6915)
	GoNPC($merch)
EndFunc

; Determine how many empty slots are left in the inventory
Func freeSlot()
Local $i, $j, $count = 0
	For $i = 1 To 3
		For $j = 1 To $BAG_SLOT[$i - 1]
			If DllStructGetData(GetItemBySlot($i, $j), 'ModelID') == 0 Then $count = $count + 1
		Next
	Next
Return $count
EndFunc

; Buy identification and salvage kits when necessary
Func ManageKits()
	Local $IDKitnumb, $SalvKitnumb
	Local $lMe = GetAgentByID(-2)
	Local $merch = GetNearestAgentToCoords(-10714,6915)
	Out1("Buying Kits")
	$IDKitnumb = CheckIDKit()
	$SalvKitnumb = CheckSalvageKit()
	If ComputeDistance(GetPos($merch,"X"),GetPos($merch,"Y"),GetPos($lMe,"X"),GetPos($lMe,"Y")) > 200 Then
		GoToMerch()
	Else
		TalkToMerch()
	EndIf
	If Not buySalvageKit(2-$SalvKitnumb) Then Return False
	If Not lbuyIDKit(1-$IDKitnumb) Then Return False
	Return True
EndFunc

#EndRegion

#Region *SALVAGE*

; Buy a salvage kit
Func buySalvageKit($quantity) ; return false in case of no gold
	If freeSlot() < $quantity Then Return False
	Local $price, $i, $gold
	DepositGold(0)
	If $quantity = 0 Then Return True
	If $salvageKit = 2 Then
		$price = 100 ; normal kit
	Else
		$price = 400 ; expert kit
	EndIf
	$gold = GetGoldStorage() + GetGoldCharacter()
	If $gold < ($price*$quantity) And $gold > $price Then
		WithdrawGold(0)
		For $i = 1 To Int($gold/$price)
			BuyItem($salvageKit, 1, $price)
			pingSleep(1000)
		Next
		$Profit -= Int($gold/$price)*$price
		Return True
	ElseIf $gold < $price Then
		Return False
	EndIf
	WithdrawGold($price*$quantity)
	pingSleep(Random(1000,1500,1))
	For $i = 1 To $quantity
		BuyItem($salvageKit, 1, $price)
		pingSleep(1000)
	Next
	pingSleep(250)
	$Profit -= $price*$quantity
	Return True
EndFunc

; Determine how many uses a salvage kit has left
Func CheckSalvageKit()
	Return CountItem(2992)
EndFunc

; Salvage an item
Func salvage() ; return false if freeslot <= 1
    If Not $SalvageShells Then Return False
	If freeSlot() <= 2 Then Return False
	Local $i,$j,$count1,$count2,$item
	Out1("Salvaging")
	$count1 = CountItem($boneID)
	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i - 1]
			$item = GetItemBySlot($i, $j)
			If canSalvage($item) Then
				If CheckSalvageKit() = 0 Then ManageKits()
				startNormSalvage($item)
				StartSalvage($item)
				If GetRarity($item) <> $RARITY_WHITE Then
					Sleep(3*GetPing()+100)
 					SalvageMaterials()
					Do
						Sleep(200)
					Until ControlSend(GetWindowHandle(), "", "", "{Enter}")
				EndIf
				Sleep(200)
				Sleep($offset)
			EndIf
		Next
	Next
	$count2 = CountItem($boneID)
	$BoneCount += $count2-$count1
	Return True
EndFunc

; Determine if an item should be salvaged
Func canSalvage($item)
	Local $i,$m = DllStructGetData($item, 'ModelID')
	Local $t = DllStructGetData($item,"Type")
	If $m = $KappaShell And $SalvageShells Then Return True
	Return False
EndFunc

; Start salvaging items with a normal salvage kit
Func startNormSalvage($aItem)
	Local $lItemID, $lOffset[4] = [0, 0x18, 0x2C, 0x62C]
	Local $lSalvageKit, $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	$lSalvageKit = findNormSalvageKit()
	If $lSalvageKit = 0 Then Return

	DllStructSetData($mSalvage, 2, $lItemID)
	DllStructSetData($mSalvage, 3, findNormSalvageKit())
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])

	Enqueue($mSalvagePtr, 16)
EndFunc

; find normal salvage kits in a player's inventory
Func findNormSalvageKit()
	Local $i,$j
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2991
					If DllStructGetData($lItem, 'Value') / 8 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 8
					 EndIf
			    Case 2992
					If DllStructGetData($lItem, 'Value') / 8 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 8
					EndIf
				Case 5900
					If DllStructGetData($lItem, 'Value') / 10 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 10
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc

#EndRegion

#Region *IDENTIFY*

; Buy identification kits
Func lbuyIDKit($quantity) ; return false in case of no gold
	If freeSlot() < $quantity Then Return False
	Local $price = 500, $i, $gold
	DepositGold(0)
	If $quantity = 0 Then Return True
	$gold = GetGoldStorage() + GetGoldCharacter()
	If $gold < ($price*$quantity) And $gold > $price Then
		WithdrawGold(0)
		For $i = 1 To Int($gold/$price)
			BuyItem($IDKit, 1, $price)
			pingSleep(1000)
		Next
		$Profit -= Int($gold/$price)*$price
		Return True
	ElseIf $gold < $price Then
		Return False
	EndIf
	WithdrawGold($price*$quantity)
	pingSleep(Random(1000,1500,1))
	For $i = 1 To $quantity
		BuyItem($IDKit, 1, $price)
		pingSleep(1000)
	Next
	pingSleep(250)
	$Profit -= $price*$quantity
	Return True
EndFunc

; Determine how many uses an identification kit has
Func CheckIDKit()
	Return CountItem(5899)
EndFunc

; Determine if an item should be identified
Func canIdentify($item)
	Local $m = DllStructGetData($item,"ModelID")
	Local $t = DllStructGetData($item,"Type")
	If $m == 0 Then Return False
	If GetRarity($item) <> $RARITY_WHITE Then
		If Not GetIsIDed($item) Then Return True
	EndIf
	Return False
EndFunc

; Identify all items in the inventory
Func lIdentify()
	Local $i,$j
	Out1("Identifying")
	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i - 1]
			Local $item = GetItemBySlot($i, $j)
			If canIdentify($item) Then
				If CheckIDKit() = 0 Then ManageKits()
				IdentifyItem($item)
				PingSleep($offset)
			EndIf
		Next
	Next
	Return True
EndFunc

#EndRegion

#Region *STOCKAGE*

; Determine what the next empty slot is in the xunlai chest
Func NextXunlaiFreeSlot()
Local $arrayslot[2], $i, $j
	For $i = 8 To $lastStock+7
		For $j = 1 To 20
			If DllStructGetData(GetItemBySlot($i, $j),'ModelID') = 0 Then
				$arrayslot[0] = $i
				$arrayslot[1] = $j
				Return $arrayslot
			EndIf
		Next
	Next
Return $arrayslot
EndFunc

; Determine if an item should be stored
Func GetIsStockable(ByRef Const $item)
	Local $i, $m = DllStructGetData($item, 'ModelID')
	Local $t = DllStructGetData($item,"Type")
	Local $r = GetRarity($item)
	If $m == 0 Then Return False
	If IsGoodOsShield($item) Then Return True
	If IsDualVamp($item) Then Return True
	If $m == 934 And $t == 5 Then Return False
	If $r <> $RARITY_WHITE Then Return False
	For $i = 1 To 36
		If $m == $materials[$i-1] Then Return True
	Next
	For $i = 1 To 38
		If $m == $consumable[$i-1] Then Return True
	Next
	Return False
 EndFunc

; Determine if an item is a valuable old school shield
Func IsGoodOsShield(ByRef Const $item)
 Local $r = GetRarirty($item)
 local $t = DllStructGetData($item, "Type")
 Local $modStruct = GetModStruct($item)
 $modStruct = StringTrimLeft($modStruct, 2)
 If $r==$RARITY_GOLD And $t==24 Then
	; 084821 = demon
	If StringInStr($modStruct, "084821") Then Return True
	If StringInStr($modStruct, "07159827") Or StringInStr($modStruct, "07119827") Then ;q7 tactics or strength
	   If StringInStr($modStruct, "080FB8A7") Then ;15 armor
		  If StringLen($modStruct)>32 Then
			 If StringInStr($modStrucdt, "0A034821") Or StringInStr($modStruct, "0A004821") Then Return True ;0A034821 = plant, 0A004821 = undead
			 If StringInStr($modStruct, "4823") Then Return True ;4823 = +10 vs damage type
			 If StringInStr($modStruct, "1821") Then Return True ;1821 = +health
			 If StringInStr($modStruct, "6823") Then Return True;6823 = +4x health we
			 If StringInStr($modStruct, "02008820") Then Return True ;02008820 = -2we
			 EndIf
		  EndIf
	   EndIf
	If StringInStr($modStruct, "08109827") Then ;16 armor
	   If StringLen($modStruct)>32 Then
		  If StringInStr($modStrucdt, "0A034821") Or StringInStr($modStruct, "0A004821") Then Return True ;0A034821 = plant, 0A004821 = undead
		  If StringInStr($modStruct, "4823") Then Return True ;4823 = +10 vs damage type
		  If StringInStr($modStruct, "1821") Then Return True ;1821 = +health
		  If StringInStr($modStruct, "6823") Then Return True;6823 = +4x health we
		  If StringInStr($modStruct, "02008820") Then Return True ;0200820 = -2we
	   EndIf
	EndIf
 EndIf
 Return False
 EndFunc

; Determine if a weapon has an inherent vampiric effect
 Func IsDualVamp(ByRef Const $item)
	Local $modStruct = GetModStruct($item)
	If StringinStr($modStruct, "0100E820") Then Return True
	Return False
 EndFunc

; Find all slots that items can be stored in
Func FindSlotToStorage(ByRef Const $item)
	Local $i,$j,$xunlaitem,$xunlaitemID,$arrayslot[2],$modelID = DllStructGetData($item,'ModelID')
	For $i = 8 To $lastStock + 7
		For $j = 1 To 20
			$xunlaitem = GetItemBySlot($i, $j)
			$xunlaitemID = DllStructGetData(($xunlaitem),'ModelID')
			If $xunlaitemID == $modelID And GetRarity($item) == $RARITY_WHITE Then
				If DllStructGetData($xunlaitem,'Quantity') < 250 Then
					$arrayslot[0] = $i
					$arrayslot[1] = $j
					Return $arrayslot
				EndIf
			EndIf
		Next
	Next
	$arrayslot = NextXunlaiFreeSlot()
	Return $arrayslot
EndFunc

; Sotre an item in the chest
Func StorageItem($item) ; return false in case of full chest
	If IsChestFull() Then Return False
	Local $arrayslot[2] = [0,0]
	$arrayslot = FindSlotToStorage($item)
	MoveItem($item,$arrayslot[0],$arrayslot[1])
	Sleep(GetPing()+$offset)
	Return True
EndFunc

; Process the inventory and store items that should be stored
Func Storage() ; return false in case of full chest
	Local $i,$j,$item
	Out1("Stocking")
	For $i = 1 To 4
		For $j = 1 To $BAG_SLOT[$i-1]
			$item = GetItemBySlot($i, $j)
			If GetIsStockable($item) Then
				If Not StorageItem($item) Then Return False
				If DllStructGetData(GetItemBySlot($i,$j),'ModelID') <> 0 Then $j -= 1
			EndIf
		Next
	Next
	Return True
EndFunc

; Determine if the xunlai chest is full
Func IsChestFull()
	Local $i,$j,$c = 0
	For $i = 8 To $lastStock + 7
		For $j = 1 To 20
			If DllStructGetData(GetItemBySlot($i,$j),"ModelID") == 0 Then $c += 1
		Next
	Next
	Return $c == 0
EndFunc

#EndRegion

#Region *SELL*

; Sell all items in the inventory
Func sellInventory()
	Local $i,$j,$count = 0
	Out1("Selling")
	DepositGold(0)
	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i-1]
			Local $item = GetItemBySlot($i, $j)
			If canSell($item) Then
				SellItem($item)
				pingSleep($offset)
				$count += DllStructGetData($item,"Value")
			EndIf
		Next
	Next
	$Profit += $count
EndFunc

; Determine if an item should be sold
Func canSell($item)
	Local $i,$m = DllStructGetData($item,"ModelID")
	Local $t = DllStructGetData($item,"Type")
	Local $r = GetRarity($item)
	If $m == 0 Then Return False
	If GetIsStockable($item) Then Return False
	Return True
EndFunc

#EndRegion

#region *UTILITY*

; Begin the run upon pressing the start button
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

; Determine an agents position
Func GetPos(ByRef $agent,$coord) ; $coord = "X" or "Y"
	Return DllStructGetData($agent,$coord)
EndFunc

; Close the window and exit the bot
Func Close()
	Exit
EndFunc

; Sleep for a random amount of time
Func RandomSleep($min,$max)
	Sleep(Random($min,$max,1))
EndFunc

; Count the number of items of a certain type
Func CountItem($itemID)
	Local $i,$j,$item,$count = 0
	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i-1]
			$item = GetItemBySlot($i,$j)
			If DllStructGetData($item,'ModelID') == $itemID Then
				$count += DllStructGetData($item,'Quantity')
			EndIf
		Next
	Next
	Return $count
EndFunc

; Update the GUI variables with the number of drops of certain types
Func Updcounts2($itemID, $quantity)
	Switch $itemID
	  Case $KappaShell
		 $ShellCount += $quantity
	  Case $boneID
		 $BoneCount += $quantity
	  Case $eyeID
		 $EyeCount += $quantity
	EndSwitch
EndFunc

; Upate the GUI with the number of drops of a certain type
Func UpdCounts()
	GUICtrlSetData($GUIgolds, $Profit)
	GUICtrlSetData($GUIshells, $ShellCount)
	GUICtrlSetData($GUIbones, $BoneCount)
	GUICtrlSetData($GUIeyes, $EyeCount)
	GUICtrlSetData($GUIruns, $Runs)
	GUICtrlSetData($GUIfails, $Fails)
EndFunc

; Print a string to the GUI
Func Out1($text)
	If GUICtrlRead($GUIUpd) <> $text Then GUICtrlSetData($GUIUpd,$text)
EndFunc

; Update the GUI with the time that the bot has been running
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

; Sleep for a time equal to the player's ping
Func pingSleep($time = 0)
	Sleep(GetPing() + $time)
EndFunc

; Toggle graphical rendering of the game
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

; Toggle items to be picked up
 Func TogglePickUp()
	$PickUpShells = Not $PickUpShells
	If $PickUpShells Then
	   GUICtrlSetState($GUIsShells, $GUI_ENABLE)
	Else
	   GUICtrlSetState($GUIsShells, $GUI_DISABLE)
	EndIf
 EndFunc

; Toggle items to be salvaged
 Func ToggleSalvage()
	$SalvageShells = Not $SalvageShells
 EndFunc

#endregion
