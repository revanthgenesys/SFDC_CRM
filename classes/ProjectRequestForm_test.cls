/*
Created By:    Amit Singh-Rsystems(18/Jan/2016)
Function:      Test Class for Class  ProjectRequestForm
*/
@isTest(seealldata=true)
public class ProjectRequestForm_test{
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
            Project_Request_Form__c  objWow1 = new Project_Request_Form__c();
            objWow1.Account__c = lstAcc[0].Id;
            objWow1.Any_Customer_Integrations_Included__c = 'Testingg';
            objWow1.Any_Onsite_Travel_Required__c = 'No';
            objWow1.Booking_Date__c = Date.Today();
            objWow1.Commitments_Been_Made_To_Customer__c = 'Yes';
            objWow1.Customer_Location__c = 'NOIDA';
            objWow1.Include_Any_Other_Pertinent__c = 'Testingg';
            objWow1.Is_this_a_package__c = 'Testingg';
            objWow1.Is_VCC_Or_SS_IVR_Project__c =  'VCC';
            objWow1.New_CMRR__c = 88;
            objWow1.New_Or_Existing_Customer__c = 'New';
            objWow1.No_Of_SS_IVR_Minutes__c = 60;
            objWow1.Number_Of_VCC_Seats__c = 60;
            objWow1.Opportunity__c = ObjOpp.id;
            objWow1.Pre_Discount_PS_Project_Value__c = 20;
            objWow1.Priority__c = 'High';
            objWow1.Region__c = 'LATAM';
            objWow1.Requester__c = UserInfo.getUserId();
            objWow1.Request_Type__c = 'Project Request';
            objWow1.Status__c = 'New';
            objWow1.Submitted__c = false;
            objWow1.Support_Area__c = 'Testingg';
            objWow1.Technical_Business_Issues_to_be_solved__c = '25 character-long string.';
            objWow1.Critical_Business_Issues_to_be_solved__c = '25 character-long string.';
            
            insert objWow1;  
            
            Attachment objAtt1 = new Attachment();
            objAtt1.Name = 'Test';
            objAtt1.body = Blob.valueOf('Test');  
            objAtt1.parentId = objWow1.id;
            objAtt1.Description = 'Statement Of Work';
            insert objAtt1;
            
            Attachment objAtt2 = new Attachment();
            objAtt2.Name = 'Test';
            objAtt2.body = Blob.valueOf('Test');  
            objAtt2.parentId = objWow1.id;
            objAtt2.Description = 'Services Order';
            insert objAtt2;
            
            Attachment objAtt3 = new Attachment();
            objAtt3.Name = 'Test';
            objAtt3.body = Blob.valueOf('Test');  
            objAtt3.parentId = objWow1.id;
            objAtt3.Description = 'Opportunity Quote Sheets';
            insert objAtt3;  
 
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Oid', ObjOpp.Id);
            ApexPages.StandardController sc = new ApexPages.standardController(objWow1); 
            
            ProjectRequestForm objPRF = new ProjectRequestForm();
            objPRF.SaveProjReqForm();
            objPRF.SubmitProjReqForm();
            objPRF.GetCurrentUserName(); 
            objPRF.UploadFile();         
            test.stoptest(); 
     
               
    }
          public static testmethod void testmethod2(){       
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
            Project_Request_Form__c  objWow1 = new Project_Request_Form__c();
            objWow1.Account__c = lstAcc[0].Id;
            objWow1.Any_Customer_Integrations_Included__c = 'Testingg';
            objWow1.Any_Onsite_Travel_Required__c = 'No';
            objWow1.Booking_Date__c = Date.Today();
            objWow1.Commitments_Been_Made_To_Customer__c = 'Yes';
            objWow1.Customer_Location__c = 'NOIDA';
            objWow1.Include_Any_Other_Pertinent__c = 'Testingg';
            objWow1.Is_this_a_package__c = 'Testingg';
            objWow1.Is_VCC_Or_SS_IVR_Project__c =  'VCC';
            objWow1.New_CMRR__c = 88;
            objWow1.New_Or_Existing_Customer__c = 'New';
            objWow1.No_Of_SS_IVR_Minutes__c = 60;
            objWow1.Number_Of_VCC_Seats__c = 60;
            objWow1.Opportunity__c = ObjOpp.id;
            objWow1.Pre_Discount_PS_Project_Value__c = 20;
            objWow1.Priority__c = 'High';
            objWow1.Region__c = 'LATAM';
            objWow1.Requester__c = UserInfo.getUserId();
            objWow1.Request_Type__c = 'Project Request';
            objWow1.Status__c = 'New';
            objWow1.Submitted__c = false;
            objWow1.Support_Area__c = 'Testingg';
            objWow1.Technical_Business_Issues_to_be_solved__c = '25 character-long string.';
            objWow1.Critical_Business_Issues_to_be_solved__c = '25 character-long string.';
            
            insert objWow1;  
            
            Attachment objAtt1 = new Attachment();
            objAtt1.Name = 'Test';
            objAtt1.body = Blob.valueOf('Test');  
            objAtt1.parentId = objWow1.id;
            objAtt1.Description = 'Statement Of Work';
            insert objAtt1;
            
            Attachment objAtt2 = new Attachment();
            objAtt2.Name = 'Test';
            objAtt2.body = Blob.valueOf('Test');  
            objAtt2.parentId = objWow1.id;
            objAtt2.Description = 'Services Order';
            insert objAtt2;
            
            Attachment objAtt3 = new Attachment();
            objAtt3.Name = 'Test';
            objAtt3.body = Blob.valueOf('Test');  
            objAtt3.parentId = objWow1.id;
            objAtt3.Description = 'Opportunity Quote Sheets';
            insert objAtt3; 
            
            Attachment objAtt4 = new Attachment();
            objAtt4.Name = 'Test';
            objAtt4.body = Blob.valueOf('Test');  
            objAtt4.parentId = objWow1.id;
            objAtt4.Description = 'Flow Documents';
            insert objAtt4;  
 
            //Set Page and Query string
            PageReference pageRef = Page.WowRequestUser;
            
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Aid', lstAcc[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(objWow1); 
            
            ProjectRequestForm objPRF = new ProjectRequestForm();
            objPRF.SaveProjReqForm();
            objPRF.SubmitProjReqForm();
            objPRF.GetCurrentUserName();
            
            objPRF.fileBody = Blob.valueof('Test1');
            objPRF.fileName = 'T1';
            objPRF.FileDescType = 'Statement Of Work';
            objPRF.UploadFile(); 
            
            objPRF.sAttachmentId = objAtt4.id;
            objPRF.DeleteAttachment();        
            test.stoptest(); 
     
               
    }
 }