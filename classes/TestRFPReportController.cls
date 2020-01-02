@isTest
private class TestRFPReportController{
    //Test Method to test unit case where there are no results of RFP records
    static testmethod void testEmptyResults(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser112211@testorg.com');
        insert u;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'Test Country';
        testCountry.Country__c = 'Test Country';
        testCountry.Region__c = 'LATAM';
        testCountry.RU__c = 'North America';
        insert testCountry;
        
        Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
        insert objTestAccount;
        
        Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
        objTestOppty.CloseDate = Date.today().addMonths(1);
        objTestOppty.StageName = '1.Recognize Needs';     
        objTestOppty.CurrencyIsoCode = 'BRL';
        objTestOppty.Sold_To_Country__c = testCountry.id;
        objTestOppty.Previous_Maintenance_Rate__c = 0;
        objTestOppty.BusinessPartner__c = objTestAccount.Id;
        objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
        
        insert objTestOppty;
        
        DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
        objSCE.Account_ID__c = objTestAccount.id;
        objSCE.Opportunity_ID__c = objTestOppty.id;
        objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
        objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
        objSCE.Design_End_Date__c = Date.Today().addDays(10);
        
        insert objSCE;
        
        RFP_Support_Request__c rfpReq = new RFP_Support_Request__c();
        rfpReq.Opportunity__c = objTestOppty.Id;
        rfpReq.Account__c = objTestAccount.Id;
        rfpReq.Proposal_Status__c = 'Request For Support';
        insert rfpReq;
           
        DSR_Virtual_Team__c dsrVirtualTeam = new DSR_Virtual_Team__c();
        dsrVirtualTeam.Virtual_User_Role__c = 'Virtual Team';
        dsrVirtualTeam.IsPrimary__c = true;
        dsrVirtualTeam.Virtual_User_type__c = 'Solution Consultant';
        dsrVirtualTeam.SCE_ID__c = objSCE.id ;
        dsrVirtualTeam.Virtual_Team_Member_Name__c = u.Id;
        insert dsrVirtualTeam;
        
        RFPReportController rfpSupport = new RFPReportController();   
       
        /* INC0422527  Added By Amit Gupta(Appirio)*/
        /* Start */
        rfpSupport.reportRegion = 'Global';
        rfpSupport.getRFPRecords();
        
        rfpSupport.reportRegion = 'APAC';
        rfpSupport.getRFPRecords();
        
        rfpSupport.reportRegion = 'LATAM';
        rfpSupport.getRFPRecords();
        
        rfpSupport.reportRegion = 'EMEA';
        rfpSupport.getRFPRecords();
        
        rfpSupport.reportRegion = 'NA';
        rfpSupport.getRFPRecords();
        /* End */
    }
}