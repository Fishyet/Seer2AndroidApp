package com.taomee.plugins.taomeeLoader
{
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class ByteLoaderEvent extends Event
   {
      
      public static const ON_TIME_OUT:String = "onTimeout";
      
      public static const GET_BYTE_DATA:String = "getByteData";
      
      public static const ON_START_LOAD:String = "onStartLoad";
      
      public static const ON_BREAK_TIME_OUT:String = "onbreaktimeout";
      
      public static const GET_DATA_BEGIN:String = "getDataBegin";
       
      
      public function ByteLoaderEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function toString() : String
      {
         return "[" + getQualifiedClassName(this) + " type=\"" + type + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
      }
   }
}
