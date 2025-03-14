package events {
import flash.events.Event;

public class DNSResolveEvent extends Event {
    private var _data:String;

    public function DNSResolveEvent(t:String, data:String) {
        super(t);
        this._data = data;
    }

    public function get data():String {
        return _data;
    }

    override public function clone():Event {
        return new DNSResolveEvent(type, _data);
    }
}
}
