package {
import async.AsyncTask;
import async.AsyncTaskManager;

import com.seer2.extensions.resolution.ResolutionController;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import managers.ConfigManager;
import managers.GameLauncher;
import managers.NetworkManager;
import managers.ResourceManager;
import managers.UIManager;

import states.AppState;

/**
 * 重构后的Client类
 * 主要职责：协调各个管理器，管理应用生命周期
 */
public class Client extends Sprite {

    // 常量定义
    private const MAIN_ENTRY_CLASS_PATH:String = "com.taomee.seer2.app.MainEntry";
    private const LOCAL_DLL_PATH:String = "seer2DLL/library.swf";
    private const VERSION_URL:String = "version/version.txt";
    private const DLL_URL:String = "version/library.swf";

    // 管理器实例
    private var _uiManager:UIManager;
    private var _configManager:ConfigManager;
    private var _networkManager:NetworkManager;
    private var _resourceManager:ResourceManager;
    private var _gameLauncher:GameLauncher;
    private var _taskManager:AsyncTaskManager;

    // 状态和数据
    private var _currentState:String = AppState.INITIALIZING;
    private var _loginData:Object;
    private var _dllDecryptionKey:String;

    // 重写的属性
    private var _width:Number = 0;
    private var _height:Number = 0;

    public static var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

    public static var originalWidth:int;
    public static var originalHeight:int;

    public function Client() {
        super();
        lc.allowCodeImport = true;
        this.stage.stageFocusRect = false;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.stage.align = StageAlign.TOP_LEFT;
        ResolutionController.instance.initializeController();
        addEventListener(Event.ADDED_TO_STAGE, this.onAddStage);
    }

    override public function set width(param1:Number):void {
        this._width = param1;
    }

    override public function get width():Number {
        return this._width;
    }

    override public function set height(param1:Number):void {
        this._height = param1;
    }

    override public function get height():Number {
        return this._height;
    }

    /**
     * 舞台添加事件处理
     */
    private function onAddStage(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, this.onAddStage);
        originalWidth = stage.stageWidth;
        originalHeight = stage.stageHeight;
        this.initialize();
    }

    /**
     * 初始化应用
     */
    private function initialize():void {
        this._uiManager = new UIManager(stage, this);
        this._configManager = new ConfigManager();
        this._networkManager = new NetworkManager();
        this._resourceManager = new ResourceManager();
        this._gameLauncher = new GameLauncher();
        this._taskManager = new AsyncTaskManager();

        this._uiManager.initializeStage();

        this._taskManager
                .createTask("加载游戏设置", this.taskLoadGameSettings)
                .createTask("加载资源", this.taskLoadAssets)
                .createTask("设置游戏区域", this.taskSetupGameArea)
                .createTask("解析DNS", this.taskResolveDNS)
                .createTask("检查版本", this.taskCheckVersion)
                .createTask("加载Bean配置", this.taskLoadBeanXML)
                .createTask("加载服务器配置", this.taskLoadServerXML)
                .createTask("加载登录界面", this.taskLoadLogin)
                .createTask("等待用户登录", this.taskWaitForLogin)
                .createTask("加载游戏DLL", this.taskLoadDLL)
                .createTask("启动游戏", this.taskLaunchGame);

        this._taskManager.execute(
                this.onApplicationComplete,
                this.onApplicationError,
                this.onTaskComplete
        );
    }

    /**
     * 任务：加载资源
     */
    private function taskLoadAssets(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_ASSETS;
        this._resourceManager.loadAssets(
                function (assetsLoader:*):void {
                    complete(assetsLoader);
                },
                function (errorMsg:String):void {
                    error("资源加载失败: " + errorMsg);
                }
        );
    }

    /**
     * 任务：设置游戏区域
     */
    private function taskSetupGameArea(complete:Function, error:Function):void {
        try {
            var assetsLoader:* = this._taskManager.getPreviousTaskResult();

            this._uiManager.setupGameArea();
            this._uiManager.createBackground();
            this._uiManager.createCloseButton();
            this._uiManager.setupProgressBar(assetsLoader.getClassFromLoader("LoginLoadingBarUI"), this);
            this._uiManager.showProgressBar();
            complete();
        } catch (e:Error) {
            error("游戏区域设置失败: " + e.message);
        }
    }

    /**
     * 任务：加载游戏设置
     */
    private function taskLoadGameSettings(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_CONFIG;
        this._uiManager.setProgressTitle("正在加载游戏设置");

        this._configManager.loadGameSettings(
                function (domain:String):void {
                    complete(domain);
                },
                function (errorMsg:String):void {
                    if (errorMsg == "CONFIG_NOT_FOUND") {
                        // 需要下载默认配置
                        _networkManager.downloadFileToLocal(
                                "initialSWF/GameDefaultSettings.xml",
                                "gameSettings/GameSettings.xml",
                                function ():void {
                                    // 重新尝试加载
                                    taskLoadGameSettings(complete, error);
                                },
                                function (downloadError:String):void {
                                    error("下载默认配置失败: " + downloadError);
                                }
                        );
                    } else {
                        error(errorMsg);
                    }
                }
        );
    }

    /**
     * 任务：解析DNS
     */
    private function taskResolveDNS(complete:Function, error:Function):void {
        this._currentState = AppState.RESOLVING_DNS;
        this._uiManager.setProgressTitle("正在解析域名, 获取游戏资源地址");

        var domain:String = this._configManager.domain;

        this._networkManager.resolveDNS(
                domain,
                function (rootURL:String):void {
                    _configManager.setRootURL(rootURL);
                    trace("ROOT_URL: " + rootURL);
                    complete(rootURL);
                },
                function (errorMsg:String):void {
                    // DNS解析失败，让用户手动输入
                    _uiManager.inputText("请手动输入域名", function (input:String):void {
                        _uiManager.setProgressTitle("正在保存域名");
                        _configManager.saveDomainSetting(
                                input,
                                function ():void {
                                    // 重新解析
                                    taskResolveDNS(complete, error);
                                },
                                function (saveError:String):void {
                                    error("保存域名失败: " + saveError);
                                }
                        );
                    });
                }
        );
    }

    /**
     * 任务：检查版本
     */
    private function taskCheckVersion(complete:Function, error:Function):void {
        this._currentState = AppState.CHECKING_VERSION;

        this._networkManager.checkVersion(
                this._configManager.rootURL,
                this.VERSION_URL,
                function (decryptionKey:String):void {
                    _dllDecryptionKey = decryptionKey;
                    complete(decryptionKey);
                },
                function (errorMsg:String):void {
                    error(errorMsg);
                }
        );
    }

    /**
     * 任务：加载Bean XML
     */
    private function taskLoadBeanXML(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_BEAN_XML;
        this._uiManager.setProgressTitle("正在加载游戏配置");

        this._resourceManager.loadXML(
                "initialSWF/bean.xml",
                function (xml:XML):void {
                    _configManager.setBeanXML(xml);
                    complete(xml);
                },
                function (errorMsg:String):void {
                    error("Bean配置加载失败: " + errorMsg);
                },
                this.onProgress
        );
    }

    /**
     * 任务：加载服务器XML
     */
    private function taskLoadServerXML(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_SERVER_XML;

        this._configManager.setLocalMode(false);
        this._resourceManager.loadXML(
                "initialSWF/Server.xml",
                function (xml:XML):void {
                    _configManager.setServerXML(xml);
                    _resourceManager.destroyXMLLoader();
                    complete(xml);
                },
                function (errorMsg:String):void {
                    error("服务器配置加载失败: " + errorMsg);
                },
                this.onProgress
        );
    }

    /**
     * 任务：加载登录界面
     */
    private function taskLoadLogin(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_LOGIN;
        this._uiManager.setProgressTitle("正在加载登录界面");

        this._resourceManager.loadLoginModule(
                "initialSWF/LoginModule.swf",
                function (loginContent:DisplayObject):void {
                    _uiManager.hideProgressBar();

                    // 设置登录回调
                    loginContent["success"] = function (loginData:Object):void {
                        _loginData = loginData;
                        _uiManager.removeLoginContent();
                        _resourceManager.unloadLoginModule();
                        complete(loginData);
                    };

                    // 初始化登录界面
                    loginContent["setXmlInfo"](_configManager.serverXML);
                    loginContent["init"](_configManager.rootURL);

                    _uiManager.setLoginContent(loginContent);
                },
                function (errorMsg:String):void {
                    error(errorMsg);
                },
                this.onProgress
        );
    }

    /**
     * 任务：等待用户登录
     */
    private function taskWaitForLogin(complete:Function, error:Function):void {
        this._currentState = AppState.LOGGING_IN;
        // 这个任务实际上在taskLoadLogin中就已经设置了回调
        // 当用户登录成功时会自动调用complete
        // 这里只是为了保持任务流程的完整性
        if (this._loginData) {
            complete(this._loginData);
        }
    }

    /**
     * 任务：加载DLL
     */
    private function taskLoadDLL(complete:Function, error:Function):void {
        this._currentState = AppState.LOADING_DLL;
        this._uiManager.setProgressTitle("正在读取游戏核心DLL");
        this._uiManager.showProgressBar();

        var dllFile:File = this._networkManager.getLocalFile(this.LOCAL_DLL_PATH);

        if (this._networkManager.checkLocalFileExists(this.LOCAL_DLL_PATH)) {
            this._resourceManager.loadDLL(
                    dllFile,
                    this._dllDecryptionKey,
                    function ():void {
                        complete();
                    },
                    function (errorMsg:String):void {
                        // DLL解密失败，需要重新下载
                        downloadDLLAndRetry();
                    },
                    this.onProgress,
                    function ():void {
                        _uiManager.setProgressTitle("正在加载游戏核心DLL");
                    }
            );
        } else {
            downloadDLLAndRetry();
        }

        function downloadDLLAndRetry():void {
            _networkManager.downloadFileToLocal(
                    _configManager.rootURL + DLL_URL,
                    LOCAL_DLL_PATH,
                    function ():void {
                        // 重新尝试加载DLL
                        taskLoadDLL(complete, error);
                    },
                    function (downloadError:String):void {
                        error("DLL下载失败: " + downloadError);
                    },
                    function (percent:int):void {
                        _uiManager.setProgressTitle("DLL需要更新,正在下载DLL");
                        _uiManager.updateProgress(percent);
                    }
            );
        }
    }

    /**
     * 任务：启动游戏
     */
    private function taskLaunchGame(complete:Function, error:Function):void {
        this._currentState = AppState.GAME_READY;

        try {
            var mainEntry:Object = this._resourceManager.createMainEntry(this.MAIN_ENTRY_CLASS_PATH);

            this._gameLauncher.launchGame(
                    mainEntry,
                    this,
                    this._configManager.getConfigData(),
                    this._loginData
            );

            // 清理UI资源
            this._uiManager.dispose();

            complete();
        } catch (e:Error) {
            error("游戏启动失败: " + e.message);
        }
    }

    /**
     * 进度更新处理
     */
    private function onProgress(event:ProgressEvent):void {
        var percent:int = event.bytesLoaded / event.bytesTotal * 100;
        this._uiManager.updateProgress(percent);
    }

    /**
     * 单个任务完成处理
     */
    private function onTaskComplete(task:AsyncTask):void {
        trace("任务完成: " + task.name);
    }

    /**
     * 应用流程完成
     */
    private function onApplicationComplete():void {
        trace("应用启动完成");
        // 清理所有管理器
        this.dispose();
    }

    /**
     * 应用流程错误处理
     */
    private function onApplicationError(errorMsg:String, task:AsyncTask):void {
        this._currentState = AppState.ERROR;
        trace("应用启动失败: " + errorMsg + " (任务: " + task.name + ")");
        this._uiManager.showError(errorMsg);
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        if (this._taskManager) {
            this._taskManager.stop();
            this._taskManager = null;
        }

        if (this._configManager) {
            this._configManager.dispose();
            this._configManager = null;
        }

        if (this._networkManager) {
            this._networkManager.dispose();
            this._networkManager = null;
        }

        if (this._resourceManager) {
            this._resourceManager.dispose();
            this._resourceManager = null;
        }

        if (this._gameLauncher) {
            this._gameLauncher.dispose();
            this._gameLauncher = null;
        }

        // 注意：UIManager在游戏启动后由任务处理
    }

    // Getters for debugging and monitoring
    public function get currentState():String {
        return this._currentState;
    }

    public function get taskProgress():Number {
        return this._taskManager ? this._taskManager.progress : 0;
    }
}
}
