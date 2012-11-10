(function(window){

  var Recorder = function(source, cfg){
    var config      = cfg                || {};
    var buffer_size = config.buffer_size || 4096;
    var worker      = new Worker('./recorder-worker.js');
    var recording   = false, currCallback;

    this.context = source.context;
    this.node    = this.context.createJavaScriptNode( buffer_size, 2, 2 );

    worker.postMessage({
        command : 'init',
        config  : config
    });

    this.node.onaudioprocess = function(e){
      if (!recording) return;
      worker.postMessage({
        command : 'record',
        buffer  : [
          e.inputBuffer.getChannelData(0)//,
          //e.inputBuffer.getChannelData(1)
        ]
      });
    }

    this.configure = function(cfg){
      for (var prop in cfg){
        if (cfg.hasOwnProperty(prop)){
          config[prop] = cfg[prop];
        }
      }
    }

    this.record = function(){
      recording = true;
    }

    this.stop = function(){
      recording = false;
    }

    this.clear = function(){
      worker.postMessage({ command: 'clear' });
    }

    this.exportWAV = function(cb, type){
      currCallback = cb || config.callback;
      type = type || config.type || 'audio/wav';
      if (!currCallback) throw new Error('Callback not set');
      worker.postMessage({
        command : 'exportWAV',
        type    : type
      });
    }

    worker.onmessage = function(e){
      var blob = e.data;
      currCallback(blob);
    }

    source.connect(this.node);
    this.node.connect(this.context.destination);    //this should not be necessary
  };

  window.Recorder = Recorder;

})(window);
