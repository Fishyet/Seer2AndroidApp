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

[Embed(source="/_assets/gameSettingsUI.swf", symbol="ConfigChildPanel")]
public dynamic class ConfigChildPanel extends Sprite {

    public var originText:TextField;

    public var chooseBtn:SimpleButton;

    public var closeBtn:SimpleButton;

    public var saveBtn:SimpleButton;

    public var replaceText:TextField;

    private var configPanel:ConfigPanel;

    private var customConfigInfoTab:CustomConfigInfoTab;

    private var localFile:File;

    public function ConfigChildPanel() {
        super();
    }

    public function startEdit(customConfigInfoTab:CustomConfigInfoTab, configPanel:ConfigPanel):void {
        Multitouch.inputMode = MultitouchInputMode.NONE;
        this.closeBtn.addEventListener(MouseEvent.CLICK, this.onClose);
        this.saveBtn.addEventListener(MouseEvent.CLICK, this.onSave);
        this.chooseBtn.addEventListener(MouseEvent.CLICK, this.onChoose);
        this.customConfigInfoTab = customConfigInfoTab;
        this.configPanel = configPanel;
        this.localFile = this.customConfigInfoTab.localFile;
        this.originText.text = this.customConfigInfoTab.xmlName;
        this.replaceText.text = GameSettingsPanel.getFileName(this.localFile);
        this.configPanel.mainUI.addChild(this);
    }


    private function onClose(e:MouseEvent):void {
        this.closeBtn.removeEventListener(MouseEvent.CLICK, this.onClose);
        this.saveBtn.removeEventListener(MouseEvent.CLICK, this.onSave);
        this.chooseBtn.removeEventListener(MouseEvent.CLICK, this.onChoose);
        Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
        this.configPanel.mainUI.removeChild(this);
        this.configPanel = null;
        this.customConfigInfoTab = null;
        this.localFile = null;

    }

    private function onSave(e:MouseEvent):void {
        if (this.localFile == null || !this.localFile.exists) {
            this.replaceText.text = "未选择文件或文件不存在!"
        }
        this.customConfigInfoTab.localFile = this.localFile;
    }


    private function onChoose(e:MouseEvent):void {
        var file:File = File.documentsDirectory;
        file.requestPermission();
        file.browseForOpen("选择文件", [new FileFilter("xml文件", "*.xml")]);
        file.addEventListener(Event.SELECT, onFileSelected);
    }


    private function onFileSelected(event:Event):void {
        var selectedFile:File = event.target as File;
        selectedFile.removeEventListener(Event.SELECT, onFileSelected);
        if (this.localFile != null && this.localFile.exists) {
            this.localFile.deleteFile();
        }
        this.localFile = File.applicationStorageDirectory.resolvePath("customConfig/" + GameSettingsPanel.getFileName(selectedFile));
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
        this.localFile = selectedFile;
        this.replaceText.text = GameSettingsPanel.getFileName(this.localFile);

    }
}
}
