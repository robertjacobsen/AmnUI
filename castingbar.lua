local addon, ns = ...

local cb = CastingBarFrame	
cb:ClearAllPoints()
cb:SetPoint("BOTTOM", UIParent, 0, 150)
cb.SetPoint = function() end

ns.CastBar = CastBar
