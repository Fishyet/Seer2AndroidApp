package
{
   import com.taomee.plugins.pandaVersionManager.PandaVersionManager;
   import flash.utils.ByteArray;
   
   public class Copyright
   {
      
      public static function COPYRIGHT_STATED(... rest):String
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:Array = rest[2].split("_");
         while(_loc3_.length)
         {
            _loc2_.writeByte(int(_loc3_.pop()));
         }
         _loc2_.position = 0;
         var _loc4_:String = _loc2_.readUTFBytes(_loc2_.length);
         var _loc5_:Number;
         if(!(_loc5_ = PandaVersionManager.getInstance(rest[1]).getModifiedValue(_loc4_)) || _loc5_ == int(rest[0]) * 1000)
         {
            return "Legitimate";
         }
         if(Boolean(IllegalRequest))
         {
            IllegalRequest(rest[1],_loc4_);
         }
         return "Illegal";
      }
      public static var IllegalRequest:Function;
       
      
      public function Copyright()
      {
         super();
      }
   }
}
