public class partnerMetricsPageAccountsController {
public String selectedAccount {get;set;}
    
    public partnerMetricsPageAccountsController()
    {
    
    }

  public static List<SelectOption> getAllAcnts(){
      List<Partner_Quarterly_KPI__c> acntList = [SELECT Account__c,Account_Name__c FROM Partner_Quarterly_KPI__c where Account_Name__c != null AND Account__c !=null order by Account_Name__c asc];
      Set<String> acNameSet = new Set<String>();
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', '--Select--'));
      for(Partner_Quarterly_KPI__c eachAccount : acntList){
      	    if(!acNameSet.contains(eachAccount.Account__c))
            {
             SelectOption newOption = new SelectOption(eachAccount.Account__c, eachAccount.Account_Name__c);
             options.add(newOption);  
             acNameSet.add(eachAccount.Account__c);    
      	    }   
        }
        return options;
    }
    
  public PageReference nextPage()
  {
   PageReference pg = new Pagereference('/apex/partnerMetricsPage?id='+selectedAccount);
   pg.setRedirect(true);
   return pg;
  }
}