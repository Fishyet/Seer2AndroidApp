package com.taomee.seer2.app.netForRelogin {
import flash.events.Event;

public class MessageEvent extends Event {


    public var message:Message;

    public function MessageEvent(param1:String, param2:Message) {
        this.message = param2;
        super(param1, false, false);
    }
}
}
