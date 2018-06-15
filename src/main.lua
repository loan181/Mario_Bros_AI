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

function printMap()
	local marioX = math.floor(getMarioXInTile())
	local marioY = math.floor(getMarioYInTile())
	for i=0, tilesH-1 do
		s = ""
		for j=0, tilesW-1 do
			if (tilesSolid[i][j]) then
				s = s .. "X"
			else
				if(i == marioY and j == marioX) then
					s = s .. "m"
				else
					s = s .. " "
				end

			end
		end
		print(s)
	end
end

function getMarioX()
	local marioX = MameCmd.readMemory(0x6D) * 0x100 + MameCmd.readMemory(0x86)
	return marioX
end

--- Prendre la round() de cette valeur pour avoir l'indice du x de Mario dans tilesSolid
function getMarioXInTile()
	local x = getMarioX()
	local subx = x % (32*16) / 16
	return subx
end

function getMarioY()
	local marioY = MameCmd.readMemory(0x03B8)
	return marioY
end

function getMarioYInTile()
	local y = getMarioY()
	local suby = (y - 16)/16
	return suby
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


MameCst.emu.register_frame(
		function ()
			print()
			printFocus(mapFocus)
		end
)

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
			local focusMarioX = leftOffset+1
			table.insert(mapFocus[marioTileY][focusMarioX], "m")
		end

		-- Add solid entities
		local tileW2 = tilesW/2
		for y=0, tilesH-1 do
			for x = -leftOffset, rightOffset do
				local offsetX = marioTileX + x
				local dataToAdd = "?"
				if (offsetX >= 0) then
					local tileAddress = tilesStart + (y)*(tileW2) + (offsetX)
					if (offsetX >= tileW2) then
						tileAddress = tileAddress + (tileW2) * (tilesH-1)
					end
					local tileVal = MameCmd.readMemory(tileAddress)
					if tileVal == 0 then
						dataToAdd = "."
					else
						dataToAdd = "X"
					end
				end
				table.insert(mapFocus[y][x+leftOffset], dataToAdd)
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

