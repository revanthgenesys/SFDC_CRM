// Written By Kartik . Update opp status when primary quote is change for cloud renewal ops
public class UpdateOppStatus {
  /*  public static void updateoppStatus(ID OppId)
    {
        List<Opportunity> list_Oppty = [SELECT RecordType.DeveloperName,Primary_Quote_Status__c,Opportunity_Status__c, Forecast_Status__c, AccountId,
             BusinessPartner__c, Support_Owner__c FROM Opportunity WHERE id =: OppId LIMIT 1];
        if(list_Oppty.size() > 0 && list_Oppty[0].RecordType.DeveloperName == 'Cloud_Renewal')
        {
            Opportunity currentOpp = list_Oppty[0];
            
            if(currentOpp.Primary_Quote_Status__c == 'Order Accepted')
            {
               currentOpp.Opportunity_Status__c = 'Renewed';    
            }
            else if ((currentOpp.Primary_Quote_Status__c == 'Quote In Progress')||(currentOpp.Primary_Quote_Status__c == 'Quote Approval Pending')||(currentOpp.Primary_Quote_Status__c == 'Quote Rejected')||(currentOpp.Primary_Quote_Status__c == 'Revision Pending'))
            {
            currentOpp.Opportunity_Status__c = 'In Progress';    
            }
            else if ((currentOpp.Primary_Quote_Status__c == 'Quote Approved')|| (currentOpp.Primary_Quote_Status__c == 'Order Submitted')||(currentOpp.Primary_Quote_Status__c == 'Order Rejected'))
            {
            currentOpp.Opportunity_Status__c = 'Quoted';    
            }
            system.debug('map_ToUpdate'+currentOpp.Primary_Quote_Status__c);
            update currentOpp;
        }
        
    } */
    public static void updateoppStatusFromQuote(Id quoteID)
    {
    	BigMachines__Quote__c quote = [select id,BigMachines__Opportunity__c,BigMachines__Opportunity__r.RecordType.DeveloperName,BigMachines__Status__c from BigMachines__Quote__c where id = :quoteID];	    
    	system.debug('newQuoteId'+quote);
        Opportunity opptoUpadte = new Opportunity();
        if(quote.BigMachines__Opportunity__r.RecordType.DeveloperName == 'Cloud_Renewal') {
           opptoUpadte.id = quote.BigMachines__Opportunity__c;
           opptoUpadte.Primary_Quote__c = quote.id;
        	updateoppStatus(opptoUpadte,quote.BigMachines__Status__c); 
            }
    }
    public static void updateoppStatus(Opportunity Opp,String Status)
    {
       // List<Opportunity> list_Oppty = [SELECT RecordType.DeveloperName,Primary_Quote_Status__c,Opportunity_Status__c, Forecast_Status__c, AccountId,
       //      BusinessPartner__c, Support_Owner__c FROM Opportunity WHERE id =: OppId LIMIT 1];
        Opportunity currentOpp = Opp;
            
            if(Status == 'Order Accepted')
            {
               currentOpp.Opportunity_Status__c = 'Renewed';    
            }
            else if ((Status == 'Quote In Progress')||(Status == 'Quote Approval Pending')||(Status == 'Quote Rejected')||(Status == 'Revision Pending'))
            {
            currentOpp.Opportunity_Status__c = 'In Progress';    
            }
            else if ((Status == 'Quote Approved')|| (Status == 'Order Submitted')||(Status == 'Order Rejected'))
            {
            currentOpp.Opportunity_Status__c = 'Quoted';    
            }
            system.debug('map_ToUpdate'+currentOpp.Opportunity_Status__c);
            try{
            update currentOpp;}
            catch(exception e){
            system.debug('Error-->'+ e.getMessage());
            system.debug('Error-->'+ e.getLineNumber());
        }
        
    }

}