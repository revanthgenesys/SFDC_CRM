@isTest (seeAllData = true) 
private class SMLCreateSMLDataSnapshotsTest { 
    static testMethod void testSMLCreateSMLDataSnapshots(){ 
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        
        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;
        
        SMLCreateSMLDataSnapshots.createSnapshotDataForAccount(testAccount.id, false);
        SMLCreateSMLDataSnapshots.createSnapshotDataForAccount(testAccount.id, true);
    } 
    
    static testMethod void testSMLCreateSMLDataSnapshotsBatch(){
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        
        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;
        
        Test.startTest();
        String batjobId = Database.executeBatch(new SMLCreateSMLDataSnapshotsBatch('SELECT id FROM Account WHERE id = \'' +testAccount.id  + '\' ', false),10);
        Test.stopTest();        
    }
    
    static testMethod void testSMLCreateSMLDataSnapshotsSchedular(){
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        
        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;
        
        Test.StartTest();
        SMLCreateSMLDataSnapshotsBatchSchedular testSchedule = new SMLCreateSMLDataSnapshotsBatchSchedular();
        String sch = '0 0 23 * * ?';
        System.schedule('Test Schedular', sch, testSchedule);
        Test.StopTest();        
    }           
}