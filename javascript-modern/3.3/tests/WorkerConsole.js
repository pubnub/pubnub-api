/*
 * WorkerConsole.js:
 * 
 * Include this script in your web pages in order to give your worker threads
 * a working console.log() function. This file is also loaded by all 
 * workers you create in order to define the log() function. It is one 
 * file used in two distinct ways.
 * 
 * This does not work in Firefox, since FF4 does not support MessageChannel.
 *
 * It appears to work in Chrome, but has not been tested in other browsers.
 * Note that Workers don't work in Chrome if you're using the file:// 
 * protocol, so in order to try this out you have to be running a server.
 * 
 * It does not work for workers nested within other workers, but it could
 * probably be made to work in that case.
 * 
 * It has only been tested with very simple directory structures.  
 * WorkerConsole.js probably needs to be in the same directory as the 
 * HTML file that includes it. There are likely to be path issues 
 * for more complicated directory structures.
 * 
 * Copyright 2011 by David Flanagan
 * http://creativecommons.org/licenses/by-nc-sa/3.0/
 */
if (this.console && this.console.log) {
    /* 
     * If there is already a console.log() function defined, then wrap the
     * Worker() constructor so that workers get console.log(), too.
     */
    // Remember the original Worker() constructor
    this._Worker = Worker;

    // Make this.Worker writable, so we can replace it.
    Object.defineProperty(this, "Worker", {writable: true});

    // Replace the Worker() constructor with this augmented version
    this.Worker = function Worker(url) {
        // Create a real Worker object that first loads this file to define
        // console.log() and then loads the requested URL
        var w = new _Worker("WorkerConsole.js#" + url);

        // Create a side channel for the worker to send log messages on
        var channel = new MessageChannel();

        // Send one end of the channel to the worker
        w.postMessage("console", [channel.port2]);

        // And listen for log messages on the other end of the channel
        channel.port1.onmessage = function(e) {
            var args = e.data;                // Array of args to console.log()
            args.unshift(url + ": ");         // Add an arg to id the worker
            console.log.apply(console, args); // Pass the args to the real log
        }

        // Return the real Worker object from this fake constructor
        return w;
    }
}
else {
    /*
     * If there wasn't a console.log() function defined, then we're in a
     * Worker created with the wrapped Worker() constructor above, and
     * we need to define the console.
     * 
     * Wait until we get the event that delivers the MessagePort sent by the
     * main thread. Once we get it, we define the console.log() function
     * and load and run the original file that was passed to the constructor.
     */
    self.onmessage = function(e) {
        if (e.data === "console") {
            // Define the console object
            self.console = { 
                _port: e.ports[0],           // Remember the port we log to
                log: function log() {        // Define console.log()
                    // Copy the arguments into a real array
                    var args = Array.prototype.slice.call(arguments);
                    // Send the arguments as a message, over our side channel
                    console._port.postMessage(args);
                }
            };

            // Get rid of this event handler
            onmessage = null;

            // Now run the script that was originally passed to Worker()
            var url = location.hash.substring(1); // Get the real URL to run
            importScripts(url);                   // Load and run it now
        }
    }
}
