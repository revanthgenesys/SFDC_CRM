//Naresh Kumar  07/27/2016
public without sharing class OpportunityHistorySnapshots {

    public static void createSnapshotDataForOpportunity(Id opportunityId, Boolean deleteAll){
        Date initialStartDate = Date.newInstance(2015, 1, 1);
        if(!deleteAll){
            List<Opportunity_History_Snapshot__c> latestSnapshots = [SELECT Snapshot_Date__c FROM Opportunity_History_Snapshot__c WHERE Opportunity__c =: opportunityId 
                ORDER BY Snapshot_Date__c DESC LIMIT 1];
            if(!latestSnapshots.isEmpty()){
                initialStartDate = latestSnapshots[0].Snapshot_Date__c.addDays(14);       
            }
        }
        System.debug('NKC debug initialStartDate [' + initialStartDate + ']');
        
        List<Opportunity_History_Snapshot__c> oppHistorySnapshotsToBeDeleted = [SELECT id FROM Opportunity_History_Snapshot__c
            WHERE Opportunity__c =: opportunityId AND Snapshot_Date__c >=: initialStartDate]; 
        if(!oppHistorySnapshotsToBeDeleted.isEmpty())
            delete oppHistorySnapshotsToBeDeleted;
        Opportunity opp = [SELECT AccountId, Amount, CloseDate, Country__c, Description, ForecastStatus__c,
            License_Amount__c, Maintenance_Amount__c, ACV_Subscription_Only__c, Lines_of_Businesses__c, Opportunity_Status__c, OwnerId,
            Primary_Line_of_Business__c, Competitor__c, WonLostCancelledReason__c, BusinessPartner__c, Sold_To_Country__c,
            StageName, Type, Win_Loss_Status__c, CreatedDate, CurrencyIsoCode FROM Opportunity WHERE id =: opportunityId];            
        
        List<Opportunity> listOfOppHistory = convertOppFieldHistoryToOppRecords(opp);
        System.debug('NKC debug listOfOppHistory.size() ['+listOfOppHistory.size()+']');
        
        Map<Date, Opportunity> mapOfDateVsOppHistory = new Map<Date, Opportunity>();
        for(Opportunity eachOpp : listOfOppHistory){        
            System.debug('NKC debug eachOpp. ['+eachOpp.Opportunity_Status__c + ' - ' + eachOpp.CreatedDate +']');
            System.debug('NKC debug eachOpp ['+eachOpp+']');            
                        
        }
         
        List<Opportunity_History_Snapshot__c> oppHistorySnapshotsToBeInserted = new List<Opportunity_History_Snapshot__c>();
        Date startDate = Date.newInstance(2015, 1, 1);
        while(startDate <= opp.CreatedDate){
            startDate = startDate.addDays(14);            
        }
        startDate = startDate.addDays(-14);
        
        //Code Start - Merging opportunity records betweend each 14 days.
        Date tempDate = startDate;
        Map<Date, Opportunity> mapOfDatesVsOpportunity = new Map<Date, Opportunity>();
        Map<Date, Date> mapOfDateVsNextDate = new Map<Date, Date>();
        Date nextDate1;
        while(tempDate <= System.today()){
            nextDate1 = tempDate.addDays(14);
            mapOfDateVsNextDate.put(tempDate, nextDate1);
            tempDate = tempDate.addDays(14);
        }        
        
        System.debug('NKC debug mapOfDatesVsOpportunity.keyset() ['+mapOfDatesVsOpportunity.keyset()+']');
        System.debug('NKC debug mapOfDateVsNextDate ['+mapOfDateVsNextDate+']');
        
        
        for(Opportunity eachOpp : listOfOppHistory){
            for(Date eachDate : mapOfDateVsNextDate.keyset()){                          
                Date nextDate = mapOfDateVsNextDate.get(eachDate);
                System.debug('NKC debug eachDate ['+eachDate+']');
                System.debug('NKC debug nextDate ['+nextDate+']');
                System.debug('NKC debug eachOpp.CreatedDate ['+eachOpp.CreatedDate+']');
                if(eachOpp.CreatedDate >= eachDate && eachOpp.CreatedDate <= nextDate){
                    mapOfDatesVsOpportunity.put(eachDate, eachOpp);                        
                }         
            }
        }
        
        listOfOppHistory = mapOfDatesVsOpportunity.values();
        System.debug('NKC debug listOfOppHistory ['+listOfOppHistory+']');
        for(Opportunity eachOpp : listOfOppHistory){        
            System.debug('NKC debug eachOpp1 ['+eachOpp+']');
        }
        
        //Code Ends - Merging opportunity records betweend each 14 days.
        
        //Default snapshot record
        Opportunity_History_Snapshot__c newSnapshot;                                    
        if(listOfOppHistory.isEmpty()){
            newSnapshot = populateSnapshotRecordFromOpportunity(opp);        
        }
        else{
            newSnapshot = populateSnapshotRecordFromOpportunity(listOfOppHistory[0]); 
            newSnapshot.Opportunity__c = opp.id;                        
        }
        Integer counter = 1;
        while(System.today() > startDate){
            if(counter == 1){
                Integer oppIndex = 0;
                for(Opportunity eachOpp : listOfOppHistory){
                    System.debug('NKC debug eachOpp.CreatedDate ['+eachOpp.CreatedDate+']');
                    System.debug('NKC debug startDate ['+startDate+']');
                    /*
                    //Go to the next opportunity (not in case of last in the list) while start date is greater then opp date
                    if(startDate > eachOpp.CreatedDate && (oppIndex + 1) < listOfOppHistory.size()){
                        continue;
                    }
                    */
                    DateTime nextOppCreatedDate = eachOpp.CreatedDate;
                    System.debug('NKC debug nextOppCreatedDate ['+nextOppCreatedDate+']');
                    if(listOfOppHistory.size() > oppIndex + 1){
                        nextOppCreatedDate = listOfOppHistory[oppIndex + 1].CreatedDate;
                        System.debug('NKC debug nextOppCreatedDate ['+nextOppCreatedDate+']'); 
                    }      
                    else{
                        nextOppCreatedDate = nextOppCreatedDate.addDays(14);
                        System.debug('NKC debug nextOppCreatedDate ['+nextOppCreatedDate+']');
                    }                                     
                    
                    while(startDate < nextOppCreatedDate){
                        newSnapshot = populateSnapshotRecordFromOpportunity(eachOpp);     
                        newSnapshot.Opportunity__c = opp.id;                                            
                        newSnapshot.Snapshot_Date__c = startDate;
                        newSnapshot.CurrencyIsoCode = opp.CurrencyIsoCode;                        
                        if(startDate > system.today())
                            break;
                        if(startDate < opp.CreatedDate){
                            startDate = startDate.addDays(14);
                            continue;
                        }
                        oppHistorySnapshotsToBeInserted.add(newSnapshot);
                        startDate = startDate.addDays(14);   
                        System.debug('NKC debug startDate ['+startDate+']');                     
                    }
                    oppIndex ++;
                    //newSnapshot = populateSnapshotRecordFromOpportunity(eachOpp);                                
                }
                counter ++;
             }
             newSnapshot = createNewSnapshot(newSnapshot);
             newSnapshot.Snapshot_Date__c = startDate;
             if(startDate > system.today())
                break;
             newSnapshot.CurrencyIsoCode = opp.CurrencyIsoCode;
             oppHistorySnapshotsToBeInserted.add(newSnapshot);
             startDate = startDate.addDays(14);
             if(!Test.isRunningTest() && startDate > System.today())
                break;
        }        
        if(!oppHistorySnapshotsToBeInserted.isEmpty())
            insert oppHistorySnapshotsToBeInserted;     
    }  
   
    private static List<Opportunity> convertOppFieldHistoryToOppRecords(Opportunity opp){
        Id opportunityId = opp.id;           
        List<wrapperOppFieldHisotry> listOfOppFieldHistory = populateOppFieldHistoryWrapper(opportunityId);
        List<wrapperOppFieldHisotry> listOfOppFieldHistoryLastChangeOnly = getOpportunityHistoryLastChangeOnly(listOfOppFieldHistory);
        Map<String, Boolean> mapOfFieldVsIsMultipleHistoryFlag = new Map<String, Boolean>();
        for(wrapperOppFieldHisotry eachRecord : listOfOppFieldHistoryLastChangeOnly){
            if(mapOfFieldVsIsMultipleHistoryFlag.get(eachRecord.field) == null)
                mapOfFieldVsIsMultipleHistoryFlag.put(eachRecord.field, false);
            else
                mapOfFieldVsIsMultipleHistoryFlag.put(eachRecord.field, true);
        }
        
        Map<Date, Opportunity> mapOfCreatedDateVsOpportunity = new Map<Date, Opportunity>();
        Opportunity defaultOpp = opp;
        Opportunity previousOpp = opp;
        Set<String> setOfFields = new Set<String>();        
        Integer counter = 1;
        //Looping over each opportunity field history record
        for(wrapperOppFieldHisotry eachFieldHistory : listOfOppFieldHistory){
            System.debug('NKC debug counter [' + counter + ']');
            Date createdDate = Date.newInstance(eachFieldHistory.CreatedDate.year(), eachFieldHistory.CreatedDate.month(), eachFieldHistory.CreatedDate.day());
            System.debug('NKC debug createdDate [' + createdDate + ']');
            System.debug('NKC debug listOfOppFieldHistory.size() [' + listOfOppFieldHistory.size() + ']');
            System.debug('NKC debug listOfOppFieldHistoryLastChangeOnly.size() [' + listOfOppFieldHistoryLastChangeOnly.size() + ']');
            
            Boolean flag = !setOfFields.contains(eachFieldHistory.field);
            if(mapOfCreatedDateVsOpportunity.get(createdDate) == null){ 
                defaultOpp = populateOpportunityFieldsOldValues(listOfOppFieldHistoryLastChangeOnly, createdDate, previousOpp);
                Opportunity newOpp = populateDefaultFields(defaultOpp);     
                newOpp = populateOpportunityFields(eachFieldHistory, newOpp, flag && mapOfFieldVsIsMultipleHistoryFlag.get(eachFieldHistory.field));
                mapOfCreatedDateVsOpportunity.put(createdDate, newOpp);
                previousOpp = defaultOpp;                
            }
            else{
                Opportunity newOpp = mapOfCreatedDateVsOpportunity.get(createdDate);
                newOpp = populateOpportunityFields(eachFieldHistory, newOpp, flag && mapOfFieldVsIsMultipleHistoryFlag.get(eachFieldHistory.field));
                mapOfCreatedDateVsOpportunity.put(createdDate, newOpp);
                previousOpp = newOpp;
            }                            
            setOfFields.add(eachFieldHistory.field);
            counter ++; 
        }        
        return mapOfCreatedDateVsOpportunity.values();
    }    
    
    private static List<wrapperOppFieldHisotry> getOpportunityHistoryLastChangeOnly(List<wrapperOppFieldHisotry> listOfOppFieldHistory){
        
        List<wrapperOppFieldHisotry> listOfOppFieldHistoryLastChangeOnly = new List<wrapperOppFieldHisotry>();
        Map<String, wrapperOppFieldHisotry> mapOfDateFieldVsFieldHistory = new Map<String, wrapperOppFieldHisotry>(); 
        for(wrapperOppFieldHisotry eachFieldHistory : listOfOppFieldHistory){
            Date createdDate = Date.newInstance(eachFieldHistory.CreatedDate.year(), eachFieldHistory.CreatedDate.month(), eachFieldHistory.CreatedDate.day());
            String fieldName = eachFieldHistory.Field;
            String key = String.valueOf(createdDate) + fieldName;
            if(mapOfDateFieldVsFieldHistory.get(key) == null){
                mapOfDateFieldVsFieldHistory.put(key, eachFieldHistory);
            }
            else{
                wrapperOppFieldHisotry oldFieldHistory = mapOfDateFieldVsFieldHistory.get(key); 
                eachFieldHistory.OldValue = oldFieldHistory.OldValue;
                mapOfDateFieldVsFieldHistory.put(key, eachFieldHistory);
            }
            System.debug('NKC debug merge eachFieldHistory [' + eachFieldHistory + ']');    
        }
        
        return mapOfDateFieldVsFieldHistory.values();
    }
    
    public static Opportunity_History_Snapshot__c createNewSnapshot(Opportunity_History_Snapshot__c snapshot){
        Opportunity_History_Snapshot__c newSnapshot = new Opportunity_History_Snapshot__c();
        newSnapshot.Account__c = snapshot.Account__c;
        newSnapshot.Amount__c = snapshot.Amount__c;
        newSnapshot.Close_Date__c = snapshot.Close_Date__c;
        newSnapshot.Country__c = snapshot.Country__c;
        newSnapshot.Description__c = snapshot.Description__c;
        newSnapshot.Forecast_Status__c = snapshot.Forecast_Status__c;
        newSnapshot.License_Amount__c = snapshot.License_Amount__c;
        newSnapshot.Maintenance_Amount__c = snapshot.Maintenance_Amount__c;
        newSnapshot.ACV_Subscription_Only__c = snapshot.ACV_Subscription_Only__c;
        newSnapshot.Offerings_Type__c = snapshot.Offerings_Type__c;
        newSnapshot.Opportunity__c = snapshot.Opportunity__c;
        newSnapshot.Opportunity_Status__c = snapshot.Opportunity_Status__c;
        newSnapshot.Owner__c = snapshot.Owner__c;
        newSnapshot.Platform_Type__c = snapshot.Platform_Type__c;
        newSnapshot.Primary_Competitor__c = snapshot.Primary_Competitor__c;
        newSnapshot.Primary_Won_Lost_Reason__c = snapshot.Primary_Won_Lost_Reason__c;
        newSnapshot.Sold_To_Business_Partner__c = snapshot.Sold_To_Business_Partner__c;
        newSnapshot.Sold_To_Country__c = snapshot.Sold_To_Country__c;
        newSnapshot.StageName__c = snapshot.StageName__c;
        newSnapshot.Type__c = snapshot.Type__c;
        newSnapshot.Win_Loss_Status__c = snapshot.Win_Loss_Status__c;
        newSnapshot.CurrencyIsoCode = snapshot.CurrencyIsoCode;
        return newSnapshot;         
    } 
     
    private static Opportunity_History_Snapshot__c populateSnapshotRecordFromOpportunity(Opportunity opp){
        Opportunity_History_Snapshot__c newSnapshot = new Opportunity_History_Snapshot__c();
        newSnapshot.Account__c = opp.accountId;
        newSnapshot.Amount__c = opp.Amount;
        newSnapshot.Close_Date__c = opp.CloseDate;
        newSnapshot.Country__c = opp.Country__c;
        newSnapshot.Description__c = opp.Description;
        newSnapshot.Forecast_Status__c = opp.ForecastStatus__c;
        newSnapshot.License_Amount__c = opp.License_Amount__c;
        newSnapshot.Maintenance_Amount__c = opp.Maintenance_Amount__c;
        newSnapshot.ACV_Subscription_Only__c = opp.ACV_Subscription_Only__c;
        newSnapshot.Offerings_Type__c = opp.Lines_of_Businesses__c;
        newSnapshot.Opportunity__c = opp.id;
        newSnapshot.Opportunity_Status__c = opp.Opportunity_Status__c;
        newSnapshot.Owner__c = opp.ownerId;
        newSnapshot.Platform_Type__c = opp.Primary_Line_of_Business__c;
        newSnapshot.Primary_Competitor__c = opp.Competitor__c;
        newSnapshot.Primary_Won_Lost_Reason__c = opp.WonLostCancelledReason__c;
        newSnapshot.Sold_To_Business_Partner__c = opp.BusinessPartner__c;
        newSnapshot.Sold_To_Country__c = opp.Sold_To_Country__c;
        newSnapshot.StageName__c = opp.StageName;
        newSnapshot.Type__c = opp.Type;
        newSnapshot.Win_Loss_Status__c = opp.Win_Loss_Status__c;
        newSnapshot.CurrencyIsoCode = opp.CurrencyIsoCode;
        return newSnapshot;     
    }
    
    private static Opportunity populateDefaultFields(Opportunity defaultOpp){
        Opportunity newOpp = new Opportunity();
        newOpp.accountId = defaultOpp.accountId;
        newOpp.Amount = defaultOpp.Amount;
        newOpp.CloseDate = defaultOpp.CloseDate;
        newOpp.Country__c = defaultOpp.Country__c;
        newOpp.Description = defaultOpp.Description;
        newOpp.ForecastStatus__c = defaultOpp.ForecastStatus__c;
        newOpp.License_Amount__c = defaultOpp.License_Amount__c;
        newOpp.Maintenance_Amount__c = defaultOpp.Maintenance_Amount__c;
        newOpp.ACV_Subscription_Only__c = defaultOpp.ACV_Subscription_Only__c;
        newOpp.Lines_of_Businesses__c = defaultOpp.Lines_of_Businesses__c;
        newOpp.Opportunity_Status__c = defaultOpp.Opportunity_Status__c;
        newOpp.Competitor__c = defaultOpp.Competitor__c;
        newOpp.ownerId = defaultOpp.ownerId;
        newOpp.WonLostCancelledReason__c = defaultOpp.WonLostCancelledReason__c;
        newOpp.BusinessPartner__c = defaultOpp.BusinessPartner__c;
        newOpp.Sold_To_Country__c = defaultOpp.Sold_To_Country__c;
        newOpp.StageName = defaultOpp.StageName;
        newOpp.Type = defaultOpp.Type;
        newOpp.Win_Loss_Status__c = defaultOpp.Win_Loss_Status__c;
        newOpp.Primary_Line_of_Business__c = defaultOpp.Primary_Line_of_Business__c;  
        newOpp.CurrencyIsoCode = defaultOpp.CurrencyIsoCode;              
        return newOpp;
    }
    
    private static Opportunity populateOpportunityFieldsOldValues(List<wrapperOppFieldHisotry> listOfOppFieldHistory, Date createDate, Opportunity previousOpp){
        Opportunity defaultOpp = new Opportunity();
        Boolean doesWinLossReasonHasHistory = false;
        Boolean doesAccountIdHasHistory = false;
        Boolean doesAmountHasHistory = false;
        Boolean doesCloseDateHasHistory = false;
        Boolean doesCountryHasHistory = false;
        Boolean doesDescriptionHasHistory = false;
        Boolean doesForecastStatusHasHistory = false;
        Boolean doesLicenseAmountHasHistory = false;
        Boolean doesMaintenanceAmountHasHistory = false;
        Boolean doesACVSubscriptionOnlyHasHistory = false; 
        Boolean doesLineOfBusinessHasHistory = false;
        Boolean doesCompetitorHasHistory = false;
        Boolean doesWonLostCancelledReasonHasHistory = false;
        Boolean doesSoldToCountryHasHistory = false;
        Boolean doesBusinessPartnerHasHistory = false;
        Boolean doesStageNameHasHistory = false;
        Boolean doesTypeHasHistory = false;
        Boolean doesPrimaryLineOfBusinessHasHistory = false;        
        Boolean doesOwnerIdHasHistory = false;
        Boolean doesOpportunityStatusHasHistory = false;
        
        for(wrapperOppFieldHisotry eachFieldHistory : listOfOppFieldHistory){
            Date createdDateFieldHistory = Date.newInstance(eachFieldHistory.CreatedDate.year(), eachFieldHistory.CreatedDate.month(), eachFieldHistory.CreatedDate.day());
            System.debug('NKC debug eachFieldHistory ['+eachFieldHistory+']');
            System.debug('NKC debug createDate ['+createDate+']');
            System.debug('NKC debug createdDateFieldHistory ['+createdDateFieldHistory+']');
            System.debug('NKC debug eachFieldHistory.Field ['+eachFieldHistory.Field+']');
            System.debug('NKC debug eachFieldHistory.OldValue ['+eachFieldHistory.OldValue+']');
            
            if(createdDateFieldHistory >= createDate  ){
                /*
                if(defaultOpp.AccountId == null && eachFieldHistory.Field == 'Account' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')){
                    defaultOpp.AccountId = String.valueOf(eachFieldHistory.OldValue);
                    doesAccountIdHasHistory = true;
                }
                else if(defaultOpp.AccountId == null && eachFieldHistory.Field == 'Account' && eachFieldHistory.OldValue == null){
                    defaultOpp.AccountId = null;                    
                }
                else if(defaultOpp.Amount == null && eachFieldHistory.Field == 'Amount'){
                    defaultOpp.Amount = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesAmountHasHistory = true;
                }
                else if(defaultOpp.CloseDate == null && eachFieldHistory.Field == 'CloseDate'){
                    defaultOpp.CloseDate = eachFieldHistory.OldValue == null ? null : Date.valueOf(eachFieldHistory.OldValue);
                    doesCloseDateHasHistory = true;
                }
                else if(defaultOpp.Country__c == null && eachFieldHistory.Field == 'Country__c' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('a06')){
                    defaultOpp.Country__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesCountryHasHistory = true;
                }
                else if(defaultOpp.Country__c == null && eachFieldHistory.Field == 'Country__c' && eachFieldHistory.OldValue == null){
                    defaultOpp.Country__c = null;                    
                }
                else if(defaultOpp.Description == null && eachFieldHistory.Field == 'Description'){
                    defaultOpp.Description = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesDescriptionHasHistory = true;
                }
                else if(defaultOpp.ForecastStatus__c == null && eachFieldHistory.Field == 'ForecastStatus__c'){
                    defaultOpp.ForecastStatus__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);  
                    doesForecastStatusHasHistory = true;                 
                }
                else if(defaultOpp.License_Amount__c == null && eachFieldHistory.Field == 'License_Amount__c'){
                    defaultOpp.License_Amount__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesLicenseAmountHasHistory = true;
                }
                else if(defaultOpp.Maintenance_Amount__c == null && eachFieldHistory.Field == 'Maintenance_Amount__c'){
                    defaultOpp.Maintenance_Amount__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesMaintenanceAmountHasHistory = true;
                }
                else if(defaultOpp.ACV_Subscription_Only__c == null && eachFieldHistory.Field == 'ACV_Subscription_Only__c'){
                    defaultOpp.ACV_Subscription_Only__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesACVSubscriptionOnlyHasHistory = true;
                }
                else if(defaultOpp.Lines_of_Businesses__c == null && eachFieldHistory.Field == 'Lines_of_Businesses__c'){
                    defaultOpp.Lines_of_Businesses__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesLineOfBusinessHasHistory = true;
                }
                else if(defaultOpp.Competitor__c == null && eachFieldHistory.Field == 'Competitor__c'){
                    defaultOpp.Competitor__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesCompetitorHasHistory = true;
                }
                else if(defaultOpp.WonLostCancelledReason__c == null && eachFieldHistory.Field == 'WonLostCancelledReason__c'){
                    defaultOpp.WonLostCancelledReason__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesWonLostCancelledReasonHasHistory = true;
                }
                else if(defaultOpp.Sold_To_Country__c == null && eachFieldHistory.Field == 'Sold_To_Country__c' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('a06')){
                    defaultOpp.Sold_To_Country__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesSoldToCountryHasHistory = true;
                }
                else if(defaultOpp.Sold_To_Country__c == null && eachFieldHistory.Field == 'Sold_To_Country__c' && eachFieldHistory.OldValue == null){
                    defaultOpp.Sold_To_Country__c = null;
                }
                if(defaultOpp.BusinessPartner__c == null && eachFieldHistory.Field == 'BusinessPartner__c' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')){
                    defaultOpp.BusinessPartner__c = String.valueOf(eachFieldHistory.OldValue);
                    doesBusinessPartnerHasHistory = true;
                }
                else if(defaultOpp.BusinessPartner__c == null && eachFieldHistory.Field == 'BusinessPartner__c' && eachFieldHistory.OldValue == null){
                    defaultOpp.BusinessPartner__c = null;
                }
                else if(defaultOpp.StageName == null && eachFieldHistory.Field == 'StageName'){
                    defaultOpp.StageName = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);   
                    doesStageNameHasHistory = true;     
                }
                else if(defaultOpp.Type == null && eachFieldHistory.Field == 'Type'){
                    defaultOpp.Type = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesTypeHasHistory = true;
                }
                else if(defaultOpp.Win_Loss_Status__c == null && eachFieldHistory.Field == 'Win_Loss_Status__c'){
                    doesWinLossReasonHasHistory = true;
                    defaultOpp.Win_Loss_Status__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);           
                }
                else if(defaultOpp.Primary_Line_of_Business__c == null && eachFieldHistory.Field == 'Primary_Line_of_Business__c'){
                    defaultOpp.Primary_Line_of_Business__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);      
                    doesPrimaryLineOfBusinessHasHistory = true;  
                }
                else if(defaultOpp.OwnerId == null && eachFieldHistory.Field == 'Owner' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('005')){
                    defaultOpp.OwnerId = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);           
                    doesOwnerIdHasHistory = true;
                }     
                else if(defaultOpp.Opportunity_Status__c == null && eachFieldHistory.Field == 'Opportunity_Status__c' ){
                    defaultOpp.Opportunity_Status__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);  
                    doesOpportunityStatusHasHistory = true;         
                }*/ 
                System.debug('NKC debug defaultOpp.AccountId [' + defaultOpp.AccountId + ']');
                System.debug('NKC debug eachFieldHistory.Field [' + eachFieldHistory.Field + ']');
                if(defaultOpp.AccountId == null && eachFieldHistory.Field == 'Account'){ 
                    //&& ((eachFieldHistory.newValue != null && String.valueOf(eachFieldHistory.newValue).startsWith('001')) 
                    //|| (eachFieldHistory.oldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')))){
                    //String str = String.valueOf(defaultOpp.AccountId);
                    if(eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')){
                        defaultOpp.AccountId = String.valueOf(eachFieldHistory.OldValue);
                    }
                    System.debug('NKC debug defaultOpp.AccountId [' + defaultOpp.AccountId + ']');
                    doesAccountIdHasHistory = true;
                }
                
                /*
                if(defaultOpp.AccountId == null && eachFieldHistory.Field == 'Account' && eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')){
                    defaultOpp.AccountId = String.valueOf(eachFieldHistory.OldValue);                   
                    doesAccountIdHasHistory = true;
                }
                */
                if(defaultOpp.Amount == null && eachFieldHistory.Field == 'Amount'){
                    defaultOpp.Amount = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesAmountHasHistory = true;
                }
                if(defaultOpp.CloseDate == null && eachFieldHistory.Field == 'CloseDate'){
                    defaultOpp.CloseDate = eachFieldHistory.OldValue == null ? null : Date.valueOf(eachFieldHistory.OldValue);
                    doesCloseDateHasHistory = true;
                }
                if(defaultOpp.Country__c == null && eachFieldHistory.Field == 'Country__c' && eachFieldHistory.OldValue != null){                   
                    if(String.valueOf(eachFieldHistory.OldValue).startsWith('a06')){
                        defaultOpp.Country__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    }
                    doesCountryHasHistory = true;
                }
                if(defaultOpp.Description == null && eachFieldHistory.Field == 'Description'){
                    defaultOpp.Description = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesDescriptionHasHistory = true;
                }
                if(defaultOpp.ForecastStatus__c == null && eachFieldHistory.Field == 'ForecastStatus__c'){
                    defaultOpp.ForecastStatus__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);  
                    doesForecastStatusHasHistory = true;                 
                }
                if(defaultOpp.License_Amount__c == null && eachFieldHistory.Field == 'License_Amount__c'){
                    defaultOpp.License_Amount__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesLicenseAmountHasHistory = true;
                }
                if(defaultOpp.Maintenance_Amount__c == null && eachFieldHistory.Field == 'Maintenance_Amount__c'){
                    defaultOpp.Maintenance_Amount__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesMaintenanceAmountHasHistory = true;
                }
                if(defaultOpp.ACV_Subscription_Only__c == null && eachFieldHistory.Field == 'ACV_Subscription_Only__c'){
                    defaultOpp.ACV_Subscription_Only__c = eachFieldHistory.OldValue == null ? null : Double.valueOf(eachFieldHistory.OldValue);
                    doesACVSubscriptionOnlyHasHistory = true;
                }
                if(defaultOpp.Lines_of_Businesses__c == null && eachFieldHistory.Field == 'Lines_of_Businesses__c'){
                    defaultOpp.Lines_of_Businesses__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesLineOfBusinessHasHistory = true;
                }
                if(defaultOpp.Competitor__c == null && eachFieldHistory.Field == 'Competitor__c'){
                    defaultOpp.Competitor__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesCompetitorHasHistory = true;
                }
                if(defaultOpp.WonLostCancelledReason__c == null && eachFieldHistory.Field == 'WonLostCancelledReason__c'){
                    defaultOpp.WonLostCancelledReason__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesWonLostCancelledReasonHasHistory = true;
                }
                if(defaultOpp.Sold_To_Country__c == null && eachFieldHistory.Field == 'Sold_To_Country__c'){
                    if(eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('a06')){
                        defaultOpp.Sold_To_Country__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    }
                    doesSoldToCountryHasHistory = true;
                }
                if(defaultOpp.Sold_To_Country__c == null && eachFieldHistory.Field == 'Sold_To_Country__c' && eachFieldHistory.OldValue == null){
                    defaultOpp.Sold_To_Country__c = null;
                }
                if(defaultOpp.BusinessPartner__c == null && eachFieldHistory.Field == 'BusinessPartner__c'){
                    if(eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('001')){
                        defaultOpp.BusinessPartner__c = String.valueOf(eachFieldHistory.OldValue);
                    }
                    doesBusinessPartnerHasHistory = true;                    
                }
                if(defaultOpp.StageName == null && eachFieldHistory.Field == 'StageName'){
                    defaultOpp.StageName = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);   
                    doesStageNameHasHistory = true;     
                }
                if(defaultOpp.Type == null && eachFieldHistory.Field == 'Type'){
                    defaultOpp.Type = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    doesTypeHasHistory = true;
                }                
                if(defaultOpp.Win_Loss_Status__c == null && eachFieldHistory.Field == 'Win_Loss_Status__c'){
                    doesWinLossReasonHasHistory = true;
                    defaultOpp.Win_Loss_Status__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);                               
                }
                if(defaultOpp.Primary_Line_of_Business__c == null && eachFieldHistory.Field == 'Primary_Line_of_Business__c'){
                    defaultOpp.Primary_Line_of_Business__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);      
                    doesPrimaryLineOfBusinessHasHistory = true;  
                }
                if(defaultOpp.OwnerId == null && eachFieldHistory.Field == 'Owner'){
                    if(eachFieldHistory.OldValue != null && String.valueOf(eachFieldHistory.OldValue).startsWith('005')){
                        defaultOpp.OwnerId = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);
                    }           
                    doesOwnerIdHasHistory = true;
                }     
                if(defaultOpp.Opportunity_Status__c == null && eachFieldHistory.Field == 'Opportunity_Status__c' ){
                    defaultOpp.Opportunity_Status__c = eachFieldHistory.OldValue == null ? null : String.valueOf(eachFieldHistory.OldValue);  
                    doesOpportunityStatusHasHistory = true;         
                }     
            }   
        } 
        if(defaultOpp.AccountId == null && !doesAccountIdHasHistory)
            defaultOpp.AccountId = previousOpp.AccountId;
        System.debug('NKC debug defaultOpp.AccountId [' + defaultOpp.AccountId + ']');
        if(defaultOpp.Amount == null && !doesAmountHasHistory)
            defaultOpp.Amount = previousOpp.Amount;
        if(defaultOpp.CloseDate == null && !doesCloseDateHasHistory)
            defaultOpp.CloseDate = previousOpp.CloseDate;
        if(defaultOpp.Country__c == null && !doesCountryHasHistory)
            defaultOpp.Country__c = previousOpp.Country__c;
        if(defaultOpp.Description == null && !doesDescriptionHasHistory)
            defaultOpp.Description = previousOpp.Description;
        if(defaultOpp.ForecastStatus__c == null && !doesForecastStatusHasHistory)
            defaultOpp.ForecastStatus__c = previousOpp.ForecastStatus__c;
        if(defaultOpp.License_Amount__c == null && !doesLicenseAmountHasHistory)
            defaultOpp.License_Amount__c = previousOpp.License_Amount__c;
        if(defaultOpp.Maintenance_Amount__c == null && !doesMaintenanceAmountHasHistory)
            defaultOpp.Maintenance_Amount__c = previousOpp.Maintenance_Amount__c;
        if(defaultOpp.ACV_Subscription_Only__c == null && !doesACVSubscriptionOnlyHasHistory)
            defaultOpp.ACV_Subscription_Only__c = previousOpp.ACV_Subscription_Only__c;
        if(defaultOpp.Lines_of_Businesses__c == null && !doesLineOfBusinessHasHistory)
            defaultOpp.Lines_of_Businesses__c = previousOpp.Lines_of_Businesses__c;
        if(defaultOpp.Competitor__c == null && !doesCompetitorHasHistory)
            defaultOpp.Competitor__c = previousOpp.Competitor__c;
        if(defaultOpp.Sold_To_Country__c == null && !doesSoldToCountryHasHistory)
            defaultOpp.Sold_To_Country__c = previousOpp.Sold_To_Country__c;
        if(defaultOpp.BusinessPartner__c == null && !doesBusinessPartnerHasHistory)
            defaultOpp.BusinessPartner__c = previousOpp.BusinessPartner__c;
        if(defaultOpp.StageName == null && !doesStageNameHasHistory)
            defaultOpp.StageName = previousOpp.StageName;
        if(defaultOpp.Type == null && !doesTypeHasHistory)
            defaultOpp.Type = previousOpp.Type;
        if(defaultOpp.Win_Loss_Status__c == null && !doesWinLossReasonHasHistory)
            defaultOpp.Win_Loss_Status__c = previousOpp.Win_Loss_Status__c;
        if(defaultOpp.Primary_Line_of_Business__c == null && !doesPrimaryLineOfBusinessHasHistory)
            defaultOpp.Primary_Line_of_Business__c = previousOpp.Primary_Line_of_Business__c;  
        if(defaultOpp.ownerId == null && !doesOwnerIdHasHistory)
            defaultOpp.ownerId = previousOpp.ownerId;  
        if(defaultOpp.Opportunity_Status__c == null && !doesOpportunityStatusHasHistory)
            defaultOpp.Opportunity_Status__c = previousOpp.Opportunity_Status__c;  
        if(defaultOpp.WonLostCancelledReason__c == null && !doesWonLostCancelledReasonHasHistory)
            defaultOpp.WonLostCancelledReason__c = previousOpp.WonLostCancelledReason__c;  
                  
        return defaultOpp;
    }
    
    private static Opportunity populateOpportunityFields(wrapperOppFieldHisotry oppFieldHistory, Opportunity opp, Boolean isFirstRecord){
        System.debug('NKC debug oppFieldHistory.NewValue ['+oppFieldHistory.NewValue+']');
        System.debug('NKC debug oppFieldHistory.Field ['+oppFieldHistory.Field+']');
        /*
        if(oppFieldHistory.Field == 'Account' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && String.valueOf(oppFieldHistory.NewValue).startsWith('001') && (!isFirstRecord || opp.AccountId == null))
            opp.AccountId = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Amount' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Amount == null))
            opp.Amount = Double.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'CloseDate' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.CloseDate == null))
            opp.CloseDate = Date.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Country__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('a06') && (!isFirstRecord || opp.Country__c == null))
            opp.Country__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Description' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Description == null))
            opp.Description = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'ForecastStatus__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.ForecastStatus__c == null))
            opp.ForecastStatus__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'License_Amount__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.License_Amount__c == null))
            opp.License_Amount__c = Double.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Maintenance_Amount__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Maintenance_Amount__c == null))
            opp.Maintenance_Amount__c = Double.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'ACV_Subscription_Only__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.ACV_Subscription_Only__c == null))
            opp.ACV_Subscription_Only__c = Double.valueOf(oppFieldHistory.NewValue);        
        else if(oppFieldHistory.Field == 'Lines_of_Businesses__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Lines_of_Businesses__c == null))
            opp.Lines_of_Businesses__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Competitor__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Competitor__c == null))
            opp.Competitor__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'WonLostCancelledReason__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.WonLostCancelledReason__c == null))
            opp.WonLostCancelledReason__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Sold_To_Country__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('a06') && (!isFirstRecord || opp.Sold_To_Country__c == null))
            opp.Sold_To_Country__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'BusinessPartner__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('001') && (!isFirstRecord || opp.BusinessPartner__c == null))
            opp.BusinessPartner__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'StageName' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.StageName == null))
            opp.StageName = String.valueOf(oppFieldHistory.NewValue);        
        else if(oppFieldHistory.Field == 'Type' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Type == null))
            opp.Type = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Win_Loss_Status__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Win_Loss_Status__c == null))
            opp.Win_Loss_Status__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Primary_Line_of_Business__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Primary_Line_of_Business__c == null))
            opp.Primary_Line_of_Business__c = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Owner' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('005') && (!isFirstRecord || opp.Owner == null))
            opp.OwnerId = String.valueOf(oppFieldHistory.NewValue);
        else if(oppFieldHistory.Field == 'Opportunity_Status__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Opportunity_Status__c == null))
            opp.Opportunity_Status__c = String.valueOf(oppFieldHistory.NewValue); 
        */ 
        System.debug('NKC debug opp.AccountId [' + opp.AccountId + ']');
        if(oppFieldHistory.Field == 'Account' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && String.valueOf(oppFieldHistory.NewValue).startsWith('001') && (!isFirstRecord || opp.AccountId == null))
            opp.AccountId = String.valueOf(oppFieldHistory.NewValue);
        System.debug('NKC debug opp.AccountId [' + opp.AccountId + ']');
        if(oppFieldHistory.Field == 'Amount' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Amount == null))
            opp.Amount = Double.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'CloseDate' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.CloseDate == null))
            opp.CloseDate = Date.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Country__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('a06') && (!isFirstRecord || opp.Country__c == null))
            opp.Country__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Description' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Description == null))
            opp.Description = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'ForecastStatus__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.ForecastStatus__c == null))
            opp.ForecastStatus__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'License_Amount__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.License_Amount__c == null))
            opp.License_Amount__c = Double.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Maintenance_Amount__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Maintenance_Amount__c == null))
            opp.Maintenance_Amount__c = Double.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'ACV_Subscription_Only__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.ACV_Subscription_Only__c == null))
            opp.ACV_Subscription_Only__c = Double.valueOf(oppFieldHistory.NewValue);        
        if(oppFieldHistory.Field == 'Lines_of_Businesses__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Lines_of_Businesses__c == null))
            opp.Lines_of_Businesses__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Competitor__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.Competitor__c == null))
            opp.Competitor__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'WonLostCancelledReason__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.WonLostCancelledReason__c == null))
            opp.WonLostCancelledReason__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Sold_To_Country__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('a06') && (!isFirstRecord || opp.Sold_To_Country__c == null))
            opp.Sold_To_Country__c = String.valueOf(oppFieldHistory.NewValue);
        System.debug('NKC debug isFirstRecord ['+isFirstRecord+'] in');
        if(oppFieldHistory.Field == 'BusinessPartner__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('001') && (!isFirstRecord || opp.BusinessPartner__c == null)){
            opp.BusinessPartner__c = String.valueOf(oppFieldHistory.NewValue);
            System.debug('NKC debug opp.BusinessPartner__c ['+opp.BusinessPartner__c+'] in');
        }
        if(oppFieldHistory.Field == 'StageName' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != '' 
            && (!isFirstRecord || opp.StageName == null))
            opp.StageName = String.valueOf(oppFieldHistory.NewValue);        
        if(oppFieldHistory.Field == 'Type' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Type == null))
            opp.Type = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Win_Loss_Status__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Win_Loss_Status__c == null)){
            opp.Win_Loss_Status__c = String.valueOf(oppFieldHistory.NewValue);
            System.debug('NKC debug opp.Win_Loss_Status__c ['+opp.Win_Loss_Status__c+'] in');
        }
        if(oppFieldHistory.Field == 'Primary_Line_of_Business__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Primary_Line_of_Business__c == null))
            opp.Primary_Line_of_Business__c = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Owner' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
            && String.valueOf(oppFieldHistory.NewValue).startsWith('005') && (!isFirstRecord || opp.Owner == null))
            opp.OwnerId = String.valueOf(oppFieldHistory.NewValue);
        if(oppFieldHistory.Field == 'Opportunity_Status__c' && oppFieldHistory.NewValue != null && oppFieldHistory.NewValue != ''
             && (!isFirstRecord || opp.Opportunity_Status__c == null))
            opp.Opportunity_Status__c = String.valueOf(oppFieldHistory.NewValue);  
        opp.CreatedDate = oppFieldHistory.CreatedDate;
        return opp;
    }
    
    private static List<wrapperOppFieldHisotry> populateOppFieldHistoryWrapper(Id opportunityId){
        List<wrapperOppFieldHisotry> newList = new List<wrapperOppFieldHisotry>();
        List<OpportunityFieldHistory> listOfOppFieldHistory;
        if(Test.isRunningTest()){
            newList.add(new wrapperOppFieldHisotry('Account', 'value1', 'value2', System.today()));    
            newList.add(new wrapperOppFieldHisotry('Account', 'value2', 'value3', System.today()));    
            newList.add(new wrapperOppFieldHisotry('Amount', '1000', '2000', System.today()));
            newList.add(new wrapperOppFieldHisotry('Amount', '2000', '3000', System.today()));
            newList.add(new wrapperOppFieldHisotry('CloseDate', '2016-11-01', '2016-11-02', System.today()));
            newList.add(new wrapperOppFieldHisotry('CloseDate', '2016-11-02', '2016-11-03', System.today()));
            newList.add(new wrapperOppFieldHisotry('Country__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Country__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Description', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Description', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('ForecastStatus__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('ForecastStatus__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('License_Amount__c', '1000', '2000', System.today()));
            newList.add(new wrapperOppFieldHisotry('License_Amount__c', '2000', '3000', System.today()));
            newList.add(new wrapperOppFieldHisotry('Maintenance_Amount__c', '1000', '2000', System.today()));
            newList.add(new wrapperOppFieldHisotry('Maintenance_Amount__c', '2000', '3000', System.today()));
            newList.add(new wrapperOppFieldHisotry('ACV_Subscription_Only__c', '1000', '2000', System.today()));
            newList.add(new wrapperOppFieldHisotry('ACV_Subscription_Only__c', '2000', '3000', System.today()));
            newList.add(new wrapperOppFieldHisotry('Lines_of_Businesses__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Lines_of_Businesses__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Competitor__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Competitor__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('WonLostCancelledReason__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('WonLostCancelledReason__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Sold_To_Country__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Sold_To_Country__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('BusinessPartner__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('BusinessPartner__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('StageName', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('StageName', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('TypeType', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Type', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Win_Loss_Status__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Win_Loss_Status__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Primary_Line_of_Business__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Primary_Line_of_Business__c', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Owner', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Owner', 'value2', 'value3', System.today()));
            newList.add(new wrapperOppFieldHisotry('Opportunity_Status__c', 'value1', 'value2', System.today()));
            newList.add(new wrapperOppFieldHisotry('Opportunity_Status__c', 'value2', 'value3', System.today()));
        }
        else{
            listOfOppFieldHistory = [SELECT Field, NewValue, OldValue, CreatedDate 
                FROM OpportunityFieldHistory WHERE opportunityId =: opportunityId ORDER BY CreatedDate];
            Set<String> setOfAccountIds = new Set<String>();
            Set<String> setOfCountryIds = new Set<String>();
            Set<String> setOfUserIds = new Set<String>();
            for(OpportunityFieldHistory eachFieldHistory : listOfOppFieldHistory){
                if(eachFieldHistory.newValue != null){
                    if(String.valueOf(eachFieldHistory.newValue).startsWith('001')){
                        setOfAccountIds.add(String.valueOf(eachFieldHistory.newValue)); 
                    }
                    else if(String.valueOf(eachFieldHistory.newValue).startsWith('a06')){
                        setOfCountryIds.add(String.valueOf(eachFieldHistory.newValue)); 
                    } 
                    else if(String.valueOf(eachFieldHistory.newValue).startsWith('005')){
                        setOfUserIds.add(String.valueOf(eachFieldHistory.newValue));    
                    }
                }
                if(eachFieldHistory.oldValue != null){
                    if(String.valueOf(eachFieldHistory.oldValue).startsWith('001')){
                        setOfAccountIds.add(String.valueOf(eachFieldHistory.oldValue)); 
                    }
                    else if(String.valueOf(eachFieldHistory.oldValue).startsWith('a06')){
                        setOfCountryIds.add(String.valueOf(eachFieldHistory.oldValue)); 
                    } 
                    else if(String.valueOf(eachFieldHistory.oldValue).startsWith('005')){
                        setOfUserIds.add(String.valueOf(eachFieldHistory.oldValue));    
                    }
                }
            }
            
            Map<Id, Account> mapOfAccounts = new Map<Id, Account>([SELECT id FROM Account WHERE id IN : setOfAccountIds]);    
            Map<Id, Country__c> mapOfCountries = new Map<Id, Country__c>([SELECT id FROM Country__c WHERE id IN : setOfAccountIds]);
            Map<Id, User> mapOfUsers = new Map<Id, User>([SELECT id FROM User WHERE id IN : setOfAccountIds]);
            
            for(OpportunityFieldHistory eachFieldHistory : listOfOppFieldHistory){
                            
                if(eachFieldHistory.newValue != null){
                    if(String.valueOf(eachFieldHistory.newValue).startsWith('001')){
                        if(mapOfAccounts.get(String.valueOf(eachFieldHistory.newValue)) == null)
                            continue;       
                    }
                    else if(String.valueOf(eachFieldHistory.newValue).startsWith('a06')){
                        if(mapOfCountries.get(String.valueOf(eachFieldHistory.newValue)) == null)
                            continue;   
                    } 
                    else if(String.valueOf(eachFieldHistory.newValue).startsWith('005')){
                        if(mapOfUsers.get(String.valueOf(eachFieldHistory.newValue)) == null)
                            continue;   
                    }   
                }
                
                if(eachFieldHistory.oldValue != null){
                    if(String.valueOf(eachFieldHistory.oldValue).startsWith('001')){
                        if(mapOfAccounts.get(String.valueOf(eachFieldHistory.oldValue)) == null)
                            continue;       
                    }
                    else if(String.valueOf(eachFieldHistory.oldValue).startsWith('a06')){
                        if(mapOfCountries.get(String.valueOf(eachFieldHistory.oldValue)) == null)
                            continue;   
                    } 
                    else if(String.valueOf(eachFieldHistory.oldValue).startsWith('005')){
                        if(mapOfUsers.get(String.valueOf(eachFieldHistory.oldValue)) == null)
                            continue;   
                    }   
                }
                wrapperOppFieldHisotry newItem = new wrapperOppFieldHisotry();
                newItem.field = eachFieldHistory.Field;
                newItem.newValue = String.valueOf(eachFieldHistory.NewValue);
                newItem.oldValue = String.valueOf(eachFieldHistory.OldValue);
                newItem.createdDate = eachFieldHistory.CreatedDate;
                newList.add(newItem);
            }
        }
        return newList;
    } 
    
    private class wrapperOppFieldHisotry{
        public String field {get;set;}
        public String newValue {get;set;}
        public String oldValue {get;set;}
        public DateTime createdDate {get;set;}   
        public wrapperOppFieldHisotry(){
            
        }
        public wrapperOppFieldHisotry(String field, String newValue, String oldValue, DateTime createdDate){
            this.field = field;
            this.newValue = newValue;
            this.oldValue = oldValue;
            this.createdDate = createdDate;
        }
    }
    
}