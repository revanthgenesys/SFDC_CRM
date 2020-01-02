public class PartnerKPIManagementController {
    // Pagination variables 
    public Integer pageSize{get; set;}
	public Integer pageNumber{get; set;}
    public Integer totalPages{get; set;}
    public Integer totalRecords{get; set;}
    public Integer startRecord{get; set;}
    public Integer endRecord{get; set;}
    
    // Messages variable
    public boolean messageExists {get; set;}
    
    // Business Logic Variable
    public Integer year {get; set;}
    public List<SelectOption> periods {get; set;}
    public String selectedPeriod {get; set;}
    
    // List to hold the information about Unprocessed Contacts
    public List<String> caseIds {get; set;}
    public List<CaseWrapper> cases {get; set;} 
    
    public List<Partner_KPI_Publish_History__c> publishHistory {get; set;}
    public String publishHistoryIdToDelete {get; set;}
    
    public Partner_KPI_Header_Stage__c kpiHeader {get; set;}
    
    // Filters
    public List<SelectOption> soldToFilterOptions {get; set;} 
    public String selectedSoldToFilter {get; set;}
    
    public PartnerKPIManagementController(){
        publishHistoryIdToDelete = '';
        messageExists = false;
        pageSize = 10;
        cases = new List<CaseWrapper>();
        publishHistory = new List<Partner_KPI_Publish_History__c>();
        year = Date.today().year();
        
        refreshPeriods();
    }
    
	public void refreshPeriods(){
        selectedPeriod = '-- SELECT --';
        periods = new List<SelectOption>();
        periods.add(new SelectOption('-- SELECT --','-- SELECT --'));
        periods.add(new SelectOption('Sep/Oct/Nov '+(year-1),'Sep/Oct/Nov '+(year-1)));
        periods.add(new SelectOption('Dec/Jan/Feb '+year,'Dec/Jan/Feb '+year));
        periods.add(new SelectOption('Mar/Apr/May '+year,'Mar/Apr/May '+year));
        periods.add(new SelectOption('Jun/Jul/Aug '+year,'Jun/Jul/Aug '+year));
        
        soldToFilterOptions = new List<SelectOption>();
        soldToFilterOptions.add(new SelectOption('-- ALL --', '-- ALL --')); 
		selectedSoldToFilter = '-- ALL --';
        //return null;
    }

    public void refreshCasesData(){
		initializeCases();
        // return null;
    }
    
    public PageReference returnToPartnerKPI(){
        PageReference pg = new PageReference('/apex/PartnerKPIManagement');
        pg.setRedirect(true);
        return pg;
    }
    
    
    
    public void initializeCases(){
 		pageNumber = startRecord = endRecord = totalPages = totalRecords = 0;
  		soldToFilterOptions = new List<SelectOption>();
        soldToFilterOptions.add(new SelectOption('-- ALL --', '-- ALL --')); 
		selectedSoldToFilter = '-- ALL --';
        Map<String, String> soldToMap = new Map<String, String>();
        Map<String, Integer> soldToCasesCountMap = new Map<String, Integer>();
        String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();
        
        caseIds = new List<String>();
        
        String casesQuery = 'SELECT Id, Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.Region__c, End_User_Account__c, End_User_Account__r.Name '
                      	+ ' FROM Case WHERE ' + PartnerKPIManagementUtil.buildWhereConditionForGivenPeriod(selectedPeriod)  
            			+ ' ORDER BY Sold_To_Account__r.Name, End_User_Account__r.Name, Sold_To_Account__r.Region__c, ClosedDate ';
        if(Test.isRunningTest()){
            casesQuery = casesQuery + ' LIMIT 25 ';
        }
        
        for(Case c : Database.query(casesQuery)){
            caseIds.add(c.Id);
			if(c.Sold_To_Account__c != NULL){
            	soldToMap.put(c.Sold_To_Account__c, c.Sold_To_Account__r.Name);    
                if(soldToCasesCountMap.containsKey(c.Sold_To_Account__c)){
                   soldToCasesCountMap.put(c.Sold_To_Account__c, soldToCasesCountMap.get(c.Sold_To_Account__c) + 1); 
                } else {
                   soldToCasesCountMap.put(c.Sold_To_Account__c, 1); 
                }
            }                            
        }
        
        for(String s: soldToMap.keySet()){
           soldToFilterOptions.add(new SelectOption(s, soldToMap.get(s) + ' ('+ soldToCasesCountMap.get(s) +')')); 
        }
		totalRecords = caseIds.size();
        totalPages = totalRecords / pageSize;
		if( (totalPages * pageSize) < totalRecords)        
        	totalPages++;
        
        fetchCases(++pageNumber);    
        publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                          FROM Partner_KPI_Publish_History__c 
                          WHERE Period__c = :selectedPeriod
                          ORDER BY CreatedDate DESC ];

    }

    /*
    public PageReference resetFilters(){
        initializeCases();
		return null;
    } 
	*/
    
	public void applyFilters(){
        kpiHeader = new Partner_KPI_Header_Stage__c();
        String filterStr = '';
        if(selectedSoldToFilter != '-- ALL --'){
            filterStr += 'Sold_To_Account__c = \'' + selectedSoldToFilter + '\' AND ';

            List<Partner_KPI_Header_Stage__c>  partnerKPIHeaders  = [SELECT id, Name, Unique_Key__c, Account__c, Account_Name__c, Partner_Name__c, Region__c,
                                                                     Period__c, Period_From__c, Period_To__c, Quarter__c, 
                                                                     Problem_Description__c, Supporting_Information__c,
                                                                     Closure_Assessment__c, Closure_Assessment_YTD__c, 
                                                                     Quality_Assessment__c, Quality_Assessment_YTD__c,
                                                                     Training_Assessment__c, Training_Assessment_YTD__c,
                                                                     Cases_Closed_by_Default__c, Cases_Closed_by_Default_YTD__c,
                                                                     Total_KPI_Score__c, Total_YTD_KPI_Score__c, 
                                                                     Closed_By_Default__c, YTD_Closed_By_Default__c 
                                                                     FROM Partner_KPI_Header_Stage__c WHERE Account__c = :selectedSoldToFilter AND Period__c = :selectedPeriod];
            if(!partnerKPIHeaders.isEmpty()){
                kpiHeader = partnerKPIHeaders[0];
            }
            
        }

        String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();
        
        pageNumber = startRecord = endRecord = totalPages = totalRecords = 0;
        caseIds = new List<String>();
        String queryStr = '';
        queryStr = 'SELECT Id, Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.Region__c, End_User_Account__c, End_User_Account__r.Name '
                     + ' FROM Case WHERE '+ filterStr + PartnerKPIManagementUtil.buildWhereConditionForGivenPeriod(selectedPeriod)  
                     + ' ORDER BY Sold_To_Account__r.Name, End_User_Account__r.Name, Sold_To_Account__r.Region__c, ClosedDate';

        for(Case c : Database.query(queryStr)){
            caseIds.add(c.Id);
        }
        
        totalRecords = caseIds.size();
        totalPages = totalRecords / pageSize;
		if( (totalPages * pageSize) < totalRecords)        
        	totalPages++;
        
        fetchCases(++pageNumber);    
        publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                          FROM Partner_KPI_Publish_History__c 
                          WHERE Period__c = :selectedPeriod
                          ORDER BY CreatedDate DESC ];
        //return null;
    }
    public void fetchCases(Integer currentPage){
        Integer startRecordIndex = ((currentPage - 1) * pageSize);
        Integer endRecordIndex = currentPage * pageSize - 1;
        if(caseIds.size()-1 < endRecordIndex)
            endRecordIndex = caseIds.size()-1;
        
        List<String> currentCaseIds = new List<String>();
        for(Integer i = startRecordIndex; i <= endRecordIndex; i++){
            currentCaseIds.add(caseIds.get(i));
        }
       	cases = new List<CaseWrapper>();
        
        List<Case> currentPageCases = [SELECT Id, CaseNumber, Sold_To_Account__c, Sold_To_Account__r.Name, 
				 Sold_To_Account__r.Region__c, End_User_Account__c, End_User_Account__r.Name, ContactId, 
				 Contact.ViewCentral_ID__c, Contact_Name__c, Contact.Email, Support_Product__c, Support_Product__r.Name, 
                 Priority, Subject,  CreatedDate, ClosedDate, Closure_Category__c, Closure_Reason_Code__c, 
                 Business_Impact_Product__c, Problem_Description_clear_and_detail__c, Supporting_Info_Provided__c, 
                 Missing_Supporting_Information__c, Should_have_been_solved_using_KB__c, Publicly_Available_Documents__c, 
				 Sub_Status__c, GU_Certified_Contact__c, Owner.Name 
				FROM Case WHERE Id IN :currentCaseIds 
				ORDER BY Sold_To_Account__r.Name, End_User_Account__r.Name, Sold_To_Account__r.Region__c, ClosedDate];
        		
        for(Case c : currentPageCases){
			cases.add(new CaseWrapper(c,selectedPeriod));
		} 
        
		startRecord = startRecordIndex + 1;
        endRecord = endRecordIndex + 1;
     }
    
    public PageReference recalculateKPIHeader(){
        if(selectedSoldToFilter != '-- ALL --' && selectedPeriod != '-- SELECT --'){
	        PartnerKPIManagementUtil.compileKPIInfoForPartnerPerPeriod(selectedSoldToFilter,selectedPeriod);
			List<Partner_KPI_Header_Stage__c>  partnerKPIHeaders  = [SELECT id, Name, Unique_Key__c, Account__c, Account_Name__c, Partner_Name__c, Region__c,
                                                                     Period__c, Period_From__c, Period_To__c, Quarter__c, 
                                                                     Problem_Description__c, Supporting_Information__c,
                                                                     Closure_Assessment__c, Closure_Assessment_YTD__c, 
                                                                     Quality_Assessment__c, Quality_Assessment_YTD__c,
                                                                     Training_Assessment__c, Training_Assessment_YTD__c,
                                                                     Cases_Closed_by_Default__c, Cases_Closed_by_Default_YTD__c,
                                                                     Total_KPI_Score__c, Total_YTD_KPI_Score__c, 
                                                                     Closed_By_Default__c, YTD_Closed_By_Default__c 
                                                                     FROM Partner_KPI_Header_Stage__c WHERE Account__c = :selectedSoldToFilter AND Period__c = :selectedPeriod];
            if(!partnerKPIHeaders.isEmpty()){
                kpiHeader = partnerKPIHeaders[0];
            }            
        }
        return null;
    }
    
    // Methods for publishing
	public PageReference publishData(){
        List<Partner_KPI_Publish_History__c> publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                                                                  FROM Partner_KPI_Publish_History__c 
                                                               WHERE Period__c = :selectedPeriod AND Status__c IN ('Pending', 'Processing') ORDER BY CreatedDate DESC];
        if(!publishHistory.isEmpty()){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'INFO: Publishing request for ['+publishHistory[0].Period__c+'] has been submitted already. You can publish once it is completed.'));
        } else {
           Partner_KPI_Publish_History__c historyObject = new Partner_KPI_Publish_History__c(Published_User__c = UserInfo.getUserId(), Period__c = selectedPeriod, Status__c = 'Pending');
           insert historyObject;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'INFO: Your Publishing request has been submitted successfully. An email will be sent once it is completed.')); 
           messageExists = true;
           // fire the batch process for offline processing ... 
           Database.executeBatch(new PartnerKPIManagementBatch(historyObject.Id), 1);
        }
        return null;
    }
    
    public PageReference publishHistoryDelete(){
        if(publishHistoryIdToDelete != ''){
        	Database.delete((ID)publishHistoryIdToDelete);    
        }
		publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                          FROM Partner_KPI_Publish_History__c 
                          WHERE Period__c = :selectedPeriod
                          ORDER BY CreatedDate DESC ];
        return null;
    }  
    
    
    // Pagination Methods for Processed Contacts
	// Enable Previous if Current Page is greater than 1
    public Boolean getDisablePrevious(){
        return (pageNumber == 1 ? true : false);
    }
    // Enable Next if Still records are there in the list 
    public Boolean getDisableNext(){
        return ((pageNumber * pageSize) < totalRecords ? false : true);
    }
    public Boolean getDisableFirst(){
        return (totalRecords > pageSize && pageNumber > 1 ? false: true);
    }
    public Boolean getDisableLast(){
        return (pageNumber * pageSize < totalRecords ? false : true);
    }
    
    public PageReference refresh() {
        fetchCases(pageNumber);
        return null;
    }
    
    public PageReference firstBtnClick() {
        pageNumber = 1;
        fetchCases(pageNumber);
        return null;
    }
    
    public PageReference lastBtnClick() {
        pageNumber = totalRecords / pageSize;
		if( (pageNumber * pageSize) < totalRecords)        
        	pageNumber++;
        
        fetchCases(pageNumber);
        return null;
    }
    
    public PageReference nextBtnClick() {
        fetchCases(++pageNumber);
        return null;
    }
    
    public PageReference previousBtnClick() {
        fetchCases(--pageNumber);
        return null;
    }
    
    
    
    public class CaseWrapper{
        public Case caseObject {get; set;}
        public String reportingPeriod {get; set;}	
		
        public CaseWrapper(Case caseObject, String reportingPeriod){
            this.caseObject = caseObject;
            this.reportingPeriod = reportingPeriod;
        }
        
		public String getCertified(){
            return caseObject.GU_Certified_Contact__c;
        }	
        public Integer getProblemDescriptionWeighted(){
            return caseObject.Problem_Description_clear_and_detail__c == 'Yes' ? 15 : 0;
        }	
        public Integer getSupportingInfoProvidedWeighted(){
            return caseObject.Supporting_Info_Provided__c == 'No' ? 0 : 15;
        }
        public String getSupportingInfoProvided(){
            return caseObject.Supporting_Info_Provided__c == 'No' ? 'No' : 'Yes';
        }	
		public Integer getQualityAssessment(){
            return getProblemDescriptionWeighted() + getSupportingInfoProvidedWeighted();
        }		
        public Integer getClosureAssessment(){
            return caseObject.Should_have_been_solved_using_KB__c == 'No' ? 30 : 0;
        }		
		public Integer getGUCertifiedSummary(){
            return caseObject.GU_Certified_Contact__c == 'Yes' ? 20 : 0;
        }		
		public Integer getCasesClosedByDefault(){
            return caseObject.Sub_Status__c == 'Auto Follow-Up' ? 0 : 20;
        }		
		public Integer getTotalScore(){
            return getQualityAssessment() + getClosureAssessment() + getGUCertifiedSummary() + getCasesClosedByDefault();
        }		
		public Integer getTotalScoreAvailable(){
            return 100;
        }		
        public Double getKPI(){
            return (Double)getTotalScore() / 100.0;
        }	
        public String getSubStatusGroup(){
            return caseObject.Sub_Status__c == 'Auto Follow-Up' ? 'Auto Follow-Up' : 'Closed by Contact';
        }
        public Integer getNumAutoFollowUp(){
            return caseObject.Sub_Status__c == 'Auto Follow-Up' ? 1 : 0;
        }
        public Integer getNumClosedbyContact(){
            return caseObject.Sub_Status__c == 'Auto Follow-Up' ? 0 : 1;
        }
        
        // methods for Long text fields in Short form
        public String getCaseSubject(){
            if(caseObject.Subject != NULL && caseObject.Subject.length() > 30)
                return caseObject.Subject.substring(0,30) + ' ...';
            else 
                return caseObject.Subject;
        }
        
        public String getCaseBusinessImpact(){
            if(caseObject.Business_Impact_Product__c != NULL && caseObject.Business_Impact_Product__c.length() > 30)
                return caseObject.Business_Impact_Product__c.substring(0,30) + ' ...';
            else 
                return caseObject.Business_Impact_Product__c;
        }
        public String getCasePubliclyAvailableDocuments(){
            if(caseObject.Publicly_Available_Documents__c != NULL && caseObject.Publicly_Available_Documents__c.length() > 30)
                return caseObject.Publicly_Available_Documents__c.substring(0,30) + ' ...';
            else 
                return caseObject.Publicly_Available_Documents__c;
        }
    }
}