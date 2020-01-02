global class refreshpuresuccessbatch implements Database.Batchable<sObject>,database.stateful {
list<Pure_Success_Package__c> pure = new list<Pure_Success_Package__c>();
global List<Puresuccess_audit_log__c> logs;
global refreshpuresuccessbatch(){
logs = new List<Puresuccess_audit_log__c>();
}
global Database.QueryLocator start(Database.BatchableContext BC) {
string status = 'Expired';
String pure= 'SELECT id,Account__c,Name,Order__c,Product_Group__c,Token_Status__c,Product__c,Package_Type__c,Product_Group_Item__c,Service_Contract_No__c,Tokens__c,refresh_date__c FROM Pure_Success_Package__c where refresh_date__c=TODAY and Token_Status__c!=\'' + String.escapeSingleQuotes(status)+'\'';
System.debug('records' +pure);
return Database.getQueryLocator(pure);
}
global void execute(Database.BatchableContext BC, List<Pure_Success_Package__c> scope) {
for(Pure_Success_Package__c a :scope)
{
try{
ID pid=a.id;
//refreashPureSuccesPackage pspObj = new refreashPureSuccesPackage();
//refreashPureSuccesPackage.refreashPureSuccesPackageMethod(pid);
}
catch (Exception e) {
                logs.add(new Puresuccess_audit_log__c(
                       Name =a.Name,
                       id__c=a.id,
                       Stacktrace__c = e.getStackTraceString(),
                       Type__c='Puresuccess package',
                       Errortype__c=e.getTypeName(),
                    puresuccess_package__c=a.id
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