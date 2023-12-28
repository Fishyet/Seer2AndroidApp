package com.taomee.plugins.versionManager
{
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   public class TaomeeVersionManager
   {
      
      public static var VERSION:uint = 20140805;
      
      public static var ALL_VERSION:String = "all";
      
      private static var _pvmDic:Dictionary = new Dictionary(true);
       
      
      private var _currentNameSpace:String;
      
      private var _bodyDic:Dictionary;
      
      private var _lastModifiedTime:uint;
      
      private var _fileLoader:com.taomee.plugins.versionManager.TaomeeVersionLoader;
      
      private var _url:String;
      
      private var _loadedHandler:Function;
      
      private var _devRand:uint = 0;
      
      private var _isTrace:Boolean = false;
      
      public function TaomeeVersionManager(param1:String)
      {
         this._bodyDic = new Dictionary(true);
         super();
         this._currentNameSpace = param1;
         _pvmDic[param1] = this;
      }
      
      public static function getInstance(param1:String = "all") : com.taomee.plugins.versionManager.TaomeeVersionManager
      {
         return !!_pvmDic[param1] ? _pvmDic[param1] : new com.taomee.plugins.versionManager.TaomeeVersionManager(param1);
      }
      
      public function set devModeEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            if(!this._devRand)
            {
               this._devRand = int(Math.random() * 9999999);
            }
         }
         else
         {
            this._devRand = 0;
         }
      }
      
      public function set isTrace(param1:Boolean) : void
      {
         this._isTrace = param1;
      }
      
      public function destroy() : void
      {
         _pvmDic[this._currentNameSpace] = null;
         delete _pvmDic[this._currentNameSpace];
         this._bodyDic = null;
      }
      
      public function getVerURLByNameSpace(param1:String, param2:Boolean = false) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc3_:Boolean = false;
         var _loc4_:String = "";
         var _loc5_:String = "";
         var _loc6_:Array;
         if((_loc6_ = param1.split("?")).length > 1)
         {
            _loc4_ = String(_loc6_[1]);
            param1 = String(_loc6_[0]);
            _loc3_ = true;
         }
         var _loc7_:Number;
         if(_loc7_ = this.getModifiedValue(param1))
         {
            _loc5_ = String(_loc7_.toString(36));
            if(_loc4_.indexOf(_loc5_) != -1)
            {
               return !!_loc4_ ? param1 + "?" + _loc4_ : param1;
            }
            if(_loc7_)
            {
               if(param2)
               {
                  if(_loc3_)
                  {
                     param1 = param1 + "?" + _loc4_ + "&" + _loc5_ + "&" + Math.round(Math.random() * 1000);
                  }
                  else
                  {
                     param1 = param1 + "?" + _loc5_ + "&" + Math.round(Math.random() * 1000);
                  }
               }
               else if(_loc3_)
               {
                  param1 = param1 + "?" + _loc4_ + "&" + _loc5_;
               }
               else
               {
                  param1 = param1 + "?" + _loc5_;
               }
            }
            else if(param2)
            {
               if(_loc3_)
               {
                  param1 = param1 + "?" + _loc4_ + "&" + Math.round(Math.random() * 1000);
               }
               else
               {
                  param1 = param1 + "?" + Math.round(Math.random() * 1000);
               }
            }
            else if(_loc3_)
            {
               param1 = param1 + "?" + _loc4_;
            }
            else
            {
               param1 = param1;
            }
         }
         if(this._isTrace)
         {
            trace("[URL]",param1);
         }
         return param1;
      }
      
      public function getModifiedDate(param1:String) : Date
      {
         return new Date(this.getModifiedValue(param1));
      }
      
      public function getModifiedValue(param1:String) : Number
      {
         while(param1.indexOf("\\") > -1)
         {
            param1 = param1.replace("\\","/");
         }
         var _loc2_:Number = Number(this._bodyDic[this.hashFileName(param1)]);
         return isNaN(_loc2_) ? this._devRand : _loc2_ * 1000 + this._devRand;
      }
      
      private function hashFileName(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = param1.charCodeAt(_loc4_) + (_loc2_ << 6) + (_loc2_ << 16) - _loc2_;
            _loc4_++;
         }
         return _loc2_ & 2147483647;
      }
      
      public function getURLRequest(param1:*, param2:Boolean = false) : URLRequest
      {
         var _loc3_:URLRequest = null;
         if(param1 is URLRequest)
         {
            _loc3_ = param1;
            _loc3_.url = this.getVerURLByNameSpace(_loc3_.url,param2);
         }
         else
         {
            param1 = this.getVerURLByNameSpace(param1,param2);
            _loc3_ = new URLRequest(param1);
         }
         return _loc3_;
      }
      
      public function get lastModifiedDate() : Date
      {
         return new Date(this._lastModifiedTime * 1000);
      }
      
      public function load(param1:String, param2:Function) : void
      {
         this._url = param1;
         this._loadedHandler = param2;
         this.startLoad();
      }
      
      private function startLoad() : void
      {
         this._fileLoader = new com.taomee.plugins.versionManager.TaomeeVersionLoader();
         this._fileLoader.addEventListener(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         this._fileLoader.addEventListener(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOAD_ERROR,this.versionLoadErrorHandler);
         var _loc1_:String = this._url;
         var _loc2_:int = _loc1_.indexOf("?");
         if(_loc2_ > -1)
         {
            _loc1_ = _loc1_ + "&" + int(Math.random() * 10000000);
         }
         else
         {
            _loc1_ = _loc1_ + "?" + int(Math.random() * 10000000);
         }
         this._fileLoader.load(_loc1_);
      }
      
      private function endLoad() : void
      {
         this._fileLoader.removeEventListener(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         this._fileLoader.removeEventListener(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOADED,this.versionLoadErrorHandler);
         this._fileLoader = null;
      }
      
      private function versionLoadedHandler(param1:com.taomee.plugins.versionManager.TaomeeVersionEvent) : void
      {
         this._fileLoader.removeEventListener(com.taomee.plugins.versionManager.TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         var _loc2_:int = int(this._fileLoader.bodyData.readUnsignedInt());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this._bodyDic[this._fileLoader.bodyData.readUnsignedInt()] = this._fileLoader.bodyData.readUnsignedInt();
            _loc3_++;
         }
         this._lastModifiedTime = this._fileLoader.lastModifiedTime;
         if(this._loadedHandler != null)
         {
            this._loadedHandler();
         }
         this.endLoad();
      }
      
      private function versionLoadErrorHandler(param1:com.taomee.plugins.versionManager.TaomeeVersionEvent) : void
      {
         this.endLoad();
         setTimeout(this.startLoad,1000);
      }
   }
}
