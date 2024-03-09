package com.taomee.seer2.core.ui.GameSettingsPanel {
import com.taomee.seer2.core.manager.GameSettingsManager;
import com.taomee.seer2.core.scene.LayerManager;
import GameSettingsUI;

import flash.display.SimpleButton;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

public class GameSettingsPanel {

    private static var _instance:GameSettingsPanel;

    private static var _stage:Stage;

    private var _closeBtn:SimpleButton;

    private var gameSettingsUI:GameSettingsUI;

    private var _basePanel:BasePanel;

    private var _downloadPanel:DownloadPanel;

    private var _replacePanel:ReplacePanel;

    private var _configPanel:ConfigPanel;

    public function GameSettingsPanel() {
        this.gameSettingsUI = new GameSettingsUI();
        this.gameSettingsUI.scaleX = LayerManager.root.width / 1200;
        this.gameSettingsUI.scaleY = LayerManager.root.height / 660;
        this._closeBtn = this.gameSettingsUI.closeBtn;
        this.initPanel();
    }

    public static function show():void {
        Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
        if (_instance == null) {
            _instance = new GameSettingsPanel();
        }
        _instance._closeBtn.addEventListener(MouseEvent.CLICK, onClose);
        LayerManager.root.addChild(_instance.gameSettingsUI);
    }

    private static function onClose(param1:MouseEvent):void {
        _instance._closeBtn.removeEventListener(MouseEvent.CLICK, onClose);
        Multitouch.inputMode = MultitouchInputMode.NONE;
        GameSettingsManager.implement();
        GameSettingsManager.saveXML();
        LayerManager.root.removeChild(_instance.gameSettingsUI);
        GameSettingsManager.isShow = false;

        //此处将更改写入文件中?
    }


    private function initPanel():void {
        this._basePanel = new BasePanel(this.gameSettingsUI);
        this._downloadPanel = new DownloadPanel(this.gameSettingsUI);
        this._replacePanel = new ReplacePanel(this.gameSettingsUI);
        this._configPanel = new ConfigPanel(this.gameSettingsUI);

    }

    public static function getFileName(f:File):String {
        if (f == null) {
            return "未设置";
        }
        var str:String = decodeURIComponent(f.nativePath);
        return str.substr(str.lastIndexOf("/") + 1);//电脑debug用\\,手机用/
    }
}
}
