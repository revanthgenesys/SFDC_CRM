global without sharing class SMLCreateSMLDataSnapshotsBatchSchedular implements Schedulable {

    global void execute(SchedulableContext schedulableContext) {
        SMLCreateSMLDataSnapshotsBatch snapShotBatch = new SMLCreateSMLDataSnapshotsBatch('SELECT id FROM Account WHERE (RecordType.DeveloperName = \'EMGCustomerRecordType\' AND Status__c = \'Active\') OR (Type = \'Prospect\' AND Account_Segmentation__c LIKE \'%Logo%\')', false);
        if(!Test.isRunningTest())    
            database.executebatch(snapShotBatch, 10);
    }
}