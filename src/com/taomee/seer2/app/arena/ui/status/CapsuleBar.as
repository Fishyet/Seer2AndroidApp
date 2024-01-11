package com.taomee.seer2.app.arena.ui.status {
import com.taomee.seer2.app.arena.Fighter;
import com.taomee.seer2.app.arena.data.FighterTeam;
import com.taomee.seer2.app.arena.resource.FightUIManager;
import com.taomee.seer2.core.utils.DisplayObjectUtil;

import flash.display.Sprite;

public class CapsuleBar extends Sprite {

    private static const CAPSULE_NUM:int = 6;

    private static const CAPSULE_WIDTH:int = 11;


    private var _occupiedVec:Vector.<Sprite>;

    private var _emptyVec:Vector.<Sprite>;

    private var _capsuleNum:int;

    private var _team:FighterTeam;

    public function CapsuleBar() {
        super();
        this._emptyVec = new Vector.<Sprite>();
        this.createCapsuleVec(this._emptyVec, "UI_FightCapsuleEmpty");
        this._occupiedVec = new Vector.<Sprite>();
        this.createCapsuleVec(this._occupiedVec, "UI_FightCapsuleOccupied");
    }

    public function setFighterTeam(param1:FighterTeam):void {
        var _loc2_:Fighter = null;
        this._team = param1;
        this._capsuleNum = this._team.fighterCount;
        for each(_loc2_ in param1.fighterVec) {
            if (_loc2_.isFit) {
                --this._capsuleNum;
            }
        }
        if (this._capsuleNum > 6) {
            this._capsuleNum = 6;
        }
        this.showCapsule(this._capsuleNum);
    }

    public function update(param1:*):void {
        var _loc2_:int = this._team.aliveFighterCount;
        this.showAliveCapsule(_loc2_);
    }

    private function createCapsuleVec(param1:Vector.<Sprite>, param2:String):void {
        var _loc4_:Sprite = null;
        var _loc3_:int = 0;
        while (_loc3_ < CAPSULE_NUM) {
            (_loc4_ = FightUIManager.getSprite(param2)).x = _loc3_ * CAPSULE_WIDTH;
            param1.push(_loc4_);
            addChild(_loc4_);
            _loc3_++;
        }
    }

    private function showCapsule(param1:int):void {
        var _loc3_:Sprite = null;
        var _loc2_:int = param1;
        while (_loc2_ < CAPSULE_NUM) {
            _loc3_ = this._occupiedVec[_loc2_];
            _loc3_.visible = false;
            _loc2_++;
        }
    }

    private function showAliveCapsule(param1:int):void {
        var _loc3_:Sprite = null;
        var _loc2_:int = 0;
        while (_loc2_ < this._capsuleNum) {
            _loc3_ = this._occupiedVec[_loc2_];
            if (_loc2_ >= param1) {
                DisplayObjectUtil.fightCapsuleBrightness(_loc3_);
            }
            _loc2_++;
        }
    }

    public function dispose():void {
        this._team = null;
    }
}
}
