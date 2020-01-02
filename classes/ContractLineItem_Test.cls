/*
	Naresh Kumar	06/21/2013
*/
@isTest(seeAllData=true)
private class ContractLineItem_Test {
    static testMethod void myUnitTest() {
    	try{
	    	ServiceContract testSC = TestUtil.createServiceContracts(1, true)[0];
	        ContractLineItem testSCLI = TestUtil.createContractLineItems(testSC.id, 1, true)[0];
	        
    	}
    	catch(Exception e){}
    	try{
    		Customer_Care_Analyst_Skill__c testSkills = new Customer_Care_Analyst_Skill__c();
	        insert testSkills;
    	}
    	catch(Exception e){}
    }
}