print("Loading Plugins...")

-- Configurations
local config = {
    mode = "local",  -- "local" for a static list, "cmd" for command-based management
    whitelistEnabled = false,  -- Enable or disable whitelist feature
    censorEnabled = true  -- Enable or disable censor feature
}

-- Censor
function normalizeMessage(message)
    local normalized = message:lower()
    normalized = normalized:gsub("[1!]", "i"):gsub("[3]", "e"):gsub("[4@]", "a"):gsub("[0]", "o"):gsub("[5]", "s"):gsub("[7]", "t")
    return normalized
end

function containsBadWord(normalizedMessage)
    local badWords = {"nigger", "faggot", "slut", "retard", "whore", "cunt", "dickhead", "asshole", "motherfucker", "kys", "kill yourself", "im going to kill you", "nigga", "niga", "niger"}
    for _, word in ipairs(badWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end

function MyChatMessageHandler(sender_id, sender_name, message)
    if config.censorEnabled and containsBadWord(normalizeMessage(message)) then
        MP.SendChatMessage(-1, .. sender_name ..  " Your message was censored.")

        print(sender_name .. "'s message was censored.")
        return 1 
    end
    return 0  
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
