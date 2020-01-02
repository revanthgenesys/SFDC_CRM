@isTest(seealldata=True)
public class TestDataFactoryForDDS {

	public static BigMachines__Quote__c prepareDataPC() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
 
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            //objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Extended_Price_Per_Month__c = 100;
            objQP.List_Price__c = 100;
            objQP.BigMachines__Quantity__c = 1;
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        update list_NewQuoteProds;
        
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objProd;
        
        return list_NewQuotes[0];   
    }

    public static BigMachines__Quote__c prepareDataPCC() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts2(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(),2);  
    
        //Unit tests for CreateQuoteCloudController methods    
        BigMachines__Quote__c objQuote = list_NewQuotes[0];  
        objQuote.No_Of_Months__c=12;
        objQuote.Deployment_Model__c='Local Control';
        objQuote.Ramp_Period__c='60';
        objQuote.Initial_Subscription_Term__c='1 Year';
        objQuote.Billing_Period__c='Annually';
        objQuote.MSA_Link__c='www.google.com';  
        objQuote.Sold_To_Name__c=[SELECT Id FROM Account WHERE Id != :list_NewAccts[0].Id LIMIT 1].Id;  
        objQuote.Sent_to_Customer__c=true;
        objQuote.Special_Offer_Terms__c='New Offer';
        objQuote.Grid_Group_By__c='Categories';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        objQuote.Subscription_Start_Date__c = Date.Today(); //Added by Priyank
        objQuote.Subscription_End_Date__c = Date.Today().addMonths(3);
        update objQuote;      
                 
        
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.Product_Specific_Discount__c =1;
              
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        list_NewQuoteProds[1].Ext_List__c =10;
        list_NewQuoteProds[0].Ext_List__c =10;
        list_NewQuoteProds[0].Is_Overage__c=False;
        list_NewQuoteProds[1].Is_Overage__c=True;
        
        update list_NewQuoteProds;
        
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true, 
            Include_in_Agent_Seat_Count__c = true, Discountable__c = false);      
        update objQtProd;        
        
        Quote_Proposal_Group__c objQProposalGroup = new Quote_Proposal_Group__c( Quote__c = objQuote.id,
                                                                                Description__c = 'Test',
                                                                                Discount__c = 2.5,
                                                                                Group_Number__c = 'PG1',
                                                                                Goal_Seek__c = 0 ,
                                                                                Name__c = 'Test Proposal Group'
                                                                               );
        insert objQProposalGroup;
        
        return objQuote;
    }

    public static DDSCloud.DDSCloudModel fetchDDSCloud(String strOfferingType, String strDirectIndirect, Decimal decDiscount,Decimal decDealSize, Decimal decContractualDiscount){
    	
    	DDSCloud.DDSCloudModel objCloudModel = new DDSCloud.DDSCloudModel();
    	objCloudModel.strOfferingType = strOfferingType;
    	objCloudModel.strDirectIndirect = strDirectIndirect;
    	objCloudModel.decDiscount = decDiscount;
    	objCloudModel.decDealSize = decDealSize;
    	objCloudModel.objScoreAdjustment = new DDSCloud.ScoreAdjustment();
    	objCloudModel.objScoreAdjustment.decContractualDiscount = decContractualDiscount;
        objCloudModel.objContractualDiscount = new DDSCloud.ContractualDiscount();
        objCloudModel.objContractualDiscount.decPartnerDiscount = decContractualDiscount;
        objCloudModel.objContractualDiscount.decCustomerDiscount = 0;
        objCloudModel.objContractualDiscount.decDealRegistrationDiscount = 0;
    	return objCloudModel;
    }
}