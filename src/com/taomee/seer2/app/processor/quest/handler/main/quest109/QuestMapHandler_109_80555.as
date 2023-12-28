 
package com.taomee.seer2.app.processor.quest.handler.main.quest109
{
   import com.taomee.seer2.app.dialog.NpcDialog;
   import com.taomee.seer2.app.processor.quest.QuestProcessor;
   import com.taomee.seer2.app.processor.quest.handler.QuestMapHandler;
   import com.taomee.seer2.app.quest.QuestManager;
   import com.taomee.seer2.app.utils.MovieClipUtil;
   import com.taomee.seer2.core.scene.SceneManager;
   import com.taomee.seer2.core.scene.SceneType;
   import flash.display.MovieClip;
   
   public class QuestMapHandler_109_80555 extends QuestMapHandler
   {
       
      
      public function QuestMapHandler_109_80555(param1:QuestProcessor)
      {
         super(param1);
      }
      
      override public function processMapComplete() : void
      {
         if(!QuestManager.isAccepted(_quest.id))
         {
            return;
         }
         if(QuestManager.isComplete(_quest.id))
         {
            return;
         }
         if(QuestManager.isStepComplete(_quest.id,1) == false)
         {
            this.initStep1();
         }
      }
      
      private function initStep1() : void
      {
         var dialog0:Array;
         var mv:MovieClip = null;
         var dialog1:Array = null;
         mv = _processor.resLib.getMovieClip("sceneMv");
         mv.gotoAndStop(1);
         SceneManager.active.mapModel.front.addChild(mv);
         mv.x = 433;
         mv.y = 136;
         dialog0 = [[10,"巴蒂",[[0,"没想到队长你人脉这么好，就连大名鼎鼎的雷伊都能为你恭候啊。"]],["……"]],[400,"小赛尔",[[0,"不，我们只不过都对真相感兴趣而已。"]],["不过能让雷伊等我们，好像还真是件有面子的事？"]],[400,"小赛尔",[[0,"雷伊，久等了"]],["……"]],[477,"雷伊",[[0,"不久不久，从阿卡迪亚的雷雨云上冲刺下来，也用不了多长时间嘛。"]],["……"]],[11,"多罗",[[0,"这是飞一样的感觉……追逐雷和闪电的力量……"]],["虽然唱岔了但是还不错啊。"]],[400,"小赛尔",[[0,"雷伊，你应该记得这里吧？"]],["……"]],[477,"雷伊",[[0,"环顾四周）是啊，刚被召唤到阿卡迪亚的时候，我看到的就是这里的景象……还有一群张牙舞爪的黑衣士兵。"]],["但现在你已经与他们交战多次了。"]],[477,"雷伊",[[0,"就这么离开了我的故乡，被带到一个完全陌生的地方，我很惶恐。更何况，当时我不知被什么东西命中，瞬间变小了。我一心想回到赫尔卡，混乱中也许做出了过激的举动……"]],["根本上说，这也不是你的错啊。"]],[10,"巴蒂",[[0,"我问过伊娃博士，当时命中你的是“缩小激光”，它能够在一定时间内改变精灵的基因表达，让其变回幼年形态。但是在你这样的强者身上，它的效果就不稳定了。"]],["果然是好学的巴蒂啊。"]],[477,"雷伊",[[0,"那之后……我似乎被带到了你们的飞船，但是当我彻底清醒过来之后，我发现自己被关在容器里，周围还是那些张牙舞爪的萨伦帝国士兵。"]],["……"]],[400,"小赛尔",[[0,"除此之外，是不是还有一个破破烂烂的老铁皮？"]],["……"]],[477,"雷伊",[[0,"想了想）是的，他和你们赛尔几乎一样，但是又老又破，说话声音还很嘶哑。"]],["是斯坦因"]],[10,"巴蒂",[[0,"斯坦因，他那时候似乎在进行什么计划，后来被证实是精灵的黑化计划。"]],["真是个疯子。但是他的行为似乎并不简单，你们看。"]]];
         dialog1 = [[400,"小赛尔",[[0,"当年，斯坦因留给我了一张字条:【雷伊的到来绝对没有这么简单！多出了一个精灵所发生的事情都可能改变历史！】现在看来，他的话是这么的发人深省"]],["……"]],[11,"多罗",[[0,"改变历史！那那那我们现在这个失忆的情况难道就是改变历史？可以说是蒙对了吧。"]],["……"]],[10,"巴蒂",[[0,"这样说来，雷伊和现在的一切有着莫大的关系啊！雷伊，你怎么看？"]],["……"]],[477,"雷伊",[[0,"是我，改变了历史么？不，我怎么可能有这么大的力量？明明连自己的故乡都……"]],["雷伊你先别急，我们接着分析。"]],[400,"小赛尔",[[0,"当时我跟着萨伦帝国的小兵来到信奉广场的时候，他们说自己在“召唤破坏神”，但是他们召唤出的，却是传说中正义的象征雷伊。"]],["……"]],[477,"雷伊",[[0,"正义的象征……能被萨伦帝国——自己的敌人如此评价，还真是我的荣幸。但是，对于现在陷入了迷茫之中的你们来说，我所带来的，真的是正义吗？"]],["……"]],[400,"小赛尔",[[0,"也许，事情就是这样充满了戏剧性。雷伊，毋庸讳言，你的到来确实为阿卡迪亚带来了变数，但是你一直都坚持着自己的正义，匡扶弱小，抵抗侵略，自身的正义是无需外物来衬托的。"]],["……"]],[477,"雷伊",[[0,"赛尔，多谢你的鼓励。被作为破坏神召唤而来的我，连自己的故乡都没有办法守护的我，现在却在这里继续践行着自己的正义……"]],["说到故乡……"]],[10,"巴蒂",[[0,"雷伊，从距离上来看，你是无法用自己的力量“飞”回故乡的。不过，这里不也挺好的吗？"]],["……"]],[477,"雷伊",[[0,"是啊，这里很好。（抬头望向天空）听说，赫尔卡以前也像这颗星球一样美丽，但是后来，当赫尔卡文明随着水银湖上的最后一次落日消失在天际的时候，我却没有办法阻止。"]],["这大概是雷伊心里永恒的伤痛吧。"]],[11,"多罗",[[0,"没……没关系的，我们都听说过你的故事，毕竟……那时你也就和被缩小激光打中了那么小。"]],["……"]],[477,"雷伊",[[0,"不过那些都是过去了。我在想，既然我来到了这里，也可能长期无法回到我那荒凉的故乡，我所要做的，就是守护好这颗星球，不要让它变成另一个赫尔卡星。"]],["为此，我们将继续并肩作战。"]],[400,"小赛尔",[[0,"当年在能源之潮，你用自己的实力挽回了迷途的凯萨，并且和我们一起对抗萨伦帝国，最大限度地阻止了他们对北半球的破坏。从那以后，你和他们也交战颇多吧。"]],["……"]],[477,"雷伊",[[0,"是的，在和他们的战斗中，我也获得了一些成长。与此同时，我觉得既然是他们把我召唤到了这里，他们也必然知道怎么送我回去。但是我并没有调查出什么有用的东西。"]],["原来如此。"]],[10,"巴蒂",[[0,"那么对于萨伦帝国的实力，你有什么想法？"]],["聪明的巴蒂果然会抢我台词"]],[477,"雷伊",[[0,"萨伦帝国之中确实有几员猛将，但是从实战来看，他们似乎无心应战，并没有发挥出全部的实力。事实上，我在阿卡迪亚所交战过的最强对手是影灵兽，但是他在那之后就没有再次出现过。"]],["这么保存实力，萨伦帝国一定别有目的"]],[10,"巴蒂",[[0,"我觉得，他们与其说是“保存实力”，不如说是“外强中干”。就像……（欲言又止）"]],["你不用说了，我明白了。"]],[477,"雷伊",[[0,"事实真的如此吗？我不知道。但是既然来到了这里，我也会成为阿卡迪亚的守护者，我不会让战争将这里烧尽！"]],["……"]],[477,"雷伊",[[0,"话说到这里，赛尔，不知你们是否注意到，南半球有一片雷电反应强烈的区域？\t"]],["你这样一说，我好像确实想到了……"]],[400,"小赛尔",[[0,"南半球的区域，那里是什么地方？"]],["……"]],[477,"雷伊",[[0,"虽然那里密集的雷雨云让我感觉很舒服，但是我能感应到那个地方有着很多的电系精灵，我也不好贸然闯入他们的领地。"]],["原来如此。"]],[400,"小赛尔",[[0,"萨伦帝国的侵略部队里，有一支使用电系精灵、控制电流的部队，而那里就是这支部队的来源吧。和电有关的氏族。但是，就算是我们也没有踏足过那里。"]],["……"]],[10,"巴蒂",[[0,"而且，云海藏书里也没有关于“我们去过那里”的记载。"]],["所以那里我们真的未曾踏足。"]],[477,"雷伊",[[0,"看来我们都还有很多疑问需要解开。而正因如此，我们以后要多交换情报才好。"]],["……"]],[11,"多罗",[[0,"雷神还是那么酷啊。不愧是全民偶像！ "]],["一会男神一会偶像，多罗你莫非是来追星的？"]],[477,"雷伊",[[0,"偶像什么的，我已经不在乎了……赛尔，这是由我的能量凝结而成的【雷电结晶】，如果想找我，那就把它摔碎，我会感应到的。当然，它也可以作为备用能源。"]],["谢谢你，雷伊。"]]];
         NpcDialog.showDialogs(dialog0,function():void
         {
            NpcDialog.showDialogs(dialog1,function():void
            {
               MovieClipUtil.playMc(mv,2,mv.totalFrames,function():void
               {
                  QuestManager.completeStep(questID,1);
                  SceneManager.changeScene(SceneType.LOBBY,70);
               });
            });
         });
      }
   }
}
