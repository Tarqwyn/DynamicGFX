-- Core DynamicGFX file

local f = CreateFrame("Frame")  -- Create the frame to listen for events
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

-- Initialize SavedVariables for character-specific settings
if not DynamicGFX_CharacterSettings then
    DynamicGFX_CharacterSettings = {
        raid = {
            maxfps = 60,
            graphicsQuality = 4
        },
        dungeon = {
            maxfps = 75,
            graphicsQuality = 6
        },
        openWorld = {
            maxfps = 144,
            graphicsQuality = 10
        },
        arena = {
            maxfps = 90,
            graphicsQuality = 7
        },
        battleground = {
            maxfps = 60,
            graphicsQuality = 5
        },
        scenario = {
            maxfps = 80,
            graphicsQuality = 6
        }
    }
end

-- Ensure RAIDsettingsEnabled is off when the addon starts
local function DisableRaidGraphicsOnStartup()
    C_CVar.SetCVar("RAIDsettingsEnabled", "0")
    print("Raid graphics settings disabled at startup.")
end

-- Call this function on addon load
DisableRaidGraphicsOnStartup()

-- Function to apply settings based on the environment
_G.ApplySettings = function(instanceType)
    print("ApplySettings function called for instance type: " .. instanceType)

    -- Forcefully enable useMaxFPS
    C_CVar.SetCVar("useMaxFPS", "1")
    local useMaxFPS = GetCVar("useMaxFPS")

    -- Confirm that useMaxFPS is set correctly
    if useMaxFPS == "1" then
        print("useMaxFPS is enabled.")
    else
        print("Failed to enable useMaxFPS, retrying...")
        C_CVar.SetCVar("useMaxFPS", "1")  -- Retry if it failed
    end

    -- Apply maxfps and graphicsQuality settings from SavedVariables
    local settings = DynamicGFX_CharacterSettings[instanceType] or DynamicGFX_CharacterSettings["openWorld"]
    print("Applying settings: maxfps = " .. settings.maxfps .. ", graphicsQuality = " .. settings.graphicsQuality)

    -- Set the max FPS cap
    C_CVar.SetCVar("maxfps", tostring(settings.maxfps))
    C_CVar.SetCVar("graphicsQuality", tostring(settings.graphicsQuality))

    -- Debugging: check if values are applied
    local maxfps = GetCVar("maxfps")
    print("Current maxfps: " .. maxfps)
end

-- Debugging function to check CVar values
_G.CheckCVars = function()
    local useMaxFPS = GetCVar("useMaxFPS") or "nil"
    local maxfps = GetCVar("maxfps") or "nil"
    local maxfpsbk = GetCVar("maxfpsbk") or "nil"
    local graphicsQuality = GetCVar("graphicsQuality") or "nil"

    print("Current CVar settings:")
    print("Use Max FPS Enabled: " .. useMaxFPS)
    print("Max Foreground FPS: " .. maxfps)
    print("Max Background FPS: " .. maxfpsbk)
    print("Graphics Quality: " .. graphicsQuality)
end

-- Table for instance type settings
local instanceSettings = {
    raid = function() ApplySettings("raid") end,
    party = function() ApplySettings("dungeon") end,
    arena = function() ApplySettings("arena") end,
    pvp = function() ApplySettings("battleground") end,
    scenario = function() ApplySettings("scenario") end,
    none = function() ApplySettings("openWorld") end  -- for open world (none)
}

-- Event handler for environment changes
f:SetScript("OnEvent", function(self, event)
    local _, instanceType = GetInstanceInfo()

    -- Ensure RAIDsettingsEnabled is always off
    C_CVar.SetCVar("RAIDsettingsEnabled", "0")

    -- Lookup the instance type in the table and apply the corresponding settings
    local apply = instanceSettings[instanceType]
    if apply then
        apply()  -- Call the function for the instance type
    else
        print("Unknown instance type: " .. tostring(instanceType))
    end
end)
