public  class PrimaryQuoteList
{
    public Id accountId {get;set;}
    public List<BigMachines__Quote__c> getListQuote()
    {
        List<BigMachines__Quote__c> ListQuote;
        ListQuote = [SELECT Id,Name,BigMachines__Opportunity__r.Name,BigMachines__Status__c,BigMachines__Opportunity__r.Opportunity_Status__c,BigMachines__Opportunity__r.Recordtype.Name  
                     FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c=true 
                     AND BigMachines__Opportunity__r.Recordtype.Name='Genesys Renewal' AND BigMachines__Status__c Not IN ('Order Accepted','Order Submitted') 
                     AND BigMachines__Opportunity__r.Opportunity_Status__c IN ('In Progress','Hypothetical','Quoted','With Customer','Sent to Customer','CoTerm Pending')
                     AND BigMachines__Account__c=:accountId];
        return ListQuote;
    }
}