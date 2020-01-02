public class SubscriptionDownloadController {
    public Subscription_Request_Log__c licenseRequest {get; set;}
    public String fileName {get; set;}
    
    public SubscriptionDownloadController(){
        String RequestLogId = ApexPages.currentPage().getParameters().get('id');
            licenseRequest = [SELECT Id, Name, Requested_By__c, Requested_By__r.Name, Generation_Date__c, Expiration_Date__c, System_Type__c, 
                                            Mail_Connector__c, License_Type__c, License_Text__c, isActive__c, Product_Line__c,
                                            Machine_Name__c, MAC_Address__c, End_User__c, End_User__r.Name
                                        FROM Subscription_Request_Log__c  
                                        WHERE id = :RequestLogId];
            fileName =  licenseRequest.MAC_Address__c;
            
        if(fileName.contains('|')){
            fileName = fileName.substring(0,fileName.indexOf('|')); 
        } 
      
            fileName = fileName + '.I3Lic';
      
    }
}