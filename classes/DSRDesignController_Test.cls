@isTest(SeeAllData = true)
public class DSRDesignController_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;

            List<DSRDataDefinition__c>list_DD = new List<DSRDataDefinition__c>();

            DSRDataDefinition__c objDataDef = new DSRDataDefinition__c();
            objDataDef.Module__c = 'Common';
            objDataDef.SubModule__c = 'Access';
            objDataDef.Header__c = 'A1';
            objDataDef.IsActive__c = true;
            list_DD.add(objDataDef);
            
            DSRDataDefinition__c objDataDef2 = new DSRDataDefinition__c();
            objDataDef2.Module__c = 'Common';
            objDataDef2.SubModule__c = 'Document Source';
            objDataDef2.Header__c = 'A1';
            objDataDef2.IsActive__c = true;
            list_DD.add(objDataDef2);
            
            DSRDataDefinition__c objDataDef3 = new DSRDataDefinition__c();
            objDataDef3.Module__c = 'Design';
            objDataDef3.SubModule__c = 'Design General Background';
            objDataDef3.Header__c = 'A1';
            objDataDef3.IsActive__c = true;
            list_DD.add(objDataDef3);
            
            insert list_DD;
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'V1';
            objDataDef_Attch.ObjectType__c = 'Design Activity';
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
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
            
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
            objActivity.ObjectType__c = 'Design Activity';
            objActivity.AttachmentType__c = 'V1';
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.DateofAttachment__c = Date.Today();
            objActivity.AttachmentURL__c = 'www.abc.com';
            objActivity.Description__c = 'hh';
            
              DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
              objSCDesign.DSR_SCEngagement__c = objSCE.id;
              //objSCDesign.OfferPlatformType__c = 'aa';
              //objSCDesign.PlatformType__c = 'aa';
              objSCDesign.HAType__c = 'aa';
              objSCDesign.DataCenters__c = 'aa';
              
            
            Test.startTest();
            
            /*For Design controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Design?id=' + objSCE.Id));
            DSRDesignController objDesign2 = new DSRDesignController();
            objDesign2.strSelectedAccess = 'aa';
            objDesign2.strSelectedSource = 'aa';
            objDesign2.strSelectedVisionType = 'aa';
            objDesign2.objDSRActivity = objActivity;
            objDesign2.saveVisionActivity();
            List<DSR_Attachments__c> list_DA = [Select id from DSR_Attachments__c where DSRSCEngagement__c =: objSCE.Id];
            
            objDesign2.strVisionActId = list_DA[0].id;
            objDesign2.EditActivity();
            objDesign2.Cancel();
            objDesign2.RemoveVisionActivity();
            objDesign2.list_VisionActivity.add(objActivity);
            objDesign2.SaveSCE();
            DSRDesignController.GetDescription('V1');
            
            objDesign2.strHAType ='aa';
            objDesign2.strDataCentre = 'aa';
            objDesign2.objDesign = objSCDesign;

            objDesign2.SaveAndUpdateDesign();
            
            objDesign2.strDesignId = objSCDesign.id;
            objDesign2.EditDesign();
            
            objDesign2.RemoveDesign();
            objDesign2.AddAct();
            objDesign2.AddDesign();
            
            DSRUtility.GetDataDefinition('Design','Design General Background');
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
            
            List<DSRDataDefinition__c>list_DD = new List<DSRDataDefinition__c>();

            DSRDataDefinition__c objDataDef = new DSRDataDefinition__c();
            objDataDef.Module__c = 'Common';
            objDataDef.SubModule__c = 'Access';
            objDataDef.Header__c = 'A1';
            objDataDef.IsActive__c = true;
            list_DD.add(objDataDef);
            
            DSRDataDefinition__c objDataDef2 = new DSRDataDefinition__c();
            objDataDef2.Module__c = 'Common';
            objDataDef2.SubModule__c = 'Document Source';
            objDataDef2.Header__c = 'A1';
            objDataDef2.IsActive__c = true;
            list_DD.add(objDataDef2);
            
            insert list_DD;
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'V1';
            objDataDef_Attch.ObjectType__c = 'Design Activity';
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
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
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
            objActivity.ObjectType__c = 'Design Activity';
            objActivity.AttachmentType__c = 'V1';
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.Access__c = 'aa';
            objActivity.Source__c = 'aa';
            objActivity.DateofAttachment__c = Date.Today().addDays(-20);
            objActivity.AttachmentURL__c = 'www.abc.com';
            objActivity.Description__c = 'hh';
            
            Test.startTest();
            
             /*For Design controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Design?id=' + objSCE.Id));
            DSRDesignController objDesign = new DSRDesignController();
            objDesign.strSelectedAccess = 'aa';
            objDesign.strSelectedSource = 'aa';
            objDesign.strSelectedVisionType = 'aa';
            objDesign.objDSRActivity = objActivity;
            objDesign.saveVisionActivity();
            
            List<DSR_Attachments__c> list_DA = [Select id from DSR_Attachments__c where DSRSCEngagement__c =: objSCE.Id];
            
            objDesign.strVisionActId = list_DA[0].id;
            objDesign.EditActivity();
            objDesign.Cancel();
            objDesign.RemoveVisionActivity();
            objDesign.list_VisionActivity.add(objActivity);
            objDesign.SaveSCE();
            //DSRDesignController.GetDescription('RFP - Response');
            
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
}