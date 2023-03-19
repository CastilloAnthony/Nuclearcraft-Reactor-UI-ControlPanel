--[[
	Developed by Anthony Castillo (Cao21745) 2/23/2020
	Designed and tested for use with OpenComputers-MC1.12.2-1.7.4.153.jar and NuclearCraft-2.17c-1.12.2.jar.
	This is still a work in progress so any suggestions will be taken into consideration.
	Email suggesttions to Cao21745@yahoo.com
	This script will require the nReactorFunctions.lua script and will draw a graphical user interface
	that helps visualize the inner workings of a reactor.
]]--

--Grab the necessary Modules
local component = require("component")
local event = require("event")
local tty = require("tty")
local nReactorFunctions = require("nReactorFunctions")
local term = require("term")
local thread = require("thread")
local computer = require("computer")
local gpu = component.gpu

--Initialize local variables
local isAuto = true
local enableSleep = true
local chartMode = true --True is power mode while false is heat mode
local x, y = 0, 0 --Initialize resolution components
local buttonSize = 0 --Initialize buttonSize
local maxSleepTime = 100
local currentStep = 0
local realTime1 = 0
local mcTime1 = 0

local powerList = {}	--Will store a bunch of power level values
local heatList = {}		--Will store a bunch of heat level values

local nReactorGUI = {}

function nReactorGUI.setupResolution() end
--Will set the resolution up to be the maximum it can possibly be, also localizes the max size to (x, y)
--Returns true if the resolution was changed or if the resolution was already at max, otherwise it return false

function nReactorGUI.bar(color1, posX, posY, sizeW, sizeH) end
--This will be the base for all the bars used in the reactor's UI

function nReactorGUI.button(color1, posX, posY, sizeW, sizeH) end
--This will be the base for any and all buttons in the UI

function nReactorGUI.buttonOperations() end
--This will provide the functionality of the on/off button, the auto button and the exit button, sleep button, as well as the increment and decrement buttons

function nReactorGUI.drawFrame() end
--Draws the frame of the bars, buttons, the info box and various other bits of system information

function nReactorGUI.drawBars() end
--This will draw the energy and heat bars

function nReactorGUI.drawButtons() end
--This will be used to draw the inner buttons of the on/off and auto buttons

function nReactorGUI.drawInfo() end
--This will write in the information for the information box

function nReactorGUI.drawChart() end
--This will draw a chart that will display the powerlevel or heatlevel of the reactor over time.

function nReactorGUI.screenSleep() end
--This will enable the GUI to fall asleep

function nReactorGUI.autoMode() end
--This function will be called whenever isAuto is true.

function nReactorGUI.manualMode() end
--This function will be called whenever isAuto is false.

function nReactorGUI.changeAutoState() end
--This funciton will change the state of the isAuto variable.

function nReactorGUI.changeSleepState() end
--This funciton will change the state of the isAuto variable.

function nReactorGUI.changeChartType() end
--This function will toggle the chart type between power and heat.

function nReactorGUI.drawIteration() end
--This function will be called to draw or redraw all the display elements to the screen.

function nReactorGUI.step() end
--This will be the primary controller for the GUI

function nReactorGUI.main() end
--This will initiate the GUI process

--[[local colors = {
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
} ]]--This is just for reference

function nReactorGUI.setupResolution()
	--Use the resolution to help position all of the UI elements
	--Also sets the resolution to the maximum that is possible
	local maxW, maxH = gpu.maxResolution()
	local w, h = gpu.getResolution()
	if (w ~= maxW) and (h ~= maxH) then
		gpu.setResolution(maxW, maxH)
		x, y = gpu.getResolution()
		return true
	elseif (w == maxW and h == maxH) then
		x, y = gpu.getResolution()
		return true
	else
		return false
	end
end --setupResolution

function nReactorGUI.bar(color1, posX, posY, sizeW, sizeH)
	gpu.setBackground(color1)
	gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end bar

function nReactorGUI.button(color1, posX, posY, sizeW, sizeH)
		gpu.setBackground(color1)
		gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end button

function nReactorGUI.buttonOperations() 
	local screenAddress, extra,touchX, touchY = event.pull(1, "touch")
	if (screenAddress ~= nil) then
		if ((touchX >= (x/10*8)) and (touchX <= (x/10*8+buttonSize*2))) and ((touchY >= (y/10*3)) and (touchY <= (y/10*3+buttonSize))) then 	--On/Off switch
			nReactorFunctions.changeReactorState()
			nReactorGUI.drawButtons()
		elseif ((touchX >= (x/10*7)) and (touchX <= (x/10*7+buttonSize*2))) and ((touchY >= (y/10*3)) and (touchY <= (y/10*3+buttonSize))) then	--Auto Switch button
			nReactorGUI.changeAutoState()
			nReactorGUI.drawButtons()
		elseif ((touchX >= (x/10*8)) and (touchX <= (x/10*8+4))) and ((touchY >= (y/10*9)) and (touchY <= (y/10*9+3))) then 					--Exit button
			if nReactorFunctions.checkState() then
				nReactorFunctions.changeReactorState()
			end
			term.setCursor(1,y)
			gpu.setBackground(0)
			print("Shutting down the reactor.")
			print("Exiting program")
			os.exit()
		elseif ((touchX >= (x/10*7+1)) and (touchX <= (x/10*7+7+1))) and ((touchY >= (y/10*5)) and (touchY <= (y/10*5+3))) then 				--Sleep mode button
			nReactorGUI.changeSleepState()
			nReactorGUI.drawButtons()
		elseif ((touchX >= (x/10*8+5)) and (touchX <= (x/10*8+5+5))) and ((touchY >= (y/10*5)) and (touchY <= (y/10*5+3))) then					--Increment sleep button
			maxSleepTime = maxSleepTime + 5
		elseif ((touchX >= (x/10*8)) and (touchX <= (x/10*8+5))) and ((touchY >= (y/10*5)) and (touchY <= (y/10*5+3))) then						--Decrement sleep button
			if maxSleepTime > 0 then
				maxSleepTime = maxSleepTime - 5
			end
		elseif ((touchX >= (x/10*8)) and (touchX <= (x/10*8+12))) and ((touchY >= (y/10*6)) and (touchY <= (y/10*6+3))) then					--Histograph button
			nReactorGUI.changeChartType()
			nReactorGUI.drawButtons()
		end
	end
end --end buttonOperations

function nReactorGUI.drawFrame()
	if (y/20 > x/20) then
		buttonSize = y/20
	else
		buttonSize = x/20
	end
	
	gpu.setForeground(0xF0F0F0)
	--Drawing the basic frame
	nReactorGUI.bar(0x5A5A5A, x/10, y/10, x/10*8, 3)						--Powerlevel Bar
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*2, x/10*8, 3)						--HeatLevel Bar
	
	nReactorGUI.bar(0x5A5A5A, x/10, y/20*6-1, 50, 9)						--Draws the info box frame
	--nReactorGUI.bar(0x5A5A5A, x/10, y/20*6-1, 50, 10)						--Draws the info box frame that includes an extra line
	--nReactorGUI.bar(0x5A5A5A, x/10+51, y/20*6-1, 50, 9)					--Draws the second info box frame
	
	nReactorGUI.button(0x5A5A5A, x/10*8, y/10*3, buttonSize*2, buttonSize)	--Enable/Disable Button
	nReactorGUI.button(0x5A5A5A, x/10*7, y/10*3, buttonSize*2, buttonSize)	--Auto/Manual Button
	nReactorGUI.drawButtons()												--Draw both inner buttons
	
	--Writing in the titles of the bars
	term.setCursor(x/10+1, y/10-1)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10-1, x/10*8, 1)
	term.write("Power Level")
	term.setCursor(x/10+1, y/10*2-1)
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*2-1, x/10*8, 1)
	term.write("Heat Level")
end --drawFrame

function nReactorGUI.drawBars()
	local widthEnergy = (x/10*8-2) * nReactorFunctions.checkEnergyLevel()
	local widthHeat = (x/10*8-2) * nReactorFunctions.checkHeatLevel()
	local energyChange = nReactorFunctions.currentStoredPower()
	local heatChange = nReactorFunctions.currentHeatLevel()
	table.insert(powerList, 1, nReactorFunctions.checkEnergyLevel())
	table.insert(heatList, 1, nReactorFunctions.checkHeatLevel())
	if (#powerList > x/10*6-2) then
		table.remove(powerList)
	end
	if (#heatList > x/10*6-2) then
		table.remove(heatList)
	end
	
	gpu.setBackground(0x5A5A5A)
	
	--Powerlevel wording
	term.setCursor(x/10+13, y/10-1)
	term.write("   ")
	term.setCursor(x/10+13, y/10-1)
	term.write(math.floor(nReactorFunctions.checkEnergyLevel()*100))
	term.setCursor(x/10+16, y/10-1)
	term.write("%")
	
	--Temperature level wording
	term.setCursor(x/10+13, y/10*2-1)
	term.write("   ")
	term.setCursor(x/10+13, y/10*2-1)
	term.write(math.floor(nReactorFunctions.checkHeatLevel()*100))
	term.setCursor(x/10+16, y/10*2-1)
	term.write("%")
	
	energyChange = energyChange - nReactorFunctions.currentStoredPower()
	if energyChange < 0 then
		nReactorGUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	elseif energyChange >= 0 then
		--nReactorGUI.bar(0x5A5A5A, x/10, y/10, x/10*8, 3)
		nReactorGUI.bar(0x5A5A5A, x/10+1, y/10+1, x/10*8-2, 1)
		nReactorGUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	else
		nReactorGUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	end
	
	heatChange = heatChange - nReactorFunctions.currentHeatLevel()
	if heatChange < 0 then
		nReactorGUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	elseif heatChange >= 0 then
		--nReactorGUI.bar(0x5A5A5A, x/10, y/10*2, x/10*8, 3)
		nReactorGUI.bar(0x5A5A5A, x/10+1, y/10*2+1, x/10*8-2, 1)
		nReactorGUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	else
		nReactorGUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	end
	
	gpu.setForeground(0xF0F0F0)
	gpu.setBackground(0x5A5A5A)
end --end drawBars
	
function nReactorGUI.drawButtons()
	if (nReactorFunctions.checkState()) then
		nReactorGUI.button(0x57A64E,x/10*8+1, y/10*3+1, buttonSize*2-2, buttonSize-2) 	--Innerbox
		term.setCursor(x/10*8+buttonSize-2,y/10*3+buttonSize/2)
		term.write("Enabled")												--Writing the words in
	elseif (nReactorFunctions.checkState() ~= true) then
		nReactorGUI.button(0xC3C3C3,x/10*8+1, y/10*3+1, buttonSize*2-2, buttonSize-2) 	--Innerbox
		term.setCursor(x/10*8+buttonSize-2,y/10*3+buttonSize/2)
		term.write("Disabled")												--Writing the words in
	end
	
	if (isAuto) then
		nReactorGUI.button(0x57A64E,x/10*7+1, y/10*3+1, buttonSize*2-2, buttonSize-2) 	--Innerbox
		term.setCursor(x/10*7+buttonSize-2,y/10*3+buttonSize/2)
		term.write("Auto")												--Writing the words in
	elseif (isAuto ~= true) then
		nReactorGUI.button(0xC3C3C3,x/10*7+1, y/10*3+1, buttonSize*2-2, buttonSize-2) 	--Innerbox
		term.setCursor(x/10*7+buttonSize-2,y/10*3+buttonSize/2)
		term.write("Manual")												--Writing the words in
	end
	
	nReactorGUI.button(0x5A5A5A, x/10*8, y/10*9, 6, 3)						--Draw Exit button
	term.setCursor(x/10*8+1, y/10*9+1)
	term.write("Exit")
	
	nReactorGUI.button(0x5A5A5A, x/10*7+1, y/10*5, 7, 3)						--Draw Sleep Button
	if enableSleep then
		term.setCursor(x/10*7+1+1, y/10*5+1)
		gpu.setBackground(0x999999)
		term.write("Sleep")
	else
		term.setCursor(x/10*7+1+1, y/10*5+1)
		gpu.setBackground(0xC3C3C3)
		term.write("Sleep")
	end
	
	nReactorGUI.button(0xC3C3C3, x/10*8+5, y/10*5, 5, 3)						--Draw Sleep Increment Button
	term.setCursor(x/10*8+5+2, y/10*5+1)
	term.write("+")
	nReactorGUI.button(0x5A5A5A, x/10*8, y/10*5, 5, 3)					--Draw Sleep Decrement Button
	term.setCursor(x/10*8+2, y/10*5+1)
	term.write("-")
	
	nReactorGUI.button(0x5A5A5A, x/10*8, y/10*6, 12, 3)
	nReactorGUI.button(0x5A5A5A, x/10*8, y/10*6+1, 10, 1)						--Draw Histograph(chart) Button
	term.setCursor(x/10*8+1, y/10*6+1)
	if chartMode then
		gpu.setBackground(0xCC4C4C)
		term.write("Histograph")
	else
		gpu.setBackground(0xF2B233)
		term.write("Histograph")
	end
	
end --end drawButtons

function nReactorGUI.drawInfo() 
	local infoBoxPositionY = y/20*6
	gpu.setBackground(0x5A5A5A)
	local time1 = computer.uptime()
	local time2 = 0
	
	term.setCursor(x/10+1, infoBoxPositionY)
	term.write("Current Fuel:")
	term.setCursor(x/10+26, infoBoxPositionY)
	term.write("              ")				--Clears the previously stated information (using 14 spaces)
	term.setCursor(x/10+26, infoBoxPositionY)
	term.write(nReactorFunctions.fuelName())
	
	term.setCursor(x/10+1, infoBoxPositionY+1)
	term.write("Power Output:")
	term.setCursor(x/10+26, infoBoxPositionY+1)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+1)
	term.write(tostring(nReactorFunctions.powerOutput()))
	term.setCursor(x/10+41, infoBoxPositionY+1)
	term.write("RF/T")
	
	term.setCursor(x/10+1, infoBoxPositionY+2)
	term.write("Power Draw:")
	term.setCursor(x/10+26, infoBoxPositionY+2)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+2)
	term.write(tostring((math.floor(nReactorFunctions.checkEnergyChange()))*(-1)))
	term.setCursor(x/10+41, infoBoxPositionY+2)
	term.write("RF/T")
	
	term.setCursor(x/10+1, infoBoxPositionY+3)
	term.write("Currently Stored Power:")
	term.setCursor(x/10+26, infoBoxPositionY+3)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+3)
	term.write(tostring(math.floor(nReactorFunctions.currentStoredPower())))
	term.setCursor(x/10+41, infoBoxPositionY+3)
	term.write("RF")
	
	term.setCursor(x/10+1, infoBoxPositionY+4)
	term.write("Burn Time Remaining:")
	term.setCursor(x/10+26, infoBoxPositionY+4)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+4)
	term.write(tostring(math.floor(nReactorFunctions.remainingProcessTime())))
	term.setCursor(x/10+41, infoBoxPositionY+4)
	term.write("Ticks")
	
	term.setCursor(x/10+1, infoBoxPositionY+5)
	term.write("Reactor Efficiency:")
	term.setCursor(x/10+26, infoBoxPositionY+5)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+5)
	term.write(tostring(math.floor(nReactorFunctions.efficiency())))
	term.setCursor(x/10+41, infoBoxPositionY+5)
	term.write("%")
	
	term.setCursor(x/10+1, infoBoxPositionY+6)
	term.write("Reactor Heat Output:")
	term.setCursor(x/10+26, infoBoxPositionY+6)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+6)
	term.write(tostring(math.floor(nReactorFunctions.checkProcessHeat())))
	
	--[[
	term.setCursor(x/10+1, infoBoxPositionY+7)
	term.write("Real Heat Change:")
	term.setCursor(x/10+26, infoBoxPositionY+7)
	term.write("              ")
	term.setCursor(x/10+26, infoBoxPositionY+7)
	term.write(tostring(nReactorFunctions.checkProcessHeat()*(computer.uptime()-realTime1)/0.05/nReactorFunctions.checkMaxHeatLevel()*100))
	term.setCursor(x/10+41, infoBoxPositionY+7)
	term.write("%")
	]] --Omitting this until I can figure out the best math to use for it.
	
	if enableSleep then
		nReactorGUI.bar(0x5A5A5A, x/10*7+1, y/10*5-1, x/10*2-1, 1)
		term.setCursor(x/10*7+1,y/10*5-1)
		gpu.setBackground(0x5A5A5A)
		term.write("Time until sleep:")
		term.setCursor(x/10*7+18+1, y/10*5-1)
		term.write(maxSleepTime-currentStep)
		term.setCursor(x/10*7+25+1, y/10*5-1)
		term.write("/")
		term.write(maxSleepTime)
	else
		nReactorGUI.button(0x5A5A5A, x/10*7+1, y/10*5-1, x/10*2-1, 1)
		term.setCursor(x/10*7+1,y/10*5-1)
		gpu.setBackground(0x5A5A5A)
		term.write("Sleep Disabled")
	end
	
	term.setCursor(1, y)
	gpu.setBackground(0)
	term.write("Version: 1.0")
end --end drawInfo

function nReactorGUI.drawChart()
	local position = 0
	local maxPosition = x/10*6-2
	local barSize = 0
	nReactorGUI.bar(0x5A5A5A, x/10, y/10*5, x/10*6, y/10*5) --Box outline
	if chartMode then
		for k in pairs(powerList) do 
			if (position < maxPosition) and  (powerList[k] ~= nil) then
					barSize = math.floor(((y/10*5)-2)*powerList[k])
					nReactorGUI.bar(0xCC4C4C, x/10+1+position, y-1-barSize, 1, barSize)
			else
				table.remove(powerList)
			end
			position = position + 1
		end
	else
		for k in pairs(heatList) do
			if (position < maxPosition) and (heatList[k] ~= nil) then
				barSize = math.floor(((y/10*5)-2)*heatList[k])
				nReactorGUI.bar(0xF2B233, x/10+1+position, y-1-barSize, 1, barSize)
			else
				table.remove(heatList)
			end
			position = position + 1
		end
	end
end --end drawChart

function nReactorGUI.screenSleep()
	gpu.setBackground(0)
	tty.clear()
	repeat
	nReactorFunctions.auto()
	table.insert(powerList, 1, nReactorFunctions.checkEnergyLevel())
	table.insert(heatList, 1, nReactorFunctions.checkHeatLevel())
	while (#powerList > x/10*6-2) do
		table.remove(powerList)
	end
	while (#heatList > x/10*6-2) do
		table.remove(heatList)
	end
	until (event.pullMultiple(1, "motion", "touch") ~= nil)
end --end screenSleep

function nReactorGUI.autoMode()
	nReactorFunctions.auto()
	nReactorGUI.drawButtons()
	nReactorGUI.drawIteration()
end --end auto

function nReactorGUI.manualMode()
	nReactorGUI.drawIteration()
 end --end manualMode

function nReactorGUI.changeAutoState()
	if isAuto then
		isAuto = false
	else
		isAuto = true
	end
end --end changeAutoState

function nReactorGUI.changeSleepState()
	if enableSleep then
		enableSleep = false
	else
		enableSleep = true
	end
end --end changeSleepState

function nReactorGUI.changeChartType()
	if chartMode then
		chartMode = false --Sets the chart to heat mode
	else
		chartMode = true --Sets the chart to power mode
	end
end --end changeChartType

function nReactorGUI.drawIteration() 
	nReactorGUI.drawInfo()
	nReactorGUI.drawBars()
	nReactorGUI.drawChart()
	nReactorGUI.buttonOperations()
end --end drawIteration

function nReactorGUI.step()
	gpu.setBackground(0)
	tty.clear()
	if nReactorGUI.setupResolution() then
		nReactorGUI.drawFrame()
		repeat
		realTime1 = computer.uptime()
		mcTime1 = os.time() * 1000/60/60 - 6000
		nReactorGUI.buttonOperations()
		if isAuto then nReactorGUI.autoMode() else nReactorGUI.manualMode() end 
		
		gpu.setBackground(0)
		term.setCursor(1, 1)
		term.write("     ")
		term.setCursor(1, 1)
		term.write(computer.uptime() - realTime1)
		term.setCursor(6, 1)
		term.write("Seconds per step")
		
		if enableSleep then currentStep=currentStep+1 end --Increment sleep timer if sleep is allowed
		until (currentStep > maxSleepTime)
		currentStep = 0
		if enableSleep then
			if isAuto then
				nReactorGUI.screenSleep()
			else
				gpu.setBackground(0)
				repeat tty.clear() until (event.pullMultiple(1, "motion", "touch") ~= nil)
			end
		end
		os.sleep(0) --Garbage Clean Up
		nReactorGUI.step()
	else
		gpu.setBackground(0)
		print("Could not setup the Resolution")
	end
end --end step

function nReactorGUI.main()
	isAuto = true 				--Reinitialize auto function to true
	x, y = 0, 0					--Reinitialize resolution components
	buttonSize = 0 				--Reinitialize buttonSize
	nReactorGUI.step()
	gpu.setBackground(0)
	term.setCursor(1, y)
	if nReactorFunctions.checkState() then
			print("Shutting down the reactor.")
			nReactorFunctions.changeReactorState()
	end
	print("Exiting Program.")
end --end main

return nReactorGUI
