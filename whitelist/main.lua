print("Loading Whitelist Plugin...")

local whitelistModule

require("config") -- Load the configuration
local mode = getConfig().mode

if mode == "local" then
    print("Whitelist Mode: Local")
    whitelistModule = require("localWhitelist")
else
    print("Whitelist Mode: Command")
    whitelistModule = require("cmdWhitelist")
end

MP.RegisterEvent("onPlayerConnecting", "onPlayerConnecting")

function onPlayerConnecting(playerID)
    local playerName = MP.GetPlayerName(playerID)

    if not whitelistModule.isWhitelisted(playerName) then
        MP.DropPlayer(playerID, "You're not whitelisted.")
    end
end

if mode == "cmd" then
    MP.RegisterEvent("onChatMessage", whitelistModule.onChatMessage)
end

print("Whitelist Plugin Loaded Successfully.")
