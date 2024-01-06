 
package com.taomee.seer2.app.questTiny
{
   import com.taomee.seer2.app.newPlayerGuideVerOne.NewPlayerGuideTimeManager;
   import com.taomee.seer2.app.quest.QuestManager;
   import com.taomee.seer2.core.scene.LayerManager;
   import com.taomee.seer2.core.scene.SceneManager;
   import com.taomee.seer2.core.scene.SceneType;
   import com.taomee.seer2.core.ui.UIManager;
   import com.taomee.seer2.core.utils.DisplayObjectUtil;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class QuestTinyPanel extends Sprite
   {
      
      private static var _instance:QuestTinyPanel;
      
      public static const CATEGORY_CLICK:String = "categoryClick";
      
      public static const QUEST_CLICK:String = "questClick";
      
      private static var _mainUI:MovieClip;
       
      
      private var _navigationView:QuestTinyNavigationView;
      
      private var _switchBtn:MovieClip;
      
      public function QuestTinyPanel()
      {
         super();
         this.setup();
      }
      
      public static function get instance() : QuestTinyPanel
      {
         if(!_instance)
         {
            _instance = new QuestTinyPanel();
         }
         return _instance;
      }
      
      public static function layout() : void
      {
          _mainUI.x = LayerManager.root.width - _mainUI.width * 0.785;
          _mainUI.y = 7 * LayerManager.root.height / 33;
      }
      
      private function setup() : void {
          _mainUI = UIManager.getMovieClip("QuestTinyUI");
          _mainUI.scaleX = LayerManager.root.height / 700;
          _mainUI.scaleY = LayerManager.root.height / 700;
          _mainUI.x = LayerManager.root.width - _mainUI.width * 0.785;
          _mainUI.y = 7 * LayerManager.root.height / 33;
          addChild(_mainUI);
          this._navigationView = new QuestTinyNavigationView(_mainUI["navigation"]);
          _mainUI.addChild(this._navigationView);
          this._switchBtn = _mainUI["switchBtn"];
          this._switchBtn.gotoAndStop(1);
          this._navigationView.close();
      }
      
      public function hide() : void
      {
         this._switchBtn.removeEventListener(MouseEvent.CLICK,this.onSwitch);
         DisplayObjectUtil.removeFromParent(instance);
      }
      
      public function show() : void
      {
         if(Boolean(SceneManager.active) && SceneManager.active.type == SceneType.ARENA)
         {
            return;
         }
         if(NewPlayerGuideTimeManager.timeCheckNewGuide() && !QuestManager.isComplete(99))
         {
            return;
         }
         LayerManager.uiLayer.addChildAt(instance,0);
         this._switchBtn.addEventListener(MouseEvent.CLICK,this.onSwitch);
         this.update();
      }
      
      public function open() : void
      {
         this._switchBtn.gotoAndStop(2);
         this._navigationView.open();
      }
      
      public function close() : void
      {
         this._switchBtn.gotoAndStop(1);
         this._navigationView.close();
      }
      
      private function onSwitch(param1:MouseEvent) : void
      {
         if(this._switchBtn.currentFrame == 2)
         {
            this._switchBtn.gotoAndStop(1);
            this._navigationView.close();
         }
         else
         {
            this._switchBtn.gotoAndStop(2);
            this._navigationView.open();
         }
      }
      
      private function update() : void
      {
         this._navigationView.update();
      }
   }
}
