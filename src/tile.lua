
require("class")

tileEnum = {
    unloadTile = "?",
    solidTile = "X",
    freeTile = ".",
    mario = "m",
    enemy = "e"
}

--- Constuctor
Tile = class(function(this, screen, x, y, size)
    this.content = {}

    this.drawScreen = screen
    this.drawX = x
    this.drawY = y
    this.drawSize = size
end)

function Tile:printIt()
    print("Content : " .. tostring(self.content))
end

--- Clear the tile information
function Tile:reset()
    for k,_ in pairs(self.content) do
        self.content[k] = nil
    end
end

--- Add a tile content to the tile (can be free and with mario on it)
function Tile:add(tile)
    table.insert(self.content, tile)
end

--- Check wherever the tile contain a tile value
function Tile:contains(tileVal)
    for _, value in ipairs(self.content) do
        if value == tileVal then
            return true
        end
    end
    return false
end

function Tile:getDrawCenterX()
    return self.drawX+(self.drawSize/2)
end

function Tile:getDrawCenterY()
    return self.drawY+(self.drawSize/2)
end

function Tile:getColor()
    local color = 0xddffffff
    local colorTransparency = 0xa0000000

    if self:contains(tileEnum.solidTile) then
        color = 0x00000000
    elseif self:contains(tileEnum.mario) then
        color = 0x00ff0000
    elseif self:contains(tileEnum.enemy) then
        color = 0x0000ff00
    else
        color = 0x00ffffff
    end
    color = color + colorTransparency
    return color
end

--- Draw the tile on the given screen
function Tile:draw()
    if self.drawScreen == nil then
        return
    end


    self.drawScreen:draw_box(
            self.drawX,
            self.drawY,
            self.drawX+self.drawSize,
            self.drawY+self.drawSize,
            self:getColor(),
            0xffffffff)
end

--- get the middle point of the tile
function Tile:getDrawMiddle()
    return {
        x = self.drawX + self.drawSize/2,
        y = self.drawY + self.drawSize/2
    }
end

function Tile:__tostring()
    local ret = ""
    for k = 1, #self.content do
        if k ~= 1 then
            ret = ret .. ", "
        end
        ret = ret .. tostring(self.content[k])
    end
    return ret
end

