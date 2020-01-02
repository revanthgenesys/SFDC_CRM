global class ScheduleBatchRateCloudUsageData implements Schedulable
{
    global void execute(SchedulableContext sc) 
	{
        // Invoke batch Job to process Usage Data
        BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
        Integer intRatingBatchSize = Integer.valueOf(Label.Billing_Rating_Batch_Size);
        Database.executeBatch(objBatch,intRatingBatchSize);
    }
}