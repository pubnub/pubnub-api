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
                border: 0,
                items: [
                        {
                          xtype: 'textfield',
                          name: 'channel',
                          id: 'channel',
                          label: 'Channel',
                        },
                        {
                          xtype: 'textfield',
                          label: 'Count',
                          name: 'count',
                          id: 'count'
                        },
                        {
                          xtype: 'textfield',
                          label: 'Start',
                          name: 'start',
                          id: 'start'
                        },
                        {
                          xtype: 'textfield',
                          label: 'End',
                          name: 'end',
                          id: 'end'
                        },
                ]
            },
            {
                xtype: 'titlebar',
                docked: 'top',
                height: '70px',
                border: 0,
                items: [
                        {
                          xtype: 'togglefield',
                          name : 'reverse',
                          id: 'reverse',
                          label: 'Reverse ?',
                        },
                        {
                          text: 'Get History',
                          align: 'left',
                          handler: function () {
                            var channel  = Ext.getCmp('channel').getValue() || 'sencha-demo-channel';
                            var count = Ext.getCmp('count').getValue() || 100;
                            var start = Ext.getCmp('start').getValue();
                            var end = Ext.getCmp('end').getValue();
                            var reverse = Ext.getCmp('reverse').getValue() ;
                            
                            myStore.removeAll();
                            pubnub.detailedHistory({
                              channel: channel,
                              count: count,
                              start: start,
                              end: end,
                              reverse: reverse?'true':'false',
                              callback: function(response){
                                for ( x in response[0] ) {
                                  myStore.insert(0,{txt : JSON.stringify(response[0][x])});
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

