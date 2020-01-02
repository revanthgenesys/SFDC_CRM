@isTest (seeAllData=true)
public class PartnerPortalRegistration_Class_Test {
    
    private static partner_portal_prospect__c  pOpp1;
    private static Account  acnt;
    private static Contact cnt;
    private static User user;

    static testMethod void testMethod_1() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;
        
        System.runAs(testUser){
            
            pOpp1 = new partner_portal_prospect__c
                                ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Request Submitted', Genesys_AE__c='exec',
                                Opportunity_Currency__c = 'USD - U.S. Dollar',Lead_Offer__c='PureConnect Premise', End_User_Account__c=testAccount.id, What_is_the_Expected_Close_Date__c=system.today());
                                               
            List<Product2> prd = [select id,name from product2 where isActive=true limit 2]; 
           //insert pOpp1 ;
            ApexPages.StandardController sc1 = new ApexPages.standardController(pOpp1);                
            PartnerPortalRegistration_Class controller1 = new PartnerPortalRegistration_Class(sc1); 
            controller1.oppProdsTab1.add(new PartnerPortalRegistration_Class.oppProduct(prd[0], 1));
            controller1.oppProdsTab1.add(new PartnerPortalRegistration_Class.oppProduct(prd[1], 2));
            //controller1.resetCurriency();
            if ( !controller1.oppProdsTab1.isEmpty() ) {
                controller1.oppProdsTab1[0].isSelected = true;
                controller1.oppProdsTab1[0].amount = '123';
            }
          //  PartnerPortalRegistration_Class.oppProduct  prdc = new PartnerPortalRegistration_Class.oppProduct(prd[0],0);
            controller1.opp.opportunity_Currency__c = 'USD';
            controller1.saveOpp();
            controller1.cancelOpp();  
            controller1.resetCurriency();  
            
        }
    }
}