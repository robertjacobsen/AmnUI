local PositionFrames = function() 
	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint("CENTER", nil, "CENTER", -150, -180)
	PlayerFrame:SetScale(1.3)

	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 50, 0)
	TargetFrame:SetScale(1.3)

	PartyMemberFrame1:ClearAllPoints()
	PartyMemberFrame1:SetPoint("LEFT", TargetFrame, "RIGHT", 50, 0)

	for i = 1,4 do
		getglobal("PartyMemberFrame" .. i):SetScale(1.3)
	end
end




local AMNUF_DEFAULT_FONT_NAME, AMNUF_DEFAULT_FONT_SIZE = GameFontNormalSmall:GetFont()

local unitframes = CreateFrame"Frame"
unitframes:RegisterEvent"UNIT_HEALTH"
unitframes:RegisterEvent"UNIT_MANA"
unitframes:RegisterEvent"UNIT_RAGE"
unitframes:RegisterEvent"UNIT_ENERGY"
unitframes:RegisterEvent"UNIT_FOCUS"
unitframes:RegisterEvent"PLAYER_ENTERING_WORLD"
unitframes:RegisterEvent"PLAYER_TARGET_CHANGED"
unitframes:RegisterEvent"PLAYER_LOGIN"
unitframes:SetScript("OnEvent", function (self, event, unit) 
	self[event](unit)
end)

local bars = {
	["PlayerFrameHealthBar"] = "PlayerFrameHealthText",
	["PlayerFrameManaBar"] = "PlayerFrameManaText",
	["TargetFrameHealthBar"] = "TargetFrameHealthText",
	["TargetFrameManaBar"] = "TargetFrameManaText",
}

local Update = function (unit) 
	if unit ~= "player" and unit ~= "target" then return end
	local health = ""
	if not UnitIsDead(unit) then
		health = string.format("%d / %d (%d%%)", UnitHealth(unit), UnitHealthMax(unit), math.ceil(100 * UnitHealth(unit) / UnitHealthMax(unit)))
	end

	-- Bah, Lua sucks sometimes.
	local mpper = 0
	if UnitMana(unit) > 0 then
		mpper = math.ceil(100 * UnitMana(unit) / UnitManaMax(unit))
	end

	local mana = string.format("%d / %d (%d%%)", UnitMana(unit), UnitManaMax(unit), mpper)
	if unit == "player" then
		getglobal("PlayerFrameHealthText"):SetText(health)
		getglobal("PlayerFrameManaText"):SetText(mana)
	else
		getglobal("TargetFrameHealthText"):SetText(health)
		getglobal("TargetFrameManaText"):SetText(mana)
	end
end

unitframes.PLAYER_LOGIN = function() 
	if not AmnUI then 
		AmnUI = {
			UnitFrames = {}
		}
	end
	
	-- If the database isn't initialized, initialize it with default values
	if not AmnUI.UnitFrames.FontSize then 
		AmnUI.UnitFrames.FontSize = AMNUF_DEFAULT_FONT_SIZE
	end

	if not AmnUI.UnitFrames.Reposition then
		AmnUI.UnitFrames.Reposition = true
	end

	if AmnUI.UnitFrames.Reposition then
		PositionFrames()
	end

	for parent, child in pairs(bars) do
		local frame = CreateFrame("Frame", nil, getglobal(parent:sub(1,11)))
		frame:SetFrameStrata"HIGH"
		frame:CreateFontString(child)
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, AmnUI.UnitFrames.FontSize)
		getglobal(child):SetShadowOffset(1, -1)
		getglobal(child):SetPoint("CENTER", getglobal(parent), "CENTER", -1, 0)
	end
end

unitframes.PLAYER_ENTERING_WORLD = function ()
	Update"player"
end
unitframes.PLAYER_TARGET_CHANGED = function ()
	Update"target"
end
unitframes.UNIT_HEALTH = Update
unitframes.UNIT_MANA = Update
unitframes.UNIT_FOCUS = Update
unitframes.UNIT_ENERGY = Update
unitframes.UNIT_RAGE = Update

-- Hide old strings.
local frames = { PlayerFrameHealthBarText, PlayerFrameManaBarText, TargetFrameTextureFrameHealthBarText, TargetFrameTextureFrameManaBarText }
for i, _ in pairs(frames) do
	frames[i]:Hide()
	frames[i].Show = function() end
end

local Print = function(text) 
	ChatFrame1:AddMessage(string.format("|cff33ff99AmnUF|r: %s", text))
end

local Help = function() 
	Print("Usage is /amnuf <command> <argument>.")
	Print(string.format("/amnuf size <number> sets the font size. Current value: [%d]", AmnUI.UnitFrames.FontSize))
	Print("/amnuf reposition toggles whether or not the unitframes will be repositioned.")
end

local UpdateFontSizes = function() 
	for parent, child in pairs(bars) do
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, AmnUI.UnitFrames.FontSize)
	end
end

-- A basic slash handler
SlashCmdList['AMNUF'] = function (arguments) 
	if not arguments then return Help() end

	local args = {}
	local i = 0;
	for k in arguments:gmatch'(%w+)' do
		args[i] = k;
		i = i + 1
	end
	if args[0] == 'size' then
		if not args[1] then return Help() end
		local value = tonumber(args[1]) or 0
		if value >= 8 and value <= 20 then
			AmnUI.UnitFrames.FontSize = argument
			UpdateFontSizes()
			return
		end
	elseif args[0] == 'reposition' then
		AmnUI.UnitFrames.Reposition = not AmnUI.UnitFrames.Reposition
		Print(string.format("UnitFrame reposition is now %s", tostring(AmnUI.UnitFrames.Reposition)))
		return
	end
	Help()
end
SLASH_AMNUF1 = '/amnuf'
