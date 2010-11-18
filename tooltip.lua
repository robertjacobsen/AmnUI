hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, self)
 	tooltip:SetOwner(self, 'ANCHOR_CURSOR')
end)	

local backdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
}

for i = 1, NUM_CONTAINER_FRAMES do
        local f = _G["ContainerFrame"..i]
        f:SetBackdrop(backdrop)
        f:SetBackdropBorderColor(.5, .5, .5, 1)
        f:SetBackdropColor(0, 0, 0, .9)
        local fade = f:CreateTexture(nil, "BORDER")
        fade:SetTexture"Interface\\ChatFrame\\ChatFrameBackground"
        fade:SetPoint("TOP", f, 0, -4)
        fade:SetPoint("LEFT", f, 4, 0)
        fade:SetPoint("RIGHT", f, -4, 0)
        fade:SetHeight(f:GetHeight() * 0.15)

        fade:SetBlendMode"ADD"
        fade:SetGradientAlpha("VERTICAL", .0, .0, .0, 1, .25, .25, .25, 1)
        -- Hides the old textures
        _G["ContainerFrame"..i.."BackgroundBottom"]:SetAlpha(0)
        _G["ContainerFrame"..i.."BackgroundMiddle2"]:SetAlpha(0)
        _G["ContainerFrame"..i.."BackgroundMiddle1"]:SetAlpha(0)
        _G["ContainerFrame"..i.."BackgroundTop"]:SetAlpha(0)
        _G["ContainerFrame"..i.."Portrait"]:SetAlpha(0)
end

local tips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}

for _, o in ipairs(tips) do
        o:SetBackdropColor(0, 0, 0, .9)
        local fade = o:CreateTexture(nil, "BORDER")
        fade:SetTexture"Interface\\ChatFrame\\ChatFrameBackground"
        fade:SetPoint("TOP", o, 0, -4)
        fade:SetPoint("LEFT", o, 4, 0)
        fade:SetPoint("RIGHT", o, -4, 0)
        fade:SetHeight(o:GetHeight() * 0.15)
        fade:SetBlendMode"ADD"
        fade:SetGradientAlpha("VERTICAL", .0, .0, .0, 1, .25, .25, .25, 1)
end
