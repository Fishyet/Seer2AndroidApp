package {
import com.taomee.seer2.core.scene.LayerManager;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

[Embed(source="/_assets/gameSettingsUI.swf", symbol="GameSettingsUI")]
public dynamic class GameSettingsUI extends Sprite {
    public var mainBtnBar:MovieClip;

    public var basePanel:MovieClip;

    public var downloadPanel:MovieClip;

    public var replacePanel:MovieClip;

    public var configPanel:MovieClip

    public var closeBtn:SimpleButton;

    private static const PANEL_NUM:uint = 4;

    private var mainBarCover:Vector.<MovieClip>;

    private var panelVec:Vector.<MovieClip>;

    private var bar:MovieClip;

    private var curIndex:uint = 0;

    private var startY:Number;

    private var beginY:Number;

    public function GameSettingsUI() {
        this.panelVec = new Vector.<MovieClip>();
        this.panelVec.push(basePanel);
        this.panelVec.push(downloadPanel);
        this.panelVec.push(replacePanel);
        this.panelVec.push(configPanel);
        initMainBtnBar();
        this.downloadPanel.visible = false;
        this.replacePanel.visible = false;
        this.configPanel.visible = false;

    }

    private function initMainBtnBar():void {
        this.mainBtnBar.scrollRect = new Rectangle(0, 0, this.mainBtnBar.width, 450);
        this.mainBarCover = new Vector.<MovieClip>();
        this.bar = this.mainBtnBar["bar"] as MovieClip;
        for (var i:int = 0; i < PANEL_NUM; i++) {
            var c:MovieClip = bar["mainCover" + i] as MovieClip;
            c.alpha = 0;
            this.mainBarCover.push(c);
        }
        this.mainBarCover[0].alpha = 1;
        this.bar.addEventListener(MouseEvent.MOUSE_DOWN, this.onTouchBegin);
        this.bar.addEventListener(MouseEvent.MOUSE_UP, this.onTouchEnd);
    }

    private function onTouchBegin(e:MouseEvent):void {
        startY = e.stageY;
        beginY = this.bar.y;
        this.bar.addEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
    }

    private function onTouchMove(e:MouseEvent):void {
        var dy:Number = (e.stageY - startY) * 660 / LayerManager.root.height;
        if (beginY + dy > -150 && beginY + dy < 150) {
            this.bar.y = beginY + dy;
        }
    }

    private function onTouchEnd(e:MouseEvent):void {
        if (Math.abs(startY - e.stageY) * 660 / LayerManager.root.height < 50) {
            var temp:uint = uint((e.stageY - this.bar.localToGlobal(new Point(0, 0)).y) * 6.6 / LayerManager.root.height);
            if (this.mainBarCover[temp] != undefined && this.panelVec[temp] != undefined) {
                this.mainBarCover[curIndex].alpha = 0;
                this.panelVec[curIndex].visible = false;
                curIndex = temp;
                this.mainBarCover[curIndex].alpha = 1;
                this.panelVec[curIndex].visible = true;
            }
        }
        this.bar.removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
    }
}
}
