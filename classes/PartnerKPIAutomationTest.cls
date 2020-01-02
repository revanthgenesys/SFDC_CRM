/*
 * Class			: PartnerKPIAutomationTest
 * Description		: This Test Class covers Unit Tests for all the following classes.
 * 					- UpdateCasesForGUCertifiedContact1
 * 					- UpdateCasesForGUCertifiedContact2 
 * 					- PartnerKPIManagementBatch
 * 					- PartnerKPIManagementController
 * 					- PartnerKPIExportController
 * 					- PartnerKPIManagementUtil
 * 					- PartnerKPIYTDCalculationsDailyBatch
 * 					- PartnerKPIYTDCalculationsDailyScheduler
 * 
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Jun 22, 2016 
 */
@isTest(seeAllData=true)
private class PartnerKPIAutomationTest {
    
    static testMethod void testUpdateCasesForGUCertifiedContact1() {
        Test.startTest();
        UpdateCasesForGUCertifiedContact1 batchClass =  new UpdateCasesForGUCertifiedContact1();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCasesForGUCertifiedContact2() {
        Test.startTest();
        UpdateCasesForGUCertifiedContact2 batchClass =  new UpdateCasesForGUCertifiedContact2();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();
    }
	
    static testMethod void testPartnerKPIManagementBatch() {
        Test.startTest();
		Integer year = Date.today().year();
		String period = 'Sep/Oct/Nov ' + (year-1);

        PartnerKPIManagementBatch batchClass;
        ID batchprocessid;
        Partner_KPI_Publish_History__c historyObject = new Partner_KPI_Publish_History__c(Published_User__c = UserInfo.getUserId(), Period__c = period, Status__c = 'Pending');
        insert historyObject;
        batchClass =  new PartnerKPIManagementBatch(historyObject.Id);        
        batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();
    }
	
    static testMethod void testPartnerKPIManagementController() {
        Test.startTest();
        Test.setCurrentPage(Page.PartnerKPIManagement);
        PartnerKPIManagementController controller  = new PartnerKPIManagementController();
        controller.year = Date.today().year();
        controller.refreshPeriods();
		String period1 = 'Sep/Oct/Nov ' + (controller.year-1);
        String period2 = 'Dec/Jan/Feb ' + controller.year;
        String period3 = 'Mar/Apr/May ' + controller.year;
        String period4 = 'Jun/Jul/Aug ' + controller.year;
        
       	controller.selectedPeriod = period1;
        controller.refreshCasesData();
       	controller.selectedPeriod = period2;
        controller.refreshCasesData();
       	controller.selectedPeriod = period3;
        controller.refreshCasesData();
       	controller.selectedPeriod = period4;
        controller.refreshCasesData();
        
       	controller.selectedPeriod = period2;
        controller.refreshCasesData();

        Partner_KPI_Publish_History__c historyObject = new Partner_KPI_Publish_History__c(Published_User__c = UserInfo.getUserId(), Period__c = controller.selectedPeriod, Status__c = 'Pending');
        insert historyObject;
        controller.publishData();
        
		controller.publishHistoryIdToDelete = historyObject.id;
        controller.publishHistoryDelete();
		controller.publishData();
        
        // Pagination Methods testing ...
        controller.getDisablePrevious();
        controller.getDisableNext();
        controller.getDisableFirst();
        controller.getDisableLast();
        controller.refresh();
        controller.firstBtnClick();
        controller.nextBtnClick();
        controller.previousBtnClick();
        controller.lastBtnClick();
        
        controller.selectedSoldToFilter = controller.soldToFilterOptions[1].getValue();

        // Test KPI Header Calculation methods
        controller.recalculateKPIHeader();

        // Test Filters related methods
        controller.applyFilters();
        
        controller.returnToPartnerKPI();
        
        // Test CaseWrapper Methods 
        Case c = [SELECT Id, CaseNumber, Sold_To_Account__c, Sold_To_Account__r.Name, 
				 Sold_To_Account__r.Region__c, End_User_Account__c, End_User_Account__r.Name, ContactId, 
				 Contact.ViewCentral_ID__c, Contact_Name__c, Contact.Email, Support_Product__c, Support_Product__r.Name, 
                 Priority, Subject,  CreatedDate, ClosedDate, Closure_Category__c, Closure_Reason_Code__c, 
                 Business_Impact_Product__c, Problem_Description_clear_and_detail__c, Supporting_Info_Provided__c, 
                 Missing_Supporting_Information__c, Should_have_been_solved_using_KB__c, Publicly_Available_Documents__c, 
				 Sub_Status__c, GU_Certified_Contact__c, Owner.Name 
				 FROM Case LIMIT 1];
        PartnerKPIManagementController.CaseWrapper cw = new PartnerKPIManagementController.CaseWrapper(c, controller.selectedPeriod);
        cw.getCertified();
        cw.getProblemDescriptionWeighted();
		cw.getSupportingInfoProvidedWeighted();
		cw.getQualityAssessment();
		cw.getClosureAssessment();
		cw.getGUCertifiedSummary();
		cw.getTotalScore();
		cw.getTotalScoreAvailable();
		cw.getKPI();
		cw.getSubStatusGroup();
		cw.getNumAutoFollowUp();
		cw.getNumClosedbyContact();
		cw.getCaseSubject();
		cw.getCaseBusinessImpact();
		cw.getCasePubliclyAvailableDocuments();
            
        
        Test.stopTest();
    }
    
    static testMethod void testPartnerKPIExportController() {
        Test.startTest();
        
        PartnerKPIManagementController controller  = new PartnerKPIManagementController();
        controller.year = Date.today().year();
        controller.refreshPeriods();
        String period = 'Dec/Jan/Feb ' + controller.year;

        String period1 = 'Sep/Oct/Nov ' + (controller.year-1);
        String period2 = 'Dec/Jan/Feb ' + controller.year;
        String period3 = 'Mar/Apr/May ' + controller.year;
        String period4 = 'Jun/Jul/Aug ' + controller.year;
        
        
       	controller.selectedPeriod = period2;
        controller.refreshCasesData();
        String soldToFilter = controller.soldToFilterOptions[1].getValue();
        
        PartnerKPIExportController exportController;
        Test.setCurrentPage(Page.PartnerKPIExport);
		System.currentPageReference().getParameters().put('sp', period1);
		System.currentPageReference().getParameters().put('stfilter', soldToFilter);
        exportController  = new PartnerKPIExportController();

		System.currentPageReference().getParameters().put('sp', period2);
		System.currentPageReference().getParameters().put('stfilter', soldToFilter);
        exportController  = new PartnerKPIExportController();

		System.currentPageReference().getParameters().put('sp', period3);
		System.currentPageReference().getParameters().put('stfilter', soldToFilter);
        exportController  = new PartnerKPIExportController();

		System.currentPageReference().getParameters().put('sp', period4);
		System.currentPageReference().getParameters().put('stfilter', soldToFilter);
        exportController  = new PartnerKPIExportController();
        
        // Test CaseWrapper Methods 
        Case c = [SELECT Id, CaseNumber, Sold_To_Account__c, Sold_To_Account__r.Name, 
				 Sold_To_Account__r.Region__c, End_User_Account__c, End_User_Account__r.Name, ContactId, 
				 Contact.ViewCentral_ID__c, Contact_Name__c, Contact.Email, Support_Product__c, Support_Product__r.Name, 
                 Priority, Subject,  CreatedDate, ClosedDate, Closure_Category__c, Closure_Reason_Code__c, 
                 Business_Impact_Product__c, Problem_Description_clear_and_detail__c, Supporting_Info_Provided__c, 
                 Missing_Supporting_Information__c, Should_have_been_solved_using_KB__c, Publicly_Available_Documents__c, 
				 Sub_Status__c, GU_Certified_Contact__c, Owner.Name 
				 FROM Case LIMIT 1];
        
        PartnerKPIHeadersExportController headerExportController;
        Test.setCurrentPage(Page.PartnerKPIHeadersExport);
    	System.currentPageReference().getParameters().put('sp', period1);
    	System.currentPageReference().getParameters().put('stfilter', soldToFilter);
        headerExportController = new PartnerKPIHeadersExportController();
        List<Partner_KPI_Header_Stage__c> kpiHeaders = headerExportController.kpiHeaders;
        Test.stopTest();
    } 
    
    static testMethod void testPartnerKPIManagementUtil() {
        Test.startTest();
    	PartnerKPIManagementUtil.compileKPIInfoForAllPartnersThroughBatch();
        PartnerKPIManagementUtil.getCurrentPeriod();
    	Test.stopTest();
	}
    
    static testMethod void testPartnerKPIYTDCalculationsDailyBatch() {
        Test.startTest();
 		PartnerKPIYTDCalculationsDailyBatch batchClass =  new PartnerKPIYTDCalculationsDailyBatch();       
        ID batchprocessid = Database.executeBatch(batchClass);
    	Test.stopTest();
	}
    
    static testMethod void testPartnerKPIYTDCalculationsDailyScheduler(){
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler', cronExp, new PartnerKPIYTDCalculationsDailyScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
}