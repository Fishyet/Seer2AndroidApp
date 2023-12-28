package ui
{
   import flash.text.TextField;
   
   public class EnterText extends TextField
   {
       
      
      private var _sw:int;
      
      private var _sh:int;
      
      public function EnterText(param1:int, param2:int)
      {
         super();
         this._sw = param1;
         this._sh = param2;
         selectable = false;
      }
      
      public function setText(param1:String) : void
      {
         htmlText = "<font size=\'18\'>" + param1 + "</font>";
         width = textWidth + 5;
         height = textHeight + 5;
         x = (this._sw - textWidth) / 2;
         y = (this._sh - textHeight) / 2;
      }
   }
}
