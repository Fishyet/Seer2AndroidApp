package com.taomee.plugins.pandaVersionManager
{
   import com.taomee.plugins.taomeeLoader.ByteLoader;
   import com.taomee.plugins.taomeeLoader.ByteLoaderEvent;
   import com.taomee.utils.LoaderUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class PandaVersionLoader extends EventDispatcher
   {
       
      
      public var BC_List:Object;
      
      private var _auoLoadBody:Boolean = false;
      
      private var _fileURL:String;
      
      private var _headerCount:uint;
      
      private var _headerFileDic:Dictionary;
      
      private var _headerLength:uint;
      
      private var _lastAmendTime:uint;
      
      private var _newURL:String;
      
      private var _version:uint;
      
      private var _versionNameSpace:String;
      
      private var fileLoader:ByteLoader;
      
      private var hasHeaderloaded:Boolean = false;
      
      private var hasReload:Boolean = false;
      
      public function PandaVersionLoader(param1:String, param2:Boolean = false)
      {
         this._headerFileDic = new Dictionary();
         super();
         this._versionNameSpace = param1;
         this._auoLoadBody = param2;
      }
      
      public function get byteLoader() : ByteLoader
      {
         return this.fileLoader;
      }
      
      public function close() : void
      {
         BC.removeEvent(this);
         this.fileLoader.close();
      }
      
      public function load(param1:String) : void
      {
         this._fileURL = param1;
         this.fileLoader = new ByteLoader(true,15000);
         LoaderUtil.addLoaderEvents(this,this.fileLoader,this._onComplete,this._ioErrorFun,null,null,this._onProgressFun);
         LoaderUtil.addByteLoaderEvents(this,this.fileLoader,null,this._onTimeoutFun,this._getDataBginFun);
         this.hasReload = false;
         this.fileLoader.load(new URLRequest(this._fileURL));
      }
      
      public function loadBody() : void
      {
         if(this.hasReload)
         {
            LoaderUtil.addLoaderEvents(this,this.fileLoader,null,null,null,null,this._onProgressFun);
            this.fileLoader.load(new URLRequest(this._newURL));
            return;
         }
         throw "必须HEADER部分加载完成后才能对BODY进行加载.";
      }
      
      private function _checkAmendLoaded(param1:ByteLoaderEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ByteArray = null;
         var _loc4_:String = null;
         if(this.fileLoader.bytesLoaded >= 10 && this.fileLoader.bytesTotal < 13 || this.fileLoader.bytesLoaded <= 13 && this.fileLoader.bytesTotal <= 39)
         {
            this._lastAmendTime = Number(this.fileLoader.readUTFBytes(10));
            BC.removeEvent(this,this.fileLoader,ByteLoaderEvent.GET_BYTE_DATA,this._checkAmendLoaded);
            dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_HEADER_AMEND_LOADED));
            _loc2_ = this._fileURL.lastIndexOf("/");
            this._newURL = this._fileURL.slice(0,_loc2_ != -1 ? _loc2_ : 0);
            this._newURL = this._newURL + "/version" + this._lastAmendTime + ".swf";
            this.changeVersion_AotuReLoad();
         }
         else if(this.fileLoader.bytesLoaded >= 13)
         {
            _loc3_ = this.fileLoader.getByteArray();
            if((_loc4_ = _loc3_.readUTFBytes(2)) != "JK")
            {
               throw "版本信息文件格式错误！";
            }
            this._lastAmendTime = _loc3_.readUnsignedInt();
            this._version = _loc3_.readByte();
            this._headerLength = _loc3_.readUnsignedInt();
            this._headerCount = _loc3_.readShort();
            BC.removeEvent(this,this.fileLoader,ByteLoaderEvent.GET_BYTE_DATA,this._checkAmendLoaded);
            dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_HEADER_AMEND_LOADED));
         }
      }
      
      private function _checkHeaderLoaded(param1:ByteLoaderEvent) : void
      {
         var _loc2_:com.taomee.plugins.pandaVersionManager.PandaVersionManager = null;
         if(this.fileLoader.bytesLoaded >= this._headerLength)
         {
            this.parseHeader();
            BC.removeEvent(this,this.fileLoader,ByteLoaderEvent.GET_BYTE_DATA,this._checkHeaderLoaded);
            this.hasHeaderloaded = true;
            _loc2_ = com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(this._versionNameSpace) as com.taomee.plugins.pandaVersionManager.PandaVersionManager;
            _loc2_.flushHeader(this._lastAmendTime,this._headerFileDic);
            if(!this._auoLoadBody)
            {
               this.fileLoader.close();
            }
            dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_HEADER_LOADED));
         }
      }
      
      private function _getDataBginFun(param1:ByteLoaderEvent) : void
      {
         if(this.fileLoader.bytesTotal <= 6 && this.fileLoader.bytesLoaded <= 0)
         {
            LoaderUtil.addByteLoaderEvents(this,this.fileLoader,null,this._onTimeoutFun,this._getDataBginFun);
            throw "文件太小了." + this.fileLoader.bytesTotal;
         }
         if(!this.hasReload)
         {
            BC.addEvent(this,this.fileLoader,ByteLoaderEvent.GET_BYTE_DATA,this._checkAmendLoaded);
         }
         else if(!this.hasHeaderloaded)
         {
            BC.addEvent(this,this.fileLoader,ByteLoaderEvent.GET_BYTE_DATA,this._checkHeaderLoaded);
         }
      }
      
      private function _onProgressFun(param1:ProgressEvent) : void
      {
         dispatchEvent(new ProgressEvent(param1.type,false,false,param1.bytesLoaded,param1.bytesTotal));
      }
      
      private function _ioErrorFun(param1:Event) : void
      {
         dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOAD_ERROR));
      }
      
      private function _onComplete(param1:Event) : void
      {
         if(!this.hasHeaderloaded && !this.hasReload)
         {
            this._checkAmendLoaded(null);
            return;
         }
         BC.removeEvent(this);
         if(!this.hasHeaderloaded)
         {
            this._checkHeaderLoaded(new ByteLoaderEvent(ByteLoaderEvent.GET_BYTE_DATA));
         }
         var _loc2_:ByteArray = new ByteArray();
         this.fileLoader.readBytes(_loc2_);
         _loc2_.position = 0;
         _loc2_.uncompress();
         var _loc3_:com.taomee.plugins.pandaVersionManager.PandaVersionManager = com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(this._versionNameSpace) as com.taomee.plugins.pandaVersionManager.PandaVersionManager;
         _loc3_.flushBady(_loc2_.readObject());
         dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOADED));
      }
      
      private function _onTimeoutFun(param1:ByteLoaderEvent) : void
      {
         this.fileLoader.reTry();
         dispatchEvent(new com.taomee.plugins.pandaVersionManager.PandaVersionEvent(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOAD_TIMEOUT));
      }
      
      private function changeVersion_AotuReLoad() : void
      {
         this.hasReload = true;
         this.fileLoader.load(new URLRequest(this._newURL));
      }
      
      private function parseHeader() : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc1_:String = this.fileLoader.readUTFBytes(2);
         if(_loc1_ != "JK")
         {
            throw "版本信息文件格式错误！";
         }
         this._lastAmendTime = this.fileLoader.readUnsignedInt();
         this._version = this.fileLoader.readByte();
         this._headerLength = this.fileLoader.readUnsignedInt();
         this._headerCount = this.fileLoader.readShort();
         var _loc2_:int = 0;
         while(_loc2_ < this._headerCount)
         {
            _loc3_ = int(this.fileLoader.readUnsignedByte());
            _loc4_ = this.fileLoader.readUTFBytes(_loc3_);
            _loc5_ = int(this.fileLoader.readUnsignedByte());
            this._headerFileDic[_loc4_] = this.fileLoader.readUTFBytes(_loc5_);
            _loc2_++;
         }
      }
   }
}
