package managers {
import com.seer2.extensions.resolution.ResolutionController;

/**
 * 游戏启动器
 * 负责启动主游戏并传递配置数据
 */
public class GameLauncher {

    private var _mainEntry:Object;

    public function GameLauncher() {
    }

    /**
     * 启动游戏
     */
    public function launchGame(mainEntry:Object, client:Client, configData:Object, loginData:Object):void {
        this._mainEntry = mainEntry;

        // 设置XML配置
        this._mainEntry.setXML(
                configData.serverXML,
                configData.beanXML,
                configData.settingsXML
        );

        // 设置游戏配置
        this._mainEntry.setConfig(
                configData.isDebug,
                configData.rootURL,
                configData.isLocal
        );
        var sett:Function = function (scale:Number):void {
            ResolutionController.instance.setResolutionScale(scale);

        };

        this._mainEntry.setResolution(ResolutionController.instance.setResolutionScale, Client.originalWidth, Client.originalHeight);
        // 初始化游戏
        this._mainEntry.initialize(client, loginData);
    }

    /**
     * 获取主入口实例
     */
    public function get mainEntry():Object {
        return this._mainEntry;
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        this._mainEntry = null;
    }
}
}
