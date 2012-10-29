/*
  PubNub sample client

  This sample client will publish raw (JSON pre-encoded) PubNub messages.

  Circuit:
  * Ethernet shield attached to pins 10, 11, 12, 13
  * (Optional.) Analog sensors on pins A0 to A5.

  created 23 October 2012
  by Petr Baudis

  https://github.com/pubnub/pubnub-api/tree/master/arduino
  This code is in the public domain.
  */

#include <SPI.h>
#include <Ethernet.h>
#include <PubNub.h>

// Some Ethernet shields have a MAC address printed on a sticker on the shield;
// fill in that address here, or choose your own at random:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

char pubkey[] = "demo";
char subkey[] = "demo";
char channel[] = "some_unique_channel_perhaps";

void setup()
{
	Serial.begin(9600);
	Serial.println("Serial set up");

	while (!Ethernet.begin(mac)) {
		Serial.println("Ethernet setup error");
		delay(1000);
	}
	Serial.println("Ethernet set up");

	PubNub.begin(pubkey, subkey);
	Serial.println("PubNub set up");
}

void loop()
{
	EthernetClient *client;

	char msg[64] = "{\"analog\":[";
	for (int i = 0; i < 6; i++) {
		sprintf(msg + strlen(msg), "%d", analogRead(i));
		if (i < 5)
			strcat(msg, ",");
	}
	strcat(msg, "]}");

	Serial.print("publishing message: ");
	Serial.println(msg);
	client = PubNub.publish(channel, msg);
	if (!client) {
		Serial.println("publishing error");
		delay(1000);
		return;
	}
	client->stop();

	delay(5000);
}
