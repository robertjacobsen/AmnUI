local panel = CreateFrame("BUTTON", nil, UIParent)
--[[
 Function FixChat
-- A function that removes the textures from the ChatFrames.
--]]
local FixChat = function()
        for i = 1,7 do
                for k,v in pairs(CHAT_FRAME_TEXTURES) do
                        getglobal("ChatFrame"..i..v):Hide()
                end
        end
        
        for k in pairs(CHAT_FRAME_TEXTURES) do
                CHAT_FRAME_TEXTURES[k] = nil
        end
end

--[[
 Function MakeFrame 
-- The function that makes a frame with the given options taken from the arguments
-- Parameters:
-- name - Name of the frame
-- width - The width of the frame
-- height - The height of the frame
-- r - Amount of red in the colour of the frame
-- g - Amount of green in the colour of the frame
-- b - Amount of blue in the colour of the frame
-- a - Alpha (transparency) of the frame
--]]
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

panel.sizes = { width = 450, height = 280 }

panel:RegisterEvent("PLAYER_LOGIN")
panel:SetScript("OnEvent", function(self) 
        --[[ The left end side of the screen, chat frames etc ]]
		
		local colors = {
			tBlack = {r = 0, g = 0, b = 0, a = 0.7},
			sBlack = {r = 0, g = 0, b = 0, a = 1},
			tBlue = {r = 0.243, g = 0.298, b = 0.345, a = 0.7},
		}


        local cf = MakeFrame(panel.sizes.width, panel.sizes.height, colors.tBlack) 
        cf:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 45, 50)
        FixChat() -- We don't like textures!

        local cful = MakeFrame(2, panel.sizes.height + 2, colors.tBlue) 
        cful:SetPoint("RIGHT", cf, "LEFT")

        local cfur = MakeFrame(2, panel.sizes.height + 2, colors.tBlue) 
        cfur:SetPoint("LEFT", cf, "RIGHT")

        local cfut = MakeFrame(panel.sizes.width + 4, 2, colors.tBlue) 
        cfut:SetPoint("BOTTOM", cf, "TOP")

        local cfub = MakeFrame(panel.sizes.width + 4, 2, colors.tBlue) 
        cfub:SetPoint("TOP", cf, "BOTTOM")
        
        ChatFrame1:SetWidth(panel.sizes.width)
        ChatFrame1:ClearAllPoints()
		ChatFrame1:SetUserPlaced(true)
        ChatFrame1:SetPoint("BOTTOM", cf, 0, 3)
        ChatFrame1:SetPoint("TOP", cf, 0, -3)
        ChatFrame1:SetPoint("LEFT", cf, 3, 0)
        ChatFrame1:SetPoint("RIGHT", cf, -3, 0)
        FCF_SetLocked(ChatFrame1, 1)
end)
