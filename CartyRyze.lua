--first check if my Hero is Carty's(Ryze)
if myHero.charName ~= "Ryze" then return end

--Carty's Ryze--

--Variables
local ts
local vp
local ignite = nil
local shop = GetShop()
local isrecalling = false
local holdpos = false
local EnemyMinions = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_HEALTH_DEC)
local miniondraw = nil
local hastears = false
local tearsslot = 1
local Ultion = false

--AutoLevel Sequence
local RyzeLevel = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}

--Ryze Stats
local Qrange = 900
local Qspeed = 1399
local Qdelay = 0.46
local Qradius = 50
local Wrange = 600
local Erange = 600
local AArange = 550
local SpellRange = {Range = Qrange, Speed = Qspeed, Delay = Qdelay, Width = Qradius}

--Version
local ScriptVersion = 0.01
local autoUpdate = true


AddLoadCallback(function()
if autoUpdate == true then
	local ServerResult = GetWebResult("raw.github.com","/MrMcCarty/CartyRyze/master/test.version")
	if ServerResult then
		ServerVersion = tonumber(ServerResult)
		if ScriptVersion < ServerVersion then
			print("A new version is available: v"..ServerVersion..". Attempting to download now.")
			DelayAction(function() DownloadFile("https://raw.githubusercontent.com/MrMcCarty/CartyRyze/master/CartyRyze.lua".."?rand"..math.random(1,9999), SCRIPT_PATH.."CartyRyze.lua", function() print("Successfully downloaded the latest version: v"..ServerVersion..".") end) end, 2)
		else
			print("You are running the latest version: v"..ScriptVersion..".")
		end
	else
		print("Error finding server version.")
	end
	else
	print("Autoupdate disabled! Your version: " .. ScriptVersion .. ".")
end
end)




--Draw Text/Color/Number Classes
TextSequence = {}
TextList = {"Harras", "QQ WW EE", "QQ W EE", "QQ W E", "Q W E", "Q E", "Q", "E"}
ColorClass = {ARGB(255,51,153,255), ARGB(255,255,230,0), ARGB(255,255,196,0), ARGB(255,255,171,0), ARGB(255,255,128,0), ARGB(255,255,85,0), ARGB(255,255,0,0), ARGB(255,255,0,0)}
CircleRadius = {45,55,60,65,70,75,80,85}
--Requirements
require "VPrediction"

--Functions

function OnLoad( ... )
	-- body
	lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
	Libry()
	draw_calc_dmg()
	myHero = GetMyHero()
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900)
	Menu()
	HookPackets()
	--Chat Print
	print("CartyRyze Beta version: v" .. ScriptVersion .. "")
end

function Libry( ... )
	-- body
	VP = VPrediction()
end

function OnDraw( ... )
	-- body
	if not (myHero.dead) then

				for i, miniondraw in pairs(EnemyMinions.objects) do
	local AAdrawdmg = getDmg("AD", miniondraw, myHero)
	if miniondraw.health <= AAdrawdmg then
if miniondraw ~= nil and not miniondraw.dead and Config.draw.drawminion then
	for j = 60, 63 do
		DrawCircle(miniondraw.x, miniondraw.y, miniondraw.z, j, 0x999999)
end
end
end
	end
		if Config.draw.drawq then
		DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x999999)
	end
	if Config.draw.drawwe then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x999999)
	end
	for i = 1, heroManager.iCount do
if ValidTarget(heroManager:GetHero(i)) and heroManager:GetHero(i) ~= nil then
local barPos = WorldToScreen(D3DXVECTOR3(heroManager:GetHero(i).x, heroManager:GetHero(i).y, heroManager:GetHero(i).z))
local PosX = barPos.x - 35
local PosY = barPos.y + 27
local PosY2 = barPos.y + 50
local qdmg = getDmg("Q", heroManager:GetHero(i), myHero)
local wdmg = getDmg("W", heroManager:GetHero(i), myHero)
local edmg = getDmg("E", heroManager:GetHero(i), myHero)
local QQWWEE = (qdmg *2) + (wdmg * 2) + (edmg * 2)
if Config.draw.drawenemy then
if heroManager:GetHero(i).health - QQWWEE >= 0 then
DrawText(tostring(math.floor( heroManager:GetHero(i).health - QQWWEE)), 24, PosX, PosY2, ColorClass[TextSequence[i]])
	end

	DrawText(TextList[TextSequence[i]], 32, PosX, PosY, ColorClass[TextSequence[i]])
	for j = 40, CircleRadius[TextSequence[i]] do
		DrawCircle(heroManager:GetHero(i).x,heroManager:GetHero(i).y,heroManager:GetHero(i).z,j, ColorClass[TextSequence[i]])
end
end
end
end
end
end



function OnTick( ... )
	-- body
	Vars()
end

function Vars( ... )
	-- body
	ts:update()
	EnemyMinions:update()
	myHero = GetMyHero()
	target = ts.target

	--Functions update
		if Config.autoL.usel then
	AutoLevel()
end
	draw_calc_dmg()
		if Config.autoS.uses then
	autosteal()
end
	if Config.autoI.usei then
	autoIginte()
end
	Qcastnearshop()
	if(Config.Key.keyfarm) then
		if heroCanMove() then
			moveToCursor()
end
	Farm()
end
	if(Config.Key.keycombo) then
		if heroCanMove() then
			moveToCursor()
end
	Combo()
end
	--Check Spells ready
	Qr = (myHero:CanUseSpell(_Q) == READY)
	Wr = (myHero:CanUseSpell(_W) == READY)
	Er = (myHero:CanUseSpell(_E) == READY)
	Rr = (myHero:CanUseSpell(_R) == READY)
end

function AutoLevel( ... )
	-- body
	if myHero.level > GetHeroLeveled() then
		LevelSpell(RyzeLevel[GetHeroLeveled() + 1])
	end
end

function OnApplyBuff(unit,source, buff)
	-- body
	if buff.name == "recall" then
isrecalling = true
end
	if buff.name == "RyzeR" then
Ultion = true
end
end

function OnRemoveBuff(unit, buff)
	-- body
	if buff.name == "recall" then 
isrecalling = false
end
	if buff.name == "RyzeR" then 
Ultion = false
end
end

function draw_calc_dmg( ... )
	-- body
	for i=1, heroManager.iCount do
if ValidTarget(heroManager:GetHero(i)) and heroManager:GetHero(i) ~= nil then
local qdmg = getDmg("Q", heroManager:GetHero(i), myHero)
local wdmg = getDmg("W", heroManager:GetHero(i), myHero)
local edmg = getDmg("E", heroManager:GetHero(i), myHero)
local QQWWEE = (qdmg *2) + (wdmg * 2) + (edmg * 2)
local QQWEE = (qdmg *2) + (wdmg) + (edmg * 2)
local QQWE = (qdmg *2) + (wdmg) + (edmg)
local QWE = (qdmg) + (wdmg) + (edmg)
local QE = (qdmg) + (edmg)
local Q = (qdmg)
local E = (edmg)

--HARRAS
if heroManager:GetHero(i).health > QQWWEE then
	TextSequence[i] = 1
end
--FIRST KILLABLE "QQWWEE"
if heroManager:GetHero(i).health <= QQWWEE and heroManager:GetHero(i).health > QQWEE then
	TextSequence[i] = 2
end
--SEC KILLABLE "QQWEE"
if heroManager:GetHero(i).health <= QQWEE and heroManager:GetHero(i).health > QQWE then
	TextSequence[i] = 3
end
--THIRD KILLABLE "QQWE"
if heroManager:GetHero(i).health <= QQWE and heroManager:GetHero(i).health > QWE then
	TextSequence[i] = 4
end
--FOURTH KILLABLE "QWE"
if heroManager:GetHero(i).health <= QWE and heroManager:GetHero(i).health > QE then
	TextSequence[i] = 5
end
--FIFTH KILLABLE "QE"
if heroManager:GetHero(i).health <= QE and heroManager:GetHero(i).health > Q and heroManager:GetHero(i).health > E then
	TextSequence[i] = 6
end
--SIX KILLABLE "Q"
if heroManager:GetHero(i).health <= Q and heroManager:GetHero(i).health > E  then
	TextSequence[i] = 7
end
--SEVENTH KILLABLE "E"
if heroManager:GetHero(i).health <= E then
	TextSequence[i] = 8
end
end
end
end

function Combo( ... )
	-- body
	if (ts.target ~= nil) and not (myHero.Dead) then
		local targetPOS, HitChance, Position = VP:GetLineCastPosition(ts.target, 0.46, 50, 900, 1400, myHero, true)
		--Q without Ulti on cast
		if Qr and not Ultion and Config.Cmo.useq and (targetPOS ~= nil and GetDistance(targetPOS)<SpellRange.Range and HitChance > 0) then
			CastSpell(_Q, targetPOS.x, targetPOS.z)
		end
		--Q with Ulti on cast
				if Qr and Ultion and Config.Cmo.useq and (targetPOS ~= nil and GetDistance(targetPOS)<SpellRange.Range) then
			CastSpell(_Q, targetPOS.x, targetPOS.z)
		end
		--W cast
		if Wr and Config.Cmo.usew and GetDistance(ts.target) <= Wrange then
				CastSpell(_W, ts.target)
			end
		--E cast
		if Er and Config.Cmo.usee and GetDistance(ts.target) <= Erange then
				CastSpell(_E, ts.target)
			end
		--R cast
		if Rr and Config.Cmo.user and GetDistance(ts.target) <= Wrange then
			if Qr or Wr or Er then
				CastSpell(_R)
			 end
			end
			if not Qr and not Wr and not Er and GetDistance(ts.target) <= AArange then
				myHero:Attack(ts.target)
			end
	end
end


function autoIginte( ... )
	-- body
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
ignite = SUMMONER_1
elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
ignite = SUMMONER_2
end
for i=1, heroManager.iCount do
if ValidTarget(heroManager:GetHero(i)) and heroManager:GetHero(i) ~= nil then
local ignitedmg = getDmg("IGNITE", heroManager:GetHero(i), myHero)
if heroManager:GetHero(i).health <= ignitedmg and GetDistance(heroManager:GetHero(i)) <= 600 then
	CastSpell(ignite, ts.target)
end
end
end
end


function autosteal( ... )
	-- body
	if (ts.target ~= nil) and not (myHero.Dead) then
		local targetPOS, HitChance, Position = VP:GetLineCastPosition(ts.target, 0.46, 50, 900, 1400, myHero, true)
	for i=1, heroManager.iCount do
if ValidTarget(heroManager:GetHero(i)) and heroManager:GetHero(i) ~= nil then
local qdmg = getDmg("Q", heroManager:GetHero(i), myHero)
local wdmg = getDmg("W", heroManager:GetHero(i), myHero)
local edmg = getDmg("E", heroManager:GetHero(i), myHero)
if Qr and (targetPOS ~= nil and GetDistance(targetPOS) < SpellRange.Range and HitChance > 0) and heroManager:GetHero(i).health < qdmg then
	CastSpell(_Q, targetPOS.x, targetPOS.z)
end
	if Wr and GetDistance(ts.target) <= Wrange and heroManager:GetHero(i).health < wdmg then
				CastSpell(_W, ts.target)
			end
		if Er and GetDistance(ts.target) <= Erange and heroManager:GetHero(i).health < edmg then
				CastSpell(_E, ts.target)
			end
		end
	end
end
end

function Qcastnearshop( ... )
	-- body
	for slot = ITEM_1, ITEM_7 do
	if GetDistance(shop) < 1250 and myHero:GetSpellData(slot).name:find("TearsDummySpell") and Config.autotears.uset then
		if Qr then
			CastSpell(_Q, math.random(50,1000),math.random(50,1000))
		end
	end
	if myHero:GetSpellData(slot).name:find("TearsDummySpell") then
		tearsslot = slot
	end
	if myHero:GetSpellData(tearsslot).name:find("TearsDummySpell") then
		hastears = true
	else
		hastears = false
	end
	end
end

function Farm( ... )
	-- body
	for i, minion in pairs(EnemyMinions.objects) do
			local qdmgmin = getDmg("Q", minion, myHero)
			local AAdmg = getDmg("AD", minion, myHero)
			local castPosmin, HitChance, Position = VP:GetLineCastPosition(minion, 0.46, 50, 900, 1400, myHero, true)
			if isrecalling == false then
						if Qr and Config.Fmr.farmmode == 2 then
	if (castPosmin ~= nil and GetDistance(castPosmin)<SpellRange.Range and HitChance > 0) then
				if minion ~= nil and not minion.dead and minion.visible and minion.health <= qdmgmin and ValidTarget(minion) then
		CastSpell(_Q, castPosmin.x, castPosmin.z)
		end
		end
		end
								if Qr and Config.Fmr.farmmode == 3 and hastears then
	if (castPosmin ~= nil and GetDistance(castPosmin)<SpellRange.Range and HitChance > 0) then
				if minion ~= nil and not minion.dead and minion.visible and minion.health <= qdmgmin and ValidTarget(minion) then
		CastSpell(_Q, castPosmin.x, castPosmin.z)
		end
		end
		end
		if not Qr then
		if minion ~= nil and not minion.dead and minion.visible and minion.health <= AAdmg and GetDistance(minion) <= AArange and ValidTarget(minion) then 
			myHero:Attack(minion)
		end
end
						if Qr then
	if (castPosmin ~= nil and GetDistance(castPosmin)<SpellRange.Range and HitChance < 0) then
				if minion ~= nil and not minion.dead and minion.visible and minion.health <= AAdmg and GetDistance(minion) <= AArange and ValidTarget(minion) then
					myHero:Attack(minion)
				end
			end
		end
	end
	end
end


function Menu( ... )
	-- body
	Config = scriptConfig("Carty's Ryze", "CartyRyze")
	Config:addSubMenu("Keys", "Key")
Config.Key:addParam("keycombo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
Config.Key:addParam("keyfarm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("F"))

Config:addSubMenu("Combo", "Cmo") 
Config.Cmo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.Cmo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.Cmo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.Cmo:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Farm", "Fmr") 
Config.Fmr:addParam("farmmode", "Use Q Mode", SCRIPT_PARAM_LIST, 3, { "No Cast", "Always", "Only with Tears"})

Config:addSubMenu("Auto Ignite", "autoI") 
Config.autoI:addParam("usei", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Auto Steal", "autoS") 
Config.autoS:addParam("uses", "Auto Steal", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Auto Level", "autoL") 
Config.autoL:addParam("usel", "Auto Level", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Stack Tears", "autotears") 
Config.autotears:addParam("uset", "Stack Tears", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Drawing", "draw") 
Config.draw:addParam("drawq", "Q Range", SCRIPT_PARAM_ONOFF, true)
Config.draw:addParam("drawwe", "W/E Range", SCRIPT_PARAM_ONOFF, true)
Config.draw:addParam("drawenemy", "Enemy Kill Draw", SCRIPT_PARAM_ONOFF, true)
Config.draw:addParam("drawminion", "Minion Last Hit", SCRIPT_PARAM_ONOFF, true)


end


function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then 
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end 
	end
end


function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 120)
end 
 
function timeToShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()* (300 + GetLatency())
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end
