global class SetQuoteAsPrimary {
	webservice static String setQuoteAsPrimary(String quoteId){
    	String result = '';
        BigMachines__Quote__c currentQuote = [SELECT Id, Name, BigMachines__Opportunity__c, Revision_No__c, BigMachines__Is_Primary__c 
                                              FROM BigMachines__Quote__c 
                                              WHERE Id = :quoteId];
        List<BigMachines__Quote__c> allAssociatedQuotes = [SELECT Id, Name, Revision_No__c, BigMachines__Is_Primary__c, 
                                                           BigMachines__Opportunity__c, BigMachines__Status__c,
                                                           Order__c, Order__r.Name, Order__r.status__c
                                                           FROM BigMachines__Quote__c 
                                                           WHERE BigMachines__Opportunity__c = :currentQuote.BigMachines__Opportunity__c];
        boolean orderAlreadyExists = false;
        for(BigMachines__Quote__c bq : allAssociatedQuotes){
            if(bq.Id != currentQuote.Id && bq.Order__c != NULL && bq.Order__r.status__c != 'Rejected'){
            	result = 'Error: Quote# ' + bq.Name + ' Revision ' + bq.Revision_No__c + ' has Order ' + bq.Order__r.Name +' associated with it, Please work with this quote.';        
                orderAlreadyExists = true;
            }
        }
        Opportunity oppToUpdate;
        if(orderAlreadyExists == false){
        	for(BigMachines__Quote__c bq : allAssociatedQuotes){
                if(bq.Id == currentQuote.Id){
                	bq.BigMachines__Is_Primary__c = true;  
                    oppToUpdate = new Opportunity(Id = bq.BigMachines__Opportunity__c, 
                                                  Quote_Quote_Status__c = bq.BigMachines__Status__c, 
                                                  Primary_Quote__c = bq.Id);
                } else {
                    bq.BigMachines__Is_Primary__c = false;    
                }
            }
            try{
                Util.Bypass_Trigger_Chk = true;
                Database.update(allAssociatedQuotes);
                Database.update(oppToUpdate);
                Util.Bypass_Trigger_Chk = false;
                result = 'Success: Quote# ' + currentQuote.Name + ' Revision ' + currentQuote.Revision_No__c + ' has been set as Primary.';
            } catch(Exception e){
                result = 'Error: Quote# ' + currentQuote.Name + ' Revision ' + currentQuote.Revision_No__c + ' could not set as Primary. Please contact IT.';
            }
        }
        return result;
    }
}