public class PartnerKPIHeadersExportController {
	public String selectedPeriod {get; set;} 
    public List<Partner_KPI_Header_Stage__c> kpiHeaders {get; set;}
    public PartnerKPIHeadersExportController(){
        selectedPeriod = ApexPages.currentPage().getParameters().get('sp');
        String selectedSoldToFilter = ApexPages.currentPage().getParameters().get('stfilter');
        String filterStr = 'WHERE Period__c = :selectedPeriod';
        if(selectedSoldToFilter != NULL && selectedSoldToFilter != '-- ALL --'){
            filterStr += ' AND Account__c = \'' + selectedSoldToFilter + '\'';
        }
        
        String query = 'SELECT id, Name, Unique_Key__c, Account__c, Account_Name__c, Partner_Name__c, Region__c, Period__c, Period_From__c, Period_To__c, Quarter__c, ' 
                     + 'Problem_Description__c, Supporting_Information__c, Closure_Assessment__c, Closure_Assessment_YTD__c,  Quality_Assessment__c, Quality_Assessment_YTD__c,'
                     + 'Training_Assessment__c, Training_Assessment_YTD__c, Cases_Closed_by_Default__c, Cases_Closed_by_Default_YTD__c, Total_KPI_Score__c, Total_YTD_KPI_Score__c,' 
                     + 'Closed_By_Default__c, YTD_Closed_By_Default__c FROM Partner_KPI_Header_Stage__c ' + filterStr;
        System.debug('query = ' + query);
        kpiHeaders  = Database.query(query);
        
    }
}