geomotes-matlab
===============

What's new? 2/9/14

A rough GUI has been outlined. Buttons are working.

Start:
	Broadcast the 'R' command to begin data collection.

Stop:
	Broadcast the 'S' command to end data collection. Broadcast T# commands where # is the moteID of the individual mote (I'm not using the address specific mode yet). Graphs the data.

Calibrate:
	Broadcasts the 'C' command to calibrate.

Frequency:
	Broadcasts the 'F#' command to set the frequency.

Gain:
	Broadcasts the 'G#' command to set the gain.

Precision:
	Broadcasts the 'P#' command to set the precision. # can be either H (high) or L (low).

TODO:
* Write a serial event callback. Currently I do not expect acknowledgement messages.
* Add an initialization prompt to ask for number of motes, gain, and precision (right now the parameters shown are broadcast on startup).
* Add validation to the "# of Motes" checkbox (currently trusing you'll enter a number).

Other notes:
* The closeProgram() function is overriding the default close function of the program. This is needed to close the serial port. If we don't explicitly close the serial port, no other instance of the program will be able to connect to the base station remote.
* I'm currently storing all my variables into one global object called programSettings. After I learn more about Matlab I will rewrite the little details.
