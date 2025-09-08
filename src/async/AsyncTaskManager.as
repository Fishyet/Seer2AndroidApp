package async {
import flash.events.EventDispatcher;

/**
 * 异步任务管理器
 * 管理按顺序执行的异步任务队列
 */
public class AsyncTaskManager extends EventDispatcher {

    public static const QUEUE_COMPLETE:String = "queueComplete";
    public static const QUEUE_ERROR:String = "queueError";
    public static const TASK_COMPLETE:String = "taskComplete";

    private var _tasks:Vector.<AsyncTask>;
    private var _currentIndex:int = 0;
    private var _isExecuting:Boolean = false;
    private var _onComplete:Function;
    private var _onError:Function;
    private var _onTaskComplete:Function;

    public function AsyncTaskManager() {
        this._tasks = new Vector.<AsyncTask>();
    }

    /**
     * 添加任务到队列
     */
    public function addTask(task:AsyncTask):AsyncTaskManager {
        this._tasks.push(task);
        return this;
    }

    /**
     * 创建并添加任务
     */
    public function createTask(name:String, executeFunc:Function):AsyncTaskManager {
        var task:AsyncTask = new AsyncTask(name, executeFunc);
        return this.addTask(task);
    }

    /**
     * 执行任务队列
     */
    public function execute(onComplete:Function = null, onError:Function = null, onTaskComplete:Function = null):void {
        if (this._isExecuting) {
            return;
        }

        if (this._tasks.length == 0) {
            if (onComplete != null) {
                onComplete();
            }
            return;
        }

        this._onComplete = onComplete;
        this._onError = onError;
        this._onTaskComplete = onTaskComplete;
        this._currentIndex = 0;
        this._isExecuting = true;

        this.executeNext();
    }

    /**
     * 执行下一个任务
     */
    private function executeNext():void {
        if (this._currentIndex >= this._tasks.length) {
            // 所有任务完成
            this._isExecuting = false;
            if (this._onComplete != null) {
                this._onComplete();
            }
            dispatchEvent(new AsyncTaskManagerEvent(QUEUE_COMPLETE));
            return;
        }

        var currentTask:AsyncTask = this._tasks[this._currentIndex];
        currentTask.addEventListener(AsyncTask.COMPLETE, this.onTaskComplete);
        currentTask.addEventListener(AsyncTask.ERROR, this.onTaskError);
        currentTask.execute();
    }

    /**
     * 任务完成处理
     */
    private function onTaskComplete(event:AsyncTaskEvent):void {
        var task:AsyncTask = event.task;
        task.removeEventListener(AsyncTask.COMPLETE, this.onTaskComplete);
        task.removeEventListener(AsyncTask.ERROR, this.onTaskError);

        // 通知单个任务完成
        if (this._onTaskComplete != null) {
            this._onTaskComplete(task);
        }
        dispatchEvent(new AsyncTaskManagerEvent(TASK_COMPLETE, task));

        this._currentIndex++;
        this.executeNext();
    }

    /**
     * 任务错误处理
     */
    private function onTaskError(event:AsyncTaskEvent):void {
        var task:AsyncTask = event.task;
        task.removeEventListener(AsyncTask.COMPLETE, this.onTaskComplete);
        task.removeEventListener(AsyncTask.ERROR, this.onTaskError);

        this._isExecuting = false;

        if (this._onError != null) {
            this._onError(task.error, task);
        }
        dispatchEvent(new AsyncTaskManagerEvent(QUEUE_ERROR, task));
    }

    /**
     * 获取当前执行的任务
     */
    public function get currentTask():AsyncTask {
        if (this._currentIndex < this._tasks.length) {
            return this._tasks[this._currentIndex];
        }
        return null;
    }

    /**
     * 获取前一个已完成任务的结果
     */
    public function getPreviousTaskResult():* {
        if (this._currentIndex > 0 && this._currentIndex <= this._tasks.length) {
            var previousTask:AsyncTask = this._tasks[this._currentIndex - 1];
            return previousTask.result;
        }
        return null;
    }

    /**
     * 获取任务总数
     */
    public function get taskCount():int {
        return this._tasks.length;
    }

    /**
     * 获取当前进度
     */
    public function get progress():Number {
        if (this._tasks.length == 0) {
            return 1.0;
        }
        return this._currentIndex / this._tasks.length;
    }

    /**
     * 是否正在执行
     */
    public function get isExecuting():Boolean {
        return this._isExecuting;
    }

    /**
     * 清空任务队列
     */
    public function clear():void {
        if (this._isExecuting) {
            return;
        }

        for each (var task:AsyncTask in this._tasks) {
            task.reset();
        }
        this._tasks.length = 0;
        this._currentIndex = 0;
    }

    /**
     * 停止执行
     */
    public function stop():void {
        this._isExecuting = false;
        if (this.currentTask != null) {
            this.currentTask.removeEventListener(AsyncTask.COMPLETE, this.onTaskComplete);
            this.currentTask.removeEventListener(AsyncTask.ERROR, this.onTaskError);
        }
    }
}
}
