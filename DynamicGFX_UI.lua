-- Create a frame to listen for the PLAYER_LOGIN event
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

-- Event handler for when the player is fully logged in
frame:SetScript("OnEvent", function(self, event)
    -- Create the addon options panel
    local panel = CreateFrame("Frame", "DynamicGFXOptionsPanel", UIParent)
    panel.name = "DynamicGFX"  -- Name of the addon in the Interface Options
    
    -- Register the panel using the new Settings API
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("DynamicGFX Settings")

    -- Addon Summary (Description, Version, Author, and Reason for Creation)
    local summary = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    summary:SetWidth(600)  -- Set the maximum width of the text block to 400 pixels
    summary:SetWordWrap(true)  -- Enable word wrap to ensure text stays within the width
    summary:SetHeight(100)  -- Set a fixed height for the text block to avoid dynamic overlap
    summary:SetText(
        "DynamicGFX automatically adjusts FPS and graphics settings based on your current environment.\n\n" ..
        "Version: 1.0\n" ..
        "Author: Tarqwyn Azjol-Nerub (EU)\n" ..
        "Why it was built: This addon was created based on a hypothesis that high-end systems can suffer CPU saturation during raids due to " ..
        "many addons checking player buffs per frame. By capping FPS in certain environments, DynamicGFX helps reduce CPU load and provide a smoother experience."
    )

    -- Starting Y-position for the sliders
    local sliderYOffset = -180  -- This starts the first slider lower, leaving room for the summary

    -- Function to create sliders for FPS settings
    local function CreateFPSSlider(labelText, defaultValue, minValue, maxValue, parentFrame, x, y, settingType)
        local slider = CreateFrame("Slider", labelText.."Slider", parentFrame, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", x, y)
        slider:SetMinMaxValues(minValue, maxValue)
        slider:SetValueStep(1)
        slider:SetValue(math.floor(defaultValue))

        -- Label
        _G[slider:GetName().."Text"]:SetText(labelText)
        _G[slider:GetName().."Low"]:SetText(minValue)
        _G[slider:GetName().."High"]:SetText(maxValue)

        -- Slider value display and rounding
        slider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value + 0.5)  -- Round to the nearest integer
            _G[slider:GetName().."Text"]:SetText(labelText .. ": " .. value)
            -- Save the FPS value for the correct instance type in SavedVariables
            DynamicGFX_CharacterSettings[settingType].maxfps = value
            -- Apply the updated settings immediately
            ApplySettings(settingType)
        end)

        return slider
    end

    -- Function to create dropdown for graphics quality
    local function CreateGraphicsDropdown(labelText, parentFrame, x, y, settingType)
        local dropdown = CreateFrame("Frame", labelText.."Dropdown", parentFrame, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", x, y)

        local function OnClick(self)
            UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
            -- Save the graphics quality value for the correct instance type in SavedVariables
            DynamicGFX_CharacterSettings[settingType].graphicsQuality = self:GetID()
            -- Apply the updated settings immediately
            ApplySettings(settingType)
        end

        local function InitializeDropdown(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for i = 1, 10 do
                info.text = "Quality " .. i
                info.func = OnClick
                info.checked = false
                UIDropDownMenu_AddButton(info, level)
            end
        end

        UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
        UIDropDownMenu_SetWidth(dropdown, 150)
        UIDropDownMenu_SetButtonWidth(dropdown, 124)
        UIDropDownMenu_SetSelectedID(dropdown, DynamicGFX_CharacterSettings[settingType].graphicsQuality or 1)
        UIDropDownMenu_JustifyText(dropdown, "LEFT")

        return dropdown
    end

    -- Create UI elements for Raid, Dungeon, Open World, Arena, Battleground, and Scenario settings
    local raidSlider = CreateFPSSlider("Raid FPS", DynamicGFX_CharacterSettings.raid.maxfps or 60, 30, 144, panel, 16, sliderYOffset, "raid")
    local raidDropdown = CreateGraphicsDropdown("Raid Graphics", panel, 200, sliderYOffset, "raid")

    sliderYOffset = sliderYOffset - 70  -- Increase spacing between sliders

    local dungeonSlider = CreateFPSSlider("Dungeon FPS", DynamicGFX_CharacterSettings.dungeon.maxfps or 75, 30, 144, panel, 16, sliderYOffset, "dungeon")
    local dungeonDropdown = CreateGraphicsDropdown("Dungeon Graphics", panel, 200, sliderYOffset, "dungeon")

    sliderYOffset = sliderYOffset - 70

    local openWorldSlider = CreateFPSSlider("Open World FPS", DynamicGFX_CharacterSettings.openWorld.maxfps or 144, 30, 144, panel, 16, sliderYOffset, "openWorld")
    local openWorldDropdown = CreateGraphicsDropdown("Open World Graphics", panel, 200, sliderYOffset, "openWorld")

    sliderYOffset = sliderYOffset - 70

    local arenaSlider = CreateFPSSlider("Arena FPS", DynamicGFX_CharacterSettings.arena.maxfps or 90, 30, 144, panel, 16, sliderYOffset, "arena")
    local arenaDropdown = CreateGraphicsDropdown("Arena Graphics", panel, 200, sliderYOffset, "arena")

    sliderYOffset = sliderYOffset - 70

    local battlegroundSlider = CreateFPSSlider("Battleground FPS", DynamicGFX_CharacterSettings.battleground.maxfps or 60, 30, 144, panel, 16, sliderYOffset, "battleground")
    local battlegroundDropdown = CreateGraphicsDropdown("Battleground Graphics", panel, 200, sliderYOffset, "battleground")

    sliderYOffset = sliderYOffset - 70

    local scenarioSlider = CreateFPSSlider("Scenario FPS", DynamicGFX_CharacterSettings.scenario.maxfps or 80, 30, 144, panel, 16, sliderYOffset, "scenario")
    local scenarioDropdown = CreateGraphicsDropdown("Scenario Graphics", panel, 200, sliderYOffset, "scenario")

    -- Apply settings on load
    panel:SetScript("OnShow", function()
        raidSlider:SetValue(DynamicGFX_CharacterSettings.raid.maxfps or 60)
        dungeonSlider:SetValue(DynamicGFX_CharacterSettings.dungeon.maxfps or 75)
        openWorldSlider:SetValue(DynamicGFX_CharacterSettings.openWorld.maxfps or 144)
        arenaSlider:SetValue(DynamicGFX_CharacterSettings.arena.maxfps or 90)
        battlegroundSlider:SetValue(DynamicGFX_CharacterSettings.battleground.maxfps or 60)
        scenarioSlider:SetValue(DynamicGFX_CharacterSettings.scenario.maxfps or 80)

        UIDropDownMenu_SetSelectedID(raidDropdown, DynamicGFX_CharacterSettings.raid.graphicsQuality or 1)
        UIDropDownMenu_SetSelectedID(dungeonDropdown, DynamicGFX_CharacterSettings.dungeon.graphicsQuality or 1)
        UIDropDownMenu_SetSelectedID(openWorldDropdown, DynamicGFX_CharacterSettings.openWorld.graphicsQuality or 1)
        UIDropDownMenu_SetSelectedID(arenaDropdown, DynamicGFX_CharacterSettings.arena.graphicsQuality or 1)
        UIDropDownMenu_SetSelectedID(battlegroundDropdown, DynamicGFX_CharacterSettings.battleground.graphicsQuality or 1)
        UIDropDownMenu_SetSelectedID(scenarioDropdown, DynamicGFX_CharacterSettings.scenario.graphicsQuality or 1)
    end)

    -- Unregister the event once the panel is created
    self:UnregisterEvent("PLAYER_LOGIN")
end)
