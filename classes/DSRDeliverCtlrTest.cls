/***************************************************************************************************
* 
*  Class Name      :   DSRDeliverCtlrTest
*  Description     :   This class is used to unit test the DSRDeliverCtlr
*  Auther          :   R Systems
* 
****************************************************************************************************/
@isTest(seealldata=true)
private class DSRDeliverCtlrTest {

    private static testMethod void DSRDeliverCtlrTestMethod() {
        
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
        objDataDef_Attch.AttachmentType__c = 'Delivered by Partner / Customer';
        objDataDef_Attch.ObjectType__c = 'Service Transition Activity';
        objDataDef_Attch.URLRequired__c = false;
        insert objDataDef_Attch;
            
        //Create Account          
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
           
        //find current user          
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser;  
        //find  country
        country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
       
        
        Opportunity ObjOpp  = TestUtil.createOpportunities(1,lstAcc[0].id, false)[0];
        ObjOpp.Lines_of_Businesses__c = 'PureCloud';
        insert ObjOpp;
        
        DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
        dsr.Account_ID__c = lstAcc[0].Id;
        dsr.AE_Name__c = objUser.Id;
        dsr.AssignTo__c = 'Lead Assign';
        dsr.Opportunity_ID__c = ObjOpp.Id;
        dsr.SC_Engagement_Status__c = 'Open and Not Assigned';
        
        insert dsr;
        
        
        DSR_Virtual_Team__c dsrvT = new DSR_Virtual_Team__c();
        dsrvT.SCE_ID__c = dsr.Id;
        dsrvT.Virtual_Team_Member_Name__c = objUser.Id;
        dsrvT.Region__c = 'Region';
        dsrvT.Sub_Region__c = 'Sub Region';
        dsrvT.Segment__c = 'Segment';
        dsrvT.Virtual_User_Role__c = 'Sub Regional Leader';
        
        insert dsrvT;
        
        DSR_Virtual_Team__c dsrvT1 = new DSR_Virtual_Team__c();
        dsrvT1.SCE_ID__c = dsr.Id;
        dsrvT1.Virtual_Team_Member_Name__c = objUser.Id;
        dsrvT1.Region__c = 'Region';
        dsrvT1.Sub_Region__c = 'Sub Region';
        dsrvT1.Segment__c = 'Segment';
        dsrvT1.Virtual_User_Role__c = 'Virtual Team';
        
        insert dsrvT1;
        
        /*DSR_Activity__c dsrA = new DSR_Activity__c();
        dsrA.SubModule__c = 'Service Transition Activity';
        dsrA.header__c = 'Test';
        dsrA.Module__c = 'Deliver';
        dsrA.ActivityDate__c = date.today();
        dsrA.Access__c = 'Partner';
        dsrA.SCEID__c = dsr.Id;
        
        insert dsrA;
        
        DSR_Activity__c dsrA1 = new DSR_Activity__c();
        dsrA1.SubModule__c = 'Delivery Requirements';
        dsrA1.header__c = 'Test';
        dsrA1.Module__c = 'Deliver';
        dsrA1.ActivityDate__c = date.today();
        dsrA1.Access__c = 'Partner';
        dsrA1.SCEID__c = dsr.Id;
        
        insert dsrA1;*/
        
        DSR_Attachments__c objActivity = new DSR_Attachments__c();
        objActivity.ObjectType__c = 'Delivery Requirements';
        objActivity.AttachmentType__c = 'V1';
        objActivity.DSRSCEngagement__c = dsr.id;
        objActivity.Access__c = 'aa';
        objActivity.Source__c = 'aa';
        objActivity.DateofAttachment__c = Date.Today();
        objActivity.AttachmentURL__c = 'www.abc.com';
        objActivity.Description__c = 'hh';
        insert objActivity ;
        
        ApexPages.CurrentPage().getParameters().put('drId',objActivity.Id);
        //ApexPages.CurrentPage().getParameters().put('serId', dsrA.Id);
        ApexPages.currentPage().getParameters().put('id', dsr.Id);
        
        DSRDeliverCtlr dsrCtlr = new DSRDeliverCtlr();
        
        dsrCtlr.saveSCDSR();
        DSRDeliverCtlr.GetDescription('Test');
        dsrCtlr.showDeliverRequirement();
        dsrCtlr.closeDeliverRequirement();
        dsrCtlr.closeDeliverRequirementCancel();
        dsrCtlr.editDeliverReq();
        dsrCtlr.closeDeliverRequirement();
        dsrCtlr.showServiceTransitionActivites();
        dsrCtlr.closeServiceTransitionActivites();
        dsrCtlr.closeServiceTransitionActivitesCancel();
        dsrCtlr.editServiceTrans();
        dsrCtlr.closeDeliverRequirement();
        dsrCtlr.removeServiceTrans();
        dsrCtlr.removeDeliverReq();
        
    }

}