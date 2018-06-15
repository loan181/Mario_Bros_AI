--
-- Created by IntelliJ IDEA.
-- User: Loan
-- Date: 3/29/2018
-- Time: 9:54 PM
--

package.path = ";LUA\\src\\?.lua;" .. package.path

--MarioBros = require("marioBros")
MameCst = require("mameLuaConstants")
MameCmd = require("mameCmd")


io = manager:machine():ioport()
p1 = io.ports[":ctrl1:joypad:JOYPAD"]

inputs = {"P1 Right", "P1 Left", "P1 Down", "P1 Up","P1 Start", "P1 Select", "B", "A"}

local tileEnum = {
    unloadTile = "?",
    solidTile = "X",
    freeTile = ".",
    mario = "m",
	ennemy = "e"
}


function doesTableContain(table, val)
    for _, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

function printMatrix(matrix, w, h)
	for i=0, h-1 do
		s = ""
		for j=0, w-1 do
			s = s .. tostring(matrix[i][j]) .. " \t"
		end
		print(s)
	end
end

function printTable(table, len)
	s = ""
	for i=0, len-1 do
		s = s .. tostring(table[i]) .. " \t"
	end
	print(s)
end

function printFocus(mapFocus)
	for i=0, #mapFocus do
		s = ""
		for j=0, #mapFocus[i] do
			for k = 1, #mapFocus[i][j] do
				if k ~= 1 then
					s = s .. ", "
				end
				s = s .. tostring(mapFocus[i][j][k])
			end
			s = s  .. " \t"
		end
		print(s)
	end
end

local marioXOnScreenAddress = 0x86
local marioHorLevelPositionAddress = 0x6D
local marioYOnScreenAdress = 0x03B8

local ennemyXOnScreenAddress = 0x87
local ennemyHorLevelPositionAddress = 0x6E
local ennemyYOnScreenAdress = 0xCF
local ennemyPresentAdress = 0xF

local function getEntityX(xOnScreenAdress, HorLevelPoisitionAdress)
    return MameCmd.readMemory(HorLevelPoisitionAdress) * 0x100 + MameCmd.readMemory(xOnScreenAdress)
end

local function getEntityY(yOnScreen)
    return MameCmd.readMemory(yOnScreen)
end

local function getEntityXInTile(x)
	return x % (32*16) / 16
end

local function getEntityYInTile(y)
	return (y - 16)/16
end

function getMarioX()
	return getEntityX(marioXOnScreenAddress, marioHorLevelPositionAddress)
end

--- Prendre la round() de cette valeur pour avoir l'indice du x de Mario dans tilesSolid
function getMarioXInTile()
	return getEntityXInTile(getMarioX())
end

function getMarioY()
	return getEntityY(marioYOnScreenAdress)
end

function getMarioYInTile()
	return getEntityYInTile(getMarioY())
end



function getFocusArea(left_offset, right_offset)
	local mapFocus = {}
	local marioXIdx = getMarioXInTile()
	for y = 0, tilesH-1 do
		local mapFocusLine = {}
		for j = -left_offset, right_offset do
			local xIdx = math.floor((marioXIdx + j ) % tilesW)
			mapFocusLine[left_offset+j] = tilesSolid[y][xIdx]
		end
		mapFocus[y] = mapFocusLine
	end
	return mapFocus
end


--MameCst.emu.register_frame(
		function zae()
			print()
			printFocus(mapFocus)
		end
--)

tilesStart = 0x0500
tilesEnd = 0x069F
tilesW = 32
tilesH = 13
-- Petite subtilité qu'il y à une coupure
-- C'est divisé en 2 tableau de taille 16 x 13 mis de manière contigue

tilesSolid = {}
for i=0, tilesH-1 do
	tilesSolid[i] = {}
	for j=0, tilesW-1 do
		tilesSolid[i][j] = nil
	end
end



MameCst.emu.register_frame(
	function()
		local marioTileX = math.floor(getMarioXInTile())
		local marioTileY = math.floor(getMarioYInTile())

		local leftOffset = 6
		local rightOffset = 6

		mapFocus = {}
		for y=0, tilesH-1 do
			local mapFocusLine = {}
			for x= 0, leftOffset+rightOffset do
				mapFocusLine[x] = {}
			end
			mapFocus[y] = mapFocusLine
		end

		-- Add Mario
		if not(marioTileY < 0 or marioTileY >= tilesH or marioTileX < 0) then
			local focusMarioX = leftOffset
			table.insert(mapFocus[marioTileY][focusMarioX], tileEnum.mario)
		end

		-- Add ennemies
		for i = 0, 4 do
			if MameCmd.readMemory(ennemyPresentAdress + i) == 1 then
				local ennemyX = getEntityX(ennemyXOnScreenAddress+i, ennemyHorLevelPositionAddress+i)
				local ennemyY = getEntityY(ennemyYOnScreenAdress+i)
				local ennemyXTile = math.floor(getEntityXInTile(ennemyX))
				local ennemyYTile = math.floor(getEntityYInTile(ennemyY))

				local focusEnnemyXTile = leftOffset+(ennemyXTile-marioTileX)

				-- filter ennemies that are out of the view
				if (focusEnnemyXTile < leftOffset+rightOffset and focusEnnemyXTile > 0 and ennemyYTile > 0 and ennemyYTile < tilesH) then
					table.insert(mapFocus[ennemyYTile][focusEnnemyXTile], tileEnum.ennemy)
				end
			end
		end

		-- Add solid entities
		local tileW2 = tilesW/2
		for y=0, tilesH-1 do
			for x = -leftOffset, rightOffset do
				local offsetX = (marioTileX + x)%tilesW
				local dataToAdd = tileEnum.unloadTile

					local tileAddress = tilesStart + y*tileW2 + offsetX
					if (offsetX >= tileW2) then
						tileAddress = tileAddress + (tileW2) * (tilesH-1)
                    end
					local tileVal = MameCmd.readMemory(tileAddress)
					if tileVal == 0 then
						dataToAdd = tileEnum.freeTile
					else
						dataToAdd = tileEnum.solidTile
					end
				table.insert(mapFocus[y][x+leftOffset], dataToAdd)
			end
		end

 	end
)

MameCst.emu.register_frame_done(
    function()
        local s = MameCst.screen

        local squareSize = 4
        local map = mapFocus
        if (map == nil) then
            return
        end
        local h = #map
        local w = #map[1]
        local xOffset = 4
        local yOffset = 4
		local colorTransparency = 0xa0000000
        for y=0, h do
            for x =0, w do
                local color = 0
                local currentMapTiles = map[y][x]
                if doesTableContain(currentMapTiles, tileEnum.solidTile) then
                    color = 0x00000000
                elseif doesTableContain(currentMapTiles, tileEnum.mario) then
                    color = 0x00ff0000
				elseif doesTableContain(currentMapTiles, tileEnum.ennemy) then
					color = 0x0000ff00
                else
                    color = 0x00ffffff
                end
				color = color + colorTransparency
                s:draw_box(
                        xOffset+x*squareSize,
                        yOffset+y*squareSize,
                        xOffset+x*squareSize+squareSize,
                        yOffset+y*squareSize+squareSize,
                        color,
                        0xffffffff)
            end
        end

    end
)

--[[
MameCst.emu.register_frame(
    function () -- refresh the solid tile table
        for i=0, tilesH-1 do
			for j=0, tilesW-1 do
				tileAdr = tilesStart + (i)*(tilesW/2) + (j)
				if (j >= 16) then
					tileAdr = tileAdr + (tilesW/2) * (tilesH-1)
				end
				tileVal = MameCmd.readMemory(tileAdr)
				-- il faudra surement ici faire la  distinction entre différents objets
				-- ex : pièces etc.
				tilesSolid[i][j] = tileVal ~= 0

			end
		end
    end
)]]

