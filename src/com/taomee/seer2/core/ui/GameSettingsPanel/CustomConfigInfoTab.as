package com.taomee.seer2.core.ui.GameSettingsPanel {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.text.TextField;

[Embed(source="/_assets/gameSettingsUI.swf", symbol="CustomConfigInfoTab")]
public dynamic class CustomConfigInfoTab extends Sprite {

    public var infoTextField:TextField;

    public var enabledState:MovieClip;

    public var inactiveState:MovieClip;

    public var xmlName:String;

    private var _localFile:File;

    private var _state:Boolean;

    private var _configType:uint;

    public function CustomConfigInfoTab() {
        super();
    }

    public function setInfo(configType:uint, f:File):void {
        this._configType = configType;
        this.xmlName = ConfigPanel.XML_NAME[configType];
        this._localFile = f;
        this.infoTextField.text = this.xmlName + "→" + GameSettingsPanel.getFileName(this._localFile);
    }

    public function set localFile(f:File):void {
        setInfo(this._configType, f);
    }

    public function get localFile():File {
        return this._localFile;
    }

    public function get path():String {
        if (this._localFile == null) {
            return "";
        }
        return decodeURIComponent(this._localFile.nativePath);
    }

    public function set state(param1:Boolean):void {
        this._state = param1;
        this.enabledState.visible = _state;
    }

    public function get state():Boolean {
        return this._state;
    }


}
}
