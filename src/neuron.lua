---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by LoanSens.
--- DateTime: 20/06/2018 21:09
---

require("class")

Neuron = class(function(this, map, tileMapX, tileMapY, tileContentExpect, inputsManager, inputIdx, p1Ports)
    --- The map
    this.map = map
    --- The tile x position based on map
    this.tileMapX = tileMapX
    this.tileMapY = tileMapY
    --- The tile which is expected at (tileMapX, tileMapY) position to activate the input
    this.tileContentExpect = tileContentExpect

    --- The input manager
    this.inputMan = inputsManager
    --- The input index
    this.inputIdx = inputIdx

    this.p1Ports = p1Ports
    this.isActive = false
end)

--- Check wherever the tile at the map is the one expected by the neuron
--- If it is, it presses the button to which it is map to
function Neuron:check()
    self.isActive = false
    if (self.map:contains(self.tileMapX, self.tileMapY, self.tileContentExpect)) then
        self.p1Ports.fields[inputsNes[self.inputIdx]]:set_value(1)
        self.isActive = true
    end
end

function Neuron:draw(screen)
    local tile = self.map:getTile(self.tileMapX, self.tileMapY)
    local tileX = tile:getDrawCenterX()
    local tileY = tile:getDrawCenterY()

    local inputX = self.inputMan:getDrawCenterX(self.inputIdx)
    local inputY = self.inputMan:getDrawCenterY(self.inputIdx)

    local desiredTile = Tile()
    desiredTile:add(self.tileContentExpect)

    local lineColor = desiredTile:getColor()
    lineColor = lineColor & 0x00ffffff -- delete transparency
    lineColor = lineColor + 0x2f000000

    if (self.isActive) then
        lineColor = lineColor + 0x7f000000
    end

    screen:draw_line(tileX, tileY, inputX, inputY, lineColor)
end

function Neuron:__tostring()
    local ret = ""
    ret = ret .. "<" .. self.tileContentExpect .. " (" .. self.tileMapX .. ", " .. self.tileMapY .. "), " .. self.inputIdx .. ">"
    return ret
end