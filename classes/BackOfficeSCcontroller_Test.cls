@isTest
public class BackOfficeSCcontroller_Test {
	
	static testMethod void boaSCcontrTest() {
	
        TestUtil.setConfigValues();
        
		Account accnt = TestUtil.createAccounts(1, true)[0];
        		
		Back_Office_Account__c boa = new Back_Office_Account__c();
		boa.Sold_To_Account__c = accnt.Id;
		boa.End_User_Account__c = accnt.Id;
 
        List<Back_Office_Account__c> boaLst = new List<Back_Office_Account__c>();
        boaLst.add(boa);
        
        BackOfficeAccountUtil.setBoaFields(boaLst);
        insert boa;
		
		ApexPages.StandardController stc = new ApexPages.StandardController(boa);
		BackOfficeAccountServContractsController boaCon = new BackOfficeAccountServContractsController(stc);
		boaCon.activeSrvContracts();
		boaCon.closedSrvContracts();
	}

}