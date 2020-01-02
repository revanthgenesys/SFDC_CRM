/*
 * Class            : GenesysCareForecastingV2Controller
 * Description      : A Controller Class for Genesys Care forecasting UI.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
public class GenesysCareForecastingV2Controller {
    public String selectedOfferingType {get; set;}
    public String selectedRegion {get; set;}
    public String selectedYear {get; set;}
    public String selectedQuarter {get; set;}
    public String selectedCurrency {get; set;}
    public Set<Integer> currentYears {get; set;}
    public List<ForecastingData> forecastingDataList {get; set;}
    
    public List<ForecastingData> getforecastingDataListWithTotals() {
    	List<ForecastingData> data = new List<ForecastingData>();
    	
    	ForecastingData q1Data = new ForecastingData();
    	ForecastingData q2Data = new ForecastingData();
    	ForecastingData q3Data = new ForecastingData();
    	ForecastingData q4Data = new ForecastingData();
    	ForecastingData annualData = new ForecastingData();
    	annualData.Name = 'Annual Total';
    	for(ForecastingData fcd : forecastingDataList){
    		String[] names = fcd.Name.split(' ');
    		if(names[0] == 'Jan' || names[0] == 'Feb' || names[0] == 'Mar' ){
    			q1Data.Name = 'Q1 Total';
	            q1Data = aggregateGCFData(q1Data, fcd);
				annualData = aggregateGCFData(annualData, fcd);
			} else if(names[0] == 'Apr' || names[0] == 'May' || names[0] == 'Jun' ){
    			q2Data.Name = 'Q2 Total';
	            q2Data = aggregateGCFData(q2Data, fcd);
				annualData = aggregateGCFData(annualData, fcd);
    		} else if(names[0] == 'Jul' || names[0] == 'Aug' || names[0] == 'Sep' ){
    			q3Data.Name = 'Q3 Total';
	            q3Data = aggregateGCFData(q3Data, fcd);
				annualData = aggregateGCFData(annualData, fcd);
    		} else if(names[0] == 'Oct' || names[0] == 'Nov' || names[0] == 'Dec' ){
    			q4Data.Name = 'Q4 Total';
	            q4Data = aggregateGCFData(q4Data, fcd);
				annualData = aggregateGCFData(annualData, fcd);
    		}
    	}
    	for(ForecastingData fcd : forecastingDataList){
    		data.add(fcd);
    		String[] names = fcd.Name.split(' ');
    		if(names[0] == 'Mar'){
    			data.add(q1Data);	
    		}
    		if(names[0] == 'Jun'){
    			data.add(q2Data);	
    		}
    		if(names[0] == 'Sep'){
    			data.add(q3Data);	
    		}
    		if(names[0] == 'Dec'){
    			data.add(q4Data);	
    		}
    	}
    	if(forecastingDataList.size() > 3){
    		data.add(annualData);	
    	}
    	
    	return data;
    }

	public ForecastingData aggregateGCFData(ForecastingData consolidated, ForecastingData input){
		consolidated.incremental_r 		= consolidated.incremental_r + input.incremental_r;
        consolidated.incremental_e 		= consolidated.incremental_e + input.incremental_e;
        consolidated.incremental_u 		= consolidated.incremental_u + input.incremental_u;
        consolidated.incremental_tiv 	= consolidated.incremental_tiv + input.incremental_tiv;
        consolidated.incremental_tiv_e 	= consolidated.incremental_tiv_e + input.incremental_tiv_e;
        
        consolidated.fym_r 				= consolidated.fym_r + input.fym_r;
        consolidated.fym_u 				= consolidated.fym_u + input.fym_u;
        consolidated.fym_tiv 			= consolidated.fym_tiv + input.fym_tiv;
        consolidated.fym_tiv_e 			= consolidated.fym_tiv + input.fym_tiv_e;
        
        consolidated.billingPlan_r 		= consolidated.billingPlan_r + input.billingPlan_r;
        consolidated.billingPlan_e 		= consolidated.billingPlan_e + input.billingPlan_e;
        consolidated.billingPlan_tiv 	= consolidated.billingPlan_tiv + input.billingPlan_tiv;
        
        consolidated.tbf_ef 			= consolidated.tbf_ef + input.tbf_ef;
        consolidated.tbf_u 				= consolidated.tbf_u + input.tbf_u;
        
        consolidated.deferred 			= consolidated.deferred + input.deferred;
        consolidated.recognized 		= consolidated.recognized + input.recognized;

        return consolidated;
	}
    
    public GenesysCareForecastingV2Controller(){
        currentYears = new Set<Integer>();
        selectedOfferingType = ApexPages.currentPage().getParameters().get('offeringType') != NULL ? ApexPages.currentPage().getParameters().get('offeringType') : 'All';
        selectedRegion = ApexPages.currentPage().getParameters().get('region') != NULL ? ApexPages.currentPage().getParameters().get('region') : 'All';
        selectedYear = ApexPages.currentPage().getParameters().get('year') != NULL ? ApexPages.currentPage().getParameters().get('year') : ''+Date.Today().Year();
        selectedQuarter = ApexPages.currentPage().getParameters().get('quarter') != NULL ? ApexPages.currentPage().getParameters().get('quarter') : 'All';
        selectedCurrency = ApexPages.currentPage().getParameters().get('currency') != NULL ? ApexPages.currentPage().getParameters().get('currency') : 'USD';
        refereshForecastingData();
    }
    
    public List<SelectOption> getCurrencies(){
        List<SelectOption> options = new List<SelectOption>();
        for(String currencyISOCode : GCFUtil.currenciesMap.KeySet()){
	        options.add(new SelectOption(currencyISOCode,currencyISOCode));
        }
        return options;
    }
    
    public List<SelectOption> getRegions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('APAC','APAC'));
        options.add(new SelectOption('EMEA','EMEA'));
        options.add(new SelectOption('Latin America','Latin America'));
        options.add(new SelectOption('North America','North America'));
        return options;
    }
    
    public List<SelectOption> getOfferingTypes() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All','All'));
		options.add(new SelectOption('PureEngage','PureEngage'));
		options.add(new SelectOption('PureConnect','PureConnect'));
   		return options;
    }

    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        Integer year = Date.Today().Year();
        for(Integer i = 0; i < 5; i++){
			options.add(new SelectOption(''+year,''+year));
        	year = year + 1;
        } 
        return options;
    }

    public List<SelectOption> getQuarters() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('1','Q1'));
        options.add(new SelectOption('2','Q2'));
        options.add(new SelectOption('3','Q3'));
        options.add(new SelectOption('4','Q4'));
        return options;
    }     
    
    public void refereshForecastingData(){
    	forecastingDataList = new List<ForecastingData>();
    	
    	Integer startIndex = 1;
		Integer endIndex = 12;
		if(selectedQuarter != 'All'){
			Integer selectedQuarterNumber = Integer.valueOf(selectedQuarter);
			startIndex = ((selectedQuarterNumber - 1) * 3) + 1;
			endIndex = (selectedQuarterNumber) * 3;
		}
    	for(Integer month = startIndex; month <= endIndex; month++){
    		ForecastingData fData = new ForecastingData();
    		fData.Name = GCFUtil.getMonthName(month) + ' ' + selectedYear;
    		forecastingDataList.add(fData);
    	}
    	
        String filterString = '';
        filterString = filterString + ' WHERE Year__c = '+selectedYear;
        if(selectedQuarter != 'All'){
            filterString = filterString + ' AND Quarter__c = '+selectedQuarter;
        }
        if(selectedRegion != 'All'){
            filterString = filterString + ' AND Region__c = \''+selectedRegion+'\'';
        }
    	if(selectedOfferingType != 'All'){
            filterString = filterString + ' AND Offering_Type__c = \''+selectedOfferingType+'\'';
        } else {
        	filterString = filterString + ' AND Offering_Type__c IN (\'PureEngage\', \'PureConnect\') '; 
        }
    	
    	String query = 'SELECT Year_Text__c, Quarter_Text__c, Month_Text__c, '
    				+ 'SUM(Incremental_R__c) Incremental_R__c, SUM(Incremental_E__c) Incremental_E__c, SUM(Incremental_U__c) Incremental_U__c, SUM(Incremental_TIV__c) Incremental_TIV__c, SUM(Incremental_TIV_E__c) Incremental_TIV_E__c,'
    				+ 'SUM(FYM_R__c) FYM_R__c, SUM(FYM_U__c) FYM_U__c, SUM(FYM_TIV__c) FYM_TIV__c, SUM(FYM_TIV_E__c) FYM_TIV_E__c,'
    				+ 'SUM(BillingPlan_R__c) BillingPlan_R__c, SUM(BillingPlan_E__c) BillingPlan_E__c, SUM(BillingPlan_TIV__c) BillingPlan_TIV__c '
    				+ 'FROM GCF_Data__c '
    				+ filterString 
    				+' GROUP BY Year_Text__c, Quarter_Text__c, Month_Text__c ORDER BY Year_Text__c, Quarter_Text__c, Month_Text__c';

		AggregateResult[] results = Database.query(query);

        for(AggregateResult ar : results){
            Integer revenueYear = Integer.valueof((String)ar.get('Year_Text__c'));
            Integer revenueQuarter = Integer.valueof((String)ar.get('Quarter_Text__c'));
            Integer revenueMonth = Integer.valueof((String)ar.get('Month_Text__c'));

            Decimal Incremental_R = ar.get('Incremental_R__c') != NULL ? (Decimal)ar.get('Incremental_R__c') : 0.0;
            Decimal Incremental_E = ar.get('Incremental_E__c') != NULL ? (Decimal)ar.get('Incremental_E__c') : 0.0;
            Decimal Incremental_U = ar.get('Incremental_U__c') != NULL ? (Decimal)ar.get('Incremental_U__c') : 0.0;
            Decimal Incremental_TIV = ar.get('Incremental_TIV__c') != NULL ? (Decimal)ar.get('Incremental_TIV__c') : 0.0;
            Decimal Incremental_TIV_E = ar.get('Incremental_TIV_E__c') != NULL ? (Decimal)ar.get('Incremental_TIV_E__c') : 0.0;
			
            Decimal FYM_R = ar.get('FYM_R__c') != NULL ? (Decimal)ar.get('FYM_R__c') : 0.0;
            Decimal FYM_U = ar.get('FYM_U__c') != NULL ? (Decimal)ar.get('FYM_U__c') : 0.0;
            Decimal FYM_TIV = ar.get('FYM_TIV__c') != NULL ? (Decimal)ar.get('FYM_TIV__c') : 0.0;
            Decimal FYM_TIV_E = ar.get('FYM_TIV_E__c') != NULL ? (Decimal)ar.get('FYM_TIV_E__c') : 0.0;

            Decimal BillingPlan_R = ar.get('BillingPlan_R__c') != NULL ? (Decimal)ar.get('BillingPlan_R__c') : 0.0;
            Decimal BillingPlan_E = ar.get('BillingPlan_E__c') != NULL ? (Decimal)ar.get('BillingPlan_E__c') : 0.0;
            Decimal BillingPlan_TIV = ar.get('BillingPlan_TIV__c') != NULL ? (Decimal)ar.get('BillingPlan_TIV__c') : 0.0;
            
            ForecastingData fData = new ForecastingData();
            fData.Name = GCFUtil.getMonthName(revenueMonth) + ' ' + revenueYear;
            
            // Incremental Forecasting
            fData.incremental_r = GCFUtil.convertCurrency(Incremental_R, 'USD', selectedCurrency);
            fData.incremental_e = GCFUtil.convertCurrency(Incremental_E, 'USD', selectedCurrency);
            fData.incremental_u = GCFUtil.convertCurrency(Incremental_U, 'USD', selectedCurrency);
			fData.incremental_tiv = GCFUtil.convertCurrency(Incremental_TIV, 'USD', selectedCurrency);
			fData.incremental_tiv_e = GCFUtil.convertCurrency(Incremental_TIV_E, 'USD', selectedCurrency);
			
			// FYM	
            fData.fym_r = GCFUtil.convertCurrency(FYM_R, 'USD', selectedCurrency);
            fData.fym_u = GCFUtil.convertCurrency(FYM_U, 'USD', selectedCurrency);
            fData.fym_tiv = GCFUtil.convertCurrency(FYM_TIV, 'USD', selectedCurrency);
            fData.fym_tiv_e = GCFUtil.convertCurrency(FYM_TIV_E, 'USD', selectedCurrency);

			// BILLING PLAN
            fData.billingPlan_r = GCFUtil.convertCurrency(BillingPlan_R, 'USD', selectedCurrency);
            fData.billingPlan_e = GCFUtil.convertCurrency(BillingPlan_E, 'USD', selectedCurrency);
            fData.billingPlan_tiv = GCFUtil.convertCurrency(BillingPlan_TIV, 'USD', selectedCurrency);
           
            // forecastingDataList.add(fData);
            for(integer i=0; i< forecastingDataList.size(); i++){
            	ForecastingData fcd = forecastingDataList[i];
	    		String[] names = fcd.Name.split(' ');
	    		if(names[0] == GCFUtil.getMonthName(revenueMonth)){
	    			forecastingDataList[i] = fData;
	    		} 
		    }
        }
        
        
        String netSuiteDataQuery = 'SELECT Revenue_Type__c, SUM(Posting_Amount_USD__c) totalInUSD FROM GCF_NetSuite_Data__c WHERE Posting_Year_formula__c  = '+selectedYear + ' ' + (selectedRegion != 'All' ? ' AND Region__c = \''+selectedRegion+'\'' : '');
		if(selectedOfferingType != 'All'){
            netSuiteDataQuery = netSuiteDataQuery + ' AND Offering_Type_Formula__c = \''+selectedOfferingType+'\'';
        } else {
        	netSuiteDataQuery = netSuiteDataQuery + ' AND Offering_Type_Formula__c IN (\'PureEngage\', \'PureConnect\') '; 
        }
        
		for(Integer month = startIndex; month <= endIndex; month++){
			AggregateResult[] netSuiteResults = Database.query(netSuiteDataQuery + ' AND Posting_Month_formula__c = ' + month + ' GROUP BY Revenue_Type__c ');
			for(AggregateResult ar : netSuiteResults){
				for(ForecastingData fcd : forecastingDataList){
		    		String[] names = fcd.Name.split(' ');
		    		if(names[0] == GCFUtil.getMonthName(month)){
		    			Decimal totalInUSD = ar.get('totalInUSD') != NULL ? (Decimal)ar.get('totalInUSD') : 0.0;
		    			String revenueType = ar.get('Revenue_Type__c') != NULL ? (String)ar.get('Revenue_Type__c') : '';
		    			if(revenueType == 'Deferred Revenue')
		    				fcd.deferred = GCFUtil.convertCurrency(totalInUSD, 'USD', selectedCurrency);
		    			if(revenueType == 'Recognized Revenue')	 
		    				fcd.recognized = GCFUtil.convertCurrency(totalInUSD, 'USD', selectedCurrency);
		    		} 
		    	}
			}
		}
    }
    
    // Wrapper class
    public class ForecastingData {
        public String name { get; set; }
        public Integer year { get; set;}
		
		// INCREMENTAL
        public Decimal incremental_r { get; set; }
        public Decimal incremental_e { get; set; }
        public Decimal incremental_u { get; set; }
        public Decimal incremental_tr { 
        	get{
        		return this.incremental_r + this.incremental_e + this.incremental_u;
        	} 
        	set; 
        }
        public Decimal incremental_tiv_e { get; set; }
        public Decimal incremental_tiv { get; set; }

		// FYM
        public Decimal fym_r { get; set; }
        public Decimal fym_u { get; set; }
        public Decimal fym_tr { 
        	get{
        		return this.fym_r + this.fym_u;
        	} 
        	set; 
        }
        public Decimal fym_tiv_e { get; set; }
        public Decimal fym_tiv { get; set; }

		// BILLING PLAN
        public Decimal billingPlan_r { get; set; }
        public Decimal billingPlan_e { get; set; }
        public Decimal billingPlan_tiv { get; set; }

        // DEFERRED
        public Decimal deferred { get; set; }
        
        // RECOGNIZED
        public Decimal recognized { get; set; }

		// TOTAL BOOKING
		public Decimal tbf_ef { 
			get{
				return this.incremental_tiv_e + this.fym_tiv_e + this.billingPlan_tiv;
			} 
			set; 
		}
		public Decimal tbf_u { 
			get{
				return this.incremental_tiv + this.fym_tiv + this.billingPlan_tiv;
			} 
			set; 
		}

        // TOTAL REVENUE
		public Decimal trf_ef { 
			get{
				return this.incremental_r + this.incremental_e + this.fym_r + this.billingPlan_r + this.billingPlan_e + this.deferred + this.recognized;
			} 
			set; 
		}
		public Decimal trf_u { 
			get{
				return this.incremental_r + this.incremental_e + this.incremental_u + this.fym_r + this.fym_u + this.billingPlan_r + this.billingPlan_e + this.deferred + this.recognized;
			} 
			set; 
		}
		
        public ForecastingData(){
            this.name = '';
            this.year = 0;
            
            this.incremental_r = this.incremental_e = this.incremental_u = this.incremental_tiv = this.incremental_tiv_e = 0.0;
            this.fym_r = this.fym_u = this.fym_tiv = this.fym_tiv_e = 0.0;
            this.billingPlan_r = this.billingPlan_e = this.billingPlan_tiv = 0.0;
            this.tbf_ef = tbf_u = 0.0; 
            
            this.deferred = 0.0;
            this.recognized = 0.0;
        }
    }
    
    public List<List<ForecastingExportData>> revenueDataLists {
        get{
            List<ForecastingExportData> rData = getForecastingDetails();
			List<List<ForecastingExportData>> rdLists = new List<List<ForecastingExportData>>();
            Integer total = rData.size();
            Integer howManyLists = math.mod(total, 10000) > 0 ? (total/10000) + 1 : (total/10000);
             
            for(Integer i=0; i<howManyLists; i++){
                List<ForecastingExportData> rdList = new List<ForecastingExportData>();
                for(Integer j=0; j<10000; j++){
                    if(i*10000+j < total){
                  		rdList.add(rData[i*10000+j]); 
                    }
                }
                rdLists.add(rdList);
            }
        	return rdLists;
    	} 
        set;
    } 
    
    public List<ForecastingExportData> getForecastingDetails(){
    	// Reference_Opportunity__r.CloseDate, Reference_Opportunity__r.StageName, Reference_Opportunity__r.ForecastStatus__c, Reference_Opportunity__r.Account.Name,
    	// Reference_Quote__r.Total_Genesys_Care__c, Reference_Quote__r.Opportunity_Close_Date__c, Reference_Quote__r.Order_Numb_of_Maint_Months__c, Reference_Quote__r.Total_Maintenance_Amount_Due_Formula__c,
  
  		List<ForecastingExportData> forecastingDetails = new List<ForecastingExportData>();
  
  		String gcfRecordsQuery 	= 'SELECT id, Name, Reference_Opportunity__c, Reference_Opportunity__r.Name, ' 
  								+ 'Maintenance_Start_Date__c, Maintenance_End_Date__c, '
							 	+ 'Reference_Quote__r.End_User_ID__c, Reference_Quote__r.End_User_ID__r.Name,  Reference_Quote__r.End_User_ID__r.SAP_Account_Code__c,  Reference_Quote__r.End_User_ID__r.Subsidary__r.Name, '
							 	+ 'Reference_Quote__r.Sold_To_Name__c, Reference_Quote__r.Sold_To_Name__r.Name,  Reference_Quote__r.Sold_To_Name__r.SAP_Account_Code__c,  Reference_Quote__r.Sold_To_Name__r.Subsidary__r.Name, '
							 	+ 'Reference_Quote__c, Reference_Quote__r.Name, Reference_Quote__r.Maintenance_Start_Date__c, Reference_Quote__r.Maintenance_End_Date__c, '
							 	+ 'Reference_Order__c, Reference_Order__r.Name, Reference_Order__r.Status__c, '
							 	+ 'Reference_Service_Contract__c, Reference_Service_Contract__r.Name, '
							 	+ 'Region__c, Revenue_Type__c, Reference_Quote__r.Genesys_Care_Rep_Name__c, Posting_Date__c, Year__c, Month__c, Quarter__c, ' 
							 	+ 'BillingPlan_E__c, BillingPlan_R__c, BillingPlan_TIV__c, '
							 	+ 'FYM_R__c, FYM_TIV__c, FYM_U__c, '
							 	+ 'Incremental_E__c, Incremental_R__c, Incremental_TIV__c, Incremental_U__c, '
							 	+ 'Total_Booking_Forecast_E__c, Total_Booking_Forecast_U__c '
							 	+ 'FROM GCF_Data__c ';
  		
		gcfRecordsQuery = gcfRecordsQuery + ' WHERE Year__c = '+selectedYear;
        if(selectedQuarter != 'All'){
            gcfRecordsQuery = gcfRecordsQuery + ' AND Quarter__c = '+selectedQuarter;
        }
        if(selectedRegion != 'All'){
            gcfRecordsQuery = gcfRecordsQuery + ' AND Region__c = \''+selectedRegion+'\'';
        }		
        if(selectedOfferingType != 'All'){
            gcfRecordsQuery = gcfRecordsQuery + ' AND Offering_Type__c = \''+selectedOfferingType+'\'';
        } else {
        	gcfRecordsQuery = gcfRecordsQuery + ' AND Offering_Type__c IN (\'PureEngage\', \'PureConnect\') '; 
        }
        
        String gcfNetSuiteRecordsQuery 	= 'SELECT id, Name, Document_Number__c, End_User_GARN_Code__c, End_User_Name__c, End_User_Subsidiary_ID__c, Internal_Id__c, Item_Description__c, Item_Name__c, Maintenance_End_Date__c, Maintenance_Start_Date__c, '
        								+ 'Order_Number__c, PO_Number__c, Posting_Amount__c, Posting_Amount_EUR__c, Posting_Amount_USD__c, Posting_Date__c, Posting_Month_Formula__c, Posting_Year_Formula__c, Quote_Number__c, Region__c, Revenue_Type__c, '
        								+ 'Sold_To_GARN_Code__c, Sold_To_Name__c, Sold_To_Subsidiary_ID__c, SO_Number__c, Status__c, Type__c '
        								+ 'FROM GCF_NetSuite_Data__c ';
        								
		gcfNetSuiteRecordsQuery = gcfNetSuiteRecordsQuery + ' WHERE Posting_Year_Formula__c = '+selectedYear;
        if(selectedQuarter != 'All'){
            gcfNetSuiteRecordsQuery = gcfNetSuiteRecordsQuery + ' AND Posting_Quarter_Formula__c = '+selectedQuarter;
        }
        if(selectedRegion != 'All'){
            gcfNetSuiteRecordsQuery = gcfNetSuiteRecordsQuery + ' AND Region__c = \''+selectedRegion+'\'';
        }
        
        if(selectedOfferingType != 'All'){
            gcfNetSuiteRecordsQuery = gcfNetSuiteRecordsQuery + ' AND Offering_Type_Formula__c = \''+selectedOfferingType+'\'';
        } else {
        	gcfNetSuiteRecordsQuery = gcfNetSuiteRecordsQuery + ' AND Offering_Type_Formula__c IN (\'PureEngage\', \'PureConnect\') '; 
        }
        
        for(GCF_Data__c record : Database.Query(gcfRecordsQuery)){
        	forecastingDetails.add(new ForecastingExportData(record, selectedCurrency));	
        }
        for(GCF_NetSuite_Data__c record : Database.Query(gcfNetSuiteRecordsQuery)){
        	forecastingDetails.add(new ForecastingExportData(record, selectedCurrency));	
        }
    	return forecastingDetails;
    }
    
    // Wrapper class
    public class ForecastingExportData {
    	public String opportunityId { get; set; }
    	public String opportunityName { get; set; }
    	  		
    	public String soldToId { get; set; }
    	public String soldToName { get; set; }
    	public String soldToGARNCode { get; set; }
    	public String soldToSubsidaryCode { get; set; }

    	public String endUserId { get; set; }
    	public String endUserName { get; set; }
    	public String endUserGARNCode { get; set; }
    	public String endUserSubsidaryCode { get; set; }

    	public String region { get; set; }
    	public String revenueType { get; set; }
		public String genesysCareSpecialist { get; set; }
		public Date postingDate { get; set; }
		public Integer postingYear { get; set; }
		public Integer postingMonth { get; set; }
		public Integer postingQuarter { get; set; }
		
		public String currencyCode { get; set; }
		
		public Decimal incrementalE { get; set; }
		public Decimal incrementalR { get; set; }
		public Decimal incrementalU { get; set; }
		public Decimal incrementalTIV { get; set; }

		public Decimal FYMR { get; set; }
		public Decimal FYMU { get; set; }
		public Decimal FYMTIV { get; set; }
		
		public Decimal billingPlanE { get; set; } 
		public Decimal billingPlanR { get; set; }
		public Decimal billingPlanTIV { get; set; }

		public Decimal deferred { get; set; }
		public Decimal recognized { get; set; }
		
		public Decimal bookingForecastE { get; set; } 
		public Decimal bookingForecastU { get; set; }
		
		public String quoteId { get; set; }
		public String quoteName { get; set; }
		
		public String orderId { get; set; }
		public String orderName { get; set; }

		public String serviceContractId { get; set; }
		public String serviceContractName { get; set; }
		
		public Date maintenanceStartDate { get; set; }
		public Date maintenanceEndDate { get; set; }
		
		public String orderStatus {get; set;}
		public ForecastingExportData(GCF_Data__c record, String selectedCurrency){
			opportunityId = record.Reference_Opportunity__c;
			opportunityName = record.Reference_Opportunity__r.Name;

			endUserId = record.Reference_Quote__r.End_User_ID__c;
			endUserName = record.Reference_Quote__r.End_User_ID__r.Name;
			endUserGARNCode = record.Reference_Quote__r.End_User_ID__r.SAP_Account_Code__c;
			endUserSubsidaryCode = record.Reference_Quote__r.End_User_ID__r.Subsidary__r.Name;
			soldToId = record.Reference_Quote__r.Sold_To_Name__c;
			soldToName = record.Reference_Quote__r.Sold_To_Name__r.Name;
			soldToGARNCode = record.Reference_Quote__r.Sold_To_Name__r.SAP_Account_Code__c;
			soldToSubsidaryCode = record.Reference_Quote__r.Sold_To_Name__r.Subsidary__r.Name;
			
			region = record.Region__c;
			revenueType = record.Revenue_Type__c;
			genesysCareSpecialist = record.Reference_Quote__r.Genesys_Care_Rep_Name__c;
			postingDate = record.Posting_Date__c;
			postingYear = record.Year__c.intValue();
			postingMonth = record.Month__c.intValue();
			postingQuarter = record.Quarter__c.intValue();
			currencyCode = selectedCurrency;
			
			maintenanceStartDate = record.Reference_Quote__r.Maintenance_Start_Date__c;
			maintenanceEndDate = record.Reference_Quote__r.Maintenance_End_Date__c;
			
			if(record.Revenue_Type__c == 'Incremental Revenue'){
				// Incremental_E__c, Incremental_R__c, Incremental_U__c,  Incremental_TIV__c,
				incrementalE = GCFUtil.convertCurrency(record.Incremental_E__c, 'USD', selectedCurrency);
				incrementalR = GCFUtil.convertCurrency(record.Incremental_R__c, 'USD', selectedCurrency);
				incrementalU = GCFUtil.convertCurrency(record.Incremental_U__c, 'USD', selectedCurrency);
				incrementalTIV = GCFUtil.convertCurrency(record.Incremental_TIV__c, 'USD', selectedCurrency);
			}
			
			if(record.Revenue_Type__c == 'First Year Maintenance'){
				// FYM_R__c, FYM_U__c,  FYM_TIV__c,
				FYMR = GCFUtil.convertCurrency(record.FYM_R__c, 'USD', selectedCurrency);
				FYMU = GCFUtil.convertCurrency(record.FYM_U__c, 'USD', selectedCurrency);
				FYMTIV = GCFUtil.convertCurrency(record.FYM_TIV__c, 'USD', selectedCurrency);
			}

			if(record.Revenue_Type__c == 'Billing Plan'){
				// BillingPlan_E__c, BillingPlan_R__c, BillingPlan_TIV__c,
				billingPlanE = GCFUtil.convertCurrency(record.BillingPlan_E__c, 'USD', selectedCurrency);
				billingPlanR = GCFUtil.convertCurrency(record.BillingPlan_R__c, 'USD', selectedCurrency);
				billingPlanTIV = GCFUtil.convertCurrency(record.BillingPlan_TIV__c, 'USD', selectedCurrency);
			}
			
			if(record.Revenue_Type__c == 'Total Booking Forecast'){
				// Total_Booking_Forecast_E__c, Total_Booking_Forecast_U__c,
				bookingForecastE = GCFUtil.convertCurrency(record.Total_Booking_Forecast_E__c, 'USD', selectedCurrency);
				bookingForecastU = GCFUtil.convertCurrency(record.Total_Booking_Forecast_U__c, 'USD', selectedCurrency);
			}
			
			quoteId = record.Reference_Quote__c;
			quoteName = record.Reference_Quote__r.Name;
			
			orderId = record.Reference_Order__c;
			orderName = record.Reference_Order__r.Name;
			orderStatus = record.Reference_Order__r.Status__c;
			
			serviceContractId = record.Reference_Service_Contract__c;
			serviceContractName = record.Reference_Service_Contract__r.Name;

			maintenanceStartDate = record.Maintenance_Start_Date__c;
			maintenanceEndDate = record.Maintenance_End_Date__c;
		}
		
		public ForecastingExportData(GCF_NetSuite_Data__c record, String selectedCurrency){
			
			endUserName = record.End_User_Name__c;
			endUserGARNCode = record.End_User_GARN_Code__c;
			endUserSubsidaryCode = record.End_User_Subsidiary_ID__c;

			soldToName = record.Sold_To_Name__c;
			soldToGARNCode = record.Sold_To_GARN_Code__c;
			soldToSubsidaryCode = record.Sold_To_Subsidiary_ID__c;
			
			region = record.Region__c;
			revenueType = record.Revenue_Type__c;
			
			postingDate = record.Posting_Date__c;
			postingYear = record.Posting_Date__c.Year();
			postingMonth = record.Posting_Date__c.Month();
			postingQuarter = GCFUtil.getQuarter(record.Posting_Date__c.Month());
			currencyCode = selectedCurrency;
			
			maintenanceStartDate = record.Maintenance_Start_Date__c;
			maintenanceEndDate = record.Maintenance_End_Date__c;

			if(record.Revenue_Type__c == 'Deferred Revenue'){
				deferred = GCFUtil.convertCurrency(record.Posting_Amount_USD__c, 'USD', selectedCurrency);
			}
			if(record.Revenue_Type__c == 'Recognized Revenue'){
				recognized = GCFUtil.convertCurrency(record.Posting_Amount_USD__c, 'USD', selectedCurrency);
			}
			
			quoteName = record.Quote_Number__c;
			orderName = record.Order_Number__c;
			
		}
    }
}