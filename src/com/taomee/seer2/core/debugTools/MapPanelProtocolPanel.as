package com.taomee.seer2.core.debugTools {
import com.taomee.seer2.core.ui.UIManager;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.text.TextField;

public class MapPanelProtocolPanel extends Sprite {

    private static var _instance:MapPanelProtocolPanel;

    public static const MAX_LINES:uint = 12;

    public static const ADD_DIRECTLY:uint = 0;

    public static const MAP_ID:uint = 1;

    public static const PANEL_NAME:uint = 2;

    public static const ACTIVE_COUNT:uint = 3;

    public static const DAY_LIMIT:uint = 4;

    public static const SWAP_ID:uint = 5;

    public static const MIBUY_ID:uint = 6;

    public static const FIGHT_ID:uint = 7;


    private var _mainUI:MovieClip;

    private var _debugInfo:TextField;

    private var _clearBtn:SimpleButton;

    private var _saveBtn:SimpleButton;

    private var _checkBoxList:Vector.<SimpleButton>;

    private var _crossSymbleList:Vector.<MovieClip>;

    private var _foreverLimitArr:Array;

    private var _buyID:uint;

    private var _fightID:uint;

    private var _swapID:uint;

    private var _addInfoFlag:Array;

    public function MapPanelProtocolPanel(param1:InterClass) {
        this._addInfoFlag = [false, false, false, false, false, false, false];
        super();
        if (_instance) {
            throw new Error("(地图、面板、协议)重复实例化");
        }
        this._mainUI = UIManager.getMovieClip("MapPanelProtocolUI");
        if (this._mainUI == null) {
            return;
        }
        this.initset();
        this.initEvent();
        addChild(this._mainUI);
    }

    public static function instance():MapPanelProtocolPanel {
        var _loc1_:MapPanelProtocolPanel = null;
        if (_instance == null) {
            _loc1_ = new MapPanelProtocolPanel(new InterClass());
            if (_loc1_.mainUI == null) {
                _instance = null;
                _loc1_ = null;
            } else {
                _instance = _loc1_;
            }
        }
        return _instance;
    }

    private function initset():void {
        this._checkBoxList = new Vector.<SimpleButton>();
        this._crossSymbleList = new Vector.<MovieClip>();
        var _loc1_:int = 0;
        _loc1_ = 0;
        while (_loc1_ < 7) {
            this._checkBoxList.push(this._mainUI["selectBtn" + _loc1_]);
            this._crossSymbleList.push(this._mainUI["crossSymble" + _loc1_]);
            this._crossSymbleList[_loc1_].visible = this._crossSymbleList[_loc1_].mouseChildren = this._crossSymbleList[_loc1_].mouseEnabled = false;
            _loc1_++;
        }
        this._clearBtn = this._mainUI["clearBtn"];
        this._saveBtn = this._mainUI["saveBtn"];
        this._debugInfo = this._mainUI["contentText"];
        this._debugInfo.text = "";
    }

    private function initEvent():void {
        var _loc1_:int = 0;
        _loc1_ = 0;
        while (_loc1_ < this._checkBoxList.length) {
            this._checkBoxList[_loc1_].addEventListener(MouseEvent.CLICK, this.onCheckBtn);
            _loc1_++;
        }
        this._clearBtn.addEventListener(MouseEvent.CLICK, this.onClearBtn);
        this._saveBtn.addEventListener(MouseEvent.CLICK, this.onSaveBtn);
    }

    private function onCheckBtn(param1:MouseEvent):void {
        var _loc2_:int = this._checkBoxList.indexOf(param1.currentTarget as SimpleButton);
        if (-1 != _loc2_) {
            if (this._crossSymbleList[_loc2_].visible) {
                this._crossSymbleList[_loc2_].visible = false;
                this._addInfoFlag[_loc2_] = false;
            } else {
                this._crossSymbleList[_loc2_].visible = true;
                this._addInfoFlag[_loc2_] = true;
            }
        }
    }

    private function onClearBtn(param1:MouseEvent):void {
        this._debugInfo.text = "";
        this._debugInfo.scrollV = 1;
    }

    private function onSaveBtn(param1:MouseEvent):void {

    }

    public function addLog(param1:uint, param2:String):void {
        if (this._debugInfo.scrollV >= 200) {
            this.onClearBtn(null);
        }
        if (Boolean(this._debugInfo) && this.checkAddCondition(param1)) {
            this._debugInfo.appendText(param2);
            if (this._debugInfo.numLines > MAX_LINES) {
                this._debugInfo.scrollV = this._debugInfo.numLines - MAX_LINES + 1;
            } else {
                this._debugInfo.scrollV = 1;
            }
        }
    }

    public function set foreverLimitArr(param1:Array):void {
        this._foreverLimitArr = param1;
    }

    public function get foreverLimitArr():Array {
        return this._foreverLimitArr;
    }

    public function set buyID(param1:uint):void {
        this._buyID = param1;
    }

    public function get buyID():uint {
        return this._buyID;
    }

    public function set fightID(param1:uint):void {
        this._fightID = param1;
    }

    public function get fightID():uint {
        return this._fightID;
    }

    public function set swapID(param1:uint):void {
        this._swapID = param1;
    }

    public function get swapID():uint {
        return this._swapID;
    }

    public function checkAddCondition(param1:uint):Boolean {
        if (param1 == 0 || Boolean(this._addInfoFlag[param1 - 1])) {
            return true;
        }
        return false;
    }

    public function get mainUI():MovieClip {
        return this._mainUI;
    }
}
}

class InterClass {


    public function InterClass() {
        super();
    }
}
