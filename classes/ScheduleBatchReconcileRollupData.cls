global class ScheduleBatchReconcileRollupData  implements Schedulable {
    
    global void execute(SchedulableContext sc) 
    {
        // Invoke batch Job to process Usage Data
        Integer intReconcileBatchSize = Integer.valueOf(Label.Billing_Reconcile_Batch_Size);
        Database.executeBatch(new BatchReconcileRollupData(),intReconcileBatchSize);
    }
    
}