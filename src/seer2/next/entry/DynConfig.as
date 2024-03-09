package seer2.next.entry {

import com.taomee.seer2.app.MainEntry;
import com.taomee.seer2.core.config.ClientConfig;
import com.taomee.seer2.core.ui.LoadingBar;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class DynConfig {
    public static var mainEntry:MainEntry;
    public static var itemConfigXML:XML;
    public static var buffConfigXML:XML;
    public static var movesConfigXML:XML;
    public static var hideMovesConfigXML:XML;
    public static var nonoActivityConfigXML:XML;
    public static var actCalendarConfigXML:XML;
    public static var shopPanelConfigXML:XML;
    public static var rightToolbarConfigXML:XML;
    public static var petConfigXML:XML;
    public static var dictionaryConfigXML:XML;
    public static var hitConfigXML:XML;
    public static var configNameVec:Vector.<String> = new <String>["itemConfigXML", "buffConfigXML", "movesConfigXML", "hideMovesConfigXML", "nonoActivityConfigXML", "actCalendarConfigXML", "shopPanelConfigXML", "rightToolbarConfigXML", "petConfigXML", "dictionaryConfigXML", "hitConfigXML"];

    public static var configPath:Vector.<String> = new <String>["http://rn.733702.xyz/seer2/config/binaryData/2_com.taomee.seer2.app.config.ItemConfig__itemXmlClass.xml",
        "http://rn.733702.xyz/seer2/config/binaryData/7_com.taomee.seer2.app.config.SkillSideEffectConfig__buffXmlClass.xml", "http://rn.733702.xyz/seer2/config/binaryData/15_com.taomee.seer2.app.config.SkillConfig__movesXmlClass.xml",
        "http://rn.733702.xyz/seer2/config/binaryData/23_com.taomee.seer2.app.config.SkillConfig__hideMovesXmlClass.xml", "http://rn.733702.xyz/seer2/config/binaryData/21_com.taomee.seer2.app.config.NonoActivityConfig__xmlClass.xml",
        "http://rn.733702.xyz/seer2/config/binaryData/29_com.taomee.seer2.app.config.ActCalendarConfig__xml.xml", "http://rn.733702.xyz/seer2/config/binaryData/44_com.taomee.seer2.app.config.ShopPanelConfig__class.xml",
        "http://rn.733702.xyz/seer2/config/binaryData/59_com.taomee.seer2.app.rightToolbar.config.RightToolbarConfig__xmlClass.xml", "http://rn.733702.xyz/seer2/config/binaryData/64_com.taomee.seer2.app.config.PetConfig__petXmlClass.xml",
        "http://rn.733702.xyz/seer2/config/binaryData/45_com.taomee.seer2.app.config.PetConfig__dictionaryXmlClass.xml", ""];


    private static function loadConfig():void {
        for (var i:int = 0; i < configNameVec.length; i++) {
            if (configPath[i] != "") {
                loadXML(configPath[i], function (xml:XML, configIndex:int):void {
                    trace("configIndex:" + configIndex);
                    DynConfig[configNameVec[configIndex]] = xml;
                }, i);
            }
        }
        loadXML("http://rn.733702.xyz/seer2/config/dyn-client-config.xml", function (xml:XML, configIndex:int):void {
            DynSwitch.loadConfig(xml);
        })
    }

    private static function loadXML(url:String, success:Function, configIndex:int = -1):void {
        loadingCnt += 1;
        xmlNum += 1;
        var loader:URLLoader = new URLLoader();
        var onLoaderComplete:Function = function (event:Event):void {
            var loader:URLLoader = event.target as URLLoader;
            var xml:XML = new XML(loader.data);
            success(xml, configIndex);
            loadingCnt -= 1;
            tryCallback();
        };
        var onLoaderError:Function = function (event:Event):void {
            trace("DynConfig loadXML error:", url);
            loadingCnt -= 1;
            tryCallback();
        }
        loader.addEventListener(Event.COMPLETE, onLoaderComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
        var request:URLRequest = new URLRequest(url);
        loader.load(request);
    }

    private static function tryCallback():void {
        LoadingBar.progress((xmlNum - loadingCnt) / xmlNum);
        if (loadingCnt == 0 && callback) {
            var cb:Function = callback;
            callback = null;
            cb();
        }
    }

    private static var callback:Function;
    private static var loadingCnt:int;
    private static var xmlNum:int;

    public static function loadConfigCallback(cb:Function):void {
        callback = cb;
        loadConfig();
    }
}
}
