/*

Raghu R : 2/3/2014 : MDM Project : Test Class for the Trigger AccountAddress_Trigger and AcntAdrs_Trigger_Class 

*/


@isTest(SeeAllData=true)
private class AcntAdrs_Trigger_Class_Test {

    static testMethod void updateAdrsAsPrimary_1() {
    	
    test.startTest();
    Account testAccount = TestUtil.createAccounts(1, true)[0];
    List<Address__c> adrssList = new List<Address__c>();
    
    Map<Integer,String> addressTypeMap = new Map<Integer,String>{0 => 'Sold To' , 1 => 'End User',2 => 'Bill To',3 => 'Ship To', 4 => 'Corporate'};
    
    for(Integer i=0; i < 5; i++)
    {
      Address__c address = new Address__c(Address_Line_1__c = 'test', Address_Line_2__c = 'test2',Type__c = addressTypeMap.get(i),Account__c = testAccount.id);
      adrssList.add(address); 
    }
    insert adrssList;

    delete adrssList[0];
    
    Address__c isert_enduser = new Address__c (); 
    isert_enduser.Type__c = 'End User';
    isert_enduser.Account__c = testAccount.id;
    insert isert_enduser;
    
    
    delete adrssList[1]; delete isert_enduser;
    
    Address__c isert_billto = new Address__c (); 
    isert_billto.Type__c = 'Bill To';
    isert_billto.Account__c = testAccount.id;
    insert isert_billto;
    
    delete adrssList[2]; delete isert_billto;
    
    Address__c isert_shipTo = new Address__c (); 
    isert_shipTo.Type__c = 'Ship To';
    isert_shipTo.Account__c = testAccount.id;
    insert isert_shipTo;
    
    delete adrssList[3]; delete isert_shipTo;
    
    Address__c isert_Corporate = new Address__c (); 
    isert_Corporate.Type__c = 'Corporate';
    isert_Corporate.Account__c = testAccount.id;
    insert isert_Corporate;
    test.stopTest();
   }
}