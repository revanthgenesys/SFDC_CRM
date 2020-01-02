@isTest
public class DSRDesignTechnicalController_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
            DSRDataDefinition__c objDataDef2 = new DSRDataDefinition__c();
            objDataDef2.Module__c = 'Design';
            objDataDef2.SubModule__c = 'Technical Design Fit%';
            objDataDef2.Header__c = '11';
            objDataDef2.IsActive__c = true;
            insert objDataDef2; 
            DSRDataDefinition__c objDataDef = new DSRDataDefinition__c();
            objDataDef.Module__c = 'Design';
            objDataDef.SubModule__c = 'Technical Design Fit Category';
            objDataDef.Header__c = '1';
            objDataDef.IsActive__c = true;
            insert objDataDef; 
            DSRDataDefinition__c objDataDef1 = new DSRDataDefinition__c();
            objDataDef1.Module__c = 'Design';
            objDataDef1.SubModule__c = 'Design Link';
            objDataDef1.Header__c = '1';
            objDataDef1.IsActive__c = true;
            insert objDataDef1;
            
            DSRDataDefinition__c objDataDef3 = new DSRDataDefinition__c();
            objDataDef3.Module__c = 'Design';
            objDataDef3.SubModule__c = 'Design Link';
            objDataDef3.Header__c = '1';
            objDataDef3.IsActive__c = true;
            insert objDataDef3;

            DSR_UseCase_BluePrint_Definition__c objDataDef_Fn = new DSR_UseCase_BluePrint_Definition__c();
            objDataDef_Fn.Active__c = true;
            objDataDef_Fn.Name__c = 'B01';
            objDataDef_Fn.ShortCode__c = 'B01';
            objDataDef_Fn.Type__c = 'Blueprint';
            insert objDataDef_Fn;
            
            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'Bill of Material';
            objDataDef_Attch.ObjectType__c = 'Technical Design Attachment';
            objDataDef_Attch.URLRequired__c = false;
            insert objDataDef_Attch;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            //objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
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
            
            
            DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
            objSCDesign.DSR_SCEngagement__c = objSCE.id;
            objSCDesign.HAType__c = 'aa';
            objSCDesign.DataCenters__c = 'aa';
            insert objSCDesign ;
              
            /*DSR_Activity__c objFn = new DSR_Activity__c();
            objFn.SCEID__c = objSCE.id;
            objFn.Module__c = 'Design';
            objFn.SubModule__c = 'Functional Use Case';
            objFn.Access__c = 'aa';
            objFn.Source__c = 'aa';
            objFn.Header__c = 'aa';
            objFn.Description__c ='aa';
            objFn.ActivityDate__c = Date.Today();
            objFn.DSRSCEDesign__c = objSCDesign.id;*/
            
            DSR_Use_Case_Blueprints__c objFnUseCase = new DSR_Use_Case_Blueprints__c();
            objFnUseCase.DSRSCEDesign__c = objSCDesign.id;
            objFnUseCase.DSRSCEngagement__c = objSCE.id;
            objFnUseCase.ShortCode__c = 'B01';
            objFnUseCase.Type__c = 'Blueprint';
            objFnUseCase.Name__c = 'aa';
            
            DSR_Attachments__c objActivity = new DSR_Attachments__c();
            objActivity.DSRSCEDesign__c = objSCDesign.id;
            objActivity.DSRSCEngagement__c = objSCE.id;
            objActivity.ObjectType__c = 'Technical Design Attachment';
            objActivity.AttachmentType__c = 'Bill of Material';

            objActivity.Description__c ='aa';
            objActivity.DateofAttachment__c = Date.Today();
            //objActivity.strSelectedAccess = 'aa';
            //objActivity.strSelectedSource = 'aa';
            
            New_Solution_Design__c nsdObj = new New_Solution_Design__c();
            nsdObj.PureConnect_Cloud_Capabilities_Phase_1__c = 'Development Environment';
            nsdObj.PureConnect_Cloud_Capabilities_Phase_2__c = 'Development Environment';
            insert nsdObj;
            Test.startTest();
            
            /*For Design controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Design_Technical?id=' + objSCDesign.Id));
            DSRDesignTechnicalController  objDesign = new DSRDesignTechnicalController();
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
            DSRDesignTechnicalController.GetDescription('Bill of Material');
            /*Save for Functional Use Case*/
            objDesign.strSelectedShortCode = 'B01';
            objDesign.strSelectedFit = '100';
            objDesign.strSelectedFitCategory = 'aa';
            objDesign.objArchBluePrint = objFnUseCase ;
            objDesign.SaveAndUpdateArchBluePrint();
            objDesign.strVisionActId = objFnUseCase.id;
            objDesign.EditArchBluePrint();
            objDesign.AddAct();
            DSRDesignTechnicalController.GetFitCategoryDtl('B01','PureCloud');
            
            objDesign.AddDesign();
            
            objDesign.strBluePrintId = objFnUseCase.id;
            objDesign.RemoveBlueprint();
            
            objDesign.strDesignId = objSCDesign.id;
            objDesign.RemoveDesign();
            objDesign.UploadFile();
            objDesign.showCopyDSOPopup();
            objDesign.newDSO();
            DSRDesignTechnicalController.autoSearchDSOList('cap');
            objDesign.dsoId =nsdObj.Name;
            //objDesign.copyDSO();
            objDesign.cancelDSO();
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
   
}