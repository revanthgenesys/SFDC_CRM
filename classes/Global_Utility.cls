global class Global_Utility
{
    webService static String Update_Forecasted_Amt(Id OpptyId) 
    {
        List<Opportunity> opp = [Select id,Amount,License_Amount__c,Forecasted_Flag__c, Lines_of_Businesses__c,BusinessPartner__c from opportunity where id=:opptyId];

        if(opp.size()> 0)
        {
            // Exclude White Label accounts like Telstra
            Boolean blnIsHybridCustomer = false;
            if(opp[0].BusinessPartner__c != null)
                blnIsHybridCustomer = Global_Configuration_Settings__c.getOrgDefaults().Hybrid_Accounts__c.contains(String.valueOf(opp[0].BusinessPartner__c)) ? true : false;
            
            if(opp[0].Forecasted_Flag__c == false && !blnIsHybridCustomer)
            {
                Savepoint objSP = Database.setSavePoint();
                try
                {
                    opp[0].Pre_Quote_License_Amount__c = opp[0].License_Amount__c;
                    opp[0].Forecasted_Flag__c = true;
                    opp[0].Pre_Quote_Total_Amount__c   = opp[0].Amount;
                    Opp[0].Pricebook2Id = Global_Setting__c.getInstance('Standard_PriceBook').ID__c;
                    
                    delete ([Select id from OpportunityLineItem where opportunityId = :opptyId]);
                    update opp;
                }
                catch(Exception ex)
                {
                    Database.rollback(objSP);
                    return ('Error : ' + ex.getMessage());
                }
            }
        }
        return 'Success';
     }
}