package com.taomee.seer2.core.ui.GameSettingsPanel {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.text.TextField;

[Embed(source="/_assets/gameSettingsUI.swf", symbol="ReplaceInfoTab")]
public dynamic class ReplaceInfoTab extends Sprite {
    public var inactiveState:MovieClip;

    public var enabledState:MovieClip;

    public var infoTextField:TextField;

    public var originFileName:String;

    private var _localFile:File;

    private var _state:Boolean;

    private var _replaceType:uint;

    public function ReplaceInfoTab(replaceType:uint) {
        super();
        this._replaceType = replaceType;
    }

    public function setInfo(originFileName:String, f:File):void {
        this.originFileName = originFileName;
        this._localFile = f;
        this.infoTextField.text = this.originFileName + "→" + GameSettingsPanel.getFileName(this._localFile);
    }

    public function set state(param1:Boolean):void {
        this._state = param1;
        this.inactiveState.visible = !_state;
    }

    public function get state():Boolean {
        return this._state;
    }

    public function get originPath():String {
        return ReplacePanel.PATH_TYPE[this._replaceType] + originFileName + (this._replaceType == 4 ? ".mp3" : ".swf");
    }

    public function get path():String {
        if (this._localFile == null) {
            return "";
        }
        return decodeURIComponent(_localFile.nativePath);
    }

    public function get localFile():File {
        return this._localFile;
    }
}
}
