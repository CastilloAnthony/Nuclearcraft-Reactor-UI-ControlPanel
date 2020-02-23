--[[
	Developed by Anthony Castillo (Cao21745) 2/23/2020
	Designed and tested for use with OpenComputers-MC1.12.2-1.7.4.153.jar and NuclearCraft-2.17c-1.12.2.jar.
	This is still a work in progress so any suggestions will be taken into consideration.
	Email suggesttions to Cao21745@yahoo.com
	This script will require the nReactorFunctions.lua script and will draw a graphical user interface
	that helps visualize the inner workings of a reactor.
]]--

local component = require("component")
local event = require("event")
local tty = require("tty")
local nReactorFunctions = require("nReactorFunctions")
local term = require("term")
local thread = require("thread")
local gpu = component.gpu

local nReactorGUI = {}

function nReactorGUI.bar(color1, posX, posY, sizeW, sizeH) end
--This will be the base for all the bars used in the reactor's UI

function nReactorGUI.button() end --NOT IMPLEMENTED
--This will be the base for any and all buttons in the UI

function nReactorGUI.buttonOperation() end --NOT IMPLEMENTED
--This will provide the functionality of all the buttons

function nReactorGUI.setupResolution() end
--We'll set the resolution up to be the maximum it can possibly be
--Returns true if the resolution was changed or if the resolution was already at max, otherwise it return false

function nReactorGUI.drawFrame(x, y) end
--Draws the frame, this should only need to be called once

function nReactorGUI.drawBars(x, y) end
--This will draw the energy and power bars, it will probably be called far more often than anything else

function nReactorGUI.drawButtons() end --NOT IMPLEMENTED
--This will be used to draw the buttons

function nReactorGUI.screenSleep() end
--This will enable the GUI to fall asleep

function nReactorGUI.drawIteration() end
--This function will start the background monitoring of the nReactor

function nReactorGUI.main() end
--This will be the primary controller for the GUI

local colors = {
	white = 0xF0F0F0,
	orange = 0xF2B233,
	magenta = 0xE57FD8,
	lightBlue = 0x99B2F2,
	yellow = 0xDEDE6C,
	lime = 0x7FCC19,
	pink = 0xF2B2CC,
	gray = 0x4C4C4C,
	lightGray = 0x999999,
	cyan = 0x4C99B2,
	purple = 0xB266E5,
	blue = 0x3366CC,
	brown = 0x7F664C,
	green = 0x57A64E,
	red = 0xCC4C4C,
	black = 0,
} --This is just for reference

function nReactorGUI.setupResolution()
	--use the resolution to help position all of the UI elements
	local maxW, maxH = gpu.maxResolution()
	local w, h = gpu.getResolution()
	if (w ~= maxW) and (h ~= maxH) then
		gpu.setResolution(maxW, maxH)
		return true
	elseif (w == maxW and h == maxH) then
		return true
	else
		return false
	end
end --setupResolution

function nReactorGUI.drawFrame(x, y)
	gpu.setForeground(0xF0F0F0)
	--Drawing the basic frame
	nReactorGUI.bar(0x5A5A5A, x/10, y/10, x/10*8, 3)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*2, x/10*8, 3)
	
	--Writing in the titles of the bars
	term.setCursor(x/10+1, y/10-1)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10-1, x/10*8, 1)
	term.write("Power Level")
	term.setCursor(x/10+1, y/10*2-1)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*2-1, x/10*8, 1)
	term.write("Heat Level")
end --drawFrame

function nReactorGUI.drawBars(x, y)
	local widthEnergy = x/10*8 * nReactorFunctions.checkEnergyLevel()
	local widthHeat = x/10*8 * nReactorFunctions.checkHeatLevel()
	nReactorGUI.bar(0x5A5A5A, x/10, y/10, x/10*8, 3)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*2, x/10*8, 3)
	nReactorGUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	nReactorGUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	
	gpu.setForeground(0xF0F0F0)
	gpu.setBackground(0x5A5A5A)
	
	--Powerlevel wording
	term.setCursor(x/10+13, y/10-1)
	term.write(math.floor(nReactorFunctions.checkEnergyLevel()*100))
	term.setCursor(x/10+16, y/10-1)
	term.write("%")
	
	--Temperature level wording
	term.setCursor(x/10+13, y/10*2-1)
	term.write(math.floor(nReactorFunctions.checkHeatLevel()*100))
	term.setCursor(x/10+16, y/10*2-1)
	term.write("%")
	
	--Current reactor state wording
	gpu.setBackground(0)
	term.setCursor(x/10, y/20*7-1)
	term.write("Current State:")
	term.setCursor(x/10+25, y/20*7-1)
	term.write(tostring(nReactorFunctions.checkState()))
	if (nReactorFunctions.checkState()) then
		term.setCursor(x/10+29, y/20*7-1)
		term.write(" ")
	end
	
	--Current Fuel and Power Info
	term.setCursor(x/10, y/20*7)
	term.write("Current Fuel:")
	term.setCursor(x/10+25, y/20*7)
	term.write(nReactorFunctions.fuelName())
	term.setCursor(x/10, y/20*7+1)
	term.write("Power Output:")
	term.setCursor(x/10+25, y/20*7+1)
	term.write(tostring(nReactorFunctions.powerOutput()))
	term.setCursor(x/10+40, y/20*7+1)
	term.write("RF/T")
	term.setCursor(x/10, y/20*7+2)
	term.write("Currently Stored Power:")
	term.setCursor(x/10+25, y/20*7+2)
	term.write(tostring(math.floor(nReactorFunctions.currentStoredPower())))
	term.setCursor(x/10+40, y/20*7+2)
	term.write("RF")
	term.setCursor(x/10, y/20*7+3)
	term.write("Efficiency:")
	term.setCursor(x/10+25, y/20*7+3)
	term.write(tostring(math.floor(nReactorFunctions.efficiency())))
	term.setCursor(x/10+40, y/20*7+3)
	term.write("%")
	term.setCursor(x/10, y/20*7+4)
	term.write("Burn Time Remaining:")
	term.setCursor(x/10+25, y/20*7+4)
	term.write(tostring(math.floor(nReactorFunctions.remainingProcessTime()))
	term.setCursor(x/10+40, y/20*7+4)
	term.write("Ticks")
	end
end --end drawBars

function nReactorGUI.bar(color1, posX, posY, sizeW, sizeH)
	gpu.setBackground(color1)
	gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end bar

function nReactorGUI.screenSleep(x, y)
	gpu.setBackground(0)
	gpu.fill(1, 1, x, y, " ")
	tty.clear()
	repeat nReactorFunctions.auto() until (event.pullMultiple(1, "motion", "touch") ~= nil)
end --end screenSleep

function nReactorGUI.drawIteration() 
	local w, h = gpu.getResolution()
	local n = 0
	gpu.setBackground(0)
	tty.clear()
	if nReactorGUI.setupResolution() then
		nReactorGUI.drawFrame(w, h)
		repeat 
		nReactorFunctions.auto()
		nReactorGUI.drawBars(w, h)
		n=n+1 
		until (n > 100)
		nReactorGUI.screenSleep(w, h)
		nReactorGUI.drawIteration()
	else
		print("Could not setup the Resolution")
	end
end --end drawIteration

function nReactorGUI.main()
	nReactorGUI.drawIteration()
	if nReactorFunctions.checkState() then
	repeat nReactorFunctions.auto() until (nReactorFunctions.checkState() == false) 
	end
end --end main

return nReactorGUI