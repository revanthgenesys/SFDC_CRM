@isTest
public class DSRDesignBusinessController_Test {
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
            
            DSRDataDefinition__c objDataDef1 = new DSRDataDefinition__c();
            objDataDef1.Module__c = 'Design';
            objDataDef1.SubModule__c = 'Business Design Fit%';
            objDataDef1.Header__c = '60';
            objDataDef1.IsActive__c = true;
            list_DD.add(objDataDef1);
            
            DSRDataDefinition__c objDataDef2 = new DSRDataDefinition__c();
            objDataDef2.Module__c = 'Common';
            objDataDef2.SubModule__c = 'Offer Type';
            objDataDef2.Header__c = 'A1';
            objDataDef2.IsActive__c = true;
            list_DD.add(objDataDef2);
            
            DSRDataDefinition__c objDataDef3 = new DSRDataDefinition__c();
            objDataDef3.Module__c = 'Common';
            objDataDef3.SubModule__c = 'Platform Type';
            objDataDef3.Header__c = 'A1';
            objDataDef3.IsActive__c = true;
            list_DD.add(objDataDef3);
            
            insert list_DD;
            
            DSR_UseCase_BluePrint_Definition__c objDataDef_Fn = new DSR_UseCase_BluePrint_Definition__c();
            objDataDef_Fn.Active__c = true;
            objDataDef_Fn.Name__c = 'B01';
            //objDataDef_Fn.OfferingType__c = 'PureCloud';
            //objDataDef_Fn.Platform__c = 'Premise';
            objDataDef_Fn.ShortCode__c = 'B01';
            objDataDef_Fn.Type__c = 'Use Case';
            insert objDataDef_Fn;
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'Bill of Material';
            objDataDef_Attch.ObjectType__c = 'Business Design Attachment';
            //objDataDef_Attch.OfferingType__c = 'PureCloud';
            //objDataDef_Attch.Platform__c = 'Cloud';
            objDataDef_Attch.URLRequired__c = false;
            insert objDataDef_Attch;
            
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            //objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name =: 'United States' LIMIT 1].Id;
            insert objTestAccount;
            
            //List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
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

            DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
            objSCDesign.DSR_SCEngagement__c = objSCE.id;
            //objSCDesign.OfferPlatformType__c = 'aa';
            //objSCDesign.PlatformType__c = 'aa';
            objSCDesign.HAType__c = 'aa';
            objSCDesign.DataCenters__c = 'aa';
            insert objSCDesign ;
       
            DSR_Use_Case_Blueprints__c objFnUseCase = new DSR_Use_Case_Blueprints__c();
            objFnUseCase.DSRSCEDesign__c = objSCDesign.id;
            objFnUseCase.DSRSCEngagement__c = objSCE.id;
            objFnUseCase.ShortCode__c = 'B01';
            objFnUseCase.Type__c = 'Use Case';
            objFnUseCase.Name__c = 'aa';
            
            DSR_Attachments__c objActivity = new DSR_Attachments__c();
            objActivity.DSRSCEDesign__c = objSCDesign.id;
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.ObjectType__c = 'Business Design Attachment';
            objActivity.AttachmentType__c = 'Bill of Material';

            objActivity.Description__c ='aa';
            objActivity.DateofAttachment__c = Date.Today();
            //objActivity.strSelectedAccess = 'aa';
            //objActivity.strSelectedSource = 'aa';
            insert objActivity;
            Test.startTest();
            
            /*For Design controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Design_Business?id=' + objSCDesign.Id));
            DSRDesignBusinessController objDesign = new DSRDesignBusinessController();
            objDesign.strSelectedAccess = 'aa';
            objDesign.strSelectedSource = 'aa';
            //objDesign.strSelectedVisionType = 'aa';
            objDesign.strSelectedAttachmentType = 'aa';
            objDesign.objDSRActivity = objActivity;
            objDesign.strURLReq = 'NO';
            objDesign.InsertAndUpdateActivity();
            objDesign.strVisionActId = objActivity.id;
            objDesign.EditActivity();
            objDesign.Cancel();
            objDesign.RemoveVisionActivity();
            objDesign.SaveSCE();
            DSRDesignBusinessController.GetDescription('Bill of Material');
            /*Save for Functional Use Case*/
            objDesign.strSelectedShortCode = 'B01';
            objDesign.strSelectedFit = '100';
            objDesign.strSelectedFitCategory = 'aa';
            objDesign.objFnUseCase = objFnUseCase ;
            objDesign.SaveAndUpdateFnUseCase();
            objDesign.strVisionActId = objFnUseCase.id;
            objDesign.EditFnUseCase();
            objDesign.AddAct();
            DSRDesignBusinessController.GetFitCategoryDtl('B01','PureCloud');
            
            objDesign.strFnId = objFnUseCase.id;
            objDesign.RemoveFnUseCase();
            
            objDesign.strDesignId = objSCDesign.id;
            objDesign.RemoveDesign();
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
}