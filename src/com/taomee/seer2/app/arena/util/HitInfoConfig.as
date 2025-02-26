package com.taomee.seer2.app.arena.util {
import com.taomee.seer2.app.arena.data.AnimationHitInfo;
import com.taomee.seer2.app.config.PetConfig;
import com.taomee.seer2.app.config.pet.PetDefinition;
import com.taomee.seer2.app.popup.AlertManager;
import com.taomee.seer2.core.manager.GameSettingsManager;

import org.taomee.ds.HashMap;

import seer2.next.entry.DynConfig;

public class HitInfoConfig {

    private static var _hitData:Class = HitInfoConfig__hitData;

    private static var _hitDatas:HashMap;


    public function HitInfoConfig() {
        super();
    }

    public static function getHitData(param1:uint):AnimationHitInfo {
        if (_hitDatas == null) {
            _hitDatas = new HashMap();
            setup();
        }
        var petDef:PetDefinition = PetConfig.getPetDefinition(param1);
        if (petDef != null) {
            param1 = petDef.realId;
        } else {
            return GetHitDataError(param1);
        }
        var _loc2_:AnimationHitInfo = _hitDatas.getValue(param1);
        if (_loc2_ == null) {
            return GetHitDataError(param1);
        }
        return _loc2_;
    }

    private static var tempHitInfo:AnimationHitInfo;

    private static function GetHitDataError(id:uint):AnimationHitInfo {
        if (!GameSettingsManager.isHitAndPetConfigEnable) {
            AlertManager.showConfirm("没有找到该精灵的帧数配置信息, 请问你要开启帧数配置表和精灵配置表动态更新吗?\n(如果开启, 下次进入游戏生效)", GameSettingsManager.enableHitAndPetConfig);
        }
        if (tempHitInfo == null) {
            tempHitInfo = new AnimationHitInfo();
            tempHitInfo.id = id;
            tempHitInfo.attribute = 1;
            tempHitInfo.critical = 1;
            tempHitInfo.fit = 1;
            tempHitInfo.physics = 1;
            tempHitInfo.special = 1;
        } else {
            tempHitInfo.id = id;
        }
        return tempHitInfo;
    }

    public static function initialize():void {
        _hitDatas = new HashMap();
        setup();
    }

    private static function setup():void {
        var _loc5_:XML = null;
        var _loc6_:AnimationHitInfo = null;
        var _loc1_:XML = DynConfig.hitConfigXML || XML(new _hitData());
        var _loc2_:XMLList = _loc1_.child("fighter");
        var _loc3_:uint = uint(_loc2_.length());
        var _loc4_:uint = 0;
        while (_loc4_ < _loc3_) {
            _loc5_ = _loc2_[_loc4_];
            (_loc6_ = new AnimationHitInfo()).id = _loc5_.@id;
            _loc6_.attribute = _loc5_.@attribute;
            _loc6_.critical = _loc5_.@critical;
            _loc6_.fit = _loc5_.@fit;
            _loc6_.physics = _loc5_.@physics;
            _loc6_.special = _loc5_.@special;
            _hitDatas.add(_loc6_.id, _loc6_);
            _loc4_++;
        }
    }
}
}
