public  without sharing class PartnerKPIController
{
    public Id idAccount;
    public Boolean blnIsKPIAvailable {get; private set;}
    public Partner_Quarterly_KPI__c objPartnerKPI {get;set;}
    public String strDuration {get; private set;}
    public String accountName {get;set;}
    public String region {get;set;}
    public List<SelectOption> childAccs {get;set;}
    public String selectedAccountName {get;set;}
    public Boolean showPicklist {get;set;}
    public Decimal qualityAssessment {get;set;}
    public Decimal closureAssessment {get;set;}
    public Decimal trainingAssessment {get;set;}
    public Decimal totalKPIScore {get;set;}
    public Decimal qualityAssessmentYTD {get;set;}
    public Decimal closureAssessmentYTD {get;set;}
    public Decimal trainingAssessmentYTD {get;set;}
    public Decimal totalKPIScoreYTD {get;set;}
    public String selectedKPI1Quarter{get;set;}
    public List<SelectOption> partnerKPI1Quarters {get;set;}
    
    private Map<String, String> mapChildAccNameVsId {get;set;}
    private Map<String, String> mapIdVsChildAccName {get;set;}
    
    public void setIdAccount (String s) {
    idAccount = s;
    }

    public String getIdAccount() {
    return idAccount;
    } 
   
    public PartnerKPIController()
    {
       objPartnerKPI = new Partner_Quarterly_KPI__c();
       partnerKPI1Quarters = new List<SelectOption>();
       blnIsKPIAvailable = false;
       strDuration = '';
       showPicklist = false;
       User currentUser;
       Contact userContact;
       Account userAcnt;
       if(ApexPages.currentPage().getParameters().get('runAs') == null){
          currentUser = [SELECT ContactId,email FROM User where id =:Userinfo.getUserId()];
       }
       else{
          String userId = ApexPages.currentPage().getParameters().get('runAs');
          currentUser = [SELECT ContactId,email FROM User where id = :userId];
       }
        childAccs = new List<SelectOption>(); 
       if((inCommunity() || Test.isRunningTest()) && ApexPages.currentPage().getParameters().get('Id') == null)
       {
       userContact = [Select AccountId from Contact where id =:currentUser.ContactId];
       userAcnt = [Select id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c, PartnerType__c from Account where id=:userContact.AccountId];
       accountName = userAcnt.Name;
       region = userAcnt.Country__r.Region__c;
       populateChildAccounts(userAcnt.id);
       }else if (ApexPages.currentPage().getParameters().get('Id') != null){
       userAcnt = [Select id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c, PartnerType__c from Account where id=:ApexPages.currentPage().getParameters().get('Id')];
       accountName = userAcnt.Name;
       region = userAcnt.Country__r.Region__c;
       populateChildAccounts(userAcnt.id);
       }
       
       
    }
    
    public void populateChildAccounts(Id acntID){
                
        List<Account> childAccounts = [SELECT Name FROM Account WHERE ParentId =: acntId OR id = : acntId];
        mapChildAccNameVsId = new Map<String, String>();
        mapIdVsChildAccName = new Map<String, String>();
        for(Account eachAccount: childAccounts){
            mapChildAccNameVsId.put(eachAccount.Name, eachAccount.id);
            mapIdVsChildAccName .put(eachAccount.id, eachAccount.Name);
        }
        
        List<Partner_Quarterly_KPI__c> allKPIs = [SELECT Account_Name__c  FROM Partner_Quarterly_KPI__c 
            WHERE Account_Name__c IN: mapChildAccNameVsId.keyset() AND Account_Name__c != null];    
        Set<String> setAccNames = new Set<String>();
        for(Partner_Quarterly_KPI__c eachKPI : allKPIs){
            if(!setAccNames.contains(eachKPI.Account_Name__c)){
                SelectOption newOption = new SelectOption(eachKPI.Account_Name__c, eachKPI.Account_Name__c);
                childAccs.add(newOption);
                setAccNames.add(eachKPI.Account_Name__c);
            }
        }
        if(childAccs.size() > 1){
            showPicklist = true;
            blnIsKPIAvailable = true;
            selectedAccountName = childAccs[0].getLabel();            
        }
        else if(childAccs.size() == 1){
            selectedAccountName = childAccs[0].getLabel();
            blnIsKPIAvailable = true;            
        }
        partnerKPI1Quarters = PartnerKPIHelper.getPopulatedPeriods();
        selectedKPI1Quarter = PartnerKPIHelper.getCurrentQuarter();
        System.debug('NKC debug selectedKPI1Quarter ['+selectedKPI1Quarter+']');
        populateAccKPIs();
    }
    
    public void populateAccKPIs(){
    	System.debug('NKC debug selectedKPI1Quarter ['+selectedKPI1Quarter+']');
    	List<Partner_Quarterly_KPI__c> partnerKPIs = [SELECT Closure_Assessment__c,Training_Assessment__c,
                        Quality_Assessment__c,Total_KPI_Score__c,Quarter__c,Year__c,
                        Closure_Assessment_YTD__c, Quality_Assessment_YTD__c,
                        Training_Assessment_YTD__c, Total_YTD_KPI_Score__c FROM Partner_Quarterly_KPI__c
                        WHERE Account_Name__c = :selectedAccountName 
                        AND Period__c =:selectedKPI1Quarter ORDER BY Year__c DESC, Quarter__c DESC LIMIT 1];
        System.debug('NKC debug partnerKPIs ['+partnerKPIs+']');
        if(partnerKPIs.isEmpty()){
	        trainingAssessment = 0;
	        qualityAssessment = 0;
	        closureAssessment = 0;
	        totalKPIScore = 0;
	        trainingAssessmentYTD = 0;
	        qualityAssessmentYTD = 0;
	        closureAssessmentYTD = 0;
	        totalKPIScoreYTD = 0;
        }
        else{
        	objPartnerKPI = partnerKPIs[0];
        	trainingAssessment = objPartnerKPI.Training_Assessment__c;
	        qualityAssessment = objPartnerKPI.Quality_Assessment__c;
	        closureAssessment = objPartnerKPI.Closure_Assessment__c;
	        totalKPIScore = objPartnerKPI.Total_KPI_Score__c;
	        trainingAssessmentYTD = objPartnerKPI.Training_Assessment_YTD__c;
	        qualityAssessmentYTD = objPartnerKPI.Quality_Assessment_YTD__c;
	        closureAssessmentYTD = objPartnerKPI.Closure_Assessment_YTD__c;
	        totalKPIScoreYTD = objPartnerKPI.Total_YTD_KPI_Score__c;
	        setDuration(objPartnerKPI);
        }
        
    }
    private String setDuration(Partner_Quarterly_KPI__c objPartnerKPI)
    {
        strDuration = '';
        if(objPartnerKPI.Quarter__c == 1)
            strDuration += 'Jan-Mar';
        else if(objPartnerKPI.Quarter__c == 2)
            strDuration += 'Apr-Jun';
        else if(objPartnerKPI.Quarter__c == 3)
            strDuration += 'Jul-Sep';
        else if(objPartnerKPI.Quarter__c == 4)
            strDuration += 'Oct-Dec';
            
        strDuration +=  ' ' + String.valueOf(objPartnerKPI.Year__c);
        return strDuration;
    }
    
   public boolean inCommunity() {
   return Network.getNetworkId() != null;
   }
}