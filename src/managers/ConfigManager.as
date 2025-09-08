package managers {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

/**
 * 配置管理器
 * 负责管理游戏设置、服务器配置等
 */
public class ConfigManager {

    private var _settingsXML:XML;
    private var _serverXML:XML;
    private var _beanXML:XML;

    private var _isDebug:Boolean = false;
    private var _isLocal:Boolean = false;
    private var _domain:String = "fish-yet.733702.xyz";
    private var _rootURL:String = "http://8.217.250.123/seer2/";

    public function ConfigManager() {
    }

    /**
     * 加载游戏设置
     */
    public function loadGameSettings(onComplete:Function, onError:Function):void {
        try {
            var file:File = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
            if (file.exists) {
                var fileStream:FileStream = new FileStream();
                fileStream.open(file, FileMode.READ);
                this._settingsXML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
                fileStream.close();

                if (this._settingsXML.elements("domain").length() == 0) {
                    // 没有域名配置，使用默认
                    this._settingsXML.appendChild(<domain>{this._domain}</domain>);
                    onComplete("fish-yet.733702.xyz");
                } else {
                    // 有域名配置，使用配置的域名
                    this._domain = this._settingsXML.elements("domain")[0].toString();
                    onComplete(this._domain);
                }

            } else {
                // 文件不存在，需要下载默认配置
                onError("CONFIG_NOT_FOUND");
            }
        } catch (e:Error) {
            onError("读取配置文件失败: " + e.message);
        }
    }

    /**
     * 保存域名设置
     */
    public function saveDomainSetting(domain:String, onComplete:Function, onError:Function):void {
        try {
            var file:File = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.WRITE);

            if (this._settingsXML.elements("domain").length() == 0) {
                this._settingsXML.appendChild(<domain>{domain}</domain>);
            } else {
                this._settingsXML.elements("domain")[0] = domain;
            }

            fileStream.writeUTFBytes(this._settingsXML);
            fileStream.close();
            onComplete();
        } catch (e:Error) {
            onError("保存配置失败: " + e.message);
        }
    }

    /**
     * 设置Bean XML配置
     */
    public function setBeanXML(xml:XML):void {
        this._beanXML = xml;
    }

    /**
     * 设置服务器XML配置
     */
    public function setServerXML(xml:XML):void {
        this._serverXML = xml;
    }

    /**
     * 设置根URL
     */
    public function setRootURL(url:String):void {
        this._rootURL = url;
    }

    /**
     * 设置调试模式
     */
    public function setDebugMode(isDebug:Boolean):void {
        this._isDebug = isDebug;
    }

    /**
     * 设置本地模式
     */
    public function setLocalMode(isLocal:Boolean):void {
        this._isLocal = isLocal;
    }

    /**
     * 获取所有配置数据
     */
    public function getConfigData():Object {
        return {
            settingsXML: this._settingsXML,
            serverXML: this._serverXML,
            beanXML: this._beanXML,
            rootURL: this._rootURL,
            isDebug: this._isDebug,
            isLocal: this._isLocal
        };
    }

    // Getters
    public function get settingsXML():XML {
        return this._settingsXML;
    }

    public function get serverXML():XML {
        return this._serverXML;
    }

    public function get beanXML():XML {
        return this._beanXML;
    }

    public function get rootURL():String {
        return this._rootURL;
    }

    public function get domain():String {
        return this._domain;
    }

    public function get isDebug():Boolean {
        return this._isDebug;
    }

    public function get isLocal():Boolean {
        return this._isLocal;
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        this._settingsXML = null;
        this._serverXML = null;
        this._beanXML = null;
    }
}
}
