package com.taomee.seer2.core.manager {
import com.taomee.seer2.app.arena.FightManager;
import com.taomee.seer2.app.arena.events.FightStartEvent;

public class ResolutionManager {

    private static var setResolution:Function; // 设置分辨率的函数, 参数为放大倍数

    private var lowResolutionRate:Number;

    private var standardResolutionRate:Number;

    private var higherResolutionRate:Number;

    private var notFightingResolution:Function;

    private var fightingResolution:Function;

    private static var _instance:ResolutionManager;

    public function ResolutionManager() {
    }

    public static function get instance():ResolutionManager {
        if (_instance == null) {
            _instance = new ResolutionManager();
        }
        return _instance;
    }

    public function init(param1:Function, deviceWidth:int, deviceHeight:int):void {
        setResolution = param1;
        if (deviceWidth / deviceHeight > 1200 / 660) {
            this.standardResolutionRate = deviceHeight / 660;
            this.lowResolutionRate = this.standardResolutionRate * 1.2; // 较低分辨率放大倍数的值为 标准分辨率的 1.2
            this.higherResolutionRate = 2 * this.standardResolutionRate / (1 + this.standardResolutionRate) // 较高分辨率的值为 标准分辨率和设备分辨率的平均值
        } else {
            this.standardResolutionRate = deviceWidth / 1200;
            this.lowResolutionRate = this.standardResolutionRate * 1.2; // 较低分辨率放大倍数的值为 标准分辨率的 1.2
            this.higherResolutionRate = 2 * this.standardResolutionRate / (1 + this.standardResolutionRate) // 较高分辨率的值为 标准分辨率和设备分辨率的平均值
        }
        FightManager.addEventListener(FightStartEvent.START_SUCCESS, onFightStart);
        FightManager.addEventListener(FightStartEvent.FIGHT_OVER_BEFORE_CHANGE_SCENE, onFightEnd);
    }

    private function setLowResolution():void {
        trace("setLowResolution: " + this.lowResolutionRate);
        setResolution(this.lowResolutionRate);
    }

    private function setStandardResolution():void {
        trace("setStandardResolution: " + this.standardResolutionRate);
        setResolution(this.standardResolutionRate);
    }

    private function setHigherResolution():void {
        trace("setHigherResolution: " + this.higherResolutionRate);
        setResolution(this.higherResolutionRate);
    }

    private function setDeviceResolution():void {
        trace("setDeviceResolution: 1");
        setResolution(1)
    }

    public function setResolutionByStrategyID(param1:int):void {
        switch (param1) {
            case 0:
                this.fightingResolution = this.setLowResolution;
                this.notFightingResolution = this.setStandardResolution;
                break;
            case 1:
                this.fightingResolution = this.setStandardResolution;
                this.notFightingResolution = this.setStandardResolution;
                break;
            case 2:
                this.fightingResolution = this.setLowResolution;
                this.notFightingResolution = this.setHigherResolution;
                break;
            case 3:
                this.fightingResolution = this.setStandardResolution;
                this.notFightingResolution = this.setHigherResolution;
                break;
            case 4:
                this.fightingResolution = this.setDeviceResolution;
                this.notFightingResolution = this.setDeviceResolution;
                break;
            default:
                this.fightingResolution = this.setStandardResolution;
                this.notFightingResolution = this.setStandardResolution;
        }
        onFightEnd(null);
    }

    private static function onFightStart(param1:FightStartEvent):void {
        if (instance.fightingResolution != null) {
            trace("onFightStart");
            instance.fightingResolution();
        }
    }

    private static function onFightEnd(param1:FightStartEvent):void {
        if (instance.notFightingResolution != null) {
            trace("onFightEnd");
            instance.notFightingResolution();
        }
    }
}
}
