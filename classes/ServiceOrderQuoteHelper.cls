public with sharing class ServiceOrderQuoteHelper 
{
    public static BigMachines__Quote__c getQuote(Id quoteId)
    {
        BigMachines__Quote__c quote;
        if(quoteId == null)
        {
            quote = new BigMachines__Quote__c();
            quote.Quote_Created_Date__c = System.today();
        }
        else
            quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));

        return quote;
    }

    public static Opportunity getOpp(Id oppId)
    {
        String strQuery = 'SELECT Id ';
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Opportunity.fieldSets.getMap().get('GetOpp').getFields();
        
        for(Schema.FieldSetMember f : fields )
            strQuery += ', ' + f.getFieldPath() ;
        
        strQuery += ' FROM Opportunity WHERE id = \'' + oppId + '\'';        
        Opportunity objOppty = Database.Query(strQuery);
        return objOppty;
    }
    
    public static BigMachines__Quote__c saveQuote(BigMachines__Quote__c quote, Opportunity opp)
    {
        List<BigMachines__Quote__c> existingQuotes = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: opp.id];
        if(existingQuotes.isEmpty())
        {
            quote.Is_Business_Primary__c = true;
            quote.BigMachines__Is_Primary__c = true;
        }
        insert quote;
        quote = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quote.id];
        quote.Name = quote.Quote_Number__c;
        quote.BigMachines__Status__c = 'Quote In Progress';
        quote.End_User_ID__c = opp.AccountId;
        
        if(opp.Direct_Sales__c)
            quote.Sold_To_Name__c = quote.End_User_ID__c;
        else
            quote.Sold_To_Name__c = opp.BusinessPartner__c;
            
        quote.Selling_Entity__c = opp.Country_Selling_Entity__c;
        quote.Expiration_Date__c = Date.today() + 90;
        List<Account> soldToAccount = [SELECT Street1__c, Street2__c, Street3__c, ZipCode__c, City__c, StateProvince__c, 
                                        Business_Country__c, Phone FROM Account WHERE id =: quote.Sold_To_Name__c];
        if(!soldToAccount.isEmpty())
        {
            quote.Sold_To_Address__c = soldToAccount[0].Street1__c;
            quote.Sold_To_Zip_Code__c = soldToAccount[0].ZipCode__c;
            quote.Sold_To_State__c = soldToAccount[0].StateProvince__c;
            quote.Sold_To_Country__c = soldToAccount[0].Business_Country__c;
            quote.Sold_To_City__c = soldToAccount[0].City__c;
            quote.Sold_To_Phone__c = soldToAccount[0].Phone;
        }
        update quote;
        return quote;
    }
    
    public static String cloneQuote(BigMachines__Quote__c quote)
    {
        String cloneQuoteId = cloneQuote(quote, false);
        return cloneQuoteId;
    }
    
    public static String cloneQuote(BigMachines__Quote__c quote, Boolean isRevise)
    {
        System.debug('NKC debug End_User_ID__c ['+quote.End_User_ID__c+']');
        List<Account> soldToAccount = [SELECT Street1__c, Street2__c, Street3__c, ZipCode__c, City__c, StateProvince__c, Business_Country__c, Phone 
        FROM Account WHERE id =: quote.Sold_To_Name__c];
        BigMachines__Quote__c quoteCopy = quote.clone(false, true);
        quoteCopy.BigMachines__Transaction_Id__c = null;
        quoteCopy.Approved_ACV__c = null;
        quoteCopy.Quote_Created_Date__c = System.today();
        quoteCopy.Is_Business_Primary__c = false;
        quoteCopy.BigMachines__Is_Primary__c = false;
        quoteCopy.Quote_Cloned_Revised__c = quote.Id;
        if(!soldToAccount.isEmpty())
        {
            quoteCopy.Sold_To_Address__c = soldToAccount[0].Street1__c;
            quoteCopy.Sold_To_Zip_Code__c = soldToAccount[0].ZipCode__c;
            quoteCopy.Sold_To_State__c = soldToAccount[0].StateProvince__c;
            quoteCopy.Sold_To_Country__c = soldToAccount[0].Business_Country__c;
            quoteCopy.Sold_To_City__c = soldToAccount[0].City__c;
            quoteCopy.Sold_To_Phone__c = soldToAccount[0].Phone;
        }
        insert quoteCopy;
        if(!isRevise)
        {
            quoteCopy = [SELECT End_User_ID__c,Quote_Number__c,BigMachines__Opportunity__r.AccountId,
                            BigMachines__Opportunity__r.BusinessPartner__c,BigMachines__Opportunity__r.Direct_Sales__c
                         FROM BigMachines__Quote__c WHERE id =: quoteCopy.id];
            
            quoteCopy.Name = quoteCopy.Quote_Number__c;
            
            // For cloned quotes determine Sold To values based on latest values on Opportunity
            if(quoteCopy.BigMachines__Opportunity__r.Direct_Sales__c)
                quoteCopy.Sold_To_Name__c = quoteCopy.BigMachines__Opportunity__r.AccountId;
            else
                quoteCopy.Sold_To_Name__c = quoteCopy.BigMachines__Opportunity__r.BusinessPartner__c;
        }
        quoteCopy.BigMachines__Status__c = 'Quote In Progress';
        if(isRevise)
        {
            if(quote.Revision_No__c == null)
                quoteCopy.Revision_No__c = 2;
            else
                quoteCopy.Revision_No__c = quote.Revision_No__c + 1;
        }            
        update quoteCopy;            
        
        List<BigMachines__Quote_Product__c> quoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quote.id));
        List<BigMachines__Quote_Product__c> quoteProductsCopy = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts)
        {
            BigMachines__Quote_Product__c quoteProductCopy = eachQuoteProduct.clone(false, true);
            quoteProductCopy.BigMachines__Quote__c = quoteCopy.id;
            quoteProductCopy.BigMachines__External_Id__c  = null;
            quoteProductsCopy.add(quoteProductCopy);
        }
        List<Quote_Service_Contracts__c> quoteServicesContracts = [SELECT Service_Contract__c, Service_Contract_ID__c, Quote__c FROM Quote_Service_Contracts__c WHERE Quote__c =: quote.id];
        List<Quote_Service_Contracts__c> quoteServicesContractsCopy = new List<Quote_Service_Contracts__c>();
        for(Quote_Service_Contracts__c eachQuoteServiceContract : quoteServicesContracts)
        {
            Quote_Service_Contracts__c newQSC = new Quote_Service_Contracts__c();
            
            if(eachQuoteServiceContract.Service_Contract__c == null)
                continue;
            
            newQSC.Quote__c = quoteCopy.id;
            newQSC.Service_Contract__c = eachQuoteServiceContract.Service_Contract__c;
            newQSC.Service_Contract_ID__c = eachQuoteServiceContract.Service_Contract_ID__c;
            quoteServicesContractsCopy.add(newQSC);
        }    
        insert quoteProductsCopy;
        insert quoteServicesContractsCopy;            
        return quoteCopy.id;
    }
    
    public static string prepareQuoteQuery(Id quoteId)    
    {
        String strQuery = 'SELECT ';
        List<Schema.FieldSetMember> fields = Schema.SObjectType.BigMachines__Quote__c.fieldSets.getMap().get('Service_Order_Quote').getFields();
        
        for(Schema.FieldSetMember f : fields)
            strQuery += f.getFieldPath() + ', ';
        
        strQuery += ' Id FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuery;
    }
    
    public static string prepareQuoteProductQuery(Id quoteId)
    {
        String strQuery = 'SELECT ';
        List<Schema.FieldSetMember> fields = Schema.SObjectType.BigMachines__Quote_Product__c.fieldSets.getMap().get('Service_Order_Quote_Product').getFields();
        
        for(Schema.FieldSetMember f : fields)
            strQuery += f.getFieldPath() + ', ';
        
        strQuery += ' Id FROM BigMachines__Quote_Product__c WHERE BigMachines__Product__r.Type__c != \'Genesys Care\' AND BigMachines__Quote__c = \'' + quoteId + '\'';
        return strQuery;
    }
}