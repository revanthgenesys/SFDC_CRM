/**

*/
@isTest(SeeAllData=true)
private class MakeQuotePrimary_WS_Test {
    
    static testMethod void MakeQuotePrimary_WS_Test1_Method1() {
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
        List<BigMachines__Quote__c> quotesList = TestUtil.createQuotes(2,true);
        testQuote.Quote_Business_Type__c = 'Cloud';
        testQuote.PPU_Rental__c = true;
        update testQuote;
        
        List<String> quotes = new List<String>{quotesList[0].Id,quotesList[1].Id};            
        testQuote.Cloud_Term_Commitment__c = 1;
        update testQuote;
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        testQuote.Cloud_Term_Commitment__c = 2;
        update testQuote;
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        //testQuote.Cloud_Term_Commitment__c = 3;
        //update testQuote;
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        Test.startTest();
        //testQuote.Cloud_Term_Commitment__c = 5;
        //update testQuote;    
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        quotesList[0].Quote_Business_Type__c = 'Cloud';
        update quotesList[0];
        
        quotesList[1].Quote_Business_Type__c = 'Cloud';
        update quotesList[1];
        Test.stopTest();  
        system.debug('-------------------------------quotes---------------------------------'+quotes);
        
    }
    
    static testMethod void MakeQuotePrimary_WS_Test1_Method2() {
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
        List<BigMachines__Quote__c> quotesList = TestUtil.createQuotes(2,true);
        testQuote.Quote_Business_Type__c = 'Cloud';
        update testQuote;
        
        List<String> quotes = new List<String>{quotesList[0].Id,quotesList[1].Id};
            
            MakeQuotePrimary_WS.makeQuotePlateformPrimary(quotes, 'Cloud');
        
        List<String> quotes1 = new List<String>{quotesList[0].Id};
            quotesList[0].Cloud_Term_Commitment__c = 1;
        update quotesList[0];
        MakeQuotePrimary_WS.makeQuotePlateformPrimary(quotes1, 'Cloud');
        
        Test.startTest();
        quotesList[0].Cloud_Term_Commitment__c = 2;
        update quotesList[0];
        MakeQuotePrimary_WS.makeQuotePlateformPrimary(quotes1, 'Cloud');
        
        quotesList[0].Cloud_Term_Commitment__c = 3;
        update quotesList[0];
        MakeQuotePrimary_WS.makeQuotePlateformPrimary(quotes1, 'Cloud');  
        
        quotes1 = new List<String>{testQuote.Id};
            MakeQuotePrimary_WS.makeQuotePlateformPrimary(quotes1, 'Cloud');
        
        Test.stopTest();
    }
    
    static testMethod void MakeQuotePrimary_WS_Test1_Method3() {
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
        List<BigMachines__Quote__c> quotesList = TestUtil.createQuotes(2,true);
        testQuote.Offering_Type__c= 'PureConnect On Premise';
        update testQuote;
        
        List<String> quotes = new List<String>{quotesList[0].Id,quotesList[1].Id};
            testQuote.Quote_Business_Type__c = 'Premise Subscription';
            testQuote.Cloud_Term_Commitment__c = 1;
        update testQuote;
        System.debug('Quote'+testQuote);
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        testQuote.Cloud_Term_Commitment__c = 2;
        update testQuote;
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        //testQuote.Cloud_Term_Commitment__c = 3;
        //update testQuote;
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        Test.startTest();
        //testQuote.Cloud_Term_Commitment__c = 5;
        //update testQuote;    
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        quotesList[0].Quote_Business_Type__c = 'Cloud';
        update quotesList[0];
        
        quotesList[1].Quote_Business_Type__c = 'Cloud';
        update quotesList[1];
        Test.stopTest();  
    }
    
    static testMethod void MakeQuotePrimary_WS_Test1_Method4() {
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
        List<BigMachines__Quote__c> quotesList = TestUtil.createQuotes(2,true);
        testQuote.Offering_Type__c= 'Business Edition';
        update testQuote;
        
        List<String> quotes = new List<String>{quotesList[0].Id,quotesList[1].Id};
            
            testQuote.Cloud_Term_Commitment__c = 1;
        update testQuote;
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        testQuote.Cloud_Term_Commitment__c = 2;
        update testQuote;
        MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        //testQuote.Cloud_Term_Commitment__c = 3;
        //update testQuote;
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        Test.startTest();
        //testQuote.Cloud_Term_Commitment__c = 5;
        //update testQuote;    
        //MakeQuotePrimary_WS.CorrectTotalCloud(testQuote.id);
        
        quotesList[0].Quote_Business_Type__c = 'Cloud';
        update quotesList[0];
        
        quotesList[1].Quote_Business_Type__c = 'Cloud';
        update quotesList[1];
        Test.stopTest();  
    }
    static testMethod void otherTests() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        /*
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);  
        
        */
        List<BigMachines__Quote__c> list_NewQuotes = TestUtil.createQuotes(1, true);
        
        list_NewQuotes[0].Total_Services__c = list_NewQuotes[0].Total_Education__c = list_NewQuotes[0].Total_Hardware__c = 0;
        list_NewQuotes[0].CMRR__c = list_NewQuotes[0].Annual_Contract_Value__c = list_NewQuotes[0].Total_Contract_Value__c = 0;
        list_NewQuotes[0].offering_type__c = 'PureCloud';
        update list_NewQuotes[0];
        MakeQuotePrimary_WS.CorrectTotalCloud(list_NewQuotes[0].id);
        
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes[0];
        
        Opportunity opp = new Opportunity(id=list_NewQuotes[0].BigMachines__Opportunity__c, Offering_Detail__c = null);
        update opp;
        
        MakeQuotePrimary_WS.CorrectTotalCloud(list_NewQuotes[0].id);
        MakeQuotePrimary_WS.getQuoteType(list_NewQuotes[0].Id);
    }
    
    static testMethod void MakeQuotePrimary_WS_Test1_Method5() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestUtil.createQuotes(1, true);
        
        list_NewQuotes[0].Total_Services__c = list_NewQuotes[0].Total_Education__c = list_NewQuotes[0].Total_Hardware__c = 0;
        list_NewQuotes[0].CMRR__c = list_NewQuotes[0].Annual_Contract_Value__c = list_NewQuotes[0].Total_Contract_Value__c = 0;
        list_NewQuotes[0].offering_type__c = 'PureCloud';
        list_NewQuotes[0].Quote_Business_Type__c = 'Cloud';
        update list_NewQuotes[0];
        MakeQuotePrimary_WS.CorrectTotalCloud(list_NewQuotes[0].id);
        
        
    }
}