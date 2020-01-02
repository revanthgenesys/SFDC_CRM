//Naresh Kumar  05/29/2015
public without sharing class QuoteRevenueSummaryDetailController {
    public List<SelectOption> oppListOptions {get;set;} 
    public String selectedOpp {get;set;}
    public String currentYear {get;set;}
    public List<QuoteRevenueForecastController.revenueDetailWrapper> revenueDetails {get;set;}
    public Boolean showRevenueDetails {get;set;}
    public List<String> monthNames {get;set;}
    public List<boolean> activeMonthNames {get;set;}

    public QuoteRevenueSummaryDetailController(){
        selectedOpp = ApexPages.currentPage().getParameters().get('oppId');     
        currentYear = ApexPages.currentPage().getParameters().get('year');     
        loadPhaseLines();
    }
    
    public void loadPhaseLines(){
        List<Cloud_Billing_Information__c> cloudBillingInfo = [SELECT id, Opportunity__r.Account.Name,Opportunity__r.CloseDate,Opportunity__r.Monthly_Commitment__c FROM Cloud_Billing_Information__c WHERE Opportunity__c =: selectedOpp];
        if(cloudBillingInfo.isEmpty()) 
            return;
        populateListOptions();
        if(currentYear == null) 
           currentYear = String.valueof(cloudBillingInfo[0].Opportunity__r.CloseDate.Year());
                
        monthNames =  QuoteRevenueForecastControllerHelper.getMonthList(cloudBillingInfo[0].Opportunity__r.CloseDate);
        activeMonthNames =  QuoteRevenueForecastControllerHelper.getActiveMonthList(cloudBillingInfo[0].Opportunity__r.CloseDate, currentYear);
        revenueDetails = QuoteRevenueForecastControllerHelper.populateRevenueDetails(cloudBillingInfo[0].id, null, activeMonthNames);   
        if(revenueDetails.isEmpty())
            showRevenueDetails = false;
        else
            showRevenueDetails = true;
    }
    
    public boolean checkColumn(String month) { 
      if (month != null && month.contains(currentYear)) 
       return true; 
     else 
      return false;  
    
    }
        
    
    private void populateListOptions(){
        List<Cloud_Billing_Information__c> cloudBillingInfo = [SELECT Opportunity__r.Name, Opportunity__c
            FROM Cloud_Billing_Information__c LIMIT 10000];
        Set<Id> setOfOppIds = new Set<Id>();
        oppListOptions = new List<SelectOption>();
        for(Cloud_Billing_Information__c eachRecord : cloudBillingInfo){
            System.debug('NKC debug eachRecord.Opportunity__c ['+eachRecord.Opportunity__c+']');
            if(eachRecord.Opportunity__c != null 
                && !setOfOppIds.contains(eachRecord.Opportunity__c)){
                System.debug('NKC debug setOfOppIds ['+setOfOppIds+']');                
                setOfOppIds.add(eachRecord.Opportunity__c);
                SelectOption newOption = new SelectOption(eachRecord.Opportunity__c, eachRecord.Opportunity__r.Name);
                oppListOptions.add(newOption);
            }
        }       
    }
}