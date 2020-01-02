trigger ServiceToken on Service_Token__c (after insert, after update, after delete) {

if (Trigger.IsAfter)
{
    String ServiceTokenDefinitionKey = 'ServiceTokenDefinitionKey'; 
    Cache.Org.Remove('ServiceTokenDefinitionKey');
}


}