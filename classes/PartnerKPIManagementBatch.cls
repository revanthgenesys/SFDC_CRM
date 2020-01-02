global class PartnerKPIManagementBatch implements Database.Batchable<sObject>, Database.Stateful {
	global String publishHistoryRecordId;
   
    global PartnerKPIManagementBatch(String publishHistoryRecordId){
        this.publishHistoryRecordId = publishHistoryRecordId;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime yearStartDate;
        DateTime periodStartDate;
        DateTime periodEndDate;        
        
        // Query Publish request info
        Partner_KPI_Publish_History__c publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                                                                  FROM Partner_KPI_Publish_History__c WHERE id = :publishHistoryRecordId];
        
        String periodToPublish = publishHistory.Period__c;
        
        // Update the Publish Request Status to Processing ...
		publishHistory.Status__c = 'Processing';
        Update publishHistory;
        
        if(periodToPublish != ''){
            String periodMonths = periodToPublish.substring(0,periodToPublish.indexOf(' '));
            Integer year = Integer.valueOf(periodToPublish.substring(periodToPublish.indexOf(' ')+1));
            
            if(periodMonths == 'Sep/Oct/Nov'){
                periodStartDate = DateTime.newInstance(year, 9, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 11, 30, 23, 59, 59);
            	yearStartDate = DateTime.newInstance(year, 9, 1, 0, 0, 1);
            }            
            if(periodMonths == 'Dec/Jan/Feb'){
                periodStartDate = DateTime.newInstance(year-1, 12, 1, 0, 0, 1);
                if(Date.isLeapYear(year))
                	periodEndDate = DateTime.newInstance(year, 2, 28, 23, 59, 59);
				else
					periodEndDate = DateTime.newInstance(year, 2, 29, 23, 59, 59);
            	yearStartDate = DateTime.newInstance(year-1, 9, 1, 0, 0, 1);
            }            
            if(periodMonths == 'Mar/Apr/May'){
                periodStartDate = DateTime.newInstance(year, 3, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 5, 31, 23, 59, 59);
            	yearStartDate = DateTime.newInstance(year-1, 9, 1, 0, 0, 1);
            }            
            if(periodMonths == 'Jun/Jul/Aug'){
                periodStartDate = DateTime.newInstance(year, 6, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 8, 31, 23, 59, 59);
            	yearStartDate = DateTime.newInstance(year-1, 9, 1, 0, 0, 1);
            }  
        }    
		
        String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();        
        AggregateResult[] groupedResults = [SELECT Sold_To_Account__c, Count(Id) 
                                            FROM Case 
                                            WHERE 
                                            (
                                                   RecordTypeId = :supportCaseRecordTypeId  
                                                   AND Sold_To_Account__r.Type = 'Partner' 
                                   				   AND Sold_To_Account__r.Status__c = 'Active'
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
                                             AND (ClosedDate >= :periodStartDate AND  ClosedDate <= :periodEndDate)
                                        GROUP BY Sold_To_Account__c];
        
        Set<String> partnerAccountIds = new Set<String>();
		for (AggregateResult ar : groupedResults)  {
			partnerAccountIds.add((String)ar.get('Sold_To_Account__c'));
		}
		
        String partnerAccountQuery = 'SELECT Id, Name, Region__c  FROM Account WHERE Id IN :partnerAccountIds';
        if(Test.isRunningTest()){
            partnerAccountQuery = partnerAccountQuery + ' LIMIT 1';
        }
		return Database.getQueryLocator(partnerAccountQuery);                         
                         
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();        
        
        Set<Integer> monthsInCurrentPeriod;
		DateTime yearStartDate;
        DateTime periodStartDate; 
        DateTime periodEndDate;        
        Integer periodYear;
        Integer periodQuarter;
        List<Partner_KPI_Publish_History__c> publishHistory = [SELECT Id, Name, Published_User__c, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                                                                  FROM Partner_KPI_Publish_History__c WHERE id = :publishHistoryRecordId];

        String periodToPublish = '';
        if(!publishHistory.isEmpty()){
            periodToPublish = publishHistory[0].Period__c;
        }
        if(periodToPublish != ''){
            String periodMonths = periodToPublish.substring(0,periodToPublish.indexOf(' '));
            Integer year = Integer.valueOf(periodToPublish.substring(periodToPublish.indexOf(' ')+1));
            
            if(periodMonths == 'Sep/Oct/Nov'){
                periodQuarter = 1;
                periodStartDate = DateTime.newInstance(year, 9, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 11, 30, 23, 59, 59);
                periodYear = year + 1;
                monthsInCurrentPeriod = new Set<Integer>{9,10,11};
            }            
            if(periodMonths == 'Dec/Jan/Feb'){
                periodQuarter = 2;
                periodStartDate = DateTime.newInstance(year-1, 12, 1, 0, 0, 1);
                if(Date.isLeapYear(year))
                	periodEndDate = DateTime.newInstance(year, 2, 28, 23, 59, 59);
				else
					periodEndDate = DateTime.newInstance(year, 2, 29, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{12,1,2};
            }            
            if(periodMonths == 'Mar/Apr/May'){
                periodQuarter = 3;
                periodStartDate = DateTime.newInstance(year, 3, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 5, 31, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{3,4,5};
            }            
            if(periodMonths == 'Jun/Jul/Aug'){
                periodQuarter = 4;
                periodStartDate = DateTime.newInstance(year, 6, 1, 0, 0, 1);
                periodEndDate = DateTime.newInstance(year, 8, 31, 23, 59, 59);
                periodYear = year;
                monthsInCurrentPeriod = new Set<Integer>{6,7,8};
            }  
            yearStartDate = DateTime.newInstance(periodYear-1, 9, 1, 0, 0, 1);
        }    
        
        for(sObject so : scope){
            Account a = (Account)so;
            
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
            Partner_Quarterly_KPI__c partnerKPI1Header;
            List<KPI1_Case_Details__c> partnerKPI1Details = new List<KPI1_Case_Details__c>();
            
            // Objects to hold the data that needs to be published for Cases closed by default
            Cases_Closed_By_Default_Header__c ccbdHeader;
            List<Cases_Closed_By_Default_Detail__c> ccdbDetails = new List<Cases_Closed_By_Default_Detail__c>();
            
            /* *************************************************************************************************************************
             * Logic for Cases Closed by Default:
        	 * - If the Case Sub Status = “Auto Follow-Up” then the case is closed by default. 
			 * - Per Period and YTD results are calculated by dividing SUM(Num Cases Closed by Auto Follow-Up)/SUM(Total Num Cases)
             * *************************************************************************************************************************
             * 
             */
            for(Case c: casesYTD){
                // KPI1 Calculations for current case
                Integer problemDescriptionWeightedPerCase = c.Problem_Description_clear_and_detail__c == 'Yes' ? 15 : 0;
                //Integer supportingInfoWeightedPerCase = c.Supporting_Info_Provided__c == 'Yes' ? 15 : 0;
                Integer supportingInfoWeightedPerCase = c.Supporting_Info_Provided__c == 'No' ? 0 : 15;
                Integer closureAssessmentPerCase = c.Should_have_been_solved_using_KB__c == 'No' ? 30 : 0;
				Integer trainingAssessmentPerCase = c.GU_Certified_Contact__c == 'Yes' ? 20 : 0;
                // Integer casesClosedByDefaultPerCase = c.Sub_Status__c == 'Auto Follow-Up' ? 20 : 0;
                Integer casesClosedByDefaultPerCase = c.Sub_Status__c == 'Auto Follow-Up' ? 0 : 20;
                Decimal kpiScorePerCase = ((Decimal)(problemDescriptionWeightedPerCase 
                                                     + supportingInfoWeightedPerCase 
                                                     + closureAssessmentPerCase 
                                                     + trainingAssessmentPerCase
                                                     + casesClosedByDefaultPerCase)) / 100;
                
                
                // KPI1 Calculations for the whole year
                problemDescriptionWeightedYTD = problemDescriptionWeightedYTD + problemDescriptionWeightedPerCase;
                supportingInfoWeightedYTD = supportingInfoWeightedYTD + supportingInfoWeightedPerCase;
                closureAssessmentYTD = closureAssessmentYTD + closureAssessmentPerCase;
                trainingAssessmentYTD = trainingAssessmentYTD + trainingAssessmentPerCase;
                casesClosedByDefaultYTD = casesClosedByDefaultYTD + casesClosedByDefaultPerCase;
                kpiScoreYTD = kpiScoreYTD + kpiScorePerCase; 

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
                    partnerKPI1Details.add(new KPI1_Case_Details__c(Account__c = c.Sold_To_Account__c,
                                                                        Account_Name__c = c.Sold_To_Account__r.Name,
                                                                        Case_Number__c = c.CaseNumber,
                                                                        Product__c = c.Support_Product__r.Name,
                                                                        Period__c = periodToPublish,
                                                                        Contact_Name__c = c.Contact_Name__c,
                                                                        Problem_Description_Clear_and_Detailed__c = c.Problem_Description_clear_and_detail__c,
                                                                        Should_Have_Been_Solved_Using_Docs_KB__c = c.Should_have_been_solved_using_KB__c,
                                                                        Supporting_Info_Provided__c = (c.Supporting_Info_Provided__c == 'Not Applicable' ? 'NA' : c.Supporting_Info_Provided__c),
                                                                        Case_Logged_By_GU_Certified_Contact__c = c.GU_Certified_Contact__c,
                                                                   		Sub_Status_Group__c = (c.Sub_Status__c == 'Auto Follow-Up' ? 'Yes' : 'No')
                                                                   ));
                    
                    // Cases closed by default details
                    ccdbDetails.add(new Cases_Closed_By_Default_Detail__c( 	Partner_Account__c = c.Sold_To_Account__c,
                                                                            Period__c = periodToPublish,
                                                                            Case_Number__c = c.CaseNumber,
                                                                            Case_Owner__c = c.Owner.Name,
                                                                            Contact_Name__c = c.Contact_Name__c));
                    
                } // End of if condition to check whether a case is in Current Period or not 
            } // End of Cases for loop
            
            // Handle Database operations (clean up & create) for Partner KPI1 Data ...
            if(partnerKPI1Details.size() > 0){
                partnerKPI1Header = new Partner_Quarterly_KPI__c( 	Account__c = a.Id,
                                                                    Account_Name__c = a.Name,
                                                                    Period__c = periodToPublish,
                                                                    Period_From__c = date.newinstance(periodStartDate.year(), periodStartDate.month(), periodStartDate.day()),
                                                                    Period_To__c = date.newinstance(periodEndDate.year(), periodEndDate.month(), periodEndDate.day()),
                                                                    Quarter__c = periodQuarter,
                                                                    Year__c = periodYear,
                                                                    Region__c = a.Region__c,
                                                                    Problem_Description__c =  (problemDescriptionWeighted/ totalCasesInPeriod).setScale(2),
                                                                    Supporting_Information__c = (supportingInfoWeighted/ totalCasesInPeriod).setScale(2),
                                                                    Quality_Assessment__c = ((problemDescriptionWeighted + supportingInfoWeighted) / totalCasesInPeriod).setScale(2),
                                                                    Quality_Assessment_YTD__c = ((problemDescriptionWeightedYTD + supportingInfoWeightedYTD) / totalCasesYTD).setScale(2),
                                                                    Closure_Assessment__c = (closureAssessment/ totalCasesInPeriod).setScale(2),
                                                                    Closure_Assessment_YTD__c = (closureAssessmentYTD/ totalCasesYTD).setScale(2),
                                                                    Training_Assessment__c = (trainingAssessment/ totalCasesInPeriod).setScale(2),
                                                                    Training_Assessment_YTD__c = (trainingAssessmentYTD/ totalCasesYTD).setScale(2),
                                                                    Cases_Closed_by_Default__c = (casesClosedByDefault/ totalCasesInPeriod).setScale(2),
                                                                    Cases_Closed_by_Default_YTD__c = (casesClosedByDefaultYTD/ totalCasesYTD).setScale(2),
                                                                    Total_KPI_Score__c = (kpiScore * 100)/ totalCasesInPeriod,
                                                                    Total_YTD_KPI_Score__c = ((kpiScoreYTD * 100)/ totalCasesYTD).setScale(2)
                                                                    );
                
                // Clean up Partner KPI1 data if it is already published for the selected period ...
                Database.delete([SELECT id FROM Partner_Quarterly_KPI__c WHERE Account__c = :a.Id AND Period__c = :periodToPublish]);
                Database.delete([SELECT id FROM KPI1_Case_Details__c WHERE Account__c = :a.Id AND Period__c = :periodToPublish]);
                
				// Create Partner KPI1 Data for the selected period ...                
                Database.insert(partnerKPI1Header);
                Database.insert(partnerKPI1Details);
            }
            // Handle Database operations (clean up & create) for Cases closed by default ...
            if(ccdbDetails.size() > 0){
				// Create Cases Closed by Default Header object
            	ccbdHeader = new Cases_Closed_By_Default_Header__c(	Partner_Account__c = a.Id,
																		Account_Name__c = a.Name,
																		Period__c = periodToPublish,
																		Year__c = ''+periodYear,
																		Closed_By_Default__c = (autoFollowUpCasesInPeriod*100)/totalCasesInPeriod,
																		YTD_Closed_By_Default__c = (autoFollowUpCasesInYear*100)/totalCasesYTD);


                // Clean up Cases Closed by Default data if it is already published for the selected period ...
                Database.delete([SELECT id FROM Cases_Closed_By_Default_Header__c WHERE Partner_Account__c = :a.Id AND Period__c = :periodToPublish]);
                Database.delete([SELECT id FROM Cases_Closed_By_Default_Detail__c WHERE Partner_Account__c = :a.Id AND Period__c = :periodToPublish]);
                
				// Create Cases Closed by Default Data for the selected period ...                
                Database.insert(ccbdHeader);
                Database.insert(ccdbDetails);
			}
        }
    }
    global void finish(Database.BatchableContext BC){
        Partner_KPI_Publish_History__c publishHistory = [SELECT Id, Name, Published_User__c, Published_User__r.Email, Period__c, Status__c, CreatedDate, Completed_Date__c, LastModifiedDate 
                                                                  FROM Partner_KPI_Publish_History__c WHERE id = :publishHistoryRecordId];
        
        // Update the Publish Request Status to Completed & Completed Date ...
		publishHistory.Status__c = 'Completed';
        publishHistory.Completed_Date__c = System.now();
        Update publishHistory;
        
        // Add the custom Setting if one not available
		PartnerKPIHelper.insertKPIPeriodCS(publishHistory.Period__c);        
        // Send the email to Publish Request Submitter
	    String emailBody = '';
        emailBody += 'Hello'+'\n\n';   
        emailBody += 'Your Partner KPI Information publish request for ' + publishHistory.Period__c + ' has been completed' +'\n\n';               
        emailBody += 'Requested Time : '+ publishHistory.CreatedDate + '\n\n';   
        emailBody += 'Completed Time : '+ publishHistory.Completed_Date__c + '\n\n';   
        emailBody += 'Note: This is system generated email.';   

        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{publishHistory.Published_User__r.Email});
        mail.setSubject('Partner KPI Data for ['+publishHistory.Period__c+'] has been published');
        mail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.singleEmailMessage[]{mail});
    }
}