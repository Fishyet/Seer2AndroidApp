package com.taomee.plugins.pandaVersionManager
{
   import flash.display.DisplayObjectContainer;
   import flash.events.ProgressEvent;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class PandaVersionManager implements com.taomee.plugins.pandaVersionManager.IPandaVersionManager
   {
      
      public static var ALL_VERSION:String = "all";
      
      public static var isOnline:Boolean = true;
      
      private static var _IllegalRequest:Function;
      
      private static var pvmDic:Dictionary = new Dictionary(true);
       
      
      public var currentNameSpace:String;
      
      private var _autoLoadBody:Boolean;
      
      private var _bodyObj:Object;
      
      private var _headerFileDic:Dictionary;
      
      private var _lastModifiedTime:uint;
      
      private var _onBodyLoadedFun:Function;
      
      private var _onHeaderLoededFun:Function;
      
      private var fileLoader:com.taomee.plugins.pandaVersionManager.PandaVersionLoader;
      
      private var vertionInfo:Object;
      
      private var errorCount:int = 0;
      
      public function PandaVersionManager(param1:String)
      {
         this._headerFileDic = new Dictionary();
         this.vertionInfo = {};
         super();
         this.currentNameSpace = param1;
         pvmDic[param1] = this;
      }
      
      public static function get IllegalRequest() : Function
      {
         return _IllegalRequest;
      }
      
      public static function set IllegalRequest(param1:Function) : void
      {
         _IllegalRequest = param1;
         Copyright.IllegalRequest = _defaultIllegalRequest;
      }
      
      public static function getInstance(param1:String = "all") : com.taomee.plugins.pandaVersionManager.IPandaVersionManager
      {
         return !!pvmDic[param1] ? pvmDic[param1] : new com.taomee.plugins.pandaVersionManager.PandaVersionManager(param1);
      }
      
      public static function getVerURLByNameSpace(param1:String, param2:Boolean = false, param3:String = "all") : String
      {
         var _loc8_:int = 0;
         if(!param1)
         {
            return "";
         }
         var _loc4_:Boolean = false;
         var _loc5_:String = "";
         var _loc6_:String = "";
         var _loc7_:Array;
         if((_loc7_ = param1.split("?")).length > 1)
         {
            _loc5_ = String(_loc7_[1]);
            param1 = String(_loc7_[0]);
            _loc4_ = true;
         }
         _loc6_ = String(com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(param3).getModifiedValue(param1).toString(36));
         if(_loc5_.indexOf(_loc6_) != -1)
         {
            return !!_loc5_ ? param1 + "?" + _loc5_ : param1;
         }
         if(isOnline)
         {
            if(_loc6_ != "0")
            {
               if(_loc8_ = int(com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(param3).getRevisionVersion(param1)))
               {
                  _loc6_ += "&" + _loc8_;
               }
               if(param2)
               {
                  if(_loc4_)
                  {
                     param1 = param1 + "?" + _loc5_ + "&" + _loc6_ + "&" + Math.round(Math.random() * 1000);
                  }
                  else
                  {
                     param1 = param1 + "?" + _loc6_ + "&" + Math.round(Math.random() * 1000);
                  }
               }
               else if(_loc4_)
               {
                  param1 = param1 + "?" + _loc5_ + "&" + _loc6_;
               }
               else
               {
                  param1 = param1 + "?" + _loc6_;
               }
            }
            else if(param2)
            {
               if(_loc4_)
               {
                  param1 = param1 + "?" + _loc5_ + "&" + Math.round(Math.random() * 1000);
               }
               else
               {
                  param1 = param1 + "?" + Math.round(Math.random() * 1000);
               }
            }
            else if(_loc4_)
            {
               param1 = param1 + "?" + _loc5_;
            }
            else
            {
               param1 = param1;
            }
         }
         else if(param2)
         {
            if(_loc4_)
            {
               param1 = param1 + "?" + _loc5_ + "&" + Math.round(Math.random() * 1000);
            }
            else
            {
               param1 = param1 + "?" + Math.round(Math.random() * 1000);
            }
         }
         else if(_loc4_)
         {
            param1 = param1 + "?" + _loc5_;
         }
         else
         {
            param1 = param1;
         }
         return param1;
      }
      
      private static function _defaultIllegalRequest(param1:String, param2:String) : void
      {
         var no:String;
         var fileName:String;
         var nameSpace:String = param1;
         var url:String = param2;
         var so:SharedObject = getVersionSharedObject(nameSpace);
         var obj:Object = so.data[nameSpace];
         obj = !!obj ? obj : {};
         var _lastModifiedValue:Number = com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(nameSpace).lastModifiedValue;
         if(!obj[_lastModifiedValue])
         {
            obj = {};
            obj[_lastModifiedValue] = {};
         }
         no = com.taomee.plugins.pandaVersionManager.PandaVersionManager.getInstance(nameSpace).getFoderNOByPath(url);
         obj[_lastModifiedValue][no] = !!obj[_lastModifiedValue][no] ? obj[_lastModifiedValue][no] + 1 : 1;
         fileName = String(url.split("?")[0]);
         fileName = url.split("/").pop();
         no = no + ":" + fileName;
         obj[_lastModifiedValue][no] = !!obj[_lastModifiedValue][no] ? obj[_lastModifiedValue][no] + 1 : 1;
         so.data[nameSpace] = obj;
         try
         {
            so.flush();
         }
         catch(e:*)
         {
         }
         if(Boolean(_IllegalRequest))
         {
            _IllegalRequest(nameSpace,url);
         }
      }
      
      private static function getVersionSharedObject(param1:String = "all") : SharedObject
      {
         return SharedObject.getLocal("pandaVersion/" + param1);
      }
      
      public function destroy() : void
      {
         pvmDic[this.currentNameSpace] = null;
         delete pvmDic[this.currentNameSpace];
         this._bodyObj = null;
         this._headerFileDic = null;
      }
      
      public function flushBady(param1:Object) : void
      {
         this._bodyObj = param1;
      }
      
      public function flushHeader(param1:uint, param2:Dictionary) : void
      {
         this._lastModifiedTime = param1;
         this._headerFileDic = param2;
      }
      
      public function getModifiedDate(param1:String) : Date
      {
         return new Date(this.getModifiedValue(param1));
      }
      
      public function getModifiedValue(param1:String) : Number
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         var _loc2_:Number = 0;
         if(Boolean(this._headerFileDic) && Boolean(this._headerFileDic[param1]))
         {
            _loc2_ = Number(this._headerFileDic[param1].slice(0,10));
         }
         if(!_loc2_ && Boolean(this._bodyObj))
         {
            _loc3_ = param1.split("/");
            _loc4_ = _loc3_.slice(0,_loc3_.length - 1).join("/");
            _loc5_ = String(String(_loc3_[_loc3_.length - 1]).split("?")[0]);
            _loc6_ = uint(this._bodyObj.folderObj[_loc4_]);
            _loc2_ = !!(_loc7_ = String(this._bodyObj.fileObj[_loc6_ + ":" + _loc5_])) ? Number(_loc7_.slice(0,10)) : 0;
         }
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         else
         {
            _loc2_ *= 1000;
         }
         return _loc2_;
      }
      
      public function getFileSize(param1:String) : uint
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         param1 = String(param1.split("?")[0]);
         var _loc2_:uint = 0;
         if(this._headerFileDic && this._headerFileDic[param1] && this._headerFileDic[param1].length > 11)
         {
            _loc2_ = uint(this._headerFileDic[param1].slice(11));
         }
         if(!_loc2_ && Boolean(this._bodyObj))
         {
            _loc3_ = param1.split("/");
            _loc4_ = _loc3_.slice(0,_loc3_.length - 1).join("/");
            _loc5_ = String(String(_loc3_[_loc3_.length - 1]).split("?")[0]);
            _loc6_ = uint(this._bodyObj.folderObj[_loc4_]);
            if(_loc7_ = String(this._bodyObj.fileObj[_loc6_ + ":" + _loc5_]))
            {
               _loc2_ = _loc7_.length > 11 ? uint(int(_loc7_.slice(11))) : 0;
            }
         }
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      public function getFilesSize(param1:Array) : uint
      {
         var _loc6_:* = undefined;
         var _loc2_:int = int(param1.length);
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            if((_loc6_ = param1[_loc5_]) is URLRequest)
            {
               _loc4_ = this.getFileSize(_loc6_.url);
               _loc3_ += _loc4_;
            }
            else
            {
               if(!(_loc6_ is String))
               {
                  throw "版本号控制器不识别的类型，无法获取文件大小信息：\n" + _loc6_;
               }
               _loc4_ = this.getFileSize(_loc6_);
               _loc3_ += this.getFileSize(_loc6_);
            }
            if(!_loc4_)
            {
               trace("找不到文件大小.",_loc6_);
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getFoderNOByPath(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         param1 = String(param1.split("?")[0]);
         var _loc2_:String = "";
         if(Boolean(this._headerFileDic) && Boolean(this._headerFileDic[param1]))
         {
            _loc2_ = param1;
         }
         if(!_loc2_ && Boolean(this._bodyObj))
         {
            _loc3_ = param1.split("/");
            _loc4_ = _loc3_.slice(0,_loc3_.length - 1).join("/");
            _loc5_ = String(_loc3_[_loc3_.length - 1]);
            _loc6_ = uint(this._bodyObj.folderObj[_loc4_]);
            _loc2_ = String(_loc6_);
         }
         return _loc2_;
      }
      
      public function getRevisionVersion(param1:String) : uint
      {
         var _loc3_:String = null;
         var _loc2_:String = this.getFoderNOByPath(param1);
         if(this.vertionInfo[_loc2_])
         {
            _loc3_ = String(param1.split("?")[0]);
            _loc3_ = param1.split("/").pop();
            _loc2_ = _loc2_ + ":" + _loc3_;
            return this.vertionInfo[_loc2_];
         }
         return 0;
      }
      
      public function getURLRequest(param1:*, param2:Boolean = false) : URLRequest
      {
         var _loc3_:URLRequest = null;
         if(param1 is URLRequest)
         {
            _loc3_ = param1;
            _loc3_.url = getVerURLByNameSpace(_loc3_.url,param2,this.currentNameSpace);
         }
         else
         {
            param1 = getVerURLByNameSpace(param1,param2,this.currentNameSpace);
            _loc3_ = new URLRequest(param1);
         }
         return _loc3_;
      }
      
      public function get lastModifiedDate() : Date
      {
         return new Date(this._lastModifiedTime * 1000);
      }
      
      public function get lastModifiedValue() : Number
      {
         return this._lastModifiedTime * 1000;
      }
      
      public function load(param1:String, param2:Boolean = false, param3:Function = null, param4:Function = null, param5:Function = null) : void
      {
         this._autoLoadBody = param2;
         this.fileLoader = new com.taomee.plugins.pandaVersionManager.PandaVersionLoader(this.currentNameSpace,param2);
         if(Boolean(this.onHeaderLoed))
         {
            this.fileLoader.addEventListener(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOAD_ERROR,this.onLoadErrorFun);
         }
         if(Boolean(this.onHeaderLoed))
         {
            this.fileLoader.addEventListener(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_HEADER_LOADED,this.onHeaderLoed);
         }
         if(Boolean(param5))
         {
            this.fileLoader.addEventListener(ProgressEvent.PROGRESS,param5);
         }
         var _loc6_:int;
         if((_loc6_ = param1.indexOf("?")) > -1)
         {
            param1 = param1 + "&" + int(Math.random() * 10000000);
         }
         else
         {
            param1 = param1 + "?" + int(Math.random() * 10000000);
         }
         this.fileLoader.load(param1);
         this._onHeaderLoededFun = param3;
         this._onBodyLoadedFun = param4;
      }
      
      public function loadBody() : void
      {
         this.fileLoader.loadBody();
      }
      
      private function checkIsOnline(param1:*) : void
      {
         if(param1 is String)
         {
            isOnline = param1.indexOf("http:") > -1 ? true : false;
         }
         else
         {
            if(!(param1 is DisplayObjectContainer))
            {
               throw "参数必须是字符串或显示对象，" + param1;
            }
            isOnline = param1.indexOf("http:") > -1 ? true : false;
         }
      }
      
      private function onBodyLoaded(param1:com.taomee.plugins.pandaVersionManager.PandaVersionEvent) : void
      {
         this.fileLoader.removeEventListener(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOADED,this.onBodyLoaded);
         if(Boolean(this._onBodyLoadedFun))
         {
            this._onBodyLoadedFun();
         }
         this.fileLoader.close();
         this.fileLoader = null;
      }
      
      private function onLoadErrorFun(param1:com.taomee.plugins.pandaVersionManager.PandaVersionEvent) : void
      {
         ++this.errorCount;
         var _loc2_:SharedObject = getVersionSharedObject(this.currentNameSpace + "_restore");
         var _loc3_:String = !!uint(_loc2_.data.v) ? String(_loc2_.data.v) : "";
         var _loc4_:*;
         var _loc5_:int = (_loc4_ = this.fileLoader.byteLoader.getURLRequest().url).lastIndexOf("/");
         _loc4_ = _loc4_.slice(0,_loc5_ != -1 ? _loc5_ : 0);
         if(Boolean(_loc3_) && this.errorCount < 2)
         {
            _loc4_ = _loc4_ + "/version" + _loc3_ + ".swf";
         }
         else
         {
            _loc4_ = "version.swf";
         }
         this.fileLoader.load(_loc4_);
      }
      
      private function onHeaderLoed(param1:com.taomee.plugins.pandaVersionManager.PandaVersionEvent) : void
      {
         var so:SharedObject;
         var _obj:Object;
         var _timerString:String;
         var e:com.taomee.plugins.pandaVersionManager.PandaVersionEvent = param1;
         var so_restore:SharedObject = getVersionSharedObject(this.currentNameSpace + "_restore");
         so_restore.data.v = uint(this.lastModifiedValue / 1000);
         try
         {
            so_restore.flush();
         }
         catch(e:*)
         {
         }
         so = getVersionSharedObject(this.currentNameSpace);
         _obj = so.data[this.currentNameSpace];
         if(!_obj)
         {
            _obj = {};
         }
         _timerString = String(this.lastModifiedValue);
         this.vertionInfo = _obj[_timerString];
         if(!this.vertionInfo)
         {
            this.vertionInfo = {};
         }
         this.fileLoader.removeEventListener(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_HEADER_LOADED,this.onHeaderLoed);
         if(Boolean(this._onHeaderLoededFun))
         {
            this._onHeaderLoededFun();
         }
         this.fileLoader.addEventListener(com.taomee.plugins.pandaVersionManager.PandaVersionEvent.ON_LOADED,this.onBodyLoaded);
      }
   }
}
