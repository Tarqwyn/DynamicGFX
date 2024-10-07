-- Slash command handler
SLASH_DYNAMICGFX1 = "/dgfx"

SlashCmdList["DYNAMICGFX"] = function(msg)
    local args = { strsplit(" ", msg) }

    if #args < 3 then
        print("Usage: /dgfx <environment> <setting> <value>")
        return
    end

    local env = args[1]  -- e.g., raid, dungeon, openWorld
    local setting = args[2]  -- e.g., maxfps, graphicsQuality
    local value = tonumber(args[3])

    if defaults[env] then
        defaults[env][setting] = value
        print(env .. " " .. setting .. " set to " .. value)

        -- Force useMaxFPS to be enabled when setting maxfps
        if setting == "maxfps" then
            C_CVar.SetCVar("useMaxFPS", "1")  -- Ensure FPS limit is enabled
            SetCVar("maxfps", value)
            print("Setting maxfps to: " .. value)
        elseif setting == "graphicsQuality" then
            SetCVar("graphicsQuality", value)
            print("Setting graphicsQuality to: " .. value)
        end
    else
        print("Invalid environment or setting.")
    end
end