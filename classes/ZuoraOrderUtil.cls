public without sharing class ZuoraOrderUtil {

	// Zuora customer account ID from the Quote
	// If this has a value an amendment is created for the customer account
	// If there is no value a new customer account and new subscription are created
	public String zAccountId
	{
		get
		{
			if(String.isNotEmpty(this.zQuote.zqu__ZuoraAccountID__c))
			{
				return this.zQuote.zqu__ZuoraAccountID__c;
			}
			else
			{
				return 'New';
			}
		}
	}

	private zqu__Quote__c zQuote;

	// Constructor
	public ZuoraOrderUtil(zqu__Quote__c zQuote)
	{
		this.zQuote = zQuote;
	}

	public void sendToZBilling()
	{
		ZuoraOrderUtil.sendToZBilling(JSON.serialize(this.zQuote), this.zAccountId);
	}

	@InvocableMethod(label='Send to Z-Billing' description='Makes a callout to Zuora cloud creating a new subscription or amendment to a subscription')
	public static void sendToZBilling(List<zqu__Quote__c> zQuotes)
	{
		for(zqu__Quote__c zQuote : zQuotes)
		{
			ZuoraOrderUtil orderUtil = new ZuoraOrderUtil(zQuote);
			orderUtil.sendToZBilling();
		}
	}

	@future (callout=true)
	private static void sendToZBilling(String zQuoteJson, String zAccountId)
	{
		zqu__Quote__c zQuote = (zqu__Quote__c)JSON.deserialize(zQuoteJson, zqu__Quote__c.class);
		List<PCOrder_Subscription_Logs__c> PClogs = new List<PCOrder_Subscription_Logs__c>();
        PCOrder_Subscription_Logs__c PClog;
        
        boolean isSuccessful = false;
        Map<String, String> zuoraResult = new Map<String, String>();

		try
		{			
			// Send the quote to Zuora's Cloud Tenant			
			if(!Test.isRunningTest())
            {
                zuoraResult = zqu.zQuoteUtil.sendToZBilling(zQuote.Id, zAccountId, false, null, null);
            }
            else
            {
                if(String.isNotBlank(zQuote.Id))
                {
                    zuoraResult.put('Success', 'Success');
                }
            } 
		}
		catch (Exception e)
		{
			PClog = new PCOrder_Subscription_Logs__c();
            PCLog.Name = 'Zuora Call for - ' + zQuote.Id;
            PCLog.Quote__c = zQuote.Id;
            PClog.Message_Type__c = 'Send to Z Billing callout Exception';
            PClog.Request_Details__c = 'Quote is sent to ZBilling, with Id - ' + zQuote.Id + '. And with ' + zAccountId + ' Zuora Billing Account';
            PClog.Result_Message__c = 'Exception Occured while sending the Quote to Z Billing. Message - ' + e.getMessage() + '\n Stack Trace - ' + e.getStackTraceString();
            PClog.Is_Request_Successful__c = false;
            PClog.Log_Type__c = 'Error';
            PClog.Date_Submitted__c = Datetime.now();
            PClogs.add(PClog);

			zQuote.zqu__Status__c = 'Failed to Send';			
		}
        
        String resultString = '';
        if(zuoraResult != null && zuoraResult.size() > 0)
        {
            for (String result : zuoraResult.keySet()) 
            { 
                System.debug('## ZuoraResult Key - ' + result);
                System.debug('## ZuoraResult Value - ' + zuoraResult.get(result));
                resultString += '\n ' + result + ' with Msg - ' + zuoraResult.get(result); 
            }
        }

        if (zuoraResult != null && !zuoraResult.containsKey('Success'))
        {     
			PClog = new PCOrder_Subscription_Logs__c();
			PCLog.Name = 'Zuora Call for - ' + zQuote.Id;
			PCLog.Quote__c = zQuote.Id;
			PClog.Message_Type__c = 'After - Send to Z Billing callout - Failure';
			PClog.Request_Details__c = 'Sending to ZBilling Quote with Id - ' + zQuote.Id + '. And with ' + zAccountId + ' Zuora Billing Account';
			PClog.Result_Message__c = resultString;
			PClog.Is_Request_Successful__c = false;
			PClog.Log_Type__c = 'Error';
			PClog.Date_Submitted__c = Datetime.now();
			PClogs.add(PClog);

			// Update Quote Fields            
            zQuote.zqu__Status__c = 'Failed to Send';
        }          
        else if(zuoraResult != null)
        { 
            isSuccessful = true;
            PClog = new PCOrder_Subscription_Logs__c();
            PCLog.Name = 'Zuora Call for - ' + zQuote.Id;
            PCLog.Quote__c = zQuote.Id;
            PClog.Message_Type__c = 'After - Send to Z Billing callout - Successful';
            PClog.Request_Details__c = 'Sending to ZBilling Quote with Id - ' + zQuote.Id + '. And with ' + zAccountId + ' Zuora Billing Account';
            PClog.Result_Message__c = resultString;
            PClog.Is_Request_Successful__c = true;
            PClog.Log_Type__c = 'Success';
            PClog.Date_Submitted__c = Datetime.now();
            PClogs.add(PClog);

			// Update Quote Fields
			// This field needs to be set to false to prevent a validation message from appearing on the quote after it is sent to Zuora
			// The validation error doesn't prevent any functionality, it just looks bad to the user
			zQuote.zqu__Is_Charge_Expired__c = false;           
        }

		try
		{
			update zQuote;
		}
		catch (Exception e)
		{
			PClog = new PCOrder_Subscription_Logs__c();
			PCLog.Name = 'Zuora Call for - ' + zQuote.Id;
			PCLog.Quote__c = zQuote.Id;
			PClog.Message_Type__c = 'UpdateAfterZuoraCallout Method Call';
			PClog.Request_Details__c = 'Call to Update Quote Fields after Zuora call with ExternalId to be -' + resultString + '. And with ' + zAccountId + ' Billing Account'; // TO DO - UPDATE MSG
			PClog.Result_Message__c = 'Exception Occured during UpdateAfterZuoraCallout Method Call. Message - ' + e.getMessage() + '\n Stack Trace - ' + e.getStackTraceString();
			PClog.Is_Request_Successful__c = false;
			PClog.Log_Type__c = 'Error';
			PClog.Date_Submitted__c = Datetime.now();
			PClogs.add(PClog);  
		}
        
        insert PClogs;
    }
}