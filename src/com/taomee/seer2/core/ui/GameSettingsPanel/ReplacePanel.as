package com.taomee.seer2.core.ui.GameSettingsPanel {
import com.taomee.seer2.core.manager.GameSettingsManager;
import com.taomee.seer2.core.scene.LayerManager;
import com.taomee.seer2.core.ui.GameSettingsPanel.GameSettingsUI;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class ReplacePanel {

    public var mainUI:MovieClip;

    private var replaceChildPanel:ReplaceChildPanel;

    private var addBtn:SimpleButton;

    private var replaceInfoBar:MovieClip;

    private var infoBar:MovieClip;

    private var replaceTypeBar:MovieClip;

    private var typeBar:MovieClip;

    private var coverVec:Vector.<MovieClip>;

    private var curIndex:uint = 0;

    private var startY:Number;

    private var beginY:Number;

    public static const REPLACE_SUB_PANEL_NUM:uint = 6;

    public static const PATH_TYPE:Array = ["res/pet/fight/", "res/pet/demo/", "res/pet/icon/", "res/map/swf/", "res/map/sound/", "res/skill/sideEffect/"]

    public function ReplacePanel(ui:GameSettingsUI) {
        this.mainUI = ui.getChildByName("replacePanel") as MovieClip;
        this.replaceChildPanel = new ReplaceChildPanel();
        this.addBtn = this.mainUI.getChildByName("addBtn") as SimpleButton;
        this.replaceTypeBar = this.mainUI.getChildByName("replaceTypeBar") as MovieClip;
        this.replaceTypeBar.scrollRect = new Rectangle(0, 0, this.replaceTypeBar.width, 450);
        this.typeBar = this.replaceTypeBar.getChildByName("bar") as MovieClip;

        this.coverVec = new Vector.<MovieClip>();

        for (var i:int = 0; i < REPLACE_SUB_PANEL_NUM; i++) {
            var c:MovieClip = this.typeBar["cover" + i] as MovieClip;
            c.alpha = 0;
            this.coverVec.push(c);
        }
        this.coverVec[0].alpha = 1;

        this.typeBar.addEventListener(MouseEvent.MOUSE_DOWN, this.onTypeTouchBegin);
        this.typeBar.addEventListener(MouseEvent.MOUSE_UP, this.onTypeTouchEnd);

        this.replaceInfoBar = this.mainUI.getChildByName("replaceInfoBar") as MovieClip;
        this.replaceInfoBar.scrollRect = new Rectangle(0, 0, 530, 370);
        this.infoBar = this.replaceInfoBar.getChildByName("bar") as MovieClip;
        this.infoBar.addEventListener(MouseEvent.MOUSE_DOWN, this.onInfoTouchBegin);
        this.infoBar.addEventListener(MouseEvent.MOUSE_UP, this.onInfoTouchEnd);

        this.addBtn.addEventListener(MouseEvent.CLICK, this.onAdd);

        for each(var mc:ReplaceInfoTab in GameSettingsManager.replaceTabArr[0]) {
            this.infoBar.addChild(mc);
        }
        this.updatePosition();
    }

    private function onTypeTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.typeBar.y;
        this.typeBar.addEventListener(MouseEvent.MOUSE_MOVE, onTypeTouchMove);
    }

    private function onTypeTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        if (beginY + dy > -150 && beginY + dy < 200) {
            this.typeBar.y = beginY + dy;
        }
    }

    private function onTypeTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 40) {
            var temp:uint = uint((e.stageY - this.typeBar.localToGlobal(new Point(0, 0)).y) * 13.2 / LayerManager.root.height);
            this.coverVec[curIndex].alpha = 0;
            for each(var mc:ReplaceInfoTab in GameSettingsManager.replaceTabArr[curIndex]) {
                this.infoBar.removeChild(mc);
            }
            //移除项项的逻辑
            curIndex = temp;
            this.coverVec[curIndex].alpha = 1;
            for each(var mc2:ReplaceInfoTab in GameSettingsManager.replaceTabArr[curIndex]) {
                this.infoBar.addChild(mc2);
            }
            //加入项项的逻辑
            this.infoBar.y = 0;
            this.updatePosition();
        }
        this.typeBar.removeEventListener(MouseEvent.MOUSE_MOVE, onTypeTouchMove);
    }

    private function onInfoTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.infoBar.y;
        this.infoBar.addEventListener(MouseEvent.MOUSE_MOVE, onInfoTouchMove);
    }

    private function onInfoTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        this.infoBar.y = beginY + dy;
    }

    private function onInfoTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 40) {
            var temp:uint = uint((e.stageY - this.infoBar.localToGlobal(new Point(0, 0)).y) * 8.25 / LayerManager.root.height);
            if (e.localX > 433) {
                //进入编辑面板
                this.replaceChildPanel.startEdit(GameSettingsManager.replaceTabArr[curIndex][temp], this);
            } else {
                //切换状态
                GameSettingsManager.replaceTabArr[curIndex][temp].state = !GameSettingsManager.replaceTabArr[curIndex][temp].state;
            }
        }
        this.infoBar.removeEventListener(MouseEvent.MOUSE_MOVE, onInfoTouchMove);
    }

    private function onAdd(e:MouseEvent):void {
        var replaceInfoTab:ReplaceInfoTab = new ReplaceInfoTab(this.curIndex);
        replaceInfoTab.setInfo(String(0), null);
        replaceInfoTab.state = false;
        replaceInfoTab.y = GameSettingsManager.replaceTabArr[curIndex].length * 80;
        GameSettingsManager.replaceTabArr[curIndex].push(replaceInfoTab);
        this.infoBar.addChild(replaceInfoTab);
    }

    public function onDelete(tab:ReplaceInfoTab):void {
        var index:int = GameSettingsManager.replaceTabArr[curIndex].indexOf(tab);
        if (index != -1) {
            GameSettingsManager.replaceTabArr[curIndex].removeAt(index);
            this.infoBar.removeChild(tab);
            updatePosition();
        }
    }

    private function updatePosition():void {
        var i:int = 0;
        for each (var replaceInfoTab:ReplaceInfoTab in GameSettingsManager.replaceTabArr[curIndex]) {
            replaceInfoTab.y = i * 80;
            i++;
        }
    }
}
}
