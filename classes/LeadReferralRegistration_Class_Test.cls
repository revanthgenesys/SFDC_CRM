@isTest(seeAllData=true)
private class LeadReferralRegistration_Class_Test {
    
    private static Lead_Referral_Registration__c  pLead;
    private static Account  acnt;
    private static Contact cnt;
    private static User user;

    static testMethod void testMethod_1() {
     User U0 = [SELECT Id, Name, UserRoleId, ProfileId, Username FROM User WHERE IsActive = True AND (Profile.Name = 'System Administrator') AND (UserRole.Name = 'System Administrator') limit 1];
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User_PP' LIMIT 1]; 
        system.RunAs(U0){
      Test.startTest();
     
      UserRole portalRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];     
      Account testAccount = TestUtil.createAccounts(1, true)[0];
  
      Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
      User testUser;      
      testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);      
      testUser.ContactId = testContact.id;
     // testUser.UserRoleId = portalRole.Id;
      insert testUser;
         
      pLead = new Lead_Referral_Registration__c( Name='Test Lead', Status__c = 'Request Submitted' );            
         
        
      insert pLead;

      //System.runAs(testUser){
          PageReference myVfPage = Page.LeadReferralRegistration;
            
            Test.setCurrentPage(myVfPage);
        //pLead = Partner_TestUtil.createPartnerLeads(1,true)[0];
        ApexPages.currentPage().getParameters().put('id', pLead.Id);
        ApexPages.currentPage().getParameters().put('ro', 'test');
        ApexPages.currentPage().getParameters().put('runAs', testUser.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(pLead);                
        LeadReferralRegistration_Class controller = new LeadReferralRegistration_Class(sc); 
      
        controller.saveleadReferralObj();
        controller.cancelleadReferralObj(); 
        Lead_Referral_Registration__c ObjLead_c=new Lead_Referral_Registration__c();
        ObjLead_c.Name='';
        ObjLead_c.Account__c=testAccount.Id;
        Insert ObjLead_c; 
        //controller.leadReferralObj=Null;        
        //controller.saveleadReferralObj();
        controller.leadReferralObjId='';
        controller.saveleadReferralObj();
        Lead_Referral_Registration__c objleadReferral=New Lead_Referral_Registration__c();   
        objleadReferral.Channel_Manager__c=null;
        Insert objleadReferral;
        controller.leadReferralObj=objleadReferral;
        controller.saveleadReferralObj();  
       }
       Test.stopTest();
      // }
    }
}