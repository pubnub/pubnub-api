<?php

$decrypt = "q/xJqqN6qbiZMXYmiQC1Fw==";
$d2 = "RVOElAJIHskATgCCP+KlaQ==";

$decoded = base64_decode($decrypt);
$key = "67a4f45f0d1d9bc606486fc42dc49416";
$iv = "0123456789012345";

decrypt($decoded, $key, $iv);
encrypt("hellohellohello!", $key, $iv);

function decrypt($ciphertext, $key, $iv) {
    $td = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, '');
    mcrypt_generic_init($td, $key, $iv);
    $decrypted = mdecrypt_generic($td, $ciphertext);
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);

    $unpadded = unpadPKCS7($decrypted, 16);
    printf("\ndecoded: %s", trim($unpadded));
}


function encrypt($encrypt, $key, $iv)
{
    $td = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, '');
    mcrypt_generic_init($td, $key, $iv);
    $encrypted = mcrypt_generic($td, $encrypt);
    $encode = base64_encode($encrypted);
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);
    printf("\nencoded: %s", $encode);
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

    function unpadPKCS7($data, $blockSize)
    {
        $length = strlen($data);
        if ($length > 0) {
            $first = substr($data, -1);

            if (ord($first) <= $blockSize) {
                for ($i = $length - 2; $i > 0; $i--)
                    if (ord($data [$i] != $first))
                        break;

                return substr($data, 0, $i);
            }
        }
        return $data;
    }
}

?>
