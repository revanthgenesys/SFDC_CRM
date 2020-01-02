public class QuoteAmendmentValidatorController {
    
    public zqu__Quote__c quote {get;set;}
    static final String AMENDMENT_QUOTE = 'Amend Subscription';

    public Boolean isZuoraSubscriptionRenewed {get;set;}
    public Boolean disableUpdate {get;set;}

    private String currentSubscriptionId;
    private Zuora.zApi zApiInstance;
    private ZObject latestSubscription;
    private PageReference quoteSubmitPageRef;

    public QuoteAmendmentValidatorController(ApexPages.StandardController stdController) 
    {
        String quoteId = stdController.getId();

        // Page doesn't reference the fields required - query quote
        List < Zqu__Quote__c > quotes = [SELECT id, Name, zqu__ExistSubscriptionID__c, zqu__SubscriptionType__c FROM zqu__Quote__c WHERE id = :quoteId limit 1];
        if (quotes.size() > 0) 
        {
            this.quote = quotes.get(0);
            quoteSubmitPageRef = Page.zqu__ZQAmendmentPreview;
            quoteSubmitPageRef.getParameters().put('id', this.quote.Id);
            quoteSubmitPageRef.getParameters().put('scontrolCaching', '1');
        }
        else 
        {
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: Cannot load Quote.');
            ApexPages.addMessage(message);
        }

        isZuoraSubscriptionRenewed = false;
        disableUpdate = false;
    }

    public PageReference onload() 
    {
        try 
        {
            if (this.quote != null) 
            {
                zApiInstance = new Zuora.zApi();
                if (!Test.isRunningTest()) 
                {
                    zApiInstance.zlogin();
                }

                String amendedSubscriptionId = this.quote.zqu__ExistSubscriptionId__c;
                String quoteType = this.quote.zqu__SubscriptionType__c;

                if (quoteType == AMENDMENT_QUOTE)
                {
                    validateLatestSubscription(amendedSubscriptionId);
                }
            }
        }
        catch (Exception e) 
        {
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage());
            ApexPages.addMessage(message);
        }

        return null;
    }

    public PageReference updateQuoteSubscriptionVersion() 
    {
        try 
        {
            DateTime termStartDate = latestSubscription.TermStartDate;
            String latestSubscriptionId = latestSubscription.Id;
            System.debug('ZuoraDebug## termStartDate = ' + termStartDate + ', latestSubscriptionId = ' + latestSubscriptionId);
            this.quote.zqu__StartDate__c = termStartDate.date();
            this.quote.zqu__ExistSubscriptionId__c = latestSubscriptionId;
            upsert quote;
        }
        catch (Exception e) 
        {
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating the quote: ' + e.getMessage());
            ApexPages.addMessage(message);
            return null;
        }

        return this.quoteSubmitPageRef;
    }

    public PageReference cancel() 
    {
        PageReference pageRef = new PageReference('/' + this.quote.Id);
        return pageRef;
    }

    public void validateLatestSubscription(String subscriptionId) 
    {
        List<ZObject> zObjects;
        Zuora.zObject amendment;
        ZObject subscription;

        String zoqlSubName = 'Select Name, Version, Status from Subscription where Id = \'' + subscriptionId + '\'';

        if (!Test.isRunningTest()) 
        {
            zObjects = ZObject.getZObjects(this.zApiInstance.zquery(zoqlSubName));
        }
        else 
        {
            zObjects = QuoteAmendmentValidatorControllerTest.createMockSubscription();
        }
        system.debug(zObjects);
        if (zObjects.size() == 1) 
        {
            subscription = zObjects[0];
        }
        //String subscriptionName = (String) subscription.getValue('Name');
        //String status = (String) subscription.getValue('Status');
        //Integer currentVersion = (Integer) subscription.getValue('Version'); 
        String subscriptionName = subscription.Name;
        String status = subscription.Status;
        Integer currentVersion = subscription.Version;

        System.debug('ZuoraDebug## subscriptionName = ' + subscriptionName + ', status = ' + status + ', currentVersion = ' + currentVersion);

        List < String > subscriptionIdList = new List < String > ();

        if (status == 'Expired')
        {
            // The subscription has already been amended
            String zoqlGetSubscriptions = 'Select Id, Version, TermStartDate from Subscription where Name = \'' + subscriptionName + '\'';
            if (!Test.isRunningTest()) 
            {
                zObjects = ZObject.getZObjects(this.zApiInstance.zquery(zoqlGetSubscriptions));
            }
            else 
            {
                zObjects = QuoteAmendmentValidatorControllerTest.createMockSubscriptions();
            }

            Integer maxVersion = 1;
            if (zObjects.size() > 0) 
            {
                // Add each subscription amendment that is greater than the version on the quote
                for (ZObject sub : zObjects) 
                {
                    Integer version = sub.Version;
                    if (version > maxVersion) 
                    {
                        latestSubscription = sub;
                        maxVersion = version;
                    }
                    if (version >= currentVersion) 
                    {
                        subscriptionIdList.add(sub.Id);
                    }
                }
            }

            // Now check from the current subscription version to the latest version, whether the amendments are all of Renewal Type.
            String zoqlAmendments = 'Select Id, Type from Amendment where ';
            for (String subId : subscriptionIdList) 
            {
                zoqlAmendments += 'SubscriptionId = \'' + subscriptionId + '\' or ';
            }

            System.debug('ZuoraDebug## zoqlAmendment = ' + zoqlAmendments);
            zoqlAmendments = zoqlAmendments.substring(0, zoqlAmendments.length() - 3);

            if (!Test.isRunningTest()) 
            {
                zObjects = ZObject.getZObjects(this.zApiInstance.zquery(zoqlAmendments));
            }
            else 
            {
                zObjects = QuoteAmendmentValidatorControllerTest.createMockAmendments(quote.Name);
            }

            boolean allRenewals = true;

            for (ZObject zObject : zObjects) 
            {
                String type = zObject.Type;
                if (type != 'Renewal') 
                {
                    allRenewals = false;
                    disableUpdate = true;
                    ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, 'There has been a non-renewal type amendment since the quote was created. Cannot submit');
                    ApexPages.addMessage(message);
                    break;
                }
            }

            this.isZuorasubscriptionRenewed = allRenewals;
        }
        else 
        {
            System.debug('ZuoraDebug## The current subscription is the latest version.  Redirecting to ZuoraQuoteSubmit...');
            this.isZuorasubscriptionRenewed = false;
        }
    }
}