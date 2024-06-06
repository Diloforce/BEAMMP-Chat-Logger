local mytimer = MP.CreateTimer()
print("Loading Plugins...")

local config = {
    mode = "local",  -- "local" for a static list, "cmd" for command-based management
    whitelistEnabled = false,  -- Enable or disable whitelist feature
    censorEnabled = true,  -- Enable or disable censor feature
    chatlogsEnabled = true,  -- Enable or disable chat logs
    webhookURL = "ENTER_WEB_HOOK",
    simpleControls = true, -- Enable if want simple controls: Kick, mute, ban and warn. 
    permsFilePath = "../perms.txt",  -- Path to the permissions file
    allowGuests = false, -- Allow guest users or not
}

-- Utility functions
local util = {}

util.createPermsFile = function()
    local permsFile, err = io.open(config.permsFilePath, "w")
    if not permsFile then
        print("Error creating perms file:", err)
        return
    end

    permsFile:write("Dilo admin\n")
    permsFile:write("Rex mod\n")
    permsFile:close()
    print("Permissions file created with default values.")
end

util.readPermsFile = function()
    local perms = {}
    local permsFile, err = io.open(config.permsFilePath, "r")
    if not permsFile then
        print("Permissions file not found, creating default one.")
        util.createPermsFile()
        permsFile, err = io.open(config.permsFilePath, "r")
        if not permsFile then
            print("Error opening perms file:", err)
            return perms
        end
    end

    for line in permsFile:lines() do
        local name, level = line:match("^(%S+)%s*(%S*)$")
        level = level ~= "" and level or "user"  
        perms[name:lower()] = level
    end

    permsFile:close()
    return perms
end

util.getPermLevel = function(name, perms)
    return perms[name:lower()] or "user"
end

util.hasPermission = function(name, requiredLevel, perms)
    local levels = {["user"] = 0, ["mod"] = 1, ["admin"] = 2}
    local userLevel = util.getPermLevel(name, perms)
    return levels[userLevel] >= levels[requiredLevel]
end

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

util.logToFile = function(message)
    local logFile, err = io.open("../chat_logs.txt", "a")
    if not logFile then
        print("Error opening log file:", err)
        return
    end

    logFile:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
    logFile:close()
end

util.sendToWebhook = function(message)
    local payload = '{"content": "' .. message .. '"}'
    local command = string.format(
        'curl -H "Content-Type: application/json" -d %q %s',
        payload, config.webhookURL
    )
    os.execute(command)
end

-- Implement simple controls
util.simpleKick = function(playerID, reason)
    MP.DropPlayer(playerID, reason)
    print("Player " .. playerID .. " has been kicked. Reason: " .. reason)
end

util.simpleMute = function(playerID, reason)
    MP.SendChatMessage(playerID, "You have been muted. Reason: " .. reason)
    print("Player " .. playerID .. " has been muted. Reason: " .. reason)
end

util.simpleBan = function(playerID, reason)
    MP.DropPlayer(playerID, "You have been banned. Reason: " .. reason)
    util.readBanFile(true, playerID .. " banned for: " .. reason)
    print("Player " .. playerID .. " has been banned. Reason: " .. reason)
end

util.simpleWarn = function(playerID, templateNumber, reason)
    local warnings = {
        "Please do not drift in town.",
        "Crash resetting is classed as FRP.",
        reason or "Custom Message"
    }

    local warningMessage = warnings[templateNumber] or reason or "Custom Message"
    MP.SendChatMessage(playerID, "Warning: " .. warningMessage)
    print("Player " .. playerID .. " has been warned. Reason: " .. warningMessage)
end

-- Censor functions
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

    if config.censorEnabled then
        if containsVeryBadWord(normalizedMessage) then
            MP.DropPlayer(sender_id, "You have been banned due to offensive language. Reason of Ban: " .. normalizedMessage)
            local banLogEntry = "Censorship-banned: " .. sender_name .. " | Reason: " .. normalizedMessage
            util.readBanFile(true, banLogEntry)
            MP.SendChatMessage(-1, sender_name .. " has been banned for offensive language.")
            print(sender_name .. " has been banned for offensive language. Reason: " .. normalizedMessage)
            if config.chatlogsEnabled then
                util.logToFile(banLogEntry)
                util.sendToWebhook(banLogEntry)
            end
            return 1  
        elseif containsBadWord(normalizedMessage) then
            local censorLogEntry = sender_name .. "'s message was censored. Reason: Bad word used."
            MP.SendChatMessage(-1, sender_name .. ", your message was censored.")
            print(censorLogEntry)
            if config.chatlogsEnabled then
                util.logToFile(censorLogEntry)
                util.sendToWebhook(censorLogEntry)
            end
            return 1  
        end
    end

    if config.chatlogsEnabled then
        util.logToFile(logEntry)
        util.sendToWebhook(logEntry)
    end

    return 0  
end

MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")

-- Whitelist functions
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

function handleConsoleInput(input)
    if input == "exampleCommand" then
        print("Example command executed!")
    end
end

MP.RegisterEvent("onConsoleInput", "handleConsoleInput")

-- Simple Controls 

function simpleControls(sender_id, sender_name, message)
    local perms = util.readPermsFile()
    local command, args = message:match("^(%S+)%s*(.*)$")
    if command == "warn" then
        if not util.hasPermission(sender_name, "mod", perms) then
            MP.SendChatMessage(sender_id, "You do not have permission to use this command.")
            return 1
        end

        local playerID, templateNumber, reason = args:match("^(%d+)%s*(%d+)%s*(.*)$")
        playerID = tonumber(playerID)
        templateNumber = tonumber(templateNumber)

        if not playerID or not templateNumber then
            MP.SendChatMessage(sender_id, "Invalid usage. Correct format: s!warn <playerID> <templateNumber> <reason>")
            return 1
        end
        util.simpleWarn(playerID, templateNumber, reason)
        return 1 
    else
        local playerID, reason = args:match("^(%d+)%s*(.*)$")
        playerID = tonumber(playerID)

        if not playerID then
            MP.SendChatMessage(sender_id, "Invalid player ID.")
            return 1
        end

        if command == "kick" then
            if not util.hasPermission(sender_name, "mod", perms) then
                MP.SendChatMessage(sender_id, "You do not have permission to use this command.")
                return 1
            end
            util.simpleKick(playerID, reason)
            return 1 
        elseif command == "mute" then
            if not util.hasPermission(sender_name, "mod", perms) then
                MP.SendChatMessage(sender_id, "You do not have permission to use this command.")
                return 1
            end
            util.simpleMute(playerID, reason)
            return 1  
        elseif command == "ban" then
            if not util.hasPermission(sender_name, "admin", perms) then
                MP.SendChatMessage(sender_id, "You do not have permission to use this command.")
                return 1
            end
            util.simpleBan(playerID, reason)
            return 1 
        else
            MP.SendChatMessage(sender_id, "Unknown command: " .. command)
            return 0  
        end
    end
end

function MyChatMessageHandler(sender_id, sender_name, message)
    if message:sub(1, 2) == "s!" then
        simpleControls(sender_id, sender_name, message:sub(3))
        return 1 
    end
    return 0  
end

MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")
MP.RegisterEvent("onConsoleInput", "handleConsoleInput")

function onPlayerAuth(playerName, senderRole, senderIsGuest, senderIdentifiers)
    if not config.allowGuests and senderIsGuest then
        return "Guest players are not allowed on this server."
    end

    if config.whitelistEnabled and not isPlayerWhitelisted(playerName) then
        return "You are not whitelisted on this server."
    end

    return nil 
end

MP.RegisterEvent("onPlayerAuth", "onPlayerAuth")

print("Registered all Events")
print("Chat Logger Plugin Loaded Successfully.")
print("Time taken: " .. mytimer:GetCurrent())
