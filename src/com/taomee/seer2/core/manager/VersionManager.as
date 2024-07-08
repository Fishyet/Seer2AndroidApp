package com.taomee.seer2.core.manager {
public class VersionManager {

    private static var time:Date = new Date(1498790165 * 1000);

    public function VersionManager() {
        super();
    }

    public static function get versionTime():Number {
        return time.time * 0.001;
    }

    public static function get version():String {
        return time.fullYear + "." + (time.getMonth() + 1) + "." + time.getDate() + " " + time.toLocaleTimeString();
    }

    public static function getURL(param1:String):String {
        return param1;
    }
}
}
