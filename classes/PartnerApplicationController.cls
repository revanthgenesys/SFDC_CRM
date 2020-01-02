//Naresh Kumar  01/17/2014
public without sharing class PartnerApplicationController 
{
    public Integer step {get;set;} 
    public Partner_Application__c newApplication {get;set;}
    public List<Partner_Application__c> existingApplications {get;set;}
    public Account newAccount {get;set;}
    public Contact newContact {get;set;}
    public Boolean hideDetails {get;set;}
    public String stepDetails {get;set;}
    public Boolean appAlreadySubmitted {get;set;}
    public Boolean showNewApplicationButton {get;set;}
    public Boolean renderNext {get;set;}
    public Boolean renderSave {get;set;}
    public Boolean renderCancel {get;set;}
    public Boolean renderSubmitApp {get;set;}
    public Boolean renderCancelApp {get;set;}
    public Boolean renderApprove {get;set;}
    public Boolean renderReject {get;set;}  
    public Boolean SPAsSC {get;set;}
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Map<String,String> mapFieldLabelVsHelpTextContact {get;set;} 
    public List<wrapperExecMgmtList> execMgmtTeam {get;set;}
    public List<wrapperCompanyOwnershipList> companyOwnership {get;set;}
    public List<WrapperCategoryAndCountryList> categoryAndCountry {get;set;}
    public List<WrapperpaEmployeeList> paEmployeeList {get;set;}
    public Integer rowToRemove {get;set;}
    public List<Partner_Application_Head_Count__c> list_PAHeadCount {get; set;}
    public Map<String,String> map_PAHeadCountRegionMap {get; private set;}
    public integer parterAppEmpFormNumber { get; set; }
    public boolean otherpartner {get;set;}
    public Boolean showSignContractButton {get;set;}
    public String docuSignRecipientExtId {get;set;}
    List<Country__c> list_Countries;
    //Public List<SelectOption> PlatformType{get;set;}
    public transient Component.Apex.OutputPanel outPanel{get;set;}
    
    //public Partner_Application_Industry_Vertical__c objO{get;set;}
    public string strIndustry {get;set;}
    public integer iIndexIndustry{get;set;}
    public boolean isSelectIndustry{get;set;}
    
    // validation variable
    public Boolean errorsInStep1 {get; set;}
    public Boolean errorsInStep2 {get; set;}
    public Boolean errorsInStep3 {get; set;}
    public Boolean errorsInStep4 {get; set;}
    
    // Contact Address Line 1 -> Same Hold
    
    public Boolean isAddressLine1Same {get ; set;}
    
    // field to use in dynamic table.
    public  List<WrapperpaSummaryRatesList> appsummaryRateList {get;set;}
   
    public List<Partner_Application_Industry_Vertical__c> list_IndustryNVertical{get;set;}
    
    public PartnerApplicationController()
    {    
        
        errorsInStep1 = false;
        errorsInStep2 = false;
        errorsInStep3 = false;
        errorsInStep4 = false;
        isAddressLine1Same = true;
        isSelectIndustry = false;
        
        //define with single row in list.by default single row will display.
        /* appsummaryRateList = new List<Partner_Application_Summary_Rate__c> ();
         appsummaryRateList.add(new Partner_Application_Summary_Rate__c());
         */
         otherpartner = false;
         
         
        appAlreadySubmitted = false;
        system.debug('++++aaa++++');
        
        isApplicationAlreadySubmitted();        
        if(appAlreadySubmitted){
            hideDetails = true;
            return;
        }
        if(ApexPages.currentPage().getParameters().get('step') == null)
            step = 0;
        else
            step = Integer.valueOf(ApexPages.currentPage().getParameters().get('step'));
        System.debug('NKC debug step ['+step+']');
        hideDetails = false;
        stepDetails = '';
        Boolean isNewApplication = false;
        if(ApexPages.currentPage().getParameters().get('new') != null)
            isNewApplication = true;
        wholeApplication result = PartnerApplicationControllerHelper.init(newApplication, newAccount, newContact, isNewApplication);
        newApplication = result.newApplication;
        newAccount = result.newAccount;
        if(newAccount.Name !=null)
            newApplication.Company_Name__c = newAccount.Name;
        newContact = result.newContact;
        SPAsSC = newApplication.Services_Partner_as_Subcontractor__c;
        if(newApplication.id != null)
          //  step = 0; //Ravi
          step = 1;  //changed by ravi from 0 to 1
        setButtonsVisibility(); //uncommented by ravi.. on 28-Aug-2014         
        if(SPAsSC != null)
           populateStepDetails();

        init();  
        
        list_PAHeadCount = new List<Partner_Application_Head_Count__c>();
        map_PAHeadCountRegionMap = new Map<String,String>();
        map_PAHeadCountRegionMap.put('North America','North America');
        map_PAHeadCountRegionMap.put('LATAM','LATAM');
        map_PAHeadCountRegionMap.put('EMEA','EMEA');
        map_PAHeadCountRegionMap.put('APAC','APAC');   
        
        system.debug('----------initializeEmpHeadCount()-------------'+initializeEmpHeadCount());    
        
        if(initializeEmpHeadCount().size() > 0)
        {
          List<Partner_Application_Head_Count__c> emyHeadCountList = initializeEmpHeadCount();
          list_PAHeadCount =  emyHeadCountList; 
        }
        else {
           for(String eachReg : map_PAHeadCountRegionMap.values())
           {
             Partner_Application_Head_Count__c obj = new Partner_Application_Head_Count__c();
             obj.Region__c = eachReg;
             list_PAHeadCount.add(obj);
           }    
        }  
    }
    
    private void init()
    {
          system.debug('121323232');
        mapFieldLabelVsHelpText = PartnerApplicationControllerHelper.getMapOfFieldsAndHelpText();   
        mapFieldLabelVsHelpTextContact = PartnerApplicationControllerHelper.getMapOfFieldsAndHelpTextContact();
        execMgmtTeam = PartnerApplicationControllerHelper.intializeExeMgmgTeamList(newApplication.id);
        companyOwnership = PartnerApplicationControllerHelper.intializeCompanyOwnershipList(newApplication.id);
        paEmployeeList = PartnerApplicationControllerHelper.intializeEmployeeList(newApplication.id);
        system.debug('paEmployeeList in init()-->'+paEmployeeList);
        appsummaryRateList = PartnerApplicationControllerHelper.intializeSummaryRatesList(newApplication.id);
        //list_IndustryNVertical = PartnerApplicationControllerHelper.getIndustryNVertical(newApplication.id);
        intializeCategoryAndCountryList();
        checkPendingSignatures();
        //DynamicControl();
        GetIndusAndVerticals();
        
    }
    
    private void GetIndusAndVerticals()
    {
      list_IndustryNVertical= new List<Partner_Application_Industry_Vertical__c>();
      system.debug('+++++newApplication.id++++'+newApplication.id);
      if(newApplication.id != null)
        list_IndustryNVertical = [select id,Partner_Application__c,Industry__c,Vertical_Markets__c from Partner_Application_Industry_Vertical__c where Partner_Application__c =: newApplication.id];
      else
      {
        Partner_Application_Industry_Vertical__c objO = new Partner_Application_Industry_Vertical__c();
        list_IndustryNVertical.add(objO);
      }
      
      if(list_IndustryNVertical == null || list_IndustryNVertical.size() <= 0)
      {
        list_IndustryNVertical= new List<Partner_Application_Industry_Vertical__c>();
        //Partner_Application_Industry_Vertical__c objO = new Partner_Application_Industry_Vertical__c();
        //list_IndustryNVertical.add(objO);
        AddIndustry();
      }
          
    }
    public void AddIndustry()
    {
      isSelectIndustry = false;
      system.debug('++++list_IndustryNVertical.size+++'+list_IndustryNVertical.size()); 
      for(Partner_Application_Industry_Vertical__c ob :list_IndustryNVertical)
      {
        if(ob.Industry__c == null || ob.Vertical_Markets__c == null)
          isSelectIndustry = true;
          
        
      }
      if(isSelectIndustry)
        ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select industry/vertical.'));
      else
      {  
        Partner_Application_Industry_Vertical__c objO = new Partner_Application_Industry_Vertical__c();      
        list_IndustryNVertical.add(objO);
      }
      system.debug('++++list_IndustryNVertical.size+++'+list_IndustryNVertical.size());
    }
    /*public Component.Apex.OutputPanel getDynamicControl()
    {
    
     list_IndustryNVertical= new List<Partner_Application_Industry_Vertical__c>();
      objO = new Partner_Application_Industry_Vertical__c();
      
      list_IndustryNVertical.add(objO);
      
      system.debug('+++list_IndustryNVertical+++'+list_IndustryNVertical);
      
      outPanel = new Component.Apex.OutputPanel();
      
      Component.apex.PageBlock rpt = new Component.apex.PageBlock(id='rptIndustry',rendered = true);
      rpt.title = 'Vertical/Industry';
      
      Component.apex.pageblocktable pbtVertical = new Component.apex.pageblocktable(id='pbtIndustry1',rendered = true);
      pbtVertical.expressions.value='{!list_IndustryNVertical}';
      pbtVertical.var = 'ver';
      
      Component.Apex.Column firstNameCol = new Component.Apex.Column();
      firstNameCol.expressions.value = '{!ver.Industry__c}';
      //firstNameCol.headerValue = 'in';
      
      
      Component.Apex.Inputfield in1 = new Component.Apex.Inputfield();
      in1.expressions.value = '{!ver.Industry__c}';
      
      firstNameCol.childComponents.add(in1);
      
      
      
      Component.Apex.Column secondNameCol = new Component.Apex.Column(rendered=true);
      secondNameCol.expressions.value = '{!ver.Vertical_Markets__c}';
      
      
      
      Component.Apex.Inputfield in2 = new Component.Apex.Inputfield();
      in2.expressions.value = '{!ver.Vertical_Markets__c}';
      secondNameCol.childComponents.add(in2);
      
                 
      
      pbtVertical.childComponents.add(firstNameCol);  
      pbtVertical.childComponents.add(secondNameCol);  
      
      rpt.childComponents.Add(pbtVertical);
      
      
      
      Component.apex.CommandButton cmdAddVer = new Component.apex.CommandButton(id='btnAddInduRow',rendered = true);
      cmdAddVer.value = 'Add Row';
      
      outPanel.childComponents.Add(rpt);
      outPanel.childComponents.Add(cmdAddVer);
      return outPanel;

    }*/
    
    
    //*** Page Action method for re-direction to detail page if application is not in progress ***
    public PageReference redirectToDetailPage()
    {
        if(newApplication != null && newApplication.Id != null && newApplication.Status__c != 'In Progress')
            return (new PageReference('/partner/Partner_ApplicationDetail?id=' + newApplication.Id));
            
        return null;
    }
    
    public  List<Partner_Application_Head_Count__c> initializeEmpHeadCount()
    {
         List<Partner_Application_Head_Count__c> EmployeeHeadCountList = new List<Partner_Application_Head_Count__c>();
         Set<String> regionSet = new Set<String>();
         if(newApplication.id != null)
         {
             for(Partner_Application_Head_Count__c eachempHc :  [SELECT Delivery_capabilities__c,Development_Team__c,Partner_Application__c,Professional_Services__c,Project_Management__c,Region__c,Technical_Support_Team__c,Total_Headcount__c FROM Partner_Application_Head_Count__c WHERE Partner_Application__c = :newApplication.id order by Region__c ])
             {
               Partner_Application_Head_Count__c eachpaHc = new Partner_Application_Head_Count__c(id = eachempHc.id,Region__c = eachempHc.Region__c,Delivery_capabilities__c = eachempHc.Delivery_capabilities__c,
                                                                                                  Development_Team__c = eachempHc.Development_Team__c ,Professional_Services__c = eachempHc.Professional_Services__c,
                                                                                                  Project_Management__c =  eachempHc.Project_Management__c,Technical_Support_Team__c =  eachempHc.Technical_Support_Team__c,
                                                                                                  Total_Headcount__c =  eachempHc.Total_Headcount__c);
               EmployeeHeadCountList.add(eachpaHc);
               regionSet.add(eachempHc.Region__c);
             }  
         }
         
        for(String eachReg : map_PAHeadCountRegionMap.values())
        {
          Partner_Application_Head_Count__c eachpaHc = new Partner_Application_Head_Count__c();
          if(regionSet.size() > 0)
          {
            if(!regionSet.contains(eachReg))
           {
             eachpaHc.Region__c = eachReg;
             EmployeeHeadCountList.add(eachpaHc);
             
           }
          }
        }
        return EmployeeHeadCountList;
   }
   
   public void checkPendingSignatures(){
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatus = [SELECT dsfs__DocuSign_Recipient_Id__c 
            FROM dsfs__DocuSign_Recipient_Status__c 
            WHERE dsfs__DocuSign_Recipient_Email__c =: UserInfo.getUserEmail() 
            AND dsfs__Recipient_Status__c != 'Completed'
            AND dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c != 'Completed'];
        
        system.debug('dsRecipientStatus size :'+dsRecipientStatus.size());
        
        if(dsRecipientStatus.isEmpty())
            showSignContractButton = false;
        else{
            docuSignRecipientExtId = dsRecipientStatus[0].dsfs__DocuSign_Recipient_Id__c;
            showSignContractButton = true;
        }
        
        system.debug('showSignContractButton: '+showSignContractButton);
      }
    
    
    public void intializeCategoryAndCountryList()
    {
        categoryAndCountry = new List<wrapperCategoryAndCountryList>();
        system.debug('++++1111++++++');
        
        list_Countries = [SELECT Id,Name FROM Country__c where Country__c not in ('Cuba','Iran','North Korea','Sudan','Syria') ORDER BY Name];
        if(newApplication.id != null)
        {
            system.debug('++++22222++++++');
            /* For Platform Type*/
            List<string> list_PlatformTypeList = new List<string>();
            Schema.DescribeFieldResult objPACC = Partner_Application_Category_and_Country__c.PlatformType__c.getDescribe();
            List<Schema.PicklistEntry> PTValues = objPACC.getPicklistValues();
               
            for(Schema.PicklistEntry o: PTValues){ 
                list_PlatformTypeList.Add(o.getvalue()); 
            }
            //Mukunth added
            System.Debug('newApplication.id--->'+newApplication.id);
            List<Partner_Application_Category_and_Country__c> list_ExistingCombinations = [SELECT Id,PlatformType__c,Category__c, Country__c,
                            Company_partner_CX_space__c,Genesys_AppFoundry__c,
                            Project_priority_in_your_Development__c,Reason_for_integration__c
                            FROM Partner_Application_Category_and_Country__c
                            WHERE Partner_Application__c =: newApplication.id
                            ORDER BY Category__c];
            
            System.Debug('list_ExistingCombinations--->'+list_ExistingCombinations);
            
            map<string,list<Partner_Application_Category_and_Country__c>> mapPTtoPACC = new map<string,list<Partner_Application_Category_and_Country__c>>();
            for(Partner_Application_Category_and_Country__c paccREC: list_ExistingCombinations){
                if(mapPTtoPACC.containskey(paccREC.Category__c+paccREC.PlatformType__c)){
                    mapPTtoPACC.get(paccREC.Category__c+paccREC.PlatformType__c).add(paccREC);
                }
                else{
                    mapPTtoPACC.put(paccREC.Category__c+paccREC.PlatformType__c,new list<Partner_Application_Category_and_Country__c>{paccREC});
                }
            }
            
            System.Debug('mapPTtoPACC--->'+mapPTtoPACC);
            
            for(string eachStr: mapPTtoPACC.keyset()){
                
                WrapperCategoryAndCountryList newRecord = new WrapperCategoryAndCountryList();
                Partner_Application_Category_and_Country__c newCategoryAndCountryRecord = 
                                            new Partner_Application_Category_and_Country__c();
                newCategoryAndCountryRecord.Category__c = (mapPTtoPACC.get(eachStr))[0].Category__c;
                //newCategoryAndCountryRecord.PlatformType__c = (mapPTtoPACC.get(eachStr))[0].PlatformType__c;
                newCategoryAndCountryRecord.Company_partner_CX_space__c = (mapPTtoPACC.get(eachStr))[0].Company_partner_CX_space__c;
                newCategoryAndCountryRecord.Genesys_AppFoundry__c = (mapPTtoPACC.get(eachStr))[0].Genesys_AppFoundry__c;
                newCategoryAndCountryRecord.Reason_for_integration__c = (mapPTtoPACC.get(eachStr))[0].Reason_for_integration__c;
                newCategoryAndCountryRecord.Project_priority_in_your_Development__c  = (mapPTtoPACC.get(eachStr))[0].Project_priority_in_your_Development__c;
                newRecord.record = newCategoryAndCountryRecord;
                Set<Id> set_CountryIds = new set<Id>();
                list<string> list_PTT = new list<string>();
                if(mapPTtoPACC.get(eachStr)!= null && (mapPTtoPACC.get(eachStr))[0].PlatformType__c != null){
                    list_PTT = ((mapPTtoPACC.get(eachStr))[0].PlatformType__c).split(';');
                }
                for(Partner_Application_Category_and_Country__c eachRec: mapPTtoPACC.get(eachStr)){
                    set_CountryIds.add(eachRec.Country__c);
                }
                System.Debug('set_CountryIds--->'+set_CountryIds);
                for(Country__c objCountry : list_Countries)
                {
                    if(set_CountryIds.contains(objCountry.Id))
                        newRecord.list_SelectedCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                    else
                        newRecord.list_AllCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                }
                
                for(string strPTT:list_PlatformTypeList){
                    if(list_PTT.contains(strPTT))
                        newRecord.list_SelectedPTType.add(new SelectOption(strPTT,strPTT));
                    else
                        newRecord.list_AllPTType.add(new SelectOption(strPTT,strPTT));
                }
                
                
                System.Debug('newRecord1--->'+newRecord);
                categoryAndCountry.add(newRecord);
                
            }
        }
        System.Debug('categoryAndCountry1--->'+categoryAndCountry);
        if(categoryAndCountry.isEmpty())
        {
            addNewRowToCategoryAndCountryList();         
        }
    }
    
    public void addNewRowToCategoryAndCountryList()
    {
        WrapperCategoryAndCountryList newRecord = new WrapperCategoryAndCountryList();
        Partner_Application_Category_and_Country__c newCategoryAndCountryRecord = new Partner_Application_Category_and_Country__c();        
        newRecord.record = newCategoryAndCountryRecord;
        
         /*For PlatForm Type*/
         List<string> list_PlatformTypeList = new List<string>();
            string sPTTyp = '';
              Schema.DescribeFieldResult objPACC = Partner_Application_Category_and_Country__c.PlatformType__c.getDescribe();
               List<Schema.PicklistEntry> PTValues = objPACC.getPicklistValues();
               //PlatformType = new list<SelectOption>();     
               
               
               for(Schema.PicklistEntry o: PTValues){ 
                    newRecord.list_AllPTType.add(new SelectOption(o.getValue(),o.getValue()));
               }
        
        for(Country__c objCountry : list_Countries)
            newRecord.list_AllCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
            
        categoryAndCountry.add(newRecord);
    }
    
    public void removeRowFromCategoryAndCountryList()
    {
        categoryAndCountry.remove(rowToRemove);
    }
    
    private void populateStepDetails(){
        if(SPAsSC)
            stepDetails = '(Step ' + step + ' of 4)';
        else
            stepDetails = '(Step ' + step + ' of 4)';
            
        if(step == 0)
            stepDetails = '';
    }
    
    public void actionYes(){
     //   step = 1; //by Ravi
        step = 3;
        SPAsSC = true;      
        stepDetails = '(Step ' + step + ' of 4)';
        populateStepDetails();
        setButtonsVisibility();     
    }
    
    //Create and Next action created by Ravi on 08/18
     public void actionCreate(){
        step = 1;
        SPAsSC = true;      
        stepDetails = '(Step ' + step + ' of 4)';
        populateStepDetails();
        setButtonsVisibility();     
    }
    
    
    public void actionNo(){
        step ++;
        SPAsSC = false;
        stepDetails = '(Step ' + step + ' of 4)';   
        
        setButtonsVisibility();
    }
    
    
    public PageReference next(){  
        system.debug('+++++step +++  '+step);  
        String add2 = newAccount.Street2__c != null ? newAccount.Street2__c : '';
        String add3 = newAccount.Street3__c != null ?  newAccount.Street3__c : '';
        newContact.MailingStreet = newAccount.Street1__c + ', ' + add2 + ', ' + add3;
        newContact.MailingCity = newAccount.BillingCity;
        newContact.MailingState = newAccount.StateProvince__c;
        newContact.MailingPostalCode = newAccount.ZipCode__c;
        if(step == 1 && isErrorsInStep1()){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please fill all the required fields before proceeding to Next step.'));
            return null;
        } 
        if(step == 3 && isErrorsInStep3()){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please fill all the required fields before proceeding to Next step.'));
            return null;
        }
        
        saveApplication();
        UpdateIndustry();
        step++;
        populateStepDetails();
        setButtonsVisibility(); 
        return null;
    }
    
    
   public void previous(){
     step--;
     populateStepDetails();
     setButtonsVisibility();
        
    }
    
  //  public pagereference backMethod() {
    //  Pagereference pg = new Pagereference(Partner_Application);
        
   //pg.setRedirect(true);
  //return pg;
        
 // }
    
    private void setButtonsVisibility(){
        Boolean flag = SPAsSC;      
        if((flag && step >= 0 && step < 2) || (!flag && step >= 1 && step < 1))
            renderNext = true;
        else
            renderNext = false;
        if(step > 0 && (flag && step < 3) || step > 0 && (!flag && step < 2) || newApplication.id != null)
            renderSave = true;
        else
            renderSave = false;
        if((flag & step > 0 && step < 3 ) || (!flag & step > 0 && step < 2 ))
            renderCancel = true;
        else
            renderCancel = false;
        
     // by ravi 08/19
     //   if((flag && step == 2) || (!flag && step == 1)){
     if((flag && step == 3) || (!flag && step == 1)){
            renderSubmitApp = true;
            renderCancelApp = true;
        }
        else{
            renderSubmitApp = false;
            renderCancelApp = false;
        }       
     // by ravi 08/19
     //   if((flag && step == 3) || (!flag && step == 2)){
     
     if((flag && step == 4) || (!flag && step == 3)){
            renderApprove = true;
            renderReject = true;
        }
        else{
            renderApprove = false;
            renderReject = false;
        }
    }
    
    public boolean isErrorsInStep1(){
        boolean isErrors = false;
        errorsInStep1 =  errorsInStep2 = errorsInStep3 = errorsInStep4 = false;
        isAddressLine1Same = true;
        
        List<Schema.FieldSetMember> fields;
        
        // Validate Section 1
        fields = Schema.SObjectType.Partner_Application__c.fieldSets.Partner_Application_Part_1.getFields();
        for(Schema.FieldSetMember f : fields) {
            if(f.getLabel()!='Industry') //added by Swastika on May/15/2017 validation is handel for industry separately
                if(String.isBlank((String)newApplication.get(f.getFieldPath()))){               
                    isErrors = errorsInStep1 = true;
                     System.debug('isErrors0 ... ' + isErrors);
                }
        }
        //check mandatory the list of Industry and Verical 
        for(Partner_Application_Industry_Vertical__c objIndVertical : list_IndustryNVertical)
            if(objIndVertical.Industry__c == null || objIndVertical.Vertical_Markets__c == null)
                isErrors = errorsInStep1 = true;
                
        System.debug('Section 1 ... ' + errorsInStep1);  
        
        if(newApplication.Do_you_want_to_integrate_to_Genesys_prod__c == true){
            if(String.isBlank(newApplication.Value_Added_to_Genesys__c)){                 
                isErrors = errorsInStep1 = true;
            }
        }
        
        // Validation - Partner Company Details
        fields = Schema.SObjectType.Account.fieldSets.Partner_Application_Part_2.getFields();
        for(Schema.FieldSetMember f : fields) {
            String fType = f.getType().name();
            String fLabel = f.getLabel();
            
            if( fLabel != 'Address 2' && fLabel != 'Address 3' && fLabel != 'VAT Number' 
               && fLabel != 'SIC Code' && fLabel != 'State/Province' && fLabel != 'Country'){
                   if(fType == 'CURRENCY' || fType == 'NUMBER' || fType == 'INTEGER' || fType == 'DOUBLE' || fType == 'DATE' ){
                       if(newAccount.get(f.getFieldPath()) == NULL){
                            isErrors = errorsInStep1 = true;
                       }
                   } else if(String.isBlank((String)newAccount.get(f.getFieldPath()))){
                       isErrors = errorsInStep1 = true;
                   }
            }
        }
        System.debug('Section 2 ... ' + errorsInStep1);        
        
        // Validation - Your Contact Information ? Primary Contact 
        fields = Schema.SObjectType.Contact.fieldSets.Partner_Application_Part_2_2.getFields();
        for(Schema.FieldSetMember f : fields) {
            String fType = f.getType().name();
            String fLabel = f.getLabel();
            if(fLabel != 'Country'){
                if( !(f.getFieldPath().equalsIgnoreCase('Street1__c') || f.getFieldPath().equalsIgnoreCase('Street2__c') || 
                    f.getFieldPath().equalsIgnoreCase('Street3__c') || f.getFieldPath().equalsIgnoreCase('MailingCity') || 
                    f.getFieldPath().equalsIgnoreCase('MailingState')|| f.getFieldPath().equalsIgnoreCase('MailingPostalCode'))){
                   // System.debug('f.getFieldPath() = '+f.getFieldPath());
                    if(String.isBlank((String)newContact.get(f.getFieldPath()))){
                        isErrors = errorsInStep1 = true;
                        System.debug('Filed Name = '+String.isBlank((String)newContact.get(f.getFieldPath())));
                    }
                }
            }
        }
        if (!String.isBlank((String)newContact.get('Street1__c'))) {
            if(!((String)newContact.get('Street1__c')).equalsIgnoreCase('same')){
                if( String.isBlank(newContact.MailingCity) || String.isBlank(newContact.MailingState)){
                    isErrors = errorsInStep1 = true;
                    isAddressLine1Same = false;
                }
            }
        }
        System.debug('Section 3 ... ' + errorsInStep1); 
       
        // Validation - Executive Management Team
        for(wrapperExecMgmtList emt : execMgmtTeam ){
            if(String.isBlank(emt.record.Position__c) || String.isBlank(emt.record.Name) || String.isBlank(emt.record.Email__c)){
                isErrors = errorsInStep1 = true;
            }
        }
        System.debug('Section 4 ... ' + errorsInStep1); 
        
        // Validation - Company Ownership - Please list persons/firms who have more than 10% ownership of the Company.
        for(wrapperCompanyOwnershipList cos : companyOwnership ){
            if(String.isBlank(cos.record.Name) || String.isBlank(cos.record.Person_Firm__c) || cos.record.Ownership__c == NULL){
                isErrors = errorsInStep1 = true;
                
            }
        }
        System.debug('Section 5 ... ' + errorsInStep1); 
        
        // Validation - Government Interests & Compliance
        fields = Schema.SObjectType.Partner_Application__c.fieldSets.Partner_Application_Part_3.getFields();
        for(Schema.FieldSetMember f : fields) {
            if(String.valueOf(f.getType()) == 'String')
            if(String.isBlank((String)newApplication.get(f.getFieldPath()))){            
                isErrors = errorsInStep1 = true;
            }
        }
        System.debug('Section 6 ... ' + errorsInStep1); 
        
        // Step 2 is Boolean flag.
        // Step 3 starts here.
        // Validation - Services Partner Assessment Form (SPAF) for Subcontractor Applicants Only
        if(isNoCountrySelected())
            isErrors = errorsInStep1 = true;
        return isErrors;
    }
    
     public boolean isErrorsInStep3(){
        boolean isErrors = false;
        errorsInStep1 =  errorsInStep2 = errorsInStep3 = errorsInStep4 = false;
         
         // Validations - Services Partner Assessment Form (SPAF) for Subcontractor Applicants Only
        List<Schema.FieldSetMember> fields;
        fields = Schema.SObjectType.Partner_Application__c.fieldSets.Partner_Application_Part_4.getFields();
        for(Schema.FieldSetMember f : fields) {
            if(String.isBlank((String)newApplication.get(f.getFieldPath()))){
                isErrors = errorsInStep3 = true;
            }
        }
        System.debug('Step 3 - Section 1 ... ' + errorsInStep3); 
         
         // Validations - Please provide a summary of your list rates for services to Genesys Professional Services. Enter 'N/A' as needed.
       
         for(WrapperpaSummaryRatesList emt : appsummaryRateList ){
            if(String.isBlank(emt.record.Resource_or_Skill_Type__c) || String.isBlank(emt.record.Rate_or_Rate_Range__c) || String.isBlank(emt.record.Currency_Type__c) || String.isBlank(emt.record.Comments__c)){
                isErrors = errorsInStep3 = true;
            }
        }
         System.debug('Step 3 - Section 2 ... ' + errorsInStep3); 
         
         // Validations - Please list the numbers of individuals in the following Genesys related technical functions. This section is required for your application. Enter '0' as needed.
         for( Partner_Application_Head_Count__c pAHeadCount : list_PAHeadCount) {
             if(pAHeadCount.Professional_Services__c == NULL || pAHeadCount.Project_Management__c == NULL || 
               pAHeadCount.Development_Team__c == NULL  || pAHeadCount.Technical_Support_Team__c == NULL ||
               pAHeadCount.Total_Headcount__c == NULL ) {
                isErrors = errorsInStep3 = true; 
             }      
         }
         if (newApplication.Number_of_Employees__c == NULL) {
             isErrors = errorsInStep3 = true;
         }
         System.debug('Step 3 - Section 3 ... ' + errorsInStep3); 
                  
         // Validations - Please provide details on your employee Genesys University Certifications. This section is required for your application. Enter N/A as needed.
         for(WrapperpaEmployeeList paEmp : paEmployeeList ){
            if(String.isBlank(paEmp.record.Employee_Name__c) ||
               String.isBlank(paEmp.record.Certification_Name__c) || paEmp.record.Year_Aheived__c == NULL || 
               String.isBlank(paEmp.record.Resource_Country_of_Residence__c)){
                isErrors = errorsInStep3 = true;
            }
        }
        fields = Schema.SObjectType.Partner_Application__c.fieldSets.Partner_Application_Part_5.getFields();
        for(Schema.FieldSetMember f : fields) {
            if(String.isBlank((String)newApplication.get(f.getFieldPath()))){
                isErrors = errorsInStep3 = true;
            }
        }
        System.debug('Step 3 - Section 4 ... ' + errorsInStep3); 
         return isErrors; 
     }
    
    public boolean saveApplication(){
        system.debug('++++saveApplication++++');
        String add2 = newAccount.Street2__c != null ? newAccount.Street2__c : '';
        String add3 = newAccount.Street3__c != null ?  newAccount.Street3__c : '';
        newContact.MailingStreet = newAccount.Street1__c + ', ' + add2 + ', ' + add3;
        newContact.MailingCity = newAccount.BillingCity;
        newContact.MailingState = newAccount.StateProvince__c;
        newContact.MailingPostalCode = newAccount.ZipCode__c;
        
        errorsInStep1 = errorsInStep2 = errorsInStep3 = errorsInStep4 = false;
         system.debug('++++saveApplication 1++++');
        newApplication.Services_Partner_as_Subcontractor__c = SPAsSC;
         system.debug('++++saveApplication 2++++');
        boolean isError= PartnerApplicationControllerHelper.save(newApplication, 
                                                newAccount, 
                                                newContact,
                                                execMgmtTeam,
                                                companyOwnership,
                                                categoryAndCountry, 
                                                appsummaryRateList, 
                                                list_PAHeadCount,paEmployeeList);
      
       
       return isError;                          
    }
    
    private void UpdateIndustry()
    {
       for(Partner_Application_Industry_Vertical__c obj : list_IndustryNVertical)
       {
         obj.Partner_Application__c = newApplication.id;
       }
       upsert list_IndustryNVertical;
    }
    public void RemoveIndustry()
    {
        system.debug('++++testing+++');
       //PageReference objPgRef = ApexPages.CurrentPage();
       system.debug('++++strIndustry+++'+strIndustry);
       system.debug('++++iIndexIndustry+++'+iIndexIndustry);
       if(strIndustry != null && strIndustry != '')
       {
         Partner_Application_Industry_Vertical__c obj = [select id from Partner_Application_Industry_Vertical__c where id =: strIndustry];
         delete obj;
       }
       else
       {
         list_IndustryNVertical.remove(iIndexIndustry);
       }
       //return objPgRef;
       if(list_IndustryNVertical.size()<=0)
        AddIndustry();
        //init();
    }
    
    //public void save(){
    public PageReference save(){
    system.debug('++++save++++');
       try
       { 
        boolean isError = saveApplication();
        if(isError == true)
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select country and category.'));
        else
        {
             UpdateIndustry();
             ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 'Application saved successfully.'));
        }     
         //ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 'Application saved successfully.'));
        }
        catch(Exception ex)
        {
          //ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select country and category....'));
        }
        return null;
    }
    
    public PageReference submit(){
        if(step == 3 && isErrorsInStep3()){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please fill all the required fields before proceeding to Next step.'));
            return null;
        } 
        saveApplication();
        step ++;        
        stepDetails = '';
        setButtonsVisibility();
        return null;
    }
    
    public void approve(){
        newApplication.Services_Partner_as_Subcontractor__c = SPAsSC;
        newApplication.Status__c = 'Submitted'; 
        newApplication.Date_Completed__c = System.now();    
        newAccount.Approval_Status__c = 'Pending';
        PartnerPortalUtil.blnIgnoreDeleteTrigger = true;
        PartnerApplicationControllerHelper.save(newApplication, newAccount, newContact, execMgmtTeam, companyOwnership, categoryAndCountry, appsummaryRateList,list_PAHeadCount,paEmployeeList);
        ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
            'Application submitted sucessfully.'));
        hideDetails = true;
        if(newContact.Email != null){
            String htmlBody = 'Hi ' + newContact.FirstName + '<br/><br/>';
            htmlBody += 'Your application has been submitted successfully.<br/><br/>';
            htmlBody += 'Thanks.';
        //  SendEmail.sendSingleEmail(newContact.Email, 'Application Submitted Successfully.', htmlBody);
        }
        try{
        PartnerApplicationControllerHelper.submitPartnerApplicationToApprovalProcess(newApplication);
        }catch(Exception ex){
            system.debug(ex);
        }
    }
    
    public void cancelApplication(){
        newApplication.Services_Partner_as_Subcontractor__c = SPAsSC;
        newApplication.Status__c = 'Cancelled';     
        newAccount.Approval_Status__c = 'Rejected';
        PartnerApplicationControllerHelper.save(newApplication, newAccount, newContact, execMgmtTeam, companyOwnership, categoryAndCountry, appsummaryRateList, list_PAHeadCount,paEmployeeList);  
        ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
            'Application cancelled successfully. NOTE : Your login will be disabled shortly and you will no longer be available to login.'));
        hideDetails = true;
    }
    
    public void reject(){
        newApplication.Services_Partner_as_Subcontractor__c = SPAsSC;
        newApplication.Status__c = 'Cancelled';     
        PartnerApplicationControllerHelper.save(newApplication, newAccount, newContact, execMgmtTeam, companyOwnership, categoryAndCountry,appsummaryRateList,list_PAHeadCount,paEmployeeList);
     
        ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
            'NOTICE: Genesys requires that a one-way NDA to be accepted in order for Genesys to accept the Partner Application. We are sorry that we are unable to accept your Partner Application at this time.'));
        hideDetails = true;
    }
    
    public PageReference cancel(){
        return new PageReference('/PotentialPartnerHome');
    }
    
    public void isApplicationAlreadySubmitted(){
        appAlreadySubmitted = false;
        showNewApplicationButton = false;       
        existingApplications = PartnerApplicationControllerHelper.getExistingApplication();
        if(existingApplications.isEmpty())
            appAlreadySubmitted = false;
        for(Partner_Application__c eachPA : existingApplications){
            if(eachPA.Status__c.equals('In Progress')){
                appAlreadySubmitted = false;
                showNewApplicationButton = false;           
                break;
            }               
        }       
        
        User currentUser = [SELECT Allow_Potential_Partner_to_Reapply__c FROM User WHERE id =: UserInfo.getUserId() LIMIT 1];
        if(currentUser.Allow_Potential_Partner_to_Reapply__c){
            appAlreadySubmitted = false;
            showNewApplicationButton = true;
        }
    }
    
    public PageReference existingNDACheckboxClick(){
        return null;
    }
    
    public void addNewRowToExecMgmtTeamList(){
        System.debug('NKC debug ');
        execMgmtTeam = PartnerApplicationControllerHelper.addNewRowToexecMgmtTeamList(execMgmtTeam);
        System.debug('NKC debug execMgmtTeam.size() ['+execMgmtTeam.size()+'] ');
    }
    
    public void removeRowFromExecMgmstTeamList(){
        execMgmtTeam = PartnerApplicationControllerHelper.removeRowFromExecMgmtTeamList(rowToRemove, execMgmtTeam);
    }
    
    public void addNewRowToCompanyOwnershipList(){
        companyOwnership = PartnerApplicationControllerHelper.addNewRowToCompanyOwnershipList(companyOwnership);
    }
    
    public void removeRowFromCompanyOwnershipList(){
        companyOwnership = PartnerApplicationControllerHelper.removeRowFromCompanyOwnershipList(rowToRemove, companyOwnership);
    }
    
    
    public void addNewRowToEmployeeList(){
    paEmployeeList = PartnerApplicationControllerHelper.addNewRowToEmployeeList(paEmployeeList);
    }
    
   public void addNewRowToSummaryRatesList(){
    system.debug('appsummaryRateList-->'+appsummaryRateList.size());
    appsummaryRateList = PartnerApplicationControllerHelper.addNewRowToSummaryRatesList(appsummaryRateList);
    system.debug('appsummaryRateList-->'+appsummaryRateList.size());
    }
    
    public void removeRowFromEmployeeList(){
    paEmployeeList = PartnerApplicationControllerHelper.removeRowToEmployeeList(rowToRemove, paEmployeeList);
    }
    
     public void removeRowFromAppsumaryList(){
        system.debug('removeRowFromAppsumaryList is calling-->'+rowToRemove);
        system.debug('appsummaryRateList-->'+appsummaryRateList.size());
        
    appsummaryRateList = PartnerApplicationControllerHelper.removeRowToASumaryList(rowToRemove, appsummaryRateList); 
       system.debug('appsummaryRateList-->'+appsummaryRateList.size());
    }
    
    public class wholeApplication{
        public Partner_Application__c newApplication {get;set;}
        public Account newAccount {get;set;}
        public Contact newContact {get;set;}
    }
    
    public class wrapperExecMgmtList{
        public Integer index {get;set;}
        public Executive_Management_Team__c record {get;set;}
    }
    
    public class wrapperCompanyOwnershipList{
        public Integer index {get;set;}
        public Company_Ownership__c record {get;set;} 
    }
    
   public class WrapperpaEmployeeList{
        public Integer index {get;set;}
        public Partner_Application_Employee_Info__c record {get;set;}
   } 
   
    public class WrapperpaSummaryRatesList{
        public Integer index {get;set;}
        public Partner_Application_Summary_Rate__c record {get;set;}
   }
    
    public class WrapperCategoryAndCountryList
    {
        public Partner_Application_Category_and_Country__c record {get; set;}
        public List<SelectOption> list_SelectedCountries { get; set; }
        public List<SelectOption> list_AllCountries {get; set;}
        
        public List<SelectOption> list_SelectedPTType { get; set;}
        public List<SelectOption> list_AllPTType { get; set;}
        //String[] countries = new String[]{};
        
        public WrapperCategoryAndCountryList()
        {
            list_SelectedCountries = new List<SelectOption>();
            list_AllCountries = new List<SelectOption>();
            
            list_SelectedPTType = new List<SelectOption>();
            list_AllPTType = new List<SelectOption>();
        }
    }
    
    
    public pageReference calculateHeadCount(){
        
        system.debug('calculateHeadCount is calling-->');
        
     return null;   
    }
    
    public pageReference addSummaryRatesRows(){
        
        //appsummaryRateList.add(new Partner_Application_Summary_Rate__c());
        return null;
    }
    
    public pageReference partnerChagne(){
        system.debug('partnerChagne-->');
        system.debug('partnerChagne-->'+newApplication.formal_partnership_with_any_other_CTI__c);
      if(newApplication.formal_partnership_with_any_other_CTI__c =='Yes'){
        otherpartner =true;
            
      }else{
        otherpartner=false;
      }
      return null;
    
    }
    
    public boolean isNoCountrySelected() {
        for(wrapperCategoryAndCountryList wcc : categoryAndCountry) {
            if(wcc.list_SelectedCountries.isEmpty()) {
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Country from Add Categories and Countries Combination(s) section');
                //ApexPages.addMessage(myMsg);   
                return true;
            }               
        } 
        return false;
    }
    
     
}