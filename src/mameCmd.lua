---
--- Created by Loan.
--- DateTime: 2/26/2018 5:43 PM
---

local MameCst = require("MameLuaConstants")

local ret = {}

--- Lis une adresse mémoire
--- @param bits : optionnel (8 par defaut)
local function readMemory(adress, bits)
    bits = bits or 8
    local val
    if (bits == 8) then
        val = MameCst.mem:read_i8(adress)
        if val < 0 then -- Interpret all byte as unsigned values
            val = val + 128 * 2
        end
    elseif (bits == 16) then
        val =  MameCst.mem:read_i16(adress)
    end
    return val
end
ret.readMemory = readMemory

--- Ecris à une adresse mémoire
--- @param bits : optionnel (8 par defaut)
local function writeMemory(adress, value, bits)
    bits = bits or 8
    if (bits == 8) then
        return MameCst.mem:write_i8(adress, value)
    elseif (bits == 16) then
        return MameCst.mem:write_i16(adress, value)
    end
end
ret.writeMemory = writeMemory

--- Créé une sauvegarde d'état
local function createSavestate(name)
    MameCst.machine:save(name)
end
ret.createSavestate = createSavestate

return ret