 
package com.taomee.seer2.app.processor.quest.handler.branch.quest10142
{
   import com.taomee.seer2.app.processor.quest.QuestProcessor;
   
   public class QuestMapHandler_10142_590 extends CandlePelayHandler
   {
       
      
      public function QuestMapHandler_10142_590(param1:QuestProcessor)
      {
         super(param1);
         _questIndex = 1;
         _y = 233;
         _x = 152;
      }
      
      override protected function showGuide() : void
      {
         _processor.showMouseHintAt(220,273);
      }
      
      override public function processMapComplete() : void
      {
         super.processMapComplete();
      }
   }
}
