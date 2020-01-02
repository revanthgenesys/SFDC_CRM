@isTest(SeeAllData = true)
public class PartnerRoles_Test {
    
    static Contact testContact;
    static testmethod void testmethod1(){
        
        
        Test.startTest();
        
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            
            List<User> runAsUser = [select Id,name,contactid from user where isactive = true  and contactid != null and name = 'Damon Watson' limit 1];
            
            
                
       
            

            System.runAs(runAsUser[0]) 
            {
                System.debug('@runAsUser[0] ' +runAsUser[0]);
                
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                insert list_Accounts;
                
                 System.debug('@list_Accounts[0] ' +list_Accounts[0]);
                
                 Partner_Application__c partApp = new Partner_Application__c();
                 partApp.Status__c = 'Approved';
                 partApp.Account__c = list_Accounts[0].id;
                 partApp.Company_Name__c = 'ABC';
                 partApp.AnnualSalesRevenue_PL__c = 'Yes';
                 partApp.Ownership_PL__c =  'Yes';
                 partApp.RightToAppointOrDismiss_PL__c =  'Yes';
                 partApp.AppointOrDismissMD_PL__c =  'Yes';
                 partApp.Government_Veto_PL__c =  'Yes';
                 partApp.PublicInternationalOrg_PL__c =  'Yes';
                 partApp.Convicted_Executive_PL__c =  'Yes';
                 partApp.BannedEmployee_PL__c =  'Yes';
                 partApp.ExportEnforcementActivity_PL__c =  'Yes';
                 partApp.CountryCurrentlyUnderUS_PL__c = 'Yes'; 
                 partApp.Conflict_of_Interest_PL__c =  'Yes';
                 partApp.Current_or_Former_Genesys_Employee_PL__c = 'Yes';
                
                 insert partApp;
              
               // System.debug('@partApp ' +partApp);
                
                Contact testContact = TestUtil.createContacts(1, list_Accounts[0], true)[0];
                
                //testContact.Self_Service_Elements_Access__c = true;
                //update testContact;
                
                System.debug('@testContact ' +testContact);
                PartnerRoles partnerRolesObj = new PartnerRoles();
                partnerRolesObj.getPMRole();
                partnerRolesObj.getuserAccountId();
                
            }
        
        
        
        
        
        
        Test.stopTest();
        
        
        
    }    
    
    static testmethod void testmethod2(){
        
        
        Test.startTest();
        
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            
            List<User> runAsUser = [select Id,name,contactid from user where isactive = true  and contactid != null and name = 'Faisal Mustafa' limit 1];
            
            
                
       
            

            System.runAs(runAsUser[0]) 
            {
                System.debug('@runAsUser[0] ' +runAsUser[0]);
                
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                list_Accounts[0].PartnerType__c = 'Technology Partner';
                insert list_Accounts;
                
                
                 System.debug('@list_Accounts[0] ' +list_Accounts[0]);
                
                 Partner_Application__c partApp = new Partner_Application__c();
                 partApp.Status__c = 'Approved';
                 partApp.Account__c = list_Accounts[0].id;
                 partApp.Company_Name__c = 'ABC';
                 partApp.AnnualSalesRevenue_PL__c = 'Yes';
                 partApp.Ownership_PL__c =  'Yes';
                 partApp.RightToAppointOrDismiss_PL__c =  'Yes';
                 partApp.AppointOrDismissMD_PL__c =  'Yes';
                 partApp.Government_Veto_PL__c =  'Yes';
                 partApp.PublicInternationalOrg_PL__c =  'Yes';
                 partApp.Convicted_Executive_PL__c =  'Yes';
                 partApp.BannedEmployee_PL__c =  'Yes';
                 partApp.ExportEnforcementActivity_PL__c =  'Yes';
                 partApp.CountryCurrentlyUnderUS_PL__c = 'Yes'; 
                 partApp.Conflict_of_Interest_PL__c =  'Yes';
                 partApp.Current_or_Former_Genesys_Employee_PL__c = 'Yes';
                
                 insert partApp;
              
               // System.debug('@partApp ' +partApp);
                
                Contact testContact = TestUtil.createContacts(1, list_Accounts[0], true)[0];
                
                //testContact.Self_Service_Elements_Access__c = true;
                //update testContact;
                
                System.debug('@testContact ' +testContact);
                PartnerRoles partnerRolesObj = new PartnerRoles();
                partnerRolesObj.getPMRole();
                partnerRolesObj.getuserAccountId();
                
            }
        
        
        
        
        
        
        Test.stopTest();
        
        
        
    }    
    
    static testmethod void testmethod3(){
        
        
        Test.startTest();
        
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            
            List<User> runAsUser = [select Id,name,contactid from user where isactive = true  and contactid != null and name = 'Stephen Baker' limit 1];
            
            
                
       
            

            System.runAs(runAsUser[0]) 
            {
                System.debug('@runAsUser[0] ' +runAsUser[0]);
                
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                insert list_Accounts;
                
                 System.debug('@list_Accounts[0] ' +list_Accounts[0]);
                
                 Partner_Application__c partApp = new Partner_Application__c();
                 partApp.Status__c = 'Approved';
                 partApp.Account__c = list_Accounts[0].id;
                 partApp.Company_Name__c = 'ABC';
                 partApp.AnnualSalesRevenue_PL__c = 'Yes';
                 partApp.Ownership_PL__c =  'Yes';
                 partApp.RightToAppointOrDismiss_PL__c =  'Yes';
                 partApp.AppointOrDismissMD_PL__c =  'Yes';
                 partApp.Government_Veto_PL__c =  'Yes';
                 partApp.PublicInternationalOrg_PL__c =  'Yes';
                 partApp.Convicted_Executive_PL__c =  'Yes';
                 partApp.BannedEmployee_PL__c =  'Yes';
                 partApp.ExportEnforcementActivity_PL__c =  'Yes';
                 partApp.CountryCurrentlyUnderUS_PL__c = 'Yes'; 
                 partApp.Conflict_of_Interest_PL__c =  'Yes';
                 partApp.Current_or_Former_Genesys_Employee_PL__c = 'Yes';
                
                 insert partApp;
              
               // System.debug('@partApp ' +partApp);
                
                Contact testContact = TestUtil.createContacts(1, list_Accounts[0], true)[0];
                
                //testContact.Self_Service_Elements_Access__c = true;
                //update testContact;
                
                System.debug('@testContact ' +testContact);
                PartnerRoles partnerRolesObj = new PartnerRoles();
                partnerRolesObj.getPMRole();
                partnerRolesObj.getuserAccountId();
                
            }
        
        
        
        
        
        
        Test.stopTest();
        
        
        
    }    
    

}