/*
Class Name = CCDBRelatedLisController
Purpose = Class represent the logic of CCDB related list. User Story# S-647340, Task# T-848007
Developed By = Sushen Adhikary
Developed Date = 10-Dec-2019
Modified By = Sushen Adhikary
Modified Date = 12-Dec-2019
*/
public class CCDBRelatedLisController {       
    public List<Subscription__c> lstSubscription{get;set;} 
    
    public CCDBRelatedLisController(ApexPages.StandardController controller) {
        List<User> lstuser = [Select id,Profile.Name from User where Profile.Name In ('Genesys Portal Gold Partner','Genesys Portal Partner')];
        try {
            Account objAcct = (account)controller.getRecord();        
            
            if(objAcct != null){                
                lstSubscription =[SELECT id,Name,Offering_Type__c,Quote__r.name,Status__c,Billing_Category__c,Billing_Period__c,Subscription_Start_Date__c FROM Subscription__c WHERE Account__c= :objAcct.id and Status__c != 'Inactive' and Opportunity_LookUp__r.CreatedById IN :lstuser]; 
                System.Debug('lstSubscription=' + lstSubscription);
            }
        }
        catch(Exception ex){
            System.Debug('Exception occured from class CCDBRelatedLisController, ERROR='+ ex);
        }
    }  
}