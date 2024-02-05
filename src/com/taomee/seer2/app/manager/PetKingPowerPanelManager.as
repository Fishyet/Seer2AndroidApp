package com.taomee.seer2.app.manager {
import com.taomee.seer2.core.manager.GlobalsManager;
import com.taomee.seer2.core.manager.TimeManager;
import com.taomee.seer2.core.manager.VersionManager;
import com.taomee.seer2.core.module.ModuleManager;
import com.taomee.seer2.core.utils.URLUtil;

public class PetKingPowerPanelManager {
    public function PetKingPowerPanelManager() {
        super();
    }

    public static function setup():void {
        ModuleManager.toggleModule(URLUtil.getAppModule("PetKingPowerPanel"), "精灵王争霸之抢分赛");

    }
}
}
