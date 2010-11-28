local db
local AMNUF_DEFAULT_FONT_NAME, AMNUF_DEFAULT_FONT_SIZE = GameFontNormalSmall:GetFont()
AmnUI = CreateFrame"Frame"

local Print = function(text) 
	ChatFrame1:AddMessage(string.format("|cff33ff99AmnUI|r: %s", text))
end

--[[ UnitFrame specific code ]]

local UnitFrames = CreateFrame"Frame"
UnitFrames:RegisterEvent"UNIT_HEALTH"
UnitFrames:RegisterEvent"UNIT_POWER"
UnitFrames:RegisterEvent"PLAYER_ENTERING_WORLD"
UnitFrames:RegisterEvent"PLAYER_TARGET_CHANGED"
UnitFrames:SetScript("OnEvent", function (self, event, ...) 
	self[event](self, event, ...)
end)


UnitFrames.Position = function(self)
	PlayerFrame:ClearAllPoints()
	TargetFrame:ClearAllPoints()
	PartyMemberFrame1:ClearAllPoints()

	if db.UnitFrames.Reposition then 
		PlayerFrame:SetPoint("CENTER", UIParent, "CENTER", -150, -180)
		TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 50, 0)
		PartyMemberFrame1:SetPoint("LEFT", TargetFrame, "RIGHT", 50, 0)
	else
		PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4)
		TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4)
		PartyMemberFrame1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -160)
	end
end

UnitFrames.Scale = function(self)
	TargetFrame:SetScale(db.UnitFrames.Scale)
	PlayerFrame:SetScale(db.UnitFrames.Scale)
	for i = 1,4 do
		getglobal("PartyMemberFrame" .. i):SetScale(db.UnitFrames.Scale)
	end
end

UnitFrames.bars = {
	["PlayerFrameHealthBar"] = "PlayerFrameHealthText",
	["PlayerFrameManaBar"] = "PlayerFrameManaText",
	["TargetFrameHealthBar"] = "TargetFrameHealthText",
	["TargetFrameManaBar"] = "TargetFrameManaText",
}

UnitFrames.Update = function(self, event, unit)
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

UnitFrames.Enable = function() 
	UnitFrames.Position()
	UnitFrames.Scale()

	for parent, child in pairs(UnitFrames.bars) do
		local frame = CreateFrame("Frame", nil, getglobal(parent:sub(1,11)))
		frame:SetFrameStrata"HIGH"
		frame:CreateFontString(child)
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, db.UnitFrames.FontSize)
		getglobal(child):SetShadowOffset(1, -1)
		getglobal(child):SetPoint("CENTER", getglobal(parent), "CENTER", -1, 0)
	end

	-- Hide old strings.
	local frames = { PlayerFrameHealthBarText, PlayerFrameManaBarText, TargetFrameTextureFrameHealthBarText, TargetFrameTextureFrameManaBarText }
	for i, _ in pairs(frames) do
		frames[i]:Hide()
		frames[i].Show = function() end
	end
end

UnitFrames.PLAYER_ENTERING_WORLD = function (self, event)
	self.Update(self, event, "player")
end

UnitFrames.PLAYER_TARGET_CHANGED = function (self, event)
	self.Update(self, event, "target")
end
UnitFrames.UNIT_HEALTH = UnitFrames.Update
UnitFrames.UNIT_POWER = UnitFrames.Update

UnitFrames.UpdateFontSizes = function() 
	for parent, child in pairs(UnitFrames.bars) do
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, db.UnitFrames.FontSize)
	end
end

AmnUI.UnitFrames = UnitFrames

--[[ ChatPanel specific code ]]
local ChatPanel = CreateFrame"Frame"
ChatPanel:RegisterEvent"UI_SCALE_CHANGED"
ChatPanel:RegisterEvent"DISPLAY_SIZE_CHANGED"
ChatPanel:SetScript("OnEvent", function(self, event, ...) 
	self[event](self, event, ...)
end)

ChatPanel.colors = { tBlack = {r = 0, g = 0, b = 0, a = 0.7},
	    	     sBlack = {r = 0, g = 0, b = 0, a = 1},
		     tBlue  = {r = 0.243, g = 0.298, b = 0.345, a = 0.7}, }

ChatPanel.FixChat = function()
	if not ChatPanel.Frame then return end
        for i = 1,7 do
                for k,v in pairs(CHAT_FRAME_TEXTURES) do
                        getglobal("ChatFrame"..i..v):Hide()
                end
        end
        
        for k in pairs(CHAT_FRAME_TEXTURES) do
                CHAT_FRAME_TEXTURES[k] = nil
        end

        ChatFrame1:ClearAllPoints()
	ChatFrame1:SetUserPlaced(true)
        ChatFrame1:SetPoint("BOTTOM", ChatPanel.Frame, 0, 3)
        ChatFrame1:SetPoint("TOP", ChatPanel.Frame, 0, -3)
        ChatFrame1:SetPoint("LEFT", ChatPanel.Frame, 3, 0)
        ChatFrame1:SetPoint("RIGHT", ChatPanel.Frame, -3, 0)
        FCF_SetLocked(ChatFrame1, 1)
end

ChatPanel.MakeFrame = function(width, height, color) 
        local frame = CreateFrame"Frame"

        frame:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
                insets = {left = 0, right = 0, top = 0, bottom = 0},
        })
        frame:SetHeight(height)
        frame:SetWidth(width)
        frame:SetBackdropColor(color.r, color.g, color.b, color.a)
        frame:SetBackdropBorderColor(0, 0, 0, 0)
        frame:SetFrameStrata"BACKGROUND"
        return frame
end

ChatPanel.Enable = function()
	ChatPanel.Draw()
end

ChatPanel.Draw = function() 
	if ChatPanel.Frame then 
		ChatPanel.Frame.u:Hide()
		ChatPanel.Frame.r:Hide()
		ChatPanel.Frame.l:Hide()
		ChatPanel.Frame.b:Hide()
		ChatPanel.Frame:Hide()
		ChatPanel.Frame = nil 
	end
	local cf = ChatPanel.MakeFrame(db.ChatPanel.Width, db.ChatPanel.Height, ChatPanel.colors.tBlack)
	cf:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 45, 50)

   	cf.u = ChatPanel.MakeFrame(2, db.ChatPanel.Height + 2, ChatPanel.colors.tBlue) 
	cf.u:SetPoint("RIGHT", cf, "LEFT")

    cf.r = ChatPanel.MakeFrame(2, db.ChatPanel.Height + 2, ChatPanel.colors.tBlue) 
	cf.r:SetPoint("LEFT", cf, "RIGHT")

    cf.l = ChatPanel.MakeFrame(db.ChatPanel.Width + 4, 2, ChatPanel.colors.tBlue) 
	cf.l:SetPoint("BOTTOM", cf, "TOP")

    cf.b = ChatPanel.MakeFrame(db.ChatPanel.Width + 4, 2, ChatPanel.colors.tBlue) 
	cf.b:SetPoint("TOP", cf, "BOTTOM")
	
	ChatPanel.Frame = cf

	ChatPanel.FixChat()
end

ChatPanel.UI_SCALE_CHANGED = ChatPanel.FixChat
ChatPanel.DISPLAY_SIZE_CHANGED = ChatPanel.FixChat

AmnUI.ChatPanel = ChatPanel

AmnUI:RegisterEvent"ADDON_LOADED"
AmnUI:RegisterEvent"PLAYER_LOGIN"
AmnUI:SetScript("OnEvent", function (self, event, ...) 
	self[event](self, event, ...)
end)

AmnUI.ADDON_LOADED = function(self, event, addon) 
	if addon == "AmnUI" then
		db = AmnUIDB
		if not db then
			db = {
				ChatPanel = {
					Width = 450,
					Height = 280,
				},
				UnitFrames = {	
					FontSize = AMNUF_DEFAULT_FONT_SIZE,
					Reposition = true,
					Scale = 1.3,
				},
			}
			AmnUIDB = db 
		end
	end
end

AmnUI.PLAYER_LOGIN = function(self, event, ...)
	AmnUI.UnitFrames.Enable()
	AmnUI.ChatPanel.Enable()
end

-- A basic slash handler
UnitFrames.Help = function() 
	Print("Usage is /amnui uf <command> <argument>.")
	Print(string.format("/amnui uf size <number> - Sets the font size. Current size: [%d]", db.UnitFrames.FontSize))
	Print(string.format("/amnui uf pos - Toggles whether or not the unit frames will be repositioned. [%s]", tostring(db.UnitFrames.Reposition)))
	Print(string.format("/amnui uf scale <decimal> - Sets the scale of the unit frames. Current scale: [%.1f]", db.UnitFrames.Scale))
end

ChatPanel.Help = function()
	Print("Usage is /amnui chat <command> <argument>.")
	Print(string.format("/amnui chat width <number> - Sets the frame's width. Current width: [%d]", db.ChatPanel.Width))
	Print(string.format("/amnui chat height <number> - Sets the frame's height. Current height: [%d]", db.ChatPanel.Height))
end

AmnUI.Help = function()
	Print("Usage is /amnui <module> <command> <argument>.")
	Print("/amnui chat - Chat Frame configurations.")
	Print("/amnui uf - Unit Frame configurations.")
end

SlashCmdList['AMNUI'] = function (arguments) 
	if not arguments then return AmnUI.Help() end

	local args = {}
	local i = 0;
	for k in arguments:gmatch'([%S]+)' do
		args[i] = k;
		i = i + 1
	end
	if args[0] == 'uf' then
		if args[1] == 'size' then
			if not args[2] then return UnitFrames.Help() end
			local value = tonumber(args[2]) or 0
			if value >= 8 and value <= 20 then
				db.UnitFrames.FontSize = value
				UnitFrames.UpdateFontSizes()
				return
			end
		elseif args[1] == 'pos' then
			db.UnitFrames.Reposition = not db.UnitFrames.Reposition
			Print(string.format("UnitFrame reposition is now %s", tostring(db.UnitFrames.Reposition)))
			UnitFrames.Position()
			return
		elseif args[1] == 'scale' then
			if not args[2] then return UnitFrames.Help() end
			local value = tonumber(args[2])
			if value >= 0.7 and value <= 20 then
				db.UnitFrames.Scale = value
				UnitFrames.Scale()
				return
			end
		end
		return UnitFrames.Help()
	elseif args[0] == 'chat' then
		if not args[1] or not args[2] then return ChatPanel.Help() end
		local value = tonumber(args[2])
		if args[1] == 'width' then
			if value <= 1000 and value >= 100 then
				db.ChatPanel.Width = value
				ChatPanel.Draw()
				return
			end
		elseif args[1] == 'height' then
			if value <= 600 and value >= 50 then
				db.ChatPanel.Height = value
				ChatPanel.Draw()
				return
			end
		end
	end
	AmnUI.Help()
end
SLASH_AMNUI1 = '/amnui'

SlashCmdList['AMNUI_RELOAD'] = ReloadUI
SLASH_AMNUI_RELOAD1 = '/rl'
