@isTest(seeAllData=true)
private class Opportunity_H_Test {

	public static testmethod void constructor_Test() {
		// test default constructor
		Opportunity_H obj = new Opportunity_H();
	}

	private static testMethod void test_Opportunity_H() {
		Map<String,RecordType> rtMap = Opportunity_H.RECORDTYPEMAP;
	}

}