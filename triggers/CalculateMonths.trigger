trigger CalculateMonths on Quote_Period__c (before insert,before update) 
{
    for(Quote_Period__c objQuotePeriod : Trigger.new)
    {
        if(objQuotePeriod.Start_Date__c != null && objQuotePeriod.End_Date__c != null)
        {
            if(Trigger.IsInsert)
                objQuotePeriod.Months__c = Util.calculateDurationInMonths(objQuotePeriod.Start_Date__c,objQuotePeriod.End_Date__c);
            
            else if(objQuotePeriod.Start_Date__c != Trigger.oldMap.get(objQuotePeriod.Id).Start_Date__c ||
                    objQuotePeriod.End_Date__c != Trigger.oldMap.get(objQuotePeriod.Id).End_Date__c)
                objQuotePeriod.Months__c = Util.calculateDurationInMonths(objQuotePeriod.Start_Date__c,objQuotePeriod.End_Date__c);
        }
    }
}