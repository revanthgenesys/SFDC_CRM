/************************************************************************************
Purpose : Batch helper to update forecasts total on user
Written By :  Naresh Kumar	08/07/2018
Test Classes :  UpdateForecastTotalOnUserBatchTest
*************************************************************************************/
public without sharing class UpdateForecastTotalOnUser {
    
   public static void updateTotal(List<Id> listOfUserIds){
        //Updating Forecast Total
        //Getting aggregate result
        AggregateResult[] results = [SELECT OwnerId, SUM(License_Equivalency__c) sum1, SUM(Genesys_Care_Amount__c) sum2  FROM Opportunity 
                                     WHERE ForecastStatus__c IN ('0.Booked','1.In Hand','3.Expected','4.Upside')
        		//AND StageName IN ('5.Purchase Solution','6.Closed') AND Win_Loss_Status__c NOT IN ('Lost','Merged/Dup Opp')
				AND RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New' 
                AND OwnerId IN : listOfUserIds
				AND CALENDAR_YEAR(CloseDate) = : System.today().Year()                                 
                GROUP BY OwnerId];
        
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        //Looping over aggregate result
        for(AggregateResult eachResult : results){        	
            Decimal decLicenseEquivalency = (Decimal)(eachResult.get('sum1') == null ? 0 : eachResult.get('sum1'));
            Decimal decGenesysCareAmount = (Decimal)(eachResult.get('sum2') == null ? 0 : eachResult.get('sum2'));
            Double total = decLicenseEquivalency == null ? 0 : decLicenseEquivalency;
            total += decGenesysCareAmount == null ? 0 : decGenesysCareAmount;
            User objUser = new User(id = (Id)eachResult.get('OwnerId'), Forecast_Amount__c = total);
            mapOfUsers.put(objUser.id, objUser);
        }
        
        
        //Updating Pipeline Total
        //Getting aggregate result
        results = [SELECT OwnerId, SUM(License_Equivalency__c) sum1, SUM(Genesys_Care_Amount__c) sum2  FROM Opportunity 
                WHERE ForecastStatus__c IN ('3.Expected','4.Upside','5.Pipeline')
        		AND StageName IN ('1.Understand Needs','2.Define Requirements','3.Evaluate Options','4.Build Consensus','5.Purchase Solution') 
                AND Win_Loss_Status__c = NULL
				AND RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New' 
                AND OwnerId IN : listOfUserIds
				AND CALENDAR_YEAR(CloseDate) = : System.today().Year()
                GROUP BY OwnerId];
        
        //Looping over aggregate result
        for(AggregateResult eachResult : results){        	
            Decimal decLicenseEquivalency = (Decimal)(eachResult.get('sum1') == null ? 0 : eachResult.get('sum1'));
            Decimal decGenesysCareAmount = (Decimal)(eachResult.get('sum2') == null ? 0 : eachResult.get('sum2'));
            Double total = decLicenseEquivalency == null ? 0 : decLicenseEquivalency;
            total += decGenesysCareAmount == null ? 0 : decGenesysCareAmount;
            User objUser = mapOfUsers.get((Id)eachResult.get('OwnerId'));
            if(objUser == null){
            	objUser = new User(id = (Id)eachResult.get('OwnerId'));    
            }
            objUser.Pipeline_Amount__c = total;
            mapOfUsers.put(objUser.id, objUser);
        }
        
        //
        //Getting aggregate result
        results = [SELECT OwnerId, SUM(License_Equivalency__c) sum1, SUM(Genesys_Care_Amount__c) sum2  FROM Opportunity 
                WHERE RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New' 
				AND (NOT Name LIKE '%CMRR%') AND (NOT NAME LIKE '%$0%') AND (NOT Name LIKE '%talker%')
                AND (NOT Owner.UserRole.Name LIKE '%WW-Sales Operation%')// AND (NOT Owner.UserRole.Name LIKE '%System Administrator%') 
                AND (NOT Owner.UserRole.Name LIKE '%MKG%') AND (NOT Owner.UserRole.Name LIKE '%WW---Sales Operation%')
                AND Has_PPU_Usage__c = false AND Cloud_Renewal__c = false
                AND ForecastStatus__c = '0.Booked' AND Has_PS__c = false
        		AND Win_Loss_Status__c NOT IN ('Lost','Merged/Dup Opp')				
                AND OwnerId IN : listOfUserIds
				AND CALENDAR_YEAR(CloseDate) = : System.today().Year()                                 
                GROUP BY OwnerId];
        
        //Looping over aggregate result
        for(AggregateResult eachResult : results){        	
            Decimal decLicenseEquivalency = (Decimal)(eachResult.get('sum1') == null ? 0 : eachResult.get('sum1'));
            Decimal decGenesysCareAmount = (Decimal)(eachResult.get('sum2') == null ? 0 : eachResult.get('sum2'));
            Double total = decLicenseEquivalency == null ? 0 : decLicenseEquivalency;
            total += decGenesysCareAmount == null ? 0 : decGenesysCareAmount;
            User objUser = mapOfUsers.get((Id)eachResult.get('OwnerId'));
            if(objUser == null){
            	objUser = new User(id = (Id)eachResult.get('OwnerId'));    
            }
            objUser.CFY_Closed_Won_Amount__c = total;
            mapOfUsers.put(objUser.id, objUser);
        }        
        
        if(!mapOfUsers.values().isEmpty())
            Database.update(mapOfUsers.values());        
    }
}