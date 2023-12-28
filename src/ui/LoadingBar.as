package ui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class LoadingBar extends Sprite
   {
       
      
      private var _stage:Stage;
      
      private var _container:Sprite;
      
      private var _numberVec:Vector.<MovieClip>;
      
      public function LoadingBar(param1:Stage)
      {
         super();
         this._stage = param1;
      }
      
      public function setup(param1:Class) : void
      {
         this._container = new param1() as Sprite;
         addChild(this._container);
         var _loc2_:MovieClip = this._container["num"];
         this._numberVec = new Vector.<MovieClip>();
         this._numberVec.push(_loc2_["unit"]);
         this._numberVec[0].gotoAndStop(1);
         this._numberVec.push(_loc2_["ten"]);
         this._numberVec[1].gotoAndStop(1);
         this._numberVec.push(_loc2_["hundred"]);
         this._numberVec[2].gotoAndStop(1);
         this._stage.addEventListener(Event.RESIZE,this.onResize);
         this.onResize(null);
      }
      
      private function onResize(param1:Event) : void
      {
         if(this._container)
         {
            this._container.scaleX = this._stage.stageWidth / 1200;
            this._container.scaleY = this._stage.stageHeight / 660;
         }
      }
      
      public function dispose() : void
      {
         this.hide();
         this._container = null;
         this._numberVec = null;
         this._stage.removeEventListener(Event.RESIZE,this.onResize);
      }
      
      public function show(param1:DisplayObjectContainer) : void
      {
         param1.addChild(this._container);
      }
      
      public function hide() : void
      {
         if(this._container.parent)
         {
            this._container.parent.removeChild(this._container);
         }
      }
      
      public function progress(param1:int) : void
      {
         this.updateShip(param1);
         this.updateNum(param1);
      }
      
      public function setTitle(param1:String) : void
      {
      }
      
      private function updateShip(param1:int) : void
      {
      }
      
      private function updateNum(param1:int) : void
      {
         var _loc2_:Array = param1.toString().split("");
         var _loc3_:Vector.<int> = Vector.<int>(_loc2_).reverse();
         var _loc4_:int = int(_loc3_.length);
         var _loc5_:int = 0;
         while(_loc5_ < 3)
         {
            if(_loc5_ <= _loc4_ - 1)
            {
               this._numberVec[_loc5_].visible = true;
               this._numberVec[_loc5_].gotoAndStop(_loc3_[_loc5_] + 1);
            }
            else
            {
               this._numberVec[_loc5_].visible = false;
            }
            _loc5_++;
         }
      }
   }
}
