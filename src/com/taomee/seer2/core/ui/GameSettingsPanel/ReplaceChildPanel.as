package com.taomee.seer2.core.ui.GameSettingsPanel {
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.text.TextField;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.ByteArray;

[Embed(source="/_assets/gameSettingsUI.swf", symbol="ReplaceChildPanel")]
public dynamic class ReplaceChildPanel extends Sprite {
    public var originText:TextField;

    public var chooseBtn:SimpleButton;

    public var closeBtn:SimpleButton;

    public var deleteBtn:SimpleButton;

    public var saveBtn:SimpleButton;

    public var replaceText:TextField;

    private var replacePanel:ReplacePanel;

    private var replaceInfoTab:ReplaceInfoTab;

    private var localFile:File;

    public static const DELETE_EVENT:String = "delete";

    public function ReplaceChildPanel() {
        super();

    }

    public function startEdit(replaceInfoTab:ReplaceInfoTab, replacePanel:ReplacePanel):void {
        Multitouch.inputMode = MultitouchInputMode.NONE;
        this.closeBtn.addEventListener(MouseEvent.CLICK, this.onClose);
        this.saveBtn.addEventListener(MouseEvent.CLICK, this.onSave);
        this.deleteBtn.addEventListener(MouseEvent.CLICK, this.onDelete);
        this.chooseBtn.addEventListener(MouseEvent.CLICK, this.onChoose);
        this.replaceInfoTab = replaceInfoTab;
        this.replacePanel = replacePanel;
        this.localFile = this.replaceInfoTab.localFile;
        this.originText.text = this.replaceInfoTab.originFileName || "未设置";
        this.replaceText.text = GameSettingsPanel.getFileName(this.localFile);
        this.replacePanel.mainUI.addChild(this);
    }


    private function onClose(e:MouseEvent):void {
        this.closeBtn.removeEventListener(MouseEvent.CLICK, this.onClose);
        this.saveBtn.removeEventListener(MouseEvent.CLICK, this.onSave);
        this.deleteBtn.removeEventListener(MouseEvent.CLICK, this.onDelete);
        this.chooseBtn.removeEventListener(MouseEvent.CLICK, this.onChoose);
        Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
        this.replacePanel.mainUI.removeChild(this);
        this.replacePanel = null;
        this.replaceInfoTab = null;
        this.localFile = null;

    }

    private function onSave(e:MouseEvent):void {
        if (this.localFile == null || !this.localFile.exists) {
            this.replaceText.text = "未选择文件或文件不存在!";
            return;
        }
        this.replaceInfoTab.setInfo(originText.text, this.localFile);
    }

    private function onDelete(e:MouseEvent):void {
        if (this.localFile != null && this.localFile.exists) {
            this.localFile.deleteFile();
        }
        this.replacePanel.onDelete(this.replaceInfoTab);
        this.onClose(null);
    }

    private function onChoose(e:MouseEvent):void {
        var file:File = File.documentsDirectory;
        file.requestPermission();
        file.browseForOpen("选择文件", [new FileFilter("swf/mp3文件", "*.swf;*.mp3")]); // 打开文件选择对话框
        file.addEventListener(Event.SELECT, onFileSelected); // 监听文件选择事件
    }

    private function onFileSelected(event:Event):void {
        var selectedFile:File = event.target as File;
        selectedFile.removeEventListener(Event.SELECT, onFileSelected);
        if (this.localFile != null && this.localFile.exists) {
            this.localFile.deleteFile();
        }
        this.localFile = File.applicationStorageDirectory.resolvePath("replaceFile/" + GameSettingsPanel.getFileName(selectedFile));
        try {
            var sourceFileStream:FileStream = new FileStream();
            var targetFileStream:FileStream = new FileStream();
            sourceFileStream.open(selectedFile, FileMode.READ);
            targetFileStream.open(localFile, FileMode.WRITE);
            var fileData:ByteArray = new ByteArray();
            sourceFileStream.readBytes(fileData);
            targetFileStream.writeBytes(fileData);
            targetFileStream.close();
            sourceFileStream.close();
        } catch (e:Error) {
            this.localFile = null;
            this.replaceText.text = "出错了!";
            return;
        }
        this.replaceText.text = GameSettingsPanel.getFileName(this.localFile);
        this.onSave(null);

    }
}
}
