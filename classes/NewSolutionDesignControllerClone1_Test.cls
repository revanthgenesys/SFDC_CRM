/*
* Created By: Ashish Goyal (05/13/2019)
* Desc: Test class for the VF Controller, Trigger, and TriggerHelper created for MDM Functionality
*/
@isTest(seealldata=true)
private class NewSolutionDesignControllerClone1_Test {
    
    static testmethod void test_ValidateTest(){
        //Create Account          
        List<Account> lstAcc=TestUtil.createAccounts(1,true);           
       
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:userinfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        update objUser;  
        
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
        
        DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
        objSCDesign.DSR_SCEngagement__c = dsr.id;
        objSCDesign.HAType__c = 'aa';
        objSCDesign.DataCenters__c = 'aa';
        insert objSCDesign ;
        
        DSR_Use_Case_Blueprints__c objFnUseCase = new DSR_Use_Case_Blueprints__c();
        objFnUseCase.DSRSCEDesign__c = objSCDesign.id;
        objFnUseCase.DSRSCEngagement__c = dsr.id;
        objFnUseCase.ShortCode__c = 'B01';
        objFnUseCase.Type__c = 'Use Case';
        objFnUseCase.Name__c = 'aa';
        insert objFnUseCase;
        
        DSR_Use_Case_Blueprints__c objFnUseCase1 = new DSR_Use_Case_Blueprints__c();
        objFnUseCase1.DSRSCEDesign__c = objSCDesign.id;
        objFnUseCase1.DSRSCEngagement__c = dsr.id;
        objFnUseCase1.ShortCode__c = 'B01';
        objFnUseCase1.Type__c = 'Use Case';
        objFnUseCase1.Name__c = 'IVR';
        insert objFnUseCase1;
        
        DSR_Use_Case_Blueprints__c objFnUseCase2 = new DSR_Use_Case_Blueprints__c();
        objFnUseCase2.DSRSCEDesign__c = objSCDesign.id;
        objFnUseCase2.DSRSCEngagement__c = dsr.id;
        objFnUseCase2.ShortCode__c = 'B01';
        objFnUseCase2.Type__c = 'Use Case';
        objFnUseCase2.Name__c = 'IVR interaction';
        insert objFnUseCase2;
        
        DSR_Use_Case_Blueprints__c objFnUseCase3 = new DSR_Use_Case_Blueprints__c();
        objFnUseCase3.DSRSCEDesign__c = objSCDesign.id;
        objFnUseCase3.DSRSCEngagement__c = dsr.id;
        objFnUseCase3.ShortCode__c = 'Custom';
        objFnUseCase3.Type__c = 'Use Case';
        objFnUseCase3.Name__c = 'aa';
        insert objFnUseCase3;
        
        Solution_Design__c sdobj = new Solution_Design__c();
        sdobj.name = 'test';
        insert sdobj;       
               
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/NewSolutionDesignVFClone1?dsrId='+dsr.Id+'&dsrSceId='+objSCDesign.Id));
        New_Solution_Design__c nsdObj = new New_Solution_Design__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(nsdObj);
        NewSolutionDesignControllerClone1 controlr = new NewSolutionDesignControllerClone1(sc);
        controlr.nsdObj.Outbound_Only__c = true;
        controlr.saveRecord();        
        controlr.editRecord();
        controlr.reviseRecord();
        controlr.SubmitApproval();
        controlr.backToPage();
        controlr.redirectToClonePage();
        controlr.relaodVoiceSection();
        controlr.relaodStorageSection();
        controlr.relaodDialerSection();
        controlr.sendSoWRequest();
        controlr.backToView();
        
        Customer_Site__c newcSite = new Customer_Site__c();
        newcSite.New_Solution_Design__c = controlr.nsdObj.Id;
        newcSite.Solution_Design__c = sdobj.Id;
        newcSite.Customer_Site_Name__c = 'test';
        insert newcSite;
        ININ_Applications__c appObj = new ININ_Applications__c();
        appObj.New_Solution_Design__c = controlr.nsdObj.Id;
        appObj.Application_Name__c = 'test';
        insert appObj;
        ININ_Solution_Components__c SCObj = new ININ_Solution_Components__c();
        SCObj.New_Solution_Design__c = controlr.nsdObj.Id;
        SCObj.Solution_Design__c = sdobj.Id;        
        insert SCObj; 

/*        String myString = 'StringToBlob';
     	Blob myBlob = Blob.valueof(myString);
        Attachment att = new Attachment(parentid=controlr.nsdObj.Id, Name = 'test Attachment' , Body = myBlob );
        insert att;
        
        controlr.uploadAttachment();*/
        
        
      
		Test.setCurrentPageReference(new PageReference('/apex/NewSolutionDesignVFClone1?dsrId='+dsr.Id+'&Id='+controlr.nsdObj.Id));
        NewSolutionDesignControllerClone1 controlr2 = new NewSolutionDesignControllerClone1();
        
        controlr.nsdObj.Outbound_Only__c = false;
        controlr.nsdObj.Dialer__c = true;        
        controlr.nsdObj.Screen_Storage__c = 'Customer premise (requires local RCS)';
        controlr.nsdObj.Voice_Storage__c = 'Customer premise (requires local RCS)';
        controlr.saveRecord();
        
        Test.setCurrentPageReference(new PageReference('/apex/NewSolutionDesignVFClone1?dsrId='+dsr.Id+'&dsrSceId='+objSCDesign.Id+'&Id='+controlr.nsdObj.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(controlr.nsdObj);
        NewSolutionDesignControllerClone1 controlr3 = new NewSolutionDesignControllerClone1(sc2);
        controlr3.relaodVoiceSection();
        controlr3.relaodStorageSection();
        controlr3.relaodDialerSection();
        controlr3.sendSoWRequest();
        
        Test.setCurrentPageReference(new PageReference('/apex/NewSolutionDesignVFClone1?dsrId='+dsr.Id+'&dsrSceId='+objSCDesign.Id+'&cloneId='+controlr.nsdObj.Id));
        ApexPages.StandardController sc3 = new ApexPages.StandardController(controlr.nsdObj);
        NewSolutionDesignControllerClone1 controlr4 = new NewSolutionDesignControllerClone1(sc3);
        controlr4.saveRecord();
        
        Test.stopTest();
    }
}