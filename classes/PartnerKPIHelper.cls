//Naresh Kumar
public class PartnerKPIHelper {
	public static List<Partner_KPI_Periods__c> kpiPeriods;
    static {
        kpiPeriods = [SELECT Id, Name, Period__c, Start_Date__c, End_Date__c, Year__c, Quarter__c,
                                                         Active__c, Current_Quarter__c, Date_Opened__c, Order__c  
                                                         FROM Partner_KPI_Periods__c 
                                                         WHERE Active__c = true 
                                                         ORDER BY Year__c DESC, Quarter__c DESC];   
    }
    
	public static List<SelectOption> getPopulatedPeriods(){
		List<SelectOption> kpiPeriodOptions = new List<SelectOption>();
        /*
		for(Partner_KPI_Periods__c eachPeriod : Partner_KPI_Periods__c.getAll().values()){         
        	if(eachPeriod.Active__c){
            	kpiPeriodOptions.add(new SelectOption(eachPeriod.Name , eachPeriod.Name)); 
        	}
   		}*/
        for(Partner_KPI_Periods__c eachPeriod : kpiPeriods){         
            kpiPeriodOptions.add(new SelectOption(eachPeriod.Name , eachPeriod.Name)); 
   		}
   		return kpiPeriodOptions;
	}
	
	public static String getCurrentQuarter(){
        /*
		for(Partner_KPI_Periods__c eachPeriod : Partner_KPI_Periods__c.getAll().values()){         
        	if(eachPeriod.Current_Quarter__c){
            	return eachPeriod.Name; 
        	}
   		}
   		return null;
		*/
        return kpiPeriods[0].Name;
	}
    
    public static List<Partner_KPI_Periods__c> getAndSortPopulatedPeriods(){
        
        /*
		List<Partner_KPI_Periods__c> activeKPIPeriods = new List<Partner_KPI_Periods__c>();
        activeKPIPeriods = [select Id,Active__c,Current_Quarter__c, Date_Opened__c, Order__c, Period__c from Partner_KPI_Periods__c where Active__c = true order by Order__c];   
		System.debug('activeKPIPeriods---'+activeKPIPeriods);
        return activeKPIPeriods;
		*/
        return kpiPeriods;
	}

    public static void insertKPIPeriodCS(String period){
 		Integer periodYear;
        Integer periodQuarter;
        Date periodStartDate;
        Date periodEndDate;
           
		String periodMonths = period.substring(0,period.indexOf(' '));
        Integer year = Integer.valueOf(period.substring(period.indexOf(' ')+1));

        if(periodMonths == 'Sep/Oct/Nov'){
            periodStartDate = Date.newInstance(year, 9, 1);
            periodEndDate = Date.newInstance(year, 11, 30);
            periodYear = year + 1;
            periodQuarter = 1;
        }            
        if(periodMonths == 'Dec/Jan/Feb'){
            periodStartDate = Date.newInstance(year-1, 12, 1);
            if(Date.isLeapYear(year))
                periodEndDate = Date.newInstance(year, 2, 28);
			else
				periodEndDate = Date.newInstance(year, 2, 29);
			periodYear = year;
            periodQuarter = 2;
        }            
        if(periodMonths == 'Mar/Apr/May'){
            periodStartDate = Date.newInstance(year, 3, 1);
            periodEndDate = Date.newInstance(year, 5, 31);
            periodYear = year;
            periodQuarter = 3;
        }            
        if(periodMonths == 'Jun/Jul/Aug'){
            periodStartDate = Date.newInstance(year, 6, 1);
            periodEndDate = Date.newInstance(year, 8, 31);
            periodYear = year;
            periodQuarter = 4;
        }  
        
        Partner_KPI_Periods__c existingKPIPeriod = Partner_KPI_Periods__c.getInstance(period); 
        if(existingKPIPeriod == NULL){
            Partner_KPI_Periods__c kpiPeriod = new Partner_KPI_Periods__c(Name = period, 
                                                                          Year__c = periodYear, 
                                                                          Quarter__c = periodQuarter, 
                                                                          Start_Date__c = periodStartDate, 
                                                                          End_Date__c = periodEndDate, 
                                                                          Active__c = true);
            insert kpiPeriod;
        }

    }    
    
}