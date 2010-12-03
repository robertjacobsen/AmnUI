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
		_G["PartyMemberFrame" .. i]:SetScale(db.UnitFrames.Scale)
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
		PlayerFrameHealthText:SetText(health)
		PlayerFrameManaText:SetText(mana)
	else
		TargetFrameHealthText:SetText(health)
		TargetFrameManaText:SetText(mana)
	end
end

UnitFrames.Enable = function() 
	UnitFrames.Position()
	UnitFrames.Scale()

	for parent, child in pairs(UnitFrames.bars) do
		local frame = CreateFrame("Frame", nil, _G[parent:sub(1,11)])
		frame:SetFrameStrata"HIGH"
		frame:CreateFontString(child)
		_G[child]:SetFont(AMNUF_DEFAULT_FONT_NAME, db.UnitFrames.FontSize)
		_G[child]:SetShadowOffset(1, -1)
		_G[child]:SetPoint("CENTER", _G[parent], "CENTER", -1, 0)
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
		_G[child]:SetFont(AMNUF_DEFAULT_FONT_NAME, db.UnitFrames.FontSize)
	end
end

AmnUI.UnitFrames = UnitFrames

--[[ ChatPanel specific code ]]
local ChatPanel = CreateFrame"Frame"
ChatPanel.colors = { tBlack = {r = 0, g = 0, b = 0, a = 0.7},
	    	     	 sBlack = {r = 0, g = 0, b = 0, a = 1},
		    		 tBlue  = {r = 0.243, g = 0.298, b = 0.345, a = 0.7}, }

ChatPanel.FixChat = function()
	if not ChatPanel.Frame then return end
        for i = 1,7 do
                for k,v in pairs(CHAT_FRAME_TEXTURES) do
                        _G["ChatFrame"..i..v]:Hide()
                end
        end
        
        for k in pairs(CHAT_FRAME_TEXTURES) do
                CHAT_FRAME_TEXTURES[k] = nil
        end
end

ChatPanel.MakeFrame = function(color) 
        local frame = CreateFrame("Frame", nil, UIParent)

        frame:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
                insets = {left = 0, right = 0, top = 0, bottom = 0},
        })
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

	local width = ChatFrame1:GetWidth()
	local height = ChatFrame1:GetHeight()

	local cf = ChatPanel.MakeFrame(ChatPanel.colors.tBlack)
	cf:SetPoint("TOP", ChatFrame1, "TOP", 0, 1)
	cf:SetPoint("LEFT", ChatFrame1, "LEFT", -2, 0)
	cf:SetPoint("RIGHT", ChatFrame1, "RIGHT", 2, 0)
	cf:SetPoint("BOTTOM", ChatFrame1, "BOTTOM", 0, -2)

   	cf.l = ChatPanel.MakeFrame(ChatPanel.colors.tBlue) 
	cf.l:SetPoint("RIGHT", cf, "LEFT")
	cf.l:SetPoint("TOP", cf)
	cf.l:SetPoint("BOTTOM", cf)
	cf.l:SetWidth(2)

	cf.r = ChatPanel.MakeFrame(ChatPanel.colors.tBlue) 
	cf.r:SetPoint("LEFT", cf, "RIGHT")
	cf.r:SetPoint("TOP", cf)
	cf.r:SetPoint("BOTTOM", cf)
	cf.r:SetWidth(2)

	cf.u = ChatPanel.MakeFrame(ChatPanel.colors.tBlue) 
	cf.u:SetPoint("BOTTOM", cf, "TOP")
	cf.u:SetPoint("LEFT", cf, -2, 0)
	cf.u:SetPoint("RIGHT", cf, 2, 0)
	cf.u:SetHeight(2)

	cf.b = ChatPanel.MakeFrame(ChatPanel.colors.tBlue) 
	cf.b:SetPoint("TOP", cf, "BOTTOM")
	cf.b:SetPoint("LEFT", cf, -2, 0)
	cf.b:SetPoint("RIGHT", cf, 2, 0)
	cf.b:SetHeight(2)
	
	ChatPanel.Frame = cf

	ChatPanel.FixChat()
end

AmnUI.ChatPanel = ChatPanel

local ActionBars = CreateFrame"Frame"

ActionBars.Page = {
    ["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
    ["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
    ["PRIEST"] = "[bonusbar:1] 7;",
    ["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
    ["WARLOCK"] = "[form:2] 7;",
    ["DEFAULT"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;",
}
  
ActionBars.GetBar = function()
    local condition = ActionBars.Page["DEFAULT"]
    local class = select(2, UnitClass"player") 
    local page = ActionBars.Page[class]
    if page then
      if class == "DRUID" then
        -- Handles prowling, prowling has no real stance, so this is a hack which utilizes the Tree of Life bar for non-resto druids.
        if IsSpellKnown(33891) then -- Tree of Life form
          page = page:format(7)
        else
          page = page:format(8)
        end
      end
      condition = condition.." "..page
    end
    condition = condition.." 1"
    return condition
end

ActionBars.RemoveTextures = function()
	local FramesToHide = {
    	MainMenuBar, 
    	MainMenuBarArtFrame, 
    	BonusActionBarFrame, 
    	VehicleMenuBar,
    	PossessBarFrame,
  	}  

	for _, f in pairs(FramesToHide) do
    	if f:GetObjectType() == "Frame" then
    		f:UnregisterAllEvents()
    	end
    	f:HookScript("OnShow", function(s) s:Hide(); end)
    	f:Hide()
  	end
end

ActionBars.MoveBars = function() 
	local actionbars = {}
	local names = {
		[1] = "MainMenuBar",
		[2] = "MultiBarBottomLeft",
		[3] = "MultiBarBottomRight"
	}

	for i = 1,3 do
		local bar = CreateFrame("Frame", "AmnUI_"..names[i], UIParent, "SecureHandlerStateTemplate")
		actionbars[i] = bar
		bar:SetWidth(35*12)
		bar:SetHeight(35)
		bar:SetScale(1.2)
		if i == 1 then 
			bar:SetPoint("BOTTOM", UIParent) 
		else
			bar:SetPoint("BOTTOM", actionbars[i-1], "TOP")
		end
		_G[names[i]]:SetParent(bar)
		
		if i == 1 then
			for j = 1, NUM_ACTIONBAR_BUTTONS do
				bar:SetFrameRef("ActionButton"..j, _G["ActionButton"..j])
			end

			local button, buttons
			bar:Execute([[
				buttons = table.new()
				for j = 1, 12 do
					table.insert(buttons, self:GetFrameRef("ActionButton"..j))
				end
			]])

			bar:SetAttribute("_onstate-page", [[
				for _, button in ipairs(buttons) do 
					button:SetAttribute("actionpage", tonumber(newstate))
				end
			]])

			RegisterStateDriver(bar, "page", ActionBars.GetBar())
		end

		local prefix = names[i]
		if names[i] == "MainMenuBar" then
			prefix = "Action"
		end

		for j = 1, 12 do
			local name = prefix.."Button"..j
			local button = _G[name]
			button:SetSize(35,35)
			button:ClearAllPoints()
			
			-- Fix icon
			local icon = _G[name.."Icon"]
			icon:SetTexCoord(.07, .93, .07, .93)
			icon:SetAllPoints(button)
			
			-- TODO: Fix border
			local border = _G[name.."Border"]		
			border:Hide()
			border.Show = function() end
			
			local nt = _G[name.."NormalTexture"]
			nt:ClearAllPoints()
			nt:Hide()
			nt:SetAlpha(0)
			nt.SetAlpha = function() end
			nt.Show = function() end

			local hk = _G[name.."HotKey"]
			hk:Hide()
			hk.MyShow = hk.Show
			hk.Show = function() end

			local nm = _G[name.."Name"]
			nm:Hide()
			
			local oe = button:GetScript"OnEnter"
			local ol = button:GetScript"OnLeave"
			button:SetScript("OnEnter", function(...) hk:MyShow() oe(...) end)
			button:SetScript("OnLeave", function(...) hk:Hide() oe(...) end)
			
			if i == 1 then
				button:SetParent(bar)
			end

			if j == 1 then
				button:SetPoint("BOTTOMLEFT", bar)
			else
				button:SetPoint("LEFT", _G[prefix.."Button"..j-1], "RIGHT", 0, 0)
			end
		end
	end
end

ActionBars.ImAShaman = function()
	local bar = _G['MultiCastActionBarFrame']
	if bar then
		local container = CreateFrame("Frame","AmnUI_TotemBar",UIParent, "SecureHandlerStateTemplate")
		container:SetWidth(bar:GetWidth())
		container:SetHeight(bar:GetHeight())
	  
	  	bar:SetParent(container)
		bar:SetAllPoints(container)
		
		hooksecurefunc(bar, "SetPoint", function() bar:SetAllPoints(container) end)
		container:SetPoint("BOTTOMRIGHT", UIParent)
		
		container:SetScale(1.2)

		bar:SetMovable(true)
		bar:SetUserPlaced(true)
		bar:EnableMouse(false)
	end
end

ActionBars.Enable = function() 
	ActionBars.RemoveTextures()
	ActionBars.MoveBars()
	if select(2, UnitClass"player") == "SHAMAN" then
		ActionBars.ImAShaman()
	end
end

AmnUI.ActionBars = ActionBars

local CastBar = CreateFrame"Frame"

CastBar.Enable = function() 
	local cb = CastingBarFrame	
	cb:ClearAllPoints()
	cb:SetPoint("BOTTOM", UIParent, 0, 150)
	cb.SetPoint = function() end
end

AmnUI.CastBar = CastBar


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
	AmnUI.ActionBars.Enable()
	AmnUI.CastBar.Enable()
end

-- A basic slash handler
UnitFrames.Help = function() 
	Print("Usage is /amnui uf <command> <argument>.")
	Print(string.format("/amnui uf size <number> - Sets the font size. Current size: [%d]", db.UnitFrames.FontSize))
	Print(string.format("/amnui uf pos - Toggles whether or not the unit frames will be repositioned. [%s]", tostring(db.UnitFrames.Reposition)))
	Print(string.format("/amnui uf scale <decimal> - Sets the scale of the unit frames. Current scale: [%.1f]", db.UnitFrames.Scale))
end

AmnUI.Help = function()
	Print("Usage is /amnui <module> <command> <argument>.")
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
	end
	AmnUI.Help()
end
SLASH_AMNUI1 = '/amnui'

SlashCmdList['AMNUI_RELOAD'] = ReloadUI
SLASH_AMNUI_RELOAD1 = '/rl'
