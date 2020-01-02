/*
Created By: Mukunthan Koothan
Created On: 11-JAN-2018
Purpose: Test class for ProposalPDFSubscriptionController
*/

@isTest
public class ProposalPDFSubscriptionControllerTest {
    
    @isTest(seeAllData=true)
    static void construtorTest(){
        Test.startTest();
            List<Account> acct = TestDataFactoryForQuoteTool.createAccounts(1);
            country__c country = [Select Id from country__c where Country__c='United States' OR Country__c='USA' limit 1];
            list<opportunity> optyList = TestDataFactoryForQuoteTool.createOpportunties1(acct[0].Id,country.Id,1);
            List<BigMachines__Quote__c> quote = TestDataFactoryForQuoteTool.createQuotes(optyList[0].Id, acct[0].Id,1);
           
            List<product2> product = TestDataFactoryForQuoteTool.createproducts(2);
            List<BigMachines__Quote_Product__c> quoteProd = TestDataFactoryForQuoteTool.createQuoteProducts(quote[0].Id);
        
            Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(quote[0]);  
            objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
            insert objNewSubscription;
            
            quote[0].Multi_Year_Quote__c = true;
            quote[0].Amendment_For__c = objNewSubscription.id;
            update quote;
        
            Product_Group__c prdGrp = new Product_Group__c();
            prdGrp.Group_Type__c = 'Base Package';
            insert prdGrp;
        
            for(BigMachines__Quote_Product__c qp:quoteProd){
                qp.Bundle__c = prdGrp.Id;
            }
            
            update quoteProd;
        
            PageReference testPage = Page.ProposalPDFSubscription;
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('id', quote[0].Id);
        
            ProposalPDFSubscriptionController proposalPDF = new ProposalPDFSubscriptionController();
        
            for(BigMachines__Quote__c q1:quote){
                q1.Group_Product_By__c = 'Use Case View';
            }
            update quote;
            
            //PageReference testPage2 = Page.ProposalPDFSubscription;
            //Test.setCurrentPage(testPage2);
            //testPage.getParameters().put('id', quote[0].Id);
            //ProposalPDFSubscriptionController proposalPDF2 = new ProposalPDFSubscriptionController();         
            
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static void getQuoteProductsTest(){
        Test.startTest();
            List<Account> acct = TestDataFactoryForQuoteTool.createAccounts(1);
            country__c country = [Select Id from country__c where Country__c='United States' OR Country__c='USA' limit 1];
            list<opportunity> optyList = TestDataFactoryForQuoteTool.createOpportunties1(acct[0].Id,country.Id,1);
            List<BigMachines__Quote__c> quote = TestDataFactoryForQuoteTool.createQuotes(optyList[0].Id, acct[0].Id,1);
        
            List<product2> product = TestDataFactoryForQuoteTool.createproducts(2);
            List<BigMachines__Quote_Product__c> quoteProd = TestDataFactoryForQuoteTool.createQuoteProducts(quote[0].Id);
        
            for(BigMachines__Quote__c q1:quote){
                q1.Group_Product_By__c = 'Use Case View';
            }
            update quote;
        
            PageReference testPage = Page.ProposalPDFSubscription;
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('id',quote[0].Id);
        
            ProposalPDFSubscriptionController proposalPDF = new ProposalPDFSubscriptionController();
        
            Product_Group__c prdGrp = new Product_Group__c();
            prdGrp.Group_Type__c = 'Base Package';
            insert prdGrp;
        
            for(BigMachines__Quote_Product__c qp:quoteProd){
                qp.Bundle__c = prdGrp.Id;
            }
            
            update quoteProd;
        
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static void getUniqueGroupNameTest(){
        Test.startTest();
            List<Account> acct = TestDataFactoryForQuoteTool.createAccounts(1);
            country__c country = [Select Id from country__c where Country__c='United States' OR Country__c='USA' limit 1];
            list<opportunity> optyList = TestDataFactoryForQuoteTool.createOpportunties1(acct[0].Id,country.Id,1);
            List<BigMachines__Quote__c> quote = TestDataFactoryForQuoteTool.createQuotes(optyList[0].Id, acct[0].Id,1);
        
            List<product2> product = TestDataFactoryForQuoteTool.createproducts(2);
            List<BigMachines__Quote_Product__c> quoteProd = TestDataFactoryForQuoteTool.createQuoteProducts(quote[0].Id);
        
            for(BigMachines__Quote__c q1:quote){
                q1.Group_Product_By__c = 'Category View';
            }
            update quote;
        
            PageReference testPage = Page.ProposalPDFSubscription;
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('id',quote[0].Id);
        
            ProposalPDFSubscriptionController proposalPDF = new ProposalPDFSubscriptionController();
        
            Product_Group__c prdGrp = new Product_Group__c();
            prdGrp.Group_Type__c = 'Base Package';
            insert prdGrp;
        
            for(BigMachines__Quote_Product__c qp:quoteProd){
                qp.Bundle__c = prdGrp.Id;
            }
            
            update quoteProd;
        
        Test.stopTest();
    }

    @isTest(seeAllData=true)
    static void testSetOutputFormat(){
        BigMachines__Quote_Product__c objQuoteProduct = [SELECT Id, BigMachines__Product__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                                                         FROM BigMachines__Quote_Product__c
                                                         WHERE BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c = null LIMIT 1];
        ProposalPDFSubscriptionController.setOutputFormat(objQuoteProduct);

        Id idQuoteProduct = objQuoteProduct.Id;
        Id idProduct = objQuoteProduct.BigMachines__Product__c;

        Product2 objProduct = [select Id from Product2 where Id = :idProduct];
        objProduct.Tier_Pricing_Decimal_Precision__c = '4';
        update objProduct;
        
        objQuoteProduct = [SELECT Id, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct];
        ProposalPDFSubscriptionController.setOutputFormat(objQuoteProduct);

        objProduct.Tier_Pricing_Decimal_Precision__c = '6';
        update objProduct;

        objQuoteProduct = [SELECT Id, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct];
        ProposalPDFSubscriptionController.setOutputFormat(objQuoteProduct);
    }
}