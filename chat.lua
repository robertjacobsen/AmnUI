local addon, ns = ...

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

ChatPanel.Draw()

ns.ChatPanel = ChatPanel

-- Fix the fonts. 
ChatFontNormal:SetFont(select(1, ChatFontNormal:GetFont()), 16)
SystemFont_Shadow_Small:SetFont(select(1, SystemFont_Shadow_Small:GetFont()), 11)
CHAT_FONT_HEIGHTS = {
    [1] = 10, 
    [2] = 12,
    [3] = 13, 
    [4] = 14,
    [5] = 16
}
