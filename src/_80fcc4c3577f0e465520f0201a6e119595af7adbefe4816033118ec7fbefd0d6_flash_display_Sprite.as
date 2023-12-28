package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   public class _80fcc4c3577f0e465520f0201a6e119595af7adbefe4816033118ec7fbefd0d6_flash_display_Sprite extends Sprite
   {
       
      
      public function _80fcc4c3577f0e465520f0201a6e119595af7adbefe4816033118ec7fbefd0d6_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain.apply(null,rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain.apply(null,rest);
      }
   }
}
