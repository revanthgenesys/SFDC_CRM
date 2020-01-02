public with sharing class QuoteSplitDrop {
    public static Boolean isQuoteSplitDrop = false;
    BigMachines__Quote__c currentQuote;  
    
    public QuoteSplitDrop(ApexPages.StandardController stdController) {
        currentQuote = (BigMachines__Quote__c)stdController.getRecord();
        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();
        if(currentQuote != null)
            quoteList.add(currentQuote);
    }
    
    public PageReference submit() {
        createDropSplit(currentQuote.id,'Split');      
        return null;
    }  
    
    //Naresh    02/04/14    Called from Order_After trigger 
    public static void createRetired(Order__c currentOrder, Order__c oldOrder){
        if(currentOrder.Status__c == 'Completed' && oldOrder.Status__c != 'Completed' && currentOrder.Quote__c != null){
            BigMachines__Quote__c currentQuote = [SELECT id, LRA_Uplift__c, Partner_Direct__c FROM BigMachines__Quote__c WHERE id =: currentOrder.Quote__c];
            createDropSplit(currentQuote.id,  'Retired');
        }
    }
    
    @future
    public static void createDropSplit(String currentQuoteId, String status) {
        System.debug('NKC debug status ['+status+']');
        //Retired should only execute if order status is completed.
        isQuoteSplitDrop = true;
        String soldToName = null;
        String endUserName = null;
        String status1 = null;
        String status2 = null;
        if(status =='Split') {
            status1 = 'Split';
            status2 = 'QuantitySplit';
        }
        if(status =='Drop') {
            status1 = 'Drop';
            status2 = 'DropQuantity';
        }
        if(status =='Retired') {
            status1 = 'Retired';
            status2 = 'RetiredQuantity';
        }
        if(status =='Shelved') {
            status1 = 'Shelved';
            status2 = 'ShelvedQuantity';
        }
        if(status =='Downsize') {
            status1 = 'Downsize';
            status2 = 'DownsizeQuantity';
        }
        
        boolean splitDrop = false;
        BigMachines__Quote__c quote = [SELECT id, Name, Sold_To_Name__c, Sold_To_Name__r.Name,
            Split_Status__c, Drop_Status__c, Retire_Status__c,Downsize_Status__c,Shelve_Status__c,
            End_User_ID__c, End_User_ID__r.Name,BigMachines__Description__c,
            BigMachines__Pricebook_Id__c,Support_Owner__c,Support_Owner__r.Name, BigMachines__Opportunity__r.id,
            LRA_Uplift__c, Partner_Direct__c, LDA_Uplift__c,
            (SELECT Id FROM Opportunities1__r WHERE Name LIKE :(status + '%'))
            FROM BigMachines__Quote__c  WHERE id =: currentQuoteId];
    
        List <BigMachines__Quote_Product__c> quoteProduct = new List<BigMachines__Quote_Product__c>();
        quoteProduct = [SELECT CurrencyIsoCode, BigMachines__Product__c, Comment__c, Original_Qty__c, 
            Current_Qty__c,BigMachines__Quantity__c,BigMachines__Sales_Price__c,Revised_Net_From_Contract_Line__c,
            Original_Net_License_Value__c,Revised_Net_License_Value__c,Maintenance_Due__c,Service_Contract_Line_ID__c,
            // To add LRA Uplift as well to previous Annualized Maint. Amount for Service Contract for Drop/Split/Retired
            BigMachines__Product__r.LRA_Uplift_Not_Applicable__c,BigMachines__Product__r.LDA_Uplift_Not_Applicable__c
            FROM BigMachines__Quote_Product__c 
            WHERE (Contract_Line_Update_Status__c = :status1 OR Contract_Line_Update_Status__c =:status2)
            AND BigMachines__Quote__c =: currentQuoteId];      
        
        if(status == 'Split' && !quote.Split_Status__c)
            splitDrop = true;
  
        else if(status == 'Drop' && !quote.Drop_Status__c)
            splitDrop = true;
        
        else if(status == 'Retired' && !quote.Retire_Status__c)
            splitDrop = true;
            
        else if(status == 'Shelved' && !quote.Shelve_Status__c)
            splitDrop = true;
            
        else if(status == 'Downsize' && !quote.Downsize_Status__c)
            splitDrop = true;
          
        if(!quoteProduct.isEmpty() && splitDrop && quote.Opportunities1__r.size() == 0) {
            List<ServiceContract> scList = new List <ServiceContract>();  
            String tempOpp = quote.BigMachines__Opportunity__r.id;
         
            String soql = CloneUtil.getCreatableFieldsSOQL('Opportunity','id=\''+tempOpp +'\'');
            Opportunity parentOpp = (Opportunity)Database.query(soql);
            Opportunity  childOpp = parentOpp.clone(false, true);
            childOpp.Service_Contract_Siebel_ID__c = '';
            
            //childOpp.Name = status + ' ' + quote.Name + ' ' + childOpp.Name;
            String oppName = status + ' ' + quote.Name + ' ' + childOpp.Name;
			if(oppName.length() > 120){
               oppName = oppName.substring(0,120); 
            }            
            childOpp.Name = oppName;
            childOpp.Opportunity_Status__c = status;
            
            if(childOpp.Split_Parent_Quote__c == null)
              childOpp.Split_Parent_Quote__c = quote.id;
          
            childOpp.Quote_Quote_Status__c = null;
            childOpp.Send_To_Customer__c = false;
            childOpp.Quote_Genesys_Care__c = null;
            childOpp.Decline_Maintenance__c = false;
            childOpp.Number_of_associated_Quotes__c = 0;
            childOpp.Primary_Quote__c = null;
           
           //childOpp.CloseDate = null;
            childOpp.Quote_USD_Equivalent__c = null;
            childOpp.Upgrade_to_Premium_Care__c = false;
            childOpp.Invoice__c = null;
            childOpp.Forecast_Status__c = null;
            childOpp.ForecastStatus__c = null;
            childOpp.Probability = null;
            childOpp.ALUProbability__c = null;
            childOpp.PO_Date__c = null;
            childOpp.PO_Number__c = null;
            childOpp.Payment_Amount__c = null;
            childOpp.Land__c = false;
            childOpp.Bill_To_Name__c = null;  
            //childOpp.Deferred_Revenue_Amount__c = 0;
            //childOpp.ForecastedAmount__c = 0;
            childOpp.Quote_Order_Payment_Terms__c = null;
            
            if(status != 'Retired')
            insert childOpp;
    
            ServiceContract sc = new ServiceContract();
            sc.name = Status + ' ' + quote.name;
            // Pulling Description/Comments from quote into Service Contract
            sc.Description = quote.BigMachines__Description__c;
            soldToName =  quote.Sold_To_Name__r.Name;
            sc.Sold_To_Name__c = quote.Sold_To_Name__c;
            endUserName = quote.End_User_ID__r.Name;            
            sc.End_User_Name__c = quote.End_User_ID__c;
            sc.Support_Owner__c = quote.Support_Owner__c;
            if(quote.BigMachines__Pricebook_Id__c != null)
                sc.Pricebook2Id = quote.BigMachines__Pricebook_Id__c;
            else
                sc.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true AND IsActive = true LIMIT 1].Id;
            sc.Renewal_Opportunity__c = childOpp.id;    
            sc.Agreement_Status__c = status;
            //Naresh Kumar  01/08/2014  This field will be used in licaudit report.
            sc.Split_Parent_Account_Id__c = quote.End_User_ID__c;
            // 07/18/2014 : Do not associate Drop/Split Service Contract with Order
            /*
            List<Order__c> orders = [SELECT id FROM Order__c WHERE Quote__c =: currentQuote.id];
            if(!orders.isEmpty())
                sc.Order__c = orders[0].id;*/
            scList.add(sc);
            if(!scList.isEmpty())
                insert scList;
    
            Set<Id> product2Ids = new Set<Id>();
            Set<String> isoCodes = new Set<String>();
            Set<String> lineIds = new Set<String>();
            
            for(BigMachines__Quote_Product__c oli : quoteProduct){
                product2Ids.add( oli.BigMachines__Product__c);
                isoCodes.add(oli.CurrencyIsoCode);
                lineIds.add(oli.Service_Contract_Line_ID__c);
            }     

            Map<Id, ContractLineItem> contLineItem = new Map<Id, ContractLineItem>([Select id,Current_Quantity__c ,
                Maintenance_Start_Date__c, Maintenance_End_Date__c,Annualized_Maintenance_Due__c,Maintenance_Level__c,Current_Maintenance_Rate__c,Lic_Invoice__c,Original_PO__c,
                Original_License_Invoice_Date__c,Previous_Line_Maintenance_Value__c,Sold_To_Name__c,Original_License_Invoice__c,Original_Quantity__c,Sold_To_Name_Lookup__c,End_User_Name__c,Sales_Order__c, Non_Billable__c 
                from ContractLineItem where id in :lineIds]);
                                                                                    
            Map<Id, List<PricebookEntry>> pb2IdToPBE = new Map<Id, List<PricebookEntry>>();
                if(!product2Ids.isEmpty())
                    
                    /*for(PricebookEntry pbe : [SELECT Product2Id, Pricebook2Id, Id, CurrencyIsoCode 
                        FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Pricebook2.IsActive = true
                        AND CurrencyIsoCode IN :isocodes AND Product2Id IN : product2Ids])*/
                    for(PricebookEntry pbe : [SELECT Product2Id, Pricebook2Id, Id, CurrencyIsoCode 
                        FROM PricebookEntry WHERE Pricebook2Id = :sc.Pricebook2Id
                        AND CurrencyIsoCode IN :isocodes AND Product2Id IN : product2Ids])
                {
                if(!pb2IdToPBE.containsKey(pbe.Product2Id))
                    pb2IdToPBE.put(pbe.Product2Id, new List<PricebookEntry>{pbe});
                else
                    pb2IdToPBE.get(pbe.Product2Id).add(pbe);
            }
            List <ContractLineItem> lineItemsToBeInserted = new List<ContractLineItem>();
            
            Double scMantAmount = 0;
            for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProduct)
            {
                // Added to resolve production test failure : Sourav (11/26/2014)
				if(!pb2IdToPBE.containsKey(eachQuoteProduct.BigMachines__Product__c))
					continue;
				
				ContractLineItem lineItemToBeInserted = new ContractLineItem();
                lineItemToBeInserted.ServiceContractId = sc.id;
                for(PricebookEntry pbe : pb2IdToPBE.get(eachQuoteProduct.BigMachines__Product__c)){
                    if(pbe.CurrencyIsoCode == eachQuoteProduct.CurrencyIsoCode){
                        lineItemToBeInserted.PricebookEntryId = pbe.Id;
                        sc.CurrencyIsoCode = pbe.CurrencyIsoCode;
                        System.debug('Vikram'+ sc.CurrencyIsoCode + pbe.Id);
                    }
                }      
                
                
                ContractLineItem previousLine = contLineItem.get(eachQuoteProduct.Service_Contract_Line_ID__c); 
                lineItemToBeInserted.Quantity = eachQuoteProduct.BigMachines__Quantity__c;
                lineItemToBeInserted.UnitPrice = eachQuoteProduct.BigMachines__Sales_Price__c;  
                lineItemToBeInserted.Actual_Original_Quantity__c = eachQuoteProduct.Original_Qty__c;
                lineItemToBeInserted.Comments__c = eachQuoteProduct.Comment__c;
                
                //Logic for the Qty goes here 
                if(eachQuoteProduct.Original_Qty__c - eachQuoteProduct.Current_Qty__c != 0){
                    lineItemToBeInserted.Original_Quantity__c = eachQuoteProduct.Original_Qty__c - eachQuoteProduct.Current_Qty__c;                    
                }
                else{ 
                    lineItemToBeInserted.Original_Quantity__c = eachQuoteProduct.Original_Qty__c;
                }
                lineItemToBeInserted.Current_Quantity__c = lineItemToBeInserted.Original_Quantity__c;
                lineItemToBeInserted.Sold_To_Name__c = soldToName; 
                lineItemToBeInserted.End_User_Name__c = endUserName;
                lineItemToBeInserted.Upgraded_Product__c = eachQuoteProduct.BigMachines__Product__c;
                
                if(eachQuoteProduct.Original_Net_License_Value__c != null) //&&
                   //eachQuoteProduct.Revised_Net_License_Value__c != null &&
                   //eachQuoteProduct.Original_Net_License_Value__c != eachQuoteProduct.Revised_Net_License_Value__c)
                {
                    // -ve values were being computed : Original Net should be considered along with quantity ratio.
                    //lineItemToBeInserted.Original_Net_License_value__c = eachQuoteProduct.Original_Net_License_Value__c - eachQuoteProduct.Revised_Net_License_Value__c;
                    lineItemToBeInserted.Original_Net_License_value__c = eachQuoteProduct.Original_Net_License_Value__c;
                }
                
                /* For complete drops/splits : When the whole line is dropped, the Revised Net should reflect the 
                    Revised net from that whole quote line (in other word whatever came in from previous 
                    service contract + LRA uplift is applicable)*/
                // revised net from previous service contract
                lineItemToBeInserted.Revised_Net_License_value__c = eachQuoteProduct.Revised_Net_From_Contract_Line__c;
                
                if(lineItemToBeInserted.Revised_Net_License_value__c != null)
                {
                    // Prorating with quantity ratio i.e. amount equivalent to decrease
                    if(eachQuoteProduct.Revised_Net_License_Value__c != null && eachQuoteProduct.Revised_Net_License_value__c != 0 &&
                        eachQuoteProduct.Original_Qty__c != null && lineItemToBeInserted.Original_Quantity__c != null &&
                        eachQuoteProduct.Original_Qty__c != 0)
                    {
                        lineItemToBeInserted.Revised_Net_License_value__c *= (lineItemToBeInserted.Original_Quantity__c/eachQuoteProduct.Original_Qty__c);
                    }
                    
                    // Adding LRA Uplift if applicable to Drop/Split/Retired Service Contract Amounts created from Quote
                	// THE FOLLOWING IF CONDITION HAS BEEN ADDED BY RAO, NOT TO ADD ANY UPLIFT CALCULATIONS FOR DROP/ DOWNSIZE CONTRACTS
                   	if(status != 'Drop' && status != 'Downsize'){
                        if(quote.LRA_Uplift__c != null && quote.LRA_Uplift__c != 0.0 &&
                            eachQuoteProduct.BigMachines__Product__c != null &&
                            !eachQuoteProduct.BigMachines__Product__r.LRA_Uplift_Not_Applicable__c)
                        {
                            lineItemToBeInserted.Revised_Net_License_value__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                        }
                        
                        if(quote.LDA_Uplift__c != null && quote.LDA_Uplift__c != 0.0 &&
                            eachQuoteProduct.BigMachines__Product__c != null &&
                            !eachQuoteProduct.BigMachines__Product__r.LDA_Uplift_Not_Applicable__c)
                        {
                            lineItemToBeInserted.Revised_Net_License_value__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                        }
                        
                        // Adding Revised Net Uplift (previously Partner Direct) if applicable
                        if(quote.Partner_Direct__c != null && quote.Partner_Direct__c != 0.0)
                        {
                            lineItemToBeInserted.Revised_Net_License_value__c *= ((100.0 + quote.Partner_Direct__c)/100.0);
                        }
					}
                }
                
                /* Commenting as this field is being overwritten below
                lineItemToBeInserted.Previous_Line_Maintenance_Value__c = eachQuoteProduct.Maintenance_Due__c;*/
               
               	if(previousLine != null) {
	                lineItemToBeInserted.Maintenance_Start_Date__c = previousLine.Maintenance_Start_Date__c;
	                lineItemToBeInserted.Maintenance_End_Date__c = previousLine.Maintenance_End_Date__c;
	                lineItemToBeInserted.Maintenance_Level__c = previousLine.Maintenance_Level__c;
	                lineItemToBeInserted.Non_Billable__c = previousLine.Non_Billable__c;
                 
					if(lineItemToBeInserted.Annualized_Maintenance_Due__c != null)
                    	lineItemToBeInserted.Annualized_Maintenance_Due__c =  (previousLine.Annualized_Maintenance_Due__c/previousLine.Original_Quantity__c)* lineItemToBeInserted.Original_Quantity__c;
                	if(previousLine.Previous_Line_Maintenance_Value__c == null)
                    	previousLine.Previous_Line_Maintenance_Value__c = 0;
                 	if(previousLine.Original_Quantity__c == null)
                    	previousLine.Original_Quantity__c = 0;
                 	if(lineItemToBeInserted.Original_Quantity__c == null)
                    	lineItemToBeInserted.Original_Quantity__c = 0;
                
                	lineItemToBeInserted.Previous_Line_Maintenance_Value__c = (previousLine.Previous_Line_Maintenance_Value__c/previousLine.Original_Quantity__c)* lineItemToBeInserted.Original_Quantity__c;
                
                	// Adding LRA Uplift if applicable to Drop/Split/Retired Service Contract Amounts created from Quote
                	// THE FOLLOWING IF CONDITION HAS BEEN ADDED BY RAO, NOT TO ADD ANY UPLIFT CALCULATIONS FOR DROP/ DOWNSIZE CONTRACTS
                   if(status != 'Drop' && status != 'Downsize'){
                        if(quote.LRA_Uplift__c != null && 
                            eachQuoteProduct.BigMachines__Product__c != null &&
                            !eachQuoteProduct.BigMachines__Product__r.LRA_Uplift_Not_Applicable__c)
                        {
                            lineItemToBeInserted.Previous_Line_Maintenance_Value__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                            if(lineItemToBeInserted.Annualized_Maintenance_Due__c != null)
                                lineItemToBeInserted.Annualized_Maintenance_Due__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                        }
                           
                        if(quote.LDA_Uplift__c != null && quote.LDA_Uplift__c != 0.0 &&
                            eachQuoteProduct.BigMachines__Product__c != null && !eachQuoteProduct.BigMachines__Product__r.LDA_Uplift_Not_Applicable__c)
                        {
                            lineItemToBeInserted.Previous_Line_Maintenance_Value__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                            if(lineItemToBeInserted.Annualized_Maintenance_Due__c != null)
                                lineItemToBeInserted.Annualized_Maintenance_Due__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                        }
                        
                   	}
                 	scMantAmount += lineItemToBeInserted.Previous_Line_Maintenance_Value__c;
                 	lineItemToBeInserted.Maintenance_Level__c = previousLine.Maintenance_Level__c;
                 	lineItemToBeInserted.Current_Maintenance_Rate__c =previousLine.Current_Maintenance_Rate__c;
                 	lineItemToBeInserted.Lic_Invoice__c =previousLine.Lic_Invoice__c;
                 	lineItemToBeInserted.Original_PO__c =previousLine.Original_PO__c;
                 	lineItemToBeInserted.Original_License_Invoice_Date__c =previousLine.Original_License_Invoice_Date__c;
                 	lineItemToBeInserted.Original_License_Invoice__c =previousLine.Original_License_Invoice__c;
                 	lineItemToBeInserted.Sales_Order__c =previousLine.Sales_Order__c;
                 	lineItemToBeInserted.Sold_To_Name__c = previousLine.Sold_To_Name__c; 
                 	lineItemToBeInserted.End_User_Name__c = previousLine.End_User_Name__c;      
	         	}
                lineItemsToBeInserted.add(lineItemToBeInserted);
            }
            sc.Maintenance_Amount__c = scMantAmount;
            update sc;
            BigMachines__Quote__c quoteToBeUpdated = new  BigMachines__Quote__c();
            quoteToBeUpdated.id = quote.id; 
            
            if(Status == 'Drop')
                quoteToBeUpdated.Drop_Status__c = true; 
            else if(Status =='Split')
                quoteToBeUpdated.Split_Status__c = true; 
            else if(Status =='Retired')
                quoteToBeUpdated.Retire_Status__c = true;
            else if(Status =='Shelved')
                quoteToBeUpdated.Shelve_Status__c = true;
            else if(Status =='Downsize')
                quoteToBeUpdated.Downsize_Status__c = true;
            
            update quoteToBeUpdated; 
           
            if(!lineItemsToBeInserted.isEmpty())  
             insert lineItemsToBeInserted;             
            
            sendEmail(sc.id);
        }
    //return null;          
    }
    
    private static void sendEmail(String serviceContractId){
        String htmlBody = 'Hi, <br/><br/>';
        htmlBody += URL.getSalesforceBaseUrl().toExternalForm() + '/' + serviceContractId;
        SendEmail.sendSingleEmail('vikram.sharma@genesyslab.com', 'New Drop/Split/Retired', htmlBody);
    }
 
    public static Account getName(String name) {
        Account acc  = null;
        Account acct = [Select id from account where name=:name limit 1];
        return acct;
    }
}