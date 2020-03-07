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

function nReactorFunctions.checkMaxHeatLevel() end
--Will return the maximum heat level of the reactor

function nReactorFunctions.checkEnergyChange() end
--Returns the power change

function nReactorFunctions.checkProcessHeat() end
--Returns the reactor's heat output in negative or positive

function nReactorFunctions.powerOutput() end
--Returns the power output of the reactor

function nReactorFunctions.currentStoredPower() end
--Returns the currently stored power

function nReactorFunctions.currentHeatLevel() end
--Returns the current heat level

function nReactorFunctions.fuelName() end
--Returns the name of the current fuel being processed

function nReactorFunctions.remainingProcessTime() end
--Returns the remaining processing time for the current fuel type

function nReactorFunctions.efficiency() end
--Returns the efficiency of the current reactor setup

function nReactorFunctions.changeReactorState() end
--Will switch the reactor's active state

function nReactorFunctions.auto() end
--Will automate the reactor temperature and energy level monitoring

function nReactorFunctions.autoWithoutMainUI() end
--Will run the automation processes except that it will also display a very primitive UI

function nReactorFunctions.main() end
--This function should only be called if you do not want the primary GUI system.

function nReactorFunctions.checkState()
	return reactor.isProcessing()
end --end checkState

function nReactorFunctions.checkEnergyLevel()
	return reactor.getEnergyStored() / reactor.getMaxEnergyStored()
end --end checkEnergyLevel

function nReactorFunctions.checkHeatLevel()
	return reactor.getHeatLevel() / reactor.getMaxHeatLevel()
end --end cheackHeatLevel

function nReactorFunctions.checkMaxHeatLevel()
	return reactor.getMaxHeatLevel()
end --end checkMaxHeatLevel

function nReactorFunctions.checkEnergyChange() 
	return reactor.getEnergyChange()
end --end checkEnergyChange

function nReactorFunctions.checkProcessHeat()
	return reactor.getReactorProcessHeat()
end --end checkProcessHeat

function nReactorFunctions.powerOutput() 
	return reactor.getReactorProcessPower()
end --end powerOutput

function nReactorFunctions.currentStoredPower()
	return reactor.getEnergyStored()
end --end currentStoredPower

function nReactorFunctions.currentHeatLevel()
	return reactor.getHeatLevel()
end --end currentHeatLevel

function nReactorFunctions.fuelName()
	return reactor.getFissionFuelName()
end --end fuelName

function nReactorFunctions.remainingProcessTime() 
	return (reactor.getFissionFuelTime() - reactor.getCurrentProcessTime())
end --end remainingProcessTime

function nReactorFunctions.efficiency() 
	return reactor.getEfficiency()
end --end efficiency

function nReactorFunctions.changeReactorState()
	if nReactorFunctions.checkState() then
		reactor.deactivate()
	else
		reactor.activate()
	end
end --end changeReactorState

function nReactorFunctions.auto()
	if (nReactorFunctions.checkState() == false) and (nReactorFunctions.checkEnergyLevel() <= 0.20) and (nReactorFunctions.checkHeatLevel() <= 0.20)then
		nReactorFunctions.changeReactorState() --turn on reactor
	elseif (nReactorFunctions.checkState()) and ((nReactorFunctions.checkEnergyLevel() >= 0.80) or (nReactorFunctions.checkHeatLevel() >= 0.80)) then
		nReactorFunctions.changeReactorState() --turn off reactor
	end
end --end auto

function nReactorFunctions.autoWithoutMainUI()
	nReactorFunctions.auto()
	print("Reactor State:", nReactorFunctions.checkState(), "; Energy Level at:", nReactorFunctions.checkEnergyLevel() * 100, "%", "; ", "Heat Level at:" , nReactorFunctions.checkHeatLevel() * 100, "%")
	print("-------------------------------------------------------------------------------------------------------------------------------------------")
end --end autoWithoutMainUI

function nReactorFunctions.main()
	nReactorFunctions.autoWithoutMainUI()
	return nReactorFunctions.main()
end --end main

return nReactorFunctions