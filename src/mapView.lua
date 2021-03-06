---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Loan.
--- DateTime: 24/06/2018 15:24
---

local MameCmd = require("mameCmd")
require("class")
require("tile")

local tilesStart = 0x0500
local tilesW = 32
local tilesH = 13

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

--- The view of the map used by the IA
MapView = class(function(this, leftOffset, rightOffset, height, drawScreen, drawX, drawY, drawTileSize)

    this.leftOffset = leftOffset
    this.rightOffset = rightOffset
    this.height = height
    this.map = {}
    --- Init the map
    for y = 1, height do
        local mapFocusLine = {}
        for x = 1, this:getW() do
            local tile = Tile(
                    drawScreen,
                    drawX + (x - 1) * drawTileSize,
                    drawY + (y - 1) * drawTileSize,
                    drawTileSize
            )
            mapFocusLine[x] = tile
        end
        this.map[y] = mapFocusLine
    end

    this.marioX = nil
    this.marioY = nil
end)

function MapView:getW()
    return self.leftOffset + self.rightOffset + 1
end

function MapView:update()
    -- Reset it first
    self:resetMap()
    self:updateMemoryInformation()

    -- Then add different elements
    self:addMario()
    self:addEnemies()
    self:addSolidEntities()
end

function MapView:resetMap()
    for y=1, #self.map do
        for x =1, #self.map[y] do
            self.map[y][x]:reset()
        end
    end
end

function MapView:getMarioX()
    return getMarioX()
end

function MapView:updateMemoryInformation()
    self.marioX = math.floor(getMarioXInTile())
    self.marioY = math.floor(getMarioYInTile())
end

function MapView:addMario()
    if not(self.marioY <= 0 or self.marioY >= self.height) then
        local focusMarioX = self.leftOffset+1
        self.map[self.marioY][focusMarioX]:add(tileEnum.mario)
    end
end

function MapView:addEnemies()
    for i = 1, 5 do
        if MameCmd.readMemory(ennemyPresentAdress + (i-1)) == 1 then
            local ennemyX = getEntityX(enemyXOnScreenAddress +(i-1), enemyHerLevelPositionAddress +(i-1))
            local ennemyY = getEntityY(enemyYOnScreenAdress +(i-1))
            local ennemyXTile = math.floor(getEntityXInTile(ennemyX))
            local ennemyYTile = math.floor(getEntityYInTile(ennemyY))

            local focusEnnemyXTile = self.leftOffset+1+(ennemyXTile-self.marioX)

            -- filter ennemies that are out of the view
            if (focusEnnemyXTile < self.leftOffset+2+self.rightOffset and focusEnnemyXTile > 0 and ennemyYTile > 0 and ennemyYTile < self.height) then
                self.map[ennemyYTile][focusEnnemyXTile]:add(tileEnum.enemy)
            end
        end
    end
end

function MapView:addSolidEntities()
    local tileW2 = tilesW/2
    for y=1, tilesH do
        for x = -self.leftOffset, self.rightOffset do
            local offsetX = (self.marioX + x)%tilesW
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
            self.map[y][x+1+self.leftOffset]:add(dataToAdd)
        end
    end
end

function MapView:getTile(x, y)
    return self.map[y][x]
end

--- Does the tiles at (x, y) position contains a tile value
function MapView:contains(x, y, tile)
    return self:getTile(x, y):contains(tile)
end

function MapView:draw()
    for y=1, #self.map do
        for x=1, #self.map[y] do
            self.map[y][x]:draw()
        end
    end
end

function MapView:__tostring()
    local s = ""
    for i=1, #self.map do
        for j=1, #self.map[i] do
            s = s .. tostring(self.map[i][j]) .. "\t"
        end
        s = s .. "\n"
    end
    return s
end