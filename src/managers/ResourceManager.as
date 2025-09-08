package managers {
import events.XMLEvent;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.getDefinitionByName;

import net.AssetsLoader;
import net.DLLLoader;
import net.XMLLoader;

/**
 * 资源管理器
 * 负责管理所有资源加载，包括SWF文件、XML配置、DLL等
 */
public class ResourceManager {

    private var _assetsLoader:AssetsLoader;
    private var _xmlLoader:XMLLoader;
    private var _dllLoader:DLLLoader;
    private var _loginLoader:Loader;

    public static var loaderContext:LoaderContext;

    public function ResourceManager() {
        if (loaderContext == null) {
            loaderContext = new LoaderContext(false);
            loaderContext.allowCodeImport = true;
        }
    }

    /**
     * 加载初始资源
     */
    public function loadAssets(onComplete:Function, onError:Function):void {
        this._assetsLoader = new AssetsLoader();
        this._assetsLoader.addEventListener(Event.COMPLETE, function (event:Event):void {
            _assetsLoader.removeEventListener(Event.COMPLETE, arguments.callee);
            onComplete(_assetsLoader);
        });
        this._assetsLoader.load();
    }

    /**
     * 加载XML文件
     */
    public function loadXML(path:String, onComplete:Function, onError:Function, onProgress:Function = null):void {
        this._xmlLoader = new XMLLoader();
        this._xmlLoader.addEventListener(XMLEvent.COMPLETE, function (event:XMLEvent):void {
            _xmlLoader.removeEventListener(XMLEvent.COMPLETE, arguments.callee);
            if (onProgress != null) {
                _xmlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            onComplete(event.data);
        });

        if (onProgress != null) {
            this._xmlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        this._xmlLoader.load(path);
    }

    /**
     * 加载登录模块
     */
    public function loadLoginModule(path:String, onComplete:Function, onError:Function, onProgress:Function = null):void {
        this._loginLoader = new Loader();

        this._loginLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event):void {
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            var secondLoader:Loader = new Loader();

            secondLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
                var finalLoaderInfo:LoaderInfo = e.target as LoaderInfo;
                finalLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
                onComplete(finalLoaderInfo.content);
            });

            secondLoader.loadBytes(loaderInfo.bytes, loaderContext);

            loaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
            if (onProgress != null) {
                loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        });

        var onIOError:Function = function (event:IOErrorEvent):void {
            _loginLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
            if (onProgress != null) {
                _loginLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            _loginLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            onError("加载登录模块失败: " + event.text);
        };

        if (onProgress != null) {
            this._loginLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        this._loginLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        this._loginLoader.load(new URLRequest(path), loaderContext);
    }

    /**
     * 加载DLL
     */
    public function loadDLL(file:*, decryptionKey:String, onComplete:Function, onError:Function, onProgress:Function = null, onDecryptionSuccess:Function = null):void {
        this._dllLoader = new DLLLoader();

        this._dllLoader.addEventListener(Event.COMPLETE, function (event:Event):void {
            _dllLoader.removeEventListener(Event.COMPLETE, arguments.callee);
            if (onProgress != null) {
                _dllLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            _dllLoader.removeEventListener(DLLLoader.DECRYPTION_SUCCESS, onDecryptSuccess);
            _dllLoader.removeEventListener(DLLLoader.DECRYPTION_ERROR, onDecryptError);
            onComplete();
        });

        var onDecryptSuccess:Function = function (event:Event):void {
            if (onDecryptionSuccess != null) {
                onDecryptionSuccess();
            }
        };

        var onDecryptError:Function = function (event:Event):void {
            _dllLoader.removeEventListener(Event.COMPLETE, arguments.callee);
            if (onProgress != null) {
                _dllLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            _dllLoader.removeEventListener(DLLLoader.DECRYPTION_SUCCESS, onDecryptSuccess);
            _dllLoader.removeEventListener(DLLLoader.DECRYPTION_ERROR, onDecryptError);
            onError("DLL解密失败");
        };

        if (onProgress != null) {
            this._dllLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        this._dllLoader.addEventListener(DLLLoader.DECRYPTION_SUCCESS, onDecryptSuccess);
        this._dllLoader.addEventListener(DLLLoader.DECRYPTION_ERROR, onDecryptError);
        this._dllLoader.loadFromLocal(file, decryptionKey);
    }

    /**
     * 创建游戏主入口实例
     */
    public function createMainEntry(mainEntryClassPath:String):Object {
        try {
            var mainEntryClass:* = getDefinitionByName(mainEntryClassPath);
            return new mainEntryClass();
        } catch (e:Error) {
            throw new Error("创建主入口类失败: " + e.message);
        }
    }

    /**
     * 卸载登录模块
     */
    public function unloadLoginModule():void {
        if (this._loginLoader) {
            this._loginLoader.unloadAndStop();
            this._loginLoader = null;
        }
    }

    /**
     * 销毁XMLLoader
     */
    public function destroyXMLLoader():void {
        if (this._xmlLoader) {
            this._xmlLoader.destroy();
            this._xmlLoader = null;
        }
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        if (this._assetsLoader) {
            this._assetsLoader.dispose();
            this._assetsLoader = null;
        }

        this.destroyXMLLoader();
        this.unloadLoginModule();

        if (this._dllLoader) {
            this._dllLoader = null;
        }
    }
}
}
