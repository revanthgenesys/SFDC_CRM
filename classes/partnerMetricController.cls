global without sharing class partnerMetricController {

  public String AccountName {get;set;}
  public String certAccountName{get;set;}
  public String trainAccountName{get;set;}
  public String AccountId {get;set;}
  public Double totalRevenue {get;set;}
  public Double targetMLB {get;set;}
  public String region {get;set;}
  public Double kpi2TimeLineScore {get;set;}  
  public List<SelectOption> childAccsKPI1 {get;set;}
  public List<SelectOption> childAccsKPI2 {get;set;}
  public List<SelectOption> childAccsSupportRevenue {get;set;}  
  public List<SelectOption> partnerKPI1Quarters {get;set;}
  public List<SelectOption> partnerKPI2Quarters {get;set;}  
  public String selectedKPI1Quarter{get;set;}  
  public String selectedKPI2Quarter{get;set;}
  public List<revWrapper> revenue_list {get; set;}
  public List<certWrapper> cert_list {get;set;}
  public List<oppWrapper> opp_list {get;set;}
  public List<trainWrapper> train_list {get;set;}
  public List<Partner_KPI2__c> objectKPI2 {get;set;}
  public Partner_Quarterly_KPI__c objPartnerKPI {get;set;}
  public String periodString {get;set;}
  public String strDuration {get; private set;}
  public Date dateToday { get { return Date.today(); }}
  
  public string sapCode {get;set;}
  public String  userEmail{get;set;}
  public String  acntId{get;set;}
  public Boolean showPickListKPI2 {get;set;} 
  public Boolean showPicklistKP1 {get;set;} 
  
  public Boolean showPickListPR {get;set;} 
  public String selectedAccountName {get;set;}
  public Id selectedPRAccountId {get;set;}
  public String selectedPRAccountName {get;set;}
  public String selectedKP1AccountName {get;set;}
  public Decimal qualityAssessment {get;set;}
  public Decimal closureAssessment {get;set;}
  public Decimal trainingAssessment {get;set;}
  public Decimal totalKPIScore {get;set;}
  public String kpiID {get;set;}
  public Boolean blnIsKPIAvailableKP1 {get; private set;}
  
  private Map<String, String> mapChildAccNameVsId {get;set;}
  private Map<String, String> mapIdVsChildAccName {get;set;}

  User currentUser;
  Contact userContact;
  Account currUserAcnt;
  List<Partner_Certifications__c> results_cert = new List<Partner_Certifications__c>();
  List<Partner_Training_Info__c> results_train = new List<Partner_Training_Info__c>();
  
  public void init()
  {
      showPickListKPI2 = false;
      showPickListPR = false;
      childAccsKPI1 = new List<SelectOption>();
      childAccsKPI2 = new List<SelectOption>();
      partnerKPI1Quarters = new List<SelectOption>();
      partnerKPI2Quarters = new List<SelectOption>();
      childAccsSupportRevenue = new List<SelectOption>();
      
      try{
      
      if(ApexPages.currentPage().getParameters().get('runAs') == null){
          currentUser = [SELECT ContactId,email FROM User where id =:Userinfo.getUserId()];
      }
      else{
          String userId = ApexPages.currentPage().getParameters().get('runAs');
          currentUser = [SELECT ContactId,email FROM User where id = :userId];
      }
      
      if(inCommunity() && ApexPages.currentPage().getParameters().get('Id') == null)
      {
      userContact = [Select AccountId, Account.Name from Contact where id =:currentUser.ContactId ];      
      currUserAcnt = [Select Id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c from Account where id=:userContact.AccountId];
      AccountName = currUserAcnt.Name;   
      AccountId = currUserAcnt.id;
      sapCode = currUserAcnt.SAP_Code__c;
      populateChildAccounts(currUserAcnt.Id);
      }
      else if (ApexPages.currentPage().getParameters().get('Id') != null)
      {
      currUserAcnt = [Select id,Name,SAP_Code__c,Country__r.Name,Country__r.Region__c,Tier__c, PartnerType__c from Account where id=:ApexPages.currentPage().getParameters().get('Id')];    
      AccountName = currUserAcnt.Name;   
      AccountId = currUserAcnt.id;
      sapCode = currUserAcnt.SAP_Code__c;
      populateChildAccounts(currUserAcnt.Id);
      }
      userEmail = currentUser.Email;
      objectKPI2 =  new List<Partner_KPI2__c>();
      objPartnerKPI = new Partner_Quarterly_KPI__c();
      cert_list = new List<certWrapper>();
      train_list = new List<trainWrapper>();
      
      system.debug('---------------------currentUser.Email-------------------------'+currentUser.Email);
      
      List<Partner_Certifications__c> certforAcntName = [SELECT Account_Name__c from Partner_Certifications__c where Email__c =:currentUser.Email Limit 1];
      List<Partner_Training_Info__c> trainforAcntName = [SELECT Account_Name__c from Partner_Training_Info__c where Email__c =:currentUser.Email Limit 1];
      
      if(certforAcntName.size() > 0)
      {
        system.debug('--------------------currUserAcnt.Country__r.Name-------------------------'+currUserAcnt.Country__r.Name);
        certAccountName = certforAcntName[0].Account_Name__c;
        results_cert = [SELECT First_Name__c,Last_Name__c,Test_Name__c,Test_Date__c  FROM Partner_Certifications__c where Account_Name__c =:certforAcntName[0].Account_Name__c and Country_Name__c =:currUserAcnt.Country__r.Name and Pass_Fail__c = 'P' order by First_Name__c];
      }
            
      if(trainforAcntName.size() > 0)
      {
        trainAccountName = trainforAcntName[0].Account_Name__c;
        results_train = [SELECT First_Name__c , Last_Name__c,Course_Name__c,Country_Name__c,Course_Start_Date__c  FROM Partner_Training_Info__c where Account_Name__c =:trainforAcntName[0].Account_Name__c and Country_Name__c =:currUserAcnt.Country__r.Name order by First_Name__c];  
      }
      
      system.debug('--------------------results_cert-------------------------'+results_cert.size());
      
      system.debug('--------------------results_train-------------------------'+results_train.size());
      
      
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
      } 
     }
      catch(exception ex)
      {
            String subject = 'Error in the Partner Portal Landing Page.';
            String htmlBody1 = 'Hi <br/><br/>';
            htmlBody1 += 'Error Details :' + ex.getMessage();            
            SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1);       
      }
   }
 
  public void populateChildAccounts(Id AcntId){
        
        system.debug('----------------------------------AcntId-----------------------------------'+AcntId);

        List<Account> childAccounts = [SELECT Name FROM Account WHERE ParentId =:AcntId];
        List<Account> currAccounts = [SELECT Name FROM Account WHERE id =:AcntId];
        
        mapChildAccNameVsId = new Map<String, String>();
        mapIdVsChildAccName = new Map<String, String>();
        if(childAccounts.size() > 0)
        {
        for(Account eachAccount: childAccounts){
            mapChildAccNameVsId.put(eachAccount.Name, eachAccount.id);
            mapIdVsChildAccName .put(eachAccount.id, eachAccount.Name);
        }
        }else{
            mapChildAccNameVsId.put(currAccounts[0].Name, currAccounts[0].id);
            mapIdVsChildAccName .put(currAccounts[0].id, currAccounts[0].Name);
        }
        
        system.debug('----------------------------------mapChildAccNameVsId-----------------------------------'+mapChildAccNameVsId);
        
        system.debug('----------------------------------mapIdVsChildAccName-----------------------------------'+mapIdVsChildAccName);
        
        // Populate Revenue Data
        List<Partner_EndUser_Data__c> allPartnerRevenues = [SELECT id, Customer__c FROM Partner_EndUser_Data__c WHERE Customer__c IN: mapChildAccNameVsId.keyset()];
        system.debug('----------------------------------allPartnerRevenues-----------------------------------'+allPartnerRevenues);
        Set<String> setAccNames = new Set<String>();
        for(Partner_EndUser_Data__c eachPR : allPartnerRevenues){
            if(mapChildAccNameVsId.get(eachPR.Customer__c) != null && !setAccNames.contains(eachPR.Customer__c)){
                system.debug('----------------------------------eachPR-----------------------------------'+eachPR);
                SelectOption newOption = new SelectOption(mapChildAccNameVsId.get(eachPR.Customer__c), eachPR.Customer__c);
                childAccsSupportRevenue.add(newOption);
                setAccNames.add(eachPR.Customer__c);
            }
        }
        if(childAccsSupportRevenue.size() > 1){
            showPickListPR = true;
            selectedPRAccountName = childAccsSupportRevenue[0].getLabel();
            selectedPRAccountId = mapChildAccNameVsId.get(selectedPRAccountName);
            populatePartnerRevenue();
        }
        else if(childAccsSupportRevenue.size() == 1){
            selectedPRAccountName = childAccsSupportRevenue[0].getLabel();
            System.debug('NKC debug selectedPRAccountName ['+selectedPRAccountName+']');
            System.debug('NKC debug mapChildAccNameVsId ['+mapChildAccNameVsId+']');
            selectedPRAccountId = mapChildAccNameVsId.get(selectedPRAccountName);
            populatePartnerRevenue();
        }
        
        //Populate Revenue Data
        List<Partner_Quarterly_KPI__c> allKPIs_kp1 = [SELECT Account_Name__c  FROM Partner_Quarterly_KPI__c  WHERE Account_Name__c IN: mapChildAccNameVsId.keyset() AND Account_Name__c != null];    
       
        system.debug('-----------------------------allKPIs_kp1------------------------------------'+allKPIs_kp1.size());
        Set<String> setAccNames_kp1 = new Set<String>();
        for(Partner_Quarterly_KPI__c eachKPI : allKPIs_kp1){
            if(!setAccNames_kp1.contains(eachKPI.Account_Name__c)){
                SelectOption newOption = new SelectOption(eachKPI.Account_Name__c, eachKPI.Account_Name__c);
                childAccsKPI1.add(newOption);
                setAccNames_kp1.add(eachKPI.Account_Name__c);
            }
        }
        
        system.debug('-----------------------------childAccsKPI1------------------------------------'+childAccsKPI1.size());
        
        Map<Decimal,SelectOption> kpiMapListOrder = new  Map<Decimal,SelectOption>();
        date today = system.today();
         for(Partner_KPI_Periods__c iso : Partner_KPI_Periods__c.getAll().values())
         {         
           if(iso.Active__c)
           {
             kpiMapListOrder.put(Integer.Valueof(iso.Order__c),new SelectOption(iso.Name , iso.Name)); 
           }
           if(iso.Current_Quarter__c)
           {
             selectedKPI1Quarter = iso.Name;
           }
         }
          
         for(Integer i = 0; i < kpiMapListOrder.size() ; i++) 
         {
           partnerKPI1Quarters.add(kpiMapListOrder.get(i+1));
           partnerKPI2Quarters.add(kpiMapListOrder.get(i+1));   
         }
         
         if(childAccsKPI1.size() > 1){
            showPicklistKP1 = true;
            blnIsKPIAvailableKP1 = true;
            selectedKP1AccountName = childAccsKPI1[0].getLabel();
            populateAccKPIs();
        }
        else if(childAccsKPI1.size() == 1){
            selectedKP1AccountName = childAccsKPI1[0].getLabel();
            blnIsKPIAvailableKP1 = true;
            populateAccKPIs();
        }

       // Populate KPI2 Data
        List<Partner_KPI2__c> allKPIs_kp2 = [SELECT Account_Name__c  FROM Partner_KPI2__c 
            WHERE Account_Name__c IN: mapChildAccNameVsId.keyset() AND Account_Name__c != null];
        Set<String> setAccIds = new Set<String>();
        for(Partner_KPI2__c eachKPI : allKPIs_kp2){
            if(!setAccIds.contains(eachKPI.Account_Name__c)){
                SelectOption newOption = new SelectOption(eachKPI.Account_Name__c,eachKPI.Account_Name__c);
                childAccsKPI2.add(newOption);
                setAccIds.add(eachKPI.Account_Name__c);
            }
        }
        if(childAccsKPI2.size() > 1){
            showPickListKPI2 = true;
            selectedAccountName = childAccsKPI2[0].getLabel();              
            populateKP2Details();               
        }
        else if(childAccsKPI2.size() == 1){
            selectedAccountName = childAccsKPI2[0].getLabel();              
            populateKP2Details();               
        } 
    }
    
    public void populatePartnerRevenue(){
      selectedPRAccountName = mapIdVsChildAccName.get(selectedPRAccountId);
      System.debug('NKC debug selectedPRAccountName ['+selectedPRAccountName+']');
      System.debug('NKC debug mapIdVsChildAccName ['+mapChildAccNameVsId+']');
 
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
      List<AggregateResult> results_rev = [SELECT Revenue_Type__c revType , SUM(Revenue_Amount__c) rev FROM Partner_EndUser_Data__c where Customer__c  =: selectedPRAccountName group by Revenue_Type__c];
      revenue_list = new List<revWrapper>();
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
      if(!revNameSet.contains('Revenue - Licence')) {  revWrap = new revWrapper(); revWrap.RevLabel = 'License'; revWrap.Revenue = 0;revwrap.RevName = 'Revenue - License'; revenue_list.add(revWrap); } 
     }
    
        public Pagereference populateAccKPIs(){
        PageReference PR;
        system.debug('-----------------------------selectedKP1AccountName------------------------------------'+selectedKP1AccountName);
        try{
        system.debug('-----------------------------selectedKPI1Quarter------------------------------------'+selectedKPI1Quarter);
        List<Partner_Quarterly_KPI__c> objPartnerKPIList = new List<Partner_Quarterly_KPI__c>();
        objPartnerKPIList = [SELECT id, Closure_Assessment__c,Training_Assessment__c,
                        Quality_Assessment__c,Total_KPI_Score__c,Year__c,Period_From__c,Period_To__c FROM Partner_Quarterly_KPI__c
                        WHERE Account_Name__c = :selectedKP1AccountName and Period__c =:selectedKPI1Quarter Limit 1];
        
        if(objPartnerKPIList.size() > 0)
        {
            objPartnerKPI = objPartnerKPIList[0];
            qualityAssessment = objPartnerKPI.Closure_Assessment__c;
            trainingAssessment = objPartnerKPI.Training_Assessment__c;
            qualityAssessment = objPartnerKPI.Quality_Assessment__c;
            closureAssessment = objPartnerKPI.Closure_Assessment__c;
            totalKPIScore = objPartnerKPI.Total_KPI_Score__c;
            kpiID = objPartnerKPI.id;
        }else{
            qualityAssessment = 0;
            trainingAssessment = 0;
            qualityAssessment = 0;
            closureAssessment = 0;
            totalKPIScore = 0;
        }
        return null;
        }
      catch(exception ex)
      {
            String subject = 'Error in the Partner Portal Landing Page.';
            String htmlBody1 = 'Hi <br/><br/>';
            htmlBody1 += 'Error Details :' + ex.getMessage();            
            SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1);  
            PageReference newpg;
            newpg = new Pagereference('/PartnerPortal_ErrorPage?eParameter='+ex.getMessage());
            return newpg;
       }
    }
     
    public void populateKP2Details(){       
        objectKPI2 = [Select Id,Name,Account_Name__c,KPI_2_On_Time__c from Partner_KPI2__c where Account_Name__c =:selectedAccountName Limit 1];
        if(objectKPI2.size() > 0){
            kpi2TimeLineScore = objectKPI2[0].KPI_2_On_Time__c;
        }else{
            kpi2TimeLineScore = 0;
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
  
  public List<oppWrapper> getRecordsToDisplay_opp() {
        opp_list = new List<oppWrapper>();
        system.debug('---------------------AccountId------------------------'+AccountId);
        for (partner_portal_prospect__c opp :  returnPartneroppList(AccountId)) { 
            opp_list.add(new oppWrapper(opp)); 
        }
        return opp_list; 
     } 
       
  @RemoteAction
  global static List<Partner_EndUser_Data__c> eachRevenueDetails(String RecId , String acntName) {
  List<Partner_EndUser_Data__c> ped = [SELECT Id,End_User_Name__c,Product_Name__c,Quarter__c,Revenue_Amount__c,Revenue_Type__c,SAP_Account_ID__c FROM Partner_EndUser_Data__c where Revenue_Type__c =:RecId and Customer__c =:acntName];
  return ped;
  }
  
  @RemoteAction
  global static List<Partner_Certifications__c> eachCertDetails(String fName,String lName,String aName) {
  List<Partner_Certifications__c> certList = [SELECT Id,First_Name__c,Last_Name__c,Pass_Fail__c,Test_Code__c,Test_Date__c,Test_Name__c,Email__c FROM Partner_Certifications__c where First_Name__c =:fName and Last_Name__c =:lName and Account_Name__c =:aName];
  return certList;
  }
  
  @RemoteAction
  global static List<Partner_Training_Info__c> eachTrainDetails(String fName,String lName,String aName) {
  List<Partner_Training_Info__c> trainList = [SELECT Id,View_Central_Registration_Number__c,Course_Start_Date__c,Course_End_Date__c,Course_Name__c,Email__c  FROM Partner_Training_Info__c where First_Name__c =:fName and Last_Name__c =:lName and Account_Name__c =:aName];
  return trainList;
  }
  
  @RemoteAction
  global static List<Partner_KPI2__c> eachKPI2Details(String aName,String region) {
  List<Partner_KPI2__c> kpi2Data = [Select Id,Name,Account_Name__c,KPI_2_On_Time__c,Sum_of_PO_s_Not_On_Time__c,Sum_of_PO_s_On_Time__c,Total_PO_s__c from Partner_KPI2__c where Account_Name__c =:aName];
  return kpi2Data;
  }
  
  @RemoteAction
  global static List<Partner_KPI2_PO_Details__c> eachKPI2DetailsP_info(String acntId,String region) {
  List<Partner_KPI2_PO_Details__c> kpi2Data = [Select Id,Name,End_User_Name__c,Maintenance_End_Date__c,PO_Date__c,PO_Number__c from Partner_KPI2_PO_Details__c where Account_Name__c =:acntId];
  return kpi2Data;
  } 
  
  public boolean inCommunity() {
  return Network.getNetworkId() != null;
  }
  
   private String setDuration(Partner_Quarterly_KPI__c objPartnerKPI)
    {
        strDuration = '';
     /*   if(objPartnerKPI.Quarter__c == 1)
            strDuration += 'Jan-Mar';
        else if(objPartnerKPI.Quarter__c == 2)
            strDuration += 'Apr-Jun';
        else if(objPartnerKPI.Quarter__c == 3)
            strDuration += 'Jul-Sep';
        else if(objPartnerKPI.Quarter__c == 4)
            strDuration += 'Oct-Dec';
            
        strDuration +=  ' ' + String.valueOf(objPartnerKPI.Year__c); */
        return strDuration;
    }

   public String getMonthName(Integer monNum)
   {
    String monName = '' ;
    if(monNum == 1) {monName = 'Jan' ;}
    else if(monNum == 2) {monName = 'Feb' ;}
    else if(monNum == 3) {monName = 'Mar' ;}
    else if(monNum == 4) {monName = 'Apr' ;}
    else if(monNum == 5) {monName = 'May' ;}
    else if(monNum == 6) {monName = 'Jun' ;}
    else if(monNum == 7) {monName = 'Jul' ;}
    else if(monNum == 8) {monName = 'Aug' ;}
    else if(monNum == 9) {monName = 'Sep' ;}
    else if(monNum == 10) {monName = 'Oct' ;}
    else if(monNum == 11) {monName = 'Nov' ;}
    else if(monNum == 12) {monName = 'Dec' ;}
    return monName;
   }

}