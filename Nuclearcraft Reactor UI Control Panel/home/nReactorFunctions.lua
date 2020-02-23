--[[
	Developed by Anthony Castillo (Cao21745) 2/23/2020
	Designed and tested for use with OpenComputers-MC1.12.2-1.7.4.153.jar and NuclearCraft-2.17c-1.12.2.jar.
	This is still a work in progress so any suggestions will be taken into consideration.
	Email suggesttions to Cao21745@yahoo.com
	This script will activate and deactivate a NuclearCraft reactor based on it's heat and energy levels.
	This will work independently of the GUI script. Simply make a call to the function nReactorFunctions.main() and it will automate the activation process.
	
]]--

local component = require("component")
local thread = require("thread")
local reactor = component.nc_fission_reactor

local nReactorFunctions = {}

function nReactorFunctions.checkState() end
--Will return true if the reactor is processing(on) or false if it is not processing(off)
--This function returns a boolean value (true or false)

function nReactorFunctions.checkEnergyLevel() end
--Will return the current energy level of the reactor
--This function returns a double (0.0100000)

function nReactorFunctions.checkHeatLevel() end
--Will return the current heat level of the reactor
--This function returns a double (0.0100000)

function nReactorFunctions.changeReactorState() end
--Will switch the reactor's active state

function nReactorFunctions.fuelName() end
--Returns the name of the current fuel being processed

function nReactorFunctions.remainingProcessTime() end
--Returns the remaining processing time for the current fuel type

function nReactorFunctions.efficiency() end
--Returns the efficiency of the current reactor setup

function nReactorFunctions.powerOutput() end
--Returns the power output of the reactor

function nReactorFunctions.currentStoredPower() end
--Returns the currently stored power

function nReactorFunctions.auto() end
--Will automate the reactor temperature and energy level monitoring

function nReactorFunctions.main() end
--This is the primary function that will control the reactor's processing

function nReactorFunctions.checkState()
	return reactor.isProcessing()
end --end checkState

function nReactorFunctions.checkEnergyLevel()
	return reactor.getEnergyStored() / reactor.getMaxEnergyStored()
end --end checkEnergyLevel

function nReactorFunctions.checkHeatLevel()
	return reactor.getHeatLevel() / reactor.getMaxHeatLevel()
end --end cheackHeatLevel

function nReactorFunctions.changeReactorState()
	if nReactorFunctions.checkState() == false then
		reactor.activate()
	else
		reactor.deactivate()
	end
end --end changeReactorState

function nReactorFunctions.fuelName()
	return reactor.getFissionFuelName()
end --end fuelName

function nReactorFunctions.efficiency() 
	return reactor.getEfficiency()
end --end efficiency

function nReactorFunctions.remainingProcessTime() 
	return (reactor.getFissionFuelTime() - reactor.getCurrentProcessTime())
end --end remainingProcessTime

function nReactorFunctions.powerOutput() 
	return reactor.getReactorProcessPower()
end --end powerOutput

function nReactorFunctions.currentStoredPower()
	return reactor.getEnergyStored()
end --end currentStoredPower

function nReactorFunctions.auto()
	if (nReactorFunctions.checkState() == false) and (nReactorFunctions.checkEnergyLevel() <= 0.20) and (nReactorFunctions.checkHeatLevel() <= 0.20)then
		nReactorFunctions.changeReactorState()
	elseif (nReactorFunctions.checkState()) and ((nReactorFunctions.checkEnergyLevel() >= 0.80) or (nReactorFunctions.checkHeatLevel() >= 0.80)) then
		nReactorFunctions.changeReactorState()
	end
end --end auto

function nReactorFunctions.autoWithoutMainUI()
	if (nReactorFunctions.checkState() == false) and (nReactorFunctions.checkEnergyLevel() <= 0.20) and (nReactorFunctions.checkHeatLevel() <= 0.20)then
		nReactorFunctions.changeReactorState()
		print("Reactor State:", nReactorFunctions.checkState(), "; Energy Level at:", nReactorFunctions.checkEnergyLevel() * 100, "%", "; ", "Heat Level at:" , nReactorFunctions.checkHeatLevel() * 100, "%")
	elseif (nReactorFunctions.checkState()) and ((nReactorFunctions.checkEnergyLevel() >= 0.80) or (nReactorFunctions.checkHeatLevel() >= 0.80)) then
		nReactorFunctions.changeReactorState()
		print("Reactor State:", nReactorFunctions.checkState(), "; Energy Level at:", nReactorFunctions.checkEnergyLevel() * 100, "%", "; ", "Heat Level at:" , nReactorFunctions.checkHeatLevel() * 100, "%")
	else
		print("Reactor State:", nReactorFunctions.checkState(), "; Energy Level at:", nReactorFunctions.checkEnergyLevel() * 100, "%", "; ", "Heat Level at:" , nReactorFunctions.checkHeatLevel() * 100, "%")
	end
	print("-------------------------------------------------------------------------------------------------------------------------------------------")
end --end auto

function nReactorFunctions.main()
	nReactorFunctions.autoWithoutMainUI()
	return nReactorFunctions.main()
end --end main

return nReactorFunctions