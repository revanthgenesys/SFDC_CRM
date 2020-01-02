//Naresh Kumar      02/10/2014
public without sharing class PartnerApplicationDetailExtension 
{
    public Partner_Application__c partnerApplication {get;set;}
    public Account paAccount {get;set;}
    public Contact paContact {get;set;}
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Map<String,String> mapFieldLabelVsHelpTextContact {get;set;}
    public List<PartnerApplicationController.wrapperExecMgmtList> execMgmtTeam {get;set;}
    public List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnership {get;set;}
    public List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList {get;set;}
    public  List<PartnerApplicationController.WrapperpaSummaryRatesList> appsummaryRateList {get;set;}
    
    public String currentUserProfile {get;set;}
    public List<Partner_Application_Head_Count__c> list_PAHeadCount {get; set;}
    
    private Id applicationId;
    
    public List<String> list_Categories {get; private set;}
    public Map<String,List<String>> map_CategoryToCountries {get; private set;}
    public Map<String,List<String>> map_CategoryToOffering {get; private set;}
    public Boolean blnDoTermsExist {get; private set;}
    
    public boolean blnTechAndServiceCnt{get;set;}
    public boolean isTechPartner{get;set;}
    public List<Partner_Application_Industry_Vertical__c> list_IndustryNVertical{get;set;}
    
    public map<string,list<Partner_Application_Category_and_Country__c>> categoryToPACCMap{get;set;}
    public map<string,integer> categoryRowspan{get;set;}
    
    public PartnerApplicationDetailExtension(ApexPages.StandardController stdController){     
      
      try{  
      system.debug('+++aa +++');
        applicationId = ApexPages.currentPage().getParameters().get('id');
        List<Partner_Application__c> partnerApplications = (List<Partner_Application__c>)Database.query(PartnerApplicationControllerHelper.prepareQuery(applicationId));
        system.debug('+++aa 11+++');
        blnTechAndServiceCnt = false;
          isTechPartner=false;
        if(!partnerApplications.isEmpty()){
            partnerApplication = partnerApplications[0];
            Id contactId = partnerApplication.Contact__c;
            Id accountId = partnerApplication.Account__c;
            //contactId = '003U000000wG2k0IAC';//'003Z000000db1yU';
            //accountId = '001U000000mE92sIAC';//'001Z000000itIGX';
            system.debug('+++aa 33+++');
            paAccount = PartnerApplicationControllerHelper.getAccount(accountId);
            paContact = PartnerApplicationControllerHelper.getContact(contactId);
            system.debug('+++aa 44+++');
            paContact.LastName = (paContact.FirstName == null ? '' : paContact.FirstName) + ' ' + paContact.LastName;
            
            if(partnerApplication.Technology_and_Service_Provider_Count__c >0 && partnerApplication.Status__c == 'Approved')
              blnTechAndServiceCnt = true;
              
           system.debug('+++aa 66+++');
           
            init(applicationId);            
        }   
      }catch(exception ex)
        {
            callException(ex);
        }        
    }
    
    public void init(String applicationId){
      
      try{
      system.debug('+++mapFieldLabelVsHelpText +++'+ mapFieldLabelVsHelpText );
        mapFieldLabelVsHelpText = PartnerApplicationControllerHelper.getMapOfFieldsAndHelpText();
        system.debug('+++mapFieldLabelVsHelpText +++'+ mapFieldLabelVsHelpText );
        mapFieldLabelVsHelpTextContact = PartnerApplicationControllerHelper.getMapOfFieldsAndHelpTextContact();
        execMgmtTeam = PartnerApplicationControllerHelper.intializeExeMgmgTeamList(applicationId);
        companyOwnership = PartnerApplicationControllerHelper.intializeCompanyOwnershipList(applicationId);
        paEmployeeList = PartnerApplicationControllerHelper.intializeEmployeeList(applicationId);
        appsummaryRateList = PartnerApplicationControllerHelper.intializeSummaryRatesList(applicationId);
        intializeCategoryAndCountryList();
        initializeEmpHeadCount();
        GetIndusAndVerticals();
        currentUserProfile = PartnerApplicationControllerHelper.getCurrentUserProfile();
        blnDoTermsExist = [SELECT count() FROM Partner_Business_Terms_and_Conditions__c WHERE
                          Partner_Application__c = :applicationId LIMIT 1] > 0 ? true:false;
        }catch(exception ex)
        {
            callException(ex);
        }                 
                          
     }
     
     
    public  void initializeEmpHeadCount()
    {
         list_PAHeadCount = new List<Partner_Application_Head_Count__c>();
         try{
       if(applicationId != null)
         {
             for(Partner_Application_Head_Count__c eachempHc :  [SELECT Delivery_capabilities__c,Development_Team__c,Partner_Application__c,Professional_Services__c,Project_Management__c,Region__c,Technical_Support_Team__c,Total_Headcount__c FROM Partner_Application_Head_Count__c WHERE Partner_Application__c = :applicationId order by Region__c])
            {
              list_PAHeadCount.add(eachempHc);
             }  
         }
         }catch(exception ex)
         {
           callException(ex);
         }                 
    }
     
   
    public pageReference goToTBusinessTerms(){
        return new PageReference('/apex/PartnerBusinessTerms?appId=' + applicationId);
    }
    
    public void intializeCategoryAndCountryList()
    {
      try{
        if(applicationId != null)
        {
            map_CategoryToCountries = new Map<String,List<String>>();
            map_CategoryToOffering  = new Map<String,List<String>>();
            categoryToPACCMap = new map<string,list<Partner_Application_Category_and_Country__c>>();
            categoryRowspan = new map<string,integer>();
            
            list_Categories = new List<String>();
            List<Partner_Application_Category_and_Country__c> list_ExistingCombinations = [SELECT Id,Name,Category__c,
                                    Country__r.Name,PlatformType__c,Company_partner_CX_space__c,Genesys_AppFoundry__c,
                                    Project_priority_in_your_Development__c,Reason_for_integration__c 
                                    FROM Partner_Application_Category_and_Country__c
                                    WHERE Partner_Application__c =: applicationId
                                    ORDER BY Category__c,Country__r.Name];
            for(Partner_Application_Category_and_Country__c objCombination : list_ExistingCombinations)
            {
                /*if(map_CategoryToCountries.containsKey(objCombination.Category__c))
                {
                    map_CategoryToCountries.get(objCombination.Category__c).add(objCombination.Country__r.Name);
                    map_CategoryToOffering.get(objCombination.Category__c).add(objCombination.PlatformType__c);
                }    
                else
                {
                    map_CategoryToCountries.put(objCombination.Category__c,new List<String>{objCombination.Country__r.Name});
                    map_CategoryToOffering.put(objCombination.Category__c,new List<String>{objCombination.PlatformType__c});
                }*/
                
                if(categoryToPACCMap.containsKey(objCombination.Category__c)){
                    categoryToPACCMap.get(objCombination.Category__c).add(objCombination);
                }
                else{
                    categoryToPACCMap.put(objCombination.Category__c,new List<Partner_Application_Category_and_Country__c>{objCombination});
                }
                
            }
            
            list_Categories.addAll(map_CategoryToCountries.keySet());
            list_Categories.sort();
            
            //System.Debug('categoryToPACCMap--->'+categoryToPACCMap);
            Set<String> s1 = new Set<String>(categoryToPACCMap.keyset());
             System.Debug('S1--->'+s1);
            if(s1.contains('Technology Partner')){
                isTechPartner=true;
            }
            for(string catStr:categoryToPACCMap.keyset()){
                categoryRowspan.put(catStr,categoryToPACCMap.get(catStr).size());
            }
        }
        
        
        
         }catch(exception ex)
         {
            callException(ex);
         }  
    }
    
  public void callException( Exception ex){
  
      String subject = 'Error in the Application Detail Page.';
            String htmlBody1 = 'Hi <br/><br/>';
            htmlBody1 += 'Error Details :' + ex.getMessage();            
            SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1);  
            PageReference newpg;
          newpg = new Pagereference('/PartnerPortal_ErrorPage?eParameter='+ex.getMessage());
  
  }
    private void GetIndusAndVerticals()
    {
      list_IndustryNVertical= new List<Partner_Application_Industry_Vertical__c>();
      system.debug('+++++partnerApplication .id++++'+partnerApplication.id);
      if(partnerApplication.id != null)
        list_IndustryNVertical = [select id,Partner_Application__c,Industry__c,Vertical_Markets__c from Partner_Application_Industry_Vertical__c where Partner_Application__c =: partnerApplication.id];
      
      system.debug('+++++list_IndustryNVertical++++'+list_IndustryNVertical);
      if(list_IndustryNVertical == null || list_IndustryNVertical.size() <= 0)
      {
        list_IndustryNVertical= new List<Partner_Application_Industry_Vertical__c>();
      }
          
    }
}