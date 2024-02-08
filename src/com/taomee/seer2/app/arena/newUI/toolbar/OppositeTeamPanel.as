package com.taomee.seer2.app.arena.newUI.toolbar {
import com.taomee.seer2.app.arena.ArenaScene;
import com.taomee.seer2.app.arena.Fighter;
import com.taomee.seer2.app.arena.cmd.ArenaResourceLoadCMD;
import com.taomee.seer2.app.arena.data.FighterInfo;
import com.taomee.seer2.app.arena.data.FighterTeam;
import com.taomee.seer2.app.arena.ui.toolbar.sub.FighterTip;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

public class OppositeTeamPanel {


    private var opPetDisplay:Sprite;

    private var DisplayController:Sprite;

    private var PetDisplays:Vector.<TextField>;

    private var PetDisplaySps:Vector.<Sprite>;

    private var myFont:TextFormat;

    private var oppositeTeam:FighterTeam = null;

    private var _tips:Vector.<FighterTip>;

    private var _contentValue:Sprite;

    private var _scene:ArenaScene;

    public function OppositeTeamPanel(param1:ArenaScene, param2:Sprite) {
        super();
        this._scene = param1;
        this._contentValue = param2;
        this.createPetDisplay();
        this.createDisplayController();
        PetDisplaySps = new Vector.<Sprite>();
    }

    private function createPetDisplay():void {
        myFont = new TextFormat();
        myFont.size = 18;
        myFont.bold = true;
        myFont.color = 16777215;
        opPetDisplay = new Sprite();
        this.opPetDisplay.x = 320;
        this.opPetDisplay.y = 490;
        this.opPetDisplay.alpha = 0.9;
        this._contentValue.addChild(this.opPetDisplay);
        this.opPetDisplay.visible = false;
        PetDisplays = new Vector.<TextField>();
    }

    private function createDisplayController():void {
        var openOrClose:TextField = new TextField();
        DisplayController = new Sprite();
        DisplayController.buttonMode = true;
        DisplayController.graphics.beginFill(0);
        DisplayController.graphics.drawRect(0, 0, 140, 50);
        DisplayController.graphics.endFill();
        DisplayController.x = 50;
        DisplayController.y = 470;
        DisplayController.alpha = 0.8;
        this._contentValue.addChild(this.DisplayController);
        openOrClose.x = 0;
        openOrClose.y = 0;
        openOrClose.width = 140;
        openOrClose.height = 50;
        openOrClose.text = "打开/关闭记牌器";
        if (ArenaResourceLoadCMD.theSide == 1) {
            openOrClose.text += "\n我方是邀请方";
        } else if (ArenaResourceLoadCMD.theSide == 2) {
            openOrClose.text += "\n我方是应战方";
        }
        openOrClose.mouseEnabled = false;
        openOrClose.setTextFormat(myFont);
        this.DisplayController.addChild(openOrClose);
        DisplayController.addEventListener(MouseEvent.CLICK, this.controlPanel);
    }

    private function controlPanel(param1:MouseEvent):void {
        opPetDisplay.visible = !opPetDisplay.visible;
    }

    public function initializePetDisplay(rightTeam:FighterTeam):void {
        var aPetDisplay:TextField;
        var aPetDisplaySp:Sprite;
        var i:int;
        var aFighterInfo:FighterInfo;
        var _tip:FighterTip;
        var titleDisplay:TextField = new TextField();
        var onMouseOver:Function = null;
        var onMouseOut:Function = null;
        var addTip:Function = null;
        this.oppositeTeam = rightTeam;
        this._tips = new Vector.<FighterTip>();
        addTip = function (param1:Sprite, param2:FighterInfo):void {
            _tip = new FighterTip();
            _tip.x = 30;
            _tip.y = param1.y;
            _tip.scaleX = 0.8;
            _tip.scaleY = 0.8;
            _tip.setFighterInfo(param2);
            _tips.push(_tip);
            param1.addChild(_tip);
            _tip.visible = false;
        };
        onMouseOver = function (param1:MouseEvent):void {
            var _loc2_:Sprite = null;
            _loc2_ = param1.currentTarget as Sprite;
            _tips[PetDisplaySps.indexOf(_loc2_)].visible = true;
            _loc2_.scaleX = 1.2;
            _loc2_.scaleY = 1.2;
        };
        onMouseOut = function (param1:MouseEvent):void {
            var _loc2_:Sprite = param1.currentTarget as Sprite;
            _tips[PetDisplaySps.indexOf(_loc2_)].visible = false;
            _loc2_.scaleX = 1;
            _loc2_.scaleY = 1;
        };
        titleDisplay.x = -90;
        titleDisplay.y = 0;
        titleDisplay.width = 90;
        titleDisplay.height = 50;
        titleDisplay.alpha = 0.9;
        titleDisplay.background = true;
        titleDisplay.backgroundColor = 0;
        titleDisplay.text = "||对方精灵||\n||血量比例||";
        titleDisplay.mouseEnabled = false;
        titleDisplay.setTextFormat(myFont);
        this.opPetDisplay.addChild(titleDisplay);
        i = 0;
        while (i < rightTeam.fighterVec.length) {
            aFighterInfo = oppositeTeam.fighterVec[i].fighterInfo;
            aPetDisplaySp = new Sprite();
            aPetDisplaySp.buttonMode = true;
            aPetDisplaySp.graphics.beginFill(0);
            aPetDisplaySp.graphics.drawRect(0, 0, 120, 50);
            aPetDisplaySp.graphics.endFill();
            aPetDisplaySp.x = 120 * i;
            aPetDisplaySp.y = 0;
            aPetDisplaySp.alpha = 0.8;
            aPetDisplay = new TextField();
            aPetDisplay.x = 0;
            aPetDisplay.y = 0;
            aPetDisplay.width = 120;
            aPetDisplay.height = 50;
            aPetDisplay.alpha = 0.8;
            aPetDisplay.mouseEnabled = false;
            if (aFighterInfo.resourceId > 600) {
                addTip(aPetDisplaySp, aFighterInfo);
                aPetDisplaySp.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
                aPetDisplaySp.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            }
            aPetDisplay.setTextFormat(myFont);
            this.PetDisplays.push(aPetDisplay);
            this.PetDisplaySps.push(aPetDisplaySp);
            aPetDisplaySp.addChild(aPetDisplay);
            this.opPetDisplay.addChild(aPetDisplaySp);
            i++;
        }
    }

    public function updatePetDisplay(rightTeam:FighterTeam):void {
        var _loc2_:int = 0;
        this.oppositeTeam = rightTeam;
        for each (var f:Fighter in rightTeam.fighterVec) {
            this.PetDisplays[_loc2_].text = "";
            this.PetDisplays[_loc2_].text += "Lv" + f.fighterInfo.level + f.fighterInfo.realName + "\n";
            this.PetDisplays[_loc2_].text += f.fighterInfo.hp + "/" + f.fighterInfo.maxHp;
            this.PetDisplays[_loc2_].setTextFormat(myFont);
            _loc2_++;
        }
    }
}
}
