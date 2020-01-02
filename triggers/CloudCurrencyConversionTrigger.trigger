trigger CloudCurrencyConversionTrigger on Cloud_Currency_Conversion__c (before insert, before update) {
    if(Util.Bypass_Trigger_Chk)return;
    
    private Date startOfMonth(Date d) {
        return d.toStartOfMonth();
    }
    Set<String> setCurrencyIsoCode = new Set<String>();
    for (Cloud_Currency_Conversion__c ccc : Trigger.new) {
        setCurrencyIsoCode.add(ccc.IsoCode__c);
    }
    List<Cloud_Currency_Conversion__c> listExistingCurrencyConversions =
        [select Id, IsoCode__c, StartDate__c, NextStartDate__c
         from Cloud_Currency_Conversion__c
         where IsoCode__c in :setCurrencyIsoCode];
    System.debug('listExistingCurrencyConversions: existing conversion list size ' + listExistingCurrencyConversions.size());
    
    //Map<String, List<Cloud_Currency_Conversion__c>> mapCurrencyIsoCode = new Map<String, List<Cloud_Currency_Conversion__c>>();
    
    // Set all dates to the 1st of the month to make sure all currencies conform to a month to month boundary.
    // Make Sure Start comes before Next.
    for (Cloud_Currency_Conversion__c ccc : Trigger.new) {
        
        ccc.StartDate__c = startOfMonth(ccc.StartDate__c);
        ccc.NextStartDate__c = startOfMonth(ccc.NextStartDate__c);
        
        if (ccc.StartDate__c >= ccc.NextStartDate__c) {
            ccc.addError('CloudCurrencyConversionTrigger: StartDate must be before NextStartDate');
        }

        // Loop through existing currencies to make sure there is no overlap of dates.
        // After this, add the new value to the existing currencies in case there are more currencies updated/inserted simultaneously
        for (Cloud_Currency_Conversion__c cccExisting : listExistingCurrencyConversions) {
            System.debug('CloudCurrencyConversionTrigger: Compare ccc ' + ccc.id + ' cccExisting ' + cccExisting.Id);
            // Don't compare against itself
            if (ccc.Id != cccExisting.Id) {
                if (CloudBillingUtil.blnDatesOverlap(ccc.StartDate__c, ccc.NextStartDate__c, cccExisting.StartDate__c, cccExisting.NextStartDate__c)) {
                    System.debug('CloudCurrencyConversionTrigger: blnDatesOverlap says overlap!!');
                    String strError = 'Start Date End Date conflicts with another currency with same Currence ISO';
                    System.Debug('CloudCurrencyConversionTrigger: ' + strError);
                    ccc.addError(strError);
                }
            } else {
                System.Debug('CloudCurrencyConversionTrigger: Updating existing, check date');
                Date dtOldEndDate = cccExisting.NextStartDate__c; dtOldEndDate = dtOldEndDate.addMonths(1);
                Date dtMaxDate = Date.today().toStartOfMonth();
                System.debug('CloudCurrencyConversionTrigger: Compare Dates dtOldEndDate:' + dtOldEndDate + ' dtMaxDate:' + dtMaxDate);
                if (dtMaxDate >= dtOldEndDate) {
                    ccc.addError('Cannot change old record as end date older than one month');
                } else {
	                System.Debug('CloudCurrencyConversionTrigger: Comparing against self, ignore');
                }
            }
        }
    }
}