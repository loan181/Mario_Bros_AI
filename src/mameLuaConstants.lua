---
--- Created by Loan.
--- DateTime: 2/26/2018 5:32 PM
---

local MameLuaCst = {}

local emu = emu
MameLuaCst.emu = emu

local machine = manager:machine()
MameLuaCst.machine = machine

local cpu = machine.devices[":maincpu"]
MameLuaCst.cpu = cpu

local mem = cpu.spaces["program"]
MameLuaCst.mem = mem

local ui = mame_manager:ui()
MameLuaCst.ui = ui

local screen = machine.screens[":screen"]
MameLuaCst.screen = screen

local video = machine:video()
MameLuaCst.video = video

local io = machine:ioport()
MameLuaCst.io = io

local p1 = io.ports[":ctrl1:joypad:JOYPAD"]
MameLuaCst.ioP1 = p1

return MameLuaCst