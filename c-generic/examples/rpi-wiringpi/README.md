PubNub-based Raspberry Pi Pin Control
=====================================

A simple PubNub-based appliance that supports remote control of
Raspberry Pi pins (both input, e.g. buttons, and output, e.g. LEDs).
It uses the popular [WiringPi](https://projects.drogon.net/raspberry-pi/wiringpi/)
library for low-level controls.

Synopsis
--------

	./pubnub-rpi-wiringpi -i 1 -r 4,10 -w 12,13

	[send to channel rpi_wiringpi_cmd]
		{"dest_id": 1, "write": {"12": "1", "13": "0"}}

	[send to channel rpi_wiringpi_cmd]
		{"dest_id": 1, "read": [4, 10]}
	[read reply from channel rpi_wiringpi_status]

Message Interface
-----------------

Each Pi has an id. By default, the id is randomly generated on program
startup, but it can be set manually using the -i commandline option.

The program will allow manipulating just a given set of pins; two sets
of read and write pins (non-overlapping) must be specified via the
-r and -w commandline arguments, with the pin numbers comma-separated.

Note that there is no consistently used Raspberry Pi pin numbering.
Here, we use the [WiringPi pin numbering](https://projects.drogon.net/raspberry-pi/wiringpi/pins/).

Two channels are used for communication. Upon startup, the player sends
a status message to the ``rpi_wiringpi_status'' channel:

	{"id":1}

Pin value messages are also sent to the channel as Pi's responses to
commands regarding these pins:

	{"id":1, "pins":{"4":0, "10":1}}

The Pi listens for messages addressed to it on the ``rpi_wiringpi_cmd''
channel:

	{"dest_id":1}

triggers just an empty status message,

	{"dest_id":1, "write":{"<pinNum>":"0 or 1", ...}}

will update voltage levels on given pins (and trigger a status message
with the pin values listed),

	{"dest_id":1, "read":[<pinNum>, ...]}

will check current voltage level on given pins and trigger a status
message with the acquired values.
