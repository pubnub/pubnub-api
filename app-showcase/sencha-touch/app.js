//<debug>
Ext.Loader.setPath({
    'Ext': '../sencha-sdk/src'
});
//</debug>

Ext.application({
    "name": "PubNub-SenchaTouch",
    // Setup your icon and startup screens
    phoneStartupScreen: 'resources/loading/Homescreen.jpg',
    tabletStartupScreen: 'resources/loading/Homescreen~ipad.jpg',

    glossOnIcon: false,
    icon: {
        57: 'resources/icons/icon.png',
        72: 'resources/icons/icon@72.png',
        114: 'resources/icons/icon@2x.png',
        144: 'resources/icons/icon@114.png'
    },

    // Require any components we will use in our example
    requires: [
        'Ext.field.Text',
        'Ext.field.Search',
        'Ext.field.Select',
        'Ext.Button',
        'Ext.List',
        'Ext.Img'
    ],

    launch: function() {
       var pubnub = PUBNUB.init({
              publish_key   : 'demo',
              subscribe_key : 'demo',
              ssl           : false,
              origin        : 'pubsub.pubnub.com'
        });
       

        function sendMessage() {
          pubnub.publish({
            channel  : 'sencha_chat',
            message  : { 
              name    : "chat_message",
              data    : {
                message : Ext.getCmp('chat_input').getValue(),
                user    : (Ext.getCmp('name_input').getValue() || "nobody")
              } 
            },
            callback : function() {
              Ext.getCmp('chat_input').setValue('');
              Ext.getCmp('chat_input').focus();
            }
          });
        }

        pubnub.subscribe({
          channel  : 'sencha_chat',
          callback : function(message) {
            if (message.name && (message.name == 'chat_message')) {
              messageList.getStore().add({
                  user: (message.data.user || nobody),
                  message: message.data.message 
              });
              setTimeout( function() {
                messageList.getScrollable().getScroller().scrollToEnd();
              }, 10);
            }
          }    
        });

        var chatField, nameField, submitButton, messageList;

        // Create a text field with a name and palceholder
        chatField = Ext.create('Ext.field.Text', {
            name: 'chat_input',
            id: 'chat_input',
            placeHolder: 'type chat here',
            flex: 7,
            listeners: {
              action: sendMessage
            }
        });

        nameField = Ext.create('Ext.field.Text', {
            name: 'name_input',
            id: 'name_input',
            placeHolder: 'your name',
            flex: 2
        });

        submitButton = Ext.create('Ext.Button', {
            iconCls: 'reply',
            iconMask: true,
            text: 'Send',
            ui: 'confirm',
            flex: 1,
            listeners: {
              tap:  sendMessage
            }

        });

        messageList = Ext.create('Ext.List', {
            itemTpl: '<b>{user}</b>: {message} ',
            data: [
                { user: 'Phil',
                  message: 'lol'},
            ],
        });
 

        Ext.create('Ext.Container', { 
            fullscreen: true,
            layout: 'vbox',
            items: [
                {
                    xtype: 'toolbar',
                    flex: 1.5,
                    items: [
                        { 
                            xtype: 'spacer'
                        },
                        {
                            xtype  : 'panel',
                            html   : '<img style="height:25px; margin-top:15px; margin-bottom:15px;" src="https://pubnub.s3.amazonaws.com/2012/pubnub-large.png"/>',
                            height : 60
                        },
                        {
                            xtype  : 'panel',
                            html   : '<img style="height:60px;" src="http://www.theberryfix.com/wp-content/uploads/sencha_logo.png" />',
                        },
                        { 
                            xtype: 'spacer' 
                        }
                    ]
                },
                {
                    
                    xtype: 'panel',
                    layout: 'fit',
                    flex: 7,
                    items: [
                        messageList,
                    ]
                },
                {
                    xtype: 'toolbar',
                    flex: 1,
                    items: [
                        nameField,
                        chatField,
                        submitButton,
                    ]
                }
            ]
        });

        // preload prev chats 
        pubnub.history({
          channel : 'sencha_chat',
          limit : 10 
        }, function(messages) {
          messageList.getStore().removeAt(0); //remove dummy
          console.log(messages);
          for (m in messages) {
            var message = messages[m];
            messageList.getStore().add({
                user: (message.data.user || nobody),
                message: message.data.message 
            });
          }
        }); 
    }
});
