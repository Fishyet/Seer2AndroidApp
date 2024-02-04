package net {
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

public class DLLLoader extends EventDispatcher {

    private var _loader:Loader;

    private var urlStream:URLStream;

    private var fileStream:FileStream;

    private var key:String;

    public static const DECRYPTION_ERROR:String = "decryptionError";

    public static const DECRYPTION_SUCCESS:String = "decryptionSuccess";

    public function DLLLoader() {
        super();
        this._loader = new Loader();
    }

    public function loadFromOrigin(url:String, _key:String):void {
        this.urlStream = new URLStream();
        this.key = _key;
        this.urlStream.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this.urlStream.addEventListener(Event.COMPLETE, this.onStreamComplete);
        this.urlStream.load(new URLRequest(url));
    }

    public function loadFromLocal(file:File, _key:String):void {
        this.fileStream = new FileStream();
        this.key = _key;
        this.fileStream.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this.fileStream.addEventListener(Event.COMPLETE, this.onStreamComplete);
        this.fileStream.openAsync(file, FileMode.READ);
    }

    private function onStreamComplete(e:Event) {
        var fileContent:ByteArray = new ByteArray();

        if (this.fileStream != null) {
            this.fileStream.readBytes(fileContent); // 将文件内容读取到 ByteArray 中
            this.fileStream.close(); // 关闭文件流
            this.fileStream.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
            this.fileStream = null;
        } else {
            this.urlStream.readBytes(fileContent);
            this.urlStream.close();
            this.urlStream.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
            this.urlStream = null;

        }


        Crypto.rc4Decrypt(fileContent, this.key);

        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoaderOver);
        this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
        this._loader.loadBytes(fileContent, Client.lc);


    }

    private function onLoaderOver(param1:Event):void {
        this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onLoaderOver);
        this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function onLoaderError(param1:IOErrorEvent):void {
        this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onLoaderOver);
        this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
        dispatchEvent(new Event(DECRYPTION_ERROR));
    }


    private function onProgress(event:ProgressEvent):void {
        dispatchEvent(event);

    }
}
}


