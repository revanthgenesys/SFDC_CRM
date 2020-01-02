public class BoaRelatedCasesController {
    
     public transient List<Case> caseList {get; private set;} 
     Id stId;
     Id euId;
        
     public BoaRelatedCasesController (ApexPages.StandardController stdController) {
         Id boaId = stdController.getId();  
         
         if ( boaId != null ) {
             List<Back_Office_Account__c> boaLst = [SELECT Sold_To_Account__c, End_User_Account__c
                                                    FROM Back_Office_Account__c
                                                    WHERE Id = :boaId]; 
                                              
            if ( !boaLst.isEmpty() )  {
                stId = boaLst[0].Sold_To_Account__c;
                euId = boaLst[0].End_User_Account__c;
            }
         }         
     }
        
     public void getNonClosedRelCases() {
          if (stId != null && euId != null)  {
            
            caseList = [SELECT Id, CaseNumber, Subject, Priority, CreatedDate, ClosedDate,
                               Status, Owner.Name, RecordType.Name, Contact.Name
                        FROM Case
                        WHERE End_User_Account__c = :euId
                          AND Sold_To_Account__c = :stId
                          AND Status != 'Closed'
                        ORDER BY CreatedDate DESC LIMIT 500];
          }              
     }
     
     public void getClosedRelCases() {
          if (stId != null && euId != null)  {
            
            caseList = [SELECT Id, CaseNumber, Subject, Priority, CreatedDate, ClosedDate,
                               Status, Owner.Name, RecordType.Name, Contact.Name
                        FROM Case
                        WHERE End_User_Account__c = :euId
                          AND Sold_To_Account__c = :stId
                          AND Status = 'Closed'
                        ORDER BY CreatedDate DESC LIMIT 500];
          }            
     }

}