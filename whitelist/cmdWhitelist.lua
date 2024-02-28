-- cmdWhitelist.lua
-- Manages a command-based whitelist for BeamMP, allowing dynamic updates.

local whitelist = {} -- Initially empty, names will be added via commands.

local M = {}

function M.onChatMessage(playerID, message)
    local cmd, name = message:match("^/(%w+)%s*(.*)")
    
    if cmd == "whitelist" and name ~= "" then
        if not M.isWhitelisted(name) then
            table.insert(whitelist, name)
            print(name .. " has been added to the whitelist.")
        else
            print(name .. " is already on the whitelist.")
        end
    elseif cmd == "unwhitelist" and name ~= "" then
        for i, whitelistedName in ipairs(whitelist) do
            if name == whitelistedName then
                table.remove(whitelist, i)
                print(name .. " has been removed from the whitelist.")
                break
            end
        end
    end
end

function M.isWhitelisted(playerName)
    for _, name in ipairs(whitelist) do
        if playerName == name then
            return true
        end
    end
    return false
end

return M
