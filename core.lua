local addon, ns = ...
local db

function ns:Print(text) 
    ChatFrame1:AddMessage(string.format("|cff33ff99AmnUI|r: %s", text))
end

local AmnUI = CreateFrame"Frame"
AmnUI:RegisterEvent"ADDON_LOADED"
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

AmnUI.Help = function()
	ns:Print("Usage is /amnui <module> <command> <argument>.")
	ns:Print("/amnui uf - Unit Frame configurations.")
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
			if not args[2] then return ns.UnitFrames.Help() end
			local value = tonumber(args[2]) or 0
			if value >= 8 and value <= 20 then
				db.UnitFrames.FontSize = value
				ns.UnitFrames.UpdateFontSizes()
				return
			end
		elseif args[1] == 'pos' then
			db.UnitFrames.Reposition = not db.UnitFrames.Reposition
			ns:Print(string.format("UnitFrame reposition is now %s", tostring(db.UnitFrames.Reposition)))
			ns.UnitFrames.Position()
			return
		elseif args[1] == 'scale' then
			if not args[2] then return UnitFrames.Help() end
			local value = tonumber(args[2])
			if value >= 0.7 and value <= 20 then
				db.UnitFrames.Scale = value
				ns.UnitFrames.Scale()
				return
			end
		end
		return ns.UnitFrames.Help()
	end
	AmnUI.Help()
end
SLASH_AMNUI1 = '/amnui'

SlashCmdList['AMNUI_RELOAD'] = ReloadUI
SLASH_AMNUI_RELOAD1 = '/rl'
