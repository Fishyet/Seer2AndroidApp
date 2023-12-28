package
{
   import flash.debugger.enterDebugger;
   import flash.utils.Dictionary;
   
   public class BC
   {
      
      private static var instancesLib:Dictionary = new Dictionary();
      
      private static var listenerLib:Dictionary = new Dictionary();
      
      private static var _checkListenerFun:Function;
       
      
      public function BC()
      {
         super();
      }
      
      public static function getInstancesDictionary() : Dictionary
      {
         return instancesLib;
      }
      
      public static function getListenerDictionary() : Dictionary
      {
         return listenerLib;
      }
      
      public static function get checkListenerFun() : Function
      {
         return _checkListenerFun;
      }
      
      public static function set checkListenerFun(param1:Function) : void
      {
         _checkListenerFun = param1;
      }
      
      public static function addEvent(param1:Object, param2:Object, param3:String, param4:Function, param5:Boolean = false, param6:int = 0, param7:Boolean = false) : void
      {
         var listener:Dictionary = null;
         var instances:Dictionary = null;
         var myobj:Object = null;
         var eventLib:Dictionary = null;
         var a:Object = param1;
         var p:Object = param2;
         var event:String = param3;
         var func:Function = param4;
         var useCapture:Boolean = param5;
         var priority:int = param6;
         var useWeakReference:Boolean = param7;
         try
         {
            listener = listenerLib;
            instances = instancesLib;
            if(Boolean(_checkListenerFun) && _checkListenerFun({
               "listener":listener,
               "instances":instances,
               "info":arguments
            }))
            {
               enterDebugger();
            }
            p.addEventListener(event,func,useCapture,priority,useWeakReference);
            if(!listener[a])
            {
               listener[a] = new Dictionary();
            }
            if(!instances[p])
            {
               instances[p] = new Dictionary();
            }
            if(!instances[p][a])
            {
               instances[p][a] = new Dictionary();
            }
            myobj = listener[a];
            if(!myobj[event])
            {
               myobj[event] = {};
               myobj[event].captureTrue = new Dictionary();
               myobj[event].captureFalse = new Dictionary();
            }
            if(useCapture)
            {
               eventLib = myobj[event].captureTrue;
            }
            else
            {
               eventLib = myobj[event].captureFalse;
            }
            if(!eventLib[p] || !eventLib[p][func])
            {
               if(!instances[p][a][func])
               {
                  instances[p][a][func] = [];
               }
               instances[p][a][func].push({
                  "e":event,
                  "u":useCapture
               });
            }
            if(!eventLib[p])
            {
               eventLib[p] = new Dictionary();
            }
            eventLib[p][func] = func;
         }
         catch(e:*)
         {
            throw "参数不能为空!\n" + "addEvent(" + a + "," + p + "," + event + "," + func + "," + useCapture + "," + priority + "," + useWeakReference + ");";
         }
      }
      
      public static function addOnceEvent(param1:Object, param2:Object, param3:String, param4:Function, param5:Boolean = false, param6:int = 0, param7:Boolean = false) : void
      {
         var onceFun:Function = null;
         var a:Object = param1;
         var p:Object = param2;
         var event:String = param3;
         var func:Function = param4;
         var useCapture:Boolean = param5;
         var priority:int = param6;
         var useWeakReference:Boolean = param7;
         onceFun = function handler(param1:*):void
         {
            removeEvent(a,p,event,onceFun,useCapture);
            func(param1);
         };
         addEvent(a,p,event,onceFun,useCapture,priority,useWeakReference);
      }
      
      public static function removeEvent(param1:Object, param2:Object = null, param3:String = null, param4:Function = null, param5:Boolean = false) : void
      {
         var _loc8_:Dictionary = null;
         var _loc9_:Function = null;
         var _loc10_:Object = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         if(!param1)
         {
            trace("监听者参数不能为空！");
            return;
         }
         var _loc6_:Dictionary = listenerLib;
         var _loc7_:Dictionary = instancesLib;
         var _loc13_:Boolean = true;
         if(param2 && Boolean(param3) && Boolean(param4))
         {
            if(!_loc6_[param1] || !_loc6_[param1][param3])
            {
               return;
            }
            if((_loc8_ = param5 ? _loc6_[param1][param3].captureTrue : _loc6_[param1][param3].captureFalse)[param2])
            {
               param2.removeEventListener(param3,param4,param5);
               delete _loc8_[param2][param4];
               _loc13_ = false;
               var _loc16_:int = 0;
               var _loc17_:* = _loc8_[param2];
               for(_loc10_ in _loc17_)
               {
                  _loc13_ = true;
               }
               if(!_loc13_)
               {
                  delete _loc8_[param2];
               }
               if(_loc11_ = _loc7_[param2][param1][param4])
               {
                  _loc15_ = int(_loc11_.length);
                  _loc14_ = 0;
                  while(_loc14_ < _loc15_)
                  {
                     if((_loc10_ = _loc11_[_loc14_]).e == param3 && _loc10_.u == param5)
                     {
                        _loc11_.splice(_loc14_,1);
                        _loc15_--;
                        break;
                     }
                     _loc14_++;
                  }
                  if(!_loc15_)
                  {
                     delete _loc7_[param2][param1][param4];
                  }
               }
               _loc13_ = false;
               _loc16_ = 0;
               _loc17_ = _loc7_[param2][param1];
               for(_loc10_ in _loc17_)
               {
                  _loc13_ = true;
               }
               if(!_loc13_)
               {
                  delete _loc7_[param2][param1];
               }
            }
         }
         else if(!param2 && !Boolean(param3) && !Boolean(param4))
         {
            _loc12_ = [];
            for(param3 in _loc6_[param1])
            {
               _loc8_ = _loc6_[param1][param3].captureFalse;
               for(param2 in _loc8_)
               {
                  for each(param4 in _loc8_[param2])
                  {
                     param2.removeEventListener(param3,param4,false);
                  }
                  _loc12_.push(param2);
               }
               _loc8_ = _loc6_[param1][param3].captureTrue;
               for(param2 in _loc8_)
               {
                  for each(param4 in _loc8_[param2])
                  {
                     param2.removeEventListener(param3,param4,true);
                  }
                  _loc12_.push(param2);
               }
            }
            _loc15_ = int(_loc12_.length);
            _loc14_ = 0;
            while(_loc14_ < _loc15_)
            {
               if(_loc7_[_loc12_[_loc14_]])
               {
                  delete _loc7_[_loc12_[_loc14_]][param1];
               }
               _loc13_ = false;
               _loc16_ = 0;
               _loc17_ = _loc7_[_loc12_[_loc14_]];
               for(_loc10_ in _loc17_)
               {
                  _loc13_ = true;
               }
               if(!_loc13_)
               {
                  delete _loc7_[_loc12_[_loc14_]];
               }
               _loc14_++;
            }
            delete _loc6_[param1];
         }
         else if(param2 && Boolean(param3) && !Boolean(param4))
         {
            if(!_loc6_[param1] || !_loc6_[param1][param3])
            {
               return;
            }
            if((_loc8_ = _loc6_[param1][param3].captureFalse)[param2])
            {
               for each(param4 in _loc8_[param2])
               {
                  param2.removeEventListener(param3,param4,false);
               }
               delete _loc8_[param2];
            }
            if((_loc8_ = _loc6_[param1][param3].captureTrue)[param2])
            {
               for each(param4 in _loc8_[param2])
               {
                  param2.removeEventListener(param3,param4,true);
               }
               delete _loc8_[param2];
            }
            _loc12_ = [];
            for(_loc10_ in _loc7_[param2][param1])
            {
               _loc9_ = _loc10_ as Function;
               if(_loc11_ = _loc7_[param2][param1][_loc9_])
               {
                  _loc14_ = (_loc15_ = int(_loc11_.length)) - 1;
                  while(_loc14_ >= 0)
                  {
                     if((_loc10_ = _loc11_[_loc14_]).e == param3)
                     {
                        _loc11_.splice(_loc14_,1);
                        _loc15_--;
                     }
                     _loc14_--;
                  }
                  if(!_loc15_)
                  {
                     _loc12_.push(_loc9_);
                  }
               }
            }
            _loc15_ = int(_loc12_.length);
            _loc14_ = 0;
            while(_loc14_ < _loc15_)
            {
               delete _loc7_[param2][param1][_loc12_[_loc14_]];
               _loc14_++;
            }
            _loc13_ = false;
            _loc16_ = 0;
            _loc17_ = _loc7_[param2][param1];
            for(_loc10_ in _loc17_)
            {
               _loc13_ = true;
            }
            if(!_loc13_)
            {
               delete _loc7_[param2][param1];
            }
         }
         else if(param2 && !Boolean(param3) && Boolean(param4))
         {
            if(!_loc7_[param2] || !_loc7_[param2][param1])
            {
               return;
            }
            if(_loc11_ = (_loc8_ = _loc7_[param2][param1])[param4])
            {
               _loc15_ = int(_loc11_.length);
               _loc14_ = 0;
               while(_loc14_ < _loc15_)
               {
                  _loc10_ = _loc11_[_loc14_];
                  param2.removeEventListener(_loc10_.e,param4,_loc10_.u);
                  _loc14_++;
               }
               delete _loc8_[param4];
            }
            _loc13_ = false;
            _loc16_ = 0;
            _loc17_ = _loc7_[param2][param1];
            for(_loc10_ in _loc17_)
            {
               _loc13_ = true;
            }
            if(!_loc13_)
            {
               delete _loc7_[param2][param1];
            }
            for(param3 in _loc6_[param1])
            {
               if((_loc8_ = _loc6_[param1][param3].captureFalse)[param2])
               {
                  param2.removeEventListener(param3,param4,false);
                  delete _loc8_[param2][param4];
               }
               _loc13_ = false;
               var _loc18_:int = 0;
               var _loc19_:* = _loc8_[param2];
               for(_loc10_ in _loc19_)
               {
                  _loc13_ = true;
               }
               if(!_loc13_)
               {
                  delete _loc8_[param2];
               }
               if((_loc8_ = _loc6_[param1][param3].captureTrue)[param2])
               {
                  param2.removeEventListener(param3,param4,true);
                  delete _loc8_[param2][param4];
               }
               _loc13_ = false;
               _loc18_ = 0;
               _loc19_ = _loc8_[param2];
               for(_loc10_ in _loc19_)
               {
                  _loc13_ = true;
               }
               if(!_loc13_)
               {
                  delete _loc8_[param2];
               }
            }
         }
         else if(param2 && !Boolean(param3) && !Boolean(param4))
         {
            if(!_loc7_[param2] || !_loc7_[param2][param1])
            {
               return;
            }
            _loc8_ = _loc7_[param2][param1];
            for(_loc10_ in _loc8_)
            {
               param4 = _loc10_ as Function;
               if(_loc11_ = _loc8_[param4])
               {
                  _loc15_ = int(_loc11_.length);
                  _loc14_ = 0;
                  while(_loc14_ < _loc15_)
                  {
                     _loc10_ = _loc11_[_loc14_];
                     param2.removeEventListener(_loc10_.e,param4,_loc10_.u);
                     _loc14_++;
                  }
               }
            }
            delete _loc7_[param2][param1];
            for(param3 in _loc6_[param1])
            {
               if((_loc8_ = _loc6_[param1][param3].captureFalse)[param2])
               {
                  for each(param4 in _loc8_[param2])
                  {
                     param2.removeEventListener(param3,param4,false);
                  }
                  delete _loc8_[param2];
               }
               if((_loc8_ = _loc6_[param1][param3].captureTrue)[param2])
               {
                  for each(param4 in _loc8_[param2])
                  {
                     param2.removeEventListener(param3,param4,true);
                  }
                  delete _loc8_[param2];
               }
            }
         }
         else
         {
            if(!param2 && Boolean(param3) && Boolean(param4))
            {
               if(!_loc6_[param1] || !_loc6_[param1][param3])
               {
                  return;
               }
               _loc8_ = _loc6_[param1][param3].captureFalse;
               _loc12_ = [];
               for(param2 in _loc8_)
               {
                  if(_loc8_[param2][param4])
                  {
                     _loc12_.push(param2);
                  }
               }
               _loc8_ = _loc6_[param1][param3].captureTrue;
               for(param2 in _loc8_)
               {
                  if(_loc8_[param2][param4])
                  {
                     _loc12_.push(param2);
                  }
               }
               _loc15_ = int(_loc12_.length);
               _loc14_ = 0;
               while(_loc14_ < _loc15_)
               {
                  removeEvent(param1,_loc12_[_loc14_],param3,param4,param5);
                  _loc14_++;
               }
               return;
            }
            if(!param2 && Boolean(param3) && !Boolean(param4))
            {
               if(!_loc6_[param1] || !_loc6_[param1][param3])
               {
                  return;
               }
               _loc8_ = _loc6_[param1][param3].captureFalse;
               _loc12_ = [];
               for(param2 in _loc8_)
               {
                  _loc12_.push(param2);
               }
               _loc8_ = _loc6_[param1][param3].captureTrue;
               for(param2 in _loc8_)
               {
                  _loc12_.push(param2);
               }
               _loc15_ = int(_loc12_.length);
               _loc14_ = 0;
               while(_loc14_ < _loc15_)
               {
                  removeEvent(param1,_loc12_[_loc14_],param3);
                  _loc14_++;
               }
               return;
            }
            if(!param2 && !Boolean(param3) && Boolean(param4))
            {
               _loc12_ = [];
               for(param3 in _loc6_[param1])
               {
                  _loc8_ = _loc6_[param1][param3].captureFalse;
                  for(param2 in _loc8_)
                  {
                     if(_loc8_[param2][param4])
                     {
                        _loc12_.push([param2,param3]);
                     }
                  }
                  _loc8_ = _loc6_[param1][param3].captureTrue;
                  for(param2 in _loc8_)
                  {
                     if(_loc8_[param2][param4])
                     {
                        _loc12_.push([param2,param3]);
                     }
                  }
               }
               _loc15_ = int(_loc12_.length);
               _loc14_ = 0;
               while(_loc14_ < _loc15_)
               {
                  removeEvent(param1,_loc12_[_loc14_][0],_loc12_[_loc14_][1]);
                  _loc14_++;
               }
               return;
            }
         }
         for(param3 in _loc6_[param1])
         {
            _loc13_ = false;
            _loc18_ = 0;
            _loc19_ = _loc6_[param1][param3].captureTrue;
            for(_loc10_ in _loc19_)
            {
               _loc13_ = true;
            }
            _loc18_ = 0;
            _loc19_ = _loc6_[param1][param3].captureFalse;
            for(_loc10_ in _loc19_)
            {
               _loc13_ = true;
            }
            if(!_loc13_)
            {
               delete _loc6_[param1][param3];
            }
         }
         _loc13_ = false;
         _loc16_ = 0;
         _loc17_ = _loc6_[param1];
         for(_loc10_ in _loc17_)
         {
            _loc13_ = true;
         }
         if(!_loc13_)
         {
            delete _loc6_[param1];
         }
         _loc13_ = false;
         _loc16_ = 0;
         _loc17_ = _loc7_[param2];
         for(_loc10_ in _loc17_)
         {
            _loc13_ = true;
         }
         if(!_loc13_)
         {
            delete _loc7_[param2];
         }
      }
   }
}
