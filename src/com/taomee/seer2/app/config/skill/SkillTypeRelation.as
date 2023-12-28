package com.taomee.seer2.app.config.skill
{
   public class SkillTypeRelation
   {
      
      public static const DEFINIES:Array = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[1,0.5,2,0.5,1,0.5,0.5,1,1,0.5,1,2,1,1,1,2,1,0.5],[1,0.5,0.5,2,1,1,1,1,2,1,1,1,2,1,1,0.5,1,0.5],[1,2,0.5,0.5,2,2,1,1,1,2,1,1,1,1,1,0.5,1,0.5],[1,1,1,1,0.5,1,1,1,2,0,1,1,1,2,0.5,2,0.5,0.5],[1,2,1,0.5,1,1,0.5,0.5,1,0.5,2,0.5,0.5,0.5,1,1,1,2],[1,2,1,1,1,2,1,0.5,2,1,1,0.5,0.5,1,1,1,1,0.5],[1,0.5,2,1,0.5,1,2,0.5,0,1,1,1,2,1,1,0.5,0.5,0.5],[1,0.5,1,2,0.5,1,0,2,1,1,0.5,1,0.5,1,0.5,1,0.5,2],[1,1,0.5,0.5,2,1,2,1,1,0.5,1,1,1,1,1,2,1,0.5],[1,1,1,1,2,0.5,1,1,1,1,0.5,0,1,2,1,1,2,0.5],[1,0,1,1,1,1,1,1,1,0.5,2,0.5,2,1,1,1,2,2],[1,1,0.5,1,1,1,1,1,1,1,2,0.5,2,1,2,1,1,2],[1,1,1,1,0.5,2,1,1,1,2,0.5,1,1,0.5,2,1,1,0.5],[1,1,1,1,1,1,1,0.5,1,2,0.5,1,1,1,1,1,2,2],[1,0.5,1,2,0,0.5,0.5,1,1,0.5,1,1,1,1,2,0.5,1,2],[1,1,1,1,1,2,1,2,0.5,1,1,1,1,0.5,1,1,2,0.5],[1,0.5,0.5,0.5,0.5,2,0.5,0.5,2,0.5,0.5,2,2,0.5,2,2,0.5,0.5]];
      
      public static const KEZHI:uint = 2;
      
      public static const WEIRUO:uint = 1;
      
      public static const YIBAN:uint = 0;
       
      
      public function SkillTypeRelation()
      {
         super();
      }
      
      public static function getSkillRelation(param1:com.taomee.seer2.app.config.skill.SkillDefinition, param2:com.taomee.seer2.app.config.skill.SkillDefinition) : uint
      {
         var _loc3_:Number = Number(DEFINIES[param1.type - 1][param2.type - 1]);
         if(_loc3_ == 2)
         {
            return KEZHI;
         }
         if(_loc3_ == 0.5)
         {
            return WEIRUO;
         }
         return YIBAN;
      }
   }
}
