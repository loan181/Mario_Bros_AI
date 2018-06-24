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
require("inputs")
require("creature")
require("neuron")
require("mapView")
require("generation")



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

local neuron = Neuron(map, 10, 12, tileEnum.solidTile, inputsManager, 1, MameCst.ioP1)
--local neuron2 = Neuron(map, 10, 8, tileEnum.solidTile, inputsManager, 8, MameCst.ioP1)
--local neuron3 = Neuron(map, 8, 10, tileEnum.solidTile, inputsManager, 8, MameCst.ioP1)
--local neuron4 = Neuron(map, 10, 12, tileEnum.freeTile, inputsManager, 8, MameCst.ioP1)
--local neuron5 = Neuron(map, 9, 11, tileEnum.enemy, inputsManager, 8, MameCst.ioP1)
--local creature = Creature(map, inputsManager, {neuron}, MameCst.screen, MameCst.ioP1, 160, 4)

local gen = Generation(5, map, inputsManager)
gen:randomizeAll()

local creature = gen:getNextCreature()
local lastFitness = 0
local timer = 0
local lastTimeOut = 0
MameCst.machine:load("start")


MameCst.emu.register_frame(
		function()
			timer = timer + 1
			-- Go to next creature if dead, or timeout keeping the same fitness
			local isTimeOut = timer - lastTimeOut >= 60*3 -- 8 seconds of timeout
			local curFitness = creature:getFitness()
			if (creature:isDead() or ( isTimeOut and lastFitness == curFitness)) then
				gen:creatureIsDead()
				MameCst.machine:load("start")
				creature = gen:getNextCreature()
				lastFitness = 0
				timer = 0
				lastTimeOut = 0
			elseif (isTimeOut and lastFitness ~= curFitness) then
				lastFitness = curFitness
				lastTimeOut = timer
			end

			map:update()
			creature:updateFitness()
			creature:updateNeurons()
		end
)

MameCst.emu.register_frame_done(
    function()
		map:draw()
		inputsManager:draw()
		if creature ~= nil then
			creature:draw()
		end
	end
)



