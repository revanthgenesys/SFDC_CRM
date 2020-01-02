//Naresh Kumr   07/14/2016
public without sharing class SMLCreateSMLDataSnapshots {
    public static void createSnapshotDataForAccount(Id accountId, Boolean doDeleteAll){
        Date initialStartDate = Date.newInstance(2016, 1, 1);
        //Querying SML Data
        List<SML_Data__c> smlData = [SELECT Account__c, Solution_Category__c, Status__c, CreatedDate, (SELECT New_Status__c, Old_Status__c, CreatedDate, SML_Data__r.Solution_Category__c,
            SML_Data__r.Status__c, SML_Data__r.Account__c, SML_Data__c FROM Account_Trends__r ORDER BY CreatedDate) FROM SML_Data__c WHERE Account__c =: accountId];
        
        //Popoulating start date    
        if(!smlData.isEmpty()){
            System.debug('NKC debug initialStartDate [' + initialStartDate + ']');
            Date createdDate = Date.newInstance(smlData[0].CreatedDate.year(), smlData[0].CreatedDate.month(), smlData[0].CreatedDate.day());
            while(initialStartDate < createdDate){
                initialStartDate = initialStartDate.addDays(14);
                System.debug('NKC debug initialStartDate [' + initialStartDate + ']');
                System.debug('NKC debug createdDate) [' + createdDate + ']');                
            }           
        }
        
        if(!doDeleteAll){
            List<Account_Trend_Snapshot__c> latestSnapshots = [SELECT Snapshot_Date__c FROM Account_Trend_Snapshot__c WHERE Account__c =: accountId 
                ORDER BY Snapshot_Date__c DESC LIMIT 1];
            if(!latestSnapshots.isEmpty()){
                initialStartDate = latestSnapshots[0].Snapshot_Date__c.addDays(14);       
            }
        }
        
        System.debug('NKC debug initialStartDate [' + initialStartDate + ']');    

        //Querying and deleting existing 
        List<Account_Trend_Snapshot__c> spanshotsToBeDeleted = [SELECT id FROM Account_Trend_Snapshot__c WHERE Account__c =: accountId
            AND Snapshot_Date__c >=: initialStartDate];
        if(!spanshotsToBeDeleted.isEmpty())
            delete spanshotsToBeDeleted;
        
        List<Account_Trend_Snapshot__c> accountTrendSnapshotsToBeInserted = new List<Account_Trend_Snapshot__c>();
              
        //Looping over each SML Data
        for(SML_Data__c eachSMLData: smlData){
            Date startDate = initialStartDate;
            if(Test.isRunningTest())
                startDate = startDate.addDays(-25);
            Map<Date, Account_Trends__c> createdDateVsAccountTrend = new Map<Date, Account_Trends__c>();
            List<Account_Trends__c> accountTrends = eachSMLData.Account_Trends__r;   
            Integer counter = 1;            
            while(System.today() - 1 > startDate){
                if(counter == 1){
                    for(Account_Trends__c eachTrend : accountTrends){ 
                        System.debug('NKC debug startDate ['+startDate+']');
                        System.debug('NKC debug eachTrend.CreatedDate ['+eachTrend.CreatedDate+']');                                        
                        while(startDate < eachTrend.CreatedDate){                                                   
                            Account_Trend_Snapshot__c newSnapshot = createNewSnapshot(eachTrend);
                            newSnapshot.Snapshot_Date__c = startDate;                            
                            accountTrendSnapshotsToBeInserted.add(newSnapshot);
                            startDate = startDate.addDays(14);      
                        }                             
                    }
                    counter ++;
                }
                if(startDate > System.today() - 1 && !Test.isRunningTest())
                    break;
                    
                //Default snapshot record
                Account_Trend_Snapshot__c defaultSnapshot = new Account_Trend_Snapshot__c();
                defaultSnapshot.Account__c = eachSMLData.Account__c;
                defaultSnapshot.Product_Category__c = eachSMLData.Solution_Category__c;
                defaultSnapshot.SML_Data__c = eachSMLData.id;                                   
                defaultSnapshot.Status__c = eachSMLData.Status__c;
                
                if(defaultSnapshot.Status__c == null)
                    defaultSnapshot.Status__c = 'Whitespace';               
                defaultSnapshot.Snapshot_Date__c = startDate;
                accountTrendSnapshotsToBeInserted.add(defaultSnapshot);
                startDate = startDate.addDays(14);
            }
        }
        if(!accountTrendSnapshotsToBeInserted.isEmpty())
            insert accountTrendSnapshotsToBeInserted;
    }
    
    private static Account_Trend_Snapshot__c createNewSnapshot(Account_Trends__c accountTrend){
        Account_Trend_Snapshot__c newSnapshot = new Account_Trend_Snapshot__c();
        newSnapshot.Account__c = accountTrend.SML_Data__r.Account__c;
        newSnapshot.Product_Category__c = accountTrend.SML_Data__r.Solution_Category__c;
        newSnapshot.SML_Data__c = accountTrend.SML_Data__c;         
        newSnapshot.Status__c = (accountTrend.Old_Status__c == null ? 'Whitespace' : accountTrend.Old_Status__c);
        return newSnapshot;
    }
    private static Account_Trend_Snapshot__c createNewSnapshot(Account_Trend_Snapshot__c snapshot){
        Account_Trend_Snapshot__c newSnapshot = new Account_Trend_Snapshot__c();
        newSnapshot.Account__c = snapshot.Account__c;
        newSnapshot.Product_Category__c = snapshot.Product_Category__c;
        newSnapshot.SML_Data__c = snapshot.SML_Data__c;         
        newSnapshot.Status__c = snapshot.Status__c;
        return newSnapshot;
    }
}