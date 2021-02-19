-- Drawing the ghostmode sign on the gm checkpoint

local showSign = false
local cp_x, cp_y, cp_z

local drawDistance = 100

local screenSizex, screenSizey = guiGetScreenSize()
local guix = screenSizex * 0.1
local guiy = screenSizex * 0.1
local globalscale = 5
local globalalpha = .5
	
local ghostIcon = guiCreateStaticImage(0, 0, guix, guiy, "icon.png", false )
guiSetVisible(ghostIcon, false)

-- Toggling the sign
function drawSign( show, x, y, z )
	showSign = not ( not show )
	if showSign then
		cp_x, cp_y, cp_z = x, y, z
		guiSetVisible(ghostIcon, true)
		removeEventHandler ( "onClientRender", root, showIcon )
		addEventHandler ( "onClientRender", root, showIcon )
	else
		cp_x, cp_y, cp_z = nil, nil, nil
		guiSetVisible(ghostIcon, false)
		removeEventHandler ( "onClientRender", root, showIcon )
	end
end
addEvent("drawSign", true )
addEventHandler ( "drawSign", root, drawSign )

-- Updating the sign's location
function showIcon()
	if showSign and cp_z then
		local playerx, playery, playerz = getCameraMatrix()
		local dist = getDistanceBetweenPoints3D ( cp_x, cp_y, cp_z, playerx, playery, playerz )
		if dist < drawDistance and ( isLineOfSightClear(cp_x, cp_y, cp_z+1.2, playerx, playery, playerz, true, false, false, false )) then
			local screenX, screenY = getScreenFromWorldPosition ( cp_x, cp_y, cp_z+1.2 )
			if(screenX and screenY) then
				local scaled = screenSizex * (1/(2*(dist+5))) *.85
				local relx, rely = scaled * globalscale, scaled * globalscale
				guiSetAlpha(ghostIcon, globalalpha)
				guiSetSize(ghostIcon, relx, rely, false)
				guiSetPosition(ghostIcon, screenX - (relx / 2), screenY, false)
				guiSetVisible(ghostIcon, true)
			else
				guiSetVisible(ghostIcon, false)
			end
		else
			guiSetVisible(ghostIcon, false)
		end
	else
		guiSetVisible(ghostIcon, false)
	end
end


-- Determining if ghostmode can be disabled for the local player

local minimDistanceCars = 20
local minimDistancePlane = 35
local minimDistanceBoats = 30
local minimDistanceHelis = 35

function checkGmCanWorkOk(bool)
	if bool then return stopTimers() end
	local isOk = true
	local playerCar = getPedOccupiedVehicle(localPlayer)
	
	for i,player in ipairs(getElementsByType('player')) do 
		local car = getPedOccupiedVehicle(player)
		if player ~= localPlayer and isElement(car) and getElementData(player, "dim") == getElementData(localPlayer, "dim") then
			if playerCar then
				x,y,z = getElementPosition(car)
				cx,cy,cz = getElementPosition(playerCar)
				local minimDistance = minimDistanceCars
				if (getVehicleType(car) == 'Plane') and (getVehicleType(playerCar) == 'Plane') then
					minimDistance = minimDistancePlane
				elseif (getVehicleType(car) == 'Boat') and (getVehicleType(playerCar) == 'Boat') then
					minimDistance = minimDistanceBoats
				elseif (getVehicleType(car) == 'Helicopter') and (getVehicleType(playerCar) == 'Helicopter') then
					minimDistance = minimDistanceHelis
				end	
				local distance = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
				if distance <= minimDistance then 
					isOk = false
					if isTimer( gmTimer ) then killTimer( gmTimer ) end
					gmTimer = setTimer( checkGmCanWorkOk, 50, 1)
					break
				end
			end		
		end
	end
	if isOk == true then
		stopTimers()
		triggerServerEvent('onGMoff', localPlayer)
	else
		startBlinking()
	end	
end
addEvent('checkGmCanWorkOk', true)
addEventHandler('checkGmCanWorkOk', root, checkGmCanWorkOk)


-- Blinking alpha to indicate GM can drop anytime
local alphaTimer
local alphaToggle

function startBlinking()
	if isTimer( alphaTimer ) then killTimer( alphaTimer ) end
	alphaTimer = setTimer ( blink, 400, 0 )
end

function blink()
	if alphaToggle then
		setElementAlpha( getPedOccupiedVehicle(localPlayer), 90 )
		alphaToggle = not alphaToggle
	else
		setElementAlpha( getPedOccupiedVehicle(localPlayer), 200 )
		alphaToggle = not alphaToggle
	end
end


-- Reset the timers when the map stops
function stopTimers()
	if isTimer( gmTimer ) then killTimer( gmTimer ) end
	if isTimer( alphaTimer ) then killTimer( alphaTimer ) end
	gmTimer = nil
	alphaTimer = nil
end
addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', localPlayer, stopTimers)

addEventHandler('onClientRender', root,
function()
	local car = getPedOccupiedVehicle(localPlayer)
	if car then
		if getElementAlpha(car) ~= 255 then
			local players = getElementsByType('player')
			for _, player in ipairs(players) do 
				if player ~= localPlayer and getElementData(localPlayer, "dim") == getElementData(player, "dim") then 
					local pedCar = getPedOccupiedVehicle(player)
					if pedCar and getElementAlpha(pedCar) ~= 255 then
						local x,y,z = getElementPosition(car)
						local cx,cy,cz = getElementPosition(pedCar)
						local distance = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
						if distance <= 5 then
							setElementAlpha(car, 240)
						
								setElementAlpha(pedCar, 40)
								setElementAlpha(player, 40)
							
						else
							setElementAlpha(pedCar, 180)
							setElementAlpha(car, 180)
							setElementAlpha(player, 180)
						end
					end
				end
			end
		end
	end
	
end
)
