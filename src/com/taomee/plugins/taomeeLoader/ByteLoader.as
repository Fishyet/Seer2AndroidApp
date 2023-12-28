package com.taomee.plugins.taomeeLoader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.Timer;
   
   public class ByteLoader extends URLStream implements IDataInput, IByteLoader
   {
      
      private static function _defaultCheckURLRequestFun(param1:IByteLoader, param2:URLRequest):URLRequest
      {
         return param2;
      } 
      
      private var _loadedTimer:Number = 0;
      
      private var _timeoutDelay:uint;
      
      private var _timeoutCount:uint = 0;
      
      private var _bytesLoaded:uint = 0;
      
      private var _reLoadCount:uint = 0;
      
      private var _checkTimeout:Boolean;
      
      protected var overtime:Timer;
      
      private var _startTimer:Number = 0;
      
      private var _currentAvailable:uint = 0;
      
      private var _bytesTotal:uint = 0;
      
      protected var _isLoading:Boolean = false;
      
      protected var _request:URLRequest;
      
      private var _hasBreakTimeout:Boolean;
      
      protected var cba:ByteArray;
      
      private var _urltag:String = "";
      
      public function ByteLoader(param1:Boolean = false, param2:uint = 15000)
      {
         cba = new ByteArray();
         _checkTimeout = param1;
         _timeoutDelay = param2;
         super();
      }
      
      public static function get defaultCheckURLRequestFun() : Function
      {
         return _defaultCheckURLRequestFun;
      }
      
      public static function set defaultCheckURLRequestFun(param1:Function) : void
      {
         _defaultCheckURLRequestFun = param1;
      }
      
      public function get delay() : uint
      {
         return _timeoutDelay;
      }
      
      override public function readShort() : int
      {
         return cba.readShort();
      }
      
      override public function readDouble() : Number
      {
         return cba.readDouble();
      }
      
      public function reTry(param1:String = "") : void
      {
         _urltag = param1;
         close();
         _hasBreakTimeout = false;
         ++_reLoadCount;
         beginLoading();
      }
      
      public function getByteArray() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeBytes(cba);
         _loc1_.position = 0;
         return _loc1_;
      }
      
      protected function pushDataToByteArray(param1:ProgressEvent) : void
      {
         _bytesLoaded = param1.bytesLoaded;
         _bytesTotal = param1.bytesTotal;
         super.readBytes(cba,cba.length);
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.GET_BYTE_DATA));
      }
      
      public function getURLRequest() : URLRequest
      {
         return _request;
      }
      
      public function get bytesTotal() : uint
      {
         return _bytesTotal;
      }
      
      protected function onTimeOut() : void
      {
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_TIME_OUT));
      }
      
      public function get hasBreakTimeout() : Boolean
      {
         return _hasBreakTimeout;
      }
      
      protected function beginLoading() : void
      {
         var temp_request:URLRequest;
         cba.length = 0;
         _currentAvailable = 0;
         addTimer();
         if(_checkTimeout && Boolean(overtime))
         {
            overtime.start();
         }
         BC.addEvent(this,this,ProgressEvent.PROGRESS,getFileBytesTotal);
         BC.addEvent(this,this,ProgressEvent.PROGRESS,pushDataToByteArray);
         BC.addEvent(this,this,IOErrorEvent.IO_ERROR,onIoError,false,4294967295 * 0.5);
         temp_request = new URLRequest();
         temp_request.contentType = _request.contentType;
         temp_request.data = _request.data;
         temp_request.digest = _request.digest;
         temp_request.method = _request.method;
         temp_request.requestHeaders = _request.requestHeaders;
         if(_urltag.length)
         {
            if(_request.url.indexOf("?") == -1)
            {
               temp_request.url = _request.url + "?" + _urltag;
            }
            else
            {
               temp_request.url = _request.url + "&" + _urltag;
            }
         }
         else
         {
            temp_request.url = _request.url;
         }
         _isLoading = true;
         try
         {
            temp_request = _defaultCheckURLRequestFun(this,temp_request);
            if(!temp_request || !(temp_request is URLRequest))
            {
               throw "";
            }
         }
         catch(e:*)
         {
            throw e + "\n默认检查URLRequest函数格式：\n" + "function(loader:IByteLoader,urlRequest:URLRequest):URLRequest\n" + "{\n" + "    //code in here...\n" + "    return urlRequest;\n" + "};";
         }
         super.load(temp_request);
         _startTimer = new Date().time;
         dispatchEvent(new Event(Event.OPEN));
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_START_LOAD));
      }
      
      protected function getFileBytesTotal(param1:ProgressEvent) : void
      {
         BC.removeEvent(this,this,ProgressEvent.PROGRESS,getFileBytesTotal);
         BC.addEvent(this,this,Event.COMPLETE,loadComplete,false,4294967295 * 0.5);
         _bytesLoaded = param1.bytesLoaded;
         _bytesTotal = param1.bytesTotal;
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.GET_DATA_BEGIN));
      }
      
      public function loadBytes(param1:ByteArray) : void
      {
         _bytesLoaded = param1.length;
         _bytesTotal = _bytesLoaded;
         _isLoading = true;
         cba.length = 0;
         dispatchEvent(new Event(Event.OPEN));
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_START_LOAD));
         cba.writeBytes(param1);
         cba.position = 0;
         _isLoading = false;
         _loadedTimer = 0;
         var _loc2_:Event = new Event(Event.COMPLETE);
         loadComplete(_loc2_);
         dispatchEvent(_loc2_);
      }
      
      override public function get bytesAvailable() : uint
      {
         return cba.bytesAvailable;
      }
      
      override public function readUTF() : String
      {
         return cba.readUTF();
      }
      
      public function get isLoading() : Boolean
      {
         return _isLoading;
      }
      
      public function get timeoutCount() : uint
      {
         return _timeoutCount;
      }
      
      private function checkIsTimeout(param1:TimerEvent) : void
      {
         ++_timeoutCount;
         onTimeOut();
         if(_currentAvailable != _bytesLoaded)
         {
            _currentAvailable = _bytesLoaded;
         }
         else
         {
            _hasBreakTimeout = true;
            onBreakTimeOut();
         }
      }
      
      override public function readBoolean() : Boolean
      {
         return cba.readBoolean();
      }
      
      override public function readObject() : *
      {
         return cba.readObject();
      }
      
      private function addTimer() : void
      {
         if(_checkTimeout)
         {
            if(!overtime || overtime && overtime.running)
            {
               overtime = new Timer(_timeoutDelay,0);
               BC.addEvent(this,overtime,TimerEvent.TIMER,checkIsTimeout);
            }
         }
      }
      
      override public function readByte() : int
      {
         return cba.readByte();
      }
      
      protected function loadComplete(param1:Event) : void
      {
         _loadedTimer = new Date().time - _startTimer;
         _isLoading = false;
         BC.removeEvent(this);
         if(overtime)
         {
            overtime.stop();
         }
         overtime = null;
      }
      
      public function get loadedTimer() : Number
      {
         return _loadedTimer;
      }
      
      protected function onBreakTimeOut() : void
      {
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_BREAK_TIME_OUT));
      }
      
      public function clear() : void
      {
         cba.length = 0;
         _currentAvailable = 0;
      }
      
      override public function readUTFBytes(param1:uint) : String
      {
         return cba.readUTFBytes(param1);
      }
      
      public function get bytesLoaded() : uint
      {
         return _bytesLoaded;
      }
      
      override public function readUnsignedByte() : uint
      {
         return cba.readUnsignedByte();
      }
      
      public function delCheckTimeout() : void
      {
         _checkTimeout = false;
      }
      
      override public function readUnsignedShort() : uint
      {
         return cba.readUnsignedShort();
      }
      
      public function get reTryCount() : uint
      {
         return _reLoadCount;
      }
      
      protected function onIoError(param1:IOErrorEvent) : void
      {
         BC.removeEvent(this);
         if(overtime)
         {
            overtime.stop();
         }
         _isLoading = false;
         overtime = null;
         trace("\n\n",param1);
      }
      
      override public function readMultiByte(param1:uint, param2:String) : String
      {
         return cba.readMultiByte(param1,param2);
      }
      
      override public function readUnsignedInt() : uint
      {
         return cba.readUnsignedInt();
      }
      
      override public function load(param1:URLRequest) : void
      {
         if(!(Boolean(_request) && Boolean(param1) && _request === param1))
         {
            _reLoadCount = 0;
         }
         _urltag = "";
         _request = param1;
         _timeoutCount = 0;
         beginLoading();
      }
      
      override public function close() : void
      {
         try
         {
            super.close();
         }
         catch(e:*)
         {
         }
         BC.removeEvent(this);
         cba.length = 0;
         _isLoading = false;
         _currentAvailable = 0;
         _bytesTotal = 0;
         _bytesLoaded = 0;
         if(overtime)
         {
            overtime.stop();
         }
         overtime = null;
      }
      
      override public function readInt() : int
      {
         return cba.readInt();
      }
      
      public function addCheckTimeout(param1:uint = 15000) : void
      {
         _checkTimeout = true;
         _timeoutDelay = param1;
      }
      
      override public function readBytes(param1:ByteArray, param2:uint = 0, param3:uint = 0) : void
      {
         cba.readBytes(param1,param2,param3);
      }
      
      override public function readFloat() : Number
      {
         return cba.readFloat();
      }
   }
}
