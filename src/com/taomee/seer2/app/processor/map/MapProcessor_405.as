 
package com.taomee.seer2.app.processor.map
{
   import com.taomee.seer2.app.actor.ActorManager;
   import com.taomee.seer2.app.gameRule.door.support.Base21LevelDoorSupport;
   import com.taomee.seer2.app.gameRule.door.warrior.Warrior50V50DoorSuport;
   import com.taomee.seer2.app.lobby.LobbyScene;
   import com.taomee.seer2.core.map.MapModel;
   import com.taomee.seer2.core.map.MapProcessor;
   import com.taomee.seer2.core.scene.SceneManager;
   
   public class MapProcessor_405 extends MapProcessor
   {
       
      
      private var _hideRemoteActorFlag:Boolean;
      
      private var _scene:LobbyScene;
      
      private var _doorSupport:Base21LevelDoorSupport;
      
      public function MapProcessor_405(param1:MapModel)
      {
         super(param1);
      }
      
      override public function dispose() : void
      {
         this.resetHideRemoteActorFlag();
         if(this._doorSupport)
         {
            this._doorSupport.dispose();
         }
         this._scene = null;
      }
      
      override public function init() : void
      {
         this.hideToolBar();
         this.hideRemoteActor();
         this._doorSupport = Warrior50V50DoorSuport.getInstance();
         this._doorSupport.init(_map);
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
