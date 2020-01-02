//Naresh Kumar	12/20/2014
@isTest(seeAllData = true)
private class GCRContentDocAddApproversControllerTest {
	static String documentId;
	static String documentApprovalId;
	static String index;
	static String gcrId;
	
	static void insertTestData(){
		Country__c testCountry = new Country__c();
		testCountry.Name = 'Test Country';
		testCountry.Country__c = 'Test Country';
		testCountry.Region__c = 'APAC';
		insert testCountry;
		
		Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Country__c = testCountry.id;
        insert acct;
      
        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'Test Opportunity';
        acct.Country__c = testCountry.id;
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.Today();        
        insert opp;
             
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';        
        insert con;
        
        List<GCR__c> gcrList = new List<GCR__c>();   
        
        GCR__c gcr = new GCR__c();
        gcr.Contact__c = con.id;
        gcr.Account__c = acct.Id;
        gcr.Region__c = acct.Country__r.Region__c;
        gcr.Request_Type__c = 'Sales';
        gcr.Contact_Name__c = con.Name;
        gcr.Contact_Phone__c = con.ContactPhone__c;
        gcr.Requestor_Name__c = UserInfo.getUserId();
        gcr.Attorney_Name__c = UserInfo.getUserId();
        gcrList.add(gcr);
        insert gcrList;
        
        GCR_Content_Document_Detail__c document = new GCR_Content_Document_Detail__c();        
        document.Account_Name__c = acct.Id;
        document.GCR__c = gcrList[0].id;       
        document.Active__c = true;
		insert document;
		
		GCR_Content_Document_Detail_Approval__c documentApproval = new GCR_Content_Document_Detail_Approval__c();
		documentApproval.GCR_Content_Document_Detail__c = document.id;
		insert documentApproval;
		String queueId;
		User testUser = TestUtil.createUsers(1, true)[0];
		System.runAs(testUser){
			Group g1 = new Group(Name = 'TestQueue', type = 'Queue');
	        insert g1;
	        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'GCR_Content_Document_Detail_Approval__c');
	        insert q1;
	        queueId = q1.id;
	        GroupMember gm1 = new GroupMember(GroupId = g1.id, UserOrGroupId = UserInfo.getUserId());
			insert gm1;
		}
		documentApproval.ownerId = queueId;				
		
		gcrId = gcrList[0].id;
		documentId = document.id;
		documentApprovalId = documentApproval.id;
		index = '1';
		
	}
    static testMethod void myUnitTest1() {
    	insertTestData();
    	ApexPages.currentPage().getParameters().put('id', documentId);
		ApexPages.currentPage().getParameters().put('index', index);
		ApexPages.currentPage().getParameters().put('gcrId', gcrId);
		ApexPages.currentPage().getParameters().put('submissionCounter', '1');
		ApexPages.currentPage().getParameters().put('approvalId', documentApprovalId);
		
    	GCRContentDocAddApproversController objCont = new GCRContentDocAddApproversController();
    	objCont.selectedApprovers = Label.GCR_Content_Document_Addititional_Approvers.split(',')[0];
    	objCont.addApprovers();
    }
    
    static testMethod void testHistoryController(){
    	insertTestData();
    	GCRContentDocApprovalHistoryController objHistoryCont = new GCRContentDocApprovalHistoryController();
    	objHistoryCont.gcrDocumentId = documentId;
    	objHistoryCont.getApprovals();
    }
    
     static testMethod void testApproveRejectController1(){
    	insertTestData();
    	GCR_Content_Document_Detail_Approval__c docApproval = new GCR_Content_Document_Detail_Approval__c(id = documentApprovalId);
    	delete docApproval;
    	ApexPages.currentPage().getParameters().put('id', documentId);
    	ApexPages.currentPage().getParameters().put('approvalRecord', documentApprovalId);
    	ApexPages.currentPage().getParameters().put('retURL', '/home');
    	GCRContentDocumentApproveReject objApproveReject = new GCRContentDocumentApproveReject();
    	//objApproveReject.approve();
    	objApproveReject.cancel();
    	//objApproveReject.reject();
    }
     
    static testMethod void testApproveRejectController2(){    	
    	insertTestData();
    	GCR_Content_Document_Detail_Approval__c docApproval = new GCR_Content_Document_Detail_Approval__c(id = documentApprovalId, Status__c = QuoteApprovalUtil.STATUS_PENDING);
    	update docApproval;
    	ApexPages.currentPage().getParameters().put('id', documentId);
    	ApexPages.currentPage().getParameters().put('approvalRecord', documentApprovalId);
    	ApexPages.currentPage().getParameters().put('retURL', '/home');
    	GCRContentDocumentApproveReject objApproveReject = new GCRContentDocumentApproveReject();
    	objApproveReject.approve();
    	objApproveReject.cancel();
    	
    }
    static testMethod void testApproveRejectController3(){
    	insertTestData();
    	GCR_Content_Document_Detail_Approval__c docApproval = new GCR_Content_Document_Detail_Approval__c(id = documentApprovalId, OwnerId = UserInfo.getUserId());
    	update docApproval;
    	ApexPages.currentPage().getParameters().put('id', documentId);
    	ApexPages.currentPage().getParameters().put('approvalRecord', documentApprovalId);
    	ApexPages.currentPage().getParameters().put('retURL', '/home');
    	GCRContentDocumentApproveReject objApproveReject = new GCRContentDocumentApproveReject();
    	objApproveReject.approve();
    	objApproveReject.cancel();
    	objApproveReject.reject();
    }
    static testMethod void testApproveRejectController4(){    	
    	insertTestData();
    	GCR_Content_Document_Detail_Approval__c docApproval = new GCR_Content_Document_Detail_Approval__c(id = documentApprovalId, Status__c = QuoteApprovalUtil.STATUS_PENDING);
    	update docApproval;
    	ApexPages.currentPage().getParameters().put('id', documentId);
    	ApexPages.currentPage().getParameters().put('approvalRecord', documentApprovalId);
    	ApexPages.currentPage().getParameters().put('retURL', '/home');
    	GCRContentDocumentApproveReject objApproveReject = new GCRContentDocumentApproveReject();
    	objApproveReject.reject();
    	objApproveReject.cancel();
    }
    static testMethod void testApproveRejectController5(){    	
    	insertTestData();
    	GCR_Content_Document_Detail_Approval__c documentApproval = new GCR_Content_Document_Detail_Approval__c();
		documentApproval.GCR_Content_Document_Detail__c = documentId;
		documentApproval.Status__c = QuoteApprovalUtil.STATUS_PENDING;
		insert documentApproval;
    	GCR_Content_Document_Detail_Approval__c docApproval = new GCR_Content_Document_Detail_Approval__c(id = documentApprovalId, Status__c = QuoteApprovalUtil.STATUS_PENDING);
    	update docApproval;
    	ApexPages.currentPage().getParameters().put('id', documentId);
    	ApexPages.currentPage().getParameters().put('approvalRecord', documentApprovalId);
    	ApexPages.currentPage().getParameters().put('retURL', '/home');
    	GCRContentDocumentApproveReject objApproveReject = new GCRContentDocumentApproveReject();
    	//objApproveReject.aprove();
    	//objApproveReject.cancel();
    	documentApproval.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
    	update documentApproval;
    }
}