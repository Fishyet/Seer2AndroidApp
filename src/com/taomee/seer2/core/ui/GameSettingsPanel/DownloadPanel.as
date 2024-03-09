package com.taomee.seer2.core.ui.GameSettingsPanel {
import GameSettingsUI;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.filesystem.File;
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
        var gameCacheDirectory:File = File.cacheDirectory.resolvePath("gameCache");
        var i:int = 0;
        var listFilesInDirectory:Function = function (dir:File):void {
            var files:Array = dir.getDirectoryListing();
            for each (var file:File in files) {
                if (file.isDirectory && i < 29) {
                    listFilesInDirectory(file);
                } else {
                    i++;
                    downloadList.text += gameCacheDirectory.getRelativePath(file) + "\n";
                }
            }
        };
        this.downloadList.text = "为了防止卡顿,只显示30条\n"
        listFilesInDirectory(gameCacheDirectory);

    }

    private function onClear(e:MouseEvent):void {
        var files:Array = File.cacheDirectory.resolvePath("gameCache").getDirectoryListing();
        for each (var file:File in files) {
            file.deleteDirectory(true);
        }
        this.downloadList.text = "";

    }
}
}
