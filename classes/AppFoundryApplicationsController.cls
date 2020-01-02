// Test Class - MarketplaceApplicationController_Test
public class AppFoundryApplicationsController {
    
    public List<Technology_Market_place_Application__c> afApplications {get; set;}
    public User currentUser {get; set;}
    public String selectedApplicationId {get; set;}
    
    public AppFoundryApplicationsController(){
    	currentUser = [SELECT id, Name, ContactId, Contact.Account.Name, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()]; 	    
        afApplications = [SELECT id, Name, Partner_Account__c, Partner_Account__r.Name, Company_Name__c, Date_Completed__c, Solution_Name__c, Status__c, CreatedDate, CreatedBy.Name
                          FROM Technology_Market_place_Application__c 
                          WHERE Partner_Account__c = :currentUser.Contact.AccountId];
    }
    
    public PageReference displayDecision(){
        if(afApplications.isEmpty()){
	        PageReference pg = Page.MarketPlaceApplication;
            return pg;
        } else {
            return null;
        } 
    }
    
    public Boolean getIsApplicationPending(){
        currentUser = [SELECT id, Name, ContactId, Contact.Account.Name, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Technology_Market_place_Application__c>  pendingAFApplications = [SELECT id, Status__c 
                                                                               FROM Technology_Market_place_Application__c 
                                                                               WHERE Partner_Account__c = :currentUser.Contact.AccountId AND Status__c != 'Approved'];
        if(pendingAFApplications.isEmpty())
            return false;
        else
            return true;
    }
    
    public PageReference newApplication(){
		return (new PageReference('/partner/MarketplaceApplication'));
    }
    public PageReference viewApplication(){
        //System.debug('selectedApplicationId = ' + selectedApplicationId);
		return (new PageReference('/partner/AppFoundry_ApplicationDetail?id=' + selectedApplicationId));
    }
    public PageReference editApplication(){
        //System.debug('selectedApplicationId = ' + selectedApplicationId);
		return (new PageReference('/partner/MarketplaceApplication?id=' + selectedApplicationId));
    }
}