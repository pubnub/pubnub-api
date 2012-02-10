// =====================================================================
// STANFORD CRYPTO Library with AES Encryption
// =====================================================================
PUBNUB.secure = (function(){
    var cipher_key = '';

    function encrypt(data) {
        return data && sjcl.encrypt(
            cipher_key, JSON.stringify(data)
        ) || data;
    }

    function decrypt(data) {
        try { return JSON.parse(
            sjcl.decrypt( cipher_key, data )
        ); }
        catch(e) { return null; }
    }

    return function(setup) {
        var pubnub = PUBNUB.init(setup);
        cipher_key = setup.cipher_key;

        return {
            publish : function(args) {
                args.message = encrypt(args.message);
                return pubnub.publish(args);
            },
            subscribe : function(args) {
                var callback = args.callback;
                args.callback = function(message) {
                    var decrypted = decrypt(message);
                    decrypted && callback(decrypted);
                }

                return pubnub.subscribe(args);
            }
        };
    };
})();
