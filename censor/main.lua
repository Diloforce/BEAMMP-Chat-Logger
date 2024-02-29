-- Main.lua
print("Loading Censor Plugin...")
function normalizeMessage(message)
    local normalized = message:lower()
    normalized = normalized:gsub("1", "i"):gsub("!", "i"):gsub("3", "e"):gsub("4", "a"):gsub("@", "a"):gsub("0", "o"):gsub("5", "s"):gsub("7", "t")
    return normalized
end

function containsBadWord(normalizedMessage)
    -- List of  bad words
    local badWords = {
        "nigger", "faggot", "slut", "retard", "whore", "cunt", "dickhead", "asshole", "motherfucker", "kys", "kill yourself", "im going to kill you", "nigga", "niga" --,"fuck", "bitch", "dumass", "idiot", "monkey", "npc" -- OPTIONAL ADDITIONS
     }
    print("Bad words loaded: " .. table.concat(badWords, ", "))
    for _, word in ipairs(badWords) do
        if normalizedMessage:find(word) then
            return true
        end
    end

    return false
end

function MyChatMessageHandler(sender_id, sender_name, message)
    local normalizedMessage = normalizeMessage(message)

    if containsBadWord(normalizedMessage) then
        -- Optionally, log or send a message about the censor action
         MP.SendChatMessageUser(-1, "Your message was censored.")
        print(sender_name .. "'s message was censored.")
        return 1  
    else
        return 0  
    end
end

MP.RegisterEvent("onChatMessage", "MyChatMessageHandler")
print("Censor Plugin Loaded.")
