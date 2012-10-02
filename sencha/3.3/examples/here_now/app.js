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
        });
        
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
                          id: 'channel'
                        },
                        {
                          text: 'Here Now',
                          handler: function () {
                            var channel  = Ext.getCmp('channel').getValue() || 'sencha-demo-channel';
                            myStore.removeAll();
                            pubnub.here_now({
                              channel: channel,
                              callback: function(response){
                                for ( x in response["uuids"] ) {
                                  myStore.insert(0,{txt : JSON.stringify(response["uuids"][x])});
                                }
                              }
                            });
                          }
                        }
                ]
            }]
        });
    }
});

