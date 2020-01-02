public class CreateMultipleSupAcsForBoaController {
        
       public String boaName {get; set;}
       public String boaST {get; private set;}
       public String boaEU {get; private set;}
        public String contactSearch {get; set;}
        public List<wrapContact> addContList {get; set;}
        public String saStatus {get; set;}
        public String saAccessLevel {get; set;}
        public Id boaId {get; set;}
        
        public CreateMultipleSupAcsForBoaController (ApexPages.StandardController stdController) {
                 boaId = stdController.getId();                 
                 addContList = new List<wrapContact>();
                 
                 if (boaId != null ) {
                    List<Back_Office_Account__c> boa = [SELECT Name, End_User_Name__c, Sold_To_Name__c
                                                         FROM Back_Office_Account__c WHERE Id = :boaId];
                    boaName = boa[0].Name;
                    boaST = boa[0].Sold_To_Name__c;
                    boaEU = boa[0].End_User_Name__c;
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
                if ( boaId == null ) {
                   ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Back Office Account is required.'));
                  return;
                } 
                else if ( addContList.isEmpty() ) {
                  ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at least one Contact.'));
                  return;
                }
                else if (saStatus == null || saAccessLevel == null ) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please provide Status and Access Level for the new Support Access records.'));
                        return;
                }
      
                List<Support_Access__c> existingSAList = [SELECT Contact__c 
                                                          FROM Support_Access__c 
                                                          WHERE Back_Office_Account__c = :boaId AND Contact__c != null];
                Set<Id> existingContIdSet = new Set<Id>();
                if ( !existingSAList.isEmpty() )  {
                    for (Support_Access__c sa : existingSAList ) 
                       existingContIdSet.add(sa.Contact__c);
                }
                
                //// process selected Contact records
                Integer skippedExisting=0, insNum=0, errNum=0, totalSelected=0;
                String messg ='', errMsg='';
                
                List<Support_Access__c> insSupAccessList = new List<Support_Access__c>();                                   
                for (wrapContact cont : addContList) {                   
                    
                    if(cont.isSelected) {
                        Id contId = (Id) cont.contact.Id;
                        totalSelected++;
                        
                        if ( !existingContIdSet.isEmpty() && existingContIdSet.contains(contId) ) {
                             skippedExisting++;
                             continue;
                        }     
                        Support_Access__c sa = new Support_Access__c (Contact__c = contId,
                                                                      Back_Office_Account__c = boaId,
                                                                      Status__c = saStatus,
                                                                      SR_Access_Level__c = saAccessLevel);
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
        
      public void getContacts () {
          addContList.clear(); 
          sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
          
          if ( contactSearch == null || contactSearch == '' ) {                          
                        return;
                }
          else {                        
               String searchStr = '%' + contactSearch + '%'; 
         
               String searchQuery = 'SELECT Id, Name, Email, Account.Name, Country__c, Designated_Contact__c ' +
                                    'FROM Contact ' +                                    
                                    'WHERE Status__c = \'Active\' ' +                                       
                                    'AND Email LIKE \'' + searchStr +  '\' '  +
                                    'ORDER BY ' + sortField + ' ' + sortDir + ' NULLS LAST LIMIT 500';
                                                   
               List<Contact> contLstS = Database.query(searchQuery );
                   
               for(Contact cont :  contLstS ) {
                  addContList.add(new wrapContact (cont)); 
               } 
          }                                                                               
      } 
      
      public String sortDir {
        get  { 
                if (sortDir == null) {  
                        sortDir = 'desc'; 
                } return sortDir;
        }
        set;
    }
    
     public String sortField {
        get  { 
                if (sortField == null) {
                        sortField = 'Name'; 
                } 
                return sortField;  
        }
        set;
    } 
}