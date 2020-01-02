/*
Created By:    Swastika Rajkhowa(04/Jan/2016)
Function:      Test Class for Class  clsWowRequestData
*/
@isTest(seealldata=true)
public class clsWowRequestData_test{

public static List<User> createUsers (Integer numToInsert, Boolean doInsert) {
      List<User> users = new List<User>();
      
      for (Integer i = 0; i< numToInsert; i++) {
          User u = new User();
          u.Username = 'aa@aa.com';    
      u.LastName= 'Test';
      u.FirstName= 'Test';
      u.Email= 'aa@aa.com';
      u.CommunityNickname= 'aaa';
      u.Alias= 'test';
      u.TimeZoneSidKey='Europe/Paris';  
      u.LocaleSidKey='fr_FR_EURO';
      u.EmailEncodingKey='ISO-8859-1';
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];     
        u.ProfileId = prof.Id;           
      u.LanguageLocaleKey='fr';
      u.isActive=true;
      u.ByPassValidationRules__c = true;
      u.EmployeeNumber = 'EMP-'+ Math.random().format();
      users.add(u);
      }
    
    if(doInsert)
      insert users;
    return users; 
            
    }

/*private static testmethod void testCreateWowUser()
         {
             List<User> pmOwner = testUtil.createUsers(1, true);
             Id MAnagerID= [ select id,ManagerId from user where id=: pmOwner[0].Id][0].ManagerId;
             Wow_Request_User__c objWowUsers=new Wow_Request_User__c();
             objWowUsers.ManagerId__c=MAnagerID;
             objWowUsers.UserId__c=pmOwner[0].Id;
             objWowUsers.User_Type__c='XYZ';
             insert objWowUsers;
         }*/
     //Test Method for clsWowRequestData class and Virtual Team
     public static testmethod void testmethodclsWowRequestDataForVirtualTeam(){
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
            
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            
            insert ObjOpp;
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='';
            objWow1.AE__c=userinfo.getUserId();
            objWow1.Lead__c=userinfo.getUserId();
            objWow1.SE__c=userinfo.getUserId();
            objWow1.BC__c=userinfo.getUserId();
            objWow1.SEM__c=userinfo.getUserId();
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;            
           
            
            //Create Attachment For Discovery Plan
            Attachment objAtt=new Attachment();
            objAtt.Description='Discovery Plan';
            objAtt.Name='Test';
            objAtt.ParentId=objWow1.Id;
            objAtt.Body=Blob.valueOf('Test');
            
            insert objAtt; 
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', lstUsr[0].Id);  
            ApexPages.currentPage().getParameters().put('view', 'yes');
            clsWowRequestData objWow=new clsWowRequestData(); 
            
            
            objWow.SaveWowDetails(); 
            test.starttest();
            objWow.SubmitWowDetails();
            
            //Upload file
            /*objWow.FileDescType = 'Discovery Finding';
            objWow.fileBody=Blob.valueOf('Test');            
            objWow.fileName = 'test';
            
            objWow.UploadFile();*/
            test.stoptest();
            
            objWow.sAttachmentId=objAtt.Id;           
            //objWow.DeleteAttachment();
            objWow.getStatusTypes();
            objWow.GetWowHistoryDetails();
            objWow.FileDescription();
            
                 
     }
     //Test Method for clsWowRequestData class and Lead Assign
     public static testmethod void testmethodclsWowRequestDataForLeadAssign(){              
             List<User> pmOwner1 = testUtil.createUsers(1, true);
             //List<User> pmOwner = createUsers(1, true);
            //test.starttest(); 
            //get Opportunity
            LIST<Opportunity> lstOpp= [Select Id,CurrencyIsoCode From Opportunity WHERE CurrencyISOCode!=NULL AND End_User_Region__c!=NULL LIMIT 2];            
            
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.AssignTo__c='Lead Assign';
            objWow1.AE__c=userinfo.getUserId();
            objWow1.Lead__c=userinfo.getUserId();
            //objWow1.SE__c=pmOwner1[0].Id;
            objWow1.BC__c=pmOwner1[0].Id;
            objWow1.SEM__c=pmOwner1[0].Id;
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;            
           
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow1.Id;
            insert objVT;
            
            //testCreateWowUser();
            
            //Create Attachment For Discovery Plan
            Attachment objAtt=new Attachment();
            objAtt.Description='Discovery Plan';
            objAtt.Name='Test';
            objAtt.ParentId=objWow1.Id;
            objAtt.Body=Blob.valueOf('Test');
            
            insert objAtt; 
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', lstOpp[0].Id);
            ApexPages.currentPage().getParameters().put('idu', lstUsr[0].Id);  
            
            clsWowRequestData objWow=new clsWowRequestData(); 
            test.starttest(); 
            
            objWow.SaveWowDetails(); 
            objWow.SubmitWowDetails();
            //test.stoptest();
            //Upload file
            /*objWow.FileDescType = 'Discovery Finding';
            objWow.fileBody=Blob.valueOf('Test');            
            objWow.fileName = 'test';
            
            objWow.UploadFile();*/
            //test.stoptest();            
            objWow.sAttachmentId=objAtt.Id;           
            //objWow.DeleteAttachment();
            objWow.getStatusTypes();
            objWow.GetWowHistoryDetails();
            objWow.FileDescription();   
            test.stoptest();       

     } 
     
     //Test Method for clsWowRequestData class and Without Wow
      public static testmethod void testmethodclsWowRequestDataForWihoutWow(){          
           //testCreateWowUser();
           //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            //find current user
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
            
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            insert ObjOpp;
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', objUser.Id);  
            clsWowRequestData objWow=new clsWowRequestData();
            
            objWow.SaveWowDetails();   
            objWow.GetVTUserList();
            objWow.RemoveVTUser();            
            
            objWow.AddBluePrint();            
            objWow.RemoveBluePrint();
            
            //objWow.pageredirSolDesgn();
            
            
            
            objWow.AddVision();
            objWow.CurrentVision ='1';          
            objWow.RemoveVisionActivity();
            objWow.AddDiscovery();  
            objWow.CurrentDiscovery ='1';             
            objWow.RemoveDiscoveryActivity();
            objWow.AddDemo();  
            //objWow.CurrentDemo = '1';        
            objWow.RemoveDemoActivity();
            objWow.AddServiceTran();  
            //objWow.CurrentServTran = '1';        
            objWow.RemoveServiceTranActivity();
            objWow.AddVisionAttachment();
            objWow.AddDiscoveryAttachment();
            //objWow.CheckLoggedInUserType('APAC');
                
      } 
        
     //Test Method for clsWowRequestData class and Lead Completed
     public static testmethod void testmethodclsWowRequestDataForLeadCompleted(){  
          test.starttest(); 
      //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            //find current user
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
            
             Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
            
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            insert ObjOpp;
            
            //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Assigned';
            objWow1.Opportunity_Id__c=ObjOpp.Id; 
            objWow1.AssignTo__c='Lead Completed';            
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;  
            
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow1.Id;
            insert objVT;
                
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', objUser.Id);  
            clsWowRequestData objWow=new clsWowRequestData(); 
            Wow_Attachments__c  objAttach1= new Wow_Attachments__c();
            objAttach1.Type__c = 'Functional Use Case';
            objAttach1.Link_URL__c ='test.com' ;
            objAttach1.Wow_Request_Form__c=  objWow1.Id;          
            insert objAttach1;
            objWow.AddFunctionUseCase();
            objWow.SubmitWowDetails();
            Wow_Attachments__c  objAttach= new Wow_Attachments__c();
            objAttach.Type__c = 'Vision';
            objAttach.Link_URL__c ='test.com' ;
            objAttach.Wow_Request_Form__c=  objWow1.Id;          
            insert objAttach;
            objWow.AddVisionLink();
            
            test.stoptest();
      }
      public static testmethod void testmethodclsWowRequestDataForLeadCompletedSave(){  
          test.starttest(); 
      //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            //find current user
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
            
             Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
            
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            insert ObjOpp;
            
            //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Assigned';
            objWow1.Opportunity_Id__c=ObjOpp.Id; 
            objWow1.AssignTo__c='Lead Completed';            
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;  
            
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow1.Id;
            insert objVT;
                
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', objUser.Id);  
            clsWowRequestData objWow=new clsWowRequestData(); 
            objWow.SaveWowDetails();            
            test.stoptest();
      }
      //test method for Scheduler class WoWSLANotificationSchedulableJob
      public static testmethod void testmethodWoWSLANotificationSchedulableJob(){
         WoWSLANotificationSchedulableJob objWowSLASch= new WoWSLANotificationSchedulableJob();
         String sch = '0  00 1 3 * ?';     
         system.schedule('Test', sch, objWowSLASch);
     }
     
      //Test method for Batch Class  BatchWoWMailNotifiactionLeadSLA
      public static testmethod void testmethodBatchWoWMailNotifiactionLeadSLA(){       
              test.starttest();   
             user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ; 
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='abc';
            insert cs;
              
            //Create Opportunity
            Opportunity objOpp=new Opportunity();
            objOpp.Name='Test';
            objOpp.CurrencyIsoCode='USD';
            objOpp.StageName='Test Stage';
            objOpp.Owner=objUser;
            objOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';                       
            insert objOpp;
          
          
            
           //Create Wow Request
          Wow_Request_Form__c objWow=new Wow_Request_Form__c();
          objWow.WoW_Status__c='Open and Not Assigned';
          objWow.Opportunity_Id__c=objOpp.Id; 
          objWow.AssignTo__c='Virtual Team';
          objWow.CreatedDate=System.now().addhours(-120);
          objWow.AE__c=userinfo.getUserId();
          objWow.Lead__c=userinfo.getUserId();
          objWow.SE__c=userinfo.getUserId();
          objWow.BC__c=userinfo.getUserId();
            objWow.SEM__c=userinfo.getUserId();
            objWow.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow.Total_Amount__c=100.00;
            objWow.Platform_Type__c='Test Platform';
            objWow.Customer_Name__c='Test Customer';
            objWow.Business_Partner__c='Test BusinessPartner';
            objWow.Primary_Solution__c='Test PrimarySolution';
            objWow.Expected_Closed_Date__c=Date.Today();
          insert objWow; 
            
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow.Id;
            insert objVT;         
          List<Wow_Request_Form__c> lstWowData= [SELECT Id,CreatedDate,Opportunity_Id__c,Opportunity_Id__r.Name,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Country_Sub_Region__c from Wow_Request_Form__c WHERE Id=:objWow.Id];
          //Call Batch Class
        if(lstWowData.size() > 0)
            { 
            BatchWoWMailNotifiactionLeadSLA objSLA = new BatchWoWMailNotifiactionLeadSLA();   
            objSLA.start(null);
            objSLA.execute(null,lstWowData);
            objSLA.finish(null);  
        }
          test.stoptest();       
     }
     
     //Test method for Class  clsWowRiskAssessment
      public static testmethod void testmethodclsWowRiskAssessment(){       
             test.starttest(); 
            
            //Create Opportunity
            LIST<Opportunity> lstOpp= [Select Id From Opportunity LIMIT 2];  
            
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            //Create Wow Request
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.AssignTo__c ='Virtual Team';
            objWow1.CreatedDate=System.now().addhours(-120);
            objWow1.AE__c=userinfo.getUserId();
            objWow1.Lead__c=userinfo.getUserId();
            objWow1.SE__c=userinfo.getUserId();
            objWow1.BC__c=userinfo.getUserId();
            objWow1.SEM__c=userinfo.getUserId();
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;             

            
            //Set Page and Query string
            PageReference pageRef = Page.WowRiskAssessment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('wowid', objWow1.Opportunity_Id__c);
            ApexPages.currentPage().getParameters().put('view', 'No');
             
            //Set the controller
            clsWowRiskAssessment contrRiskAss1 = new clsWowRiskAssessment();
            contrRiskAss1.sIsReadonly = 'No';
            contrRiskAss1.SaveData();
            contrRiskAss1.GetWowRiskAssessmentData();    
            
            
            //Create Wow Request
            Wow_Request_Form__c objWow2=new Wow_Request_Form__c();
            objWow2.WoW_Status__c='Open and Not Assigned';
            objWow2.Opportunity_Id__c=lstOpp[1].Id; 
            objWow2.AssignTo__c ='';
            objWow2.CreatedDate=System.now().addhours(-120);
            objWow2.AE__c=userinfo.getUserId();
            objWow2.Lead__c=userinfo.getUserId();
            objWow2.SE__c=userinfo.getUserId();
            objWow2.BC__c=userinfo.getUserId();
            objWow2.SEM__c=userinfo.getUserId();
            objWow2.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow2.Total_Amount__c=100.00;
            objWow2.Platform_Type__c='Test Platform';
            objWow2.Customer_Name__c='Test Customer';
            objWow2.Business_Partner__c='Test BusinessPartner';
            objWow2.Primary_Solution__c='Test PrimarySolution';
            objWow2.Expected_Closed_Date__c=Date.Today();
            insert objWow2; 
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow2.Id;
            insert objVT;
            ApexPages.currentPage().getParameters().put('wowid', objWow2.Opportunity_Id__c);
            ApexPages.currentPage().getParameters().put('view', 'Yes');
            
            //Set the controller
            clsWowRiskAssessment contrRiskAss2 = new clsWowRiskAssessment();
            contrRiskAss2.SaveData();
            contrRiskAss2.GetWowRiskAssessmentData();            
            WoWUtility.GetMandatoryMessage(objWow2.id); 
            WoWUtility.IsVirtualTeamExist(objWow2.id,userinfo.getUserId()); 
            WoWUtility.getSubRegionalUsersForSC(userinfo.getUserId());
            List<user> lstUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];
            WoWUtility.ShareWowRequest(lstUser,objWow2);
            WoWUtility.getSubRegionalUsersForSharing();
            //New method
            WoWUtility.getSubRegionalNewUsersForSharing('Test','Test','Test');
            List<WoW_Virtual_Users__c> newVTlist=[SELECT Id,Virtual_User_type__c,Virtual_User__c FROM WoW_Virtual_Users__c WHERE Virtual_User__c=:userinfo.getUserId() AND Wow_Request_Form__c =: objWow2.Id];
            WoWUtility.getDiffVTList(newVTlist,newVTlist);
            test.stoptest();       
     }
      public static testmethod void testmethodWowRequestUserAccess(){       
             test.starttest();
            LIST<Opportunity> lstOpp= [Select Id From Opportunity LIMIT 2];  
            Wow_Request_Form__c objWow2=new Wow_Request_Form__c();
            objWow2.WoW_Status__c='Open and Not Assigned';
            objWow2.Opportunity_Id__c=lstOpp[1].Id; 
            objWow2.AssignTo__c ='';
            objWow2.CreatedDate=System.now().addhours(-120);
            objWow2.AE__c=userinfo.getUserId();
            objWow2.Lead__c=userinfo.getUserId();
            objWow2.SE__c=userinfo.getUserId();
            objWow2.BC__c=userinfo.getUserId();
            objWow2.SEM__c=userinfo.getUserId();
            objWow2.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow2.Total_Amount__c=100.00;
            objWow2.Platform_Type__c='Test Platform';
            objWow2.Customer_Name__c='Test Customer';
            objWow2.Business_Partner__c='Test BusinessPartner';
            objWow2.Primary_Solution__c='Test PrimarySolution';
            objWow2.Expected_Closed_Date__c=Date.Today();
            insert objWow2;
            
            List<Attachment> list_Attach=new List<Attachment>();
            Attachment objAtt1=new Attachment();
            objAtt1.Description='Discovery Plan';
            objAtt1.ParentId=objWow2.Id;
            objAtt1.Body=Blob.valueOf('Test');
            objAtt1.Name  = 'T1';
            list_Attach.add(objAtt1);
            
            Attachment objAtt2=new Attachment();
            objAtt2.Description='Discovery Finding';
            objAtt2.ParentId=objWow2.Id;
            objAtt2.Body=Blob.valueOf('Test');
             objAtt2.Name  = 'T2';
            list_Attach.add(objAtt2);
            
            Attachment objAtt3=new Attachment();
            objAtt3.Description='Design Plan';
            objAtt3.ParentId=objWow2.Id;
            objAtt3.Body=Blob.valueOf('Test');
             objAtt3.Name  = 'T3';
            list_Attach.add(objAtt3);
            
            Attachment objAtt4=new Attachment();
            objAtt4.Description='SCToolkit';
            objAtt4.ParentId=objWow2.Id;
            objAtt4.Body=Blob.valueOf('Test');
            objAtt4.Name  = 'T4';
            list_Attach.add(objAtt4);
            
            Attachment objAtt5=new Attachment();
            objAtt5.Description='Architectural BluePrint';
            objAtt5.ParentId=objWow2.Id;
            objAtt5.Body=Blob.valueOf('Test');
            objAtt5.Name  = 'T5';
            list_Attach.add(objAtt5);
            
            Attachment objAtt6=new Attachment();
            objAtt6.Description='Design Finding';
            objAtt6.ParentId=objWow2.Id;
            objAtt6.Body=Blob.valueOf('Test');
            objAtt6.Name  = 'T6';
            list_Attach.add(objAtt6);
            
            Attachment objAtt7=new Attachment();
            objAtt7.Description='Custom Use Case';
            objAtt7.ParentId=objWow2.Id;
            objAtt7.Body=Blob.valueOf('Test');
            objAtt7.Name  = 'T7';
            list_Attach.add(objAtt7);
            
            Attachment objAtt8=new Attachment();
            objAtt8.Description='Delivery Findings';
            objAtt8.ParentId=objWow2.Id;
            objAtt8.Body=Blob.valueOf('Test');
            objAtt8.Name  = 'T8';
            list_Attach.add(objAtt8);
            
            insert list_Attach;
            
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', lstOpp[1].Id);
            ApexPages.currentPage().getParameters().put('idu', userinfo.getUserId());  
            
            clsWowRequestData objWowReq = new clsWowRequestData();
            objWowReq.FileDescType = 'Discovery Plan';
            objWowReq.UploadFile();
            objWowReq.GetAttachmentsWow();
            /*objWowReq.sAttachmentId = objAtt1.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt2.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt3.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt4.id;
            objWowReq.DeleteAttachment();*/
            
            /*objWowReq.sAttachmentId = objAtt5.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt6.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt7.id;
            objWowReq.DeleteAttachment();
            
            objWowReq.sAttachmentId = objAtt8.id;
            objWowReq.DeleteAttachment();*/
            

              
            /* ApexPages.StandardController StdApex =new ApexPages.StandardController(objWow2);
             WowRequestUserAccess objWoWAccess=new WowRequestUserAccess(StdApex);            
             objWoWAccess.FilterUsers();             
             objWoWAccess.first();
             objWoWAccess.last();
             objWoWAccess.previous();
             objWoWAccess.next();
             objWoWAccess.getTotalPages();*/
             
             test.stoptest();
             }
             
         public static testmethod void testmethodBatchWoWMailNotifiactionLeadAssign(){       
            test.starttest();   
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ; 
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
              
            //Create Opportunity
            Opportunity objOpp=new Opportunity();
            objOpp.Name='Test';
            objOpp.CurrencyIsoCode='USD';
            objOpp.StageName='Test Stage';
            objOpp.Owner=objUser;
            objOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';                    
                                  
            insert objOpp;
            
            
            
            //Create Wow Request
            Wow_Request_Form__c objWow=new Wow_Request_Form__c();
            objWow.WoW_Status__c='Open and Not Assigned';
            objWow.Opportunity_Id__c=objOpp.Id; 
            objWow.AssignTo__c='Lead Assigned';
            objWow.CreatedDate=System.now().addhours(-120);
            objWow.AE__c=userinfo.getUserId();
            objWow.Lead__c=userinfo.getUserId();
            objWow.SE__c=userinfo.getUserId();
            objWow.BC__c=userinfo.getUserId();
            objWow.SEM__c=userinfo.getUserId();
            objWow.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow.Total_Amount__c=100.00;
            objWow.Platform_Type__c='Test Platform';
            objWow.Customer_Name__c='Test Customer';
            objWow.Business_Partner__c='Test BusinessPartner';
            objWow.Primary_Solution__c='Test PrimarySolution';
            objWow.Expected_Closed_Date__c=Date.Today();
            insert objWow; 
            
            WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
            objVT.Virtual_User__c=userinfo.getUserId();
            objVT.Virtual_User_type__c='Solution Consultant';
            objVT.Wow_Request_Form__c=objWow.Id;
            insert objVT;    
                
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', objUser.Id);  
            clsWowRequestData objWowReq=new clsWowRequestData();
            //objWowReq.SaveWowDetails();
            objWowReq.SubmitWowDetails(); 
            objWowReq.DeleteVirtualUsers();
            test.stoptest();       
     }    
              
         public static testmethod void testmethodclsWowRequestDataForVirtualTeam2(){
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
            
            Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
            
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            
            
            insert ObjOpp;
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            /*Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='';
            objWow1.AE__c=userinfo.getUserId();
            objWow1.Lead__c=userinfo.getUserId();
            objWow1.SE__c=userinfo.getUserId();
            objWow1.BC__c=userinfo.getUserId();
            objWow1.SEM__c=userinfo.getUserId();
            objWow1.Assign_Queue__c ='LATAM Wow Leadership Queue';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;  */          
           
            
            
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);
            ApexPages.currentPage().getParameters().put('idu', lstUsr[0].Id);  
            ApexPages.currentPage().getParameters().put('view', 'yes');
            clsWowRequestData objWow=new clsWowRequestData(); 
            
            //objWow.SubmitWowDetails();
            //objWow.SaveWowDetails(); 
            test.starttest();
            
      }  
      public static testmethod void testmethodclsWowRequestDataForVirtualTeam3(){
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;  
            
             Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
             
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            
            insert ObjOpp;
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='Virtual Team';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);          
            clsWowRequestData objWow=new clsWowRequestData(); 
            
            objWow.AddFunctionUseCase();             
            
             
            objWow.CurrentDemo = '1'; 
            
            List<Wow_Attachments__c> list_WowAttachment = new List<Wow_Attachments__c>();
            
            Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
            objWowAttFn.Wow_Request_Form__c = objWow1.id;
            objWowAttFn.Row_Number__c = 1;
            objWowAttFn.Type__c = 'Demo';
            
            list_WowAttachment.add(objWowAttFn);
            
            objWow.CurrentBlePrint ='2';
            Wow_Attachments__c objWowAtt_2 = new Wow_Attachments__c();
             objWowAtt_2.Wow_Request_Form__c = objWow1.id;
             objWowAtt_2.Type__c = 'Architectural Blueprint';
             objWowAtt_2.Row_Number__c =  2;
             list_WowAttachment.add(objWowAtt_2);
       
             objWow.CurrentFunUseCase = '3';
             Wow_Attachments__c objWowAttFn3 = new Wow_Attachments__c();
               objWowAttFn3.Wow_Request_Form__c = objWow1.id;
               objWowAttFn3.Type__c = 'Functional Use Case';
               objWowAttFn3.Functional_Use_Case__c = 'Inbound: CE01 - Connect Voice Interaction to right resource';
               objWowAttFn3.Functional_Usecases_Numbers__c = 'CE01';
               objWowAttFn3.Row_Number__c = 3;
               list_WowAttachment.add(objWowAttFn3);
               
               
              objWow.CurrentServTran = '4';
               Wow_Attachments__c objWowAttFn4 = new Wow_Attachments__c();
               objWowAttFn4.Wow_Request_Form__c = objWow1.id;
               objWowAttFn4.Type__c = 'Services Transition';
               objWowAttFn4.Row_Number__c = 4;
               list_WowAttachment.add(objWowAttFn4);
               
               insert list_WowAttachment;
               
               objWow.SaveWowDetails();
            
            test.starttest();
            objWow.RemoveFunctionalUseCase();
            objWow.RemoveBluePrint();
            objWow.RemoveDemoActivity();
            objWow.RemoveServiceTranActivity();
            
            
            test.stoptest();
            //objWow.SubmitWowDetails();
            //objWow.SaveWowDetails(); 
           // test.starttest();
            
      }     
      public static testmethod void testmethodclsWowRequestDataForStatusAE(){
            //Create Account          
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;  
            
             Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
             
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Key_Business_Objective__c ='Provide Consistent OmniChannel Experience';   
            ObjOpp.Lines_of_Businesses__c ='PureConnect';         
            insert ObjOpp;
            ObjOpp.Key_Business_Objective__c ='Increase First Contact Resolution'; 
            //update ObjOpp; 
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
             //Create Wow Request for Virtual Team
            Wow_Request_Form__c objWow1=new Wow_Request_Form__c();
            objWow1.WoW_Status__c='Open and Not Assigned';
            //objWow1.Opportunity_Id__c=lstOpp[0].Id; 
            objWow1.Opportunity_Id__c=ObjOpp.Id;
            objWow1.AssignTo__c='AE';
            objWow1.Total_Amount__c=100.00;
            objWow1.Platform_Type__c='Test Platform';
            objWow1.Customer_Name__c='Test Customer';
            objWow1.Business_Partner__c='Test BusinessPartner';
            objWow1.Primary_Solution__c='Test PrimarySolution';
            objWow1.Expected_Closed_Date__c=Date.Today();
            insert objWow1;
            
            //Set Page and Query string
            PageReference pageRef = Page.WoW_Request_Form;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);          
            clsWowRequestData objWow=new clsWowRequestData(); 
            objWow.SubmitWowDetails();
            
            wow_request_form__c o =new wow_request_form__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(o);
            clsSCEngagementReport objSCRpt= new clsSCEngagementReport(sc);
            objSCRpt.getUserRecords();
            objSCRpt.getTotalPages();
            objSCRpt.first();
            objSCRpt.last();
            objSCRpt.previous();
            objSCRpt.next();
            test.starttest();            
      }
       public static testmethod void testmethodSCEngagementExtn (){
           opportunity objOpp =new opportunity();
           ApexPages.StandardController opp= new ApexPages.StandardController(objOpp);
           SCEngagementExtn objSC= new SCEngagementExtn(opp);
           objSC.SelectedOppLineId='testid';
           objSC.isRenewalOppy=true;
       } 
     public static testmethod void testmethodclsWowRequestDeateAttachment(){
    LIST<Opportunity> lstOpp= [Select Id From Opportunity LIMIT 2];  
        Wow_Request_Form__c objWow=new Wow_Request_Form__c();
        objWow.WoW_Status__c='Open and Not Assigned';
        objWow.Opportunity_Id__c=lstOpp[1].Id; 
        objWow.AssignTo__c ='';
        objWow.CreatedDate=System.now().addhours(-120);
        objWow.AE__c=userinfo.getUserId();
        objWow.Lead__c=userinfo.getUserId();
        objWow.SE__c=userinfo.getUserId();
        objWow.BC__c=userinfo.getUserId();
        objWow.SEM__c=userinfo.getUserId();
        objWow.Assign_Queue__c ='LATAM Wow Leadership Queue';
        objWow.Total_Amount__c=100.00;
        objWow.Platform_Type__c='Test Platform';
        objWow.Customer_Name__c='Test Customer';
        objWow.Business_Partner__c='Test BusinessPartner';
        objWow.Primary_Solution__c='Test PrimarySolution';
        objWow.Expected_Closed_Date__c=Date.Today();
        insert objWow;
        Attachment objAttach=new Attachment();  
        objAttach.Description='Discovery Plan';
        objAttach.ParentId=objWow.Id;
        objAttach.Body=Blob.valueOf('Test');
        objAttach.Name  = 'T1';
        insert objAttach;
        
        Attachment objAttach1=new Attachment();  
        objAttach1.Description='Discovery Finding';
        objAttach1.ParentId=objWow.Id;
        objAttach1.Body=Blob.valueOf('Test');
        objAttach1.Name  = 'T1';
        insert objAttach1;
        
        Attachment objAttach2=new Attachment();  
        objAttach2.Description='Design Finding';
        objAttach2.ParentId=objWow.Id;
        objAttach2.Body=Blob.valueOf('Test');
        objAttach2.Name  = 'T1';
        insert objAttach2;

        PageReference pageRef = Page.WoW_Request_Form;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lstOpp[1].Id);        
        clsWowRequestData objWowReq=new clsWowRequestData(); 
    
        objWowReq.sAttachmentId = objAttach.Id;
        objWowReq.DeleteAttachment();
        
        objWowReq.sAttachmentId = objAttach1.Id;
        objWowReq.DeleteAttachment();
        test.starttest();
        objWowReq.sAttachmentId = objAttach2.Id;
        objWowReq.DeleteAttachment();
        
        objWowReq.fileBody =Blob.valueOf('test');
        objWowReq.fileName ='test';
        objWowReq.FileDescType = 'Vision Activity';
        objWowReq.UploadFile();
        
        objWowReq.fileBody =Blob.valueOf('test');
        objWowReq.fileName ='test';
        objWowReq.FileDescType = 'Discovery Plan';
        objWowReq.UploadFile();
        
        objWowReq.fileBody =Blob.valueOf('test');
        objWowReq.fileName ='test';
        objWowReq.FileDescType = 'Design Plan';
        objWowReq.UploadFile();       
        
        
        
         objWowReq.SubmitWowDetails();

        test.stoptest();
    } 
    public static testmethod void testmethodVT2(){
    List<Account> lstAcc=TestUtil.createAccounts(1,true);
               
            //find current user          
            user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
            objUser.Bypass_Triggers__c = true;
            update objUser;  
            //find  country
            country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;  
            
             Wow_Sub_Regional_Users__c cs = new Wow_Sub_Regional_Users__c();
            cs.Region__c='APAC';
            cs.SubRegion__c='APAC';
            cs.Subregional_Leader__c=objUser.Id;
            cs.Name='XYZ';
            insert cs;
             
            //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
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
            ObjOpp.Key_Business_Objective__c ='Provide Consistent OmniChannel Experience';   
            ObjOpp.Lines_of_Businesses__c ='PureConnect';         
            insert ObjOpp; 
    
     
        Wow_Request_Form__c objWow=new Wow_Request_Form__c();
        objWow.WoW_Status__c='Open and Assigned';
        objWow.Opportunity_Id__c=ObjOpp.Id; 
        objWow.AssignTo__c ='Virtual Team';
        objWow.CreatedDate=System.now().addhours(-120);
        objWow.AE__c=userinfo.getUserId();
        objWow.Lead__c=userinfo.getUserId();
        objWow.SE__c=userinfo.getUserId();
        objWow.BC__c=userinfo.getUserId();
        objWow.SEM__c=userinfo.getUserId();
        objWow.Assign_Queue__c ='LATAM Wow Leadership Queue';
        objWow.Total_Amount__c=100.00;
        objWow.Platform_Type__c='Test Platform';
        objWow.Customer_Name__c='Test Customer';
        objWow.Business_Partner__c='Test BusinessPartner';
        objWow.Primary_Solution__c='Test PrimarySolution';
        objWow.Expected_Closed_Date__c=Date.Today();
        insert objWow;
        
        WoW_Virtual_Users__c objVT=new WoW_Virtual_Users__c();
        objVT.Virtual_User__c=userinfo.getUserId();
        objVT.Virtual_User_type__c='Solution Consultant';
        objVT.Wow_Request_Form__c=objWow.Id;
        insert objVT; 
        PageReference pageRef = Page.WoW_Request_Form;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', ObjOpp.Id);        
        clsWowRequestData objWowReq=new clsWowRequestData(); 
        test.starttest();
         objWowReq.SubmitWowDetails();
         //objWow.SaveWowDetails();
        test.stoptest();
    }     
}