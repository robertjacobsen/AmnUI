local addon, ns = ...
local db

local AMNUF_DEFAULT_FONT_NAME, AMNUF_DEFAULT_FONT_SIZE = GameFontNormalSmall:GetFont()

--[[ UnitFrame specific code ]]

local UnitFrames = CreateFrame"Frame"
UnitFrames:RegisterEvent"UNIT_HEALTH"
UnitFrames:RegisterEvent"UNIT_POWER"
UnitFrames:RegisterEvent"ADDON_LOADED"
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

    UnitFrames.PLAYER_ENTERING_WORLD = function (self, event)
        self.Update(self, event, "player")
    end

    UnitFrames.PLAYER_TARGET_CHANGED = function (self, event)
        self.Update(self, event, "target")
    end
    UnitFrames.UNIT_HEALTH = UnitFrames.Update
    UnitFrames.UNIT_POWER = UnitFrames.Update
end

UnitFrames.ADDON_LOADED = function(self, event, addon) 
    if addon == "AmnUI" then
        db = AmnUIDB
        UnitFrames.Enable()
    end
end

UnitFrames.UpdateFontSizes = function() 
    for parent, child in pairs(UnitFrames.bars) do
        _G[child]:SetFont(AMNUF_DEFAULT_FONT_NAME, db.UnitFrames.FontSize)
    end
end

UnitFrames.Help = function() 
    ns:Print("Usage is /amnui uf <command> <argument>.")
    ns:Print(string.format("/amnui uf size <number> - Sets the font size. Current size: [%d]", db.UnitFrames.FontSize))
    ns:Print(string.format("/amnui uf pos - Toggles whether or not the unit frames will be repositioned. [%s]", tostring(db.UnitFrames.Reposition)))
    ns:Print(string.format("/amnui uf scale <decimal> - Sets the scale of the unit frames. Current scale: [%.1f]", db.UnitFrames.Scale))
end

ns.UnitFrames = UnitFrames
