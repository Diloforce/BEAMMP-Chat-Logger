-- localWhitelist.lua
-- Manages a local whitelist for BeamMP.

local whitelist = {"Dilo", "Player2"} -- Add player names here to whitelist them.

local M = {}

function M.isWhitelisted(playerName)
    for _, name in ipairs(whitelist) do
        if playerName == name then
            return true
        end
    end
    return false
end

return M
