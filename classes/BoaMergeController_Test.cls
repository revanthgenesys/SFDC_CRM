@isTest
public class BoaMergeController_Test {
	
	static testMethod void testMerge () {

     Util.Bypass_Trigger_Chk = true; 
    RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
        List<Account> testAccounts = TestUtil.createAccounts(2, false);
        testAccounts[0].RecordTypeId = rType.id;
        testAccounts[0].Status__c = 'Active';
        testAccounts[0].Name = 'Test Group Account 1';
        testAccounts[1].Name = 'Holding Account';
        insert testAccounts;
        
        List<Contact> testContacts = TestUtil.createContacts(2, testAccounts[0], false);
        testContacts[1].AccountId = testAccounts[1].id;
        insert testContacts;
        
        Account accnt1 = testAccounts[0];
        Account accnt2 = testAccounts[1];
 
        Contact cont1 = testContacts[0];
        Contact cont2 = testContacts[1];
        		
		Back_Office_Account__c boaTo = new Back_Office_Account__c();
		boaTo.Contract_Status__c = 'Active';
	   	boaTo.Service_Type__c = 'Premise';
	   	boaTo.Approval_Status__c = 'Active';
	   	boaTo.Sold_To_Account__c = accnt1.id;
	   	boaTo.End_User_Account__c = accnt1.id;
	   	boaTo.Unique_STEU__c = accnt1.id + '_' + accnt1.id ;
	   	boaTo.End_User_Name__c = accnt1.Name;
	   	boaTo.Sold_To_Name__c = accnt1.Name;
        insert boaTo;
        
        Back_Office_Account__c boaFrom = new Back_Office_Account__c();
		boaFrom.Contract_Status__c = 'Active';
	   	boaFrom.Service_Type__c = 'Premise';
	   	boaFrom.Approval_Status__c = 'Active';
	   	boaFrom.Sold_To_Account__c = accnt2.id;
	   	boaFrom.End_User_Account__c = accnt2.id;
	   	boaFrom.Unique_STEU__c = accnt2.id + '_' + accnt2.id ;
	   	boaFrom.End_User_Name__c = accnt2.Name;
	   	boaFrom.Sold_To_Name__c = accnt2.Name;
        insert boaFrom;
        
        Back_Office_Account__c boafr = [SELECT Name FROM Back_Office_Account__c WHERE Id = :boaFrom.Id LIMIT 1];
        
        Support_Access__c sa1 = new Support_Access__c (Contact__c = cont1.Id, Back_Office_Account__c = boaTo.Id, Status__c = 'Active');
        insert sa1;
        Support_Access__c sa2 = new Support_Access__c (Contact__c = cont1.Id, Back_Office_Account__c = boaFrom.Id, Status__c = 'Active');
        insert sa2;
        Support_Access__c sa3 = new Support_Access__c (Contact__c = cont2.Id, Back_Office_Account__c = boaFrom.Id, Status__c = 'Active');
        insert sa3;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(boaTo);
    	BoaMergeController mrgContrl = new BoaMergeController(stdController);
  
    	if ( boafr != null)
    		mrgContrl.searchBoaFromName = boafr.Name;
 
        mrgContrl.getSupportAccessList();
          mrgContrl.mergeBoa();              
        //this should cover errors 
        mrgContrl.mergeBoa(); 
          mrgContrl.searchBoaFromName = null;
        mrgContrl.getSupportAccessList();
        
         mrgContrl.searchBoaFromName = '123';
         mrgContrl.getSupportAccessList();
         
        Test.stopTest();     
                                                        
	}
    
   static testMethod void testClone () {
	   Util.Bypass_Trigger_Chk = true; 
    
    RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
        List<Account> testAccounts = TestUtil.createAccounts(2, false);
        testAccounts[0].RecordTypeId = rType.id;
        testAccounts[0].Status__c = 'Active';
        testAccounts[0].Name = 'Test Group Account 1';
        testAccounts[1].Name = 'Holding Account';
        insert testAccounts;
        
        List<Contact> testContacts = TestUtil.createContacts(2, testAccounts[0], false);
        testContacts[1].AccountId = testAccounts[1].id;
        insert testContacts;
        
        Account accnt1 = testAccounts[0];
        Account accnt2 = testAccounts[1];
 
        Contact cont1 = testContacts[0];
        Contact cont2 = testContacts[1];
        		
		Back_Office_Account__c boaTo = new Back_Office_Account__c();
		boaTo.Contract_Status__c = 'Active';
	   	boaTo.Service_Type__c = 'Premise';
	   	boaTo.Approval_Status__c = 'Active';
	   	boaTo.Sold_To_Account__c = accnt1.id;
	   	boaTo.End_User_Account__c = accnt1.id;
	   	boaTo.Unique_STEU__c = accnt1.id + '_' + accnt1.id ;
	   	boaTo.End_User_Name__c = accnt1.Name;
	   	boaTo.Sold_To_Name__c = accnt1.Name;
        insert boaTo;
        
        Back_Office_Account__c boaFrom = new Back_Office_Account__c();
		boaFrom.Contract_Status__c = 'Active';
	   	boaFrom.Service_Type__c = 'Premise';
	   	boaFrom.Approval_Status__c = 'Active';
	   	boaFrom.Sold_To_Account__c = accnt2.id;
	   	boaFrom.End_User_Account__c = accnt2.id;
	   	boaFrom.Unique_STEU__c = accnt2.id + '_' + accnt2.id ;
	   	boaFrom.End_User_Name__c = accnt2.Name;
	   	boaFrom.Sold_To_Name__c = accnt2.Name;
        insert boaFrom;
        
        Back_Office_Account__c boafr = [SELECT Name FROM Back_Office_Account__c WHERE Id = :boaFrom.Id LIMIT 1];
        
        Support_Access__c sa1 = new Support_Access__c (Contact__c = cont1.Id, Back_Office_Account__c = boaTo.Id, Status__c = 'Active');
        insert sa1;
        Support_Access__c sa2 = new Support_Access__c (Contact__c = cont1.Id, Back_Office_Account__c = boaFrom.Id, Status__c = 'Active');
        insert sa2;
        Support_Access__c sa3 = new Support_Access__c (Contact__c = cont2.Id, Back_Office_Account__c = boaFrom.Id, Status__c = 'Active');
        insert sa3;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(boaTo);
    	BoaMergeController mrgContrl = new BoaMergeController(stdController);
  
    	if ( boafr != null)
    		mrgContrl.searchBoaFromName = boafr.Name;
 
        mrgContrl.getSupportAccessList();
           
         mrgContrl.cloneBoa();
          //this should cover errors 
        mrgContrl.cloneBoa(); 
          
        Test.stopTest();     
                                                        
	}

}