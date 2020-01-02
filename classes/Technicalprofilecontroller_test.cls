@isTest(seealldata=true)
public class Technicalprofilecontroller_test {
     static Account testAccount;
      public static testmethod void testmethodTechnicalprofilecontroller(){  
          test.starttest(); 
          Technical_Profile__c techProfile=new Technical_Profile__c();         
          testAccount = TestUtil.createAccounts(1, true)[0];
          testAccount.ownerid = userInfo.getUserId();
            techProfile.Account__c = testAccount.id;
            techProfile.Name = 'Unknown';
            techProfile.Contact_Center__c = 'Unknown';
            techProfile.Contact_Center_Specify_Others__c = 'Unknown';
            techProfile.Contact_Center_Specific_Requests__c = 'Unknown';
            techProfile.Unified_Communication__c = 'Unknown';
            techProfile.Unified_Communications_Specify_Others__c = 'Unknown';
            techProfile.Unified_Communications_Specific_Request__c ='Unknown';
            techProfile.Digital_Channels__c ='Unknown';
            techProfile.Digital_Channels_Specify_Other__c = 'Unknown';          
            techProfile.Digital_Channels_Specific_Requests__c = 'Unknown';
            techProfile.Infrastructure_Deployment_Model__c = 'Unknown';
            techProfile.Genesys_Routing_Role__c = 'Unknown';
            techProfile.WEM_Solution__c = 'Unknown';
            techProfile.WEM_Solution_Specify_Others__c = 'Unknown';
            techProfile.WEM_Solution_Specific_Requests__c = 'Unknown';
            techProfile.Predictive_Journey_Analytics__c = 'Unknown';
            techProfile.Predictive_JA_Specify_Others__c = 'Unknown';
            techProfile.Predictive_JA_Specific_Requests__c = 'Unknown';
            techProfile.CRM_Vendors__c = 'Unknown';
            techProfile.CRM_Vendor_Specify_Others__c = 'Unknown';
            techProfile.CRM_Vendor_Specific_Requests__c = 'Unknown';
            techProfile.Voice_IVR_Vendor__c = 'Unknown';
            techProfile.Voice_IVR_Vendor_Specify_Others__c = 'Unknown';
            techProfile.Voice_IVR_Vendor_Specific_Requests__c ='Unknown';
            techProfile.Voice_Chat_Bots__c = 'Unknown';
            techProfile.Voice_Chat_Bots_Specify_Others__c = 'Unknown';
            techProfile.Voice_Chat_Bots_Specific_Requests__c = 'Unknown';
            techProfile.Multichannel_Campaign_Management__c   = 'Unknown';
            techProfile.Multichannel_CM_Specify_Others__c = 'Unknown';
            techProfile.Multichannel_Campaign_Mgmt_Specific__c = 'Unknown';
            techProfile.Digital_Marketing_Hubs__c = 'Unknown';
            techProfile.Digital_Marketing_Hubs_Specify_Other__c   = 'Unknown';
            techProfile.Digital_Marketing_Hubs_Specific_Request__c = 'Unknown';
            techProfile.Salesforce_Automation__c = 'Unknown';
            techProfile.Salesforce_Automation_Specify_Others__c = 'Unknown';
            techProfile.Salesforce_Automation_Specific_Requests__c = 'Unknown';
            techProfile.CRM_Lead_Management__c = 'Unknown';
            techProfile.CRM_Lead_Management_Specify_Others__c = 'Unknown';
            techProfile.CRM_Lead_Management_Specific_Requests__c = 'Unknown';
            techProfile.Digital_Commerce_Platform__c = 'Unknown';
            techProfile.Digital_Commerce_Platform1__c = 'Unknown';
            techProfile.Digital_Commerce_Platform_Specific__c = 'Unknown';
            techProfile.Business_Process_Management_Suites__c = 'Unknown';
            techProfile.Business_Process_Mgmt_Suites_Specify__c = 'Unknown';
            techProfile.Business_Process_Mgmt_Suites_Specific__c = 'Unknown';
            techProfile.Master_Data_Management_Customer_Data__c = 'Unknown';
            techProfile.Master_Data_Mgmt_Cust_Data_Specify__c = 'Unknown';
            techProfile.Master_Data_Mgmt_Cust__c = 'Unknown';
            techProfile.Evolution_of_CERM_Profile__c = 'Unknown';
          insert techProfile;

          PageReference pageRef = Page.TechProfile;
          Test.setCurrentPage(pageRef);          
          pageRef.getParameters().put('id',techProfile.id);
          ApexPages.StandardController sc = new ApexPages.standardController(techProfile);
          TechnicalProfileController objTechProfile=new TechnicalProfileController(sc);
          objTechProfile.save();           
          objTechProfile.Cancel();
          objTechProfile.test1();      
          
         
          
          
          
    test.stopTest();
      }
    public static testmethod void testmethodTechnicalprofilecontroller1()
    {
         PageReference pageRef1 = Page.TechProfile;
          Test.setCurrentPage(pageRef1); 
        Technical_Profile__c techProfile=new Technical_Profile__c(); 
        testAccount = TestUtil.createAccounts(1, true)[0];
          pageRef1.getParameters().put('accId',  testAccount.id); 
          ApexPages.StandardController sc1 = new ApexPages.standardController(techProfile);
          TechnicalProfileController objTechProfile1 =new TechnicalProfileController(sc1);
          objTechProfile1.save();           
        
    }

}