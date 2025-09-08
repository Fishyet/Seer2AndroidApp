package async {
import flash.events.Event;

/**
 * 异步任务事件类
 */
public class AsyncTaskEvent extends Event {

    private var _task:AsyncTask;

    public function AsyncTaskEvent(type:String, task:AsyncTask, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._task = task;
    }

    public function get task():AsyncTask {
        return this._task;
    }

    override public function clone():Event {
        return new AsyncTaskEvent(type, this._task, bubbles, cancelable);
    }

    override public function toString():String {
        return formatToString("AsyncTaskEvent", "type", "task", "bubbles", "cancelable");
    }
}
}
