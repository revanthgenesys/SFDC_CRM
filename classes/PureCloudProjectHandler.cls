public without sharing class PureCloudProjectHandler {

    public static void BeforeInsert(List<PureCloud_Trial__c> newPCProjects)
    {
        PureCloudProjectHandler handler = new PureCloudProjectHandler(newPCProjects);
        //Default the email readiness flag to false
        handler.readyForEmail = false;
            
        for(PureCloud_Trial__c currPCProj : newPCProjects)
        {
            handler.currPCProject = currPCProj;
            //Service Packages field should be auto-populated before the email gets sent.
            handler.UpdateServicePackagesField();
            
            //NOTE: Set the readyForEmail flag to true only after all the logic (present and future) for autopopulation is done before the Email is sent out
            handler.readyForEmail = true;
            handler.SetEmailStatus();
        }
        
        // Make sure the PureCloud Project creation includes the Quote Id into the new lookup field during creation (process builder)
        // Get all the Quote Line items and check for all Services and populate the picklist options on the "Service Package" field
        // Once this field is successfully updated, set the Email Status to "Pending" (This field should trigger the email being sent, its a workflow that needs updating)
    }
    
    public List<PureCloud_Trial__c> pcProjects;
    public PureCloud_Trial__c currPCProject;
    
    private boolean readyForEmail {get; set;}
     
    private Set<Id> QuoteIds
  {
    get
    {
          //System.debug('PureCloudProjectHandler --> QuotesMap');
            if (QuoteIds == null)
      {
                QuoteIds = new Set<Id>();
        for(PureCloud_Trial__c pcProject : pcProjects)
                {
                    QuoteIds.add(pcProject.Quote__c);
                }
      }
      return QuoteIds;
    }
    set;
  }
    
    private Map<Id, List<zqu__QuoteRatePlanCharge__c>> QuoteIdQuoteChargesMap
  {
    get
    {
          //System.debug('ZQuoteRatePlanChargeManagment.QuoteIdQuoteChargesMap');

            //system.debug(this.QuoteIds);
      //system.debug(this.quoteChargesMap.keySet());
      if (QuoteIdQuoteChargesMap == null)
      {
        QuoteIdQuoteChargesMap = new Map<Id, List<zqu__QuoteRatePlanCharge__c>> ();
        for (zqu__QuoteRatePlanCharge__c charge :[SELECT Id, Product_Category__c, QuoteId__c, Part_Number__c, Name, zqu__ProductName__c
             FROM zqu__QuoteRatePlanCharge__C WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :this.QuoteIds])
        {
          Id quoteId = charge.QuoteId__c;
                    if(charge.Product_Category__c == 'Services')
                    { 
                        if (!QuoteIdQuoteChargesMap.containsKey(quoteId))
                        {
                            QuoteIdQuoteChargesMap.put(quoteId, new List<zqu__QuoteRatePlanCharge__c> ());
                        }
                        List<zqu__QuoteRatePlanCharge__c> qCharges = QuoteIdQuoteChargesMap.get(quoteId);
                        qCharges.add(charge);
                    }
        }
      }
      return QuoteIdQuoteChargesMap;
    }
    set;
  }
    
    private PureCloudProjectHandler(List<PureCloud_Trial__c> newPCProjects)
    {
        this.pcProjects = newPCProjects;
    }
    
    private void UpdateServicePackagesField()
    {
        Id currQuoteID = this.currPCProject.Quote__c;
        Set<String> plValues = new Set<String>();
        Set<String> AllServicePackages = GetServicePackagesPicklistVals();
        List<String> selectedServicePackages;
        if(String.isNotBlank(this.currPCProject.Service_Packages__c))
        {
          selectedServicePackages = this.currPCProject.Service_Packages__c.Split(';');
        }
        else
        {
          selectedServicePackages = new List<String>();  
    }
        //For the current QuoteId, check the line Items and add the picklist values per the line items onto the PC Project
        List<zqu__QuoteRatePlanCharge__c> currServiceCharges = this.QuoteIdQuoteChargesMap.get(currQuoteId);
        if(currServiceCharges != null && currServiceCharges.size() > 0)
        {
            for(zqu__QuoteRatePlanCharge__c qtCharge : currServiceCharges)
            {
                String currPartName = qtCharge.zqu__ProductName__c.toLowerCase();
                if(AllServicePackages.contains(currPartName))
                {
                    plValues.add(currPartName);
                }
            }
            if(plValues.size() > 0)
            {
                selectedServicePackages.addAll(plValues);
                this.currPCProject.Service_Packages__c = String.join(selectedServicePackages, ';');
            }      
        }
    }
    
    private void SetEmailStatus()
    {
        if(this.readyForEmail)
        {
          this.currPCProject.Email_Status__c = 'Pending';
        }
    }
    
    private Set<String> GetServicePackagesPicklistVals()
    {
        Set<String> values = new Set<String>();
        DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('PureCloud_Trial__c').getDescribe().fields.getMap().get('Service_Packages__c').getDescribe();
        List<Schema.PicklistEntry> plServicePackages = fieldResult.getPicklistValues();
           
        for(Schema.PicklistEntry plSrvPackage : plServicePackages)
        {
            values.add((plSrvPackage.getValue().toLowerCase()));
        }   
        return values;
    }
    
}