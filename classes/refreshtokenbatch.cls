global class refreshtokenbatch implements Database.Batchable<sObject>,database.stateful {
global List<Puresuccess_audit_log__c> logs;
global refreshtokenbatch(){
logs = new List<Puresuccess_audit_log__c>();
}
global Database.QueryLocator start(Database.BatchableContext BC) {
string status = 'Expired';
String token= 'SELECT id,Name,Account__c,Order__c,Token_Offering_Type__c,Product_Group__c,Allocation_Type__c,Token_Status__c,Product__c,Product_Group_Item__c,Tokens__c,refresh_date__c FROM Token_Allocations__c where refresh_date__c=TODAY  and Token_Status__c!=\'' + String.escapeSingleQuotes(status)+'\'';
    system.debug('query'+token);
    return Database.getQueryLocator(token);
}
global void execute(Database.BatchableContext BC, List<Token_Allocations__c> scope) {
for(Token_Allocations__c a :scope)
{
try{
ID tid=a.id;
//refreshTokenAllocation.refreshTokenAllocationPackageMethod(tid);
}
catch (Exception e) {
                logs.add(new Puresuccess_audit_log__c(
                       Name =a.Name,
                       id__c=a.id,
                       Stacktrace__c = e.getStackTraceString(),
                       Type__c='Subscription token',
                       Errortype__c=e.getTypeName(),
                    Token_Allocation__c=a.id
                    ));
                system.debug('logs'+logs);
                throw e;
            }
}
}

global void finish(Database.BatchableContext BC) {
            system.debug('logs'+logs);
           insert logs;
}
}