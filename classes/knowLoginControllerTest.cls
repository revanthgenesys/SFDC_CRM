@IsTest(SeeAllData=true)
private class knowLoginControllerTest {

    static testMethod void validateCommunitymethods() {
        knowLoginController gcLc = new knowLoginController();
        gcLc.forwardToAuthPage();
        gcLc.loginCheck();
        gcLc.saveRecord();
        gcLc.upload(); 
        gcLc.advisorUser =null;
        gcLc.csmUser =null;
        gcLc.isPartner=false;
        gcLc.searchTxt=null;
        gcLc.PureConnectCookie='f';
        gcLc.PureEngageCookie='c';
        gcLc.isaccessableToKnowledge=false;
        gcLc.savePureEngageState();
        gcLc.savePureConnectState();
        gcLc.savePureCloudState();
      	gcLc.MyProflieName=null;
    } 
    
    static testMethod void validateCommunitymethodsGKNUser() {
        
        list<user> testUstlist = [Select Id,Name,Contact.Account.AccountOfferingTypes__c from User where isActive=true AND 
                            Profile.Name = 'Genesys Portal End User' 
                            limit 1000];
                            
         user runAsUserRec = new User();
         
         for(User usrRec:testUstlist){
             if(usrRec.Contact.Account.AccountOfferingTypes__c != null){
                 runAsUserRec  = usrRec;
                 break;
             }
         }
        
        System.runAs(runAsUserRec){
            knowLoginController gcLc = new knowLoginController();
            gcLc.forwardToAuthPage();
            gcLc.loginCheck();
            gcLc.saveRecord();
            gcLc.upload(); 
            gcLc.advisorUser =null;
            gcLc.csmUser =null;
            gcLc.isPartner=false;
            gcLc.searchTxt=null;
            gcLc.PureConnectCookie='f';
            gcLc.PureEngageCookie='c';
            gcLc.isaccessableToKnowledge=false;
            gcLc.savePureEngageState();
            gcLc.savePureConnectState();
            gcLc.savePureCloudState();
            gcLc.MyProflieName=null;
            gcLc.getperms();
            
            gcLc.ispureCld = false;
            gcLc.ispureEngCld = false; 
            gcLc.ispureEngPrem = false; 
            gcLc.ispureCnctCld = false;  
            gcLc.isPartnerUser();
        }
    }  
    
    /*
    static testMethod void validateCommunitymethodsGKNUserPureCloud() {
        
        list<user> testUstlist = [Select Id,Name,Contact.Account.AccountOfferingTypes__c from User where isActive=true AND 
                            Profile.Name = 'Genesys Portal End User' 
                            limit 1000];
                            
         user runAsUserRec = new User();
         
         for(User usrRec:testUstlist){
             if(usrRec.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureCloud')){
                 runAsUserRec  = usrRec;
                 break;
             }
         }
        
        System.runAs(runAsUserRec){
            knowLoginController gcLc = new knowLoginController();
            gcLc.forwardToAuthPage();
            gcLc.loginCheck();
            gcLc.saveRecord();
            gcLc.upload(); 
            gcLc.advisorUser =null;
            gcLc.csmUser =null;
            gcLc.isPartner=false;
            gcLc.searchTxt=null;
            gcLc.PureConnectCookie='f';
            gcLc.csmUserName = 'test';
            gcLc.advisorUserName = 'test';
            gcLc.PureEngageCookie='c';
            gcLc.isaccessableToKnowledge=false;
            gcLc.savePureEngageState();
            gcLc.savePureConnectState();
            gcLc.savePureCloudState();
            gcLc.MyProflieName=null;
            gcLc.getperms();
        }
    }  
    
    static testMethod void validateCommunitymethodsGKNUserPureConnect() {
        
        list<user> testUstlist = [Select Id,Name,Contact.Account.AccountOfferingTypes__c from User where isActive=true AND 
                            Profile.Name = 'Genesys Portal End User' 
                            limit 1000];
                            
         user runAsUserRec = new User();
         
         for(User usrRec:testUstlist){
             if(usrRec.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureEngage')){
                 runAsUserRec  = usrRec;
                 break;
             }
         }
        
        System.runAs(runAsUserRec){
            knowLoginController gcLc = new knowLoginController();
            gcLc.forwardToAuthPage();
            gcLc.loginCheck();
            gcLc.saveRecord();
            gcLc.upload(); 
            gcLc.advisorUser =null;
            gcLc.csmUser =null;
            gcLc.isPartner=false;
            gcLc.searchTxt=null;
            gcLc.PureConnectCookie='f';
            gcLc.PureEngageCookie='c';
            gcLc.isaccessableToKnowledge=false;
            gcLc.savePureEngageState();
            gcLc.savePureConnectState();
            gcLc.savePureCloudState();
            gcLc.MyProflieName=null;
            gcLc.getperms();
        }
    }  
    
    static testMethod void validateCommunitymethodsGKNUserPureEngage() {
        
        list<user> testUstlist = [Select Id,Name,Contact.Account.AccountOfferingTypes__c from User where isActive=true AND 
                            Profile.Name = 'Genesys Portal End User' 
                            limit 1000];
                            
         user runAsUserRec = new User();
         
         for(User usrRec:testUstlist){
             if(usrRec.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureConnect')){
                 runAsUserRec  = usrRec;
                 break;
             }
         }
        
        System.runAs(runAsUserRec){
            knowLoginController gcLc = new knowLoginController();
            gcLc.forwardToAuthPage();
            gcLc.loginCheck();
            gcLc.saveRecord();
            gcLc.upload(); 
            gcLc.advisorUser =null;
            gcLc.csmUser =null;
            gcLc.isPartner=false;
            gcLc.searchTxt=null;
            gcLc.PureConnectCookie='f';
            gcLc.PureEngageCookie='c';
            gcLc.isaccessableToKnowledge=false;
            gcLc.savePureEngageState();
            gcLc.savePureConnectState();
            gcLc.savePureCloudState();
            gcLc.MyProflieName=null;
            gcLc.getperms();
        }
    }  
*/
    
    static testMethod void validateCommunitymethodsPortalUser() {
		list<user> testUstlist = [Select Id,Name,Contact.Account.AccountOfferingTypes__c from User where isActive=true AND 
                            Profile.Name = 'Genesys Portal Partner' 
                            limit 1000];
                            
         user runAsUserRec = new User();
         
         for(User usrRec:testUstlist){
             if(usrRec.Contact.Account.AccountOfferingTypes__c != null){
                 runAsUserRec  = usrRec;
                 break;
             }
         }
        
        System.runAs(runAsUserRec){
            knowLoginController gcLc = new knowLoginController();
            gcLc.forwardToAuthPage();
            gcLc.loginCheck();
            gcLc.saveRecord();
            gcLc.upload(); 
            gcLc.advisorUser = null;
            gcLc.csmUser = null;
            gcLc.isPartner = true;
            gcLc.searchTxt = null;
            gcLc.PureConnectCookie = 'f';
            gcLc.PureEngageCookie = 'c';
            gcLc.isaccessableToKnowledge = false;
            gcLc.savePureEngageState();
            gcLc.savePureConnectState();
            gcLc.savePureCloudState();
            gcLc.MyProflieName = null;
            gcLc.getperms();
        
        	gcLc.ispureCld = true;
            gcLc.ispureEngCld = false; 
            gcLc.ispureEngPrem = false; 
            gcLc.ispureCnctCld = false;  
            gcLc.isPartnerUser();
        }
    }  
}