package com.taomee.seer2.core.manager {

import com.taomee.seer2.app.arena.controller.ArenaUIIsNew;
import com.taomee.seer2.core.config.ClientConfig;
import com.taomee.seer2.core.scene.LayerManager;
import com.taomee.seer2.core.ui.GameSettingsPanel.*;
import com.taomee.seer2.app.actor.ActorManager;

import flash.display.StageQuality;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.media.SoundMixer;
import flash.media.SoundTransform;

import org.taomee.ds.HashMap;

import org.taomee.ds.HashSet;

import seer2.next.entry.DynConfig;

public class GameSettingsManager {

    public static var switchState:Vector.<uint> = new <uint>[0, 1, 1, 1, 1, 1, 0, 0];
    //最终开关的状态就用这个数组表示,BasePanel从这个数组获取上一次设置的开关状态,如果有修改,则直接修改这个数组

    public static var replaceTabArr:Array = [];

    public static var replaceList:XMLList;

    public static var replaceMapVec:Vector.<HashMap> = new <HashMap>[new HashMap(), new HashMap(), new HashMap(), new HashMap(), new HashMap(), new HashMap()];

    public static var dynConfigState:Vector.<Boolean> = new <Boolean>[false, false, false, false, false, false, false, false, false, false];

    public static var customConfigTabVec:Vector.<CustomConfigInfoTab> = new Vector.<CustomConfigInfoTab>();

    public static var customConfigList:XMLList;

    public static var isShow:Boolean = false;

    private static const ROOT_URL_LIST:Array = ["http://43.136.112.146/seer2/", "http://106.52.198.27/seer2/", "http://rn.733702.xyz/seer2/", "http://rn-cdn.733702.xyz/seer2/", "http://seer2.61.com/"];

    private static const stageQualityVec:Vector.<String> = new <String>[StageQuality.LOW, StageQuality.MEDIUM, StageQuality.HIGH];

    private static var _xml:XML;

    public static function parseXML(gameSettingsXML:XML):void {
        _xml = gameSettingsXML;
        switchState[0] = uint(_xml.elements("rootURL"));
        switchState[1] = uint(_xml.elements("imageQuality"));
        switchState[2] = uint(_xml.elements("otherPlayers"));
        switchState[3] = uint(_xml.elements("sound"));
        switchState[4] = uint(_xml.elements("UI_Arena"));
        switchState[5] = uint(_xml.elements("fighterAnimation"));
        switchState[6] = uint(_xml.elements("fighterAnimationFront"));
        switchState[7] = uint(_xml.elements("register"));
        var dynConfigStateList:String = _xml.elements("dynConfig");
        var i:int = 0;
        while (i < dynConfigState.length) {
            dynConfigState[i] = dynConfigStateList.charAt(i) == "1";
            if (!dynConfigState[i]) {
                DynConfig.configPath[i] = "";
            }
            i++;
        }
        replaceList = _xml.elements("resReplaceList").elements("type");
        i = 0;
        while (i < ReplacePanel.REPLACE_SUB_PANEL_NUM) {
            //在这里把上一次的ReplaceInfoTab给弄下来
            var vec:Vector.<ReplaceInfoTab> = new Vector.<ReplaceInfoTab>();
            for each(var replaceInfo:XML in replaceList[i].descendants("info")) {
                var replaceInfoTab:ReplaceInfoTab = new ReplaceInfoTab(i);
                var replaceFile:File = replaceInfo.attribute("path") == "" ? null : new File(replaceInfo.attribute("path"));
                replaceInfoTab.setInfo(replaceInfo.attribute("resName"), replaceFile);
                replaceInfoTab.state = String(replaceInfo.attribute("state")) == "1";
                vec.push(replaceInfoTab);
                if (replaceFile != null && replaceInfoTab.state && replaceFile.exists) {
                    replaceMapVec[i].add(replaceInfoTab.originFileName, replaceFile.url)
                }
                //如果state是true的话,在这里把原url路径(res/fight/+53.swf),以及替换文件的URL(file.url),作为键值对,放入hashmap中
            }
            replaceTabArr.push(vec);
            i++;
        }

        customConfigList = _xml.elements("customConfig").elements("config");
        i = 0;
        while (i < ConfigPanel.XML_NAME.length) {
            var tab:CustomConfigInfoTab = new CustomConfigInfoTab();
            tab.y = 80 * i;
            var customConfigFile:File = customConfigList[i].attribute("path") == "" ? null : new File(customConfigList[i].attribute("path"));
            tab.setInfo(i, customConfigFile);
            tab.state = String(customConfigList[i].attribute("state")) == "1";
            if (customConfigFile != null && tab.state && customConfigFile.exists) {
                DynConfig.configPath[customConfigIndexShift(i)] = customConfigFile.url;
            }
            customConfigTabVec.push(tab);
            i++;
        }
    }

    public static function customConfigIndexShift(index:uint):uint {
        switch (index) {
            case 0:
                return 2;
            case 1:
                return 4;
            case 2:
                return 5;
            case 3:
                return 7;
            case 4:
                return 8;
            case 5:
                return 10;
        }
        return 0;
    }

    public static function implement():void {
        ClientConfig.setRootURL(ROOT_URL_LIST[switchState[0]]);
        LayerManager.realStage.quality = stageQualityVec[switchState[1]];
        ActorManager.showRemoteActor = switchState[2] != 0;
        SoundMixer.soundTransform = new SoundTransform(switchState[3]);
        ArenaUIIsNew.isNewUI = switchState[4] == 1;
        ArenaUIIsNew.fighterAnimation = switchState[5] == 1;
        ArenaUIIsNew.fighterAnimationFront = switchState[6] == 1;
        ArenaUIIsNew.isRegisterOn = switchState[7] == 1;
    }

    public static function saveXML():void {
        _xml.replace("rootURL", <rootURL>{switchState[0]}</rootURL>);
        _xml.replace("imageQuality", <imageQuality>{switchState[1]}</imageQuality>);
        _xml.replace("otherPlayers", <otherPlayers>{switchState[2]}</otherPlayers>);
        _xml.replace("sound", <sound>{switchState[3]}</sound>);
        _xml.replace("UI_Arena", <UI_Arena>{switchState[4]}</UI_Arena>);
        _xml.replace("fighterAnimation", <fighterAnimation>{switchState[5]}</fighterAnimation>);
        _xml.replace("fighterAnimationFront", <fighterAnimationFront>{switchState[6]}</fighterAnimationFront>);
        _xml.replace("register", <register>{switchState[7]}</register>);
        var str:String = "";
        for (var i:int = 0; i < dynConfigState.length; i++) {
            str += dynConfigState[i] ? "1" : "0";
        }
        _xml.replace("dynConfig", <dynConfig>{str}</dynConfig>);

        i = 0;
        while (i < ReplacePanel.REPLACE_SUB_PANEL_NUM) {
            for each (var child:XML in replaceList[i].children()) {
                delete replaceList[i][child.name()];
            }
            for each(var replaceInfoTab:ReplaceInfoTab in replaceTabArr[i]) {
                replaceList[i].appendChild(<info resName={replaceInfoTab.originFileName}
                                                 path={replaceInfoTab.path.replace(/\\/g, "\\\\").replace(/\//g, "\/\/")}
                                                 state={replaceInfoTab.state ? "1" : "0"}/>);
            }
            i++;
        }

        i = 0;
        while (i < ConfigPanel.XML_NAME.length) {
            customConfigList[i].@path = customConfigTabVec[i].path.replace(/\\/g, "\\\\").replace(/\//g, "\/\/");
            customConfigList[i].@state = customConfigTabVec[i].state ? "1" : "0";
            i++;
        }
        var f:File = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
        if (f.exists) {
            f.deleteFile();
        }
        var stream:FileStream = new FileStream();
        stream.open(f, FileMode.WRITE);
        stream.writeUTFBytes(_xml.toXMLString());
        stream.close();
    }

    public function GameSettingsManager() {
    }

    public static function showGameSettingsPanel():void {
        if (!isShow) {
            GameSettingsPanel.show();
            isShow = true;
        }
    }

}
}
