-- WhitelistManager.lua
-- Module for managing a whitelist in a game server environment
-- 27th February 2024

local WhitelistManager = {}

WhitelistManager.list = {}

function WhitelistManager.addPlayer(playerID)
    if not WhitelistManager.list[playerID] then
        WhitelistManager.list[playerID] = true
        return "Player " .. playerID .. " has been added to the whitelist."
    else
        return "Player " .. playerID .. " is already on the whitelist."
    end
end

function WhitelistManager.removePlayer(playerID)
    if WhitelistManager.list[playerID] then
        WhitelistManager.list[playerID] = nil
        return "Player " .. playerID .. " has been removed from the whitelist."
    else
        return "Player " .. playerID .. " is not on the whitelist."
    end
end

function WhitelistManager.isPlayerWhitelisted(playerID)
    return WhitelistManager.list[playerID] or false
end

function WhitelistManager.getWhitelist()
    local players = {}
    for playerID in pairs(WhitelistManager.list) do
        table.insert(players, playerID)
    end
    return players
end

return WhitelistManager
