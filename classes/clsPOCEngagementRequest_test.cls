/*
Created By:    Swastika Rajkhowa(01/July/2016)
Function:      Test Class for Class  clsPOCEngagementRequest,BatchPOCMailNotifiactionLeadSLA,POCRequestUserAccess,POCSLANotificationSchedulableJob    
*/
@isTest(seealldata=true)
public class clsPOCEngagementRequest_test{
    public static testmethod void testmethodclsPOCEngagementRequest1(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create POC
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
        
        	//18/11/19 Muthu Added below code for code coverage  
        	POCUtility.CreateHistory('Test_Action','Type','SubType', userinfo.getuserid(),'User', 'TestStage','testStatus',objPOC.Id);
        	List<POCVirtualUser__c> NewVT = new List<POCVirtualUser__c>();
        	String result=POCUtility.SendEmailNotification('Lead Assigned',objPOC.Id,NewVT);
            
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('view', 'Yes');
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
                       
            //objclsPOC.SubmitWowDetails();
            
            test.stoptest();
    }
    
    	@isTest(seealldata=false)
    	private static void getSubRegionalUserstest(){
        Wow_Sub_Regional_Users__c testrec = new Wow_Sub_Regional_Users__c();
        testrec.Segment__c = 'Commercial';
        testrec.Offering_Type__c='PureCloud';
        testrec.Name='testrecord';
        testrec.SubRegion__c='Andean';
        testrec.Region__c='Test';
        insert testrec;
        Id LeaderId = POCUtility.getSubRegionalUsers('Test','Andean');
        List<String> results=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Andean','PureCloud');
        List<String> results2=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Andean','PureEngage');
        List<String> results3=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Sample','PureEngage');
        List<String> results4=POCUtility.getSubRegionalNewUsersForSharing('','Sample','PureEngage');
        List<Wow_Sub_Regional_Users__c> subregions = POCUtility.getSubRegionalNewUsersName('Commercial','Andean','PureCloud');
        List<Wow_Sub_Regional_Users__c> subregions2 = POCUtility.getSubRegionalNewUsersName('Commercial','Andean','PureEngage');
        List<Wow_Sub_Regional_Users__c> subregions3 = POCUtility.getSubRegionalNewUsersName('','Andean','PureEngage');
       
    }
    public static testmethod void testmethodclsPOCEngagementRequest2(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create POC
            POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='Lead Assign'; 
            insert objPOC; 
            
            POCVirtualUser__c objVT = new POCVirtualUser__c();
            objVT.Solution_Consultant__c=objUser.Id;
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.POC_Engagement_Request__c=objPOC.Id;
            insert objVT;
            
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            objclsPOC.SubmitWowDetails();
            
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest3(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create POC
            POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='Lead Completed'; 
            insert objPOC; 
            
            POCVirtualUser__c objVT = new POCVirtualUser__c();
            objVT.Solution_Consultant__c=objUser.Id;
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.POC_Engagement_Request__c=objPOC.Id;
            insert objVT;
            
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            //objclsPOC.SubmitWowDetails();
            
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest4(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create POC
            POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='Virtual Team for Result'; 
            insert objPOC; 
            
            POCVirtualUser__c objVT = new POCVirtualUser__c();
            objVT.Solution_Consultant__c=objUser.Id;
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.POC_Engagement_Request__c=objPOC.Id;
            insert objVT;
            
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            objclsPOC.SubmitWowDetails();
            
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest5(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create Wow Request for Virtual Team
            POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='Virtual Team'; 
            objPOC.Main_Product__c='test1;test2';
            objPOC.Primary_Solution__c='test';
            insert objPOC; 
            
            POCVirtualUser__c objVT = new POCVirtualUser__c();
            objVT.Solution_Consultant__c=objUser.Id;
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.POC_Engagement_Request__c=objPOC.Id;
            insert objVT;
            //Create Attachment For Discovery Plan
            Attachment objAtt=new Attachment();
            objAtt.Description='POC Scope';
            objAtt.Name='Test';
            objAtt.ParentId=objPOC.Id;
            objAtt.Body=Blob.valueOf('Test');
            
            insert objAtt; 
            
            //Insert solution and product mapping
            POC_Solution_Product_Map__c objSolProd= new POC_Solution_Product_Map__c();
            objSolProd.POC_Request_Id__c = objPOC.Id;
            objSolProd.Primary_Solution__c = 'testSolution';
            objSolProd.Products__c = 'testProduct';
            insert objSolProd;
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            objclsPOC.SaveWowDetails(); 
            /*
             //Upload file
            objclsPOC.FileDescType = 'POC Scope';
            objclsPOC.fileBody=Blob.valueOf('Test');            
            objclsPOC.fileName = 'test';            
            objclsPOC.UploadFile();            
            
            objclsPOC.GetSolutionProductList();
            objclsPOC.GetVTUserList();
            objclsPOC.RemoveVTUser();
            objclsPOC.RemoveSolutionProduct();
            objclsPOC.getStatusTypes();
            objclsPOC.FileDescription();
            */            
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest6(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
                                    
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            objclsPOC.SaveWowDetails(); 
             
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest7(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
                                    
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            //objclsPOC.SubmitWowDetails(); 
             
            test.stoptest();
    }
    public static testmethod void testmethodclsPOCEngagementRequest8(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
                                    
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            objclsPOC.SaveWowDetails(); 
             
            test.stoptest();
    }
    
    public static testmethod void testmethodclsPOCEngagementRequest9(){
            test.starttest();
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
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
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11; 
            insert ObjOpp;
            
            //Create Wow Request for Virtual Team
            POC_Engagement_Request__c objPOC=new POC_Engagement_Request__c();
            objPOC.Opportunity_Id__c=ObjOpp.Id;
            objPOC.AssignTo__c='Virtual Team'; 
            objPOC.Main_Product__c='test1;test2';
            objPOC.Primary_Solution__c='test';
            insert objPOC; 
            
            //Create Attachment For Discovery Plan
            Attachment objAtt=new Attachment();
            objAtt.Description='POC Scope';
            objAtt.Name='Test';
            objAtt.ParentId=objPOC.Id;
            objAtt.Body=Blob.valueOf('Test');
            
            insert objAtt; 
            
            //Insert solution and product mapping
            POC_Solution_Product_Map__c objSolProd= new POC_Solution_Product_Map__c();
            objSolProd.POC_Request_Id__c = objPOC.Id;
            objSolProd.Primary_Solution__c = 'testSolution';
            objSolProd.Products__c = 'testProduct';
            insert objSolProd;
            //Set Page and Query string
            PageReference pageRef = Page.POCEngagementRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            clsPOCEngagementRequest objclsPOC=new clsPOCEngagementRequest();
            
            //objclsPOC.SubmitWowDetails(); 
            /*
             //Upload file
            objclsPOC.FileDescType = 'POC Scope';
            objclsPOC.fileBody=Blob.valueOf('Test');            
            objclsPOC.fileName = 'test';            
            objclsPOC.UploadFile();            
            
            objclsPOC.GetSolutionProductList();
            objclsPOC.GetVTUserList();
            objclsPOC.RemoveVTUser();
            objclsPOC.RemoveSolutionProduct();
            objclsPOC.getStatusTypes();
            objclsPOC.FileDescription();
            */   
            objclsPOC.AddFunctionUseCase();
            objclsPOC.RemoveFunctionalUseCase();   
            objclsPOC.DeleteVirtualUsers();
            objclsPOC.UploadFile();
            //objclsPOC.DeleteAttachment();
            objclsPOC.RemoveSolutionProduct();
            objclsPOC.GetVTUserList();
            objclsPOC.RemoveVTUser();
            objclsPOC.GetSolutionProductList();
            objclsPOC.getStatusTypes(); 
            objclsPOC.FileDescription();   
            test.stoptest();
    }
    //Test method for Batch Class  BatchPOCMailNotifiactionLeadSLA
      public static testmethod void testmethodBatchWoWMailNotifiactionLeadSLA(){       
            test.starttest();   
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ; 
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='ANZ';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='abc';
            insert cs;
              
            //Create Opportunity
            Opportunity objOpp=new Opportunity();
            objOpp.Name='Test';
            objOpp.CurrencyIsoCode='USD';
            objOpp.StageName='Test Stage';
            objOpp.Owner=objUser;
            objOpp.Primary_Line_of_Business__c='On Premise';
            objOpp.Account=lstAcc[0];
            objOpp.BusinessPartner__c=lstAcc[0].Id;
            objOpp.Primary_Solution_Category__c='Analytics';
            objOpp.CloseDate=date.today();
            objOpp.CurrencyISOCode='USD';
            objOpp.Country__c=objCountry.Id;
            
            objOpp.Key_Business_Objective__c = 'Add on Seats';
            objOpp.Annual_Contract_Value_new__c = 11;
            objOpp.Monthly_Commitment__c = 11;
            objOpp.Estimated_Usage_Agreements_EUA__c = 11;
            objOpp.Hardware_Total__c = 11;
            objOpp.License_Amount__c = 11;
            objOpp.Total_PS_Support__c = 11;
            objOpp.Term_License__c = 11;
            
            objOpp.Total_Annual_Contract_Value__c = 11;                       
            insert objOpp; 
            
           //Create POC Request
            POC_Engagement_Request__c  objPOC=new POC_Engagement_Request__c();
            objPOC.POC_Status__c='Open and Not Assigned';
            objPOC.Opportunity_Id__c=objOpp.Id; 
            objPOC.AssignTo__c='Lead Assign';
            objPOC.CreatedDate=System.now().addhours(-120);            
            objPOC.Total_Amount__c=100.00;           
            insert objPOC;
           List<POC_Engagement_Request__c > List_POC= [SELECT Id,CreatedDate,Opportunity_Id__c,Opportunity_Id__r.Name,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Country_Sub_Region__c from POC_Engagement_Request__c  WHERE Id=:objPOC.Id];
          //Call Batch Class
          if(List_POC.size() > 0)
            { 
            BatchPOCMailNotifiactionLeadSLA objSLA = new BatchPOCMailNotifiactionLeadSLA();   
            objSLA.start(null);
            objSLA.execute(null,List_POC);
            objSLA.finish(null);  
        }
          test.stoptest();       
     }
     //test method for Scheduler class WoWSLANotificationSchedulableJob
      public static testmethod void testmethodPOCSLANotificationSchedulableJob(){
         POCSLANotificationSchedulableJob objWowSLASch= new POCSLANotificationSchedulableJob();
         String sch = '0  00 1 3 * ?';     
         system.schedule('Test', sch, objWowSLASch);
     }
     
     //test class for POCRequestUserAccess
      public static testmethod void testmethodPOCRequestUserAccess(){         
             test.starttest();
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ; 
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='ANZ';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='abc';
            insert cs;
              
            //Create Opportunity
            Opportunity objOpp=new Opportunity();
            objOpp.Name='Test';
            objOpp.CurrencyIsoCode='USD';
            objOpp.StageName='Test Stage';
            objOpp.Owner=objUser;
            objOpp.Primary_Line_of_Business__c='On Premise';
            objOpp.Account=lstAcc[0];
            objOpp.BusinessPartner__c=lstAcc[0].Id;
            objOpp.Primary_Solution_Category__c='Analytics';
            objOpp.CloseDate=date.today();
            objOpp.CurrencyISOCode='USD';
            objOpp.Country__c=objCountry.Id;
            
            objOpp.Key_Business_Objective__c = 'Add on Seats';
            objOpp.Annual_Contract_Value_new__c = 11;
            objOpp.Monthly_Commitment__c = 11;
            objOpp.Estimated_Usage_Agreements_EUA__c = 11;
            objOpp.Hardware_Total__c = 11;
            objOpp.License_Amount__c = 11;
            objOpp.Total_PS_Support__c = 11;
            objOpp.Term_License__c = 11;
            
            objOpp.Total_Annual_Contract_Value__c = 11;                       
            insert objOpp; 
            
            //Create POC Request
            POC_Engagement_Request__c  objPOC=new POC_Engagement_Request__c();
            objPOC.POC_Status__c='Open and Not Assigned';
            objPOC.Opportunity_Id__c=objOpp.Id; 
            objPOC.AssignTo__c='Lead Assign';
            objPOC.CreatedDate=System.now().addhours(-120);            
            objPOC.Total_Amount__c=100.00;           
            insert objPOC;           
                       
            ApexPages.StandardController StdApex =new ApexPages.StandardController(objPOC);
             POCRequestUserAccess objPOCAccess=new POCRequestUserAccess(StdApex);            
             objPOCAccess.FilterUsers();             
             objPOCAccess.first();
             objPOCAccess.last();
             objPOCAccess.previous();
             objPOCAccess.next();
             objPOCAccess.getTotalPages();
             
             test.stoptest();
        }
      
}