package managers {
import com.seer2.extensions.resolution.ResolutionController;

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.ContextMenu;

import ui.Background;
import ui.LoadingBar;

/**
 * UI管理器
 * 负责界面初始化、布局管理和UI组件
 */
public class UIManager {

    private var _stage:Stage;
    private var _root:Sprite;
    private var _progressBar:LoadingBar;
    private var _loginContent:DisplayObject;
    private var _background:Background;
    private var _closeButton:SimpleButton;

    private var _fixWidth:Number;
    private var _fixHeight:Number;

    public function UIManager(stage:Stage, root:Sprite) {
        this._stage = stage;
        this._root = root;
    }

    /**
     * 初始化舞台设置
     */
    public function initializeStage():void {
        var contextMenu:ContextMenu = new ContextMenu();
        contextMenu.hideBuiltInItems();
        this._root.contextMenu = contextMenu;
        trace("Stage: " + this._stage.stageWidth + "x" + this._stage.stageHeight);
        if (this._stage.stageWidth > this._stage.stageHeight * 1.82) {
            ResolutionController.instance.setResolutionScale(this._stage.stageHeight / 660);
        } else {
            ResolutionController.instance.setResolutionScale(this._stage.stageWidth / 1200);
        }
    }

    /**
     * 设置游戏区域尺寸和位置
     */
    public function setupGameArea():void {
        if (this._stage.stageWidth > this._stage.stageHeight * 1.82) {
            this._fixWidth = int(this._stage.stageHeight * 1.82);
            this._fixHeight = this._stage.stageHeight;
        } else {
            this._fixWidth = this._stage.stageWidth;
            this._fixHeight = int(this._stage.stageWidth * 0.55);
        }

        this._root.width = this._fixWidth;
        this._root.height = this._fixHeight;
        this._root.x = (this._stage.stageWidth - this._fixWidth) / 2;
        this._root.y = (this._stage.stageHeight - this._fixHeight) / 2;
        this._root.scrollRect = new Rectangle(0, 0, this._fixWidth, this._fixHeight);

        trace("stageWidth: " + this._stage.stageWidth + ", stageHeight: " + this._stage.stageHeight);
    }

    /**
     * 创建背景
     */
    public function createBackground():void {
        this._background = new Background();
        this._stage.addEventListener(Event.RESIZE, function (event:Event):void {
            if (_background) {
                _background.width = _stage.stageWidth;
                _background.height = _stage.stageHeight;
            }

        });
        this._background.width = this._stage.stageWidth;
        this._background.height = this._stage.stageHeight;
        this._stage.addChildAt(this._background, 0);
    }

    /**
     * 创建关闭按钮
     */
    public function createCloseButton():void {
        this._closeButton = this.createButton(0, 0, 25, 100, "关闭游戏");
        this._closeButton.addEventListener(MouseEvent.CLICK, this.onCloseGame);
        this._stage.addChild(this._closeButton);
    }

    /**
     * 创建按钮的辅助方法
     */
    private function createButton(x:int, y:int, height:int, width:int, label:String):SimpleButton {
        var createButtonState:Function = function (color:uint, text:String):Sprite {
            var state:Sprite = new Sprite();
            state.graphics.beginFill(color);
            state.graphics.drawRect(0, 0, width, height);
            state.graphics.endFill();

            var labelField:TextField = createStaticText(0, 0, height, width, false);
            labelField.text = text;
            labelField.selectable = false;
            state.addChild(labelField);
            return state;
        };

        var normalState:Sprite = createButtonState(5591163, label);
        var hoverState:Sprite = createButtonState(7700386, label);
        var downState:Sprite = createButtonState(6369338, label);
        var disabledState:Sprite = createButtonState(6369338, "已禁用");

        var button:SimpleButton = new SimpleButton(normalState, hoverState, downState, disabledState);
        button.x = x;
        button.y = y;
        return button;
    }

    /**
     * 创建静态文本的辅助方法
     */
    private function createStaticText(x:int, y:int, height:int, width:int, mouseEnabled:Boolean):TextField {
        var textField:TextField = new TextField();
        var textFormat:TextFormat = new TextFormat();
        textField.text = "";
        textField.x = x;
        textField.y = y;
        textField.height = height;
        textField.width = width;
        textField.mouseEnabled = mouseEnabled;
        textField.alpha = 0.9;
        textFormat.size = height - 3;
        textFormat.color = 10798591;
        textField.defaultTextFormat = textFormat;
        return textField;
    }

    /**
     * 设置进度条
     */
    public function setupProgressBar(loginLoadingBarClass:Class, client:*):void {
        this._progressBar = new LoadingBar(this._stage, client);
        this._progressBar.setup(loginLoadingBarClass);
    }

    /**
     * 显示进度条
     */
    public function showProgressBar():void {
        if (this._progressBar) {
            this._progressBar.show(this._root);
        }
    }

    /**
     * 隐藏进度条
     */
    public function hideProgressBar():void {
        if (this._progressBar) {
            this._progressBar.hide();
        }
    }

    /**
     * 设置进度条标题
     */
    public function setProgressTitle(title:String):void {
        if (this._progressBar) {
            this._progressBar.setTitle(title);
        }
    }

    /**
     * 更新进度
     */
    public function updateProgress(percent:int):void {
        if (this._progressBar) {
            this._progressBar.progress(percent);
        }
    }

    /**
     * 显示错误信息
     */
    public function showError(message:String):void {
        if (this._progressBar) {
            this._progressBar.showError(message);
        }
    }

    /**
     * 输入文本对话框
     */
    public function inputText(prompt:String, callback:Function):void {
        if (this._progressBar) {
            this._progressBar.inputText(prompt, callback);
        }
    }

    /**
     * 设置登录内容
     */
    public function setLoginContent(content:DisplayObject):void {
        this._loginContent = content;
        this._root.addChild(this._loginContent);

        this.layoutLoginContent();
    }

    /**
     * 移除登录内容
     */
    public function removeLoginContent():void {
        if (this._loginContent && this._root.contains(this._loginContent)) {
            this._root.removeChild(this._loginContent);
            this._loginContent = null;
        }
    }

    /**
     * 布局登录内容
     */
    public function layoutLoginContent():void {
        if (this._loginContent && this._loginContent.hasOwnProperty("layOut")) {
            this._loginContent["layOut"](this._root);
        }
    }


    /**
     * 关闭游戏
     */
    private function onCloseGame(event:MouseEvent):void {
        ResolutionController.instance.dispose();
        NativeApplication.nativeApplication.exit();
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        if (this._progressBar) {
            this._progressBar.dispose();
            this._progressBar = null;
        }

        this.removeLoginContent();
    }

    // Getters
    public function get fixWidth():Number {
        return this._fixWidth;
    }

    public function get fixHeight():Number {
        return this._fixHeight;
    }

    public function get progressBar():LoadingBar {
        return this._progressBar;
    }
}
}
