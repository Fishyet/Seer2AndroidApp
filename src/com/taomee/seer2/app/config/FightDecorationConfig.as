package com.taomee.seer2.app.config
{
   import com.taomee.seer2.app.config.info.AnswerInfo;
   import org.taomee.ds.HashMap;
   
   public class FightDecorationConfig
   {
      
      private static var _xmlClass:Class = com.taomee.seer2.app.config.FightDecorationConfig__xmlClass;
      
      private static var _xml:XML;
      
      public static var _map:HashMap = new HashMap();
      
      {
         setup();
      }
      
      private var xmlData:XML;
      
      public function FightDecorationConfig()
      {
         super();
      }
      
      public static function setup() : void
      {
         _xml = XML(new _xmlClass());
         for each(var imageXML in _xml.descendants("answerQuery"))
         {
            var fakeHash:String = String(imageXML.attribute("fakeHash"));
            var imageId:uint = uint(imageXML.attribute("id"));
            var answer:uint = uint(imageXML.attribute("answer"));
            var pack:AnswerInfo = new AnswerInfo(imageId,answer);
            _map.add(fakeHash,pack);
         }
      }
      
      public static function getInfo(fakeHash:String) : AnswerInfo
      {
         if(_map.containsKey(fakeHash))
         {
            return _map.getValue(fakeHash);
         }
         return null;
      }
      
      public static function addInfo(fakeHash:String, ans:uint) : Boolean
      {
         if(_map.containsKey(fakeHash))
         {
            return false;
         }
         var imageId:uint = uint(_map.length + 1);
         var answer:uint = ans;
         _map.add(fakeHash,new AnswerInfo(imageId,answer));
         _xml.appendChild(<answerQuery fakeHash={fakeHash} id={imageId} answer={answer}/> );
         return true;
      }
   }
}
