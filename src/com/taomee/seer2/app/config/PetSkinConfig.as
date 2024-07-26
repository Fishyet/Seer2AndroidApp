package com.taomee.seer2.app.config {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import org.taomee.ds.HashMap;

import seer2.next.entry.DynConfig;

public class PetSkinConfig {

    private static var _xmlClass:Class = PetSkinConfig__xmlClass;

    private static var skinMap:HashMap = new HashMap();

    private static var _skinXml:XML;

    {
        setup();
    }

    public function PetSkinConfig() {
        super();
    }

    private static function setup():void {
        var _xml:XML = null;
        _skinXml = DynConfig.petSkinConfigXML || XML(new _xmlClass());
        var _skinList:XMLList = _skinXml.descendants("pet");
        for each(_xml in _skinList)
        {
            skinMap.add(uint(_xml.@resourceId),uint(_xml.@skinId));
        }
    }

    public static function getSkinId(petId:uint):uint
    {
        if (skinMap.containsKey(petId)) {
            return skinMap.getValue(petId) as uint;
        }
        else
        {
            return 0;
        }
    }

    public static function setPetSkin(petId:uint,skinId:uint):void {
        if (skinMap.containsKey(petId)) {
            skinMap.remove(petId);
            skinMap.add(petId, skinId);
            var list:XMLList = _skinXml.descendants("pet");
            for (var i:int = 0; i < list.length(); i++) {
                if (list[i].@resourceId == petId.toString()) {
                    list[i] = <pet resourceId={petId} skinId={skinId}/>;
                }
            }
        } else {
            skinMap.add(petId, skinId);
            _skinXml.appendChild(<pet resourceId={petId} skinId={skinId}/>);
        }

        var f:File = File.applicationStorageDirectory.resolvePath("gameSettings/SkinSettings.xml");
        if (f.exists) {
            f.deleteFile();
        }

        var stream:FileStream = new FileStream();
        stream.open(f, FileMode.WRITE);
        stream.writeUTFBytes(_skinXml.toXMLString());
        stream.close();
    }
}
}
