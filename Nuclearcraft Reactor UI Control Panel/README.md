
	Developed by Anthony Castillo (MC Useraccount: Cao21745) 2/23/2020
	Designed and tested for use with OpenComputers-MC1.12.2-1.7.4.153.jar and NuclearCraft-2.17c-1.12.2.jar.
	
	This is still a work in progress so any suggestions will be taken into consideration.
	Email suggesttions to Cao21745@yahoo.com
	
	This is a simple program that is designed to automatically control a Nuclearcraft Reactor while drawing
	a fairly simple UI.
	It currently draws a power level bar and a heat level bar.
	Additionally it'll label the name of the currently processing FUEL, the power output of the reactor,
	the amount of power being drawn from the reactor, the reactor's currently stored power,
	the fuel's remaining burn time, the fuel's efficiency, and the amount of heat the reactor is outputting.
	The program also features a histograph displaying the power level and heat level of the last minute or so.
	The script also has a builtin screen timeout, using either a motion sensor or a touch event to wake the
	screen back up. You can set the duration that the program will wait for before the screen times out.
	The script is still monitoring the reactor while the screen UI is off unless the program is set to manual mode.
	There is also an exit button that shuts down the reactor and then exits the program.
	
	You will need a Tier 3 Graphics Card and at least two Tier 1 Memory Chips for a total of 384k RAM and atleast
	a Tier 1 CPU, a harddrive with OpenOS, and the GUI files and functions.