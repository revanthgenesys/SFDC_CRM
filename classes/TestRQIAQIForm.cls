@isTest(SeeAllData=true)
private class TestRQIAQIForm {

    static testMethod void testRQIAQIForm() {
        RqiAqiForm RAF = new RqiAqiForm();
        //returning cases
        //date range
        ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
    	ApexPages.currentPage().getParameters().put('datestart','12/12/2012');
    	ApexPages.currentPage().getParameters().put('dateend','12/12/2013');
    	
    	//testing > 6 cases
    	RAF.authorname=new RQI_Audit__c(Author__c= TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	RAF.valuesFromUser();
    	RAF.getcaseList();
    	//System.assert(RAF.getcaseList().size() > 0);
    	
    	
        //testing < 6 cases
        RAF.authorname=new RQI_Audit__c(Author__c= TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	RAF.valuesFromUser();
    	
    	//prev 2 months
    	//testing no cases
    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
    	ApexPages.currentPage().getParameters().put('datestart','');
    	ApexPages.currentPage().getParameters().put('dateend','');
    	RAF.valuesFromUser();
    	
    	//returning articles
    	//set date range
    	ApexPages.currentPage().getParameters().put('casesorarticles','retArticles');
    	ApexPages.currentPage().getParameters().put('datestart','12/12/2012');
    	ApexPages.currentPage().getParameters().put('dateend','12/12/2013');
    	
    	//testing articles > 4
    	RAF.authorname=new RQI_Audit__c(Author__c= TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	RAF.valuesFromUser();
    	RAF.getarticleList();
    	//System.assert(RAF.getarticleList().size() > 0);
    	
    	//testing articles < 4
    	RAF.authorname=new RQI_Audit__c(Author__c= TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	RAF.valuesFromUser();
    	
    	//prev 2 months
    	//testing no articles
    	ApexPages.currentPage().getParameters().put('casesorarticles','retArticles');
    	ApexPages.currentPage().getParameters().put('datestart','');
    	ApexPages.currentPage().getParameters().put('dateend','');
    	RAF.valuesFromUser();
    	
    }
}