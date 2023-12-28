package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   public class _3812cfdc3dc0f07893ccb94205bd1268a12fc92765fcb304ec70e189d21da26f_flash_display_Sprite extends Sprite
   {
       
      
      public function _3812cfdc3dc0f07893ccb94205bd1268a12fc92765fcb304ec70e189d21da26f_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain(rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain(rest);
      }
   }
}
