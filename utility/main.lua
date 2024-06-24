local mytimer = MP.CreateTimer()
print("Loading Plugins...")

local config = {
    mode = "local",  -- "local" for a static list, "cmd" for command-based management
    whitelistEnabled = false,  -- Enable or disable whitelist feature
    censorEnabled = true,  -- Enable or disable censor feature
}

-- Utility functions
local util = {}

util.readBanFile = function(rwSw, wrInput)
    local path = "../blacklist"
    local blFile, err = io.open(path, rwSw and "a+" or "r")
    if not blFile then
        print("Error opening file:", err)
        return
    end

    if rwSw and wrInput then
        blFile:write(wrInput .. "\n")
        blFile:flush()
    elseif not rwSw then
        local content = blFile:read("*all")
        blFile:close()
        return content
    end
    if blFile then blFile:close() end
end

local function logMessage(message)
    local logFile, err = io.open("chat_log.txt", "a+")
    if not logFile then
        print("Error opening log file:", err)
        return
    end
    logFile:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
    logFile:close()
end

-- Censor functions
local function normalizeMessage(message)
    local normalized = message:lower()
    normalized = normalized:gsub("[1!]", "i"):gsub("[3]", "e"):gsub("[4@]", "a"):gsub("[0]", "o"):gsub("[5]", "s"):gsub("[7]", "t")
    return normalized
end

local function containsBadWord(normalizedMessage)
    local badWords = {"slut", "retard", "whore", "cunt", "asshole", "motherfucker", "kys", "kill yourself", "im going to kill you"}
    for _, word in ipairs(badWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end

local function containsVeryBadWord(normalizedMessage)
    local veryBadWords = {"nigger", "faggot", "nigga", "niga"}
    for _, word in ipairs(veryBadWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end
    return false
end

function MyChatMessageHandler(sender_id, sender_name, message)
    local normalizedMessage = normalizeMessage(message)
    local logEntry = sender_name .. ": " .. message

    -- Log the message
    logMessage(logEntry)

    -- Censorship Handling
    if config.censorEnabled then
        if containsVeryBadWord(normalizedMessage) then
            MP.DropPlayer(sender_id, "You have been banned due to offensive language. Reason of Ban: " .. normalizedMessage)
            local banLogEntry = "Censorship-banned: " .. sender_name .. " | Reason: " .. normalizedMessage
            util.readBanFile(true, banLogEntry)
            MP.SendChatMessage(-1, sender_name .. " has been banned for offensive language.")
            print(sender_name .. " has been banned for offensive language. Reason: " .. normalizedMessage)
            return 1  
        elseif containsBadWord(normalizedMessage) then
            local censorLogEntry = sender_name .. "'s message was censored. Reason: Bad word used."
            MP.SendChatMessage(-1, sender_name .. ", your message was censored.")
            print(censorLogEntry)
            return 1  
        end
    end 
end

MP.RegisterEvent("onPlayerAuth", "onPlayerAuth")

print("Registered all Events")
print("Chat Logger Plugin Loaded Successfully.")
print("Time taken: " .. mytimer:GetCurrent())
