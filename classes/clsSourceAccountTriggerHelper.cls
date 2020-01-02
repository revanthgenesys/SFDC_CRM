/*
Pankaj Kr Pandey
Source Account Trial Deactivated date update.
12/04/2017    
Description   : Update the Trial Deactivated with current date if Trial Status is Inactive or Converted.
*/
public without sharing class clsSourceAccountTriggerHelper {

 public static void UpdateTrialDate(Map <ID, SourceAccounts__c> newMap, Map <ID, SourceAccounts__c> oldMap) 
 {
     Set <Id> sAccId = new Set<Id>();
     List<SourceAccounts__c> srcAcc = new List<SourceAccounts__c>();
     if(oldMap != null)
     {
         for(SourceAccounts__c src : newMap.values()){
             if(src.Trial_Status__c != oldMap.get(src.Id).Trial_Status__c && (src.Trial_Status__c == 'Inactive' || src.Trial_Status__c == 'Converted'))
             {
                 sAccId.add(src.Id);
                 //src.Trial_Deactivation_Date__c = System.Today();
                 //srcAcc.add(src);
             }
         }
     } 
     if(sAccId.size()>0)
     {
         for(SourceAccounts__c sa : [Select ID, Trial_Status__c,Trial_Deactivation_Date__c from SourceAccounts__c Where Id IN: sAccId ])
         {
             sa.Trial_Deactivation_Date__c = System.Today();
             srcAcc.add(sa);
         }
         if(srcAcc.size()>0)
         {
           update srcAcc;
         }
         
     }
 }
}