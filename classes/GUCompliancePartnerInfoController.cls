public class GUCompliancePartnerInfoController {
    public boolean hasErrors {get; set;}  
    
    public String accountId {get; set;}  
    public String pName {get; set;}
    public String pType {get; set;}
    public String pTier {get; set;}
    public String pSize {get; set;}
    public boolean isPartnerUser {get; set;}
    public boolean displayTrainingTab {get; set;}
    public list<string> currentSpecialization{
        get{if(currentSpecialization==null){
                currentSpecialization = new list<string>();
            }
            return currentSpecialization;
        }
        set;}
   
    public String strPartnerCategory {get; set;}
    
    public List<PartnerComplianceInfoWrapper> data {get; set;}
    
    // Variables to display Certifications List block
    public String certificationListTestCode {get; set;}
    public String certificationListType {get; set;}
    public String certificationListTypeToDisplay {get; set;}
    public List<Partner_Certifications__c> certificationList {get; set;}  

    public Boolean showTrainingDetails {get; set;}
    public Boolean showCourse {get; set;}
    public Integer trainingRequirement {get; set;}
    
    public Integer trainingDone {get; set;}
    public List<docebo_v3__CourseEnrollment__c> trainingList {get; set;}
  
    //public Integer litmosTrainingDone {get; set;}
    //public List<Litmos__UserProgramResult__c> litmosTrainingList {get; set;}    
    //public List<Litmos__UserLearningPathResult__c> litmosLearningPathUsersList {get; set;}
    
    public String selectedPartnerType {get; set;}   
    public List<selectOption> partnerTypes {get; set;}
    
    public String selectedPartnerCategory {get; set;}   
    public List<selectOption> partnerCategories {get; set;}
    
    // Added by Vijay  - Start
    public boolean blnShowNewSpecialization {get; set;} // This variable is used for conditional display/hide New Specialization on UI. Usage: Click on "Add New Specialization" Button to set to TRUE.
    public List<SelectOption> list_SpecilaizOptions {get; set;}
    public List<String> strSelectedSpecialization {get; set;}
    
    public List<SelectOption> list_SpecByOffer {get; set;}
    public List<String> list_SelectedSpecByOff {get; set;} 
    
    public Static final String TRAINING_SALES_PEOPLE_GROUP = 'Trained Sales People';
    public Static final String CERTIFIED_PEOPLE_GROUP = '# of Certifications';
    public Static final String SPECIALIZATION_GROUP = '# of Specializations';
    
    public List<CS_Partner_Offering_Type__c> list_Offerings {get; set;}
    public List<CS_Specialization__c> list_SepcByOff {get; set;}
    
    public Map<String, boolean> map_BlnShowHideTreeGroup {get; set;}
    public Map<String, boolean> map_BlnSelectedSpec {get; set;}
    public Map<String, Set<String>> map_OfferingGroupSpec {get; set;}
    public boolean choosenSpec {get; set; }
    
    public String strSpecialAdded {get; set;}
    public String strCurrSpecial {get; set;}
    public list<CS_Solution_Group__c> list_SoultionGrp {get; set;}
    
    public List<PartnerComplianceInfoWrapper> objAddSepcData {get; set;}
    public Map<String,Set<String>> map_CurrentSpec {get; set;}
    
    public boolean blnShowHideSpecDetail {get; set;}
    public boolean blnShowHideAddedSepDetail {get; set;}
    public boolean blnShowHideCurrSepDetail {get; set;}
    public String strSelectedSpec {get; set;}
    public List<String> selectedSpec {get; set;}
    //Map<String , List<Litmos__UserProgramResult__c>> map_LCertBySG {get; set;}
    Map<String , List<docebo_v3__CourseEnrollment__c>> map_DoceboBySG {get; set;}
    
    Map<String , List<Partner_Certifications__c>> map_PCertBySG {get; set;}
    //Map<String , List<Litmos__UserLearningPathResult__c>> map_LearnPathCertBySG {get; set;}
    
    public CS_Helper__c objHelpInfo {get; set;}
    public boolean blnShowHelper {get; set;}
    public boolean blnShowSpecStr {get; set;}
    public boolean blnShowCurrentStr {get; set;}
    public Map<String, Set<String>> map_SGCertCode {get; set;}
    public Map<String,String> map_CourseInfo {get; set;}
    public boolean blnShowAutoSelection {get; set;}
    // Added by Vijay  - End
    
    public GUCompliancePartnerInfoController(String accountId){
      displayTrainingTab = false;
        
        // Added by Vijay  - Start
        blnShowNewSpecialization= false;
        strSelectedSpecialization = new List<String>{'None'};
        blnShowHideSpecDetail = false;
        selectedSpec = new List<String>();
        objHelpInfo = CS_Helper__c.getInstance('GU Compliance Specialization Helper');
        blnShowHelper = true;
        blnShowSpecStr = false;
        blnShowCurrentStr =  false;
        blnShowAutoSelection = true;
        // Added by Vijay  - End
        
        Account a = [SELECT Id, Name, PartnerType__c, Partner_Tier__c, Partner_Business_Size__c FROM Account WHERE Id = :accountId];
      if(a != null && a.PartnerType__c != null){
            /* RAO
            for(String ptypeVar : a.PartnerType__c.split(';')){
                if(CS_Partner_Type__c.getall().keySet().contains(ptypeVar)){
                    displayTrainingTab = true;
                    break;
                }
            }
          */
            Set<String> partnerCategoriesSet = new Set<String>();
            for(String ptypeVar : a.PartnerType__c.split(';')){
                if(CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar) != NULL && 
                    CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c != NULL && 
                        CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c != 'Technology')
                {
                    partnerCategoriesSet.add(CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c);    
                }      
            }
            if(PartnerCategoriesSet.size() > 0){
                displayTrainingTab = true;
            }
        }       
        List<CS_Course__c> list_Course = [SELECT Id, Name, Label__c FROM CS_Course__c];
        map_CourseInfo = new Map<String,String>();
        
        for(CS_Course__c objCourse : list_Course){
            map_CourseInfo.put(objCourse.Name, objCourse.Label__c);
        }
        
    }
    
    public GUCompliancePartnerInfoController(){
      data = new List<PartnerComplianceInfoWrapper>();
        hasErrors = false;
        isPartnerUser = false;
        displayTrainingTab = false;
      selectedPartnerType = 'Please Select';
        certificationListTestCode = '';
        certificationListType = '';       
        
        // Added by Vijay  - Start
        blnShowNewSpecialization = false;
        strSelectedSpecialization = new List<String>{'None'};
        strSpecialAdded = '';
        strCurrSpecial = '';
        blnShowHideSpecDetail = false;
        selectedSpec = new List<String>();
        objHelpInfo = CS_Helper__c.getInstance('GU Compliance Specialization Helper');
        blnShowHelper = true;
        blnShowSpecStr = false;
        blnShowCurrentStr =  false;
        blnShowAutoSelection = true;
        // Added by Vijay  - End
        
        accountId = ApexPages.currentPage().getParameters().get('aid'); 
        
        Account a;
        // Check whether the account Id has been passed to the Page
        if(accountId != null){
            a = [SELECT Id, Name, PartnerType__c, Partner_Tier__c, Partner_Business_Size__c FROM Account WHERE Id = :accountId];
        } else { // When no Account Id is passed check whether the logged in user id partner user or not and then use partner account
            User u = [SELECT id, name, ContactId, Contact.AccountId from User WHERE id =:UserInfo.getUserId()];
            if(u.ContactId != null){
                isPartnerUser = true;
                a = [SELECT Id, Name, PartnerType__c, Partner_Tier__c, Partner_Business_Size__c FROM Account WHERE Id = :u.Contact.AccountId];
            }
        }
        
        if(a == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Account is not selected, Please select Partner Account.'));
            hasErrors = true;
        } else {
            pName = a.Name;
            pType = a.PartnerType__c;
            pTier = a.Partner_Tier__c;
            pSize = a.Partner_Business_Size__c;
          accountId = a.Id;                        
            partnerCategories = new List<selectOption>();
            selectedPartnerCategory = 'Please Select';
          if(String.isBlank(pType)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Type is not set for Partner Account [ '+a.Name+' ].'));
                hasErrors = true;
          } else if(String.isBlank(pTier)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Tier is not set for Partner Account [ '+a.Name+' ].'));
                hasErrors = true;
            } else if(pSize == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Business Size is not set for Partner Account [ '+a.Name+' ].'));
                hasErrors = true;
            } else {
                Set<String> partnerCategoriesSet = new Set<String>();
                for(String ptypeVar : pType.split(';')){
                    if(CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar) != NULL && 
                        CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c != NULL && 
                            CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c != 'Technology')
                    {
                        partnerCategoriesSet.add(CS_Partner_Type_Category_Mapping__c.getInstance(ptypeVar).Category__c);    
                    }      
                }
                if(PartnerCategoriesSet.size() > 0){
                    displayTrainingTab = true;    
                }
        partnerCategories.add(new selectOption('Please Select','Please Select'));
                if(partnerCategoriesSet.size() > 0){
                    List<String> partnerCategoriesList = new List<String>();
                    partnerCategoriesList.addAll(partnerCategoriesSet);
                    partnerCategoriesList.sort();
                    if(partnerCategoriesList.size() == 1){
                        partnerCategories.add(new selectOption(partnerCategoriesList[0],partnerCategoriesList[0]));
                        selectedPartnerCategory = partnerCategoriesList[0];
                        retrieveComplianceInfo();
                    } else {
                        for(String ptypeVar : partnerCategoriesList){
                            partnerCategories.add(new selectOption(ptypeVar,ptypeVar)); 
                        }
                    }
                }
                if(partnerCategories.size() == 1 && partnerCategories[0].getLabel() == 'Please Select'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Type [ '+pType+' ] has no GU Compliance configuration.'));
                    hasErrors = true;
                }
            }
        }
        
        List<CS_Course__c> list_Course = [SELECT Id, Name, Label__c FROM CS_Course__c];
        map_CourseInfo = new Map<String,String>();
        
        for(CS_Course__c objCourse : list_Course){
            map_CourseInfo.put(objCourse.Name, objCourse.Label__c);
        }
    }
    
    public String getPartnerCategory(String strPartnerType){
        return CS_Partner_Type_Category_Mapping__c.getInstance(strPartnerType).Category__c;
    }
    
    public void retrieveComplianceInfo(){
      data = new List<PartnerComplianceInfoWrapper>();
        certificationListTestCode = '';
      certificationListType = '';
        showTrainingDetails = false;
        currentSpecialization = new list<string>();
        showCourse = false;
        
        // Added by Vijay  - Start
        blnShowNewSpecialization = false;
        // Added by Vijay  - End
        // strPartnerCategory = getPartnerCategory(selectedPartnerType);
      List<GU_Compliance_Requirement__c> requirementsList = [SELECT Id, Name, Compliance_Requirement__c, Required_Number__c 
                                                               FROM GU_Compliance_Requirement__c
                                                               WHERE Partner_Type__c = :selectedPartnerCategory AND
                                                               Partner_Tier__c = :pTier AND
                                                               Partner_Size__c = :pSize
                                                               ];
        System.debug('requirementsList = ' + requirementsList);
        if(selectedPartnerCategory == 'Please Select'){
          // do nothing ...
        } else if(requirementsList.isEmpty()){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Your Partner Tier/Type has no GU Compliance configuration'));
            hasErrors = true;
            // displayTrainingTab = false;
        } else {
            Map<String, Integer> requirementsMap = new Map<String, Integer>();
            for(GU_Compliance_Requirement__c gucr : requirementsList){
                if(gucr.Compliance_Requirement__c.equalsIgnoreCase(TRAINING_SALES_PEOPLE_GROUP) ){
                    requirementsMap.put(gucr.Compliance_Requirement__c, gucr.Required_Number__c.intValue());
                }
                else if(gucr.Compliance_Requirement__c.equalsIgnoreCase(SPECIALIZATION_GROUP)){
                    requirementsMap.put(gucr.Compliance_Requirement__c, gucr.Required_Number__c.intValue());
                }
                else {
                    if( !requirementsMap.containsKey(CERTIFIED_PEOPLE_GROUP) ){
                        requirementsMap.put(CERTIFIED_PEOPLE_GROUP, gucr.Required_Number__c.intValue());
                    }else{
                        requirementsMap.put(CERTIFIED_PEOPLE_GROUP, requirementsMap.get(CERTIFIED_PEOPLE_GROUP)+ gucr.Required_Number__c.intValue());
                    }
                }
                
            }
            System.debug('Req Map : '+requirementsMap);
            trainingRequirement = requirementsMap.get(TRAINING_SALES_PEOPLE_GROUP) != null ? requirementsMap.get(TRAINING_SALES_PEOPLE_GROUP) : 0;

            //Mukunth updated from Litmos to Docebo on 15-NOV-2019
            //litmosTrainingDone = [SELECT Count() FROM Litmos__UserProgramResult__c  WHERE Litmos__Completed__c = true AND Litmos__UserID__r.Contact.AccountId = :accountId];    
            trainingDone = [select count() from docebo_v3__CourseEnrollment__c where 
                            (docebo_v3__DoceboUser__r.docebo_v3__Contact__r.AccountId =  :accountId 
                            OR docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.AccountId =  :accountId) AND docebo_v3__Status__c='Completed'];
            
            // New Change to Litmos Learning Path - Start
            /*integer intLearnigPathResDoneCount = [SELECT Count() 
                                                  FROM Litmos__UserLearningPathResult__c 
                                                  WHERE Litmos__Completed__c = TRUE 
                                                    AND Litmos__UserID__r.Contact.AccountId = :accountId];
                                                    //AND Litmos__ContactID__r.AccountId = :accountId];
            litmosTrainingDone += (intLearnigPathResDoneCount != NULL) ? intLearnigPathResDoneCount : 0;*/

            // New Change to Litmos Learning Path - End
            List<CS_Partner_Certification_Group__c> cspCertGroupsCS = [SELECT Id, Name, DisplayOrder__C, Certification_Prefix__c  FROM CS_Partner_Certification_Group__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__C];
    
            // Certificatons expired in last 90 days
            AggregateResult[] partnerExpiredLast90CertsAR = [SELECT  COUNT(Name) certCount FROM Partner_Certifications__c 
                                                      WHERE Account__c = :accountId AND Pass_Fail__c = 'P' AND Expiry_Date__c = LAST_N_DAYS:90];
                                                      //GROUP BY Genesys_Test_Code__c];
            
            // Certificatons expiring in next 90 days 
            AggregateResult[] partnerExpiringNext90CertsAR = [SELECT  COUNT(Name) certCount FROM Partner_Certifications__c 
                                                      WHERE Account__c = :accountId AND Pass_Fail__c = 'P' AND Expiry_Date__c = NEXT_N_DAYS:90];
                                                      //GROUP BY Genesys_Test_Code__c];
            
            // Certificatons expiring this year which are not yet expired   
            AggregateResult[] partnerExpiringThisYearCertsAR = [SELECT  COUNT(Name) certCount FROM Partner_Certifications__c 
                                                      WHERE Account__c = :accountId AND Pass_Fail__c = 'P' AND Expiry_Date__c  >= TODAY AND Expiry_Date__c = THIS_YEAR];
                                                      // GROUP BY Genesys_Test_Code__c];
    
            // Active Certificatons as of Today   
            AggregateResult[] partnerCurrentCertsAR = [SELECT COUNT(Name) certCount FROM Partner_Certifications__c 
                                                      WHERE Account__c = :accountId AND Pass_Fail__c = 'P' AND (Expiry_Date__c = NULL OR Expiry_Date__c  >= TODAY)];
                                                     // GROUP BY Genesys_Test_Code__c];
            
            Map<String, List<CertificationInfo>> partnerCertificationsGrouped = new Map<String, List<CertificationInfo>>();
            for(CS_Partner_Certification_Group__c cs : cspCertGroupsCS){
                List<CertificationInfo> ciList = new List<CertificationInfo>();

                ciList.add(new CertificationInfo(   'G', 
                                  'C',  
                                  (Integer)partnerCurrentCertsAR[0].get('certCount'), (Integer)partnerExpiredLast90CertsAR[0].get('certCount') , 
                                                   (Integer)partnerExpiringNext90CertsAR[0].get('certCount'), (Integer)partnerExpiringThisYearCertsAR[0].get('certCount')
                                                 )
            );
                partnerCertificationsGrouped.put(cs.Name, ciList);
                
            }
            
            getNewSpecializationDetails();
            integer intSpecCount = 0 ; 
            List<CertificationInfo> list_DummyCert = new List<CertificationInfo>();
            for(String strKey : map_BlnSelectedSpec.keySet()){
                if(map_BlnSelectedSpec.get(strKey)) {
                    intSpecCount++;
                    list_DummyCert.add(new CertificationInfo('G' , 'C/T' , 1 , 0 , 0 , 0));
                } 
            }
            System.Debug('list_DummyCert--->'+list_DummyCert);
            for(CS_Partner_Certification_Group__c cs : cspCertGroupsCS){
                if(!cs.Name.equalsIgnoreCase('# of Specializations'))
                    data.add(new PartnerComplianceInfoWrapper(cs.Name,  
                                                          requirementsMap.keySet().contains(cs.Name) ?  requirementsMap.get(cs.Name) : 0, 
                                                          partnerCertificationsGrouped.keySet().contains(cs.Name) ? partnerCertificationsGrouped.get(cs.Name) : new List<CertificationInfo>()));
                else{
                    data.add(new PartnerComplianceInfoWrapper(cs.Name,  requirementsMap.keySet().contains(cs.Name) ?  requirementsMap.get(cs.Name) : 0 ,  list_DummyCert ));
                }
          
            }
            System.Debug('dataspec--->'+data);
            blnShowNewSpecialization = false;
        }
    }
    
    
    public PageReference partnerTypeChanged(){
        retrieveComplianceInfo();
        return null;
    }
    
    public PageReference getCertificationDetails(){
        showTrainingDetails = false;
        currentSpecialization = new list<string>();
        showCourse = false;
        // Added by Vijay  - Start
        blnShowNewSpecialization = false;
        blnShowHelper = false;
        // Added by Vijay  - End
        // AND Genesys_Test_Code__c = :certificationListTestCode
        if(certificationListType == 'CURRENT'){
            certificationList = [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                             FROM Partner_Certifications__c 
                             WHERE Account__c = :accountId  AND Pass_Fail__c = 'P' AND (Expiry_Date__c = NULL OR Expiry_Date__c  >= TODAY)];
            certificationListTypeToDisplay = 'Done';
        } else if(certificationListType == 'PAST3MONTHS'){
            certificationList = [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                             FROM Partner_Certifications__c 
                             WHERE Account__c = :accountId  AND Pass_Fail__c = 'P' AND Expiry_Date__c = LAST_N_DAYS:90];
            certificationListTypeToDisplay = 'Has expired during past 3 month';
        } else if(certificationListType == 'NEXT3MONTHS'){
            certificationList = [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                             FROM Partner_Certifications__c 
                             WHERE Account__c = :accountId  AND Pass_Fail__c = 'P' AND Expiry_Date__c = NEXT_N_DAYS:90];
            certificationListTypeToDisplay = 'Will Expire Before 3 month';
        } else if(certificationListType == 'BEFOREEOY'){
            certificationList = [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                             FROM Partner_Certifications__c 
                             WHERE Account__c = :accountId AND Pass_Fail__c = 'P' AND Expiry_Date__c  >= TODAY AND Expiry_Date__c = THIS_YEAR];
            certificationListTypeToDisplay = 'Will Expire before the end of the year';
        }
            
        return null;
    }
    
    public PageReference getTrainingDetails(){
        certificationListTestCode = '';
      certificationListType = '';
        showTrainingDetails = true;
        currentSpecialization = new list<string>();
        ShowCourse = true;
        // Added by Vijay  - Start
        blnShowNewSpecialization = false;
        blnShowHideSpecDetail = false;
        blnShowHelper = false;
      // Added by Vijay  - End

      trainingList = new list<docebo_v3__CourseEnrollment__c>();
      trainingList = [select docebo_v3__CompletedLearningObjects__c, docebo_v3__Completion__c, docebo_v3__EnrollmentCompletionDate__c, docebo_v3__Course__c, 
                        docebo_v3__Credits__c, docebo_v3__DoceboUser__c, docebo_v3__EnrollmentStartDate__c, docebo_v3__EnrolmentId__c, docebo_v3__Score__c, 
                        docebo_v3__Status__c, docebo_v3__TimeInCourse__c, docebo_v3__Who__c,docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Contact_Full_Name__c,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Contact_Full_Name__c,docebo_v3__DoceboUser__r.docebo_v3__User__c,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__c,docebo_v3__Course__r.docebo_v3__Name__c,docebo_v3__Course__r.docebo_v3__CourseId__c
                        from docebo_v3__CourseEnrollment__c  
                        where (docebo_v3__DoceboUser__r.docebo_v3__Contact__r.AccountId = :accountId 
                        OR docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.AccountId = :accountId) AND docebo_v3__Status__c='Completed'];
       
       System.Debug('trainingList--->'+trainingList);
       System.Debug('trainingListsize--->'+trainingList.size());
            
        /*litmostrainingList = [SELECT Id,Litmos__Active__c,Litmos__Completed__c,Litmos__ProgramID__r.Litmos__LitmosID__c,Litmos__FinishDate__c,Litmos__LitmosID__c,
                                Litmos__PercentageComplete__c,Litmos__ProgramID__c,Litmos__Program_Code__c,Litmos__ProgramID__r.name,Litmos__StartDate__c,Litmos__ProgramID__r.Litmos__Code__c,
                                Litmos__status__c,Litmos__UserID__c,Litmos__User_Name__c,Litmos__ContactID__r.name,Name,OwnerId,Litmos__ContactID__r.Email 
                                FROM Litmos__UserProgramResult__c  WHERE Litmos__Completed__c = true 
                                AND Litmos__UserID__r.Contact.AccountId = :accountId  ORDER BY Litmos__FinishDate__c DESC NULLS LAST LIMIT 100];
        System.Debug('litmostrainingList--->'+litmostrainingList);*/
                                
        /*litmosLearningPathUsersList = [SELECT Id, Name, Litmos__LearningPathID__r.Litmos__Description__c,
                                       Litmos__LearningPathID__r.Litmos__LitmosID__c , Litmos__UserID__r.Contact.Name, Litmos__Completed__c, 
                                       Litmos__FinishDate__c, Litmos__StartDate__c, Litmos__LearningPathID__c, Litmos__UserID__c, Litmos__UserID__r.Email
                                      FROM Litmos__UserLearningPathResult__c  
                                      WHERE Litmos__Completed__c = TRUE AND Litmos__UserID__r.Contact.AccountId = :accountId
                                      ORDER BY Litmos__FinishDate__c LIMIT 100 ];*/
        return null;
    }

    public List<Partner_Certifications__c> getAllCertifications(){
        return [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, 
                Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                FROM Partner_Certifications__c WHERE Account__c = :accountId AND (Expiry_Date__c = NULL OR Expiry_Date__c  >= TODAY) ORDER BY Expiry_Date__c];
    } 
    
    // Added by Vijay - Start
    public PageReference getNewSpecializationDetails(){
        certificationListTestCode = '';
      certificationListType = '';
        showTrainingDetails = false;
        currentSpecialization = new list<string>();
        showCourse = false;
        blnShowNewSpecialization = true;
        blnShowHideSpecDetail = false;
        blnShowHelper = true;
        blnShowAutoSelection = true;
        list_SpecilaizOptions = getSpecilaizationData();
        System.debug(list_SpecilaizOptions);
        return NULL;
    }
    
    public PageReference getNewSpecializationDetailsUI(){
        getNewSpecializationDetails() ; blnShowHelper = false;
        return NULL;
    }
    
    public pagereference fetchcurrentSpecialization(){
        certificationListTestCode = '';
        showTrainingDetails = false;
        blnShowHideSpecDetail = false;
        blnShowHelper = false;
        currentSpecialization = new list<string>();
        getSpecializationByOffering();
        blnShowNewSpecialization = false;
        list<string> tempSpec = new list<string>();
        System.Debug('currentSpec2--->'+strCurrSpecial);
        if(!string.isBlank(strCurrSpecial)){
            tempSpec = strCurrSpecial.split('\\+');
        }
        for(string eachStr:tempSpec){
            currentSpecialization.add(eachStr.trim());
        }
        System.Debug('currentSpecialization--->'+currentSpecialization);
        return null;
    }
    
    private List<SelectOption> getSpecilaizationData(){
        List<SelectOption> list_SpecOpts = new List<SelectOption>();
        map_BlnShowHideTreeGroup = new Map<String , boolean>();
        list_Offerings = [SELECT id, Name, isActive__c, DisplayOrder__c, Specialization__c FROM CS_Partner_Offering_Type__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__c];
        for(CS_Partner_Offering_Type__c objOffering : list_Offerings){
            list_SpecOpts.add(new SelectOption(objOffering.Name , objOffering.Name));
            map_BlnShowHideTreeGroup.put(objOffering.Name, false);
        }
        getSpecializationByOffering();
        return list_SpecOpts;
    }
    
    public PageReference changeSelection(){
        if(String.isNotBlank(strSelectedSpec))
            map_BlnSelectedSpec.put(strSelectedSpec, !map_BlnSelectedSpec.get(strSelectedSpec)) ;
        
        system.debug('Selections ; '+map_BlnSelectedSpec);
        return NULL;
    }
    
    public PageReference getSpecializationByOffering(){
        // Step 1 - Start
        // Collect all Certifications from Litmos and Map it by Course Id code.

        //List<Litmos__UserProgramResult__c> list_LitmosCertUsers = getAllLitmosTrainings();mukunth commented

        //Mukunth commented below
        //Map<String, List<Litmos__UserProgramResult__c>> map_LCertUserbyCode = new Map<String, List<Litmos__UserProgramResult__c>>();
        
        /*for(Litmos__UserProgramResult__c objUser :  list_LitmosCertUsers){
            if(!map_LCertUserbyCode.containsKey(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c)){
                map_LCertUserbyCode.put(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c, new  List<Litmos__UserProgramResult__c>{objUser});
            }else{
                map_LCertUserbyCode.get(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c).add(objUser);
            }
        }*/

        List<docebo_v3__CourseEnrollment__c> list_DoceboCourses = getAllDoceboCourses();
        Map<string, List<docebo_v3__CourseEnrollment__c>> map_DCoursesEnrollment = new Map<string, List<docebo_v3__CourseEnrollment__c>>();

        for(docebo_v3__CourseEnrollment__c objUser :  list_DoceboCourses){
            if(!map_DCoursesEnrollment.containsKey(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c))){
                map_DCoursesEnrollment.put(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c), new  List<docebo_v3__CourseEnrollment__c>{objUser});
            }else{
                map_DCoursesEnrollment.get(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c)).add(objUser);
            }
        }


        System.Debug('DcertMap--->'+map_DCoursesEnrollment);
        
        // Collect all Learning Path Users From Litmos Learning Path and map then by Learning Path Id
        //List<Litmos__UserLearningPathResult__c> list_LitmosLearnPathUsers = getAllLitmosLearningPathUsers();
        
        /*Map<String, List<Litmos__UserLearningPathResult__c>> map_LLPathUsersByCode = new Map<String, List<Litmos__UserLearningPathResult__c>>();
        
        for(Litmos__UserLearningPathResult__c objUser :  list_LitmosLearnPathUsers){
            if(!map_LLPathUsersByCode.containsKey(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c)){
                map_LLPathUsersByCode.put(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c, new  List<Litmos__UserLearningPathResult__c>{objUser});
            }else{
                map_LLPathUsersByCode.get(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c).add(objUser);
            }
        }
        System.Debug('LLPathUsersByCode--->'+map_LLPathUsersByCode);*/
        
        // Collect all Certifications from Partner and Map it by Test code.
        List<Partner_Certifications__c> list_PartCertUser = getAllCertifications();
        Map<String, List<Partner_Certifications__c>> map_PCertUserbyCode = new Map<String, List<Partner_Certifications__c>>();
        
        for(Partner_Certifications__c objUser :  list_PartCertUser){
            if(!map_PCertUserbyCode.containsKey(objUser.Genesys_Test_Code__c)){
                map_PCertUserbyCode.put(objUser.Genesys_Test_Code__c, new  List<Partner_Certifications__c>{objUser});
            }else{
                map_PCertUserbyCode.get(objUser.Genesys_Test_Code__c).add(objUser);
            }
        }
        System.Debug('PCertMap--->'+map_PCertUserbyCode);
        // Step 1 - End
        // Step 2 - Start
        // Get Specialization with test code and Map Test codes by Specialization. 
        List<CS_Certification_Group_By_Specialization__c> list_CSCGS = [SELECT Id, Name,Certification_Codes__c,Solution_Group__c, Specialization__c FROM CS_Certification_Group_By_Specialization__c];
        System.Debug('list_CSCGS--->'+list_CSCGS);
        Map<String, Set<String>> map_CGSBySG = new Map<String, Set<String>>();
        
        for(CS_Certification_Group_By_Specialization__c objCG : list_CSCGS){
            List<String> list_Temp = new List<String>();
            if(String.isNotBlank(objCG.Certification_Codes__c)){
                if(objCG.Certification_Codes__c.contains(',')){
                    list_Temp.addAll(objCG.Certification_Codes__c.split(','));
                }else{
                    list_Temp.add(objCG.Certification_Codes__c);
                }
            }
            
            if(!map_CGSBySG.containsKey(objCG.Specialization__c)){
                map_CGSBySG.put(objCG.Specialization__c, new Set<String>(list_Temp));
            }else{
                map_CGSBySG.get(objCG.Specialization__c).addAll(list_Temp);
            }
        }
        System.debug('Map : '+map_CGSBySG);
        // Step 2 - End
        // Step 3 - Start
        // Check Qualification of each Specialization.
        Map<String , Map<String, boolean>> map_QualificationBySpecAndCode = new Map<String , Map<String, boolean>>();
        // Step a: Setup
        for(String strSpec : map_CGSBySG.keySet()){
            if(!map_QualificationBySpecAndCode.containsKey(strSpec)){
                map_QualificationBySpecAndCode.put(strSpec, new Map<String, boolean>());
            }
            if(map_CGSBySG.get(strSpec).size() > 0){
                for(String strCertCode : map_CGSBySG.get(strSpec)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode , false);
                }
            }else{
                map_QualificationBySpecAndCode.get(strSpec).put('NONE' , true);
            }
            
        }
        System.Debug('map_QualificationBySpecAndCode--->'+map_QualificationBySpecAndCode);
        // Step b: Check 
        for(String strSpec : map_QualificationBySpecAndCode.keySet()){
            for(String strCertCode : map_QualificationBySpecAndCode.get(strSpec).keySet()){
                if(map_PCertUserbyCode.containsKey(strCertCode)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }else if(map_DCoursesEnrollment.containsKey(strCertCode)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }/*else if(map_LLPathUsersByCode.containsKey(strCertCode) ){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }*/
            }
        }
        System.Debug('map_QualificationBySpecAndCode after--->'+map_QualificationBySpecAndCode);
        // Step 3 - End
        // Step 4 - Start
        // Collect all Offering Types by Specializations
        List<CS_Specialization__c> list_ComplSpec = [SELECT Id, Name, Offering_Type__c, Prerequisite__c FROM CS_Specialization__c ORDER BY Offering_Type__c NULLS First, Prerequisite__c NULLS FIRST];
        System.Debug('list_ComplSpec--->'+list_ComplSpec);
        Map<String, Set<String>> map_AllSpec = new Map<String, Set<String>>();
        map_CurrentSpec = new Map<String, Set<String>>();
        for(CS_Specialization__c objCS : list_ComplSpec){
            if(map_AllSpec.containsKey(objCS.Offering_Type__c)){
                map_AllSpec.get(objCS.Offering_Type__c).add(objCS.Name);
            }else{
                map_AllSpec.put(objCS.Offering_Type__c, new Set<String>{objCS.Name});
            }
            if(String.isBlank(objCS.Offering_Type__c)){
                map_AllSpec.put('Other', new Set<String>{objCS.Name});
            }
        }
        System.Debug('map_AllSpec--->'+map_AllSpec);
        // Collect Offering Types for above Specializations which are eligible.
        Map<String , boolean> map_SpecEligible = new Map<String, boolean>();
        
        for(String strSpec : map_QualificationBySpecAndCode.keySet()){
            boolean flag = true ;
            for(String strCode : map_QualificationBySpecAndCode.get(strSpec).keySet()){
                flag = flag && map_QualificationBySpecAndCode.get(strSpec).get(strCode);
            }
            map_SpecEligible.put(strSpec, flag);
        }
        System.Debug('map_SpecEligible--->'+map_SpecEligible);
        for(CS_Specialization__c objCS : list_ComplSpec){
            if(map_SpecEligible.containsKey(objCS.Name) && map_SpecEligible.get(objCS.Name)){
                if(map_CurrentSpec.containsKey(objCS.Offering_Type__c)){
                    map_CurrentSpec.get(objCS.Offering_Type__c).add(objCS.Name);
                }else{
                    map_CurrentSpec.put(objCS.Offering_Type__c, new Set<String>{objCS.Name});
                }
                if(String.isBlank(objCS.Offering_Type__c)){
                    map_CurrentSpec.put('Other', new Set<String>{objCS.Name});
                }
            }
            
        }
        System.Debug('map_CurrentSpec--->'+map_CurrentSpec);
        // Check if Core is eligible on PureConnect and PureEngage 
        // Step 4 - End
        // Step 5 - Start
        // Setup data to Present in UI
        map_BlnSelectedSpec = new Map<String , boolean>();
        map_OfferingGroupSpec = new Map<String, Set<String>>();
        list_SepcByOff = [SELECT Id, Name, Offering_Type__c, Prerequisite__c FROM CS_Specialization__c ORDER BY Offering_Type__c NULLS First, Prerequisite__c NULLS FIRST];
        System.Debug('list_SepcByOff--->'+list_SepcByOff);
        for(CS_Specialization__c objSpec :  list_SepcByOff){
            boolean blnAddSpec = false; 
            if( (String.isNotBlank(objSpec.Prerequisite__c) && map_CurrentSpec.containsKey(objSpec.Offering_Type__c) && 
                               map_CurrentSpec.get(objSpec.Offering_Type__c).contains(objSpec.Prerequisite__c)) ||
                 String.isBlank(objSpec.Prerequisite__c)
              )
            {
                blnAddSpec = true;
            }
            
            if(blnAddSpec){
                boolean flag = map_CurrentSpec.containsKey(objSpec.Offering_Type__c) ? (map_CurrentSpec.get(objSpec.Offering_Type__c)).contains(objSpec.Name) : false; 
                flag = (objSpec.Name.equalsIgnoreCase('Speech Analytics') ) ? map_CurrentSpec.containsKey('Other') : flag ;
                map_BlnSelectedSpec.put(objSpec.Name, flag);
                if(String.isNotBlank(objSpec.Offering_Type__c)){
                    if(!map_OfferingGroupSpec.containsKey(objSpec.Offering_Type__c))
                        map_OfferingGroupSpec.put(objSpec.Offering_Type__c, new Set<String>{objSpec.Name});
                    else
                        map_OfferingGroupSpec.get(objSpec.Offering_Type__c).add(objSpec.Name);
                }
            }
            
            /*
            else{
                map_OfferingGroupSpec.put('Other', new List<String>{objSpec.Name});
            }
            */
        }
        System.Debug('map_OfferingGroupSpec--->'+map_OfferingGroupSpec);
        // Step 5 - End
        getSelectedSpecializationDetails();
        return NULL;
    }
    
    /*
    public PageReference updateSelectedSpecializations(){
        List<GU_Compliance_Specialization__c> list_ComplSpec  = new List<GU_Compliance_Specialization__c>();
        for(String strKeyOff : map_OfferingGroupSpec.keySet()){
            for(String strKeySep : map_OfferingGroupSpec.get(strKeyOff)){
                if(map_CurrentSpec.containsKey(strKeyOff) && map_CurrentSpec.get(strKeyOff).contains(strKeySep)){
                    //strCurrSpecial = (strKeySep.equalsIgnoreCase('PureEngage - Core') || strKeySep.equalsIgnoreCase('PureCloud') ? strKeySep : strKeyOff +' - '+strKeySep ) + ' + ';
                }else if(map_BlnSelectedSpec.get(strKeySep)){
                    list_ComplSpec.add(new GU_Compliance_Specialization__c(Account__c = accountId , Offering_Type__c = strKeyOff , Specialization_Name__c = strKeySep));
                }
            }
        }
        if(!map_CurrentSpec.containsKey('Other') && map_BlnSelectedSpec.get('Speech Analytics')){
            list_ComplSpec.add(new GU_Compliance_Specialization__c(Account__c = accountId , Specialization_Name__c = 'Speech Analytics'));
        }
        insert list_ComplSpec;
        return NULL;
    }
    */
    public PageReference getSelectedSepcsDetailsByUser(){
        blnShowAutoSelection = false;
        getSelectedSpecializationDetails();
        return null;
    }
    
    public PageReference getSelectedSpecializationDetails(){
        strSpecialAdded = '';
        strCurrSpecial = '';
        blnShowHideSpecDetail = true;
        blnShowHideAddedSepDetail = false;
        blnShowHideCurrSepDetail = false;
        showTrainingDetails = false;
        currentSpecialization = new list<string>();
        showCourse = false;
        certificationListTestCode = '' ;
        selectedSpec = new List<String>();
        // Collected User selected Specialization and default specializations. 
        System.debug('Offering Map: '+map_OfferingGroupSpec);
        System.debug('Current Specs:'+map_CurrentSpec);
        for(String strKeyOff : map_OfferingGroupSpec.keySet()){
            for(String strKeySep : map_OfferingGroupSpec.get(strKeyOff)){
                boolean flag = blnShowAutoSelection ? map_CurrentSpec.containsKey(strKeyOff) && map_CurrentSpec.get(strKeyOff).contains(strKeySep) : map_BlnSelectedSpec.get(strKeySep);
                
                if(map_CurrentSpec.containsKey(strKeyOff) && map_CurrentSpec.get(strKeyOff).contains(strKeySep)){
                    strCurrSpecial += (strKeySep.equalsIgnoreCase('PureEngage - Core') || strKeySep.equalsIgnoreCase('PureCloud') ? strKeySep : strKeyOff +' - '+strKeySep ) + ' + ';
                    if(map_BlnSelectedSpec.get(strKeySep))
                        selectedSpec.add(strKeySep);
                }else if(map_BlnSelectedSpec.get(strKeySep)){
                    strSpecialAdded += (strKeySep.equalsIgnoreCase('PureEngage - Core') || strKeySep.equalsIgnoreCase('PureCloud') ? strKeySep : strKeyOff +' - '+strKeySep ) + ' + ';
                    selectedSpec.add(strKeySep);
                }
                
                System.debug('Key : '+strKeySep +' , Value :'+map_BlnSelectedSpec.get(strKeySep));
            }
        }
        if(map_CurrentSpec.containsKey('Other')){
            strCurrSpecial += 'Speech Analytics'+' + ';
            if(map_BlnSelectedSpec.get('Speech Analytics'))
                selectedSpec.add('Speech Analytics');
        }
        else if(map_BlnSelectedSpec.get('Speech Analytics')){
            strSpecialAdded +=  'Speech Analytics'+' + ';
            selectedSpec.add('Speech Analytics');
        }
        strCurrSpecial = strCurrSpecial.removeEndIgnoreCase(' + ');
        blnShowHideCurrSepDetail = String.isNotBlank(strCurrSpecial);
        
        strSpecialAdded = strSpecialAdded.removeEndIgnoreCase(' + ');
        blnShowHideAddedSepDetail = String.isNotBlank(strSpecialAdded) || blnShowHideCurrSepDetail;
        
        blnShowSpecStr =  String.isNotBlank(strSpecialAdded);
        blnShowCurrentStr =  blnShowHideCurrSepDetail;
        
        System.Debug('map_BlnSelectedSpec--->'+map_BlnSelectedSpec);
        System.debug('strCurrSpecial : '+strCurrSpecial);
        System.debug('blnShowHideCurrSepDetail : '+blnShowHideCurrSepDetail); 
        System.debug('strSpecialAdded : '+strSpecialAdded);
        System.debug('blnShowHideAddedSepDetail : '+blnShowHideAddedSepDetail);
        
        list_SoultionGrp = [SELECT Id, Name, DisplayOrder__C FROM CS_Solution_Group__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__C];
        collectSelectSpecs();
        return NULL;
    }
    //  map_PCertBySG , map_DoceboBySG
    public PageReference collectSelectSpecs(){
        objAddSepcData = New List<PartnerComplianceInfoWrapper>();
        List<CertificationInfo> tempCert = new List<CertificationInfo>();
        System.Debug('Selected Spec : '+selectedSpec);
        List<CS_Certification_Group_By_Specialization__c> list_CSCGS = [SELECT Id, Name,Certification_Codes__c,Solution_Group__c, Specialization__c 
                                                                        FROM CS_Certification_Group_By_Specialization__c
                                                                       WHERE Specialization__c IN :selectedSpec];
        System.debug(list_CSCGS);
        Map<String, List<CS_Certification_Group_By_Specialization__c>> map_CGSBySG = new Map<String, List<CS_Certification_Group_By_Specialization__c>>();
        
        for(CS_Certification_Group_By_Specialization__c objCG : list_CSCGS){
            if(!map_CGSBySG.containsKey(objCG.Solution_Group__c)){
                map_CGSBySG.put(objCG.Solution_Group__c, new List<CS_Certification_Group_By_Specialization__c>{objCG});
            }else{
                //map_CGSBySG.get(objCG.Solution_Group__c).add(objCG);
                if(map_CGSBySG.get(objCG.Solution_Group__c) != NULL)
                    map_CGSBySG.get(objCG.Solution_Group__c).add(objCG);
                else
                    map_CGSBySG.put(objCG.Solution_Group__c, new List<CS_Certification_Group_By_Specialization__c>{objCG});
            }
        }
        System.debug(map_CGSBySG);
        Map<String, integer> map_SGCertCount = new Map<String, integer>();
        map_SGCertCode = new Map<String, Set<String>>();
        
        for(String strKey : map_CGSBySG.keySet()){
            System.debug('Solution Group : '+strKey);
            for(CS_Certification_Group_By_Specialization__c obj : map_CGSBySG.get(strKey)){
                integer count = String.isNotBlank(obj.Certification_Codes__c) ? (obj.Certification_Codes__c.contains(',') ? obj.Certification_Codes__c.split(',').size() : 1 )  : 0;
                System.debug('Count : '+count);
                if(map_SGCertCount.containsKey(strKey)){
                    count = map_SGCertCount.get(strKey) + count ;
                }
                map_SGCertCount.put(strKey, count);
                Set<String> certCodes = new Set<String>();
                if(String.isNotBlank(obj.Certification_Codes__c) && obj.Certification_Codes__c.contains(',')){
                    certCodes = new Set<String>(obj.Certification_Codes__c.split(','));
                }else{
                    certCodes.add(obj.Certification_Codes__c);
                }
                if(map_SGCertCode.containsKey(strKey)){
                    map_SGCertCode.get(strKey).addAll(certCodes);
                }else{
                    map_SGCertCode.put(strKey , new Set<String>(certCodes));
                }
            }
        }
        System.debug(map_SGCertCount);
        System.debug(map_SGCertCode);
        
        // Get Specialization with test code and Map Test codes by Specialization. 
        List<CS_Certification_Group_By_Specialization__c> list_CSCGS_other = [SELECT Id, Name,Certification_Codes__c,Solution_Group__c, Specialization__c FROM CS_Certification_Group_By_Specialization__c];
        System.Debug('list_CSCGS--->'+list_CSCGS_other);
        Map<String, Set<String>> map_CGSBySG_Other = new Map<String, Set<String>>();
        
        for(CS_Certification_Group_By_Specialization__c objCG : list_CSCGS){
            List<String> list_Temp = new List<String>();
            if(String.isNotBlank(objCG.Certification_Codes__c)){
                if(objCG.Certification_Codes__c.contains(',')){
                    list_Temp.addAll(objCG.Certification_Codes__c.split(','));
                }else{
                    list_Temp.add(objCG.Certification_Codes__c);
                }
            }
            
            if(!map_CGSBySG_Other.containsKey(objCG.Specialization__c)){
                map_CGSBySG_Other.put(objCG.Specialization__c, new Set<String>(list_Temp));
            }else{
                map_CGSBySG_Other.get(objCG.Specialization__c).addAll(list_Temp);
            }
        }
        System.debug('Map : '+map_CGSBySG_Other);
        
        List<String> list_PartCodes = new List<String>();
        List<String> list_LitmoCodes = new List<String>();
        List<String> list_LearningPathCodes = new List<String>();
        
        for(String str : map_SGCertCode.keySet()){
            if(str.equalsIgnoreCase('Sales - Training') || str.equalsIgnoreCase('Pre-Sales')){
                if(map_SGCertCode.containsKey(str))
                for(String strCode : map_SGCertCode.get(str)){
                    if(strCode != NULL){
                        String temp = strCode.trim();
                        if(str.equalsIgnoreCase('Pre-Sales') && map_CGSBySG_Other.keyset().contains('PureEngage - Core') 
                           && (map_CGSBySG_Other.get('PureEngage - Core').contains(temp) || map_CGSBySG_Other.get('PureEngage - Core').contains(strCode) )){
                               list_LearningPathCodes.add(temp);
                           }
                        else{
                            list_LitmoCodes.add(temp);
                        }
                    }
                }
            }
            /*
            else if(str.equalsIgnoreCase('Pre-Sales')){
                if(map_SGCertCode.containsKey(str))
                for(String strCode : map_SGCertCode.get(str)){
                    if(strCode != NULL){
                        String temp = strCode.trim();
                        list_LearningPathCodes.add(temp);
                    } 
                }
            }
*/
            else{
                if(map_SGCertCode.containsKey(str))
                for(String strCode : map_SGCertCode.get(str)){
                    if(strCode != NULL){
                        String temp = strCode.trim();
                        list_PartCodes.add(temp);
                    } 
                }
            }
        }
        System.debug(list_LitmoCodes);
        System.debug(list_PartCodes);
        System.debug(list_LearningPathCodes);
        // Litmos Course User Info -Start
        //List<Litmos__UserProgramResult__c> list_LitmosCertUsers = getAllLitmosTrainings();mukunth commented
        
        //Map<String, List<Litmos__UserProgramResult__c>> map_LCertUserbyCode = new Map<String, List<Litmos__UserProgramResult__c>>();
        
        //Mukunth commented
        /*for(Litmos__UserProgramResult__c objUser :  list_LitmosCertUsers){
            if(!map_LCertUserbyCode.containsKey(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c)){
                map_LCertUserbyCode.put(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c, new  List<Litmos__UserProgramResult__c>{objUser});
            }else{
                map_LCertUserbyCode.get(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c).add(objUser);
            }
        }*/

        List<docebo_v3__CourseEnrollment__c> list_DoceboCourses = getAllDoceboCourses();
        Map<string, List<docebo_v3__CourseEnrollment__c>> map_DCoursesEnrollment = new Map<string, List<docebo_v3__CourseEnrollment__c>>();

        for(docebo_v3__CourseEnrollment__c objUser :  list_DoceboCourses){
            if(!map_DCoursesEnrollment.containsKey(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c))){
                map_DCoursesEnrollment.put(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c), new  List<docebo_v3__CourseEnrollment__c>{objUser});
            }else{
                map_DCoursesEnrollment.get(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c)).add(objUser);
            }
        }

        //map_LCertBySG = new Map<String, List<Litmos__UserProgramResult__c>>();
        map_DoceboBySG = new Map<String, List<docebo_v3__CourseEnrollment__c>>();
        // Litmos Learning Path - Start
        //List<Litmos__UserLearningPathResult__c> list_LearningPathUsers = getAllLitmosLearningPathUsers();
        
        //Map<String, List<Litmos__UserLearningPathResult__c>> map_LearningPathUserbyCode = new Map<String, List<Litmos__UserLearningPathResult__c>>();
        
        /*for(Litmos__UserLearningPathResult__c objUser :  list_LearningPathUsers){
            if(!map_LearningPathUserbyCode.containsKey(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c)){
                map_LearningPathUserbyCode.put(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c, new  List<Litmos__UserLearningPathResult__c>{objUser});
            }else{
                map_LearningPathUserbyCode.get(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c).add(objUser);
            }
        }*/
        //map_LearnPathCertBySG = new Map<String, List<Litmos__UserLearningPathResult__c>>();
        
        
        for(String strSG : map_SGCertCode.keySet()){
            if(strSG.equalsIgnoreCase('Sales - Training')  || strSG.equalsIgnoreCase('Pre-Sales')){
                if(map_SGCertCode.containsKey(strSG) && map_SGCertCode.get(strSG).size() > 0){
                    for(String strCode : map_SGCertCode.get(strSG)){
                        /*if(strSG.equalsIgnoreCase('Pre-Sales') && map_CGSBySG_Other.keyset().contains('PureEngage - Core') 
                           && map_CGSBySG_Other.get('PureEngage - Core').contains(strCode)){
                               if(strCode != NULL && map_LearningPathUserbyCode.containsKey(strCode)){
                                   if(!map_LearnPathCertBySG.containsKey(strSG)){
                                       map_LearnPathCertBySG.put(strSG, new List<Litmos__UserLearningPathResult__c>(map_LearningPathUserbyCode.get(strCode)));
                                   }else{
                                       map_LearnPathCertBySG.get(strSG).addAll((map_LearningPathUserbyCode.get(strCode)));
                                   }
                               }
                           }*/
                        //else{
                            if(strCode != NULL && map_DCoursesEnrollment.containsKey(strCode)){
                                if(!map_DoceboBySG.containsKey(strSG)){
                                    map_DoceboBySG.put(strSG, new List<docebo_v3__CourseEnrollment__c>(map_DCoursesEnrollment.get(strCode)));
                                }else{
                                    map_DoceboBySG.get(strSG).addAll((map_DCoursesEnrollment.get(strCode)));
                                }
                            }
                        //}
                    }
                }else{
                    //map_LearnPathCertBySG.put(strSG, new List<Litmos__UserLearningPathResult__c>());
                    //map_LCertBySG.put(strSG, new List<Litmos__UserProgramResult__c>());
                    map_DoceboBySG.put(strSG, new List<docebo_v3__CourseEnrollment__c>());
                }
            }
        }
        // Litmos Course User Info -End
        // Partner Certificate - Start
        List<Partner_Certifications__c> list_PartCertUser = getAllCertifications();
        Map<String, List<Partner_Certifications__c>> map_PCertUserbyCode = new Map<String, List<Partner_Certifications__c>>();
        
        for(Partner_Certifications__c objUser :  list_PartCertUser){
            if(!map_PCertUserbyCode.containsKey(objUser.Genesys_Test_Code__c)){
                map_PCertUserbyCode.put(objUser.Genesys_Test_Code__c, new  List<Partner_Certifications__c>{objUser});
            }else{
                map_PCertUserbyCode.get(objUser.Genesys_Test_Code__c).add(objUser);
            }
        }
        map_PCertBySG = new Map<String, List<Partner_Certifications__c>>();
        
        for(String strSG : map_SGCertCode.keySet()){
            if(!strSG.equalsIgnoreCase('Sales - Training') && !strSG.equalsIgnoreCase('Pre-Sales') ){
                if(map_SGCertCode.containsKey(strSG) && map_SGCertCode.get(strSG).size() > 0){
                    for(String strCode : map_SGCertCode.get(strSG)){
                        if(strCode != NULL && map_PCertUserbyCode.containsKey(strCode)){
                            if(!map_PCertBySG.containsKey(strSG)){
                                map_PCertBySG.put(strSG, new List<Partner_Certifications__c>(map_PCertUserbyCode.get(strCode)));
                            }else{
                                map_PCertBySG.get(strSG).addAll((map_PCertUserbyCode.get(strCode)));
                            }
                        }
                    }
                }else{
                    map_PCertBySG.put(strSG, new List<Partner_Certifications__c>());
                }
            }
        }
        // Partner Certificate - End
        // Litmos Learning Path - Start
        /*
        
        for(String strSG : map_SGCertCode.keySet()){
            if(strSG.equalsIgnoreCase('Pre-Sales') ){
                if(map_SGCertCode.containsKey(strSG) && map_SGCertCode.get(strSG).size() > 0){
                    for(String strCode : map_SGCertCode.get(strSG)){
                        if(strCode != NULL && map_LearningPathUserbyCode.containsKey(strCode)){
                            if(!map_LearnPathCertBySG.containsKey(strSG)){
                                map_LearnPathCertBySG.put(strSG, new List<Litmos__UserLearningPathResult__c>(map_LearningPathUserbyCode.get(strCode)));
                            }else{
                                map_LearnPathCertBySG.get(strSG).addAll((map_LearningPathUserbyCode.get(strCode)));
                            }
                        }
                    }
                }else{
                    map_LearnPathCertBySG.put(strSG, new List<Litmos__UserLearningPathResult__c>());
                }
            }
        }
*/
        // Litmos Learning Path - End
        Set<String> set_SGs = map_SGCertCode.keySet();
        List<String> list_OrderSG = new List<String>();
        if(set_SGs.contains('Pre-Sales')){
            list_OrderSG.add('Pre-Sales');
        }
        if(set_SGs.contains('Sales - Training')){
            list_OrderSG.add('Sales - Training');
        }
        if(set_SGs.contains('Services/Support')){
            list_OrderSG.add('Services/Support');
        }
        if(set_SGs.contains('Developer')){
            list_OrderSG.add('Developer');
        }
        
        for(String strSG : list_OrderSG){
            if(strSG.equalsIgnoreCase('Sales - Training') || strSG.equalsIgnoreCase('Pre-Sales')){
                /*if(strSG.equalsIgnoreCase('Pre-Sales') && map_CGSBySG_Other.keyset().contains('PureEngage - Core'))
                {
                    integer count = map_LearnPathCertBySG.containsKey(strSG) ? map_LearnPathCertBySG.get(strSG).size() : 0;
                    count += map_LearnPathCertBySG.containsKey(strSG) ? map_LearnPathCertBySG.get(strSG).size()  : 0 ;
                    tempCert.add(new CertificationInfo('G' , 'C' , count, 0 , 0, 0 ));
                }
                else{*/
                    tempCert.add(new CertificationInfo('G' , 'C' , map_DoceboBySG.containsKey(strSG) ? map_DoceboBySG.get(strSG).size()  : 0  , 0 , 0, 0 ));
                //}
            }
            else{
                tempCert.add(new CertificationInfo('G' , 'C' , map_PCertBySG.containsKey(strSG) ? map_PCertBySG.get(strSG).size()  : 0   , 0 , 0, 0 ));
            }
            
            objAddSepcData.add(new PartnerComplianceInfoWrapper(strSG , map_SGCertCount.containsKey(strSG) ? map_SGCertCount.get(strSG) : 0, tempCert.clone() ));
            
            tempCert = new List<CertificationInfo>();

            System.Debug('objAddSepcData--->'+objAddSepcData);
        }
        return NULL;
    }
    
    public PageReference getCertificationDetailsBySpecialization(){
        if(certificationListType.equalsIgnoreCase('Sales - Training') || certificationListType.equalsIgnoreCase('Pre-Sales')){
            trainingList = map_DoceboBySG.containsKey(certificationListType) ? map_DoceboBySG.get(certificationListType) : NULL;
            System.Debug('trainingList123--->'+trainingList);
            //litmosLearningPathUsersList = map_LearnPathCertBySG.containsKey(certificationListType) ? map_LearnPathCertBySG.get(certificationListType) : NULL;
            showTrainingDetails = true;
            currentSpecialization = new list<string>();
            showCourse = false;
            certificationListTestCode = '';
            if(trainingList != NULL){
                showCourse = true;
            }
            //if(litmosLearningPathUsersList != NULL){
            //}
            
        }
        else{
            showTrainingDetails = false;
            currentSpecialization = new list<string>();
            showCourse = false;
            certificationListTestCode = certificationListType ;
            certificationList = map_PCertBySG.get(certificationListType);
            certificationListTypeToDisplay = 'Done';
        }
         
        return NULL;
    }
    
    //Mukunth commented
    /*public List<Litmos__UserProgramResult__c> getAllLitmosTrainings(){
      return [SELECT Id,Litmos__Active__c,Litmos__Completed__c,Litmos__ProgramID__r.Litmos__LitmosID__c,Litmos__FinishDate__c,Litmos__LitmosID__c,
                                Litmos__PercentageComplete__c,Litmos__ProgramID__c,Litmos__Program_Code__c,Litmos__ProgramID__r.name,Litmos__StartDate__c,Litmos__ProgramID__r.Litmos__Code__c,
                                Litmos__status__c,Litmos__UserID__c,Litmos__User_Name__c,Litmos__ContactID__r.name,Name,OwnerId,Litmos__ContactID__r.Email 
                                FROM Litmos__UserProgramResult__c  WHERE Litmos__Completed__c = true 
                                AND Litmos__UserID__r.Contact.AccountId = :accountId  ORDER BY Litmos__FinishDate__c ASC NULLS LAST];                
    }*/

    public list<docebo_v3__CourseEnrollment__c> getAllDoceboCourses(){
        return [select docebo_v3__CompletedLearningObjects__c, docebo_v3__Completion__c, docebo_v3__EnrollmentCompletionDate__c, docebo_v3__Course__c, 
                        docebo_v3__Credits__c, docebo_v3__DoceboUser__c, docebo_v3__EnrollmentStartDate__c, docebo_v3__EnrolmentId__c, docebo_v3__Score__c, 
                        docebo_v3__Status__c, docebo_v3__TimeInCourse__c, docebo_v3__Who__c,docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Contact_Full_Name__c,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Contact_Full_Name__c,docebo_v3__DoceboUser__r.docebo_v3__User__c,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__c,docebo_v3__Course__r.docebo_v3__Name__c,docebo_v3__Course__r.docebo_v3__CourseId__c
                        from docebo_v3__CourseEnrollment__c  
                        where (docebo_v3__DoceboUser__r.docebo_v3__Contact__r.AccountId = :accountId 
                        OR docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.AccountId = :accountId) AND docebo_v3__Status__c='Completed'];
    }
    
    /*public List<Litmos__UserLearningPathResult__c> getAllLitmosLearningPathUsers(){
        return [SELECT Id, Name, Litmos__LearningPathID__r.Litmos__Description__c,
                Litmos__LearningPathID__r.Litmos__LitmosID__c , Litmos__UserID__r.Contact.Name, Litmos__Completed__c, 
                Litmos__FinishDate__c, Litmos__StartDate__c, Litmos__LearningPathID__c, Litmos__UserID__c, Litmos__UserID__r.Email
                FROM Litmos__UserLearningPathResult__c  
                WHERE Litmos__Completed__c = TRUE AND Litmos__UserID__r.Contact.AccountId = :accountId
                ORDER BY Litmos__FinishDate__c ];
    }*/
    
    public class PartnerComplianceInfoWrapper{
        public String groupName {get; set;}
        public List<CertificationInfo> certifications {get; set;}
        public Integer requirements {get; set;}
        public Integer requirementsDone {
            get{
                try{
                    Integer totalCertsCount = 0;
                    if(certifications != null && !certifications.isEmpty() && certifications.size() > 0){
                        for(CertificationInfo ci : certifications){
                            totalCertsCount = totalCertsCount + ci.currentCount;
                        }
                    }   
                    return totalCertsCount;
                }catch(Exception ex){
                    return 0;
                }
            } 
           set;
        }
        public Integer requirementsGap {
          get {
                 return (requirements - requirementsDone) > 0 ? 
                     (requirements - requirementsDone) : 0;   
        }
            set;
        }
        
        public PartnerComplianceInfoWrapper(String groupName,  Integer requirements, List<CertificationInfo> certifications){
            this.groupName = groupName;
            this.requirements = requirements;
            this.certifications = certifications;
        }
    }
    
    public class CertificationInfo {
        public String code {get; set;}
        public String type {get; set;}
        public Integer currentCount {get; set;}
        public Integer expiredInLast3Months {get; set;}
        public Integer expiringInNext3Months {get; set;}
        public Integer expiringBeforeEOY {get; set;}
        
        public CertificationInfo(String code, String type, Integer currentCount, Integer expiredInLast3Months, Integer expiringInNext3Months, Integer expiringBeforeEOY){
            this.code = code;
            this.type = type;
            this.currentCount = currentCount;
            this.expiredInLast3Months = expiredInLast3Months;
            this.expiringInNext3Months = expiringInNext3Months;
            this.expiringBeforeEOY = expiringBeforeEOY;
        }
    }
}