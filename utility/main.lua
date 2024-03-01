local mytimer = MP.CreateTimer()
print("Loading Plugins...")

-- admin 
local config = {
    mode = "local",  -- "local" for a static list, "cmd" for command-based management
    whitelistEnabled = false,  -- Enable or disable whitelist feature
    censorEnabled = true,  -- Enable or disable censor feature
    chatlogsEnabled = true,
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
    local badWords = {"slut", "retard", "whore", "cunt", "asshole", "motherfucker", "kys", "kill yourself", "im going to kill you"}
    for _, word in ipairs(badWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end
function containsVeryBadWord(normalizedMessage)
    local veryBadWords = {"nigger", "faggot", "nigga", "niga"}
    for _, word in ipairs(veryBadWords) do  -- Corrected to iterate over veryBadWords
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end

function MyChatMessageHandler(sender_id, sender_name, message)
    local normalizedMessage = normalizeMessage(message)
    if containsVeryBadWord(normalizedMessage) then
        -- Your existing logic for very bad words
        MP.DropPlayer(sender_id, "You have been banned due to offensive language. Reason of Ban: " .. normalizedMessage)
        local logEntry = "\nCensorship-banned: " .. sender_name .. " | Reason: " .. normalizedMessage
        util.readBanFile(true, logEntry)
        MP.SendChatMessage(-1, sender_name .. " has been banned for offensive language.")
        print(sender_name .. " has been banned for offensive language. Reason: " .. normalizedMessage)
    elseif containsBadWord(normalizedMessage) then
        -- Adjusted logic for bad words
        MP.SendChatMessage(-1, sender_name .. ", your message was censored.")
        print(sender_name .. "'s message was censored. Reason: Bad word used.")
    end
end

-- Properly registering the event handler for chat messages
MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")


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

-- Commands 

MP.RegisterEvent("onChatMessage", "onChatMessage")

MP.RegisterEvent("onConsoleInput", "handleConsoleInput")

MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")
MP.RegisterEvent("onPlayerConnecting", "onPlayerConnecting") print("Registered all Events")  
print("Utilities Plugin Loaded Successfully.")
print("Time taken: " .. mytimer:GetCurrent()) 

