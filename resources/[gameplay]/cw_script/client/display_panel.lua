local mode = "main"
local screenW, screenH = guiGetScreenSize()
local margin = math.floor(10 * (screenW / 1920))

local rowCount = 15
local rowHeight = math.floor(25 * (screenH / 1080))
local windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount
local wX, wY = screenW - windowSizeX - 20, (screenH - windowSizeY) / 2

local fSize = screenH/1080
local fBold = dxCreateFont("fonts/Roboto-Bold.ttf", 9 * fSize, true,"cleartype") or "default"
local fReg = dxCreateFont("fonts/Roboto-Medium.ttf", 9 * fSize, false, "cleartype") or "default"

local nickWidth = 160 * (screenW/1920)
local rankWidth = 40 * (screenW/1920)
local ptsWidth = 50 * (screenW/1920)

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function dxDrawBottomRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y, radius, height-(radius), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y, radius, height-(radius), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function updateDisplay()
	if isElement(teams[1]) and isElement(teams[2]) then
		local state = ""
		local sColor = "#ffffff"
		local r1, g1, b1 = getTeamColor(teams[1])
        local r2, g2, b2 = getTeamColor(teams[2])
		local t1c = rgb2hex(r1, g1, b1)
		local t2c = rgb2hex(r2, g2, b2)
        local t1tag = tags[1]
        local t2tag = tags[2]
		local t1 = getTeamName(teams[1])
		local t2 = getTeamName(teams[2])
		local t1t = getTeamFromName(t1)
		local t2t = getTeamFromName(t2)
		local t2Players = getPlayersInTeam(t2t)

		local t1Players = getPlayersInTeam(t1t)
        if ffa_mode == "FFA" then t1Players = getElementsByType("player") end


		windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount

		table.sort(t1Players, function(a, b) return (getElementData(a, 'Score') or 0) > (getElementData(b, 'Score') or 0) end)
		table.sort(t2Players, function(a, b) return (getElementData(a, 'Score') or 0) > (getElementData(b, 'Score') or 0) end)

		if not f_round then
			sColor = "#00ff00"
			state = "Event Active"
		else
			sColor = "#FFA500"
			state = "Free Round"
		end

		if #t1Players > 8 and #t2Players > 8 then
			rowCount = 8 + 8 + 5
		elseif #t1Players > 8 and #t2Players < 8 then
			rowCount = 8 + #t2Players + 5
		elseif #t1Players < 8 and #t2Players > 8 then
			rowCount = 8 + #t1Players + 5
		else
			rowCount = #t1Players + #t2Players + 5
		end

		if mode == "main" then
			local count = 0
			if #t1Players > 8 then
				count = 8
			else
				count = #t1Players
			end
			dxDrawRoundedRectangle(wX, wY, windowSizeX, windowSizeY, 10, tocolor(0, 0, 0, 160), false, false) -- background
			dxDrawRectangle(wX, wY + (rowHeight*2), windowSizeX, rowHeight, tocolor(r1, g1, b1, 30), false, false) -- t1 bg
            if ffa_mode == "CW" then
                dxDrawRectangle(wX, wY + (rowHeight*(2+(count+1))), windowSizeX, rowHeight, tocolor(r2, g2, b2, 30), false, false) -- t2 bg
            end
			dxDrawBottomRoundedRectangle(wX, wY + (rowHeight * (rowCount-1)), windowSizeX, rowHeight, 10, tocolor(0, 0, 0, 160), false, false) -- mode bg
			dxDrawText("Press #bababa0 #ffffffto change mode", wX, wY + (rowHeight * (rowCount-1)), wX+windowSizeX, wY + (rowHeight * (rowCount)), tocolor(255, 255, 255, 200), 1, fBold, "center", "center", false, false, true, true, false)

			dxDrawText(sColor..state, wX, wY, wX+windowSizeX, wY+rowHeight, tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText("Round "..c_round.."/"..m_round, wX, wY+rowHeight, wX+windowSizeX, wY+(rowHeight*2), tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(getTeamName(teams[1]), wX + margin, wY + (rowHeight*2), wX+windowSizeX-margin, wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "left", "center", false, false, false, true, false)
			dxDrawText(getElementData(teams[1], 'Score'), wX + rankWidth + nickWidth, wY + (rowHeight*2), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "center", "center", false, false, false, true, false)
            local isLocalPlayerInView = false
			for playerKey, player in ipairs(t1Players) do
				local rank = tonumber(getElementData(player, 'race rank')) or 1
                if ffa_mode == "FFA" then
                    rank = playerKey
                    local playerTeam = getPlayerTeam(player)
                    if playerTeam then
                        r1, g1, b1 = getTeamColor(playerTeam)
                    else
                        r1, g1, b1 = 255, 255, 255
                    end
                end
				local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
				local pts = getElementData(player, 'Score') or 0
				if playerKey <= 8 then
                    if player == getLocalPlayer() then isLocalPlayerInView = true end
					dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(2+playerKey)), wX+rankWidth, wY+(rowHeight*(3+playerKey)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
					dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(2+playerKey)), wX+nickWidth, wY+(rowHeight*(3+playerKey)), tocolor(r1, g1, b1, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
					dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(2+playerKey)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(3+playerKey)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
				end

                -- shows local player in the list if he is not in top 8 during FFA mode
                if ffa_mode == "FFA" then
                    if playerKey >= 9 and (not isLocalPlayerInView) then
                        if player == getLocalPlayer() then
                            dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(2+9)), wX+rankWidth, wY+(rowHeight*(3+9)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
                            dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(2+9)), wX+nickWidth, wY+(rowHeight*(3+9)), tocolor(r1, g1, b1, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
                            dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(2+9)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(3+9)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
                        end
                    elseif playerKey == 9 and isLocalPlayerInView then
                        dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(2+playerKey)), wX+rankWidth, wY+(rowHeight*(3+playerKey)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
                        dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(2+playerKey)), wX+nickWidth, wY+(rowHeight*(3+playerKey)), tocolor(r1, g1, b1, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
                        dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(2+playerKey)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(3+playerKey)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
                    end
                end
			end

            if (ffa_mode == "CW") then
                dxDrawText(getTeamName(teams[2]), wX + margin, wY + (rowHeight*(3+count)), wX+windowSizeX-margin, wY+(rowHeight*(4+count)), tocolor(r2, g2, b2, 255), 1, fBold, "left", "center", false, false, false, true, false)
                dxDrawText(getElementData(teams[2], 'Score'), wX + rankWidth + nickWidth, wY + (rowHeight*(3+count)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(4+count)), tocolor(r2, g2, b2, 255), 1, fBold, "center", "center", false, false, false, true, false)

                local t2start = 0
                if #t1Players > 8 then
                    t2start = 3+8
                else
                    t2start = 3+#t1Players
                end
                for playerKey, player in ipairs(t2Players) do
                    local rank = tonumber(getElementData(player, 'race rank')) or 1
                    local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
                    local pts = getElementData(player, 'Score')
                    if playerKey < 9 then
                        dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(t2start+playerKey)), wX+rankWidth, wY+(rowHeight*(t2start+playerKey+1)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
                        dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(t2start+playerKey)), wX+nickWidth, wY+(rowHeight*(t2start+playerKey+1)), tocolor(r2, g2, b2, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
                        dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(t2start+playerKey)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(t2start+playerKey+1)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
                    end
                end
            end
            elseif mode == "compact" then
                rowCount = 4
			windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount
			dxDrawRoundedRectangle(wX, wY, windowSizeX, windowSizeY, 10, tocolor(0, 0, 0, 160), false, false) -- background
			dxDrawRectangle(wX, wY + (rowHeight*2), windowSizeX, rowHeight, tocolor(r1, g1, b1, 20), false, false) -- t1 bg
			dxDrawBottomRoundedRectangle(wX, wY + (rowHeight * (rowCount-1)), windowSizeX, rowHeight, 10, tocolor(0, 0, 0, 160), false, false) -- mode bg
			dxDrawText("Press #bababa0 #ffffffto change mode", wX, wY + (rowHeight * (rowCount-1)), wX+windowSizeX, wY + (rowHeight * (rowCount)), tocolor(255, 255, 255, 200), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(sColor..state, wX, wY, wX+windowSizeX, wY+rowHeight, tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText("Round "..c_round.."/"..m_round, wX, wY+rowHeight, wX+windowSizeX, wY+(rowHeight*2), tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(t1c..t1tag.."   "..getElementData(teams[1], 'Score').."  #ffffff-  "..t2c..getElementData(teams[2], 'Score').."   "..t2tag, wX + margin, wY + (rowHeight*2), wX+windowSizeX-(margin*2), wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(1,1,1,1, 0, tocolor(0, 0, 0, 0), false, false)
		end
	end
end

function toggleMode()
	if mode == "main" and ffa_mode == "CW" then
		mode = "compact"
		outputInfoClient('Compact mode')

    elseif mode == "main" and ffa_mode == "FFA" then
        mode = "hidden"
        outputInfoClient('Hidden mode')
	elseif mode == "compact" then
		mode = "hidden"
		outputInfoClient('Hidden mode')
	else
		mode = "main"
		outputInfoClient('Full mode')
	end
end
bindKey('0', 'down', toggleMode)

addEventHandler('onClientRender', getRootElement(), updateDisplay)
