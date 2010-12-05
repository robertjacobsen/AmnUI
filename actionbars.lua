local addon, ns = ...

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
            
            local border = _G[name.."Border"]       
            border:Hide()
            border.Show = function() end
            
            local nt = _G[name.."NormalTexture"]
            nt:SetPoint("BOTTOM", 0, -100000000000) -- GET THE HELL OFF MY SCREEN
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

    -- StanceBar
    local StanceBar = CreateFrame("Frame", "AmnUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
    ShapeshiftBarFrame:SetParent(StanceBar)
    
    for i = 1, NUM_SHAPESHIFT_SLOTS do
        local button = _G["ShapeshiftButton"..i]
        button:SetSize(25, 25)
        button:ClearAllPoints()
        
        local nt = _G["ShapeshiftButton"..i.."NormalTexture"]
        nt:SetPoint("BOTTOM", 0, -100000000)

        local icon = _G["ShapeshiftButton"..i.."Icon"]
        icon:SetTexCoord(.07, .93, .07, .93)
        icon:SetAllPoints(button)

        if i == 1 then
            button:SetPoint("BOTTOMLEFT", StanceBar)
        else
            button:SetPoint("LEFT", _G["ShapeshiftButton"..i-1], "RIGHT")
        end
    end
    StanceBar:SetPoint("BOTTOMLEFT", "AmnUI_"..names[3], 0, 42)
    StanceBar:SetHeight(25)
    StanceBar:SetWidth(25*NUM_SHAPESHIFT_SLOTS)
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

ActionBars.RemoveTextures()
ActionBars.MoveBars()
if select(2, UnitClass"player") == "SHAMAN" then
    ActionBars.ImAShaman()
end

ns.ActionBars = ActionBars
