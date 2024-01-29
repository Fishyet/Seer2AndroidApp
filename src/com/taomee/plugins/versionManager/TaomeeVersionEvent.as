package com.taomee.plugins.versionManager {
import flash.events.Event;

public class TaomeeVersionEvent extends Event {

    public static const VERSION_LOADED:String = "versionLoaded";

    public static const VERSION_LOAD_ERROR:String = "versionLoadError";


    public function TaomeeVersionEvent(param1:String, param2:* = null, param3:Boolean = false, param4:Boolean = false) {
        super(param1, param3, param4);
    }

    override public function clone():Event {
        return new TaomeeVersionEvent(type, bubbles, cancelable);
    }
}
}
