trigger ServiceTokenDefinition on Service_Token_Definition__c (after insert, after update, after delete) {
    if (Trigger.IsAfter)
    {
        String ServiceTokenDefinitionKey = 'ServiceTokenDefinitionKey'; 
        Cache.Org.Remove('ServiceTokenDefinitionKey');
    }
}