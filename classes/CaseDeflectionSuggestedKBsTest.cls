@isTest
public with sharing class CaseDeflectionSuggestedKBsTest {

	static testMethod void testcaseDefelectionData() {
		
		CaseDeflectionSuggestedKBs cdsk = new CaseDeflectionSuggestedKBs();
		cdsk.supportProduct = '003U000000jX8GFIA0';
		cdsk.majorRelease = 'theVersion';
		
		system.assert(cdsk.getSelectedCategories() != null);
		
		
		
	}

}