public class BoaDuplicateReportController {

        public transient List<Back_Office_Account__c> boaLst {get; private set;}
        
        public BoaDuplicateReportController()  {
           boaLst = new List<Back_Office_Account__c>();
                
              AggregateResult[] groupedResults = [SELECT Sold_To_Account__c, End_User_Account__c, Platform__c, count(name) 
                                                  FROM Back_Office_Account__c 
                                                  GROUP BY Sold_To_Account__c, End_User_Account__c, Platform__c HAVING count(name) > 1];
      
        
              for (AggregateResult ar : groupedResults)  {
                
                 List<Back_Office_Account__c> dupBoa = [SELECT ID, Name, Sold_To_Account__r.Name, End_User_Account__r.Name,
                                                              Approval_Status__c, Contract_Status__c, Support_Access_Count__c,
                                                              CreatedDate, Platform__c  
                                                       FROM Back_Office_Account__c 
                                                       WHERE Sold_To_Account__c = :(Id)ar.get('Sold_To_Account__c')
                                                        AND End_User_Account__c = :(Id)ar.get('End_User_Account__c')];
                
                
                if ( !dupBoa.isEmpty() )  {
                        boaLst.addAll(dupBoa);
                        boaLst.add( new Back_Office_Account__c() );
                }
        }
    }
}