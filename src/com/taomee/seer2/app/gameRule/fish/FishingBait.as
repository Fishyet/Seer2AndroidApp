package com.taomee.seer2.app.gameRule.fish {
import com.taomee.seer2.app.inventory.item.CollectionItem;

public class FishingBait {


    private var _item:CollectionItem;

    public function FishingBait(param1:CollectionItem) {
        super();
        this._item = param1;
    }

    public function get item():CollectionItem {
        return this._item;
    }
}
}
