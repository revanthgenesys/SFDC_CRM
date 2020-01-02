/***************************************************************************************************
* 
*  Class Name      :   SCEngagementDSRCtlrTest
*  Description     :   This class is used to unit test the SCEngagementDSRCtlr
*  Auther          :   R Systems
* 
****************************************************************************************************/
@isTest
private class SCEngagementDSRCtlrTest {
    @isTest(seealldata=true)
    private static void TestFirst() {
        test.startTest();
        //Create Account          
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
           
        //find current user          
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser;  
        
        
        //find  country
        country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
       
            Wow_Sub_Regional_Users__c custSet = new Wow_Sub_Regional_Users__c();
        custSet.Name = 'Test';
        custSet.Subregional_Leader__c = 'amit@rsys.com';
        custSet.User_Name__c = 'Test';
        insert custSet;
        
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
        PageReference pageRef = Page.SC_Engagement_DSR;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('oppid', ObjOpp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(dsr);
        SCEngagementDSRCtlr sceng = new SCEngagementDSRCtlr(sc);
        sceng.submitDetails();
        
        SCEngagementPartnerDSRCtlr objPart = new SCEngagementPartnerDSRCtlr(sc);
        
        objPart.submitDetails();
        objPart.openVision();
        objPart.openDiscovery();
        objPart.OpenHistory();
        objPart.OpenDesign();
        objPart.OpenDeliver();
        objPart.OpenSolutionOverview();
        SCEngagementPartnerDSRCtlr.GetWowStage('Lead Assign');
        SCEngagementPartnerDSRCtlr.CreateHistory('test',UserInfo.getUserId(), 'Virtual User', 'Completed','Completed', dsr.id);
        
        sceng.CheckSalesCOE('amit@rsys.com');
        //sceng.CloseDSR();
        
        
        //ApexPages.currentPage().getParameters().put('idu', lstUsr[0].Id);  
        test.StopTest();
    }
    
    
    @isTest(seealldata=true)
    private static void TestSecond() {
        List<User> VTUser = TestUtil.createUsers(1, false);
        VTUser[0].Bypass_Triggers__c = true;
        VTUser[0].BypassWorkflows__c = true;
        VTUser[0].BypassValidationRules__c = true;
        insert VTUser[0];
        
        //Create Account 
        Map<Id,Account> mapAcc = new Map<Id,Account>();         
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
        lstAcc[0].OwnerId = [Select id from User Limit 1].id;
        update lstAcc[0];
        mapAcc.put(lstAcc[0].id,lstAcc[0]);  
        //find current user          
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser;  
        //find  country
        country__c objCountry=[SELECT ID,Region__c FROM country__c WHERE Name=:'New Zealand'] ;   
       
        Map<id,opportunity> newMap = new Map<id,opportunity>();
        Map<id,opportunity> oldMap = new Map<id,opportunity>();
        Opportunity ObjOpp  = TestUtil.createOpportunities(1,lstAcc[0].id, false)[0];
        ObjOpp.Lines_of_Businesses__c = 'PureCloud';
        ObjOpp.StageName = '5.Purchase Solution';
        insert ObjOpp;
        oldMap.put(objOpp.id,objOpp);
        ObjOpp.StageName = '6.Closed';
        update ObjOpp;
        newMap.put(objOpp.id,objOpp);
        
        DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
        dsr.Account_ID__c = lstAcc[0].Id;
        dsr.AE_Name__c = objUser.Id;
        dsr.AssignTo__c = 'Lead Assign';
        dsr.Opportunity_ID__c = ObjOpp.Id;
        dsr.SC_Engagement_Status__c = 'Open and Not Assigned';
        
        insert dsr;
        
        
        DSR_SCE_Design__c objDSD = new DSR_SCE_Design__c();
        objDSD.OfferingPlatformType__c = 'PureCloud';
        objDSD.DSR_SCEngagement__c = dsr.id;
        objDSD.IsPrimary__c = false;
        insert objDSD;
        
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
        dsrvT1.Virtual_Team_Member_Name__c = VTUser[0].id;//objUser.Id;
        dsrvT1.Region__c = 'Region';
        dsrvT1.Sub_Region__c = 'Sub Region';
        dsrvT1.Segment__c = 'Segment';
        dsrvT1.Virtual_User_Role__c = 'Virtual Team';
        test.startTest();
        insert dsrvT1;
        
        ApexPages.CurrentPage().getParameters().put('uId' , dsrvT.Id);
        ApexPages.CurrentPage().getParameters().put('uIdVirtual' , dsrvT1.Id);
        ApexPages.currentPage().getParameters().put('id', dsr.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(dsr);
        SCEngagementDSRCtlr sceng = new SCEngagementDSRCtlr(sc);
        sceng.SelectedStatusType = 'Approve';
        sceng.getStatusTypes();
        sceng.submitDetails();
        
        
        DSR_Virtual_Team__c objV = new DSR_Virtual_Team__c();
        objV.Virtual_Team_Member_Name__c = objUser.Id;
        objV.SCE_ID__c = dsr.Id;
        objV.Virtual_User_type__c = 'Solution Consultant';
        objV.IsPrimary__c = true;
        insert objV;
        sceng.dsrVirtualTeamEdit = objV;
        //sceng.dsrVirtualTeamEdit = dsrvT1;
        sceng.uIdVTEdit = VTUser[0].Name;
        
        
        sceng.showVirtualTeam();
        sceng.CloseDSR();
        sceng.invokeDSRPage();
        sceng.closeVirtualTeam();
        sceng.closeVirtualTeamCancel();
        sceng.getSubRegionleadersall();
        sceng.showVirtualTeamEdit();
        sceng.closeVirtualTeamEdit();
        sceng.closeVirtualTeamEditCancel();
        
        sceng.showSubRegionalLeaders();
        sceng.closeSubregionalLeaders();
        sceng.closeSubregionalLeadersCancel();
        sceng.removeLeader();
        sceng.removeVirtualTeam();
        
        
        // Links
        
        sceng.openVision();
        sceng.openDiscovery();
        sceng.OpenHistory();
        sceng.OpenDesign();
        sceng.OpenDeliver();
        sceng.OpenSolutionOverview();
        
        dsr.SC_Engagement_Status__c = 'Open and Assigned';
        update dsr; 
        sceng.submitDetails();

        dsr.SC_Engagement_Status__c = 'Open and Assigned';
        update dsr;

        sceng.isAdminUser = true;
        sceng.dsrEngagement = dsr;
        sceng.SaveSCE();
        
        dsr.SC_Engagement_Status__c = 'Submitted for Completion';
        update dsr; 
        
        sceng.submitDetails();
        
        sceng.reOpen();
        //sceng.CloseDSR();
        
        DSRSCEngagementHistoryCtlr objHis = new DSRSCEngagementHistoryCtlr();
        //DSRUtility.GetProfileName(UserInfo.getUserId());
        DSRUtility.GlobalUser(UserInfo.getUserId());
        DSRUtility.getSubRegionalUsersForSC(UserInfo.getUserId(),dsr.id);
        DSRUtility.IsVirtualTeamExist(dsr.id,UserInfo.getUserId());
        DSRUtility.HasReadAccessibility(UserInfo.getProfileId());
        DSRUtility.GetWowStage('Lead Assign');
        
        List<DSR_Virtual_Team__c>list_VT = new List<DSR_Virtual_Team__c>();
        list_VT.add(objV);
        DSRUtility.ShareSCERequest(list_VT);
        DSRUtility.GetFnUseCaseAndBluePrints(ObjOpp.id, 'PureConnect On Premise');
        DSRUtility.GetFnUseCaseAndBluePrints(ObjOpp.id, 'PureCloud');
        DSRUtility.CreateHistory('test',UserInfo.getUserId(), 'Virtual User', 'Completed','Completed', dsr.id);
        DSRUtility.CreateHistory('test','Vision', 'Vision Activity', UserInfo.GetUserId(), 'Virtual User', 'Completed','Completed', dsr.id); 
     }
      
      
      @isTest(seealldata=true) 
      private static void TestThird() {
        List<User> VTUser = TestUtil.createUsers(1, false);
        VTUser[0].Bypass_Triggers__c = true;
        VTUser[0].BypassWorkflows__c = true;
        VTUser[0].BypassValidationRules__c = true;
        insert VTUser[0];
        
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
        
        Opportunity ObjOpp2  = TestUtil.createOpportunities(1,lstAcc[0].id, false)[0];
        ObjOpp2.Lines_of_Businesses__c = 'PureCloud';
        insert ObjOpp2;
        
        DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
        dsr.Account_ID__c = lstAcc[0].Id;
        dsr.AE_Name__c = objUser.Id;
        dsr.Next_Step__c = 'Test';
        dsr.Lessons_Learned_Feedback__c = 'test';
        dsr.Impact_on_Deal__c = 'tetsing';
        dsr.AssignTo__c = 'Lead Assign';
        dsr.Opportunity_ID__c = ObjOpp.Id;
        dsr.SC_Engagement_Status__c = 'Open and Assigned';
        
        insert dsr;
        
        DSR_SCEngagement__c dsr1 = new DSR_SCEngagement__c();
        dsr1.Account_ID__c = lstAcc[0].Id;
        dsr.AE_Name__c = objUser.Id;
        dsr1.Next_Step__c = 'Test';
        dsr1.Lessons_Learned_Feedback__c = 'test';
        dsr1.Impact_on_Deal__c = 'tetsing';
        dsr1.AssignTo__c = 'Lead Assign';
        dsr1.Opportunity_ID__c = ObjOpp2.Id;
        dsr1.SC_Engagement_Status__c = 'Open and Assigned';
        
        insert dsr1;
        
        DSR_SCE_Design__c objDSD = new DSR_SCE_Design__c();
        objDSD.OfferingPlatformType__c = 'PureCloud';
        objDSD.DSR_SCEngagement__c = dsr1.id;
        objDSD.IsPrimary__c = true;
        objDSD.IsPrimary__c = false;
        insert objDSD;
        
        DSR_Virtual_Team__c dsrvT = new DSR_Virtual_Team__c();
        dsrvT.SCE_ID__c = dsr.Id;
        dsrvT.Virtual_Team_Member_Name__c = objUser.Id;
        dsrvT.Region__c = 'Region';
        dsrvT.Sub_Region__c = 'Sub Region';
        dsrvT.Segment__c = 'Segment';
        dsrvT.Notes__c = 'test';
        dsrvT.Virtual_User_Role__c = 'Sub Regional Leader';
        dsrvT.Virtual_User_type__c = 'Solution Consultant';
        dsrvT.IsPrimary__c = true;
        
        insert dsrvT;
        
        DSR_Virtual_Team__c dsrvT1 = new DSR_Virtual_Team__c();
        dsrvT1.SCE_ID__c = dsr.Id;
        dsrvT1.Virtual_Team_Member_Name__c =UserInfo.getUserId();//objUser.Id;
        dsrvT1.Region__c = 'Region';
        dsrvT1.Sub_Region__c = 'Sub Region';
        dsrvT1.Segment__c = 'Segment';
        dsrvT1.Virtual_User_Role__c = 'Virtual Team';
        dsrvT1.Notes__c = 'test';
        dsrvT1.IsPrimary__c = true;
        dsrvT1.Virtual_User_type__c = 'Solution Consultant';
        test.startTest();
        insert dsrvT1;
        
        DSR_Virtual_Team__c dsrvT11 = new DSR_Virtual_Team__c();
        dsrvT11.SCE_ID__c = dsr1.Id;
        dsrvT11.Virtual_Team_Member_Name__c =UserInfo.getUserId();//objUser.Id;
        dsrvT11.Region__c = 'Region';
        dsrvT11.Sub_Region__c = 'Sub Region';
        dsrvT1.Segment__c = 'Segment';
        dsrvT11.Virtual_User_Role__c = 'Virtual Team';
        dsrvT11.Notes__c = 'test';
        dsrvT11.IsPrimary__c = true;
        dsrvT11.Virtual_User_type__c = 'Solution Consultant';
        insert dsrvT11;
                
        ApexPages.currentPage().getParameters().put('id', dsr.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(dsr);
        SCEngagementDSRCtlr sceng = new SCEngagementDSRCtlr(sc);
        sceng.SelectedStatusType = 'Approve';
        sceng.getStatusTypes();
        sceng.submitDetails();
        
        
        DSR_Virtual_Team__c objV = new DSR_Virtual_Team__c();
        objV.Virtual_Team_Member_Name__c = objUser.Id;
        objV.SCE_ID__c = dsr.Id;
        objV.Virtual_User_type__c = 'Solution Consultant';
        objV.IsPrimary__c = true;
        objV.Notes__c = 'test';
        insert objV;
        
        DSR_Virtual_Team__c objV1 = new DSR_Virtual_Team__c();
        objV1.Virtual_Team_Member_Name__c = objUser.Id;
        objV1.SCE_ID__c = dsr.Id;
        objV1.Virtual_User_type__c = 'Solution Consultant';
        objV1.Virtual_User_Role__c ='Sub Regional Leader';
        objV1.IsPrimary__c = true;
        objV1.Notes__c = 'test';
        insert objV1;
        
        DSR_Attachments__c objActivity = new DSR_Attachments__c();
        objActivity.ObjectType__c = 'Vision Activity';
        objActivity.AttachmentType__c = 'V1';
        objActivity.DSRSCEngagement__c = dsr1.id;
        objActivity.Access__c = 'aa';
        objActivity.Source__c = 'aa';
        objActivity.DateofAttachment__c = Date.Today();
        objActivity.AttachmentURL__c = 'www.abc.com';
        objActivity.Description__c = 'hh';
        insert objActivity ;
        
        DSR_Attachments__c objActivity1 = new DSR_Attachments__c();
        objActivity1.ObjectType__c = 'Discovery Activity';
        objActivity1.AttachmentType__c = 'V1';
        objActivity1.DSRSCEngagement__c = dsr1.id;
        objActivity1.Access__c = 'aa';
        objActivity1.Source__c = 'aa';
        objActivity1.DateofAttachment__c = Date.Today();
        objActivity1.AttachmentURL__c = 'www.abc.com';
        objActivity1.Description__c = 'hh';
        insert objActivity1 ;
        
        DSR_Attachments__c objActivity2 = new DSR_Attachments__c();
        objActivity2.ObjectType__c = 'Delivery Requirements';
        objActivity2.AttachmentType__c = 'V1';
        objActivity2.DSRSCEngagement__c = dsr1.id;
        objActivity2.Access__c = 'aa';
        objActivity2.Source__c = 'aa';
        objActivity2.DateofAttachment__c = Date.Today();
        objActivity2.AttachmentURL__c = 'www.abc.com';
        objActivity2.Description__c = 'hh';
        insert objActivity2 ;
        
        DSR_Attachments__c objActivity3 = new DSR_Attachments__c();
        objActivity3.ObjectType__c = 'Design Activity';
        objActivity3.AttachmentType__c = 'V1';
        objActivity3.DSRSCEngagement__c = dsr1.id;
        objActivity3.Access__c = 'aa';
        objActivity3.Source__c = 'aa';
        objActivity3.DateofAttachment__c = Date.Today();
        objActivity3.AttachmentURL__c = 'www.abc.com';
        objActivity3.Description__c = 'hh';
        insert objActivity3 ;
        
        DSR_Attachments__c objActivity4 = new DSR_Attachments__c();
        objActivity4.ObjectType__c = 'Business Design Attachment';
        objActivity4.AttachmentType__c = 'V1';
        objActivity4.DSRSCEngagement__c = dsr1.id;
        objActivity4.DSRSCEDesign__c = objDSD.id;
        objActivity4.Access__c = 'aa';
        objActivity4.Source__c = 'aa';
        objActivity4.DateofAttachment__c = Date.Today();
        objActivity4.AttachmentURL__c = 'www.abc.com';
        objActivity4.Description__c = 'hh';
        insert objActivity4 ;
        
        DSR_Attachments__c objActivity5 = new DSR_Attachments__c();
        objActivity5.ObjectType__c = 'Technical Design Attachment';
        objActivity5.AttachmentType__c = 'V1';
        objActivity5.DSRSCEngagement__c = dsr1.id;
        objActivity5.DSRSCEDesign__c = objDSD.id;
        objActivity5.Access__c = 'aa';
        objActivity5.Source__c = 'aa';
        objActivity5.DateofAttachment__c = Date.Today();
        objActivity5.AttachmentURL__c = 'www.abc.com';
        objActivity5.Description__c = 'hh';
        insert objActivity5 ;
        
        sceng.getWrapperSubRegionalLeaders();
        sceng.SaveSCE();
        
        dsr.Next_Step__c = 'Test12';
        update dsr;
        
        List<DSR_SCEngagement__c > dsrObj = [Select id,name from DSR_SCEngagement__c where id =: dsr.id limit 1];
        system.debug('++++++++++>>> dsrObj   '+dsrObj[0].name);
        List<DSR_SCEngagement__c > dsrObj1 = [Select id,name from DSR_SCEngagement__c where id =: dsr1.id limit 1];
        system.debug('++++++++++>>> dsrObj1   '+dsrObj1[0].name);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(dsr1);
        SCEngagementDSRCtlr sceng1 = new SCEngagementDSRCtlr(sc1);
        sceng1.isAdminUser= true;
        sceng1.isVirtualUser = true;
        sceng1.isSubRegional= true;
        sceng1.getWrapperSubRegionalLeaders();
        sceng1.SaveSCE();
        
        sceng1.showCopyDSRPopup();
        sceng1.copyDSRObj.dsrName = dsrObj1[0].Name;
        sceng1.copyDSRObj.isPrimaryDesign = true;
        sceng1.copyDSRObj.isAllDesign = true;
        sceng1.copyDSRObj.isVision = true;
        sceng1.copyDSRObj.isDiscovery = true;
        sceng1.copyDSRObj.isDelivery= true;
        sceng1.copyDSRObj.isBusiness= true;
        sceng1.copyDSRObj.isTechnical= true;
        sceng1.copyDSRFromDSR();
        
        sceng1.cancelCopyDSRPopup();
        sceng1.enableDesignCopy();
        
        List<String> dsrIdList = new List<String>();
        dsrIdList.add(dsr.id); 
        
        DSRViewController.getDSR(dsrIdList);
        test.StopTest();
      }
      
      
      @isTest(seealldata=true) 
      private static void TestOpportunityPreSalesPriority() {
        test.startTest();
        List<User> VTUser = TestUtil.createUsers(1, false);
        VTUser[0].Bypass_Triggers__c = true;
        VTUser[0].BypassWorkflows__c = true;
        VTUser[0].BypassValidationRules__c = true;
        insert VTUser[0];
        
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
        dsr.Pre_Sales_Priority__c = 'Genesys for Sales';
        insert dsr;
        
        ObjOpp.Pre_Sales_Priority__c = 'Genesys for Sales;Genesys for Services';
        update ObjOpp;
        
        test.StopTest();
    }
    
     static testMethod void TestSeconda() {
        List<User> VTUser = TestUtil.createUsers(1, false);
        VTUser[0].Bypass_Triggers__c = true;
        VTUser[0].BypassWorkflows__c = true;
        VTUser[0].BypassValidationRules__c = true;
        insert VTUser[0];
        
        //Create Account 
        Map<Id,Account> mapAcc = new Map<Id,Account>();         
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
        lstAcc[0].OwnerId = [Select id from User Limit 1].id;
        update lstAcc[0];
        mapAcc.put(lstAcc[0].id,lstAcc[0]);  
        //find current user          
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser; 
       
        Map<id,opportunity> newMap = new Map<id,opportunity>();
        Map<id,opportunity> oldMap = new Map<id,opportunity>();
        
        Opportunity ObjOpp  = TestUtil.createOpportunities(1,lstAcc[0].id, false)[0];
        ObjOpp.Lines_of_Businesses__c = 'PureCloud';
        ObjOpp.StageName = '5.Purchase Solution';
        insert ObjOpp;
        oldMap.put(objOpp.id,objOpp);
        
        DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
        dsr.Opportunity_ID__c = ObjOpp.Id;
        dsr.SC_Engagement_Status__c = 'Open and Assigned';
        insert dsr;
        
        DSR_SCE_Design__c objDSD = new DSR_SCE_Design__c();
        objDSD.OfferingPlatformType__c = 'PureCloud';
        objDSD.DSR_SCEngagement__c = dsr.id;
        objDSD.IsPrimary__c = false;
        insert objDSD;
        
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
        dsrvT1.Virtual_Team_Member_Name__c = VTUser[0].id;//objUser.Id;
        dsrvT1.Region__c = 'Region';
        dsrvT1.Sub_Region__c = 'Sub Region';
        dsrvT1.Segment__c = 'Segment';
        dsrvT1.Virtual_User_Role__c = 'Virtual Team';
        test.startTest();
        insert dsrvT1;
        
        ObjOpp.StageName = '6.Closed';
        ObjOpp.AccountId = lstAcc[0].id;
        update ObjOpp;
        newMap.put(objOpp.id,objOpp);
        
        DSRUtility.sendNotificationtoSCSRL(newMap,oldMap);
        DSRUtility.fetchOppIdFromAccount(lstAcc,mapAcc);
     }
}