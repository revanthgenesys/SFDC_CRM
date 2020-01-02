@isTest
public class DealQualificationController_Test{
    @isTest
    private static void unitTestOne(){
        Test.starttest();
            Account testAccount = TestUtil.createAccounts(1, false)[0];
            testAccount.Partner_Tier__c = 'Gold';
            insert testAccount;
            
            Country__c country = new Country__c(Name='India',Country__c='India001',Region__c='India');
            insert country;
            
            Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
            testOpp.Enablement_Model__c = 'Direct Enablement';
            testOpp.Type = 'New logo';
            testOpp.Sold_To_Country__c = country.Id;
            testOpp.BusinessPartner__c = testAccount.Id;
            testOpp.License_Amount__c = 1000;
            insert testOpp;
            
            Deal_Qualification__c testDQ = new Deal_Qualification__c();
            testDQ.Opportunity__c = testOpp.id;
            testDQ.Offering_Type__c = 'Business Edition';
            testDQ.Pricing_Type__c = 'New Pricing';
            testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            testDQ.Platform_Type__c = 'Cloud';
            testDQ.Is_Telco_Included__c = 'No';
            testDQ.Term_Length__c = 120;
            testDq.Seat_Count_Tier__c = 50;
            testDQ.Compliance_of_the_Request_with_Value_Pri__c = 'Yellow Test';
            testDQ.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;
            insert testDQ;
            
            Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
            dqp.Deal_Qualification__c= testDQ.id;
            //dqp.Product__c = list_Prods[1].id;
            dqp.Discount__c = 15;
            insert dqp;
            
            PPU_Regional_Tier_Discount__c tierDiscount = new PPU_Regional_Tier_Discount__c(Name='India',Gold__c=10,Bronze__c=10,Silver__c=10);
            insert tierDiscount;
            
            PPU_Term_Discount__c termDiscount = new PPU_Term_Discount__c(Name='Test',Month__c=120, Discount__c=10, Range__c='0 - 5%');
            insert termDiscount;
            
            PPU_Size_Discount__c sizeDiscount = new PPU_Size_Discount__c(Name='Test',Seat__c=50, Discount__c=10, Range__c='0 - 5%');
            insert sizeDiscount;
            
            PPU_New_Logo_Discount__c newLogo = new PPU_New_Logo_Discount__c(Name='Test',Discount__c=10, Range__c='0 - 5%');
            insert newLogo;
            
            ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
            ApexPages.currentPage().getParameters().put('id', testDQ.id);
            
            ApexPages.StandardController stdCtr = new ApexPages.StandardController(testDQ);
            DealQualificationController dealQualification = new DealQualificationController(stdCtr);
            dealQualification.dqProductIdToBeDeleted = dqp.Id;
            dealQualification.populatePPUDetails();
            dealQualification.initDiscount();
            dealQualification.revise();
            dealQualification.reviseOnLoad();
            dealQualification.save();
            dealQualification.submitForApproval();
            dealQualification.deleteDQProduct();
            dealQualification.saveFinanceApproval();
            dealQualification.unlockFinFn = 'revenue';
            dealQualification.unlockSubApprSection();
            dealQualification.unlockFinFn = 'orderMgmt';
            dealQualification.unlockSubApprSection();
            dealQualification.unlockFinFn = 'creditCol';
            dealQualification.unlockSubApprSection();
            dealQualification.unlockFinFn = 'legal';
            dealQualification.unlockSubApprSection();
            
            
            Deal_Qualification__c testDQ1 = new Deal_Qualification__c();
            testDQ1.Opportunity__c = testOpp.id;
            testDQ1.Offering_Type__c = 'Business Edition';
            testDQ1.Pricing_Type__c = 'New Pricing';
            testDQ1.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
            testDQ1.Platform_Type__c = 'Cloud';
            testDQ1.Is_Telco_Included__c = 'No';
            testDQ1.Term_Length__c = 120;
            testDq1.Seat_Count_Tier__c = 50;
            testDQ1.Compliance_of_the_Request_with_Value_Pri__c = 'Green Test';
            testDQ1.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;
            insert testDQ1;
            
            ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
            ApexPages.currentPage().getParameters().put('id', testDQ1.id);
            
            ApexPages.StandardController stdCtr1 = new ApexPages.StandardController(testDQ1);
            DealQualificationController dealQualification1 = new DealQualificationController(stdCtr1);
            
        Test.stopTest();
    }
    @isTest
    private static void unitTestTwo(){
        Test.starttest();
            Account testAccount = TestUtil.createAccounts(1, false)[0];
            testAccount.Partner_Tier__c = 'Silver';
            insert testAccount;
            
            Country__c country = new Country__c(Name='India',Country__c='India001',Region__c='India');
            insert country;
            
            Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
            testOpp.Enablement_Model__c = 'Direct Enablement';
            testOpp.Type = 'New logo';
            testOpp.Sold_To_Country__c = country.Id;
            testOpp.BusinessPartner__c = testAccount.Id;
            insert testOpp;
            
            PPU_Regional_Tier_Discount__c tierDiscount = new PPU_Regional_Tier_Discount__c(Name='India',Gold__c=10,Bronze__c=10,Silver__c=10);
            insert tierDiscount;
            
            ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
            ApexPages.currentPage().getParameters().put('id', testOpp.id);
            
            ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
            DealQualificationController dealQualification = new DealQualificationController(stdCtr);
            
            dealQualification.populatePPUDetails();
            dealQualification.initDiscount();
            //dealQualification.revise();
            dealQualification.reviseOnLoad();
            dealQualification.save();
            dealQualification.submitForApproval();
            //dealQualification.deleteDQProduct();
            
        Test.stopTest();
    }
}