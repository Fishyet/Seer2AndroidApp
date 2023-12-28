package net
{
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLRequest;

public class DLLLoader extends EventDispatcher
   {

      public static var size:uint = 0;
      
      private var _loader:Loader;
      
      public function DLLLoader()
      {
         super();
         this._loader = new Loader();

      }
      
      public function doLoad() : void
      {
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderOver);
            this._loader.load(new URLRequest("library.swf"),Client.lc);

      }

      private function onLoaderOver(param1:Event) : void
      {
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderOver);
         var l:Loader = new Loader();
         var onComplete:Function = function (e:Event):void {
            l.removeEventListener(Event.COMPLETE,onComplete)
            dispatchEvent(new Event(Event.COMPLETE));
         }

         l.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
         l.loadBytes((param1.target as LoaderInfo).bytes,Client.lc)

      }

   }
}


