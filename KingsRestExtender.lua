-- aDDON NAME: KingsRestExtender
local ADDON_NAME = ...

-- Constants
local KingsRestInstanceName = "Kings' Rest"
local KingsRestInstanceMapId = 1762

-- Forward declarations
local KingsRestExtenderButton
local LockoutExists
local LockoutIsExtended
local ToggleExtend
local shouldExtend = false

local initHelper = CreateFrame("Frame")
initHelper:RegisterEvent("ADDON_LOADED");

initHelper:SetScript("OnEvent", function(self, event, ...)
    if ... ~= ADDON_NAME then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")

    KingsRestExtenderButton = CreateFrame("Button", nil, UIParent, "SecureHandlerClickTemplate");
    KingsRestExtenderButton:SetPoint("CENTER");
    KingsRestExtenderButton:SetSize(40, 40);
    KingsRestExtenderButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
    KingsRestExtenderButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
    KingsRestExtenderButton:Hide()

    local ExampleButtonIcon = KingsRestExtenderButton:CreateTexture(nil, "BACKGROUND");
    ExampleButtonIcon:SetAllPoints(KingsRestExtenderButton);
    ExampleButtonIcon:SetTexture("Interface\\Icons\\Inv_armoredraptorundead");

    KingsRestExtenderButton:SetScript("OnClick", function(self, arg1)
        ToggleExtend(self, arg1)
    end);
end)

LockoutExists = function(self, button)
    for index = 1, GetNumSavedInstances() do
        name, id, reset, difficulty, locked, extended, _, _, _, _, _, _ = GetSavedInstanceInfo(index)
        if name == KingsRestInstanceName then
            return true
        end
    end
    return false
end

LockoutIsExtended = function(self, button)
    for index = 1, GetNumSavedInstances() do
        name, id, reset, difficulty, locked, extended, _, _, _, _, _, _ = GetSavedInstanceInfo(index)
        if name == KingsRestInstanceName then
            return extended
        end
    end
    return false
end

ToggleExtend = function(self, button)
    for index = 1, GetNumSavedInstances() do
        local name, id, reset, difficulty, locked, extended, _, _, _, _, _, _ = GetSavedInstanceInfo(index)
        if name == KingsRestInstanceName then
            SetSavedInstanceExtend(index, shouldExtend)
        end
    end

    self:Hide()
end

local function OnZoneChange(self, event, ...)
    if event == "ZONE_CHANGED" then
        local subZoneText = GetSubZoneText()
        if subZoneText == "Atal'Dazar" then
            if LockoutExists() and not LockoutIsExtended() then
                shouldExtend = true
                KingsRestExtenderButton:Show()
            end
        end
    end

    if event == "PLAYER_ENTERING_WORLD" then
        local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo()
        if instanceMapId == KingsRestInstanceMapId then
            if LockoutExists() and LockoutIsExtended() then
                shouldExtend = false
                KingsRestExtenderButton:Show()
            end
        end
    end

end

local zoneListener = CreateFrame("Frame")
zoneListener:RegisterEvent("ZONE_CHANGED");
zoneListener:RegisterEvent("PLAYER_ENTERING_WORLD");
zoneListener:SetScript("OnEvent", OnZoneChange);
