@isTest
private class PartnerKPIHelperTest {
	static testmethod void testPartnerKPIHelper() {
		List<Partner_KPI_Periods__c> kpiPeriodsData = new List<Partner_KPI_Periods__c>();
        kpiPeriodsData.add(new Partner_KPI_Periods__c(Name = 'Sep/Oct/Nov 2015', Year__c = 2016, Quarter__c = 1, Start_Date__c = Date.parse('09/01/2015'), End_Date__c = Date.parse('11/30/2015'), Active__c = true));
        kpiPeriodsData.add(new Partner_KPI_Periods__c(Name = 'Dec/Jan/Feb 2016', Year__c = 2016, Quarter__c = 2, Start_Date__c = Date.parse('12/01/2015'), End_Date__c = Date.parse('02/29/2016'), Active__c = true));
        kpiPeriodsData.add(new Partner_KPI_Periods__c(Name = 'Mar/Apr/May 2016', Year__c = 2016, Quarter__c = 3, Start_Date__c = Date.parse('03/01/2016'), End_Date__c = Date.parse('05/31/2016'), Active__c = true));
        kpiPeriodsData.add(new Partner_KPI_Periods__c(Name = 'Jun/Jul/Aug 2016', Year__c = 2016, Quarter__c = 4, Start_Date__c = Date.parse('06/01/2016'), End_Date__c = Date.parse('08/31/2016'), Active__c = true));
        
        insert kpiPeriodsData;
        
        List<Partner_KPI_Periods__c> kpiPeriods = PartnerKPIHelper.getAndSortPopulatedPeriods();
		String  currentQuarter = PartnerKPIHelper.getCurrentQuarter();
        List<SelectOption> activePeriods =  PartnerKPIHelper.getPopulatedPeriods();
    }
    
    
    static testMethod void testKPICustomSettings(){
        PartnerKPIHelper.insertKPIPeriodCS('Sep/Oct/Nov 2015');
        PartnerKPIHelper.insertKPIPeriodCS('Dec/Jan/Feb 2016');
        PartnerKPIHelper.insertKPIPeriodCS('Dec/Jan/Feb 2015');
        PartnerKPIHelper.insertKPIPeriodCS('Mar/Apr/May 2016');
        PartnerKPIHelper.insertKPIPeriodCS('Jun/Jul/Aug 2016');
    }
}