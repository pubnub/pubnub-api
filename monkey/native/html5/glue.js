//globals
var _pubNubInitSuccess = false;
var _pubNubPublishKey = "";
var _pubNubSubscribeKey = "";


//classes
//class channel
function pubNubChannel(id) {
	// --- channel constructor ---
	//fields
	this.channel = id;
	this.isConnected = false;
	this.isFetching = 0;
	this.messages = [];
	this.history = [];
	
	//subscribe to channel
	var chan = this;
	PUBNUB.subscribe({
		channel: this.channel,
		restore: false,
		callback: function(message) {
			//convert to string and add to messages
			chan.messages.push(String(message));
		},
		disconnect: function() {
			chan.isConnected = false;
		},
		reconnect: function() {
			chan.isConnected = true;
		},
		connect: function() {
			chan.isConnected = true;
		},
		error: function(e) {
			//alert("error = "+e);
		}
	});
}

//class channel - methods
pubNubChannel.prototype.send = function(value) {
	// --- send a message on this channel ---
	PUBNUB.publish({
		channel: this.channel,
		message: value,
		callback: function(info) {
			if (info[0] == 0) {
				//failed
			}
		}
	});
}

pubNubChannel.prototype.connected = function() {
	// --- return true if connected ---
	return this.isConnected;
}

pubNubChannel.prototype.fetch = function(amount) {
	// --- fetch items from the history ---
	this.isFetching++;
	this.history = [];
	
	//request history from pubnub
	var chan = this;
	PUBNUB.history({
		channel: this.id,
		limit: amount
	}, function(messages) {
		//success
		chan.isFetching--;
		
		//convert to strings and add to history
		for(var index=0;index<messages.length;index++) {
			chan.history.push(String(messages[index]));
		}
	});
}

pubNubChannel.prototype.fetching = function() {
	// --- returns true if currently fetching history ---
	return (this.isFetching > 0);
}

pubNubChannel.prototype.fetchAvailable = function() {
	// --- returns the number of history waiting ---
	return this.history.length;
}

pubNubChannel.prototype.nextFetch = function() {
	// --- returns a history if there is one ---
	if (this.history.length > 0) { return this.history.shift(); }
}

pubNubChannel.prototype.messageAvailable = function() {
	// --- returns the number of messages waiting ---
	return this.messages.length;
}

pubNubChannel.prototype.nextMessage = function() {
	// --- returns a message if there is one ---
	if (this.messages.length > 0) { return this.messages.shift(); }
}

pubNubChannel.prototype.id = function() {
	// --- returns name of channel ---
	return this.channel;
}


//functions
function pubNubStart(publishKey,subscribeKey,secretKey) {
	// --- start the pubnub runtime ---
	_pubNubPublishKey = publishKey;
	_pubNubSubscribeKey = subscribeKey;
	
	//create config div
	var config = document.createElement("div");
	config.setAttribute("pub-key",_pubNubPublishKey);
	config.setAttribute("sub-key",_pubNubSubscribeKey);
	config.setAttribute("ssl","off");
	config.setAttribute("origin","pubsub.pubnub.com");
	config.setAttribute("id","pubnub");
	
	//append the config to the body
	document.body.appendChild(config)

	var script = document.createElement("script");
	script.setAttribute("language","javascript");
	script.setAttribute("src","http://cdn.pubnub.com/pubnub-3.1.min.js");
	
	//setup load events
	if (script.readyState) {
		//internet explorer
		script.onreadystatechange = function(){
			if (script.readyState == "loaded" || script.readyState == "complete") {
				script.onreadystatechange = null;
				_pubNubStartCallback();
			}
		};
	} else {
		//good browsers
		script.onload = function() { _pubNubStartCallback() };
	}
	
	//append the script to the body
	document.body.appendChild(script);
}

function _pubNubStartCallback() {
	// --- callback after verfied script is in place ---
	_pubNubInitSuccess = true;
	PUBNUB.ready();
}

function pubNubLoaded() {
	// --- returns true if pubnub is loaded ---
	return _pubNubInitSuccess;
}

function pubNubSubcribe(channel) {
	// --- subscribe to a channel and return the channel object ---
	return new pubNubChannel(channel);
}