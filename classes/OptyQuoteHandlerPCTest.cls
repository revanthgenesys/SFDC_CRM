//Naresh Kumar  06/10/2018
@isTest(SeeAllData=true)
private class OptyQuoteHandlerPCTest {

    static testMethod void testMethod1() {
        
        Subscription__c testsub = [Select Id,Account__c,Opportunity_LookUp__c from Subscription__c where Offering_Type__c = 'PureConnect Cloud'
                                    AND Account__c != NULL AND Opportunity_LookUp__c != NULL LIMIT 1];
        System.Debug('testsub--->'+testsub);
        
        opportunity opty = [SELECT id, Name, AccountId, Sold_To_Country__r.Name, Offering_Detail__c,
            Sold_To_Country__r.RU__c, Quote_Category__c, Lines_of_Businesses__c, Type,
            Primary_Line_of_Business__c , CurrencyIsoCode, BusinessPartner__c, Support_Owner__c,
            System_Integrator__c, Direct_Sales__c, Account.Country__r.New_Price_Book__c, Country_Sub_Region__c,
            BusinessPartner__r.Country__r.New_Price_Book__c, Account.Country__r.Old_Price_Book__c,
            BusinessPartner__r.Country__r.Old_Price_Book__c, Sold_To_Country__r.New_Price_Book__c,
            Sold_To_Country__r.Old_Price_Book__c, Country_Selling_Entity__c, SOW_Url__c, Product_Version__c,
            Contractual_Obligation__c, PricingType__c, Direct_Indirect_Sale__c,Primary_Solution__c, Quote_Type1__c,
            Account.RecordType.DeveloperName, Indirect_Partner_PureCloud_Approved__c,
            BusinessPartner__r.Approved_for_PureCloud_Billing__c, BusinessPartner__r.SMART_Qualified__c, BusinessPartner__r.Subscription_Qualified__c,
            Account.Pricesheet_Permission__c,BusinessPartner__r.Pricesheet_Permission__c FROM Opportunity where Id=:testsub.Opportunity_LookUp__c Limit 1];
            
            PageReference pageRef = Page.OptyQuoteCategoryPC;
            test.setCurrentPage(pageRef);
            pageRef.getParameters().put('oppId',opty.Id);

        	Util.Bypass_Trigger_Chk = true;
            OptyQuoteHandlerPC objPC = new OptyQuoteHandlerPC();
            objPC.blnIsAdmin = false;
            //objPC.objOppQuoteCategory.Offering_Details__c = 'Subscription';
            objPC.nextStep1();
            //objPC.createQuoteAndGoToQuote();
            objPC.getProductVersion();
            objPC.redirectToRespectiveDQ();
            objPC.goToCloneQuoteIfOppIsDownUpGrade();
            objPC.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(opty.AccountId,'PureConnect Cloud');
            System.Debug('map_Subscriptions--->'+objPC.map_Subscriptions);
            set<Id> testLstId = objPC.map_Subscriptions.keyset();
            for(Id testId:testLstId ){
                objPC.selectedSubscrToAmend = testId;
            }
            /*for(Product_Group__c testUC:objPC.listOfUseCases){
                testUC.Selected__c = true;
            }*/
            objPC.createAmendPureCloudQuote();
            objPC.strSubscrSubType = 'Renew Existing Subscription';
            objPC.createAmendPureCloudQuote();
            objPC.createCICQuote();
            objPC.createOnPremiseQuote();
            objPC.createAmendPureEngageOrPureConnectSubscriptionQuote();
            objPC.createPureEngageSubscriptionQuote();
            objPC.createPureConnectSubscriptionQuote();
            objPC.createPPUQuote();
            objPC.createCloudQuote();
            objPC.getOrderTypes();
            objPC.getSubscrSubTypes();
            objPC.strSelectedOrderType = 'Amend';
            objPC.createQuoteAndGoToQuote();
         
    }
    
    static testMethod void testMethod2() {
        opportunity opty = [SELECT id, Name, AccountId, Sold_To_Country__r.Name, Offering_Detail__c,
            Sold_To_Country__r.RU__c, Quote_Category__c, Lines_of_Businesses__c, Type,
            Primary_Line_of_Business__c , CurrencyIsoCode, BusinessPartner__c, Support_Owner__c,
            System_Integrator__c, Direct_Sales__c, Account.Country__r.New_Price_Book__c, Country_Sub_Region__c,
            BusinessPartner__r.Country__r.New_Price_Book__c, Account.Country__r.Old_Price_Book__c,
            BusinessPartner__r.Country__r.Old_Price_Book__c, Sold_To_Country__r.New_Price_Book__c,
            Sold_To_Country__r.Old_Price_Book__c, Country_Selling_Entity__c, SOW_Url__c, Product_Version__c,
            Contractual_Obligation__c, PricingType__c, Direct_Indirect_Sale__c,Primary_Solution__c, Quote_Type1__c,
            Account.RecordType.DeveloperName, Indirect_Partner_PureCloud_Approved__c,
            BusinessPartner__r.Approved_for_PureCloud_Billing__c, BusinessPartner__r.SMART_Qualified__c, BusinessPartner__r.Subscription_Qualified__c,
            Account.Pricesheet_Permission__c,BusinessPartner__r.Pricesheet_Permission__c FROM Opportunity where Primary_Line_of_Business__c = 'On Premise' Limit 1];
            
            PageReference pageRef = Page.OptyQuoteCategoryPC;
            test.setCurrentPage(pageRef);
            pageRef.getParameters().put('oppId',opty.Id);

        	Util.Bypass_Trigger_Chk = true;
            OptyQuoteHandlerPC objPC = new OptyQuoteHandlerPC();
            objPC.blnIsAdmin = false;
            objPC.objOppQuoteCategory.Offering_Details__c = 'On Premise';
            objPC.nextStep1();
            objPC.createQuoteAndGoToQuote();
            objPC.getProductVersion();
            objPC.redirectToRespectiveDQ();
            objPC.goToCloneQuoteIfOppIsDownUpGrade();
            objPC.createOnPremiseQuote();
            objPC.createCICQuote();
            //objPC.createAmendPureCloudQuote();
            objPC.createAmendPureEngageOrPureConnectSubscriptionQuote();
            objPC.blnShowBaseAndPureSuccessPackage = true;
            objPC.createPureEngageSubscriptionQuote();
            objPC.createPureConnectSubscriptionQuote();
            objPC.createPPUQuote();
            objPC.createCloudQuote();
            objPC.getOrderTypes();
            objPC.getSubscrSubTypes();
            objPC.forCodeCoverage();
            
    }
    
    static testMethod void testMethod3() {
        
        opportunity opty = [SELECT id, Name, AccountId, Sold_To_Country__r.Name, Offering_Detail__c,
            Sold_To_Country__r.RU__c, Quote_Category__c, Lines_of_Businesses__c, Type,
            Primary_Line_of_Business__c , CurrencyIsoCode, BusinessPartner__c, Support_Owner__c,
            System_Integrator__c, Direct_Sales__c, Account.Country__r.New_Price_Book__c, Country_Sub_Region__c,
            BusinessPartner__r.Country__r.New_Price_Book__c, Account.Country__r.Old_Price_Book__c,
            BusinessPartner__r.Country__r.Old_Price_Book__c, Sold_To_Country__r.New_Price_Book__c,
            Sold_To_Country__r.Old_Price_Book__c, Country_Selling_Entity__c, SOW_Url__c, Product_Version__c,
            Contractual_Obligation__c, PricingType__c, Direct_Indirect_Sale__c,Primary_Solution__c, Quote_Type1__c,
            Account.RecordType.DeveloperName, Indirect_Partner_PureCloud_Approved__c,
            BusinessPartner__r.Approved_for_PureCloud_Billing__c, BusinessPartner__r.SMART_Qualified__c, BusinessPartner__r.Subscription_Qualified__c,
            Account.Pricesheet_Permission__c,BusinessPartner__r.Pricesheet_Permission__c FROM Opportunity where Primary_Line_of_Business__c = 'Cloud' AND 
            Lines_of_Businesses__c= 'PureEngage' Limit 1];
            
            PageReference pageRef = Page.OptyQuoteCategoryPC;
            test.setCurrentPage(pageRef);
            pageRef.getParameters().put('oppId',opty.Id);

        	Util.Bypass_Trigger_Chk = true;
            OptyQuoteHandlerPC objPC = new OptyQuoteHandlerPC();
            objPC.blnIsAdmin = false;
            objPC.objOppQuoteCategory.Offering_Details__c = 'Subscription';
            objPC.nextStep1();
            objPC.createQuoteAndGoToQuote();
            objPC.getProductVersion();
            objPC.redirectToRespectiveDQ();
            objPC.goToCloneQuoteIfOppIsDownUpGrade();
            /*objPC.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(opty.AccountId,opty.Lines_of_Businesses__c);
            set<Id> testLstId = objPC.map_Subscriptions.keyset();
            for(Id testId:testLstId ){
                objPC.selectedSubscrToAmend = testId;
            }
            for(Product_Group__c testUC:objPC.listOfUseCases){
                testUC.Selected__c = true;
            }*/
            //objPC.createAmendPureCloudQuote();
            objPC.strSubscrSubType = 'Renew Existing Subscription';
            //objPC.createAmendPureCloudQuote();
            objPC.createCICQuote();
            objPC.createOnPremiseQuote();
            objPC.createAmendPureEngageOrPureConnectSubscriptionQuote();
            objPC.createPureEngageSubscriptionQuote();
            objPC.createPureConnectSubscriptionQuote();
            objPC.createPPUQuote();
            objPC.createCloudQuote();
            objPC.getOrderTypes();
            objPC.getSubscrSubTypes();
         
    }
}