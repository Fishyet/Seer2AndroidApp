package com.taomee.seer2.core.ui.GameSettingsPanel {
import com.taomee.seer2.core.manager.GameSettingsManager;
import com.taomee.seer2.core.scene.LayerManager;
import GameSettingsUI;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;

public class BasePanel {

    private var mainUI:MovieClip;

    private var panel:MovieClip;

    private var startY:Number;

    private var beginY:Number;

    private var textVec:Vector.<TextField>;

    public static const SWITCH_ARRAY:Array = [["43.136.112.146/seer2/", "106.52.198.27/seer2/", "rn.733702.xyz/seer2/", "rn-cdn.733702.xyz/seer2/", "seer2.61.com/"],
        ["低", "中", "高"], ["关闭", "显示"], ["关闭", "打开"], ["旧", "新"], ["简约", "正常"], ["后面", "前面"], ["关闭", "打开"]];

    public function BasePanel(ui:GameSettingsUI) {
        this.mainUI = ui.getChildByName("basePanel") as MovieClip;
        this.panel = this.mainUI.getChildByName("panel") as MovieClip;
        this.init();
    }

    private function init():void {
        this.mainUI.scrollRect = new Rectangle(0, 0, this.mainUI.width, 500);
        this.textVec = new Vector.<TextField>();
        for (var i:int = 0; i < SWITCH_ARRAY.length; i++) {
            var t:TextField = this.panel["txt" + i] as TextField;
            t.text = SWITCH_ARRAY[i][GameSettingsManager.switchState[i]];
            this.textVec.push(t);
        }
        this.panel.addEventListener(MouseEvent.MOUSE_DOWN, this.onTouchBegin);
        this.panel.addEventListener(MouseEvent.MOUSE_UP, this.onTouchEnd);
        setOptionMc(this.panel["rootURLBar"]["o"] as MovieClip, 5, 0);
        setOptionMc(this.panel["imageBar"]["o"] as MovieClip, 3, 1);
        setOptionMc(this.panel["otherPlayersBtn"]["o"] as MovieClip, 2, 2);
        setOptionMc(this.panel["soundBtn"]["o"] as MovieClip, 2, 3);
        setOptionMc(this.panel["uiArenaBtn"]["o"] as MovieClip, 2, 4);
        setOptionMc(this.panel["fightAnimateBtn"]["o"] as MovieClip, 2, 5);
        setOptionMc(this.panel["fighterAnimationFront"]["o"] as MovieClip, 2, 6);
        setOptionMc(this.panel["register"]["o"] as MovieClip, 2, 7);

    }

    private function setOptionMc(mc:MovieClip, optionNum:uint, index:uint):void {
        var startX:Number;
        var maxX:int = 150 * (optionNum - 1);
        var beginX:Number;
        var onOpTouchMove:Function = function (e:MouseEvent):void {
            var dx:Number = (e.stageX - startX) * 660 / LayerManager.root.height;
            var tempX:Number = beginX + dx;
            if (tempX >= 0 && tempX <= maxX) {
                mc.x = tempX;
            }
        }
        var onOpTouchEnd:Function = function (e:MouseEvent):void {
            var a:uint = uint((mc.x + 75) / 150)
            mc.x = 150 * a;
            textVec[index].text = SWITCH_ARRAY[index][a];
            GameSettingsManager.switchState[index] = a;
            panel.removeEventListener(MouseEvent.MOUSE_MOVE, onOpTouchMove);
            panel.removeEventListener(MouseEvent.MOUSE_UP, onOpTouchEnd);
            panel.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
            panel.addEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
        }
        var onOpTouchBegin:Function = function (e:MouseEvent):void {
            startX = e.stageX;
            beginX = mc.x;

            panel.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
            panel.removeEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
            panel.addEventListener(MouseEvent.MOUSE_MOVE, onOpTouchMove);
            panel.addEventListener(MouseEvent.MOUSE_UP, onOpTouchEnd);
        }
        mc.x = 150 * GameSettingsManager.switchState[index];
        mc.addEventListener(MouseEvent.MOUSE_DOWN, onOpTouchBegin);

    }


    private function onTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.panel.y;
        this.panel.addEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
    }

    private function onTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        if (beginY + dy <= 0 && beginY + dy > -300) {
            this.panel.y = beginY + dy;
        }
    }

    private function onTouchEnd(e:MouseEvent):void {
        this.panel.removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
    }

}
}
