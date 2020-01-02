@isTest
public class DealQualificationSubscriptionCtrlTest{
     
     static testMethod void unitTest(){
           
         List<Country__c>  testCountries = new List<Country__c>();
        testCountries.add(new Country__c(
          Name = 'India', Region__c = 'EMEA', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
          SW_Download_Site__c = 'Canada', Old_DAP_Region__c = 'NA', Old_Sub_Region__c = 'North America', Old_Sub_Sub_Region__c = 'USA',
          price_book__c = 'NA-USD', Old_Price_Book__c = 'G5_NA_USD', New_Price_Book__c = 'NG5_NA_USD',
          Big_Four__c = 'North America', Big_Six__c = 'North America',
          Basic_Care_New_End_User__c = 18.0, Basic_Care_New_Partner__c = 18.0,
          Business_Care_New_End_User__c = 18.0, Business_Care_New_Partner__c = 18.0,
          Premium_Care_New_End_User__c = 18.0, Premium_Care_New_Partner__c = 18.0,
          Basic_Care_Renewal_End_User__c = 18.0, Basic_Care_Renewal_Partner__c = 18.0,
          Business_Care_Renewal_End_User__c = 18.0, Business_Care_Renewal_Partner__c = 18.0,
          Premium_Care_Renewal_End_User__c = 18.0, Premium_Care_Renewal_Partner__c = 18.0,
          Business_Care_New_End_User_Licensing__c = 18.0, Premium_Care_New_End_User_Licensing__c = 18.0,
          Business_Care_New_Partner_Licensing__c = 18.0, Premium_Care_New_Partner_Licensing__c = 18.0,
          Basic_Support__c = 18.0, Standard_Support__c = 18.0, Priority_Support__c = 18.0, VIP_Priority_Support__c = 18.0
        ));
        insert testCountries;
        
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.PartnerType__c = 'AppFoundry Partner';
        objAccount.Partner_Tier__c = 'Gold';
        insert objAccount;
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,objAccount.id, false)[0];
        objOpportunity.StageName = '6.Closed';
        objOpportunity.Win_Loss_Status__c = 'Won';
        objOpportunity.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        objOpportunity.Term_Commitment__c = '1 Year';
        objOpportunity.Type = 'New logo';
        objOpportunity.Competitor__c = 'Five9';
        objOpportunity.BusinessPartner__c = objAccount.id;
        objOpportunity.Sold_To_Country__c = testCountries[0].id;
        insert objOpportunity;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        //testDQ.Quote__c = quote.id;
        testDQ.Offering_Type__c = 'Test';
        testDQ.Pricing_Type__c = 'Old Pricing';
        testDQ.Type__c = 'Original';
        testDQ.PPU_Deal_Approval__c = false; 
        testDQ.Premium_Care__c = false;
        testDQ.Seat_Count_Tier__c = 2;
        testDQ.IsOldPricingApproved__c = false;
        testDQ.Term_Length__c =6;
        testDQ.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        testDQ.CarveOutDetails__c = 'test123';
        testDQ.Carveout__c = false;
        testDQ.Finance_Exception__c = 'Non-Standard Warranty';
        testDQ.Legal_Exceptions__c ='Other Non-Standard Legal Requests';
        testDQ.Opportunity__c = objOpportunity.id;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Additional_Legal_Terms__c = false;
        testDQ.Cloud_Partner_Approval__c = false;
        testDQ.X3rd_Party_Override__c = false;
        testDQ.Competitor__c = 'Cisco';
        testDQ.Is_Telco_Included__c = 'No';
        testDQ.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;
        insert testDQ;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= testDQ.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        ApexPages.currentPage().getParameters().put('id',testDQ.id); 
        ApexPages.currentPage().getParameters().put('p','Old Pricing'); 
        ApexPages.currentPage().getParameters().put('ot','Test'); 
        ApexPages.currentPage().getParameters().put('od','Test');
        ApexPages.currentPage().getParameters().put('pt','Cloud'); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testDQ);
        DealQualificationSubscriptionController dqCICcontroller = new DealQualificationSubscriptionController(sc);
        dqCICcontroller.initDiscount();
        dqCICcontroller.revise();
        dqCICcontroller.reviseOnLoad();
        dqCICcontroller.save();
        dqCICcontroller.dqProductIdToBeDeleted = dqp.id;
        dqCICcontroller.deleteDQProduct();
        dqCICcontroller.refresh();
        dqCICcontroller.submitForApproval();
        testDQ.Compliance_of_the_Request_with_Value_Pri__c = 'Yellow = Value Pricing Risk';
        update testDQ;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(testDQ);
        DealQualificationSubscriptionController dqCICcontroller1 = new DealQualificationSubscriptionController(sc1);
        dqCICcontroller1.save();
        testDQ.Compliance_of_the_Request_with_Value_Pri__c = 'Red = Value Pricing Non Compliant';
        update testDQ;
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testDQ);
        DealQualificationSubscriptionController dqCICcontroller2 = new DealQualificationSubscriptionController(sc2);
        dqCICcontroller2.save();
        dqCICcontroller.saveFinanceApproval();
        dqCICcontroller.unlockFinFn = 'revenue';
        dqCICcontroller.unlockSubApprSection();
        dqCICcontroller.unlockFinFn = 'orderMgmt';
        dqCICcontroller.unlockSubApprSection();
        dqCICcontroller.unlockFinFn = 'creditCol';
        dqCICcontroller.unlockSubApprSection();
        dqCICcontroller.unlockFinFn = 'legal';
        dqCICcontroller.unlockSubApprSection();
     }
     
     static testMethod void unitTest1(){
        
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        objAccount.PartnerType__c = 'AppFoundry Partner';
        insert objAccount;
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,objAccount.id, false)[0];
        objOpportunity.StageName = '6.Closed';
        objOpportunity.Win_Loss_Status__c = 'Won';
        objOpportunity.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        objOpportunity.License_Amount__c = 24000;
        objOpportunity.Direct_Indirect_Sale__c = 'Direct';
        insert objOpportunity;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        //testDQ.Quote__c = quote.id;
        testDQ.Offering_Type__c = 'Test';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Type__c = 'History';
        testDQ.PPU_Deal_Approval__c = false; 
        testDQ.Premium_Care__c = false;
        testDQ.IsOldPricingApproved__c = false;
        testDQ.Term_Length__c =6;
        testDQ.CarveOutDetails__c = 'test123';
        testDQ.Carveout__c = false;
        testDQ.Term_Length__c = 2;
        testDQ.Finance_Exception__c = 'Non-Standard Warranty';
        testDQ.Legal_Exceptions__c ='Other Non-Standard Legal Requests';
        testDQ.Opportunity__c = objOpportunity.id;
        testDQ.Genesys_Care__c = 'Non Standard';
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Additional_Legal_Terms__c = false;
        testDQ.Cloud_Partner_Approval__c = false;
        testDQ.X3rd_Party_Override__c = false;
        testDQ.Is_Telco_Included__c = 'No';
        testDQ.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;
        insert testDQ;
        
        
        //ApexPages.currentPage().getParameters().put('NO_REDIRECT','test');
        //ApexPages.currentPage().getParameters().put('REVISE','Test');
        ApexPages.currentPage().getParameters().put('oppId',objOpportunity.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller = new DealQualificationSubscriptionController(sc);
        dqCICcontroller.reviseOnLoad();
        
        Test.StartTest();
        objOpportunity.License_Amount__c = 49000;
        update objOpportunity;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller1 = new DealQualificationSubscriptionController(sc1);
        
        objOpportunity.License_Amount__c = 99000;
        update objOpportunity;
        ApexPages.StandardController sc2 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontrolle2r = new DealQualificationSubscriptionController(sc2);
        
        objOpportunity.License_Amount__c = 490000;
        update objOpportunity;
        ApexPages.StandardController sc3 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller3 = new DealQualificationSubscriptionController(sc3);
        
        objOpportunity.License_Amount__c = 550000;
        update objOpportunity;
        ApexPages.StandardController sc4 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller4 = new DealQualificationSubscriptionController(sc4);
        
        objOpportunity.License_Amount__c = 1100000;
        update objOpportunity;
        ApexPages.StandardController sc5 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller5 = new DealQualificationSubscriptionController(sc5);
        
        objOpportunity.License_Amount__c = 2200000;
        update objOpportunity;
        ApexPages.StandardController sc6 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller6 = new DealQualificationSubscriptionController(sc6);
        Test.StopTest();
        objOpportunity.License_Amount__c = 3300000;
        update objOpportunity;
        ApexPages.StandardController sc7 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller7 = new DealQualificationSubscriptionController(sc7);
        
        objOpportunity.License_Amount__c = 14000000;
        update objOpportunity;
        ApexPages.StandardController sc8 = new ApexPages.StandardController(objOpportunity);
        DealQualificationSubscriptionController dqCICcontroller8 = new DealQualificationSubscriptionController(sc8);
     }
}