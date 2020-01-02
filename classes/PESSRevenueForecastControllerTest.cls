//Naresh Kumar  05/09/2016
@isTest(seeAllData = true)
private class PESSRevenueForecastControllerTest { 
  static Account testAccount;
    static Account_Revenue_Forecast__c testARF;
    static testmethod void PESSRevenueForecastController1() {
      insertData();
      PESSRevenueForecastController objController = new PESSRevenueForecastController(); 
      objController.populateWeeks();
      objController.records[0].isSelected = true;
      objController.save();
      objController.goToPage();
      objController.next();
      objController.previous();
      objController.populateData();
      objController.next();
      objController.next();
      
    }
    
    static testmethod void PESSRevenueForecastController2017() {
      insertData();
      PESSRevenueForecastController2017 objController = new PESSRevenueForecastController2017(); 
      objController.populateWeeks();
      objController.records[0].isSelected = true;
      objController.save();
      objController.goToPage();
      objController.next();
      objController.previous();
      objController.populateData();
      
    }
    
    static testmethod void PESSRevenueForecastController2018() {
      insertData();
      PESSRevenueForecastController2018 objController = new PESSRevenueForecastController2018(); 
      objController.populateWeeks();
      objController.records[0].isSelected = true;
      objController.save();
      objController.goToPage();
      objController.next();
      objController.previous();
      objController.populateData();
      objController.next();
      objController.next();
      
    }
    static testMethod void PESSRevenueForecastCommentsController1(){
      /*
      insertData();
      PESSRevenueForecastCommentsController objController = new PESSRevenueForecastCommentsController();
      objController.save();
      objController.search();
      */
    }
    
    static testMethod void PESSRevenueForecastCommentsController2(){
      ApexPages.currentPage().getParameters().put('page', 'Change');
      insertData();
      PESSRevenueForecastCommentsController objController = new PESSRevenueForecastCommentsController();      
      objController.save();
      objController.search();
    }
    
    static testMethod void PESSRevenueForecastControllerOutbound(){
      ApexPages.currentPage().getParameters().put('page', 'Change');
      insertData();
      PESSRevenueForecastControllerOutbound objController = new PESSRevenueForecastControllerOutbound();      
      objController.save();
      //objController.search();
    }
    
    
    
    private static void insertData(){
      testAccount = TestUtil.createAccounts(1, false)[0];
      testAccount.PE_SS_Flag__c = true;
      insert testAccount;
      testARF = new Account_Revenue_Forecast__c();
      testARF.Account__c = testAccount.id;
      testARF.PE_SS_Flag__c = true;
      testARF.Comment_Validation__c = true;
      insert testARF;
    }
    }