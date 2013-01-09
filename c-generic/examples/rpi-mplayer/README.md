PubNub-based Raspberry Pi Media Player
======================================

A simple PubNub-based appliance that supports playback of media
files controlled by PubNub messages. It's designed mainly for
Raspberry Pi, but you can run it on any other Linux system too!

Synopsis
--------

	wget -O ./song.mp3 http://freedownloads.last.fm/download/466248492/Aperture.mp3

	./pubnub-rpi-mplayer -i 1

	[send to channel rpi_mplayer_cmd]
		{"dest_id": 1, "cmd":"play", "file": "song.mp3"}

	[send to channel rpi_mplayer_cmd]
		{"dest_id": 1, "cmd":"stop"}

Message Interface
-----------------

Each player has an id. By default, the id is randomly generated on startup,
but it can be set manually using the -i commandline option.

Two channels are used for communication. Upon startup and after
each command, the player sends a status message to the ``rpi_mplayer_status''
channel:

	{"id":1, "status":"idle"}
	{"id":1, "status":"playing", "file":"song.mp3"}

The player listens for messages addressed to it on the ``rpi_mplayer_cmd''
channel:

	{"dest_id":1, "cmd":"ping"}

triggers just a status update,

	{"dest_id":1, "cmd":"play", "file":"song.mp3"}

starts playing a given file, and

	{"dest_id":1, "cmd":"stop"}

stops the playback.

Media file playback itself is done by an external command. ``mplayer''
is used by default, but this can be overriden using the -m commandline
option.
