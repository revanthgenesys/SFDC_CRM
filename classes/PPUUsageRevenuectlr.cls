global with Sharing class PPUUsageRevenuectlr {
  
  
  webservice static String processPPU(String oppId){
     
     try{
         List<Opportunity> lstOpp = [Select Id,Name, AccountId,Primary_Line_of_Business__c,ACV_Subscription_Only__c,Total_Annual_Contract_Value__c,Monthly_Commitment__c, Lines_of_Businesses__c, Offering_Detail__c, CloseDate,Term_Commitment__c,currencyisocode  from Opportunity where Id=: oppId];
         List<RecordType> rtType = [Select Id from RecordType where SObjectType = 'Opportunity' and DeveloperName = :'PPU_Usage_Revenue_Record_Type'];
         integer childcount = [select count() from opportunity where ParentOpportunity__c =: oppId];
         
         childcount +=1;
         
         Opportunity opp = new Opportunity();
         if(rtType.size() > 0){
             if(lstOpp.size() > 0){
                 opp.AccountId = lstOpp[0].AccountId;
                 opp.RecordTypeId = rtType[0].Id;
                 opp.Name = lstOpp[0].Name + ' - ' + childcount;
                 opp.StageName = '1.Understand Needs';
                 opp.ForecastStatus__c = '5.Pipeline';
                 opp.ParentOpportunity__c = oppId;
                 opp.ACV_Subscription_Only__c = lstOpp[0].ACV_Subscription_Only__c;
                 opp.Total_Annual_Contract_Value__c = lstOpp[0].Total_Annual_Contract_Value__c;
                 opp.Monthly_Commitment__c = lstOpp[0].Monthly_Commitment__c;
                 opp.Lines_of_Businesses__c= lstOpp[0].Lines_of_Businesses__c;
                 opp.Primary_Line_of_Business__c	 = lstOpp[0].Primary_Line_of_Business__c	;
                 opp.Offering_Detail__c = lstOpp[0].Offering_Detail__c;
                 opp.CloseDate = lstopp[0].CloseDate;
                 opp.Term_Commitment__c = lstopp[0].Term_Commitment__c;
                 opp.currencyisocode = lstopp[0].currencyisocode;
                 //opp.Term_Length__c = lstopp[0].Term_Commitment__c;
                 insert opp;
              }
         
             return opp.Id;
         }else{
             return 'PPU Usage Revenue record Type not found.';
         }
     }Catch(Exception ex){
         return ex.getMessage();
         //return 'There was a problem creating the PPU Usage Revenue Opportunity.';
     }
  }
}