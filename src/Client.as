package {
import events.XMLEvent;

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
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
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.ContextMenu;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;

import net.AssetsLoader;
import net.DLLLoader;
import net.VersionInfoParser;
import net.XMLLoader;

import ui.*;

public class Client extends Sprite {

    private var fixWidth:Number;

    private var fixHeight:Number;

    private const mainEntryClassPath:String = "com.taomee.seer2.app.MainEntry";

    private var _xmlloader:XMLLoader;

    private var _dllLoader:DLLLoader;

    private var _versionInfoStream:URLStream;

    private var dllDecryptionKey:String;

    private var _isDebug:Boolean = false;

    private var _isLocal:Boolean;

    private var ROOT_URL:String = "http://43.136.112.146/seer2/";

    private const ROOT_URL_LIST:Array = ["http://43.136.112.146/seer2/", "http://106.52.198.27/seer2/", "http://rn.733702.xyz/seer2/", "http://rn-cdn.733702.xyz/seer2/", "http://seer2.61.com/"];

    private var _versionURL:String = "version/version.txt";

    private var _DLLURL:String = "version/library.swf"

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
        this.loadAssets();
    }

    private function loadVersion():void {
        this._versionInfoStream = new URLStream();
        this._versionInfoStream.addEventListener(Event.COMPLETE, this.onVersionComplete);
        this._versionInfoStream.addEventListener(IOErrorEvent.IO_ERROR, onVersionError);
        /*this._versionInfoStream.load(new URLRequest("initialSWF/version.txt"));*/
        this._versionInfoStream.load(new URLRequest("http://43.136.112.146/seer2/" + this._versionURL + "?" + Math.round(Math.random() * 10000)));
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
            this._progressBar.showError("需要版本更新啦!\n下载地址:\nhttp://rn.733702.xyz/seer2/seer2app/seer2.apk");
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
        var file:File = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
        if (file.exists) {
            this._xmlloader = new XMLLoader();
            this._xmlloader.addEventListener(XMLEvent.COMPLETE, this.onGameSettingsXMLComplete);
            this._xmlloader.load(file.url);
        } else {
            this.downloadFileToLocal("initialSWF/GameDefaultSettings.xml", "gameSettings/GameSettings.xml", this.loadGameSettings, "使用默认游戏设置");
        }
    }

    private function onGameSettingsXMLComplete(event:XMLEvent):void {
        this._xmlloader.removeEventListener(XMLEvent.COMPLETE, this.onGameSettingsXMLComplete);
        this._settingsXML = event.data;
        this.ROOT_URL = this.ROOT_URL_LIST[uint(this._settingsXML.elements("rootURL").toString())];
        this.loadVersion();
    }

    private function onAssetsComplete(param1:Event):void {
        var createStaticText:Function = function (_x:int, _y:int, _height:int, _width:int, _mouseEnabled:Boolean):TextField {
            var textField:TextField = new TextField();
            var textFormat:TextFormat = new TextFormat();
            textField.text = "";
            textField.x = _x;
            textField.y = _y;
            textField.height = _height;
            textField.width = _width;
            textField.mouseEnabled = _mouseEnabled;
            textField.alpha = 0.9;
            textFormat.size = _height - 3;
            textFormat.color = 10798591;
            textField.defaultTextFormat = textFormat;
            return textField;
        }

        var createButton:Function = function (_x:int, _y:int, _height:int, _width:int, normal:String):SimpleButton {
            var myButton:SimpleButton;
            var createButtonState:Function = function (color:uint, label:String):Sprite {
                var state:Sprite = new Sprite();
                state.graphics.beginFill(color);
                state.graphics.drawRect(0, 0, _width, _height);
                state.graphics.endFill();
                var labelField:TextField = createStaticText(0, 0, _height, _width, false);
                labelField.text = label;
                labelField.selectable = false;
                state.addChild(labelField);
                return state;
            };
            var normalState:Sprite = createButtonState(5591163, normal);
            var hoverState:Sprite = createButtonState(7700386, normal);
            var downState:Sprite = createButtonState(6369338, normal);
            var disabledState:Sprite = createButtonState(6369338, "已禁用");
            myButton = new SimpleButton(normalState, hoverState, downState, disabledState);
            myButton.x = _x;
            myButton.y = _y;
            return myButton;
        }

        this._assetsLoader.removeEventListener(Event.COMPLETE, this.onAssetsComplete);
        if (stage.stageWidth > stage.stageHeight * 1.82) {
            this.fixWidth = int(stage.stageHeight * 1.82);
            this.fixHeight = stage.stageHeight;
        } else {
            this.fixWidth = stage.stageWidth;
            this.fixHeight = int(stage.stageWidth * 0.55);
        }
        root.width = this.fixWidth;
        root.height = this.fixHeight;
        root.x = (stage.stageWidth - this.fixWidth) / 2;
        root.y = (stage.stageHeight - this.fixHeight) / 2;
        root.scrollRect = new Rectangle(0, 0, this.fixWidth, this.fixHeight);
        var background:Background = new Background();
        background.width = stage.stageWidth;
        background.height = stage.stageHeight;
        this.stage.addChildAt(background, 0);
        var closeGameBtn:SimpleButton = createButton(0, 0, 50, 200, "关闭游戏");
        closeGameBtn.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
            NativeApplication.nativeApplication.exit();
        });
        this.stage.addChild(closeGameBtn);
        this._progressBar = new LoadingBar(stage, this);
        this._progressBar.setup(this._assetsLoader.getClassFromLoader("LoginLoadingBarUI"));
        this._progressBar.show(this);
        this._assetsLoader.dispose();
        this._assetsLoader = null;
        this.loadGameSettings();
    }

    private function loadBeanXML():void {
        this._xmlloader.addEventListener(XMLEvent.COMPLETE, this.onBeanXMLComplete);
        this._xmlloader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
        this._xmlloader.load("initialSWF/bean.xml");
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
        this._isLocal = false;
        this._xmlloader.load("initialSWF/Server.xml");
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
        var file:File = File.applicationStorageDirectory.resolvePath("seer2DLL/library.swf");
        if (file.exists) {
            this._dllLoader = new DLLLoader();
            this._dllLoader.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
            this._dllLoader.addEventListener(DLLLoader.DECRYPTION_SUCCESS, this.onDecryptionSuccess);
            this._dllLoader.addEventListener(DLLLoader.DECRYPTION_ERROR, this.onDecryptionError);
            this._dllLoader.addEventListener(Event.COMPLETE, this.onDLLComplete);
            this._dllLoader.loadFromLocal(file, this.dllDecryptionKey);
        } else {
            this.downloadFileToLocal("http://43.136.112.146/seer2/" + this._DLLURL, "seer2DLL/library.swf", this.loadDLL, "下载DLL中...");
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
        downloadFileToLocal("http://43.136.112.146/seer2/" + this._DLLURL, "seer2DLL/library.swf", this.loadDLL, "DLL需要更新,正在下载DLL");
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
        mainEntry.setXML(this._serverXML, this._beanXML, this._settingsXML);
        mainEntry.setConfig(this._isDebug, this.ROOT_URL, this._isLocal);
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

    private function downloadFileToLocal(url:String, localPath:String, onComplete:Function = null, title:String = ""):String {
        var urlRequest:URLRequest = new URLRequest(url);
        var urlLoader:URLLoader = new URLLoader(urlRequest);
        var file:File = File.applicationStorageDirectory.resolvePath(localPath);
        if (file.exists) {
            file.deleteFile();
        }
        this._progressBar.setTitle(title);
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
            _progressBar.showError("文件下载失败!\n\n试试检查网络并重启游戏!");

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
