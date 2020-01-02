@isTest
private class POCUtility_Test {
	@isTest
    private static void getSubRegionalUserstest(){
        Wow_Sub_Regional_Users__c testrec = new Wow_Sub_Regional_Users__c();
        testrec.Segment__c = 'Commercial';
        testrec.Offering_Type__c='PureCloud';
        testrec.Name='testrecord';
        testrec.SubRegion__c='Andean';
        testrec.Region__c='Test';
        insert testrec;
        Id LeaderId = POCUtility.getSubRegionalUsers('Test','Andean');
        List<String> results=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Andean','PureCloud');
        List<String> results2=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Andean','PureEngage');
        List<String> results3=POCUtility.getSubRegionalNewUsersForSharing('Commercial','Sample','PureEngage');
        List<String> results4=POCUtility.getSubRegionalNewUsersForSharing('','Sample','PureEngage');
        List<Wow_Sub_Regional_Users__c> subregions = POCUtility.getSubRegionalNewUsersName('Commercial','Andean','PureCloud');
        List<Wow_Sub_Regional_Users__c> subregions2 = POCUtility.getSubRegionalNewUsersName('Commercial','Andean','PureEngage');
        List<Wow_Sub_Regional_Users__c> subregions3 = POCUtility.getSubRegionalNewUsersName('','Andean','PureEngage');
       
    }

}