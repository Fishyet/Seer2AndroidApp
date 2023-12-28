package
{
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
import flash.events.KeyboardEvent;
import flash.events.ProgressEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.getDefinitionByName;
import net.AssetsLoader;
import net.DLLLoader;
import net.XMLLoader;
import ui.EnterText;
import ui.LoadingBar;

public class Client extends Sprite
   {
      
      private var fixWidth:Number;
      
      private var fixHeight:Number;
      
      private const TURN_XML_URL:String = "turn.xml";
      
      private const ROOT_URL_LIST:Array = ["","",""];
      
      private const CONFIG_XML_URL:String = "config/seer.xml";
      
      private const mainEntryClassPath:String = "com.taomee.seer2.app.MainEntry";
      
      private var _xmlloader:XMLLoader;
      
      private var _dllLoader:DLLLoader;
      
      private var _isDebug:Boolean;
      
      private var _isLocal:Boolean;
      
      private var ROOT_URL:String = "";
      
      private var _turnType:uint;
      
      private var _serverURL:String;
      
      private var _loginURL:String;
      
      private var _assetsURL:String;
      
      private var _versionURL:String;
      
      private var _beanURL:String;
      
      private var _dllXML:XML;
      
      private var _serverXML:XML;
      
      private var _beanXML:XML;
      
      private var _progressBar:LoadingBar;
      
      private var _loginLoader:Loader;
      
      private var _assetsLoader:AssetsLoader;
      
      private var _enterTxt:EnterText;
      
      private var _sessionid:String;
      
      private var _loginData:Object;
      
      private var _loginContent:DisplayObject;
      
      private var _width:Number = 0;
      
      private var _height:Number = 0;
      
      private var clickFlag:Boolean = false;
      
      private var clickStart:Date;
      
      private var clickEnd:Date;

      private var _contextMenu:ContextMenu;

      public static var lc:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
      
      public function Client()
      {
         this.clickStart = new Date();
         this.clickEnd = new Date();
         super();
         lc.allowCodeImport = true;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddStage);

      }
      
      public static function getVersionView() : String
      {
         var _loc1_:Date = TaomeeVersionManager.getInstance().lastModifiedDate as Date;
         return _loc1_.fullYear + "." + (_loc1_.getMonth() + 1) + "." + _loc1_.getDate() + " " + _loc1_.toLocaleTimeString();
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      private function onAddStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddStage);
         if(Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX") {
            this.registerJS();
            this.initialize();
         }
         else
         {
            this.initialize();
         }
      }

      
      private function initialize() : void
      {

         stage.stageFocusRect = false;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("fit_size");
         }
         this._contextMenu = new ContextMenu();
         this._contextMenu.hideBuiltInItems();
         this.showEnterText("请稍候，正在进入赛尔Ⅱ...");
         this._turnType = 0;
         this.ROOT_URL = "http://seer2.61.com/";
         this.loadConfig();
         DLLLoader.size = 1011;
      }
      
      private function showEnterText(param1:String) : void
      {
         if(this._enterTxt == null)
         {
            this._enterTxt = new EnterText(this.fixWidth,this.fixHeight);
         }
         this._enterTxt.setText(param1);
         addChild(this._enterTxt);
      }
      
      private function loadTurnXML() : void
      {
         this._xmlloader = new XMLLoader();
         this._xmlloader.addEventListener(XMLEvent.COMPLETE,this.onTurnXMLComplete);
         this._xmlloader.load(this.ROOT_URL + this.TURN_XML_URL + "?" + Math.random());
      }
      
      private function onTurnXMLComplete(param1:XMLEvent) : void
      {
         this._xmlloader.removeEventListener(XMLEvent.COMPLETE,this.onTurnXMLComplete);
         var _loc2_:XML = param1.data;
         this._turnType = uint(_loc2_.type);
         this.ROOT_URL = this.ROOT_URL_LIST[this._turnType];
         this.loadConfig();
      }
      
      private function loadConfig() : void
      {
         this._xmlloader = new XMLLoader();
         this._xmlloader.addEventListener(XMLEvent.COMPLETE,this.onConfigXMLComplete);
         this._xmlloader.load(this.ROOT_URL + this.CONFIG_XML_URL + "?" + Math.random());
      }
      
      private function onConfigXMLComplete(param1:XMLEvent) : void
      {
         this._xmlloader.removeEventListener(XMLEvent.COMPLETE,this.onConfigXMLComplete);
         var _loc2_:XML = param1.data;
         this._isDebug = false;
         this._serverURL = String(_loc2_.server);
         this._loginURL = String(_loc2_.login);
         this._assetsURL = String(_loc2_.assets);
         this._versionURL = String(_loc2_.version);
         this._beanURL = String(_loc2_.bean);
         this._dllXML = _loc2_.dll[0];
         this.loadVersion();
      }
      
      private function loadVersion() : void
      {
         TaomeeVersionManager.getInstance().load(this.ROOT_URL + this._versionURL,this.onVersionComplete);
      }
      
      private function onVersionComplete() : void
      {
         var _loc1_:ContextMenuItem = new ContextMenuItem("您的客户端版本：" + getVersionView());
         this.loadAssets();
      }
      
      private function loadAssets() : void
      {
         this._assetsLoader = new AssetsLoader();
         this._assetsLoader.addEventListener(Event.COMPLETE,this.onAssetsComplete);
         this._assetsLoader.load(this.ROOT_URL + TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._assetsURL));
      }
      
      private function onAssetsComplete(param1:Event) : void
      {
         this._assetsLoader.removeEventListener(Event.COMPLETE,this.onAssetsComplete);
         removeChild(this._enterTxt);
         this._enterTxt = null;
         this._progressBar = new LoadingBar(stage);
         this._progressBar.setup(this._assetsLoader.getClassFromLoader("LoginLoadingBarUI"));
         this._progressBar.show(this);
         this._assetsLoader.dispose();
         this._assetsLoader = null;
         this.loadBeanXML();
      }
      
      private function loadBeanXML() : void
      {
         this._xmlloader.addEventListener(XMLEvent.COMPLETE,this.onBeanXMLComplete);
         this._xmlloader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._xmlloader.load(this.ROOT_URL + TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._beanURL));
      }
      
      private function onBeanXMLComplete(param1:XMLEvent) : void
      {
         this._xmlloader.removeEventListener(XMLEvent.COMPLETE,this.onBeanXMLComplete);
         this._xmlloader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._beanXML = param1.data;
         this.loadServerXML();
      }
      
      private function loadServerXML() : void
      {
         this._xmlloader.addEventListener(XMLEvent.COMPLETE,this.onServerXMLComplete);
         this._xmlloader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._isLocal = String(this._serverURL.split("/")[1]).search("_") != -1;
         this._xmlloader.load(this.ROOT_URL + TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._serverURL));
      }
      
      private function onServerXMLComplete(param1:XMLEvent) : void
      {
         this._xmlloader.removeEventListener(XMLEvent.COMPLETE,this.onServerXMLComplete);
         this._xmlloader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._xmlloader.destroy();
         this._xmlloader = null;
         this._serverXML = param1.data;
         this.loadLogin();
      }
      
      private function loadLogin() : void
      {
         this._progressBar.setTitle("正在加载登陆界面");
         this._loginLoader = new Loader();
         this._loginLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoginBytesComplete);
         this._loginLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._loginLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
         var _loc1_:URLRequest = new URLRequest("assets/LoginModule.swf");
         this._loginLoader.load(_loc1_,lc);
      }
      
      private function onLoginBytesComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         var _loc3_:Loader = new Loader();
         _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoginComplete);
         _loc3_.loadBytes(_loc2_.bytes,lc);
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoginBytesComplete);
         _loc2_.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
      }
      
      private function onLoginComplete(param1:Event) : void
      {
         this._progressBar.hide();
         (param1.target as LoaderInfo).removeEventListener(Event.COMPLETE,this.onLoginComplete);
         this._loginContent = (param1.target as LoaderInfo).content;
         this._loginContent["success"] = this.onLoginSuccess;
         this._loginContent["setXmlInfo"](this._serverXML);
         this._loginContent["setVersionObj"](TaomeeVersionManager);
         this._loginContent["init"](this.ROOT_URL);
         addChild(this._loginContent);
         if(stage.stageWidth / stage.stageHeight > 1.9){
            stage.stageWidth = int(stage.stageHeight * 1.9);
         }
         this.fixWidth = stage.stageWidth;
         this.fixHeight = stage.stageHeight;
         root.width = this.fixWidth;
         root.height = this.fixHeight;
         root.scrollRect = new Rectangle(0,0,this.fixWidth,this.fixHeight);
         stage.addEventListener(Event.RESIZE,this.onResize);
         this.onResize(null);
      }
      
      private function onResize(param1:Event) : void
      {

         this._loginContent["layOut"](stage);
      }
      
      private function onLoginSuccess(param1:Object) : void
      {
         removeChild(this._loginContent);
         stage.removeEventListener(Event.RESIZE,this.onResize);
         this._loginData = param1;
         this._loginLoader.unloadAndStop();
         this._loginContent = null;
         this._loginLoader = null;
         this.loadDLL();
      }
      
      private function loadDLL() : void
      {
         this._progressBar.setTitle("正在进入游戏");
         this._progressBar.show(this);
         this._dllLoader = new DLLLoader();
         this._dllLoader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._dllLoader.addEventListener(Event.COMPLETE,this.onDLLComplete);
         this._dllLoader.doLoad();
      }
      
      private function onDLLComplete(param1:Event) : void
      {
         var mainEntryClass:*;
         var mainEntry:Object = null;
         var e:Event = param1;
         this._dllLoader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._dllLoader.removeEventListener(Event.COMPLETE,this.onDLLComplete);
         this._dllLoader = null;
         mainEntryClass = getDefinitionByName(this.mainEntryClassPath);
         mainEntry = new mainEntryClass();
         mainEntry.setXML(this._serverXML,this._beanXML);
         mainEntry.setConfig(this._isDebug,TaomeeVersionManager,this.ROOT_URL,this._isLocal);
         this._progressBar.dispose();
         this._progressBar = null;
         this._dllXML = null;
         this._serverXML = null;
         this._beanXML = null;
         if(true)
         {
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN,function(param1:KeyboardEvent):void
            {
               var _loc2_:uint = 0;
               if(param1.keyCode == 32)
               {
                  if(!clickFlag)
                  {
                     clickFlag = true;
                     clickStart = new Date();
                  }
                  else
                  {
                     clickFlag = false;
                     clickEnd = new Date();
                  }
                  _loc2_ = Math.abs(clickEnd.getTime() - clickStart.getTime());
                  if(_loc2_ > 100 && _loc2_ < 300)
                  {
                     mainEntry.showDebugToolPanel();
                  }
               }
            });
         }
         mainEntry.initialize(this,this._loginData);
      }
      
      private function registerJS() : void
      {
         ExternalInterface.addCallback("startWebSessionLogin",this.startWebSessionLogin);
      }
      
      private function startWebSessionLogin(param1:String) : void
      {
         this._sessionid = param1;
         if(this._loginLoader.content)
         {
            this._loginLoader.content["sessionId"] = this._sessionid;
            this._loginLoader.content["loginStart"]();
         }
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         var _loc2_:int = param1.bytesLoaded / param1.bytesTotal * 100;
         this._progressBar.progress(_loc2_);
      }
      
      private function onIoError(param1:IOErrorEvent) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoginComplete);
         _loc2_.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
         this._progressBar.dispose();
         this._progressBar = null;
         throw new Error(param1.text);
      }
   }
}
