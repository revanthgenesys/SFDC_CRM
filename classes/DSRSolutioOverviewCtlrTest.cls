/***************************************************************************************************
* 
*  Class Name      :   DSRSolutioOverviewCtlrTest
*  Description     :   This class is used to unit test the DSRSolutioOverviewCtlr
*  Auther          :   R Systems
* 
****************************************************************************************************/
@isTest(seealldata=true)
private class DSRSolutioOverviewCtlrTest {

    private static testMethod void testFirst() {
        //Create Account          
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
           
        //find current user          
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser;  
        //find  country
        country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
       
        DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
        objDataDef_Attch.Active__c = true;
        objDataDef_Attch.AttachmentType__c = 'Bill of Material';
        objDataDef_Attch.ObjectType__c = 'Technical Design Attachment';
        objDataDef_Attch.URLRequired__c = false;
        insert objDataDef_Attch;
        
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
        insert dsrA1;
        
        DSR_Activity__c dsrA2 = new DSR_Activity__c();
        dsrA2.SubModule__c = 'Delivery Requirements';
        dsrA2.header__c = 'Test';
        dsrA2.Module__c = 'Discovery';
        dsrA2.ActivityDate__c = date.today();
        dsrA2.Access__c = 'Partner';
        dsrA2.SCEID__c = dsr.Id;
        insert dsrA2;
        
        DSR_Activity__c dsrA3 = new DSR_Activity__c();
        dsrA3.SubModule__c = 'Delivery Requirements';
        dsrA3.header__c = 'Test';
        dsrA3.Module__c = 'Design';
        dsrA3.ActivityDate__c = date.today();
        dsrA3.Access__c = 'Partner';
        dsrA3.SCEID__c = dsr.Id;
        insert dsrA3;
        
        DSR_Activity__c dsrA4 = new DSR_Activity__c();
        dsrA4.SubModule__c = 'Delivery Requirements';
        dsrA4.header__c = 'Test';
        dsrA4.Module__c = 'Vision';
        dsrA4.ActivityDate__c = date.today();
        dsrA4.Access__c = 'Partner';
        dsrA4.SCEID__c = dsr.Id;
        
        insert dsrA4;*/
        
        DSR_SCE_Design__c design = new DSR_SCE_Design__c();
        design.DSR_SCEngagement__c = dsr.Id;
        design.Name__C = 'Test';
        design.IsPrimary__c = true;
        insert design;
        
        List<DSR_Attachments__c>lst_Act = new List<DSR_Attachments__c>();
        
        DSR_Attachments__c objActivity1 = new DSR_Attachments__c();
        objActivity1.DSRSCEDesign__c = design.id;
        objActivity1.DSRSCEngagement__c = dsr.id;
        objActivity1.ObjectType__c = 'Vision Activity';
        objActivity1.AttachmentType__c = 'aa';
        objActivity1.Description__c ='aa';
        objActivity1.DateofAttachment__c = Date.Today();
        lst_Act.add(objActivity1);
        
        DSR_Attachments__c objActivity2 = new DSR_Attachments__c();
        objActivity2.DSRSCEDesign__c = design.id;
        objActivity2.DSRSCEngagement__c = dsr.id;
        objActivity2.ObjectType__c = 'Delivery Requirements';
        objActivity2.AttachmentType__c = 'aa';
        objActivity2.Description__c ='aa';
        objActivity2.DateofAttachment__c = Date.Today();
        lst_Act.add(objActivity2);
        
        DSR_Attachments__c objActivity3 = new DSR_Attachments__c();
        objActivity3.DSRSCEDesign__c = design.id;
        objActivity3.DSRSCEngagement__c = dsr.id;
        objActivity3.ObjectType__c = 'Design Activity';
        objActivity3.AttachmentType__c = 'aa';
        objActivity3.Description__c ='aa';
        objActivity3.DateofAttachment__c = Date.Today();
        lst_Act.add(objActivity3);
        
        DSR_Attachments__c objActivity4 = new DSR_Attachments__c();
        objActivity4.DSRSCEDesign__c = design.id;
        objActivity4.DSRSCEngagement__c = dsr.id;
        objActivity4.ObjectType__c = 'Discovery Activity';
        objActivity4.AttachmentType__c = 'aa';
        objActivity4.Description__c ='aa';
        objActivity4.DateofAttachment__c = Date.Today();
        lst_Act.add(objActivity4);
        
        insert lst_Act;
        
        ApexPages.currentPage().getParameters().put('id', dsr.Id);
        
        DSRSolutioOverviewCtlr dsrCtlr = new DSRSolutioOverviewCtlr();
        dsrCtlr.postSolutionOverview();
    }

}