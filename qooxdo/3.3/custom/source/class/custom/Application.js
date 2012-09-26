qx.Class.define("custom.Application",
    {
        extend:qx.application.Standalone,


        /*
         *****************************************************************************
         MEMBERS
         *****************************************************************************
         */

        members:{
            /**
             * This method contains the initial application code and gets called
             * during startup of the application
             *
             * @lint ignoreDeprecated(alert)
             */
            main:function () {

                var pubnub = PUBNUB.init({
                    publish_key:'demo',
                    subscribe_key:'demo',
                    origin:'pubsub.pubnub.com'
                });

                // Call super class
                this.base(arguments);

                // Enable logging in debug variant
                if (qx.core.Environment.get("qx.debug")) {
                    // support native logging capabilities, e.g. Firebug for Firefox
                    qx.log.appender.Native;
                    // support additional cross-browser console. Press F7 to toggle visibility
                    qx.log.appender.Console;
                }

                /*
                 -------------------------------------------------------------------------
                 Below is your actual application code...
                 -------------------------------------------------------------------------
                 */

                var label1 = new qx.ui.basic.Label("Last Received Message").set({
                    decorator:"main",
                    font:new qx.bom.Font(28, ["Verdana", "sans-serif"]),
                    width: 500,
                    rich: true
                });
                this.getRoot().add(label1, {left:500, top:50});

                // Create a button
                var publishButton = new qx.ui.form.Button("Publish a message!", "custom/test.png");
                var subscribeButton = new qx.ui.form.Button("Subscribe!", "custom/test.png");
                var unsubscribeButton = new qx.ui.form.Button("Un-Subscribe!", "custom/test.png");
                var historyButton = new qx.ui.form.Button("Message History!", "custom/test.png");


                // Document is the application root
                var doc = this.getRoot();

                // Add button to document at fixed coordinates
                doc.add(historyButton, {left:0, top:100});
                doc.add(unsubscribeButton, {left:300, top:50});
                doc.add(publishButton, {left:125, top:50});
                doc.add(subscribeButton, {left:0, top:50});

                // Add an event listener

                historyButton.addListener("execute", function (e) {

                    pubnub.detailedHistory({
                        count:10,
                        channel:"hello_world",
                        callback:function (message) {
                            label1.set({"value":message.toString()});
                        }
                    });
                    //console.log(message);


                });

                unsubscribeButton.addListener("execute", function (e) {

                    pubnub.unsubscribe({
                        channel:'hello_world'
                    });

                    label1.set({"value":"Unsubscribed."});

                });

                publishButton.addListener("execute", function (e) {

                    pubnub.publish({
                        channel:"hello_world",
                        message:"Hello from Qooxdo on " + new Date() + " !"
                    });
                });

                subscribeButton.addListener("execute", function (e) {

                    pubnub.subscribe({
                        channel:'hello_world',
                        connect:function () {
                            label1.set({"value":"Subscribed."});
                        },
                        callback:function (message) {
                            label1.set({"value":message});
                        }
                    });

                });

            }
        }
    });
