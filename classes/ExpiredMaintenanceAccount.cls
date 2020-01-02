global class ExpiredMaintenanceAccount implements Database.batchable<sObject>
{

   global iterable<sObject> Start(Database.BatchableContext bc)
   {
     Date dt = Date.today().addyears(-3);
     List<Account>list_Acc = [Select id,InactivateDate__c,Status__c  from Account where Status__c =: 'Expired Maintenance' and Date_of_Offboard__c  <: dt];
     return list_Acc;
   }
   global void Execute(Database.BatchableContext bc,List<Sobject>scope){
     List<Account> list_acc = new List<Account>();

     for(sObject s : scope)
     { 
       Account a = (Account)s;
       a.Status__c = 'Inactive';
       a.InactivateDate__c = Date.Today();   
       list_acc.add(a);
     }
     update list_acc;
   }
   
   global void Finish(Database.BatchableContext bc){
   }
}