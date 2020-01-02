/************************************************************************************
Purpose : Unit test class for OpportunityCloudUtil
Written By : Rony Joseph
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
public class OpportunityCloudUtilTest {
    
    static testMethod void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].ACV_Subscription_Only__c = 100.00;
        list_NewOpps[0].ACV_Subscription_Only__c = 100.00;
        list_NewOpps[0].Lead_Offer__C = 'PureCloud';
        list_NewOpps[0].Lines_of_Businesses__c = 'PureCloud';
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, Product__r.APN_Number__c, Product__c,Subscription__r.Account__c,
                                                                Subscription__r.Subscription_Start_Date__c, Quantity__c,
                                                                Subscription__r.Start_Date__c, Subscription__r.Name, Subscription__c
                                                                FROM Subscription_Product__c 
                                                                WHERE Subscription__c =: objNewSubscription.Id];
        
        Set<ID> set_AccountIds = new Set<ID>();
        for(Account acc : list_NewAccts)
            set_AccountIds.add(acc.id);
        
        Set<ID> set_OpptyIds = new Set<ID>();
        for(Opportunity opp : list_NewOpps)
            set_OpptyIds.add(opp.id);
        
        OpportunityCloudUtil.FetchGSRelationship(set_AccountIds);  
        
        Cloud_Forecast_Quarter__c objCloudForecast = new Cloud_Forecast_Quarter__c(Current_Week__c = True, Active__c = True);
        insert objCloudForecast;
        //Note:Will Need to change fields to reflect the previous 3 months before the last month.Ex for July 2018, will need the field values for March,April and May 2018.                                   
        Account_Revenue_Forecast__c objAccountRevenue = new Account_Revenue_Forecast__c(Account__c = list_NewAccts[0].id,Offering_Type__c='PureCloud',Cloud_Forecast_Quarter__c = objCloudForecast.id, LOB__c = 'A - In-Force Subscription',Oct_2017__c = 100.00,Nov_2017__c =100.00,Dec_2017__c = 100.00,Jan_2018__c = 100.00,Feb_2018__c =100.00,Mar_2018__c = 100.00,Apr_2018__c = 100.00,May_2018__c =100.00,June_2018__c = 100.00,July_2018__c = 100.00,Aug_2018__c =100.00,Sept_2018__c = 100.00,Oct_2018__c = 100.00); 
        insert objAccountRevenue;
        
        Set<ID> set_AccountIds1 = new Set<ID>();
        for(Account acc : list_NewAccts)
            set_AccountIds.add(acc.id);
        
        Set<ID> set_OpptyIds1 = new Set<ID>();
        for(Opportunity opp : list_NewOpps)
            set_OpptyIds1.add(opp.id);
        OpportunityCloudUtil.UpdateRunRate(set_OpptyIds1); 
        OpportunityCloudUtil.fetchGSRelationship(list_NewAccts[0].id);
        list_NewOpps[0].Lines_of_Businesses__c = 'PureConnect Cloud';
        list_NewOpps[0].Lead_Offer__C = 'PureConnect Cloud';
        update list_NewOpps[0];
        objAccountRevenue.Offering_Type__c = 'PureConnect';
        update objAccountRevenue;
        OpportunityCloudUtil.UpdateRunRate(set_OpptyIds1);
        Map<Id,Opportunity> map_PCOpp = new Map<Id,Opportunity>();
        map_PCOpp.put(list_NewOpps[0].id,list_NewOpps[0]);
        OpportunityCloudUtil.updateRenewalRunRate(map_PCOpp );
    }
    
    static testMethod void updateLegalExceptiononOnOpportunityTest() {
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        
        JBCXM__GSRelationshipType__c jbxmgs = new JBCXM__GSRelationshipType__c();
            jbxmgs.JBCXM__Active__c = true;
            jbxmgs.Name = 'PureCloud'; 
            jbxmgs.JBCXM__Attributes__c = 'test';
            jbxmgs.JBCXM__CardConfig__c = 'test';
            jbxmgs.JBCXM__Definition__c = 'test';
            jbxmgs.JBCXM__Description__c = 'test';
            jbxmgs.JBCXM__DisplayOrder__c = 1;
            jbxmgs.JBCXM__LayoutAttribute__c = 'test';
            jbxmgs.JBCXM__LayoutCriteria__c = 'test';
            jbxmgs.JBCXM__Type__c = 'PureCloud';
            insert jbxmgs;
        
        JBCXM__GSRelationship__c jbcxm = new JBCXM__GSRelationship__c();
        jbcxm.JBCXM__GSCSM__c = UserInfo.getUserId();
        jbcxm.JBCXM__Account__c = list_NewAccts[0].Id;      
        jbcxm.JBCXM__RelationshipType__c = jbxmgs.id;
        jbcxm.PureEngage_Cloud_Stage__c = 'Steady State';
        insert jbcxm;
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].ACV_Subscription_Only__c = 100.00;
        update list_NewOpps[0];
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        insert objNewSubscription;
        objNewSubscription.Legal_Exceptions__c = 'Background Checks;';
        update objNewSubscription;    
        list_NewQuotes[0].Amendment_For__c = objNewSubscription.id;
        update list_NewQuotes[0];
        OpportunityCloudUtil.updateLegalExceptiononOnOpportunity(list_NewOpps[0],objNewSubscription.ID);
        GCR__c objGCR = new GCR__c();
        objGCR.Account__c =list_NewAccts[0].Id;
        objGCR.Request_Type__c = 'Sales';
        objGCR.Requestor_Name__c = UserInfo.getUserId();
        objGCR.Attorney_Name__c = UserInfo.getUserId();
        objGCR.Status__c = '1-New';
        objGCR.Offering_type__c = 'PureCloud'; 
        objGCR.Opportunity__c = list_NewOpps[0].Id;
        insert  objGCR;
        GCR_Content_Document_Folder__c objGCRFolder = new GCR_Content_Document_Folder__c();
        objGCRFolder.Name = objGCR.Name;
        objGCRFolder.Account__c = objGCR.Account__c;
        objGCRFolder.GCR__c = objGCR.id;
        objGCRFolder.Active__c = true;
        insert objGCRFolder;
        GCR_Content_Document_Detail__c  objGCRDocDetail = new GCR_Content_Document_Detail__c();
        objGCRDocDetail.Folder__c = objGCRFolder.id;
        objGCRDocDetail.Account_Name__c = objGCR.Account__c;
        objGCRDocDetail.Opportunity__c = list_NewOpps[0].Id;
        objGCRDocDetail.GCR__c = objGCR.id;
        objGCRDocDetail.Document_Name__c = objGCR.Name;
        objGCRDocDetail.Legal_Exceptions__c = 'Background Checks;';
        objGCRDocDetail.Contract_Type__c = 'Adoption Agreement';
        objGCRDocDetail.Active__c = true;
        insert objGCRDocDetail;
        String strWhereCondition = 'where id = \''+objNewSubscription.ID+'\'';
        OpportunityCloudUtil.updateLegalExceptiononOnOpportunity(list_NewOpps[0],objNewSubscription.ID);
        
        
        objNewSubscription = Database.query(SubscriptionUtil.buildQryForRenewOppAndQuoteFromSubscrs(strWhereCondition));
        OpportunityCloudUtil.createRenewalOpportunity(objNewSubscription);
        OpportunityCloudUtil.cloneSubscriptionOpportunity(objNewSubscription.Id);

        
        
    }
    
}