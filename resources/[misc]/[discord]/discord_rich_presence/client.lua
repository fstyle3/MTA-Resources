local mode
local clientAppId
local clientWebsiteUrl
local clientServerUrl

local startTime = 0

function onStart()
    triggerServerEvent("onClientRequestDiscordInitialization", localPlayer)
    startTime = getRealTime().timestamp
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop ( stoppedRes )
    if getResourceName(stoppedRes) ~= "discord_rich_presence" then
        setupInfo()
    end
end
addEventHandler( "onClientResourceStop", getRootElement(), onStop);

function setupInfo()
    resetDiscordRichPresenceData()
    setDiscordApplicationID(clientAppId)
    setDiscordRichPresencePartySize(0, 0)
    setDiscordRichPresenceButton(1, "Join now!", clientServerUrl)
    setDiscordRichPresenceButton(2, "Website", clientWebsiteUrl)
    setDiscordRichPresenceAsset("mrgreenlogo", "MrGreen Gaming")
    setDiscordRichPresenceStartTime(getRealTime().timestamp - startTime)
end

function onDiscordInitialize(appId, websiteUrl, serverUrl)
    if appId then
        clientAppId = appId
        clientWebsiteUrl = websiteUrl
        clientServerUrl = serverUrl

        setupInfo()
        setTimer(onUpdateRank, 1500, 0)
    else
        setTimer(onStart, 60000 * 5, 1)
    end
end
addEvent("onDiscordRichPresenceInitialize", true)
addEventHandler("onDiscordRichPresenceInitialize", root, onDiscordInitialize)

function onMapStarting(mapInfo)
    if isDiscordRichPresenceConnected() then
        setDiscordRichPresenceDetails(mapInfo.name)
        setDiscordRichPresenceState("")

        if mapInfo.modename == "Sprint" then
            mode = "race"
        elseif mapInfo.modename == "Never the same" then
            mode = "nts"
        elseif mapInfo.modename == "Capture the flag" then
            mode = "ctf"
        elseif mapInfo.modename == "Shooter" then
            mode = "shooter"
        elseif mapInfo.modename == "Destruction derby" then
            mode = "dd"
        elseif mapInfo.modename == "Reach the flag" then
            mode = "rtf"
        else
            mode = nil
        end

        if mode then
            setDiscordRichPresenceSmallAsset(mode, mapInfo.modename)
        else
            setDiscordRichPresenceSmallAsset("", "")
        end
    end
end
addEventHandler("onClientMapStarting", root, onMapStarting)

function onUpdateRank()
    if (mode == "race" or mode == "nts") and isDiscordRichPresenceConnected() then
        local rank = getElementData(localPlayer,'race rank')

        if not tonumber(rank) then
            setDiscordRichPresenceState("")
            return
        end

        local currentCheckpoint = (getElementData(localPlayer, 'race.checkpoint') or 1) - ((getElementData(localPlayer, 'race.finished') and 0) or 1)
        local totalCheckpoints = (#(exports.race:getCheckPoints() or {}) or 1)

        local isFinished = getElementData(localPlayer, 'race.finished')

        if isFinished then
            setDiscordRichPresenceState("Finished in " .. rank .. getSuffix(rank) .. " place!")
        else
            setDiscordRichPresenceState(rank .. getSuffix(rank) .. " place (" .. currentCheckpoint .. "/" .. totalCheckpoints ..")")
        end

    end
end

function getSuffix(rank)
    local suffix
    if (rank == 11) or (rank == 12) or (rank == 13) then
        suffix = "th"
    else
        local lastNumber = rank % 10
        if lastNumber == 1 then
            suffix = "st"
        elseif lastNumber == 2 then
            suffix = "nd"
        elseif lastNumber == 3 then
            suffix = "rd"
        else
            suffix = "th"
        end
    end
    return suffix
end
