local panel = CreateFrame("BUTTON", nil, UIParent)

-- Define configuration
panel.sizes = { width = 450, 
		height = 280, }

panel.colors = { tBlack = {r = 0, g = 0, b = 0, a = 0.7},
		 sBlack = {r = 0, g = 0, b = 0, a = 1},
		 tBlue  = {r = 0.243, g = 0.298, b = 0.345, a = 0.7}, }

local FixChat = function()
        for i = 1,7 do
                for k,v in pairs(CHAT_FRAME_TEXTURES) do
                        getglobal("ChatFrame"..i..v):Hide()
                end
        end
        
        for k in pairs(CHAT_FRAME_TEXTURES) do
                CHAT_FRAME_TEXTURES[k] = nil
        end

        ChatFrame1:SetWidth(panel.sizes.width)
        ChatFrame1:ClearAllPoints()
	ChatFrame1:SetUserPlaced(true)
        ChatFrame1:SetPoint("BOTTOM", panel.chatframe, 0, 3)
        ChatFrame1:SetPoint("TOP", panel.chatframe, 0, -3)
        ChatFrame1:SetPoint("LEFT", panel.chatframe, 3, 0)
        ChatFrame1:SetPoint("RIGHT", panel.chatframe, -3, 0)
        FCF_SetLocked(ChatFrame1, 1)
end

local MakeFrame = function(width, height, c) 
        local frame = CreateFrame("Frame", nil, UIParent)

        frame:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
                insets = {left = 0, right = 0, top = 0, bottom = 0},
        })
        frame:SetHeight(height)
        frame:SetWidth(width)
        frame:SetBackdropColor(c.r, c.g, c.b, c.a)
        frame:SetBackdropBorderColor(0, 0, 0, 0)
        frame:SetFrameStrata"BACKGROUND"
        return frame
end

panel:RegisterEvent"PLAYER_LOGIN"
panel:RegisterEvent"UI_SCALE_CHANGED"
panel:RegisterEvent"DISPLAY_SIZE_CHANGED"

panel:SetScript("OnEvent", function(self, event, ...) 
	self[event](...)
end)

panel.UI_SCALE_CHANGED = FixChat
panel.DISPLAY_SIZE_CHANGED = FixChat
panel.PLAYER_LOGIN = function() 
	--[[ The left end side of the screen, chat frames etc ]]
        panel.chatframe = MakeFrame(panel.sizes.width, panel.sizes.height, panel.colors.tBlack) 
        panel.chatframe:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 45, 50)
        FixChat() -- We don't like textures!

        local cful = MakeFrame(2, panel.sizes.height + 2, panel.colors.tBlue) 
        cful:SetPoint("RIGHT", panel.chatframe, "LEFT")

        local cfur = MakeFrame(2, panel.sizes.height + 2, panel.colors.tBlue) 
        cfur:SetPoint("LEFT", panel.chatframe, "RIGHT")

        local cfut = MakeFrame(panel.sizes.width + 4, 2, panel.colors.tBlue) 
        cfut:SetPoint("BOTTOM", panel.chatframe, "TOP")

        local cfub = MakeFrame(panel.sizes.width + 4, 2, panel.colors.tBlue) 
        cfub:SetPoint("TOP", panel.chatframe, "BOTTOM")
end
