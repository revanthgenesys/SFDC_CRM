@isTest
private class PartnerRevenueDetailsControllerTest {
    @isTest(SeeAllData=false)
    static void TestPartnerRevenueDetailsController(){
        
        Test.startTest();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        
        Profile p = [Select Id from Profile where name = 'Genesys Portal Partner'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        System.runAs(thisUser){
            Util.Bypass_Trigger_Chk = true;
            //Create account
            Account a = new Account (Name = 'Holding Account',RecordTypeId=rc.id,Status__c='Active'); 
            insert a;
            
            //Create contact
            Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                    MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                    Designated_Partner_Contact__c=true,  Email='raotest@test.com');
            insert c;
            
            User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                                LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
            insert u;
            
            Partner_EndUser_Data__c revData = new  Partner_EndUser_Data__c(Offering_Type__c='pureEngage',Revenue_Type__c='Revenue - Cloud',Revenue_Year__c='2018',
                                                        Revenue_Amount__c=120000,CurrencyIsoCode='USD',Account__c = a.Id,Solutions_Multiplier__c=1000.0);
            insert revData;
            
            Partner_Revenue_Reporting__c revCS = new Partner_Revenue_Reporting__c(Name='Revenue - Cloud');
            insert revCS;
            
            list<global_setting__c> glgSetLst = new list<global_setting__c>();
            Global_setting__c perfDashb = new Global_setting__c(Name='Performance Dash 2019',Information__c='2019,2020,2021,2022,2023,2024,2025');
            Global_setting__c optyRecTp = new Global_setting__c(Name='GEN - Opportunity Record Type',Information__c='RecordType',ID__c='012U0000000LrBP',Type__c='Opportunity');
            Global_setting__c cldBknTp = new Global_setting__c(Name='Cloud Booking Type',
                                                                Information__c='PureConnect Cloud,PureConnect Premise Subscription,PureConnect Premise Rental,PureConnect Cloud Partner PPU,PureEngage Cloud,PureEngage Premise Subscription,PureEngage Premise Rental,PureEngage Cloud Partner PPU,PureCloud',
                                                                ID__c='Cloud');
            Global_setting__c LicBkTp = new Global_setting__c(Name='License Booking Type',Information__c='PureConnect Premise,PureEngage Premise',ID__c='License');
            Global_setting__c RevTpTN = new Global_setting__c(Name='Revenue Types 2019 Dash',Information__c='Revenue - Cloud,Revenue - License,Total');
            Global_setting__c tstCS1 = new Global_setting__c(Name='Cloud PureConnect',Information__c='\'PureConnect Cloud\'');
            Global_setting__c tstCS2 = new Global_setting__c(Name='Cloud PureEngage',Information__c='\'PureEngage Cloud\'');
            Global_setting__c tstCS3 = new Global_setting__c(Name='License PureConnect',Information__c='\'PureConnect Premise\'');
            Global_setting__c tstCS4 = new Global_setting__c(Name='License PureEngage',Information__c='\'PureEngage Premise\'');
            glgSetLst.add(perfDashb);
            glgSetLst.add(optyRecTp);
            glgSetLst.add(cldBknTp);
            glgSetLst.add(LicBkTp);
            glgSetLst.add(RevTpTN);
            glgSetLst.add(tstCS1);
            glgSetLst.add(tstCS2);
            glgSetLst.add(tstCS3);
            glgSetLst.add(tstCS4);
            insert glgSetLst; 
            
            list<Opportunity> testOpp1 = TestUtil.createOpportunities(3, a.id, false);
            testOpp1[0].Closedate = date.newinstance(2018, 2, 17);
            testOpp1[0].Lines_of_Businesses__c='PureCloud';
            testOpp1[0].BusinessPartner__c = a.id;
            testOpp1[0].Win_Loss_Status__c = 'Won';
            testOpp1[0].RecordTypeId = '012U0000000LrBP';
            
            testOpp1[1].Closedate = date.newinstance(2019, 2, 18);
            testOpp1[1].StageName = '6.Closed';
            testOpp1[1].Win_Loss_Status__c = 'Won';
            testOpp1[1].RecordTypeId = '012U0000000LrBP';
            testOpp1[1].BusinessPartner__c = a.id;
            testOpp1[1].Lead_Offer__c = 'PureConnect Premise';
            
            testOpp1[2].Closedate = date.newinstance(2019, 2, 18);
            testOpp1[2].StageName = '6.Closed';
            testOpp1[2].Win_Loss_Status__c = 'Won';
            testOpp1[2].RecordTypeId = '012U0000000LrBP';
            testOpp1[2].BusinessPartner__c = a.id;
            testOpp1[2].Lead_Offer__c = 'PureConnect Cloud';
            
            insert testOpp1;
        
            Test.setCurrentPageReference(Page.PartnerRevenueDetails);
            System.currentPageReference().getParameters().put('ry', '2018');
            System.currentPageReference().getParameters().put('rt', 'Total');
            System.currentPageReference().getParameters().put('lua', a.Id);
            System.currentPageReference().getParameters().put('ot','pureEngage');
            PartnerRevenueDetailsController rsController = new PartnerRevenueDetailsController();
            rsController.pAccount = a;
            rsController.pUser = u;
            
            Test.setCurrentPageReference(Page.PartnerRevenueDetails);
            System.currentPageReference().getParameters().put('ry', '2018');
            System.currentPageReference().getParameters().put('rt', 'Total');
            System.currentPageReference().getParameters().put('lua', a.Id);
            System.currentPageReference().getParameters().put('sm','true');
            PartnerRevenueDetailsController rsController1 = new PartnerRevenueDetailsController();
            rsController1.pAccount = a;
            rsController1.pUser = u;
            
            Test.setCurrentPageReference(Page.PartnerRevenueDetails);
            System.currentPageReference().getParameters().put('ry', '2019');
            System.currentPageReference().getParameters().put('rt', 'Revenue - Cloud');
            System.currentPageReference().getParameters().put('lua', a.Id);
            System.currentPageReference().getParameters().put('ot','PureConnect Cloud');
            PartnerRevenueDetailsController rsController2 = new PartnerRevenueDetailsController();
            rsController2.pAccount = a;
            rsController2.pUser = u;

            Test.setCurrentPageReference(Page.PartnerRevenueDetails);
            System.currentPageReference().getParameters().put('ry', '2019');
            System.currentPageReference().getParameters().put('rt', 'Total');
            System.currentPageReference().getParameters().put('lua', a.Id);
            System.currentPageReference().getParameters().put('ot','PureCloud');
            PartnerRevenueDetailsController rsController3 = new PartnerRevenueDetailsController();
            rsController3.pAccount = a;
            rsController3.pUser = u;
            
            Test.stopTest();
        }   
        
    }
}