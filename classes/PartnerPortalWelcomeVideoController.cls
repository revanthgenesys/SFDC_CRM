public class PartnerPortalWelcomeVideoController {
       
   public PartnerPortalWelcomeVideoController() {}
     
   public void updateUser() { 
        try {
           User usr = new User (Id = UserInfo.getUserId(), Block_Partner_Welcome_Video__c = true);
           update usr;
        }
        catch (Exception ex) {
            System.debug( ex.getMessage() );
        }
    }
}