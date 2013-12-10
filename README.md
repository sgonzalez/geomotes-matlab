geomotes-matlab
===============

What's new? 12/9/13
A rough GUI has been outlined. Buttons are visible, but not functional (yet).
Start:
	(does nothing yet)
Stop:
	(request data transmission from mote 1)
Calibrate:
	(does nothing yet)
Frequency:
	(does nothing yet)
Gain:
	(does nothing yet)
Precision:
	(does nothing yet)
Graph:
	(does nothing yet)

TODO:
* Wire up commands for calibrate, frequency, gain, precision, and start to write to the serial port.
* Add an initialization prompt to ask for number of motes, gain, and precision.
* Beef up the Stop callback function to stop the motes, request transmissions, and graph the results.

Other notes:
* The closeProgram() function is overriding the default close function of the program. This is needed to close the serial port. If we don't explicitly close the serial port, no other instance of the program will be able to connect to the base station remote.
* I'm currently storing all my variables into one global object called programSettings. After I learn more about Matlab I will rewrite the little details.
