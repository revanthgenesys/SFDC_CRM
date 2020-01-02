@isTest(SeeAllData = true)
public class DSRVisionController_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            Test.startTest();
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            insert objTestOppty;
            
            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Vision_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Vision_End_Date__c = Date.Today().addDays(10);
            
            objSCE.Discovery_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Discovery_End_Date__c = Date.Today().addDays(10);
            insert objSCE;
           
            /*DSR_Activity__c objActivity = new DSR_Activity__c();
            objActivity.SCEID__c = objSCE.id;
            objActivity.Module__c = 'Vision';
            objActivity.SubModule__c = 'Vision Activity';
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.Header__c = 'aa';
            objActivity.Description__c ='aa';
            objActivity.ActivityDate__c = Date.Today();*/
            
            DSR_Attachments__c objActivity = new DSR_Attachments__c();
            objActivity.ObjectType__c = 'Vision Activity';
            objActivity.AttachmentType__c = 'V1';
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.DateofAttachment__c = Date.Today();
            objActivity.AttachmentURL__c = 'www.abc.com';
            objActivity.Description__c = 'hh';
            
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'V1';
            objDataDef_Attch.ObjectType__c = 'Vision Activity';
            objDataDef_Attch.URLRequired__c = false;
            insert objDataDef_Attch;
            
            /*For Vision controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Vision?id=' + objSCE.Id));
            DSRVisionController objVision = new DSRVisionController();
            objVision.strSelectedAccess = 'aa';
            objVision.strSelectedSource = 'aa';
            objVision.strSelectedVisionType = 'aa';
            objVision.objDSRActivity = objActivity;
            
            objVision.saveVisionActivity();
            
            List<DSR_Attachments__c> list_DA = [Select id from DSR_Attachments__c where DSRSCEngagement__c =: objSCE.Id];
            
            objVision.strVisionActId = list_DA[0].id;
            
            objVision.EditActivity();
            objVision.Cancel();
            objVision.RemoveVisionActivity();
            objVision.list_VisionActivity.add(objActivity);
            objVision.SaveSCE();
            DSRVisionController.GetDescription('V1');
            
            
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
    static testmethod void test2()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'V1';
            objDataDef_Attch.ObjectType__c = 'Vision Activity';
            objDataDef_Attch.URLRequired__c = false;
            insert objDataDef_Attch;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            insert objTestOppty;
            
            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Vision_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Vision_End_Date__c = Date.Today().addDays(10);
            
            objSCE.Discovery_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Discovery_End_Date__c = Date.Today().addDays(10);
            insert objSCE;
            
            /*DSR_Activity__c objActivity = new DSR_Activity__c();
            objActivity.SCEID__c = objSCE.id;
            objActivity.Module__c = 'Vision';
            objActivity.SubModule__c = 'Vision Activity';
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.Header__c = 'aa';
            objActivity.Description__c ='aa';
            objActivity.ActivityDate__c = Date.Today().addDays(-20);*/
            
            DSR_Attachments__c objActivity = new DSR_Attachments__c();
            objActivity.ObjectType__c = 'Vision Activity ';
            objActivity.AttachmentType__c = 'V1';
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.DateofAttachment__c = Date.Today().addDays(-20);
            
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Vision?id=' + objSCE.Id));
            DSRVisionController objVision = new DSRVisionController();
            objVision.strSelectedAccess = 'aa';
            objVision.strSelectedSource = 'aa';
            objVision.strSelectedVisionType = 'aa';
            objVision.objDSRActivity = objActivity;
            
            objVision.saveVisionActivity();
            List<DSR_Attachments__c> list_DA = [Select id from DSR_Attachments__c where DSRSCEngagement__c =: objSCE.Id];
            
            objVision.strVisionActId = list_DA[0].id;
            
            objVision.EditActivity();
            objVision.Cancel();
            objVision.RemoveVisionActivity();
            objVision.list_VisionActivity.add(objActivity);
            objVision.SaveSCE();
            DSRVisionController.GetDescription('V1');
            
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
}