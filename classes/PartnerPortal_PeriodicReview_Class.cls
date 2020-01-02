global class PartnerPortal_PeriodicReview_Class {

  public String AccountName {get;set;}
  public String certAccountName{get;set;}
  public String trainAccountName{get;set;}
  public String AccountId {get;set;}
  public Double totalRevenue {get;set;}
  public Double targetMLB {get;set;}
  public String region {get;set;}
  public Double kpi2TimeLineScore {get;set;}  
  public List<SelectOption> childAccsKPI2 {get;set;}
  public List<SelectOption> childAccsSupportRevenue {get;set;}  
  public List<revWrapper> revenue_list {get; set;}
  public List<certWrapper> cert_list {get;set;}
  public List<oppWrapper> opp_list {get;set;}
  public List<leadWrapper> lead_list {get;set;}
  public List<trainWrapper> train_list {get;set;}
  List<Partner_KPI2__c> objectKPI2 ;
  public String kpi2YTDScore {get;set;}
  public String selectedKPI2Quarter {get;set;}
  public List<SelectOption> partnerKPI2Quarters {get;set;}
  
  public string sapCode {get;set;}
  public String  userEmail{get;set;}
  public String  acntId{get;set;}
  public Boolean showPickListKPI2 {get;set;} 
  public Boolean showPickListPR {get;set;} 
  public String selectedAccountName {get;set;}
  public String selectedAccountId {get;set;}
  public Id selectedPRAccountId {get;set;}
  //public String selectedPRAccountName {get;set;}
  //private Map<String, String> mapChildAccNameVsId {get;set;}
  //private Map<String, String> mapIdVsChildAccName {get;set;}
  public Boolean isDesignatedContact {get;set;}
  public Date dateToday {get;set;}
  User currentUser;
  Contact userContact;
  Account currUserAcnt;
  
  public void init()
  {
      dateToday = System.today();
      showPickListKPI2 = false;
      showPickListPR = false;
      isDesignatedContact = true;
      childAccsKPI2 = new List<SelectOption>();
      childAccsSupportRevenue = new List<SelectOption>();
      if(ApexPages.currentPage().getParameters().get('runAs') == null){
          currentUser = [SELECT ContactId,email FROM User where id =:Userinfo.getUserId()];
      }
      else{
          String userId = ApexPages.currentPage().getParameters().get('runAs');
          currentUser = [SELECT ContactId,email FROM User where id = :userId];
      }
      
      if((inCommunity() || Test.isRunningTest()) && ApexPages.currentPage().getParameters().get('Id') == null)
      {
      userContact = [Select AccountId, Account.Name, Designated_Partner_Contact__c,Designated_Contact__c  from Contact where id =:currentUser.ContactId ]; 
      isDesignatedContact =  userContact.Designated_Partner_Contact__c;
      currUserAcnt = [Select Id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c from Account where id=:userContact.AccountId];
      AccountName = currUserAcnt.Name;   
      AccountId = currUserAcnt.id;
      sapCode = currUserAcnt.SAP_Code__c;
      populateCertifications();
      populateChildAccounts(currUserAcnt.Id);
      }
      else if (ApexPages.currentPage().getParameters().get('Id') != null)
      {
      currUserAcnt = [Select id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c, PartnerType__c from Account where id=:ApexPages.currentPage().getParameters().get('Id')];    
      AccountName = currUserAcnt.Name;   
      AccountId = currUserAcnt.id;
      sapCode = currUserAcnt.SAP_Code__c;
      populateCertifications();
      populateChildAccounts(currUserAcnt.Id);
      }
      userEmail = currentUser.Email;
      objectKPI2 =  new List<Partner_KPI2__c>();
   }
 
  public void populateChildAccounts(Id AcntId){
        List<Account> childAccounts = [SELECT Name FROM Account WHERE ParentId =:  acntId  OR id = : acntId];
        System.debug('the size is'+childAccounts.size());
        //mapChildAccNameVsId = new Map<String, String>();
        /*mapIdVsChildAccName = new Map<String, String>();
        for(Account eachAccount: childAccounts){
            mapChildAccNameVsId.put(eachAccount.Name, eachAccount.id);
            mapIdVsChildAccName .put(eachAccount.id, eachAccount.Name);
        }*/
        List<Partner_KPI2__c> allKPIs = [SELECT Account__r.Name,Account_Name__c  FROM Partner_KPI2__c 
            WHERE Account__c IN: childAccounts];
        Set<String> setAccIds = new Set<String>();
        for(Partner_KPI2__c eachKPI : allKPIs){
            if(!setAccIds.contains(eachKPI.Account__c)){
                SelectOption newOption = new SelectOption(eachKPI.Account__c,eachKPI.Account__r.Name);
                childAccsKPI2.add(newOption);
                setAccIds.add(eachKPI.Account__c);
            }
        }
        
        if(childAccsKPI2.size() > 1){
            showPickListKPI2 = true;
            selectedAccountId = childAccsKPI2[0].getValue();
            selectedAccountName = childAccsKPI2[0].getLabel();                           
        }
        else if(childAccsKPI2.size() == 1){
            selectedAccountId = childAccsKPI2[0].getValue();
            selectedAccountName = childAccsKPI2[0].getLabel();
        }
        
        List<Partner_EndUser_Data__c> allPartnerRevenues = [SELECT id, Customer__c,Account__r.Name FROM Partner_EndUser_Data__c WHERE Account__c IN: childAccounts];
        system.debug('----------------------------------allPartnerRevenues-----------------------------------'+allPartnerRevenues);
        Set<String> setAccNames = new Set<String>();
        for(Partner_EndUser_Data__c eachPR : allPartnerRevenues){
            if(!setAccNames.contains(eachPR.Account__c)){
                system.debug('----------------------------------eachPR-----------------------------------'+eachPR);
                SelectOption newOption = new SelectOption(eachPR.Account__c,eachPR.Account__r.Name);
                childAccsSupportRevenue.add(newOption);
                setAccNames.add(eachPR.Account__c);
            }
        }
        if(childAccsSupportRevenue.size() > 1){
            showPickListPR = true;
            //selectedPRAccountName = childAccsSupportRevenue[0].getLabel();
            selectedPRAccountId = childAccsSupportRevenue[0].getValue();
            populatePartnerRevenue();
        }
        else if(childAccsSupportRevenue.size() == 1){
            /*selectedPRAccountName = childAccsSupportRevenue[0].getLabel();
            System.debug('NKC debug selectedPRAccountName ['+selectedPRAccountName+']');
            System.debug('NKC debug mapChildAccNameVsId ['+mapChildAccNameVsId+']');*/
            selectedPRAccountId = childAccsSupportRevenue[0].getValue();
            populatePartnerRevenue();
        }
        partnerKPI2Quarters = PartnerKPIHelper.getPopulatedPeriods();
        selectedKPI2Quarter = PartnerKPIHelper.getCurrentQuarter();
        populateKP2Details();
    }
    
    public void populatePartnerRevenue(){
      /*selectedPRAccountName = mapIdVsChildAccName.get(selectedPRAccountId);
      System.debug('NKC debug selectedPRAccountName ['+selectedPRAccountName+']');
      System.debug('NKC debug mapIdVsChildAccName ['+mapChildAccNameVsId+']');*/
      //List<Partner_Certifications__c> results_cert = new List<Partner_Certifications__c>();
      //List<Partner_Training_Info__c> results_train = new List<Partner_Training_Info__c>();
      List<Partner_MLB_Target_Data__c> targetMLBList = new List<Partner_MLB_Target_Data__c>();
      Set<String> revNameSet = new Set<String>();
      revWrapper revWrap ;
      Account userAcnt = [Select Id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c from Account where id=:selectedPRAccountId];
      region = userAcnt.Country__r.Region__c;
      //Target      
      System.debug('NKC debug userAcnt.Country__r.Name ['+userAcnt.Country__r.Name+']');
      System.debug('NKC debug userAcnt.Country__r.Region__c ['+userAcnt.Country__r.Region__c+']');
      System.debug('NKC debug userAcnt.tier__c ['+userAcnt.tier__c+']');
      
      targetMLBList = [SELECT Id,Name,MLB__c from Partner_MLB_Target_Data__c where Country__c =:userAcnt.Country__r.Name  and Region__c =:userAcnt.Country__r.Region__c 
        and tier__c =:userAcnt.tier__c Limit 1];
      if(targetMLBList.size() > 0)
      {
        targetMLB = Double.valueof(targetMLBList[0].MLB__c);
      }else
      {
        targetMLB = 0;    
      }
      //List
      List<AggregateResult> results_rev = [SELECT Revenue_Type__c revType , SUM(Revenue_Amount__c) rev FROM Partner_EndUser_Data__c where Account__c  =: selectedPRAccountId group by Revenue_Type__c];
      revenue_list = new List<revWrapper>();
      //cert_list = new List<certWrapper>();
      //train_list = new List<trainWrapper>();
      totalRevenue = 0;
      if(results_rev.size() > 0)
      {
        for (AggregateResult ar : results_rev) {
             Decimal revNumber = Integer.valueOf(ar.get('rev'));
             String revName = (String)ar.get('revType');
             totalRevenue = totalRevenue + revNumber;
             revNameSet.add((String)ar.get('revType'));  
             revWrap = new revWrapper();
             if((String)ar.get('revType') == 'Revenue - Maintenance') { revWrap.RevLabel = 'Maintenance'; } 
             else if((String)ar.get('revType') == 'Revenue - Education') {  revWrap.RevLabel = 'Education'; }
             else if((String)ar.get('revType') == 'Revenue - PS') {  revWrap.RevLabel = 'Professional Services'; }
             else if((String)ar.get('revType') == 'Revenue - License') {  revWrap.RevLabel = 'License'; }
             else { revWrap.RevLabel = revName.replace('Revenue - ', ''); }
             revwrap.RevName = (String)ar.get('revType');
             revwrap.Revenue = (Decimal)ar.get('rev');
             revenue_list.add(revWrap);
          }  
      }
    
      if(!revNameSet.contains('Revenue - Maintenance')) {  revWrap = new revWrapper() ; revWrap.RevLabel = 'Maintenance'; revWrap.Revenue = 0; revwrap.RevName = 'Revenue - Maintenance';revenue_list.add(revWrap); }
      if(!revNameSet.contains('Revenue - Education')) {  revWrap = new revWrapper(); revWrap.RevLabel = 'Education'; revWrap.Revenue = 0;revwrap.RevName = 'Revenue - Education'; revenue_list.add(revWrap); }  
      if(!revNameSet.contains('Revenue - PS')) {  revWrap = new revWrapper();revWrap.RevLabel = 'Professional Services'; revWrap.Revenue = 0;revwrap.RevName = 'Revenue - PS'; revenue_list.add(revWrap); }  
      if(!revNameSet.contains('Revenue - License')) {  revWrap = new revWrapper(); revWrap.RevLabel = 'License'; revWrap.Revenue = 0;revwrap.RevName = 'Revenue - License'; revenue_list.add(revWrap); } 
      /*
      List<Partner_Certifications__c> certforAcntName = [SELECT Account_Name__c from Partner_Certifications__c where Email__c =:currentUser.Email Limit 1];
      List<Partner_Training_Info__c> trainforAcntName = [SELECT Account_Name__c from Partner_Training_Info__c where Email__c =:currentUser.Email Limit 1];
      
      if(certforAcntName.size() > 0)
      {
        certAccountName = certforAcntName[0].Account_Name__c;
        System.debug('NKC debug certAccountName ['+certAccountName+']');
        results_cert = [SELECT First_Name__c,Last_Name__c,Test_Name__c,Test_Date__c  FROM Partner_Certifications__c where Account_Name__c =:certforAcntName[0].Account_Name__c and Country_Name__c =:userAcnt.Country__r.Name and Pass_Fail__c = 'P' order by First_Name__c];
      }
      
      if(trainforAcntName.size() > 0)
      {
        trainAccountName = trainforAcntName[0].Account_Name__c;
        System.debug('NKC debug trainAccountName ['+trainAccountName+']');
        results_train = [SELECT First_Name__c , Last_Name__c,Course_Name__c,Country_Name__c,Course_Start_Date__c  FROM Partner_Training_Info__c where Account_Name__c =:trainforAcntName[0].Account_Name__c and Country_Name__c =:userAcnt.Country__r.Name order by First_Name__c limit 14 ];  
      }
      if(results_cert.size() > 0) 
      {     
       for (Partner_Certifications__c eachcert : results_cert) {
         cert_list.add(new certWrapper(eachcert));
        } 
      }
       
      if(results_train.size() > 0) 
      { 
       for (Partner_Training_Info__c ar : results_train) {
         train_list.add(new trainWrapper(ar));
       } 
      } */
    }
    
    public void populateKP2Details(){       
        objectKPI2 = [SELECT Id,Name,Account_Name__c,KPI_2_On_Time__c, Total_YTD_KPI_Score__c FROM Partner_KPI2__c
             WHERE Account__c =:selectedAccountId 
             AND Period__c =:selectedKPI2Quarter LIMIT 1];
        if(objectKPI2.size() > 0){
            kpi2TimeLineScore = objectKPI2[0].KPI_2_On_Time__c;
            kpi2YTDScore = String.valueOf(objectKPI2[0].Total_YTD_KPI_Score__c);
        }else{
            kpi2TimeLineScore = 0;
        }
    }
   
    /************************************************************
    * Name             : populateCertifications
    * Description      : Populates the certifications based on the email 
    *                    address of the user logged in.         
    * Input Parameters : NA 
    * Return           : void
    ************************************************************/   
   public void populateCertifications(){
     cert_list = new List<certWrapper>();
     train_list = new List<trainWrapper>();
     List<Partner_Certifications__c> results_cert = new List<Partner_Certifications__c>();
     List<Partner_Training_Info__c> results_train = new List<Partner_Training_Info__c>();
     try{
     //List<Partner_Certifications__c> certforAcntName = [SELECT Account_Name__c,Account__c,Account__r.Name from Partner_Certifications__c where Email__c =:currentUser.Email Limit 1];
     //List<Partner_Training_Info__c> trainforAcntName = [SELECT Account_Name__c,Account__c,Account__r.Name from Partner_Training_Info__c where Email__c =:currentUser.Email Limit 1];
     
     for(Partner_Certifications__c certRec : [SELECT First_Name__c,Last_Name__c,Test_Name__c,Test_Date__c,Account_Name__c,Email__c, Account__c,Account__r.Name from Partner_Certifications__c where Account__c =:AccountId AND Pass_Fail__c ='P' Order By First_Name__c]){
     	certAccountName = AccountId;
     	if(isDesignatedContact){
     		cert_list.add(new certWrapper(certRec));
     	}
     	else if(certRec.Email__c == currentUser.Email){
     		cert_list.add(new certWrapper(certRec));
     	}
     }

     for(Partner_Training_Info__c trRec : [SELECT First_Name__c,Last_Name__c,Course_Name__c,Course_Start_Date__c,Country_Name__c,
     									   Account_Name__c,Account__c,Account__r.Name,Email__c FROM Partner_Training_Info__c 
     									   where Account__c=:AccountId Order By First_Name__c]){
     	trainAccountName = AccountId;
     	if(isDesignatedContact){
     		train_list.add(new trainWrapper(trRec));
     	}
     	else if(trRec.Email__c == currentUser.Email){
     		train_list.add(new trainWrapper(trRec));
     	}
     }
     /*if(certforAcntName.size() > 0){      
      if(certforAcntName[0].Account_Name__c != null && certforAcntName[0].Account__c != null){
          certAccountName = certforAcntName[0].Account__c;        
          results_cert = [SELECT First_Name__c,Last_Name__c,Test_Name__c,Test_Date__c  FROM Partner_Certifications__c where Account__c =:certforAcntName[0].Account__c AND Pass_Fail__c = 'P' ORDER BY First_Name__c];
      }
     }
     if(results_cert.size() > 0){     
      for (Partner_Certifications__c eachcert : results_cert) {
       cert_list.add(new certWrapper(eachcert));
      } 
     }*/
      
     /*if(trainforAcntName.size() > 0){
       if(trainforAcntName[0].Account_Name__c != null && trainforAcntName[0].Account__c != null){
        trainAccountName = trainforAcntName[0].Account__c;        
        results_train = [SELECT First_Name__c , Last_Name__c,Course_Name__c,Country_Name__c,Course_Start_Date__c  FROM Partner_Training_Info__c where Account__c =:trainforAcntName[0].Account__c ORDER BY First_Name__c limit 14 ];  
       }
     }
     
       
     if(results_train.size() > 0){ 
      for (Partner_Training_Info__c ar : results_train) {
       train_list.add(new trainWrapper(ar));
      } 
     }*/  
    }
    catch(Exception e){        //Exception Handling
        System.debug('Exception :'+e.getMessage());
    } 
   } 
    
   public class revWrapper{
     public String RevName {get; private set;}
     public Decimal Revenue {get; private set;}
     public String RevLabel {get;private set;}
   }  
  
   public class certWrapper{
   public String FName {get; private set;}
   public String LName {get; private set;}
   public String exam_Name {get; private set;}
   public Date pass_Date {get; private set;}    

    // Constructor
    public certWrapper(Partner_Certifications__c each) {
        FName = each.First_Name__c; 
        LName = each.Last_Name__c;
        exam_Name =  each.Test_Name__c;
        pass_Date =  each.Test_Date__c;
     }
    }
    public class trainWrapper{
    public String FName_train {get; private set;}
    public String LName_train {get; private set;}
    public String Cert_Name {get; private set;}
    public Date Cert_Date {get; private set;}
    public String Cert_Place {get; private set;}
   
   public List<Partner_Training_Info__c> trainList {get;set;}
    // Constructor
    public trainWrapper(Partner_Training_Info__c ar) {
        FName_train = ar.First_Name__c;
        LName_train = ar.Last_Name__c;
        Cert_Name = ar.Course_Name__c;
        Cert_Date = ar.Course_Start_Date__c;
        Cert_Place = ar.Country_Name__c;
     }  
    }
  
  public List<Partner_EndUser_Data__c> returnPartnerDataList(String sapCodeStrr)
  {
    List<Partner_EndUser_Data__c> pedList = [SELECT Id,Customer__c,Product_Name__c,Quarter__c,Revenue_Amount__c,Revenue_Type__c,SAP_Account_ID__c FROM Partner_EndUser_Data__c where SAP_Account_ID__c =:sapCodeStrr];
    return pedList;
  }
  
  public List<Partner_Certifications__c> returnPertnerCertList(String email)
  {
    List<Partner_Certifications__c> certList = [SELECT Id,First_Name__c,Last_Name__c,Pass_Fail__c,Test_Code__c,Test_Date__c,Test_Name__c FROM Partner_Certifications__c where email__c =:email];
    return certList;
  }
  
  public list<partner_portal_prospect__c> returnPartneroppList(String AccountId)
  {
    List<partner_portal_prospect__c> oppList = [Select Id,Name,Status__c,Amount__c,End_Date__c,CreatedDate from partner_portal_prospect__c where Account__c =: AccountId];
    return oppList;
  }
  
  public list<Lead_Referral_Registration__c> returnPartnerleadList(String AccountId)
  {
    List<Lead_Referral_Registration__c> leadList = [Select Id,Name,Status__c,CreatedDate from Lead_Referral_Registration__c where Account__c =: AccountId];
    return leadList;
  }
  
  public Decimal returnTotalRevenue(String sapCodeStr)
  {  
    Decimal totalRevenue = 0.0;
    for(Partner_EndUser_Data__c eachped: returnPartnerDataList(sapCodeStr))
    {
     totalRevenue = totalRevenue + eachped.Revenue_Amount__c;   
    }
    return totalRevenue;
   }            

   //opp Wrapper
  public class oppWrapper {
    public partner_portal_prospect__c oppData{get; set;} 
        
        public oppWrapper(partner_portal_prospect__c opData) {
            this.oppData = opData;      
    }
  }
  
  //lead Wrapper
  public class leadWrapper {
    public Lead_Referral_Registration__c leadData{get; set;} 
        
        public leadWrapper(Lead_Referral_Registration__c leData) {
            this.leadData = leData;      
    }
  }
  
  public List<oppWrapper> getRecordsToDisplay_opp() {
        opp_list = new List<oppWrapper>();
        system.debug('---------------------AccountId------------------------'+AccountId);
        for (partner_portal_prospect__c opp :  returnPartneroppList(AccountId)) { 
            opp_list.add(new oppWrapper(opp)); 
        }
        return opp_list; 
     } 
     
   public List<leadWrapper> getRecordsToDisplay_lead() {
        lead_list = new List<leadWrapper>();
        system.debug('---------------------AccountId------------------------'+AccountId);
        for (Lead_Referral_Registration__c lead :  returnPartnerleadList(AccountId)) { 
            lead_list.add(new leadWrapper(lead)); 
        }
        return lead_list; 
     } 
       
  @RemoteAction
  global static List<Partner_EndUser_Data__c> eachRevenueDetails(String RecId , String acntName) {
  List<Partner_EndUser_Data__c> ped = [SELECT Id,End_User_Name__c,Product_Name__c,Quarter__c,Revenue_Amount__c,Revenue_Type__c,SAP_Account_ID__c FROM Partner_EndUser_Data__c where Revenue_Type__c =:RecId and Account__c =:acntName];
  return ped;
  }
  
  @RemoteAction
  global static List<Partner_Certifications__c> eachCertDetails(String fName,String lName,String aName) {
  List<Partner_Certifications__c> certList = [SELECT Id,First_Name__c,Last_Name__c,Pass_Fail__c,Test_Code__c,Test_Date__c,Test_Name__c,Email__c FROM Partner_Certifications__c where First_Name__c =:fName and Last_Name__c =:lName and Account__c =:aName];
  return certList;
  }
  
  @RemoteAction
  global static List<Partner_Training_Info__c> eachTrainDetails(String fName,String lName,String aName) {
  List<Partner_Training_Info__c> trainList = [SELECT Id,View_Central_Registration_Number__c,Course_Start_Date__c,Course_End_Date__c,Course_Name__c,Email__c  FROM Partner_Training_Info__c where First_Name__c =:fName and Last_Name__c =:lName and Account__c =:aName];
  return trainList;
  }
  
  @RemoteAction
  global static List<Partner_KPI2__c> eachKPI2Details(String aName,String region, string quarter) {
  List<Partner_KPI2__c> kpi2Data = [Select Id,Name,Account_Name__c,KPI_2_On_Time__c,Sum_of_PO_s_Not_On_Time__c,Sum_of_PO_s_On_Time__c,Total_PO_s__c from Partner_KPI2__c where Account_Name__c =:aName AND Period__c =: quarter];
  return kpi2Data;
  }
  
  @RemoteAction
  global static List<Partner_KPI2_PO_Details__c> eachKPI2DetailsP_info(String acntId,String region, string quarter) {
  List<Partner_KPI2_PO_Details__c> kpi2Data = [Select Id,Name,End_User_Name__c,Maintenance_End_Date__c,PO_Date__c,PO_Number__c from Partner_KPI2_PO_Details__c where Account_Name__c =:acntId AND Period__c =: quarter];
  return kpi2Data;
  } 
  
  public boolean inCommunity() {
  return Network.getNetworkId() != null;
  }
}