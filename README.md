# Nuclearcraft-Reactor-UI-ControlPanel

	Developed by Anthony Castillo (MC Useraccount: Cao21745) 2/23/2020
	Designed and tested for use with OpenComputers-MC1.12.2-1.7.4.153.jar and NuclearCraft-2.17c-1.12.2.jar.
	
	Email suggesttions to Cao21745@yahoo.com or post on the project's github site.
	
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

	Use the command "nReactorGUIStart" to begin the gui program.
	Alternatively use "nReactorBegin" to run a very simplified program that will only display a text based
	panel.

	A word of caution, don't use this program to monitor a reactor where the heat level grows very rapidly. I'm afraid
	that this program might not be able to shutoff the reactor fast enough before it has a meltdown. So long as the
	reactor's heat output is less than 20% of its total heat capacity, the program should be able to catch it and
	shutdown the reactor before it is too late. If the reactor does output more than 20% of it's max heat capacity
	then I recommend that you use "nReactorBegin" to monitor the reactor. Atleast then it'll have a higher chance
	of turning off the reactor intime. But really you should redesign your reactor or use a more stable fuel type.

	I plan on rearranging the UI slightly, but for now its perfectly functional.
