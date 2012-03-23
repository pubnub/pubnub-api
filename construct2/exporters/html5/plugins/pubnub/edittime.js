function GetPluginSettings()
{
	return {
		"name": "Pubnub",
		"id": "Pubnub",
		"description": "Allows you to communicate over the Internet via Pubnub.",
		"author": "Simpleex",
		"help url": "http://www.twitter.com/simpleex",
		"category": "Web",
		"type":	"object",
		"rotatable": false,
		"flags": pf_singleglobal
	};
};

AddCondition(0,cf_trigger,"On message received","Pubnub","On message received","Triggered when a message is received.","OnData");
AddCondition(1,cf_trigger,"On connect","Pubnub","On connect","Triggered when connection is established.","OnConnect");
AddCondition(2,cf_trigger,"On reconnect","Pubnub","On reconnect","Triggered when connection is restored.","OnReconnect");
AddCondition(3,cf_trigger,"On disconnect","Pubnub","On disconnect","Triggered when connection is lost.","OnDisconnect");

AddStringParam("Origin","The Pubnub origin address.","\"pubsub.pubnub.com\"");
AddStringParam("Pub-Key","Your Pubnub Publish Key.","\"pub-XXXXXXXXXXXXXX\"");
AddStringParam("Sub-Key","Your Pubnub Subscribe Key.","\"sub-XXXXXXXXXXXX\"");
AddStringParam("Channel","The Channel to subscribe to.","\"YourChannel\"");
AddAction(0,0,"Connect","Pubnub","Subscribe to channel : <b>{3}</b>.","Subscribe to a channel.","Connect");
AddAnyTypeParam("Message","The message to send.","\"\"");
AddAction(1,0,"Publish","Pubnub","Publish <b>{0}</b>","Send a message.","Publish");

AddExpression(0,ef_return_string,"Get last address","Pubnub","LastAddress","Get the last address that the socket connected to.");
AddExpression(1,ef_return_any,"Get last message","Pubnub","LastData","Get the last message that was received .");

ACESDone();

var property_list = [
];

function CreateIDEObjectType()
{
	return new IDEObjectType();
}

function IDEObjectType()
{
	assert2(this instanceof arguments.callee, "Constructor called as a function");
}

IDEObjectType.prototype.CreateInstance = function(instance)
{
	return new IDEInstance(instance, this);
}

function IDEInstance(instance, type)
{
	assert2(this instanceof arguments.callee, "Constructor called as a function");

	this.instance = instance;
	this.type = type;
	
	this.properties = {};
	
	for(property in property_list)
		this.properties[property.name] = property.initial_value;
}
IDEInstance.prototype.OnCreate = function()
{
}
IDEInstance.prototype.OnPropertyChanged = function(property_name)
{
}
IDEInstance.prototype.Draw = function(renderer)
{
}
IDEInstance.prototype.OnRendererReleased = function()
{
}
