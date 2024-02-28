-- M.lua
-- Module for whitelisting functionality

local M = {}
local MP = require("MP") -- Assuming MP module exists for multiplayer functionality

-- Reads the configuration from a JSON file
local function readConfig()
    local configFile, err = io.open("config.json", "r")
    if not configFile then
        error("Could not read config file: " .. tostring(err))
    end

    local content = configFile:read("*a")
    configFile:close()

    local config = json.decode(content) -- Assuming json.decode exists and is capable of parsing JSON content
    return config
end

function M.whitelist(playerID)
    MP.addList(playerID)
    MP.SendChatMessage(playerID, "Whitelisted: " .. MP.GetPlayerName(playerID))
end

-- Function to remove a player from the whitelist
function M.unwhitelist(playerID)
    -- Assuming MP.removelist exists and removes a player from a whitelist
    MP.removelist(playerID)
    MP.SendChatMessage(playerID, "Unwhitelisted: " .. MP.GetPlayerName(playerID))
end

return M
