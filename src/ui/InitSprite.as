package ui {
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.net.URLRequest;

public class InitSprite extends Sprite {


    private var _stage:Stage;

    private var _container:Sprite;

    private var _root:Client;

    private var _loader:Loader;


    public function InitSprite(param1:Stage,param2:Client){

        this._stage = param1;
        this._root = param2;
        this._loader = new Loader();
        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
        this._loader.load(new URLRequest("../"));

    }

    public function setup(param1:Class) : void
    {
        this._container = new param1() as Sprite;
        addChild(this._container);
        this._stage.addEventListener(Event.RESIZE,this.onResize);
        this.onResize(null);
    }

    private function onResize(param1:Event) : void
    {
        if(this._container)
        {
            this._container.scaleX = this._root.width / 1200;
            this._container.scaleY = this._root.height / 660;
        }
    }

    public function dispose() : void
    {

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

    public function setTitle(param1:String) : void
    {
    }

    private function updateShip(param1:int) : void
    {
    }

    private function updateNum(param1:int) : void
    {

    }

    private function onComplete(event:Event):void {
        this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
    }
}
}
