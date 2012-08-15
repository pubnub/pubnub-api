# Chat With Sound

Sample Chat Application with Sound Effect on Chat Message Arrival/Send.
I've updated the example and provided an extra **sound.js** JavaScript
HTML5 lib that will help with playing the sound effect.
Note that I took your Sound **WAV** file and converted it to **OGG** and
**MP3** file formats as well in order to provide cross browser compatibility.
Next I will paste the Complete and Working Source Code for the Chat with
Sound Effects on Receiving of a message.
Following the source code, I have pasted the URL
Resources that you need such as **sound.js** and the **audio** files too.

Try it **LIVE!** - [http://pubnub-demo.s3.amazonaws.com/chat-with-sounds/chat.html](http://pubnub-demo.s3.amazonaws.com/chat-with-sounds/chat.html)

### See Source Code:

```html
<div><input id=input placeholder=chat-here></div>
<code>Chat Output</code>
<div id=box></div>
<div id=pubnub pub-key=demo sub-key=demo></div>
<script src=http://cdn.pubnub.com/pubnub-3.1.min.js></script>
<script src=sound.js></script>
<script>(function(){
    var box = PUBNUB.$('box'), input = PUBNUB.$('input'), channel = 'chatlllll';
    PUBNUB.subscribe({
        channel : channel,
        callback : function(text) { 
            // PLAY SOUND HERE
            sounds.play('chat');

            // UPDATE TEXT OUTPUT HERE
            box.innerHTML = 
                (''+text).replace( /[<>]/g, '' ) +
                '<br>' +
                box.innerHTML; 
        }
    });
    PUBNUB.bind( 'keyup', input, function(e) {

       (e.keyCode || e.charCode) === 13 && PUBNUB.publish({
           channel : channel, 
           message : input.value, 
           x       : (input.value='')
       });
   });
})();</script>
```

**Download Source Code on GitHub**

[https://github.com/pubnub/pubnub-api/tree/master/app-showcase/chat-with-sounds](https://github.com/pubnub/pubnub-api/tree/master/app-showcase/chat-with-sounds) - Click link to visit the PubNub GitHub Repository with Source Code for the Chat with Sound Demo.

#### Stackoverflow Original Posting

[http://stackoverflow.com/questions/11532364/javascript-pubnub-chat-notifications/11535242](http://stackoverflow.com/questions/11532364/javascript-pubnub-chat-notifications/11535242)

