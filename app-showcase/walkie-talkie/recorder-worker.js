var recorded_samples = 0
,   recorded_buffers = []
,   channels         = 1      // Mono or Stereo
,   sample_rate      = 44100  // Sample Rate
,   bits             = 16;    // Bits Per Sample (16bit)

/*
PUBNUB.publish({
    channels : my_channel,
    message  : 'init'
});
*/

this.onmessage = function(e){
  switch(e.data.command){
    case 'init':
      init(e.data.config);
      break;
    case 'record':
      record(e.data.buffer);
      break;
    case 'exportWAV':
      exportWAV(e.data.type);
      break;
    case 'clear':
      clear();
      break;
  }
};

function init(config) {
    channels    = config.channels;
    sample_rate = config.sample_rate;
    bits        = config.bits;
}

function record(inputBuffer){
    recorded_buffers.push(inputBuffer[0]);
    recorded_samples += inputBuffer[0].length;
}

function exportWAV(type) {
    var buffer = join_buffers( recorded_buffers, recorded_samples );
    var dataview = encodeWAV(buffer);
    //var dataview  = encodeLowWAV(buffer);
    var audioBlob = new Blob( [dataview], { type : type } );
    this.postMessage(audioBlob);
}

function clear(){
    recorded_samples = 0;
    recorded_buffers = [];
}

function join_buffers( recorded_buffers, recorded_samples ) {
    var result = new Float32Array(recorded_samples);
    var offset = 0;
    for (var i = 0; i < recorded_buffers.length; i++){
        result.set(recorded_buffers[i], offset);
        offset += recorded_buffers[i].length;
    }
    return result;
}

/*jjjjjjj
function interleave(inputL, inputR){
  var length = inputL.length + inputR.length;
  var result = new Float32Array(length);

  var index = 0,
    inputIndex = 0;

  while (index < length){
    result[index++] = inputL[inputIndex];
    result[index++] = inputR[inputIndex];
    inputIndex++;
  }
  return result;
}
*/

function floatTo16BitPCM( view, offset, samples ) {
    for (var i = 0; i < samples.length; i++, offset+=2) {
        var s = Math.max( -1, Math.min( 1, samples[i] ) );
        view.setInt16( offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true );
    }
}

function writeString( view, offset, string ) {
    for (var i = 0; i < string.length; i++) {
        view.setUint8( offset + i, string.charCodeAt(i) );
    }
}

function reduce_sample_rate(samples) {
    return samples.filter(function( sample, position ) {
        return !(position % 2);
    } );
}

function encodeLowWAV(samples) {
    var block_align   = (channels * bits) / 8
    ,   byte_rate     = sample_rate * block_align
    ,   data_size     = (samples.length * bits) / 8
    ,   buffer        = new ArrayBuffer(44 + data_size)
    ,   view          = new DataView(buffer);

    writeString( view, 0, 'RIFF' );
    view.setUint32( 4, 32 + data_size, true ); //!!!
    writeString( view, 8, 'WAVE' );
    writeString( view, 12, 'fmt' );
    view.setUint32( 16, 16, true );
    view.setUint16( 20, 1, true );
    view.setUint16( 22, channels, true );
    view.setUint32( 24, sample_rate, true );
    view.setUint32( 28, byte_rate, true );
    view.setUint16( 32, block_align, true );
    view.setUint16( 34, bits, true );
    writeString( view, 36, 'data' );
    view.setUint32( 40, data_size, true ); //!!!
    floatTo16BitPCM( view, 44, samples );

    return view;
}

function encodeWAV(samples){
  var buffer = new ArrayBuffer(44 + samples.length * 2);
  var view = new DataView(buffer);

  /* RIFF identifier */
  writeString(view, 0, 'RIFF');
  /* file length */
  view.setUint32(4, 32 + samples.length * 2, true);
  /* RIFF type */
  writeString(view, 8, 'WAVE');
  /* format chunk identifier */
  writeString(view, 12, 'fmt ');
  /* format chunk length */
  view.setUint32(16, 16, true);
  /* sample format (raw) */
  view.setUint16(20, 1, true);
  /* channel count */
  view.setUint16(22, channels, true);
  /* sample rate */
  view.setUint32(24, sample_rate, true);
  /* byte rate (sample rate * block align) */
  view.setUint32(28, sample_rate * channels * 2, true);
  /* block align (channel count * bytes per sample) */
  view.setUint16(32, channels * 2, true);
  /* bits per sample */
  view.setUint16(34, 16, true);
  /* data chunk identifier */
  writeString(view, 36, 'data');
  /* data chunk length */
  view.setUint32(40, samples.length * 2, true);

  floatTo16BitPCM(view, 44, samples);

  return view;
}
