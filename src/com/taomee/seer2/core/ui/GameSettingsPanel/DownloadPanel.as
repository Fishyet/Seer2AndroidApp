package com.taomee.seer2.core.ui.GameSettingsPanel {
import com.taomee.seer2.core.ui.GameSettingsPanel.GameSettingsUI;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

public class DownloadPanel {

    private var mainUI:MovieClip;

    private var clearBtn:SimpleButton;

    private var downloadList:TextField;

    public function DownloadPanel(ui:GameSettingsUI) {
        this.mainUI = ui.getChildByName("downloadPanel") as MovieClip;
        this.clearBtn = this.mainUI.getChildByName("clearBtn") as SimpleButton;
        this.downloadList = this.mainUI.getChildByName("downloadList") as TextField;
        this.clearBtn.addEventListener(MouseEvent.CLICK, this.onClear);
    }

    private function onClear(e:MouseEvent):void {
        this.downloadList.text = "";
    }
}
}
