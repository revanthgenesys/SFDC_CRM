/*
Created By:    Swastika Rajkhowa-Rsystems(12/Jan/2016)
Function:      Test Class for Class  WowRequestUserAccess
*/
@isTest(seealldata=true)
public class WowRequestUserAccess_test{
      public static testmethod void testmethod1(){       
            test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:UserInfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;
            
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'Anguilla'] ;   
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='On Premise';
            ObjOpp.Account=lstAcc[0];
            ObjOpp.BusinessPartner__c=lstAcc[0].Id;
            ObjOpp.Primary_Solution_Category__c='Analytics';
            ObjOpp.CloseDate=date.today();
            ObjOpp.CurrencyISOCode='USD';
            ObjOpp.Country__c=objCountry.Id;
            insert ObjOpp;
            
              LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='';
            objWow1.AE__c=UserInfo.getUserId();            
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;     
            
            objWow1.Lead__c=UserInfo.getUserId();
            objWow1.SE__c=UserInfo.getUserId();
            update objWow1;  
            objWow1.BC__c=UserInfo.getUserId();
            objWow1.SEM__c=UserInfo.getUserId();
            
            update objWow1;  
            
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('view', 'Yes'); 
            ApexPages.StandardController sc = new ApexPages.standardController(objWow1);            
            WowRequestUserAccess objWow=new WowRequestUserAccess(); 
           //objWow.pageSize=10;
            objWow.searchWow();
            objWow.getprev();
            objWow.getnxt();
            //objWow.pageN=2;           
            objWow.FirstPage();
          	objWow.next();
            objWow.previous();
            //objWow.LastPage();                      
            test.stoptest();          
               
    }
    
    public static testmethod void testmethod2(){       
            
            Profile p = [SELECT Id FROM Profile WHERE Name='GEN - Direct Touch APAC']; 
            User u2 = new User(Alias = 'newUser', Email='newuser6789@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='newuser6789@testorg.com',Bypass_Triggers__c =true);

            System.runAs(u2)
            {
            test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user
            user objUser=[SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'Anguilla'] ;   
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='On Premise';
            ObjOpp.Account=lstAcc[0];
            ObjOpp.BusinessPartner__c=lstAcc[0].Id;
            ObjOpp.Primary_Solution_Category__c='Analytics';
            ObjOpp.CloseDate=date.today();
            ObjOpp.CurrencyISOCode='USD';
            ObjOpp.Country__c=objCountry.Id;
            insert ObjOpp;
            
              LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='';
            objWow1.AE__c=UserInfo.getUserId();            
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;     
            
            objWow1.Lead__c=UserInfo.getUserId();
          //  objWow1.SE__c=UserInfo.getUserId();
            update objWow1;  
          //  objWow1.BC__c=UserInfo.getUserId();
         //   objWow1.SEM__c=UserInfo.getUserId();
            
            update objWow1;  
            
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('view', 'Yes');                      
            WowRequestUserAccess objWow=new WowRequestUserAccess(); 
           // objWow.pageSize=10;
            objWow.searchWow();
            objWow.getprev();
            objWow.getnxt();
            //objWow.pageNumber=2;           
            objWow.FirstPage();
            objWow.next();
            objWow.previous();
            //objWow.LastPage();
            test.stoptest(); 
            }    
    }
    public static testmethod void testmethod3(){       
            
            Profile p = [SELECT Id FROM Profile WHERE Name='GEN - Direct Touch APAC']; 
            User u2 = new User(Alias = 'newUser', Email='newuser6789@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='newuser6789@testorg.com',Bypass_Triggers__c =true);

            System.runAs(u2)
            {
            test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user
            user objUser=[SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'Anguilla'] ;   
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='On Premise';
            ObjOpp.Account=lstAcc[0];
            ObjOpp.BusinessPartner__c=lstAcc[0].Id;
            ObjOpp.Primary_Solution_Category__c='Analytics';
            ObjOpp.CloseDate=date.today();
            ObjOpp.CurrencyISOCode='USD';
            ObjOpp.Country__c=objCountry.Id;
            insert ObjOpp;
            
              LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='';
            objWow1.AE__c=UserInfo.getUserId();            
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;     
            
            //objWow1.Lead__c=UserInfo.getUserId();
            //objWow1.SE__c=UserInfo.getUserId();
            //update objWow1;  
            //objWow1.BC__c=UserInfo.getUserId();
            //objWow1.SEM__c=UserInfo.getUserId();
            
            update objWow1;  
            
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('view', 'Yes'); 
            //ApexPages.StandardController sc = new ApexPages.standardController(objWow1);            
            WowRequestUserAccess objWow=new WowRequestUserAccess(); 
            //objWow.pageSize=10;
            objWow.searchWow();
            objWow.getprev();
            objWow.getnxt();
            //objWow.pageNumber=2;           
            objWow.FirstPage();
            objWow.next();
            objWow.previous();
            //objWow.LastPage();
            test.stoptest();  
            }    
    }
}