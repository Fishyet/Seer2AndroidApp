 
package com.taomee.seer2.app.processor.map
{
   import com.taomee.seer2.app.actor.ActorManager;
   import com.taomee.seer2.app.lobby.LobbyScene;
   import com.taomee.seer2.core.map.MapModel;
   import com.taomee.seer2.core.map.MapProcessor;
   import com.taomee.seer2.core.scene.SceneManager;
   
   public class MapProcessor_413 extends MapProcessor
   {
       
      
      private var _hideRemoteActorFlag:Boolean;
      
      private var _scene:LobbyScene;
      
      public function MapProcessor_413(param1:MapModel)
      {
         super(param1);
      }
      
      override public function init() : void
      {
         this.hideToolBar();
         this.hideRemoteActor();
      }
      
      override public function dispose() : void
      {
         this.resetHideRemoteActorFlag();
         this._scene = null;
      }
      
      private function hideRemoteActor() : void
      {
         this._hideRemoteActorFlag = ActorManager.showRemoteActor;
         ActorManager.showRemoteActor = false;
      }
      
      private function hideToolBar() : void
      {
         this._scene = SceneManager.active as LobbyScene;
         this._scene.hideTrailsToolBar();
      }
      
      private function resetHideRemoteActorFlag() : void
      {
         ActorManager.showRemoteActor = this._hideRemoteActorFlag;
      }
   }
}
