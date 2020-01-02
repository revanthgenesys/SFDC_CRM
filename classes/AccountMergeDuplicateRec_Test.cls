/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountMergeDuplicateRec_Test {

   static testMethod void testCustomMerge(){
        TestUtil.setConfigValues();
        List<Account> accListToInsert=  TestUtil.createAccounts(3, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[1].name='new test accountt1'; 
        accListToInsert[2].name='new test accountt2';        
        insert accListToInsert;
        System.debug('****accListToInsert'+accListToInsert);
        
        PageReference pageRef = Page.AccountMergeDuplicateRecords;
        pageRef.getParameters().put('id',accListToInsert[0].id);
        
        //String jSonDataCustom = '{\"Entries\" :[{\"fieldName\":\"Id\",\"fieldValue\":\"' + accListToInsert[0].id + '\"},{\"fieldName\":\"Name\",\"fieldValue\":\"' + accListToInsert[0].id + '\"}]}';
        //apexpages.currentpage().getparameters().put('jsonData',jSonDataCustom);
        
        Test.setCurrentPage(pageRef);   
        
        
            
        //Account testAccount = new Account(id='001U000000YdHQb');
        //Account testAccount = new Account(id=accListToInsert[0].id);
        ApexPages.StandardController con = new ApexPages.StandardController(accListToInsert[0]);
        AccountMergeDuplicateRecordsController accountMergeExtensionObj = new AccountMergeDuplicateRecordsController(con);
        accountMergeExtensionObj.selectedAccountList = new List<Account>();
        accountMergeExtensionObj.selectedAccountList.add(accListToInsert[0]);
        
        accountMergeExtensionObj.doNext();
        accountMergeExtensionObj.doPrevious();
        accountMergeExtensionObj.accountName = 'new test accountt';
        accountMergeExtensionObj.searchAccounts();
        accountMergeExtensionObj.doNext();
        
        String jSonDataCustom = '{\"Entries\" :[{\"fieldName\":\"Id\",\"fieldValue\":\"' + accListToInsert[0].id + '\"},{\"fieldName\":\"Name\",\"fieldValue\":\"' + accListToInsert[0].id + '\"}]}';
        apexpages.currentpage().getparameters().put('jsonData',jSonDataCustom);
        
        accountMergeExtensionObj.domerge();
        
        AccountMergeDuplicateRecordsController.sendEmail(accListToInsert[0],accListToInsert,'err');
        
    }
    
   
   static testMethod void testCustomMerge2(){
        TestUtil.setConfigValues();
        List<Account> accListToInsert=  TestUtil.createAccounts(3, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[1].name='new test accountt1'; 
        accListToInsert[2].name='new test accountt2';        
        insert accListToInsert;

        
        PageReference pageRef = Page.AccountMergeDuplicateRecords;
        pageRef.getParameters().put('id',accListToInsert[0].id);
        
        //String jSonDataCustom = '{\"Entries\" :[{\"fieldName\":\"Id\",\"fieldValue\":\"' + accListToInsert[0].id + '\"},{\"fieldName\":\"Name\",\"fieldValue\":\"' + accListToInsert[0].id + '\"}]}';
        //apexpages.currentpage().getparameters().put('jsonData',jSonDataCustom);
        
        Test.setCurrentPage(pageRef);       
        
        
        //Account testAccount = new Account(id=accListToInsert[0].id);
        ApexPages.StandardController con = new ApexPages.StandardController(accListToInsert[0]);
        AccountMergeDuplicateRecordsController accountMergeExtensionObj = new AccountMergeDuplicateRecordsController(con);
        accountMergeExtensionObj.selectedAccountList = new List<Account>();
        accountMergeExtensionObj.selectedAccountList.add(accListToInsert[0]);
        accountMergeExtensionObj.isAssyncMode = true;
        
        accountMergeExtensionObj.doNext();
        accountMergeExtensionObj.doPrevious();
        accountMergeExtensionObj.accountName = 'new test accountt';
        accountMergeExtensionObj.searchAccounts();
        accountMergeExtensionObj.doNext();
        
        String jSonDataCustom = '{\"Entries\" :[{\"fieldName\":\"Id\",\"fieldValue\":\"' + accListToInsert[0].id + '\"},{\"fieldName\":\"Name\",\"fieldValue\":\"' + accListToInsert[0].id + '\"}]}';
        apexpages.currentpage().getparameters().put('jsonData',jSonDataCustom);
        accountMergeExtensionObj.domerge();
        
    }
    
    static testMethod void testCustomMerge3(){
        TestUtil.setConfigValues();
        List<Account> accListToInsert=  TestUtil.createAccounts(4, false);   
        insert accListToInsert;
        System.debug('****accListToInsert'+accListToInsert);
               
        PageReference pageRef = Page.AccountMergeDuplicateRecords;
        pageRef.getParameters().put('id',accListToInsert[0].id);
        Test.setCurrentPage(pageRef);       
        //Account testAccount = new Account(id=accListToInsert[0].id);
        ApexPages.StandardController con = new ApexPages.StandardController(accListToInsert[0]);
        AccountMergeDuplicateRecordsController accountMergeExtensionObj = new AccountMergeDuplicateRecordsController(con);
        
        accountMergeExtensionObj.accountName = 'test account123';
        accountMergeExtensionObj.searchAccounts();
        
        accountMergeExtensionObj.accountName = 'test account';
        accountMergeExtensionObj.searchAccounts();
        
        accountMergeExtensionObj.doNext();
        accountMergeExtensionObj.doPrevious();
        accountMergeExtensionObj.doNext();
        
        String jSonDataCustom = '{\"Entries\" :[{\"fieldName\":\"Id\",\"fieldValue\":\"' + accListToInsert[0].id + '\"},{\"fieldName\":\"Name\",\"fieldValue\":\"' + accListToInsert[0].id + '\"}]}';
        apexpages.currentpage().getparameters().put('jsonData',jSonDataCustom);      
    }
    
}