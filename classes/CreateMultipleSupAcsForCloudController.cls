public class CreateMultipleSupAcsForCloudController {
        
           public String dplName {get; set;}
       public String dplST {get; private set;}
       public String dplEU {get; private set;}
        public String contactSearch {get; set;}
        public List<wrapContact> addContList {get; set;}
        public List<Contact> contList;
        public String saStatus {get; set;}
        public String saAccessLevel {get; set;}
        public Id deplId {get; set;}
        
        public CreateMultipleSupAcsForCloudController (ApexPages.StandardController stdController) {
                 deplId = stdController.getId();                 
                 addContList = new List<wrapContact>();
                 
                 if (deplId != null ) {
                    List<Cloud_Deployment__c> deplmt = [SELECT Name, Account__c, Sold_To_Account__c
                                                         FROM Cloud_Deployment__c WHERE Id = :deplId];
                    dplName = deplmt[0].Name;
                    dplST = deplmt[0].Sold_To_Account__c;
                    dplEU = deplmt[0].Account__c;
                 }
        }
        
        public void getContacts () {
                addContList.clear(); 
            
                if ( contactSearch == null || contactSearch == '' ) {                          
                        return;
                }
                else {                        
                        String searchStr = '%' + contactSearch + '%'; 
           
                        List<Contact> contLst = [SELECT Id, Name, Email, Account.Name, Country__c, Designated_Contact__c
                                                 FROM Contact                                     
                                                 WHERE Status__c = 'Active'                                         
                                                 AND Email LIKE :searchStr                                     
                                                 ORDER BY Name LIMIT 500];                     
                         
                         for(Contact cont :  contLst ){
                            addContList.add(new wrapContact (cont));  
                                                      
                        }
                }               
        }
        
        public class wrapContact {
            public Contact contact {get; set;}
            public Boolean isSelected {get; set;}
 
            public wrapContact(Contact c) {
                contact = c;
                isSelected = false;
            }
        }
        
        public void addSupportAccessRecords() {
                if ( deplId == null ) {
                   ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Cloud Deployment is required.'));
                  return;
                } 
                else if ( addContList.isEmpty() ) {
                  ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at lease one Contact.'));
                  return;
                }
                else if (saStatus == null || saAccessLevel == null ) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please provide Status and Access Level for the new Support Access records.'));
                        return;
                }
      
                List<Support_Access_Cloud__c> existingSAList = [SELECT Contact__c 
                                                          FROM Support_Access_Cloud__c 
                                                          WHERE Cloud_Deployment__c = :deplId AND Contact__c != null];
                Set<Id> existingContIdSet = new Set<Id>();
                if ( !existingSAList.isEmpty() )  {
                    for (Support_Access_Cloud__c sa : existingSAList ) 
                       existingContIdSet.add(sa.Contact__c);
                }
                
                //// process selected Contact records
                Integer skippedExisting=0, insNum=0, errNum=0, totalSelected=0;
                String messg ='', errMsg='';
                
                List<Support_Access_Cloud__c> insSupAccessList = new List<Support_Access_Cloud__c>();                                   
                for (wrapContact cont : addContList) {                   
                    
                    if(cont.isSelected) {
                        Id contId = (Id) cont.contact.Id;
                        totalSelected++;
                        
                        if ( !existingContIdSet.isEmpty() && existingContIdSet.contains(contId) ) {
                             skippedExisting++;
                             continue;
                        }     
                        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = contId,
                                                                      Cloud_Deployment__c = deplId,
                                                                      Access_Status__c = saStatus,
                                                                      Access_Level__c = saAccessLevel);
                        insSupAccessList.add(sa);
                    }
                }
                
                if ( !insSupAccessList.isEmpty() ) {
                        List<Database.SaveResult> insResults = Database.insert(insSupAccessList, false);                                                                          
                         for (Database.SaveResult result : insResults) {
                                   if (result.isSuccess()) 
                                          insNum++;
                                   else {
                                         errNum++;
                                         errMsg += result.getErrors()[0].getMessage() + '\n';
                                   }
                      }
                }
                messg = 'Out of total ' + totalSelected + ' Contact selected records:  ';
                messg += insNum + ' Support Access records added successfully; ';              
                if ( skippedExisting > 0 )
                     messg += skippedExisting + ' found existing;  ';
                                             
               if ( errNum > 0 )
                   messg += errNum + ' Failed due to error';
                         
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, messg));                
                                         
        }
        

}