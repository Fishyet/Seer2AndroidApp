package com.taomee.plugins.pandaVersionManager
{
   import flash.net.URLRequest;
   
   public interface IPandaVersionManager
   {
       
      
      function load(param1:String, param2:Boolean = false, param3:Function = null, param4:Function = null, param5:Function = null) : void;
      
      function getModifiedDate(param1:String) : Date;
      
      function getRevisionVersion(param1:String) : uint;
      
      function getFoderNOByPath(param1:String) : String;
      
      function getModifiedValue(param1:String) : Number;
      
      function loadBody() : void;
      
      function get lastModifiedDate() : Date;
      
      function get lastModifiedValue() : Number;
      
      function getFileSize(param1:String) : uint;
      
      function getFilesSize(param1:Array) : uint;
      
      function getURLRequest(param1:*, param2:Boolean = false) : URLRequest;
      
      function destroy() : void;
   }
}
