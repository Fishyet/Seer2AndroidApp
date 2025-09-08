package async {
import flash.events.Event;

/**
 * 异步任务管理器事件类
 */
public class AsyncTaskManagerEvent extends Event {

    private var _task:AsyncTask;

    public function AsyncTaskManagerEvent(type:String, task:AsyncTask = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._task = task;
    }

    public function get task():AsyncTask {
        return this._task;
    }

    override public function clone():Event {
        return new AsyncTaskManagerEvent(type, this._task, bubbles, cancelable);
    }

    override public function toString():String {
        return formatToString("AsyncTaskManagerEvent", "type", "task", "bubbles", "cancelable");
    }
}
}
