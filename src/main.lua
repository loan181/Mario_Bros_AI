--
-- Created by IntelliJ IDEA.
-- User: Loan
-- Date: 3/29/2018
-- Time: 9:54 PM
--

package.path = ";LUA\\src\\?.lua;" .. package.path

--MarioBros = require("marioBros")
local MameCst = require("mameLuaConstants")
require("tile")
require("inputs")
require("creature")
require("neuron")
require("mapView")
require("generation")
require("mameController")



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

local map = MapView(6, 6, 13, MameCst.screen, 4, 4, 4)

local inputsManager = Inputs(MameCst.screen, 120, 4, 4, 2, MameCst.ioP1)

--local neuron = Neuron(map, 10, 12, tileEnum.solidTile, inputsManager, 1, MameCst.ioP1)
--local neuron2 = Neuron(map, 10, 8, tileEnum.solidTile, inputsManager, 8, MameCst.ioP1)
--local neuron3 = Neuron(map, 8, 10, tileEnum.solidTile, inputsManager, 8, MameCst.ioP1)
--local neuron4 = Neuron(map, 10, 12, tileEnum.freeTile, inputsManager, 8, MameCst.ioP1)
--local neuron5 = Neuron(map, 9, 11, tileEnum.enemy, inputsManager, 8, MameCst.ioP1)
--local creature = Creature(map, inputsManager, {neuron, neuron2, neuron3, neuron4}, MameCst.screen, MameCst.ioP1, 160, 4)

local gen = Generation(5, map, inputsManager)
gen:randomizeAll()

local mameController = MameController(map, inputsManager, gen, 3)
mameController:registerFrame()
mameController:registerFrameDone()



