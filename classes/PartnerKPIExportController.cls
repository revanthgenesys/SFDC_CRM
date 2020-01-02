public class PartnerKPIExportController {
    public String selectedPeriod {get; set;} 
    public List<PartnerKPIManagementController.CaseWrapper> cases {get; set;}
    public PartnerKPIExportController(){
        selectedPeriod = ApexPages.currentPage().getParameters().get('sp');
        String selectedSoldToFilter = ApexPages.currentPage().getParameters().get('stfilter');
        String filterStr = '';
        if(selectedSoldToFilter != NULL && selectedSoldToFilter != '-- ALL --'){
            filterStr += 'Sold_To_Account__c = \'' + selectedSoldToFilter + '\' AND ';
        }
        String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();
        
        cases = new List<PartnerKPIManagementController.CaseWrapper>();
		String queryStr = '';
        queryStr = 'SELECT Id, CaseNumber, Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.Region__c, '
                 + ' End_User_Account__c, End_User_Account__r.Name, ContactId, Contact.ViewCentral_ID__c, Contact_Name__c, Contact.Email, Support_Product__c, Support_Product__r.Name, '
                 + ' Priority, Subject,  CreatedDate, ClosedDate, Closure_Category__c, Closure_Reason_Code__c, '
                 + ' Business_Impact_Product__c, Problem_Description_clear_and_detail__c, Supporting_Info_Provided__c, '
                 + ' Missing_Supporting_Information__c, Should_have_been_solved_using_KB__c, Publicly_Available_Documents__c, Sub_Status__c, GU_Certified_Contact__c, Owner.Name '
                 + ' FROM Case WHERE '+ filterStr + PartnerKPIManagementUtil.buildWhereConditionForGivenPeriod(selectedPeriod) 
            	 + ' ORDER BY Sold_To_Account__r.Name, End_User_Account__r.Name, Sold_To_Account__r.Region__c, ClosedDate';
        for(Case c : Database.query(queryStr)){
			cases.add(new PartnerKPIManagementController.CaseWrapper(c,selectedPeriod));
		} 
    }
}