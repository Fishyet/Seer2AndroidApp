package com.taomee.seer2.app.netForRelogin {
import com.taomee.seer2.core.net.LittleEndianByteArray;

import flash.utils.ByteArray;

public class Message {

    public static const HEAD_LENGTH:int = 18;


    private var _length:uint;

    public var cmdId:uint;

    public var uid:uint;

    public var sequenceIndex:uint;

    public var statusCode:uint;

    private var _rawData:LittleEndianByteArray;

    public function Message(param1:ByteArray) {
        super();
        this.parseHead(param1);
        this.parseBody(param1);
    }

    private function parseHead(param1:ByteArray):void {
        this._length = param1.readUnsignedInt();
        this.cmdId = param1.readUnsignedShort();
        this.uid = param1.readUnsignedInt();
        this.sequenceIndex = param1.readUnsignedInt();
        this.statusCode = param1.readUnsignedInt();
    }

    private function parseBody(param1:ByteArray):void {
        this._rawData = new LittleEndianByteArray();
        var _loc2_:int = this._length - HEAD_LENGTH;
        if (_loc2_ > 0) {
            param1.readBytes(this._rawData, 0, _loc2_);
        }
    }

    public function getRawData():LittleEndianByteArray {
        return this._rawData;
    }

    public function getRawDataCopy():ByteArray {
        this._rawData.position = 0;
        var _loc1_:ByteArray = new ByteArray();
        _loc1_.endian = this._rawData.endian;
        this._rawData.readBytes(_loc1_);
        _loc1_.position = 0;
        this._rawData.position = 0;
        return _loc1_;
    }
}
}
