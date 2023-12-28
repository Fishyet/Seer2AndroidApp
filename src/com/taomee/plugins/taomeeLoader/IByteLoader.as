package com.taomee.plugins.taomeeLoader
{
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public interface IByteLoader
   {
       
      
      function get loadedTimer() : Number;
      
      function get delay() : uint;
      
      function loadBytes(param1:ByteArray) : void;
      
      function load(param1:URLRequest) : void;
      
      function get reTryCount() : uint;
      
      function reTry(param1:String = "") : void;
      
      function get timeoutCount() : uint;
      
      function get bytesLoaded() : uint;
      
      function getURLRequest() : URLRequest;
      
      function close() : void;
      
      function get bytesTotal() : uint;
      
      function addCheckTimeout(param1:uint = 15000) : void;
      
      function getByteArray() : ByteArray;
      
      function get hasBreakTimeout() : Boolean;
      
      function get bytesAvailable() : uint;
   }
}
