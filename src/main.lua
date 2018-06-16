--
-- Created by IntelliJ IDEA.
-- User: Loan
-- Date: 3/29/2018
-- Time: 9:54 PM
--

package.path = ";LUA\\src\\?.lua;" .. package.path

--MarioBros = require("marioBros")
local MameCst = require("mameLuaConstants")
local MameCmd = require("mameCmd")
require("tile")

local inputs = {"P1 Right", "P1 Left", "P1 Down", "P1 Up","P1 Start", "P1 Select", "B", "A"}




function doesTableContain(table, val)
    for _, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

function printMatrix(matrix, w, h)
	for i=1, h do
		s = ""
		for j=1, w do
			s = s .. tostring(matrix[i][j]) .. " \t"
		end
		print(s)
	end
end

function printTable(table, len)
	s = ""
	for i=1, len do
		s = s .. tostring(table[i]) .. " \t"
	end
	print(s)
end

function printFocus(mapFocus)
	for i=1, #mapFocus do
		s = ""
		for j=1, #mapFocus[i] do
			s = s .. tostring(mapFocus[i][j]) .. "\t"
		end
		print(s)
	end
end

local marioXOnScreenAddress = 0x86
local marioHorLevelPositionAddress = 0x6D
local marioYOnScreenAdress = 0x03B8

local enemyXOnScreenAddress = 0x87
local enemyHerLevelPositionAddress = 0x6E
local enemyYOnScreenAdress = 0xCF
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
	return y/16
end

local function getMarioX()
	return getEntityX(marioXOnScreenAddress, marioHorLevelPositionAddress)
end

local function getMarioXInTile()
	return getEntityXInTile(getMarioX())
end

local function getMarioY()
	return getEntityY(marioYOnScreenAdress)
end

local function getMarioYInTile()
	return getEntityYInTile(getMarioY())
end

local tilesStart = 0x0500
local tilesW = 32
local tilesH = 13
-- Petite subtilité qu'il y à une coupure
-- C'est divisé en 2 tableau de taille 16 x 13 mis de manière contigue


local squareSize = 4
local xOffset = 4
local yOffset = 4

local leftOffset = 6
local rightOffset = 6
local mapFocus = {}
for y = 1, tilesH do
    local mapFocusLine = {}
    for x = 1, leftOffset + rightOffset + 1 do
        local tile = Tile(
                MameCst.screen,
                xOffset + (x - 1) * squareSize,
                yOffset + (y - 1) * squareSize,
                squareSize
        )
        mapFocusLine[x] = tile
    end
    mapFocus[y] = mapFocusLine
end



MameCst.emu.register_frame(
	function()
		local marioTileX = math.floor(getMarioXInTile())
		local marioTileY = math.floor(getMarioYInTile())

		for y=1, tilesH do
			for x= 1, leftOffset+rightOffset+1 do
				mapFocus[y][x]:reset()
			end
		end

		-- Add Mario
		if not(marioTileY <= 0 or marioTileY >= tilesH or marioTileX < 0) then
			local focusMarioX = leftOffset+1
			mapFocus[marioTileY][focusMarioX]:add(tileEnum.mario)
		end

		-- Add ennemies
		for i = 1, 5 do
			if MameCmd.readMemory(ennemyPresentAdress + (i-1)) == 1 then
				local ennemyX = getEntityX(enemyXOnScreenAddress +(i-1), enemyHerLevelPositionAddress +(i-1))
				local ennemyY = getEntityY(enemyYOnScreenAdress +(i-1))
				local ennemyXTile = math.floor(getEntityXInTile(ennemyX))
				local ennemyYTile = math.floor(getEntityYInTile(ennemyY))

				local focusEnnemyXTile = leftOffset+1+(ennemyXTile-marioTileX)

				-- filter ennemies that are out of the view
				if (focusEnnemyXTile < leftOffset+2+rightOffset and focusEnnemyXTile > 0 and ennemyYTile > 0 and ennemyYTile < tilesH) then
					mapFocus[ennemyYTile][focusEnnemyXTile]:add(tileEnum.enemy)
				end
			end
		end

		-- Add solid entities
		local tileW2 = tilesW/2
		for y=1, tilesH do
			for x = -leftOffset, rightOffset do
				local offsetX = (marioTileX + x)%tilesW
				local dataToAdd = tileEnum.unloadTile

					local tileAddress = tilesStart + (y-1)*tileW2 + offsetX
					if (offsetX >= tileW2) then
						tileAddress = tileAddress + (tileW2) * (tilesH-1)
                    end
					local tileVal = MameCmd.readMemory(tileAddress)
					if tileVal == 0 then
						dataToAdd = tileEnum.freeTile
					else
						dataToAdd = tileEnum.solidTile
					end
				mapFocus[y][x+1+leftOffset]:add(dataToAdd)
			end
		end
 	end
)

MameCst.emu.register_frame_done(
    function()
        local s = MameCst.screen

        local function drawMap()
            local map = mapFocus
            for y=1, #map do
                for x =1, #map[y] do
                	map[y][x]:draw()
				end
            end
        end
        drawMap()


        local function drawInputs()
            local xOffset = 120
            local yOffset = 4
            local squareSize = 4
            local space = 2

			local currentPressInput = MameCst.ioP1:read()

            for y = 1, #inputs do
				local bitVal = (2^(#inputs-y))
				local isPressed = currentPressInput & bitVal == bitVal
                local yRealOffset = yOffset+y*space+y*squareSize

				local boxColor = 0x80ffffff
				if isPressed then
					boxColor = 0xcc000000
				end
                s:draw_box(xOffset,
                        yRealOffset,
                        xOffset+squareSize,
                        yRealOffset+squareSize,
						boxColor,
                        0xccffffff)
                s:draw_text(xOffset+squareSize+space+0.5, yRealOffset-2, inputs[y], 0xff000000)
                s:draw_text(xOffset+squareSize+space, yRealOffset-2, inputs[y])
            end

        end
        drawInputs()
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

