(function(){function r(){return function(){}}window.JSON&&window.JSON.stringify||function(){function t(a,b){var c,d,e,f,g=i,h,j=b[a];j&&"object"===typeof j&&"function"===typeof j.toJSON&&(j=j.toJSON(a));"function"===typeof m&&(j=m.call(b,a,j));switch(typeof j){case"string":return w(j);case"number":return isFinite(j)?""+j:"null";case"boolean":case"null":return""+j;case"object":if(!j)return"null";i+=p;h=[];if("[object Array]"===Object.prototype.toString.apply(j)){f=j.length;for(c=0;c<f;c+=1)h[c]=t(c,j)||"null";e=0===h.length?"[]":i?"[\n"+i+h.join(",\n"+i)+"\n"+g+"]":"["+h.join(",")+"]";i=g;return e}if(m&&"object"===typeof m){f=m.length;for(c=0;c<f;c+=1)d=m[c],"string"===typeof d&&(e=t(d,j))&&h.push(w(d)+(i?": ":":")+e)}else for(d in j)Object.hasOwnProperty.call(j,d)&&(e=t(d,j))&&h.push(w(d)+(i?": ":":")+e);e=0===h.length?"{}":i?"{\n"+i+h.join(",\n"+i)+"\n"+g+"}":"{"+h.join(",")+"}";i=g;return e}}function w(a){k.lastIndex=0;return k.test(a)?'"'+a.replace(k,function(a){var b=g[a];return"string"===typeof b?b:"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+a+'"'}window.JSON||(window.JSON={});"function"!==typeof String.prototype.toJSON&&(String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(){return this.valueOf()});var k=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,i,p,g={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},m;"function"!==typeof JSON.stringify&&(JSON.stringify=function(a,b,c){var d;p=i="";if("number"===typeof c)for(d=0;d<c;d+=1)p+=" ";else"string"===typeof c&&(p=c);if((m=b)&&"function"!==typeof b&&("object"!==typeof b||"number"!==typeof b.length))throw Error("JSON.stringify");return t("",{"":a})});"function"!==typeof JSON.parse&&(JSON.parse=function(c){return eval("("+c+")")})}();window.PUBNUB||function(){function v(){if(!J.get)return 0;var a={id:v.id++,send:r(),abort:function(){a.id={}},open:function(b,c){v[a.id]=a;J.get(a.id,c)}};return a}function u(){PUBNUB.time(c);PUBNUB.time(function(){setTimeout(function(){H||(H=1,h(I,function(a){a[2].subscribe(a[0],a[1])}))},C)})}function t(a){function c(){if(!f){f=1;clearTimeout(g);try{response=JSON.parse(d.responseText)}catch(a){return b(1)}i(response)}}function b(a){e||(e=1,clearTimeout(g),d&&(d.onerror=d.onload=null,d.abort&&d.abort(),d=null),a&&h())}var d,e=0,f=0,g=setTimeout(function(){b(1)},B),h=a.a||r(),i=a.b||r();try{d=v()||window.XDomainRequest&&new XDomainRequest||new XMLHttpRequest,d.onerror=d.onabort=function(){b(1)},d.onload=d.onloadend=c,d.timeout=B,d.open("GET",a.url.join(A),!0),d.send()}catch(j){return b(0),D=0,s(a)}return b}function s(a){function c(a,b){h||(h=1,a||k(b),d.onerror=null,clearTimeout(i),setTimeout(function(){a&&j();var b=e(g),c=b&&b.parentNode;c&&c.removeChild(b)},C))}if(D||v())return t(a);var d=o("script"),f=a.c,g=b(),h=0,i=setTimeout(function(){c(1)},B),j=a.a||r(),k=a.b||r();window[f]=function(a){c(0,a)};d[z]=z;d.onerror=function(){c(1)};d.src=a.url.join(A);m(d,"id",g);l().appendChild(d);return c}function q(a){return i(encodeURIComponent(a).split(""),function(a){return 0>"-_.!~*'()".indexOf(a)?a:"%"+a.charCodeAt(0).toString(16).toUpperCase()}).join("")}function p(){return D||v()?0:b()}function o(a){return document.createElement(a)}function n(a,b){for(var c in b)if(b.hasOwnProperty(c))try{a.style[c]=b[c]+(0<"|width|height|top|left|".indexOf(c)&&"number"==typeof b[c]?"px":"")}catch(d){}}function m(a,b,c){if(c)a.setAttribute(b,c);else return a&&a.getAttribute&&a.getAttribute(b)}function l(){return g("head")[0]}function k(a,b,c){h(a.split(","),function(a){function d(a){a||(a=window.event);c(a)||(a.cancelBubble=!0,a.returnValue=!1,a.preventDefault&&a.preventDefault(),a.stopPropagation&&a.stopPropagation())}b.addEventListener?b.addEventListener(a,d,!1):b.attachEvent?b.attachEvent("on"+a,d):b["on"+a]=d})}function j(a,b){return a.replace(y,function(a,c){return b[c]||a})}function i(a,b){var c=[];h(a||[],function(a,d){c.push(b(a,d))});return c}function h(a,b){if(a&&b)if("undefined"!=typeof a[0])for(var c=0,d=a.length;c<d;)b.call(a[c],a[c],c++);else for(c in a)a.hasOwnProperty&&a.hasOwnProperty(c)&&b.call(a[c],c,a[c])}function g(a,b){var c=[];h(a.split(/\s+/),function(a){h((b||document).getElementsByTagName(a),function(a){c.push(a)})});return c}function f(a){console.log(a)}function e(a){return document.getElementById(a)}function d(a,b){function d(){f+b>c()?(clearTimeout(e),e=setTimeout(d,b)):(f=c(),a())}var e,f=0;return d}function c(){return+(new Date)}function b(){return"x"+ ++x+""+ +(new Date)}function a(t){var v={},x=t.publish_key||"",y=t.subscribe_key||"",z=t.ssl?"s":"",A="http"+z+"://"+(t.origin||"pubsub.pubnub.com"),B={history:function(a,b){var b=a.callback||b,c=a.limit||100,d=a.channel,e=p();if(!d)return f("Missing Channel");if(!b)return f("Missing Callback");s({c:e,url:[A,"history",y,q(d),e,c],b:function(a){b(a)},a:function(a){f(a)}})},time:function(a){var b=p();s({c:b,url:[A,"time",b],b:function(b){a(b[0])},a:function(){a(0)}})},uuid:function(a){var b=p();s({c:b,url:["http"+z+"://pubnub-prod.appspot.com/uuid?callback="+b],b:function(b){a(b[0])},a:function(){a(0)}})},publish:function(a,b){var b=b||a.callback||r(),c=a.message,d=a.channel,e=p();if(!c)return f("Missing Message");if(!d)return f("Missing Channel");if(!x)return f("Missing Publish Key");c=JSON.stringify(c);c=[A,"publish",x,y,0,q(d),e,q(c)];if(1800<c.join().length)return f("Message Too Big");s({c:e,b:function(a){b(a)},a:function(){b([0,"Disconnected"])},url:c})},unsubscribe:function(a){a=a.channel;a in v&&(v[a].d=0,v[a].e&&v[a].e(0))},subscribe:function(a,b){function c(){var a=p();v[d].d&&(v[d].e=s({c:a,url:[o,"subscribe",y,q(d),a,g],a:function(){m||(m=1,l());setTimeout(c,C);B.time(function(a){a||i()})},b:function(a){v[d].d&&(n||(n=1,j()),m&&(m=0,k()),e=w.set(y+d,g=e&&w.get(y+d)||a[1]),h(a[0],function(c){b(c,a)}),setTimeout(c,10))}}))}var d=a.channel,b=b||a.callback,e=a.restore,g=0,i=a.error||r(),j=a.connect||r(),k=a.reconnect||r(),l=a.disconnect||r(),m=0,n=0,o=E(A);if(!H)return I.push([a,b,B]);if(!d)return f("Missing Channel");if(!b)return f("Missing Callback");if(!y)return f("Missing Subscribe Key");d in v||(v[d]={});if(v[d].d)return f("Already Connected");v[d].d=1;c()},xdr:s,ready:u,db:w,each:h,map:i,css:n,$:e,create:o,bind:k,supplant:j,head:l,search:g,attr:m,now:c,unique:b,events:F,updater:d,init:a};return B}window.console||(window.console=window.console||{});console.log||(console.log=(window.opera||{}).postError||r());var w=function(){var a=window.localStorage;return{get:function(b){try{return a?a.getItem(b):-1==document.cookie.indexOf(b)?null:((document.cookie||"").match(RegExp(b+"=([^;]+)"))||[])[1]||null}catch(c){}},set:function(b,c){try{if(a)return a.setItem(b,c)&&0;document.cookie=b+"="+c+"; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/"}catch(d){}}}}(),x=1,y=/{([\w\-]+)}/g,z="async",A="/",B=14e4,C=1e3,D=-1==navigator.userAgent.indexOf("MSIE 6"),E=function(){var a=Math.floor(9*Math.random())+1;return function(b){return 0<b.indexOf("pubsub")&&b.replace("pubsub","ps"+(10>++a?a:a=1))||b}}(),F={list:{},unbind:function(a){F.list[a]=[]},bind:function(a,b){(F.list[a]=F.list[a]||[]).push(b)},fire:function(a,b){h(F.list[a]||[],function(a){a(b)})}},G=e("pubnub")||{},H=0,I=[];PUBNUB=a({publish_key:m(G,"pub-key"),subscribe_key:m(G,"sub-key"),ssl:"on"==m(G,"ssl"),origin:m(G,"origin")});n(G,{position:"absolute",top:-C});if("opera"in window||m(G,"flash"))G.innerHTML="<object id=pubnubs data=https://dh15atwfs066y.cloudfront.net/pubnub.swf><param name=movie value=https://dh15atwfs066y.cloudfront.net/pubnub.swf><param name=allowscriptaccess value=always></object>";var J=e("pubnubs")||{};k("load",window,function(){setTimeout(u,0)});PUBNUB.rdx=function(a,b){if(!b)return v[a].onerror();v[a].responseText=unescape(b);v[a].onload()};v.id=C;window.jQuery&&(window.jQuery.PUBNUB=PUBNUB);"undefined"!==typeof module&&(module.f=PUBNUB)&&u()}()})()

// ECMAScript 5 strict mode
"use strict";

//Pubnub plugin
assert2(cr,"cr namespace not created");
assert2(cr.plugins_,"cr.plugins not created");

cr.plugins_.Pubnub = function(runtime)
{
	this.runtime = runtime;
};

(function ()
{
	var pluginProto = cr.plugins_.Pubnub.prototype;

	pluginProto.Type = function(plugin)
	{
		this.plugin = plugin;
		this.runtime = plugin.runtime;
	};

	var typeProto = pluginProto.Type.prototype;
	typeProto.onCreate = function()
	{
	};

	pluginProto.Instance = function(type)
	{
		this.type = type;
		this.runtime = type.runtime;
		this.lastAddress = "";		
		this.dataStack = [];
	};
	
	var instanceProto = pluginProto.Instance.prototype;

	instanceProto.onCreate = function()
	{
		
	};


	instanceProto.connect = function(origin,pubkey,subkey,channel)
	{		

		this.lastAddress = origin;
		var instance = this;
		var runtime = instance.runtime;
		var pubnub = this.pubnub;
				
		pubnub = PUBNUB.init({
			publish_key   : pubkey,
			subscribe_key :  subkey,
			ssl           : false,
			origin        : origin
			});
		
		pubnub.subscribe({
			channel    : channel,      // CONNECT TO THIS CHANNEL.
			restore    : false,              // STAY CONNECTED, EVEN WHEN BROWSER IS CLOSED
											 // OR WHEN PAGE CHANGES.
	 
			callback   : function(message) { // RECEIVED A MESSAGE.
				instance.dataStack.push(message.message);
				runtime.trigger(pluginProto.cnds.OnData,instance);
			},
	 
			disconnect : function() {        // LOST CONNECTION.
				runtime.trigger(pluginProto.cnds.OnDisconnect,instance);
			},
	 
			reconnect  : function() {        // CONNECTION RESTORED.
				runtime.trigger(pluginProto.cnds.OnReconnect,instance);
			},
	 
			connect    : function() {        // CONNECTION ESTABLISHED.
	 
				runtime.trigger(pluginProto.cnds.OnConnect,instance);
				
				instanceProto.publish = function(data)
					{
						pubnub.publish({             // SEND A MESSAGE.
						channel : channel,
						message : {message : data}
						});
						
					};
					
				}
		});
 
	};

	pluginProto.cnds = {};
	var cnds = pluginProto.cnds;

	cnds.OnConnect = function()
	{
		return true;
	};
	cnds.OnDisconnect = function()
	{
		return true;
	};
	
	cnds.OnReconnect = function()
	{
		return true;
	};
	
	cnds.OnData = function()
	{
		return true;
	};

	pluginProto.acts = {};
	var acts = pluginProto.acts;

	acts.Connect = function(origin,pubkey,subkey,channel)
	{
		origin = origin.toString();
		channel = channel.toString();
		pubkey = pubkey.toString();
		subkey = subkey.toString();
		this.connect(origin,pubkey,subkey,channel);       
		
	};
	acts.Publish = function(data)
	{
		this.publish(data);
	};

	pluginProto.exps = {};
	var exps = pluginProto.exps;

	exps.LastData = function(result)
	{
		var dataStack = this.dataStack;
		var dataLength = dataStack.length;
		
		var data = "";
		if(dataLength > 0)
			data = dataStack.splice(0,1)[0].toString();
		
		result.set_string(data);
	};

	exps.LastAddress = function(result)
	{
		result.set_string(this.lastAddress);
	};

}());

