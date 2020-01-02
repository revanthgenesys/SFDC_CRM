@isTest(seeAllData = true)
private class WorkspaceConnectorBAController_Test {

    static testMethod void findCaseFromNumber_Test()
    {
        String test_subject = '123test321test';
        //error leg
        Case result = WorkspaceConnectorBAController.findCaseFromNumber('1');
        //System.assert(result == null);
         
        //Create Case test data
       	Case testCase = TestUtil.createCases(1, true)[0];
        Case myCase = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id];  
        result = WorkspaceConnectorBAController.findCaseFromNumber(myCase.CaseNumber);
        //System.assert(result!=null);
    }
    
    static testMethod void test_getProductFromName()
    {
        String test_name = '123test321test';
        //error leg
        Support_Product__c result = WorkspaceConnectorBAController.getProductFromName(test_name);
        //System.assert(result == null);
        //create test data
        Support_Product__c testProduct = new Support_Product__c(Name = test_name);
        insert testProduct;
        Support_Product__c product = [SELECT Name FROM Support_Product__c WHERE Name= :test_name];
        result = WorkspaceConnectorBAController.getProductFromName(product.Name);
        //System.assert(result!=null);
    }     
    
    static testMethod void WorkspaceConnector_Test()
    {       
        String connectorInfo = WorkspaceConnectorBAController.getWorkspaceConnectorInfo();
        //System.assert(connectorInfo != null);
    }
    
    static testMethod void findObjectFromANI_Test() {
        Object id;
        //Error leg
        id = WorkspaceConnectorBAController.findObjectFromANI('5558555');
        //System.assert(id == null);
        
        //Create Account test data 
        Account acc = new Account(Name = 'Test Account', Phone = '5555', Status__c = 'Active');     	
        id = WorkspaceConnectorBAController.findObjectFromANI('5555');
        //System.assert(id == null);
        
        insert acc;
        id = WorkspaceConnectorBAController.findObjectFromANI('5555');
        //System.assert(id != null);
        
        //Create Contact test data
        Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444', MobilePhone = '3333',  Email = 'test@test.com', accountId = acc.id);
        id = WorkspaceConnectorBAController.findObjectFromANI('4444');
        //System.assert(id == null);
        
        insert con;
        id = WorkspaceConnectorBAController.findObjectFromANI('4444');
        //System.assert(id != null);
    }    
    
    static testMethod void createActivity_Test() {
        Map<String,String> fieldsMap = new Map<String,String>();
        String contactResult = WorkspaceConnectorBAController.createActivity(fieldsMap);
        //System.assert(contactResult != null);
    }    
}