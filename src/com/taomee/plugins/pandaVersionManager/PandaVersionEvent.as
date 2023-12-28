package com.taomee.plugins.pandaVersionManager
{
   import flash.events.Event;
   
   public class PandaVersionEvent extends Event
   {
      
      public static const ON_HEADER_AMEND_LOADED:String = "onHeaderAmendLoaded";
      
      public static const ON_HEADER_LOADED:String = "onHeaderLoaded";
      
      public static const ON_LOADED:String = "onLoaded";
      
      public static const ON_LOAD_ERROR:String = "onLoadError";
      
      public static const ON_LOAD_TIMEOUT:String = "onLoadTimeout";
       
      
      public function PandaVersionEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function getTarget() : PandaVersionLoader
      {
         return super.target as PandaVersionLoader;
      }
   }
}
