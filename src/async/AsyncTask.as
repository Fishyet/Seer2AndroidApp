package async {
import flash.events.EventDispatcher;

/**
 * 异步任务类
 * 用于封装异步操作，支持链式调用
 */
public class AsyncTask extends EventDispatcher {

    public static const COMPLETE:String = "asyncTaskComplete";
    public static const ERROR:String = "asyncTaskError";

    private var _name:String;
    private var _executeFunc:Function;
    private var _isExecuting:Boolean = false;
    private var _isCompleted:Boolean = false;
    private var _result:*;
    private var _error:String;

    public function AsyncTask(name:String, executeFunc:Function) {
        this._name = name;
        this._executeFunc = executeFunc;
    }

    public function get name():String {
        return this._name;
    }

    public function get isExecuting():Boolean {
        return this._isExecuting;
    }

    public function get isCompleted():Boolean {
        return this._isCompleted;
    }

    public function get result():* {
        return this._result;
    }

    public function get error():String {
        return this._error;
    }

    /**
     * 执行任务
     */
    public function execute():void {
        if (this._isExecuting || this._isCompleted) {
            return;
        }

        this._isExecuting = true;
        try {
            // 执行函数，传入complete和error回调
            this._executeFunc(this.complete, this.onError);
        } catch (e:Error) {
            this.onError("Task execution failed: " + e.message);
        }
    }

    /**
     * 任务完成回调
     */
    public function complete(result:* = null):void {
        if (!this._isExecuting) {
            return;
        }

        this._isExecuting = false;
        this._isCompleted = true;
        this._result = result;
        dispatchEvent(new AsyncTaskEvent(COMPLETE, this));
    }

    /**
     * 任务错误回调
     */
    public function onError(message:String):void {
        if (!this._isExecuting) {
            return;
        }

        this._isExecuting = false;
        this._isCompleted = true;
        this._error = message;
        dispatchEvent(new AsyncTaskEvent(ERROR, this));
    }

    /**
     * 重置任务状态
     */
    public function reset():void {
        this._isExecuting = false;
        this._isCompleted = false;
        this._result = null;
        this._error = null;
    }
}
}
