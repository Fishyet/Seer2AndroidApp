package net {
import com.hurlant.crypto.prng.ARC4;
import com.hurlant.crypto.symmetric.AESKey;
import com.hurlant.crypto.symmetric.ECBMode;

import flash.utils.ByteArray;

public class Crypto {

    public function Crypto() {

    }

    public static function aesDecrypt(_data:ByteArray, _key:String):void {
        var temp:ByteArray = new ByteArray();
        temp.writeUTFBytes(_key);
        temp.position = 0;
        var aesKey:AESKey = new AESKey(temp);
        var ecb:ECBMode = new ECBMode(aesKey);
        ecb.decrypt(_data);
    }


    public static function rc4Decrypt(_data:ByteArray, _key:String):void {
        var temp:ByteArray = new ByteArray();
        temp.writeUTFBytes(_key);
        temp.position = 0;
        var rc4:ARC4 = new ARC4(temp);
        rc4.decrypt(_data);
    }


}
}
