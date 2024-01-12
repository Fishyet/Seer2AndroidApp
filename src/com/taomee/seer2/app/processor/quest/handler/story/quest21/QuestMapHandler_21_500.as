package com.taomee.seer2.app.processor.quest.handler.story.quest21 {
import com.taomee.seer2.app.processor.quest.QuestProcessor;
import com.taomee.seer2.app.processor.quest.handler.QuestMapHandler;
import com.taomee.seer2.core.quest.constant.QuestStatus;

import flash.display.MovieClip;

public class QuestMapHandler_21_500 extends QuestMapHandler {


    private var _angryAnimation:MovieClip;

    private var _leaveAnimation:MovieClip;

    public function QuestMapHandler_21_500(param1:QuestProcessor) {
        super(param1);
    }

    override public function processMapComplete():void {
        super.processMapComplete();
        if (_quest.status == QuestStatus.IN_PROGRESS) {
            if (Boolean(_quest.isStepCompete(3)) && !_quest.isStepCompete(4)) {
                this.processStep4();
            }
        }
    }

    override public function processMapDispose():void {
        super.processMapDispose();
    }

    private function processStep4():void {
    }
}
}
