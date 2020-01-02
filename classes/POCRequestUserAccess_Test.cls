/*
Created By:    Mahesh Varde -Rsystems(10/10/2017)
Function:      Test Class for Class  POCRequestUserAccess
*/
@isTest(seealldata=true)
public class POCRequestUserAccess_Test{
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
            
           
            
             POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.POC_Status__c='Open and Not Assigned';            
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='';  
            objPOC.Total_Amount__c=100.00;
            objPOC.Platform_Type__c='Test Platform';
            objPOC.Customer_Name__c='Test Customer';
            objPOC.Business_Partner__c='Test BusinessPartner';
            objPOC.Primary_Solution__c='Test PrimarySolution';
            objPOC.Expected_Closed_Date__c=Date.Today();
            insert objPOC;    
          
            
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('view', 'Yes'); 
            ApexPages.StandardController sc = new ApexPages.standardController(objPOC);            
            POCRequestUserAccess objWow=new POCRequestUserAccess(sc); 
           //objWow.pageSize=10;
            objWow.FilterUsers();
            objWow.previous();
            objWow.next();
            //objWow.pageN=2;           
            objWow.last();
            objWow.last();
            objWow.previous();
            //objWow.LastPage();                      
            test.stoptest();          
               
    }
}