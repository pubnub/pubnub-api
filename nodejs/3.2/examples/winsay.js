var sp = new ActiveXObject("SAPI.SpVoice");
var text = "";
for(var i = 0; i < WScript.Arguments.length; i++) {
  text = text + WScript.Arguments.Item(i);  
}
sp.speak( text );