package {
import com.taomee.plugins.versionManager.TaomeeVersionManager;

import events.XMLEvent;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.ui.ContextMenu;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;

import net.AssetsLoader;
import net.DLLLoader;
import net.VersionInfoParser;
import net.XMLLoader;

import ui.*;

public class Client extends Sprite {

    private var fixWidth:Number = 1800;

    private var fixHeight:Number = 900;

    private const mainEntryClassPath:String = "com.taomee.seer2.app.MainEntry";

    private var _xmlloader:XMLLoader;

    private var _dllLoader:DLLLoader;

    private var _versionInfoStream:URLStream;

    private var dllDecryptionKey:String;

    private var _isDebug:Boolean = false;

    private var _isLocal:Boolean;

    private var ROOT_URL:String = "http://106.52.198.27/seer2/";

    private var _serverURL:String = "config/Server.xml";

    private var _versionURL:String = "version/version.txt";

    private var _beanURL:String = "config/bean.xml";

    private var _settingsXML:XML;

    private var _serverXML:XML;

    private var _beanXML:XML;

    private var _progressBar:LoadingBar;

    private var _loginLoader:Loader;

    private var _assetsLoader:AssetsLoader;

    private var _loginData:Object;

    private var _loginContent:DisplayObject;

    private var _width:Number = 0;

    private var _height:Number = 0;

    private var clickFlag:Boolean = false;

    private var clickStart:Date;

    private var clickEnd:Date;

    private var _contextMenu:ContextMenu;

    public static var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

    public function Client() {
        this.clickStart = new Date();
        this.clickEnd = new Date();
        super();
        lc.allowCodeImport = true;
        addEventListener(Event.ADDED_TO_STAGE, this.onAddStage);

    }

    override public function set width(param1:Number):void {
        this._width = param1;
    }

    override public function get width():Number {
        return this._width;
    }

    override public function set height(param1:Number):void {
        this._height = param1;
    }

    override public function get height():Number {
        return this._height;
    }

    private function onAddStage(param1:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, this.onAddStage);
        this.initialize();
    }


    private function initialize():void {
        stage.stageFocusRect = false;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        this._contextMenu = new ContextMenu();
        this._contextMenu.hideBuiltInItems();
        this.loadGameSettings();

    }

    private function loadVersion():void {

        this._versionInfoStream = new URLStream();
        this._versionInfoStream.addEventListener(Event.COMPLETE, this.onVersionComplete);
        this._versionInfoStream.addEventListener(IOErrorEvent.IO_ERROR, onVersionError);
        /*this._versionInfoStream.load(new URLRequest("initialSWF/version.txt"));*/
        this._versionInfoStream.load(new URLRequest("http://106.52.198.27/seer2/" + this._versionURL + "?" + Math.round(Math.random() * 1000)));
    }

    private function onVersionComplete(event:Event):void {
        this._versionInfoStream.removeEventListener(Event.COMPLETE, this.onVersionComplete);
        this._versionInfoStream.removeEventListener(IOErrorEvent.IO_ERROR, this.onVersionError);
        var versionInfo:ByteArray = new ByteArray();
        this._versionInfoStream.readBytes(versionInfo);
        this._versionInfoStream.close();
        this._versionInfoStream = null;
        var versionInfoParser:VersionInfoParser = new VersionInfoParser();
        this.dllDecryptionKey = versionInfoParser.parseVersionInfo(versionInfo);
        if (dllDecryptionKey == VersionInfoParser.EXPIRED) {
            this._progressBar.showError("校验失败,无法进入游戏\n请刷新应用缓存后重试");
        } else if (dllDecryptionKey == VersionInfoParser.CLIENT_NEED_UPDATE) {
            this._progressBar.showError("需要版本更新啦!\n下载地址:");
        } else {
            this.loadBeanXML();
        }
    }

    private function onVersionError(e:IOErrorEvent):void {
        this._versionInfoStream.removeEventListener(Event.COMPLETE, this.onVersionComplete);
        this._versionInfoStream.removeEventListener(IOErrorEvent.IO_ERROR, this.onVersionError);
        this._progressBar.showError("版本文件下载失败!\n请检查网络后重启游戏");
    }

    private function loadAssets():void {
        this._assetsLoader = new AssetsLoader();
        this._assetsLoader.addEventListener(Event.COMPLETE, this.onAssetsComplete);
        this._assetsLoader.load();
    }

    private function loadGameSettings():void {
        this._xmlloader = new XMLLoader();
        this._xmlloader.addEventListener(XMLEvent.COMPLETE, this.onGameSettingsXMLComplete);
        this._xmlloader.load("initialSWF/GameDefaultSettings.xml");
    }

    private function onGameSettingsXMLComplete(event:XMLEvent):void {
        this._xmlloader.removeEventListener(XMLEvent.COMPLETE, this.onGameSettingsXMLComplete);
        this._settingsXML = event.data;
        this.ROOT_URL = this._settingsXML.child("rootURL").toString();
        this.loadAssets();

    }

    private function onAssetsComplete(param1:Event):void {
        this._assetsLoader.removeEventListener(Event.COMPLETE, this.onAssetsComplete);
        this.fixWidth = int(stage.stageHeight * 1.82);
        this.fixHeight = stage.stageHeight;
        root.width = this.fixWidth;
        root.height = this.fixHeight;
        root.x = (stage.stageWidth - this.fixWidth) / 2;
        root.scrollRect = new Rectangle(0, 0, this.fixWidth, this.fixHeight);
        this._progressBar = new LoadingBar(stage, this);
        this._progressBar.setup(this._assetsLoader.getClassFromLoader("LoginLoadingBarUI"));
        this._progressBar.show(this);
        this._assetsLoader.dispose();
        this._assetsLoader = null;
        loadVersion();
    }

    private function loadBeanXML():void {
        this._xmlloader.addEventListener(XMLEvent.COMPLETE, this.onBeanXMLComplete);
        this._xmlloader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._xmlloader.load(this.ROOT_URL + TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._beanURL));
    }

    private function onBeanXMLComplete(param1:XMLEvent):void {
        this._xmlloader.removeEventListener(XMLEvent.COMPLETE, this.onBeanXMLComplete);
        this._xmlloader.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._beanXML = param1.data;
        this.loadServerXML();
    }

    private function loadServerXML():void {
        this._xmlloader.addEventListener(XMLEvent.COMPLETE, this.onServerXMLComplete);
        this._xmlloader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._isLocal = String(this._serverURL.split("/")[1]).search("_") != -1;
        this._xmlloader.load(this.ROOT_URL + TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._serverURL));
    }

    private function onServerXMLComplete(param1:XMLEvent):void {
        this._xmlloader.removeEventListener(XMLEvent.COMPLETE, this.onServerXMLComplete);
        this._xmlloader.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._xmlloader.destroy();
        this._xmlloader = null;
        this._serverXML = param1.data;
        this.loadLogin();
    }

    private function loadLogin():void {
        this._progressBar.setTitle("正在加载登陆界面");
        this._loginLoader = new Loader();
        this._loginLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoginBytesComplete);
        this._loginLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._loginLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIoError);
        this._loginLoader.load(new URLRequest("initialSWF/LoginModule.swf"), lc);
    }

    private function onLoginBytesComplete(param1:Event):void {
        var _loc2_:LoaderInfo = param1.target as LoaderInfo;
        var _loc3_:Loader = new Loader();
        _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoginComplete);
        _loc3_.loadBytes(_loc2_.bytes, lc);
        _loc2_.removeEventListener(Event.COMPLETE, this.onLoginBytesComplete);
        _loc2_.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        _loc2_.removeEventListener(IOErrorEvent.IO_ERROR, this.onIoError);
    }

    private function onLoginComplete(param1:Event):void {
        this._progressBar.hide();
        (param1.target as LoaderInfo).removeEventListener(Event.COMPLETE, this.onLoginComplete);
        this._loginContent = (param1.target as LoaderInfo).content;
        this._loginContent["success"] = this.onLoginSuccess;
        this._loginContent["setXmlInfo"](this._serverXML);
        this._loginContent["setVersionObj"](TaomeeVersionManager);
        this._loginContent["init"](this.ROOT_URL);
        addChild(this._loginContent);
        stage.addEventListener(Event.RESIZE, this.onResize);
        this.onResize(null);
    }

    private function onResize(param1:Event):void {

        this._loginContent["layOut"](this);
    }

    private function onLoginSuccess(param1:Object):void {
        removeChild(this._loginContent);
        stage.removeEventListener(Event.RESIZE, this.onResize);
        this._loginData = param1;
        this._loginLoader.unloadAndStop();
        this._loginContent = null;
        this._loginLoader = null;
        this.loadDLL();
        /*downloadFileToLocal("seer2DLL/library.swf","seer2DLL/library.swf",this.loadDLL);*/
    }

    private function loadDLL():void {
        this._progressBar.setTitle("正在读取游戏核心DLL");
        this._progressBar.show(this);
        this._dllLoader = new DLLLoader();
        this._dllLoader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._dllLoader.addEventListener(DLLLoader.DECRYPTION_SUCCESS, this.onDecryptionSuccess);
        this._dllLoader.addEventListener(DLLLoader.DECRYPTION_ERROR, this.onDecryptionError);
        this._dllLoader.addEventListener(Event.COMPLETE, this.onDLLComplete);
        var file:File = File.applicationStorageDirectory.resolvePath("seer2DLL/library.swf");
        if (file.exists) {
            this._dllLoader.loadFromLocal(file, this.dllDecryptionKey);
        } else {
            this._dllLoader.loadFromOrigin("seer2DLL/library.swf", this.dllDecryptionKey);
        }

    }

    private function onDecryptionSuccess(param1:Event):void {
        _dllLoader.removeEventListener(DLLLoader.DECRYPTION_SUCCESS, this.onDecryptionSuccess);
        _progressBar.setTitle("正在加载游戏核心DLL");
    }

    private function onDecryptionError(param1:Event):void {
        this._dllLoader.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._dllLoader.removeEventListener(DLLLoader.DECRYPTION_SUCCESS, this.onDecryptionSuccess);
        this._dllLoader.removeEventListener(DLLLoader.DECRYPTION_ERROR, this.onDecryptionError);
        this._dllLoader.removeEventListener(Event.COMPLETE, this.onDLLComplete);
        downloadFileToLocal("http://106.52.198.27/seer2/version/library.swf", "seer2DLL/library.swf", this.loadDLL, "DLL");
    }

    private function onDLLComplete(param1:Event):void {
        var mainEntryClass:*;
        var mainEntry:Object = null;
        var e:Event = param1;
        this._dllLoader.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._dllLoader.removeEventListener(DLLLoader.DECRYPTION_ERROR, this.onDecryptionError);
        this._dllLoader.removeEventListener(Event.COMPLETE, this.onDLLComplete);
        this._dllLoader = null;
        mainEntryClass = getDefinitionByName(this.mainEntryClassPath);
        mainEntry = new mainEntryClass();
        mainEntry.setXML(this._serverXML, this._beanXML);
        mainEntry.setConfig(this._isDebug, TaomeeVersionManager, this.ROOT_URL, this._isLocal);
        this._progressBar.dispose();
        this._progressBar = null;
        this._serverXML = null;
        this._beanXML = null;
        mainEntry.initialize(this, this._loginData);
    }

    private function onProgress(param1:ProgressEvent):void {
        var _loc2_:int = param1.bytesLoaded / param1.bytesTotal * 100;
        this._progressBar.progress(_loc2_);
    }

    private function onIoError(param1:IOErrorEvent):void {
        var _loc2_:LoaderInfo = param1.target as LoaderInfo;
        _loc2_.removeEventListener(Event.COMPLETE, this.onLoginComplete);
        _loc2_.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
        _loc2_.removeEventListener(IOErrorEvent.IO_ERROR, this.onIoError);
        this._progressBar.dispose();
        this._progressBar = null;
        throw new Error(param1.text);
    }

    private function downloadFileToLocal(url:String, localPath:String, onComplete:Function = null, name:String = ""):String {
        var urlRequest:URLRequest = new URLRequest(url);
        var urlLoader:URLLoader = new URLLoader(urlRequest);
        var file:File = File.applicationStorageDirectory.resolvePath(localPath);
        if (file.exists) {
            file.deleteFile();
        }
        this._progressBar.setTitle(name + "需要更新,正在下载" + name + "文件...");
        this._progressBar.show(this);
        var onDownloadComplete:Function = function (event:Event):void {

            urlLoader.removeEventListener(Event.COMPLETE, onDownloadComplete);
            urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            _progressBar.hide();
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.WRITE);
            fileStream.writeBytes(urlLoader.data);
            fileStream.close();
            if (onComplete != null) {
                onComplete();
            }
        }
        var onDownloadError:Function = function (event:IOErrorEvent):void {
            urlLoader.removeEventListener(Event.COMPLETE, onDownloadComplete);
            urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            _progressBar.showError(name + "文件下载失败!\n\n试试检查网络并重启游戏!");

        }
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        urlLoader.addEventListener(Event.COMPLETE, onDownloadComplete);
        urlLoader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
        urlLoader.load(urlRequest);
        return file.url;
    }


}
}
