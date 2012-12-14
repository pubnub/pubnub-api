<?php

#$plaintext = "this is my plaintext.";
$cipher_key = "enigma";

#printf("\ncipher key is %s\n", $cipher_key);

#$cipher_text = "q/xJqqN6qbiZMXYmiQC1Fw==";
#$decrypt = "RVOElAJIHskATgCCP+KlaQ==";
#$key = "67a4f45f0d1d9bc606486fc42dc49416";
#$iv = "0123456789012345";
## Manual Run
#$cipher_text = encrypt("hellohellohello!", $cipher_key, $iv);
#$p_text = decrypt($cipher_text, $cipher_key, $iv);
##

function decrypt($cipher_text, $cipher_key) {
    $iv = "0123456789012345";

    if (gettype($cipher_text) != "string")
        return "DECRYPTION_ERROR";

    $decoded = base64_decode($cipher_text);

    $sha_cipher_key = hash("sha256", $cipher_key);
    $padded_cipher_key = substr($sha_cipher_key, 0, 32);

    $td = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, '');
    mcrypt_generic_init($td, $padded_cipher_key, $iv);

    $decrypted = mdecrypt_generic($td, $decoded); // TODO: handle non-encrypted unicode corner-case
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);

    $unpadded = unpadPKCS7($decrypted, 16);
    #printf("\ndecoded: %s", $unpadded);
    return $unpadded;
}


function encrypt($plain_text, $cipher_key) {
    $iv = "0123456789012345";

    $sha_cipher_key = hash("sha256", $cipher_key);
    $padded_cipher_key = substr($sha_cipher_key, 0, 32);
    $padded_plain_text = pkcs5_pad($plain_text, 16);

//    printf("sha256 key is %s\n", $sha_cipher_key);
//    printf("padded cipher key is %s\n\n", $padded_cipher_key);
//    printf("padded plain_text is %s\n\n", $padded_plain_text);

    # This is the way to do AES-256 using mcrypt PHP - its not AES-128 or anything other than that!
    $td = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, '');
    mcrypt_generic_init($td, $padded_cipher_key, $iv);
    $encrypted = mcrypt_generic($td, $padded_plain_text);
    $encode = base64_encode($encrypted);
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);
    #printf("\nencoded: %s", $encode);
    return $encode;
}

function pkcs5_pad ($text, $blocksize)
{
    $pad = $blocksize - (strlen($text) % $blocksize);
    return $text . str_repeat(chr($pad), $pad);
}

function unpadPKCS7($data, $blockSize)
{
    $length = strlen($data);
    if ($length > 0) {
        $first = substr($data, -1);

        if (ord($first) <= $blockSize) {
            for ($i = $length - 2; $i > 0; $i--)
                if (ord($data [$i] != $first))
                    break;

            return substr($data, 0, $i+1);
        }
    }
    return $data;
}

function isBlank($word)
{
    if (($word == null) || ($word == false))
        return true;
    else
        return false;
}

?>
