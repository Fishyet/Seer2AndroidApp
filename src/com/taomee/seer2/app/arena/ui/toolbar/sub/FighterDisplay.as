package com.taomee.seer2.app.arena.ui.toolbar.sub {
import com.taomee.seer2.app.arena.Fighter;
import com.taomee.seer2.app.arena.data.FighterInfo;
import com.taomee.seer2.app.arena.resource.FightUIManager;
import com.taomee.seer2.app.component.IconDisplayer;
import com.taomee.seer2.app.component.PetTypeIcon;
import com.taomee.seer2.app.config.PetPressConfig;
import com.taomee.seer2.core.utils.DisplayObjectUtil;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

public class FighterDisplay extends Sprite {


    private var _backBtn:MovieClip;

    private var _fighter:Fighter;

    private var _iconDisplayer:IconDisplayer;

    private var _typeIcon:PetTypeIcon;

    private var _enabled:Boolean;

    private var _healthBar:Sprite;

    private var _infoDisplay:MovieClip;

    private var keZhiDisplay:TextField;

    private var _lvTxt:TextField;

    private var _hpTxt:TextField;

    private var _nameTxt:TextField;

    private var _mark:MovieClip;

    private var _shape:Shape;

    private var myFont:TextFormat;

    public function FighterDisplay() {
        super();
        this.keZhiDisplay = new TextField();
        myFont = new TextFormat();
        myFont.size = 15;
        myFont.bold = true;
        this.keZhiDisplay.alpha = 0.9;
        this.keZhiDisplay.backgroundColor = 263172;
        this.keZhiDisplay.width = 68;
        this.keZhiDisplay.height = 20;
        this.keZhiDisplay.x = -10;
        this.keZhiDisplay.y = -60;
        this.mouseChildren = false;
        this.buttonMode = true;
        this._backBtn = FightUIManager.getMovieClip("UI_FightPetBtn");
        this._backBtn.gotoAndStop(1);
        addChild(this._backBtn);
        this._shape = new Shape();
        this._shape.x = 45;
        this._shape.y = 43;
        addChild(this._shape);
        this._iconDisplayer = new IconDisplayer();
        this._iconDisplayer.x = 20;
        this._iconDisplayer.y = 10;
        DisplayObjectUtil.disableSprite(this._iconDisplayer);
        addChild(this._iconDisplayer);
        this._healthBar = FightUIManager.getSprite("UI_FightPetHealthBar");
        this._healthBar.x = 12;
        this._healthBar.y = 63;
        addChild(this._healthBar);
        this._infoDisplay = FightUIManager.getMovieClip("UI_FightPetInfo");
        DisplayObjectUtil.disableSprite(this._infoDisplay);
        this._infoDisplay.x = -15;
        this._infoDisplay.y = 10;
        this._lvTxt = this._infoDisplay["lvTxt"];
        this._hpTxt = this._infoDisplay["hpTxt"];
        this._nameTxt = this._infoDisplay["nameTxt"];
        addChild(this._infoDisplay);
        this._typeIcon = new PetTypeIcon();
        this._typeIcon.x = 75;
        DisplayObjectUtil.disableSprite(this._typeIcon);
        addChild(this._typeIcon);
        this._mark = FightUIManager.getMovieClip("UI_FightFighterMark");
        this._mark.visible = false;
        addChild(this._mark);
    }

    public function getFighter():Fighter {
        return this._fighter;
    }

    public function setFighter(param1:Fighter):void {
        this.clear();
        this.enabled = true;
        this._fighter = param1;
        this.showFighter();
    }

    public function updatePressStatus(param1:uint):void {
        var _loc2_:uint = uint(PetPressConfig.getFrame(this._fighter.fighterInfo.typeId, param1));
        this._backBtn.gotoAndStop(_loc2_);
        var _loc3_:uint = uint(PetPressConfig.getFrame(param1, this._fighter.fighterInfo.typeId));
        switch (_loc3_) {
            case 1:
                this.keZhiDisplay.background = false;
                keZhiDisplay.text = "";
                break;
            case 2:
                this.keZhiDisplay.background = true;
                keZhiDisplay.text = "被克制❌";
                myFont.color = 16462392;
                break;
            case 3:
                this.keZhiDisplay.background = true;
                keZhiDisplay.text = "可防御🔰";
                myFont.color = 7929644;
                break;
            case 4:
                this.keZhiDisplay.background = true;
                keZhiDisplay.text = "可免疫🌟";
                myFont.color = 7400439;
        }
        this.keZhiDisplay.setTextFormat(myFont);
        addChild(this.keZhiDisplay);
    }

    public function clear():void {
        this.enabled = false;
        this._iconDisplayer.dispose();
        this._fighter = null;
    }

    private function showFighter():void {
        this.updateInteraction();
        this.updateInfoDisplay();
        this.updateHealthBar();
        this._typeIcon.type = this._fighter.fighterInfo.typeId;
        this._iconDisplayer.setIconUrl(this._fighter.iconUrl);
        this.updateFightingMark();
    }

    public function update():void {
        if (this._fighter != null) {
            this.updateInteraction();
            this.updateInfoDisplay();
            this.updateHealthBar();
            this.updateFightingMark();
        }
    }

    private function updateInteraction():void {
        if (this._fighter.fighterInfo.hp <= 0) {
            this.mouseEnabled = false;
            DisplayObjectUtil.darkenDisplayObject(this);
        } else {
            this.mouseEnabled = true;
            DisplayObjectUtil.recoverDisplayObject(this);
        }
        if (this._fighter.fighterInfo.position != 0) {
            this.mouseEnabled = false;
        }
    }

    public function isCloseMouse(param1:Boolean):void {
        if (param1) {
            this.mouseEnabled = false;
            DisplayObjectUtil.darkenDisplayObject(this);
        } else {
            this.mouseEnabled = true;
        }
    }

    private function updateInfoDisplay():void {
        var _loc1_:FighterInfo = this._fighter.fighterInfo;
        this._lvTxt.text = _loc1_.level.toString();
        this._hpTxt.text = _loc1_.hp + "/" + _loc1_.maxHp;
        this._nameTxt.text = _loc1_.name;
    }

    private function updateHealthBar():void {
        var _loc1_:FighterInfo = this._fighter.fighterInfo;
        var _loc2_:Number = _loc1_.hp / _loc1_.maxHp;
        if (_loc2_ > 1) {
            _loc2_ = 1;
        }
        this._healthBar.scaleX = _loc2_;
    }

    private function updateFightingMark():void {
        if (this._fighter.fighterInfo.position != 0) {
            this._mark.visible = true;
        } else {
            this._mark.visible = false;
        }
    }

    private function set enabled(param1:Boolean):void {
        this._enabled = param1;
        if (this._enabled == true) {
            this._infoDisplay.visible = true;
            this._healthBar.visible = true;
            this._typeIcon.visible = true;
            this.mouseEnabled = true;
        } else {
            this._infoDisplay.visible = false;
            this._healthBar.visible = false;
            this._typeIcon.visible = false;
            this.mouseEnabled = false;
        }
    }

    private function get enabled():Boolean {
        return this._enabled;
    }

    public function dispose():void {
        this._fighter = null;
        this._iconDisplayer.dispose();
        this._iconDisplayer = null;
        this._shape = null;
    }
}
}
