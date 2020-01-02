public class PartnerKPIManagementUtil {
    public static String buildWhereCondition(){
        String supportCaseRecordTypeId = getCaseSupportRecordTypeId();
        String whereCondition = ' (RecordTypeId = \''+supportCaseRecordTypeId+'\''
                                + '  AND Sold_To_Account__r.Type = \'Partner\' '
                                + '  AND Sold_To_Account__r.Status__c = \'Active\' '
                                + '  AND Status = \'Closed\' '
                                + '  AND Assignment_Status__c = \'Closure Activities Completed\' '
                                + '  AND Deployment_Type__c != \'Cloud\' '
                                + '  AND Origin != \'Alarm\' '
                                + '  AND Product_Support_Group__c NOT IN (\'Custom Applications\',\'CC Tools & Infrastructure\') '
                                + '  AND Product_Line__c NOT IN :supportProductsToExclude '
                                + '  AND Sold_To_Account__r.Name != \'Genesys Internal\' ' 
                                + '  AND (NOT Contact.Account.Name like \'%Genesys%\') '
                                + '  ) '
                                + '  AND ' 
                                + '  ( '
                                + '    ( '
                                + '        Closure_Reason_Code__c NOT IN (\'Customer requested to Close\', \'Closed by Customer - Cancelled\', \'Closed by Customer - Resolved\') '
                                + '        AND Owner.Name = \'Unassigned\' '
                                + '    ) '
                                + '    OR Owner.Name != \'Unassigned\' '
                                + '  ) ';
        return whereCondition;
    }
    public static String buildWhereConditionForGivenPeriod(String selectedPeriod){
        String periodStart;
    	String periodEnd;

    	DateTime periodStartDate;
    	DateTime periodEndDate;
        
        String periodMonths = selectedPeriod.substring(0,selectedPeriod.indexOf(' '));
		Integer year = Integer.valueOf(selectedPeriod.substring(selectedPeriod.indexOf(' ')+1));
        if(periodMonths == 'Sep/Oct/Nov'){
            periodStart = year+'-09-01'+'T00:00:01Z';
            periodEnd = year+'-11-30'+'T23:59:59Z';
            periodStartDate = DateTime.newInstanceGmt(year, 9, 1, 0, 0, 1);
            periodEndDate = DateTime.newInstanceGmt(year, 11, 30, 23, 59, 59);
        }            
        if(periodMonths == 'Dec/Jan/Feb'){
            periodStart = (year-1)+'-12-01'+'T00:00:01Z';
            periodEnd =  Date.isLeapYear(year) ? year+'-02-29'+'T23:59:59Z' : year+'-02-28'+'T23:59:59Z';
            periodStartDate = DateTime.newInstanceGmt(year-1, 12, 1, 0, 0, 1);
            if(Date.isLeapYear(year))
                periodEndDate = DateTime.newInstanceGmt(year, 2, 28, 23, 59, 59);
            else
                periodEndDate = DateTime.newInstanceGmt(year, 2, 29, 23, 59, 59);
            
        }            
        if(periodMonths == 'Mar/Apr/May'){
            periodStart = year+'-03-01'+'T00:00:01Z';
            periodEnd = year+'-05-31'+'T23:59:59Z';
            periodStartDate = DateTime.newInstanceGmt(year, 3, 1, 0, 0, 1);
            periodEndDate = DateTime.newInstanceGmt(year, 5, 31, 23, 59, 59);
        }            
        if(periodMonths == 'Jun/Jul/Aug'){
            periodStart = year+'-06-01'+'T00:00:01Z';
            periodEnd = year+'-08-31'+'T23:59:59Z';
            periodStartDate = DateTime.newInstanceGmt(year, 6, 1, 0, 0, 1);
            periodEndDate = DateTime.newInstanceGmt(year, 8, 31, 23, 59, 59);
        }    
        String whereCondition = buildWhereCondition() + ' AND (ClosedDate >= '+periodStart+' AND  ClosedDate <= '+periodEnd+') ';                     
        return whereCondition;
    }
    
    public static void compileKPIInfoForAllPartnersThroughBatch(){
        String supportCaseRecordTypeId = getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = getSupportProductsToExclude();
        Integer currentYear = Date.today().year();
        String periodStart = (currentYear-1)+'-01-01'+'T00:00:01Z';
        String periodEnd = currentYear+'-12-31'+'T23:59:59Z';
        AggregateResult[] groupedResults = [SELECT Sold_To_Account__c, Count(Id) 
                                            FROM CASE WHERE RecordTypeId = :supportCaseRecordTypeId
                                            AND Sold_To_Account__r.Type = 'Partner' 
                                            AND Sold_To_Account__r.Status__c = 'Active'
                                            AND (ClosedDate >= 2016-01-01T00:00:01Z AND  ClosedDate <= 2017-01-31T00:00:01Z) 
                                            GROUP BY Sold_To_Account__c];
        
        Set<String> partnerAccountIds = new Set<String>();
		for (AggregateResult ar : groupedResults)  {
			partnerAccountIds.add((String)ar.get('Sold_To_Account__c'));
		}
        Database.executeBatch(new PartnerKPIYTDCalculationsBatch(partnerAccountIds, 'All'), 1);
    }
    public static void compileKPIInfoForPartnerThroughBatch(String partnerAccountId, String period){
        Set<String> partnerAccountIds = new Set<String>{partnerAccountId};
        Database.executeBatch(new PartnerKPIYTDCalculationsBatch(partnerAccountIds, period), 1);
    }
    
    public static void compileKPIInfoForPartner(String partnerAccountId){
        String supportCaseRecordTypeId = getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = getSupportProductsToExclude();
        
        AggregateResult[] results = [SELECT min(ClosedDate) minDate, max(ClosedDate) maxDate 
                               FROM CASE WHERE 
                               (
                                   RecordTypeId = :supportCaseRecordTypeId  
                                   AND Status = 'Closed' 
                                   AND Assignment_Status__c = 'Closure Activities Completed' 
                                   AND Deployment_Type__c != 'Cloud' 
                                   AND Origin != 'Alarm' 
                                   AND Product_Support_Group__c NOT IN ('Custom Applications','CC Tools & Infrastructure') 
                                   AND Product_Line__c NOT IN :supportProductsToExclude
                                   AND Sold_To_Account__r.Name != 'Genesys Internal' 
                                   AND (NOT Contact.Account.Name like '%Genesys%')
                               )
                                AND 
                                ( 
                                    (
                                        Closure_Reason_Code__c NOT IN ('Customer requested to Close', 'Closed by Customer - Cancelled', 'Closed by Customer - Resolved') 
                                        AND Owner.Name = 'Unassigned'
                                    ) 
                                    OR Owner.Name != 'Unassigned'
                                )
                                AND Sold_To_Account__c = :partnerAccountId];
        
        DateTime minCreatedDate = (DateTime)results[0].get('minDate');
        DateTime maxCreatedDate = (DateTime)results[0].get('maxDate');
        
        List<String> periods = new List<String>();
        	
        // 2016 ==> Sep 01, 2015 to Aug 31, 2016 
        for(integer y = minCreatedDate.year(); y <= maxCreatedDate.year(); y++){
            periods.add('Sep/Oct/Nov ' + (y-1));
            periods.add('Dec/Jan/Feb ' + y);
            periods.add('Mar/Apr/May ' + y);
            periods.add('Jun/Jul/Aug ' + y);
        }
        
        for(String s : periods){
            System.debug('PERIOD = ' + s);
            compileKPIInfoForPartnerPerPeriod(partnerAccountId,s);
        }
    }
    
    public static void compileKPIInfoForPartnerPerPeriod(String partnerAccountId, String period){
       	Set<Integer> monthsInCurrentPeriod;
		DateTime yearStartDate;
        DateTime periodStartDate; 
        DateTime periodEndDate;        
        Integer periodYear;
        Integer periodQuarter;
        
        String periodToPublish = period;
        if(periodToPublish != ''){
            String periodMonths = periodToPublish.substring(0,periodToPublish.indexOf(' '));
            Integer year = Integer.valueOf(periodToPublish.substring(periodToPublish.indexOf(' ')+1));
            
            if(periodMonths == 'Sep/Oct/Nov'){
                periodQuarter = 1;
                periodStartDate = DateTime.newInstanceGmt(year, 9, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstanceGmt(year, 11, 30, 23, 59, 59);
                periodYear = year + 1;
                monthsInCurrentPeriod = new Set<Integer>{9,10,11};
            }            
            if(periodMonths == 'Dec/Jan/Feb'){
                periodQuarter = 2;
                periodStartDate = DateTime.newInstanceGmt(year-1, 12, 1, 0, 0, 1);
                if(Date.isLeapYear(year))
                	periodEndDate = DateTime.newInstanceGmt(year, 2, 28, 23, 59, 59);
				else
					periodEndDate = DateTime.newInstanceGmt(year, 2, 29, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{12,1,2};
            }            
            if(periodMonths == 'Mar/Apr/May'){
                periodQuarter = 3;
                periodStartDate = DateTime.newInstanceGmt(year, 3, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstanceGmt(year, 5, 31, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{3,4,5};
            }            
            if(periodMonths == 'Jun/Jul/Aug'){
                periodQuarter = 4;
                periodStartDate = DateTime.newInstanceGmt(year, 6, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstanceGmt(year, 8, 31, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{6,7,8};
            }  
            yearStartDate = DateTime.newInstance(periodYear-1, 9, 1, 0, 0, 1);
        }
        
        Account a = [SELECT id, Name, Region__c FROM Account WHERE Id = :partnerAccountId];
        
        String supportCaseRecordTypeId = getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = getSupportProductsToExclude();
        
        List<Case> casesYTD = [SELECT Id, CaseNumber, Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.Region__c, 
                               End_User_Account__c, End_User_Account__r.Name, ContactId, Contact.ViewCentral_ID__c, Contact_Name__c, 
                               Contact.Email, Support_Product__c, Support_Product__r.Name, Priority, Subject,  CreatedDate, ClosedDate, 
                               Closure_Category__c, Closure_Reason_Code__c, Business_Impact_Product__c, Problem_Description_clear_and_detail__c, 
                               Supporting_Info_Provided__c, Missing_Supporting_Information__c, Should_have_been_solved_using_KB__c, 
                               Publicly_Available_Documents__c, Sub_Status__c, GU_Certified_Contact__c, Owner.Name FROM Case
                               WHERE 
                               (
                                   RecordTypeId = :supportCaseRecordTypeId  
                                   AND Status = 'Closed' 
                                   AND Assignment_Status__c = 'Closure Activities Completed' 
                                   AND Deployment_Type__c != 'Cloud' 
                                   AND Origin != 'Alarm' 
                                   AND Product_Support_Group__c NOT IN ('Custom Applications','CC Tools & Infrastructure') 
                                   AND Product_Line__c NOT IN :supportProductsToExclude
                                   AND Sold_To_Account__r.Name != 'Genesys Internal' 
                                   AND (NOT Contact.Account.Name like '%Genesys%')
                               ) AND ( (
                                        Closure_Reason_Code__c NOT IN ('Customer requested to Close', 'Closed by Customer - Cancelled', 'Closed by Customer - Resolved') 
                                        AND Owner.Name = 'Unassigned'
                                    ) OR Owner.Name != 'Unassigned'
                                ) AND Sold_To_Account__c = :a.Id AND (ClosedDate >= :yearStartDate AND  ClosedDate <= :periodEndDate)
                              ORDER BY CreatedDate]; 
        
        	System.debug('Total Cases = ' + casesYTD.size());    
        
            Integer totalCasesYTD = casesYTD.size();
            Integer totalCasesInPeriod = 0;

            // KPI1 Calculations
			Decimal problemDescriptionWeighted = 0;
			Decimal problemDescriptionWeightedYTD = 0;
        	Decimal supportingInfoWeighted = 0;
			Decimal supportingInfoWeightedYTD = 0;
            
        	Decimal qualityAssessment = 0;
        	Decimal qualityAssessmentYTD = 0;
        	Decimal closureAssessment = 0;
        	Decimal closureAssessmentYTD = 0;
        	Decimal trainingAssessment = 0;
        	Decimal trainingAssessmentYTD = 0;
        	Decimal casesClosedByDefault = 0;
        	Decimal casesClosedByDefaultYTD = 0;
        	
            Decimal kpiScore = 0.0;
            Decimal kpiScoreYTD = 0.0;
        
			// Cases Closed by Default Calculations
            Integer autoFollowUpCasesInPeriod = 0;
            Integer autoFollowUpCasesInYear = 0;
            
            // Objects to hold the data that needs to be published for KPI1
            Partner_KPI_Header_Stage__c partnerKPIHeaderStage;
        	Boolean partnerKPI1DetailsExists = false;
        	Boolean casesClosedByDefaultExists = false;
        
            /* *************************************************************************************************************************
             * Logic for Cases Closed by Default:
        	 * - If the Case Sub Status = “Auto Follow-Up” then the case is closed by default. 
			 * - Per Period and YTD results are calculated by dividing SUM(Num Cases Closed by Auto Follow-Up)/SUM(Total Num Cases)
             * *************************************************************************************************************************
             */
            for(Case c: casesYTD){
                // KPI1 Calculations for current case
                Integer problemDescriptionWeightedPerCase = c.Problem_Description_clear_and_detail__c == 'Yes' ? 15 : 0;
                //Integer supportingInfoWeightedPerCase = c.Supporting_Info_Provided__c == 'Yes' ? 15 : 0;
                Integer supportingInfoWeightedPerCase = c.Supporting_Info_Provided__c == 'No' ? 0 : 15;
                Integer closureAssessmentPerCase = c.Should_have_been_solved_using_KB__c == 'No' ? 30 : 0;
				Integer trainingAssessmentPerCase = c.GU_Certified_Contact__c == 'Yes' ? 20 : 0;
                //Integer casesClosedByDefaultPerCase = c.Sub_Status__c == 'Auto Follow-Up' ? 20 : 0;
                Integer casesClosedByDefaultPerCase = c.Sub_Status__c == 'Auto Follow-Up' ? 0 : 20;
                Decimal kpiScorePerCase = ((Decimal)(problemDescriptionWeightedPerCase 
                                                     + supportingInfoWeightedPerCase 
                                                     + closureAssessmentPerCase 
                                                     + trainingAssessmentPerCase
                                                     + casesClosedByDefaultPerCase
                                                    )) / 100;
                
                // KPI1 Calculations for the whole year
                problemDescriptionWeightedYTD = problemDescriptionWeightedYTD + problemDescriptionWeightedPerCase;
                supportingInfoWeightedYTD = supportingInfoWeightedYTD + supportingInfoWeightedPerCase;
                closureAssessmentYTD = closureAssessmentYTD + closureAssessmentPerCase;
                trainingAssessmentYTD = trainingAssessmentYTD + trainingAssessmentPerCase;
                casesClosedByDefaultYTD = casesClosedByDefaultYTD + casesClosedByDefaultPerCase;
                kpiScoreYTD = kpiScoreYTD + kpiScorePerCase; 
				System.debug('trainingAssessmentPerCase ['+c.Id+'] = ' + trainingAssessmentPerCase);
				if(c.Sub_Status__c == 'Auto Follow-Up')
                    autoFollowUpCasesInYear++;
                
                // Cases is closed in the selected period 
                if(monthsInCurrentPeriod.contains(c.ClosedDate.MONTH())){
                     
					totalCasesInPeriod++;
                    
                    // KPI1 Calculations for the selected period
					problemDescriptionWeighted = problemDescriptionWeighted + problemDescriptionWeightedPerCase;
					supportingInfoWeighted = supportingInfoWeighted + supportingInfoWeightedPerCase;
					closureAssessment = closureAssessment + closureAssessmentPerCase;
                    trainingAssessment = trainingAssessment + trainingAssessmentPerCase;
                    casesClosedByDefault = casesClosedByDefault + casesClosedByDefaultPerCase;
                    kpiScore = kpiScore + kpiScorePerCase; 
                    
                    // Check case whether it is closed by default or not 
                    if(c.Sub_Status__c == 'Auto Follow-Up')
                    	autoFollowUpCasesInPeriod++;
                    
                    // Partner KPI1 Child details
					partnerKPI1DetailsExists = true;                    
                    // Cases closed by default details
					casesClosedByDefaultExists = true;                    
                } // End of if condition to check whether a case is in Current Period or not 
            } // End of Cases for loop
        	
        	System.debug(' Training_Assessment__c = ' + trainingAssessment);
        	System.debug(' Training_Assessment_YTD__c = ' + trainingAssessmentYTD);
        
            // Handle Database operations (clean up & create) for Partner KPI1 Data ...
            if(partnerKPI1DetailsExists){
                partnerKPIHeaderStage = new Partner_KPI_Header_Stage__c(Account__c = a.Id,
                                                                    Account_Name__c = a.Name,
                                                                    Period__c = periodToPublish,
                                                                    Period_From__c = date.newinstance(periodStartDate.year(), periodStartDate.month(), periodStartDate.day()),
                                                                    Period_To__c = date.newinstance(periodEndDate.year(), periodEndDate.month(), periodEndDate.day()),
                                                                    Quarter__c = periodQuarter,
                                                                    Year__c = periodYear,
                                                                    Region__c = a.Region__c,
                                                                    Problem_Description__c =  (problemDescriptionWeighted/ totalCasesInPeriod).setScale(2),
                                                                    Supporting_Information__c = (supportingInfoWeighted/ totalCasesInPeriod).setScale(2),
                                                                    Quality_Assessment__c = (problemDescriptionWeighted + supportingInfoWeighted) / totalCasesInPeriod,
                                                                    Quality_Assessment_YTD__c = ((problemDescriptionWeightedYTD + supportingInfoWeightedYTD) / totalCasesYTD).setScale(2),
                                                                    Closure_Assessment__c = (closureAssessment/ totalCasesInPeriod).setScale(2),
                                                                    Closure_Assessment_YTD__c = (closureAssessmentYTD/ totalCasesYTD).setScale(2),
                                                                    Training_Assessment__c = (trainingAssessment/ totalCasesInPeriod).setScale(2),
                                                                    Training_Assessment_YTD__c = (trainingAssessmentYTD/ totalCasesYTD).setScale(2),
                                                                    Cases_Closed_by_Default__c = (casesClosedByDefault/ totalCasesInPeriod).setScale(2),
                                                                    Cases_Closed_by_Default_YTD__c = (casesClosedByDefaultYTD/ totalCasesYTD).setScale(2),
                                                                    Total_KPI_Score__c = ((kpiScore * 100)/ totalCasesInPeriod).setScale(2),
                                                                    Total_YTD_KPI_Score__c = ((kpiScoreYTD * 100)/ totalCasesYTD).setScale(2),
                                                                    Closed_By_Default__c = (autoFollowUpCasesInPeriod*100)/totalCasesInPeriod,
                                                                    YTD_Closed_By_Default__c = (autoFollowUpCasesInYear*100)/totalCasesYTD,
                                                                    Unique_Key__c = a.id + '-' + periodToPublish 
																);
                
                Database.upsert(partnerKPIHeaderStage, Partner_KPI_Header_Stage__c.Unique_Key__c);
            }
    }
    
    public static String getCaseSupportRecordTypeId(){
        //012U0000000M2BfIAK
        return Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId();
    }

    public static List<String> getSupportProductsToExclude(){
        // a12U0000004xBQNIA2, a12U0000000RKNcIAO
        List<String> supportProducts = new List<String>();
        for(Support_Product__c sp : [SELECT id from Support_Product__c WHERE Name in ('Custom PS Applications', 'Cloud')]){
    		supportProducts.add(sp.id);
		}
        return supportProducts;
    } 
    
    public static String getCurrentPeriod(){
        String period = '';
        Integer currentMonth = Date.today().Month();
        Integer currentYear = Date.today().Year();
        if(currentMonth == 12 || currentMonth ==  1 || currentMonth == 2){
            period = 'Dec/Jan/Feb';
            if(currentMonth == 12) 
                period = period + ' ' + (currentYear + 1);
			else 
                period = period + ' ' + currentYear;
        } else if(currentMonth == 3 || currentMonth ==  4 || currentMonth == 5){
            period = 'Mar/Apr/May' + ' ' + currentYear;
        } else if(currentMonth == 6 || currentMonth ==  7 || currentMonth == 8){
            period = 'Jun/Jul/Aug' + ' ' + currentYear;
        } else if(currentMonth == 9 || currentMonth ==  10 || currentMonth == 11){
            period = 'Sep/Oct/Nov' + ' ' + currentYear;
        }
        return period;
    }
}