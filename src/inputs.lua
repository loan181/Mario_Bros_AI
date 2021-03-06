---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by LoanSens.
--- DateTime: 20/06/2018 21:22
---

inputsNes = {"P1 Right", "P1 Left", "P1 Down", "P1 Up", "P1 Start", "P1 Select", "B", "A"}


Inputs = class(function(this, screen, xOffset, yOffset, squareSize, space, ioP1)
    this.drawScreen = screen
    this.drawXOffset = xOffset
    this.drawYOffset = yOffset
    this.drawSquareSize = squareSize
    this.drawSpace = space

    this.ioP1 = ioP1
end)

function Inputs:draw()
    for i, v in pairs(inputsNes) do
        self:drawInput(i)
    end
end

function Inputs:isInputPress(inputNesIdx)
    local isPressed = false
    local currentPressInput = self.ioP1:read()
    local bitVal = (2^(#inputsNes-inputNesIdx))
    isPressed = currentPressInput & bitVal == bitVal
    return isPressed
end

function Inputs:getDrawCenterX(inputNesIdx)
    return self.drawXOffset + (self.drawSquareSize/2)
end

function Inputs:getDrawCenterY(inputNesIdx)
    local yRealOffset = self.drawYOffset+inputNesIdx*self.drawSpace+inputNesIdx*self.drawSquareSize
    return yRealOffset + (self.drawSquareSize/2)
end

function Inputs:drawInput(inputNesIdx)
    local inputNes = inputsNes[inputNesIdx]

    local boxColor = 0x80ffffff
    if self:isInputPress(inputNesIdx) then
        boxColor = 0xcc000000
    end

    local yRealOffset = self.drawYOffset+inputNesIdx*self.drawSpace+inputNesIdx*self.drawSquareSize

    local s = self.drawScreen
    s:draw_box(self.drawXOffset,
            yRealOffset,
            self.drawXOffset+self.drawSquareSize,
            yRealOffset+self.drawSquareSize,
            boxColor,
            0xccffffff)
    s:draw_text(self.drawXOffset+self.drawSquareSize+self.drawSpace+0.5, yRealOffset-2, inputNes, 0xff000000)
    s:draw_text(self.drawXOffset+self.drawSquareSize+self.drawSpace, yRealOffset-2, inputNes)

end


