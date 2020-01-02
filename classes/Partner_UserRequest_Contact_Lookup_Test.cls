@isTest(seeAllData = true)
private class Partner_UserRequest_Contact_Lookup_Test {

    static testMethod void myUnitTest() {
      
      Test.StartTest();
      Account testAccount = TestUtil.createAccounts(1, true)[0];
      Apexpages.currentPage().getParameters().put('searchText','test');
      Apexpages.currentPage().getParameters().put('op', '003');
      Apexpages.currentPage().getParameters().put('fields','Id,Email');
      Apexpages.currentPage().getParameters().put('role','');
      Apexpages.currentPage().getParameters().put('query',testAccount.Id);
      Partner_UserRequest_Contact_Lookup_Class objController = new Partner_UserRequest_Contact_Lookup_Class();
      List<Contact> setRecords = objController.objects;
      Test.StopTest();
    }
}