var pubnub = PUBNUB.init({
    publish_key   : 'demo',
    subscribe_key : 'demo',
    ssl           : false,
    origin        : 'pubsub.pubnub.com'
});


Ext.application({
    launch: function () {
        var myStore = Ext.create('Ext.data.Store', {
            storeId: 'list',
            fields: ['txt']
        }); // create()
        
        Ext.create('Ext.List', {
            fullscreen: true,
            store: 'list',
            itemTpl: '{txt}',
            items: [{
                xtype: 'titlebar',
                docked: 'top',
                items: [
                        {
                          xtype: 'textfield',
                          label: 'Channel',
                          name: 'channel',
                          id: 'channel',
                          align: 'left',
                        },
                        {
                          text: 'Subscribe',
                          align: 'left',
                          handler: function () {
                            var channel  = Ext.getCmp('channel').getValue() || 'sencha-demo-channel';
                            myStore.removeAll();
                            pubnub.subscribe({
                              channel: channel,
                              callback: function(message){
                                myStore.insert(0,{txt : JSON.stringify(message)});
                              }
                            });
                          }
                        },
                        {
                          xtype: 'textfield',
                          label: 'Message',
                          name: 'message',
                          id: 'message',
                          align: 'right'
                        },
                        {
                          text: 'Publish',
                          align: 'right',
                          handler: function () {
                            var channel  = Ext.getCmp('channel').getValue() || 'sencha-demo-channel';
                            var message = Ext.getCmp('message').getValue() || 'default-dummy-message';
                            pubnub.publish({
                              channel: channel,
                              message: message
                            });
                          }
                        }
                ]
            }]
        });
    }
});

