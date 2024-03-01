local mytimer = MP.CreateTimer()
print("Loading Plugins...")
-- Requirements

-- webhook


-- Configurations
local config = {
    mode = "local",  -- "local" for a static list, "cmd" for command-based management
    whitelistEnabled = false,  -- Enable or disable whitelist feature
    censorEnabled = true,  -- Enable or disable censor feature
}

-- Integrations 
util = {}

util.readBanFile = function(rwSw, wrInput)
    local path = "../blacklist"
    local blFile = io.open(path, rwSw and "a+" or "r")
    if rwSw and wrInput and blFile then
        blFile:write(wrInput)
        blFile:flush()
    elseif not rwSw and blFile then
        local content = blFile:read("*all")
        blFile:close()
        return content
    end
    if blFile then blFile:close() end
end

-- Censor
function normalizeMessage(message)
    local normalized = message:lower()
    normalized = normalized:gsub("[1!]", "i"):gsub("[3]", "e"):gsub("[4@]", "a"):gsub("[0]", "o"):gsub("[5]", "s"):gsub("[7]", "t")
    return normalized
end

function containsBadWord(normalizedMessage)
    local badWords = {"nigger", "faggot", "slut", "retard", "whore", "cunt"", "motherfucker", "kys", "kill yourself", "im going to kill you", "nigga", "niga"}
    for _, word in ipairs(badWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end

function MyChatMessageHandler(sender_id, sender_name, message)
    local normalizedMessage = normalizeMessage(message)  
    if normalizedMessage:find("nigger") or normalizedMessage:find("niga") or normalizedMessage:find("faggot") or normalizedMessage:find("niger") or normalizedMessage:find("nigga") then
        MP.DropPlayer(sender_id, "You have been banned due to offensive language. Reason of Ban: " .. normalizedMessage) 
        local i = "\nCensorship-banned: " .. sender_name .. " | Reason: " .. normalizedMessage
        util.readBanFile(true, i) 
        MP.SendChatMessage(-1, sender_name .. ": Your message was censored.")
        print(sender_name .. "'s message was censored. Bad word used: " .. normalizedMessage)
    else
        MP.SendChatMessage(-1, sender_name .. ": Your message was censored.")
        print(sender_name .. "'s message was censored. Bad word used: " .. normalizedMessage) 
            return 1
         end
    return false 
end

-- Whitelist 
local whitelist = {"Player1", "Player2"}

function isPlayerWhitelisted(playerName)
    for _, name in ipairs(whitelist) do
        if playerName:lower() == name:lower() then
            return true
        end
    end
    return false
end

function onPlayerConnecting(playerID)
    local playerName = MP.GetPlayerName(playerID)
    if config.whitelistEnabled and not isPlayerWhitelisted(playerName) then
        MP.DropPlayer(playerID, "You're not whitelisted on this server.")
    end
end

MP.RegisterEvent("onPlayerConnecting", "onPlayerConnecting")
MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")

print("Plugins Loaded Successfully.")
print("Time taken:"  ..  mytimer:GetCurrent()) -- print how much time elapsed
