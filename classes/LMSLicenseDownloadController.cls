public class LMSLicenseDownloadController {
    public License_Request_Log__c licenseRequest {get; set;}
    public String fileName {get; set;}
    
    public LMSLicenseDownloadController(){
        boolean sipProduct = false;
        String RequestLogId = ApexPages.currentPage().getParameters().get('id');
            licenseRequest = [SELECT Id, Name, Requested_By__c, Requested_By__r.Name, Generation_Date__c, Expiration_Date__c, SystemType1__c, 
                                            Product_Type__c, MailConnector1__c, License_Type__c, License_Text__c, Active__c, Product_Line__c, Product_Line__r.SIP_Product__c,
                                            Machine_Name__c, MAC_Address__c, End_User__c, End_User__r.Name, Sold_To__c, Deactivated_By__c, Deactivated_Date__c,
                                            Install_Site__r.Name 
                                        FROM License_Request_Log__c  
                                        WHERE id = :RequestLogId];
            fileName =  licenseRequest.MAC_Address__c;
            sipProduct = licenseRequest.Product_Line__r.SIP_Product__c;
            
        if(fileName.contains('|')){
            fileName = fileName.substring(0,fileName.indexOf('|')); 
        } 
        if(sipProduct){
            fileName = fileName + '.i3lic';
        } else {
            fileName = fileName + '.I3Lic';
        }
    }
}