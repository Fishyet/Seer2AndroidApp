package com.taomee.seer2.core.ui.GameSettingsPanel {
import com.taomee.seer2.core.manager.GameSettingsManager;
import com.taomee.seer2.core.scene.LayerManager;
import GameSettingsUI;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class ConfigPanel {

    public var mainUI:MovieClip;

    private var configChildPanel:ConfigChildPanel;

    private var configMainBar:MovieClip;

    private var configLittleBar:MovieClip;

    private var dynConfigBar:MovieClip;

    private var dynLittleBar:MovieClip;

    private var customConfigBar:MovieClip;

    private var customLittleBar:MovieClip;

    private var coverVec:Vector.<MovieClip>;

    private var dynConfigTabVec:Vector.<MovieClip>;

    private var curIndex:uint = 0;

    private var startY:Number;

    private var beginY:Number;

    private static const SUB_PANEL_NUM:uint = 2;

    public static const XML_NAME:Array = ["技能描述", "Nono", "活动日历", "工具栏", "精灵", "打击帧"];


    public function ConfigPanel(ui:GameSettingsUI) {
        this.mainUI = ui.getChildByName("configPanel") as MovieClip;
        this.configChildPanel = new ConfigChildPanel();
        this.configMainBar = this.mainUI.getChildByName("configMainBar") as MovieClip;
        this.configLittleBar = this.configMainBar.getChildByName("bar") as MovieClip;

        this.dynConfigBar = this.mainUI.getChildByName("dynConfigBar") as MovieClip;
        this.dynLittleBar = this.dynConfigBar.getChildByName("bar") as MovieClip;

        this.customConfigBar = this.mainUI.getChildByName("customConfigBar") as MovieClip;
        this.customLittleBar = this.customConfigBar.getChildByName("bar") as MovieClip;
        this.customConfigBar.visible = false;

        this.configMainBar.scrollRect = new Rectangle(0, 0, this.configMainBar.width, 450);
        this.dynConfigBar.scrollRect = new Rectangle(0, 0, 455, 455);
        this.customConfigBar.scrollRect = new Rectangle(0, 0, 455, 455);

        this.coverVec = new Vector.<MovieClip>();
        for (var i:int = 0; i < SUB_PANEL_NUM; i++) {
            var c:MovieClip = this.configLittleBar["cover" + i] as MovieClip;
            c.alpha = 0;
            this.coverVec.push(c);
        }
        this.coverVec[0].alpha = 1;

        this.dynConfigTabVec = new Vector.<MovieClip>();
        for (var j:int = 0; j < GameSettingsManager.dynConfigState.length; j++) {
            var e:MovieClip = this.dynLittleBar["tab" + j]["enabledState"];
            e.visible = GameSettingsManager.dynConfigState[j];
            this.dynConfigTabVec.push(e);
        }

        for (var t:int = 0; t < XML_NAME.length; t++) {
            this.customLittleBar.addChild(GameSettingsManager.customConfigTabVec[t]);
        }

        this.configLittleBar.addEventListener(MouseEvent.MOUSE_DOWN, this.littleTouchBegin);
        this.configLittleBar.addEventListener(MouseEvent.MOUSE_UP, this.littleTouchEnd);

        this.dynLittleBar.addEventListener(MouseEvent.MOUSE_DOWN, this.dynTouchBegin);
        this.dynLittleBar.addEventListener(MouseEvent.MOUSE_UP, this.dynTouchEnd);

        this.customLittleBar.addEventListener(MouseEvent.MOUSE_DOWN, this.customTouchBegin);
        this.customLittleBar.addEventListener(MouseEvent.MOUSE_UP, this.customTouchEnd);

    }


    private function littleTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.configLittleBar.y;
    }


    private function littleTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 40) {
            var temp:uint = uint((e.stageY - this.configLittleBar.localToGlobal(new Point(0, 0)).y) * 13.2 / LayerManager.root.height);
            this.coverVec[curIndex].alpha = 0;
            curIndex = temp;
            this.coverVec[curIndex].alpha = 1;

            this.dynConfigBar.visible = (curIndex == 0);
            this.customConfigBar.visible = !(curIndex == 0);
            //切换动态config/自定义config

            this.dynLittleBar.y = 0;
            this.customLittleBar.y = 0;
        }
    }

    private function dynTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.dynLittleBar.y;
        this.dynLittleBar.addEventListener(MouseEvent.MOUSE_MOVE, this.dynTouchMove);
    }

    private function dynTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        if (beginY + dy >= -450 && beginY + dy <= 0) {
            this.dynLittleBar.y = beginY + dy;
        }

    }

    private function dynTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 40) {
            var temp:uint = uint((e.stageY - this.dynLittleBar.localToGlobal(new Point(0, 0)).y) * 8.25 / LayerManager.root.height);
            if (temp < GameSettingsManager.dynConfigState.length) {
                GameSettingsManager.dynConfigState[temp] = !GameSettingsManager.dynConfigState[temp];
                this.dynConfigTabVec[temp].visible = GameSettingsManager.dynConfigState[temp];
            }
        }
        this.dynLittleBar.removeEventListener(MouseEvent.MOUSE_MOVE, this.dynTouchMove);
    }

    private function customTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.customLittleBar.y;
        this.customLittleBar.addEventListener(MouseEvent.MOUSE_MOVE, customTouchMove);
    }

    private function customTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        if (beginY + dy >= -160 && beginY + dy <= 0) {
            this.customLittleBar.y = beginY + dy;
        }
    }

    private function customTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 40) {
            var temp:uint = uint((e.stageY - this.customLittleBar.localToGlobal(new Point(0, 0)).y) * 8.25 / LayerManager.root.height);
            if (e.localX > 360) {
                //进入编辑面板
                this.configChildPanel.startEdit(GameSettingsManager.customConfigTabVec[temp], this);
            } else {
                //切换状态
                GameSettingsManager.customConfigTabVec[temp].state = !GameSettingsManager.customConfigTabVec[temp].state;
            }
        }
        this.customLittleBar.removeEventListener(MouseEvent.MOUSE_MOVE, customTouchMove);
    }
}
}
