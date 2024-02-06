package net {
import flash.errors.EOFError;
import flash.utils.ByteArray;

public class VersionInfoParser {

    private const VERSION_INFO_KEY:String = "玩萨特头&玩四害&刷分卡人炸服狗";//玩萨特头&玩四害&刷分卡人炸服狗都是大傻逼!

    private const CLIENT_VERSION:uint = 6;

    public static const EXPIRED:String = "时间码不对";

    public static const CLIENT_NEED_UPDATE:String = "要更新应用";

    public static const DLL_NEED_UPDATE:String = "要更新dll";

    private var firstPageVersion:uint;

    private var time:uint;

    private var clientSwfVersion:uint;

    private var dllDecryptionKey:String;

    public function VersionInfoParser() {
    }

    public function parseVersionInfo(data:ByteArray):String {
        try {
            this.firstPageVersion = data.readUnsignedShort();
            var sb:ByteArray = new ByteArray();
            for (var i:int = 0; i < 10; i++) {
                sb.writeByte(data.readByte());
                sb.writeByte(data.readByte());
                data.readBytes(new ByteArray(), 0, 2);
            }
            sb.position = 0;
            var encryptedPack:ByteArray = new ByteArray();
            data.readBytes(encryptedPack, 0, data.length - data.position);
            Crypto.aesDecrypt(encryptedPack, this.VERSION_INFO_KEY + sb.readUTFBytes(sb.length));
            encryptedPack.position = 0;
            this.time = encryptedPack.readUnsignedInt();
            this.clientSwfVersion = encryptedPack.readUnsignedShort();
            this.dllDecryptionKey = encryptedPack.readUTFBytes(encryptedPack.length - encryptedPack.position);
            return versionVerify();
        } catch (e:EOFError) {
            return EXPIRED;
        }

    }

    private function versionVerify():String {
        var curtime:uint = uint(new Date().fullYear * 100 + new Date().month + 1)
        if (this.time != curtime) {
            return EXPIRED;
        }
        if (this.clientSwfVersion != this.CLIENT_VERSION) {
            return CLIENT_NEED_UPDATE;
        }
        return this.dllDecryptionKey;
    }
}
}
