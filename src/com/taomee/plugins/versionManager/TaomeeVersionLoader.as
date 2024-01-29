package com.taomee.plugins.versionManager {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

public class TaomeeVersionLoader extends EventDispatcher {


    private var _fileURL:String;

    private var _lastModifiedTime:uint;

    private var _newURL:String;

    private var _version:uint;

    private var _bodyData:ByteArray;

    private var _configLoader:URLLoader;

    private var _fileStreamLoader:URLStream;

    public function TaomeeVersionLoader() {
        super();
    }

    private function startLoadConfig():void {
        this._configLoader = new URLLoader();
        this._configLoader.addEventListener(Event.COMPLETE, this.configLoadedHandler);
        this._configLoader.addEventListener(IOErrorEvent.IO_ERROR, this.configErrorHandler);
        this._configLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.configErrorHandler);
        this._configLoader.load(new URLRequest(this._fileURL));
    }

    private function configErrorHandler(param1:Event):void {
        throw new Error("版本配置文件加载失败");
    }

    private function configLoadedHandler(param1:Event):void {
        this._lastModifiedTime = Number(param1.target.data);
        var _loc2_:int = this._fileURL.lastIndexOf("/");
        this._newURL = this._fileURL.slice(0, _loc2_ != -1 ? _loc2_ : 0);
        this._newURL = this._newURL + "/version" + this._lastModifiedTime + ".swf";
        this._fileStreamLoader = new URLStream();
        this._fileStreamLoader.addEventListener(Event.COMPLETE, this.fileLoadedHandler);
        this._fileStreamLoader.addEventListener(IOErrorEvent.IO_ERROR, this.fileErrorHandler);
        this._fileStreamLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.fileErrorHandler);
        this._fileStreamLoader.load(new URLRequest(this._newURL));
    }

    private function fileErrorHandler(param1:Event):void {
        throw new Error("版本文件加载失败");
    }

    private function fileLoadedHandler(param1:Event):void {
        this._version = this._fileStreamLoader.readUnsignedInt();
        if (this._version != com.taomee.plugins.versionManager.TaomeeVersionManager.VERSION) {
            throw "版本不匹配(" + this._version + "->" + com.taomee.plugins.versionManager.TaomeeVersionManager.VERSION + ")！";
        }
        this._lastModifiedTime = this._fileStreamLoader.readUnsignedInt();
        this._bodyData = new ByteArray();
        this._fileStreamLoader.readBytes(this._bodyData);
        this._bodyData.position = 0;
        this._bodyData.uncompress();
        this._fileStreamLoader.close();
        dispatchEvent(new com.taomee.plugins.versionManager.TaomeeVersionEvent(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOADED));
    }

    public function load(param1:String):void {
        this._fileURL = param1;
        this.startLoadConfig();
    }

    public function get bodyData():ByteArray {
        return this._bodyData;
    }

    public function get lastModifiedTime():uint {
        return this._lastModifiedTime;
    }
}
}
