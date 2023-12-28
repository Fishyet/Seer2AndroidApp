package com.taomee.utils
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class LoaderUtil
   {
       
      
      public function LoaderUtil()
      {
         super();
      }
      
      public static function addByteLoaderEvents(param1:*, param2:URLStream, param3:Function = null, param4:Function = null, param5:Function = null, param6:Function = null) : void
      {
         var _closeFun:Function;
         var _ioErrorFun:Function;
         var _completeFun:Function;
         var d:URLStream = null;
         var _timeoutFun:Function = null;
         var _getDataBginFun:Function = null;
         var _onbreaktimeout:Function = null;
         var _getByteDataFun:Function = null;
         var listener:* = param1;
         var loader:URLStream = param2;
         var timeoutFun:Function = param3;
         var onbreaktimeout:Function = param4;
         var getDataBginFun:Function = param5;
         var getByteDataFun:Function = param6;
         if(!loader)
         {
            throw "加载器不能为空！";
         }
         d = loader;
         if(Boolean(timeoutFun))
         {
            _timeoutFun = function(param1:*):void
            {
               timeoutFun(param1);
            };
            BC.addEvent(listener,d,"onTimeout",_timeoutFun);
         }
         if(Boolean(getDataBginFun))
         {
            _getDataBginFun = function(param1:*):void
            {
               BC.removeEvent(listener,d,"getDataBegin",_getDataBginFun);
               getDataBginFun(param1);
            };
            BC.addEvent(listener,d,"getDataBegin",_getDataBginFun);
         }
         if(Boolean(onbreaktimeout))
         {
            _onbreaktimeout = function(param1:*):void
            {
               BC.removeEvent(listener,d,"onbreaktimeout",_onbreaktimeout);
               onbreaktimeout(param1);
            };
            BC.addEvent(listener,d,"onbreaktimeout",_onbreaktimeout);
         }
         if(Boolean(getByteDataFun))
         {
            _getByteDataFun = function(param1:*):void
            {
               BC.removeEvent(listener,d,"getDataBegin",_getByteDataFun);
               getByteDataFun(param1);
            };
            BC.addEvent(listener,d,"getByteData",_getByteDataFun);
         }
         _closeFun = function(param1:*):void
         {
            BC.removeEvent(listener,d);
         };
         BC.addEvent(listener,d,Event.CLOSE,_closeFun);
         _ioErrorFun = function(param1:*):void
         {
            BC.removeEvent(listener,d);
         };
         BC.addEvent(listener,d,IOErrorEvent.IO_ERROR,_ioErrorFun);
         _completeFun = function(param1:*):void
         {
            BC.removeEvent(listener,d);
         };
         BC.addEvent(listener,d,Event.COMPLETE,_completeFun);
      }
      
      public static function addLoaderEvents(param1:*, param2:IEventDispatcher, param3:Function = null, param4:Function = null, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Function = null) : void
      {
         var d:* = undefined;
         var _completeFun:Function = null;
         var _ioErrorFun:Function = null;
         var _openFun:Function = null;
         var _progressFun:Function = null;
         var _securityErrorFun:Function = null;
         var _httpStatusFun:Function = null;
         var listener:* = param1;
         var loader:IEventDispatcher = param2;
         var completeFun:Function = param3;
         var ioErrorFun:Function = param4;
         var closeFun:Function = param5;
         var openFun:Function = param6;
         var progressFun:Function = param7;
         var securityErrorFun:Function = param8;
         var httpStatusFun:Function = param9;
         if(!loader)
         {
            throw "加载器不能为空！";
         }
         d = loader;
         if(d is Loader)
         {
            d = d.contentLoaderInfo as IEventDispatcher;
         }
         if(Boolean(completeFun))
         {
            _completeFun = function(param1:*):void
            {
               BC.removeEvent(listener,d);
               completeFun(param1);
            };
            BC.addEvent(listener,d,Event.COMPLETE,_completeFun);
         }
         if(Boolean(ioErrorFun))
         {
            _ioErrorFun = function(param1:*):void
            {
               BC.removeEvent(listener,d);
               ioErrorFun(param1);
            };
            BC.addEvent(listener,d,IOErrorEvent.IO_ERROR,_ioErrorFun);
         }
         if(Boolean(openFun))
         {
            _openFun = function(param1:*):void
            {
               BC.removeEvent(listener,d,Event.COMPLETE,_openFun);
               openFun(param1);
            };
            BC.addEvent(listener,d,Event.OPEN,_openFun);
         }
         if(Boolean(progressFun))
         {
            _progressFun = function(param1:*):void
            {
               progressFun(param1);
            };
            BC.addEvent(listener,d,ProgressEvent.PROGRESS,_progressFun);
         }
         if(Boolean(securityErrorFun))
         {
            _securityErrorFun = function(param1:*):void
            {
               BC.removeEvent(listener,d,Event.COMPLETE,_securityErrorFun);
               securityErrorFun(param1);
            };
            BC.addEvent(listener,d,SecurityErrorEvent.SECURITY_ERROR,_securityErrorFun);
         }
         if(Boolean(httpStatusFun))
         {
            _httpStatusFun = function(param1:*):void
            {
               httpStatusFun(param1);
            };
            BC.addEvent(listener,d,HTTPStatusEvent.HTTP_STATUS,_httpStatusFun);
         }
      }
      
      private static function joinApplicatrionDomainLoaderContext(param1:ApplicationDomain) : LoaderContext
      {
         return new LoaderContext(false,param1);
      }
      
      public static function joinApplicatrionDomain(param1:*, param2:ApplicationDomain, param3:Function = null, param4:Function = null) : void
      {
         var l:Loader;
         var fun:Function;
         var _bytes:Array = null;
         var bytes:* = param1;
         var applicationDomain:ApplicationDomain = param2;
         var onComplete:Function = param3;
         var onError:Function = param4;
         _bytes = bytes is Array ? bytes.slice() : [bytes];
         if(!_bytes.length)
         {
            if(Boolean(onComplete))
            {
               onComplete();
            }
            return;
         }
         l = new Loader();
         fun = function(param1:Event):void
         {
            if(!_bytes.length)
            {
               if(Boolean(onComplete))
               {
                  onComplete();
               }
            }
            else
            {
               joinApplicatrionDomain(_bytes,applicationDomain,onComplete);
            }
         };
         addLoaderEvents(l,l,fun,onError);
         l.loadBytes(_bytes.shift(),joinApplicatrionDomainLoaderContext(applicationDomain));
      }
   }
}
