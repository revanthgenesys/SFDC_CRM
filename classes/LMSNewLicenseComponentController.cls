public class LMSNewLicenseComponentController {
    public Boolean isSIP { get; set; }
    public String pageBlock {get; set;}
    public Map<String,LMS_ProductLine__c> products;
    public String paginationKey {get; set;}
    public Map<String,String> productType; //This holds product and its type (IC product / SIP Product)
    public Static List<String> orderKeys {get;set;} 
    public Static Set<String> SULicensingFeatureProductLines = new Set<String>{'CIC 3.0','Interaction Monitor 1.0','CIC 4.0','CIC IVR 3.0','CIC IVR 4.0','MIC 4.0'};
    public Static Set<String> mediaPartList= new Set<String>{'SY-014-4.0-IE00-B01','SY-014-4.0-IE01-B01','SY-014-4.0-IE02-B01','SY-014-4.0-IE04-B01','SY-014-4.0-IE08-B01','SY-014-4.0-MSAS-B01','SY-014-4.0-MSAM-B01','SY-014-4.0-MSAL-B01','SW-014-4.0-MSEA','SY-014-4.0-MSAS-B02','SY-014-4.0-MSAM-B02','SY-014-4.0-MSAL-B02','SY-014-4.0-MSAS-CP-B03','SY-014-4.0-MSAM-CP-B03','SY-014-4.0-MSAL-CP-B03','SY-014-4.0-MSAM8-CP-B01','SY-014-4.0-MSAL8-CP-B01','SY-014-4.0-MSAL8-3CP-B01','SY-014-4.0-MSAL8-5CP-B01','SY-014-4.0-MSAM8-3CP-B01','SY-014-4.0-MSAM8-5CP-B01','SY-014-4.0-MSAL8-3CP-B02','SY-014-4.0-MSAL8-5CP-B02','SY-014-4.0-MSAM8-3CP-B02','SY-014-4.0-MSAM8-5CP-B02'};
    Map<String,LMS_License_Types__c> internalLicenses;
    public Static String SULicensingFeatureKey = 'I3_FEATURE_SU_ALLOWED';
    public Boolean isMedia4 {get;set;}
    public String updateErrMsg {get;set;}
    Set<String> SIPOverrideParts; 
    public List<License_Request_Log__c> requests{get;set;}
    public LMS_Utility.SelectionWrapper inputs{get;set;}
    public String requestType {get;set;}
    public Boolean showSubsAddon {get;set;}
    
    public transient String sipType {
        get{
            if(products.get(selectedProdLine).SIPType__c != NULL)
                return products.get(selectedProdLine).SIPType__c;
            else
                return '';    
        }
    }
    // Gets the user type
    public String userType {get; 
                          set{ 
                              userType = value;
                              List<LMS_ProductLine__c> eligibleProductList = new List<LMS_ProductLine__c>();
                              if(products==NULL){
                                  products = new Map<String,LMS_ProductLine__c>();
                                  productType = new Map<String,String>();
                                  if(!userType.equalsIgnoreCase('Internal'))
                                      eligibleProductList = LMS_Utility.fetchEligibleProducts(u.contactid);
                                  else{
                                      eligibleProductList = LMS_Utility.getProductLines().values();
                                  }       
                                  
                                  if(eligibleProductList.size()>0) 
                                      for(LMS_ProductLine__c prod: eligibleProductList){
                                          products.put(prod.Name,prod);
                                          productType.put(prod.ProductLineName__c,prod.SIP_Product__c==true ? 'SIP Products' : 'IC Products');
                                      }
                                      system.debug('inside userType setter:'+products);  
                                  prepareProductLineLicenses();    
                              }        
                          }
    }
    public transient String endUserAccountId  {get;
                                               set{ 
                                                   if(selectedAccount==NULL || selectedAccount.Id != value){
                                                       selectedAccount = [Select id,name from account where id=:value Limit 1]; 
                                                       refresh();
                                                   }
                                                   endUserAccountId = value;      
                                               }
    }
    public List<SelectOption> selectProdType{  
        get
        {
            List<selectOption> temp = new List<selectOption>();
            temp.add(new SelectOption('-- SELECT --', '-- SELECT --'));
            //selectedProduct = '-- SELECT --';
            if(productVersion.keySet().size()>0) 
                for(String s : productVersion.keySet())
                temp.add(new SelectOption(s, String.format('{0}_{1}', new List<String>{productType.get(s),s})));
            return temp;  
        } set;
    }
    public String selectedInstallSite  {get;set;}
    public String selectedProdLine {get; set;}
    public String urlPrefix {get; set;}
    public Boolean showMailConnector{get;set;}
    public Boolean showSystemType{get;set;}
    public Boolean showExpiry {get{
     if(requestType == 'Temporary' || requestType == 'Hybrid' || requestType == 'Dummy')
         return true;
     else
         return false;    
    }set;}
    
    public Boolean hasLicense {
        get{
            if(prodlineKeys<>NULL && prodlineKeys.size()>0){
                List<String> cats = prodlineKeys.values();
                if(!hasLicense && cats.contains('License'))
                   return true;
            }
            return false;   
        }
        set;}
    
    public Boolean hasAddon {
        get{
            system.debug('inside hasAddon:');
            if(!selectedLic.Ordered__c){
                if(prodlineKeys<>NULL && prodlineKeys.size()>0){
                    List<String> cats = prodlineKeys.values();
                    if(!hasAddon && cats.contains('Addon License'))
                        return true;
                }
                return false;   
            }
            return hasAddon; 
        }
        set;}
    
    public Boolean hasFeature {
        get{
            if(prodlineKeys<>NULL && prodlineKeys.size()>0){
                List<String> cats = prodlineKeys.values();
                if(!hasFeature && cats.contains('Feature'))
                    return true;
            }
            return false;   
        }
        set;}
    
    public List<LicenseSummaryWrapper> licenseSummaryData {get; set;}
    public List<LicenseSummaryWrapper> addOnSummaryData {get; set;}
    
    /*used by hybrid */
    public List<LicenseSummaryWrapper> SubscriptionSummaryData {get; set;}
    
    public List<LicenseSummaryWrapper> switchoverSummaryData {get; set;}
    public LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest req {get;set;}
    public LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest SIPreq {get;set;}
    List<LMS_LicenseGenerationRequestWrapper.Licenses> licenseLst;
    List<LMS_LicenseGenerationRequestWrapper.Features> featLst;
    Map<String,String> SIPlicense ; 
    List<String> SIPFeatures;
    public License_Request_Log__c log {get;set;}
    public transient License_Request_Log__c clonedLog {get; set;}
    
    public Boolean hasSwitchOverParts{get;set;}
    public String selectedProduct {get;set;}     
    Map<String,Boolean> partAddonVisibility;    
    
    public List<SelectOption> selectProdLineList{ get; set;}
    public boolean displaySummary {get; set;}
    public String switchHostIds {get;set;}
    public String switchmachineNames {get;set;}
    
    public Boolean show{get;set;}
    
    Map<String,Set<License_Translations__c>> partTranslations;
    public List<License_Usage__c> LicenseUsageList;
    public Account selectedAccount;
    
    LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection ilc= new LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection();
    List<LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers> ilist = new List<LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers>();
    LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection SIPilc= new LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection();
    List<LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers> SIPilist = new List<LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers>();
    String version;
    public Boolean validVersion{get;set;}
    
    public User u {get;set;}
    public String[] soldToAccountIds { get; set;}   
    public String selectedSoldToAccountId {get; set;}
    public Boolean isMultipleSoldTos {
        get {
            if(soldToAccountIds<>NULL && soldToAccountIds.size()>1)
                return true;
            else
                return false;    
        } 
        set;
    }
    public Boolean showSwitchoverMachineDetail {get; set;}
    public Map<String,List<SelectOption>> licensePickValues, tempPickValues;
    
    public String requestLogId {get; set;} //This used in the update License page load
    
    private String requestLog;
    public Boolean init{
        get{
            if(!requestLogId.equalsIgnoreCase(requestLog)) {   
                requestLog= requestLogid;
                pageBlock = 'page3';
                updateErrMsg='';
                //inputs = new LMS_Utility.SelectionWrapper();
                inputs.LicenseUsageList = new List<License_Usage__c>();
                log = [select IsActive__c,Type__c,SystemType1__c,mailconnector1__c,MAC_Address__c ,Machine_Name__c, License_Text__c,End_User__c,End_User__r.Name,
                       Sold_to__c,Expiration_Date__c,Generation_Date__c,Temp_License_type__c,License_Type__c,License_Type__r.Name,Product_Line__c,Product_Line__r.ProductLineName__c,
                       Product_Line__r.name, Requested_By__c, Requested_By__r.Name,Install_Site__c,Install_Site__r.Name,Notes__c 
                       from License_Request_Log__c 
                       where id =: requestLog];
                       SYstem.debug('Internal License Type'+log.Temp_License_type__c);
                inputs.requestType = log.type__c;       
                selectedProdLine = log.Product_Line__r.Name;
                selectedProduct = log.Product_Line__r.ProductLineName__c;
                selectedLicense = log.license_Type__r.name;
                selectedSoldToAccountId = log.sold_to__c;
                List<String> machineIds = splitMultiple(log.Mac_Address__c);
                List<string> machinenames = splitMultiple(log.Machine_Name__c);
                
                if(machineIds.size()>1){
                    log.MAC_Address__c = machineIds[0].Trim();
                    switchHostIds = machineIds[1].Trim();
                }
                if(machineNames.size()>1){
                    log.Machine_Name__c = machinenames[0].Trim();
                    switchmachineNames = machinenames[1].Trim();
                }
                
                pageTwoCompleted();
                populateOrder(); 
            }
            else{
                log = [select IsActive__c,type__c, SystemType1__c,mailconnector1__c,MAC_Address__c ,Machine_Name__c,Temp_License_type__c, License_Text__c,End_User__c,End_User__r.Name,Sold_to__c,Expiration_Date__c,Generation_Date__c,License_Type__c,License_Type__r.Name,Product_Line__c,Product_Line__r.ProductLineName__c,Product_Line__r.name, Requested_By__c, Requested_By__r.Name,Install_Site__c,Install_Site__r.Name,Notes__c from License_Request_Log__c where id =: requestLog];
                List<String> machineIds = splitMultiple(log.Mac_Address__c);
                List<string> machinenames = splitMultiple(log.Machine_Name__c);
                
                if(machineIds.size()>1){
                    log.MAC_Address__c = machineIds[0].Trim();
                    switchHostIds = machineIds[1].Trim();
                    show=false;
                }
                if(machineNames.size()>1){
                    log.Machine_Name__c = machinenames[0].Trim();
                    switchmachineNames = machinenames[1].Trim();
                }
                //isHybrid = log.type__c;
            } 
            return false;    
        } 
    }
    
    List<SelectOption> LicenseTypes,TempTypes;
    Set<String> switchoverpartnumbers;
  transient  Map<String,Set<License_Snapshot__c>> partNumbers;
    Map<String,String> partIdMappings;  //ServerPartnumber, ProductId map
    
    Map<String,LicenseSummaryWrapper> populatedSummaryData; //partnumber, licensesummarywrapper
    
    public Map<String,List<NonOrderedLicense>> nonOrderedLicenses {get;set;}
    public Boolean isNonOrdered {get;set;}
    
    public String selectedLicense {get; 
    set{
        selectedLicense = value;
        }
    }
    
    public String selectedTempType {get; set;}
    
    public LMS_License_Types__c selectedLic{
        get{
            system.debug('inside selectedLic:'+selectedLicense);
            selectedLic = LicenseMap.get(selectedLicense);
            return selectedLic;
        }
        set;
    }
    
    public Static String noKeyStr{get{
        return 'This item is legally licensed however no license string appears to \'key\' the item in the product.';
    }set;} 
    
    public Map<String,Set<String>> productVersion {
        get{
            Set<String> uniqueVersions = new Set<String>();
            Map<String,Set<String>> tempVersionMap = new Map<String,Set<String>>();
            
            for(LMS_ProductLine__c temp : products.values())
                if(tempVersionMap.containsKey(temp.ProductLineName__c)){
                    Set<String> strOptions = tempVersionMap.get(temp.ProductLineName__c);    
                    strOptions.add(temp.ProductLine_Version__c);
                }
            else{
                Set<String> strOptions = new Set<String>(); 
                strOptions.add(temp.ProductLine_Version__c);
                tempVersionMap.put(temp.ProductLineName__c,strOptions);
            }            
            
            return tempVersionMap;
        }set;} 
    
    public List<SelectOption> getSoldTo(){
        List<SelectOption> soldToOptions = new List<SelectOption>();
        List <Account> soldAccs = new List<Account>();
        if(soldToAccountIds <> NULL && soldToAccountIds.size()>0)
            soldAccs = [Select Id, Name from Account where id in : soldToAccountIds];
        
        if(soldAccs.size()>1){
            soldToOptions.add(new SelectOption('-- SELECT --','-- SELECT --'));
            for(Account acc : soldAccs)
                soldToOptions.add(new SelectOption(acc.Id, acc.Name));
        }
        else if(soldAccs.size()>0) {
            soldToOptions.add(new SelectOption(soldAccs[0].Id, soldAccs[0].Name));
            selectedSoldToAccountId = soldAccs[0].id;
        }
        
        return soldToOptions;    
    }
    
    public List<SelectOption> getLicenseTypes(){
        LicenseTypes = new List<SelectOption>(); 
        if(String.ISBLANK(requestLogId)){ 
            Set<String> temp = new Set<String>();
            LicenseTypes.add(new SelectOption('-- SELECT --','-- SELECT --'));
            if(!selectedProdLine.equalsIgnoreCase('-- SELECT --')){
                if(licensePickValues.containsKey(selectedProdLine))
                    for(SelectOption plt: licensePickValues.get(selectedProdLine))
                    LicenseTypes.add(plt);
            }
        }   
        return LicenseTypes;        
    } 
    
    public List<SelectOption> getTempTypes(){
        TempTypes = new List<SelectOption>(); 
        if(String.ISBLANK(requestLogId)){ 
            Set<String> temp = new Set<String>();
            TempTypes.add(new SelectOption('-- SELECT --','-- SELECT --'));
            if(!selectedLicense.equalsIgnoreCase('-- SELECT --')){
                if(tempPickValues.containsKey(selectedLicense))
                    for(SelectOption plt: tempPickValues.get(selectedLicense))
                    TempTypes.add(plt);
            }
        }   
        return TempTypes;        
    } 
    
    Map<String,String> keyDescription;
    Map<String,LMS_License_Types__c> licenseMap;
    Map<String,String> prodlineKeys;
    Map<String,String> fetchProductkeys(Boolean displayonDevState){
        try{
            Map<String,String> plKeys = new Map<String,String>();
            keyDescription = new Map<String,String>();
            
            LMS_ProductLine__c chosen = products.get(selectedProdLine);
            
            if(displayonDevState)
                for(LMS_Product_Line_Keys__c pl: [Select ProductLine__c,FeatureOpted__c,ProductLine__r.name,License_Category__c,License_Key__r.Key_Name__c,License_Key__c,License_Key__r.description__c,DefaultValueOnDev__c from LMS_Product_Line_Keys__c where productLine__c=:chosen.id and displayOnDev__c=:displayonDevState order by License_category__c desc]){
                    plKeys.put(pl.License_Key__r.Key_Name__c,pl.License_category__c);   
                    keyDescription.put(pl.License_Key__r.Key_Name__c,pl.License_Key__r.description__c); 
                }
            else
                for(LMS_Product_Line_Keys__c pl: [Select ProductLine__c,FeatureOpted__c,ProductLine__r.name,License_Category__c,License_Key__r.Key_Name__c,License_Key__c,License_Key__r.description__c,DefaultValueOnDev__c from LMS_Product_Line_Keys__c where productLine__c=:chosen.id order by License_category__c desc]){
                    plKeys.put(pl.License_Key__r.Key_Name__c,pl.License_category__c);   
                    keyDescription.put(pl.License_Key__r.Key_Name__c,pl.License_Key__r.description__c); 
                }    
            
            if(SULicensingFeatureProductLines.contains(selectedProdLine))
                plKeys.put(SULicensingFeatureKey,'Feature');    
            
            return plKeys;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No active productline keys available'));
            return null;
        } 
    }
    
    Public LMSNewLicenseComponentController(){
        internalLicenses = new Map<String,LMS_License_Types__c>();
        inputs = new LMS_Utility.SelectionWrapper();
        u = [SELECT id, ContactId, Name, Contact.AccountId,Contact.Name, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        
        LicenseMap = new Map<String,LMS_License_Types__c>();
        for(LMS_License_Types__c licType: [Select Id,Description__c,Name,LicenseTypeGUID__c,Use_Parent__c,Expiry_Duration__c,ExpiryType__c,Leagcy_Id__c,Ordered__c,Allow_Addons__c,internal__c FROM LMS_License_Types__c where internal__c = False and active__c = true]) 
            LicenseMap.put(licType.Name,licType);
        
        for(LMS_License_Types__c licType: [Select Id,Description__c,Name,LicenseTypeGUID__c,Use_Parent__c,Expiry_Duration__c,ExpiryType__c,Leagcy_Id__c,Ordered__c,Allow_Addons__c,internal__c FROM LMS_License_Types__c where internal__c = True and active__c = true]) 
            internalLicenses.put(licType.Name,licType);
        
        pageBlock = 'page1';
        show=false;
        showSubsAddon = false; // hybrid
        showExpiry=false;
        isMedia4 = false;
        hasSwitchOverParts = False;
        hasAddon = False;
        displaySummary = true;
        showSwitchoverMachineDetail = False;
        orderKeys=  new List<String>{'License','Addon License','Feature'};    
            inputs.LicenseUsageList = new List<License_Usage__c>();
        inputs.requestType = requestType;
        req = new LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();
        SIPreq = new LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();        
        switchoverpartnumbers = new Set<String>();
        partAddonVisibility = new Map<String,Boolean>();
        log = new License_Request_Log__c();
        selectedLic = new LMS_License_Types__c();
        selectedProduct = '-- SELECT --';
        selectedLicense = '-- SELECT --'; 
        getSecondaryPickVals();
    }
    
    public List<String> splitMultiple(String machines){
        machines = machines.replace('|',',');
        List<String> tempStr = new List<String>();
        for(String str:machines.split(',')){
            tempStr.add(str.trim());
        }
        return  tempStr;        
    }
    
    public void resetPaginationKey(){
      paginationKey = String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
    }
    
    public void refresh(){
        pageBlock = 'page1';
        show=false;
        hasSwitchOverParts = False;
        hasAddon = False;
        hasLicense = False;
        displaySummary = true;
        switchmachineNames = '';
        switchHostIds='';
        nonOrderedLicenses = new Map<String,List<NonOrderedLicense>>();
        log = new License_Request_Log__c();
        inputs = new LMS_Utility.SelectionWrapper();
        inputs.LicenseUsageList = new List<License_Usage__c>();
        inputs.requestType = requestType;
        req = new LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();
        SIPreq = new LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();        
        switchoverpartnumbers = new Set<String>();
        selectedLic = new LMS_License_Types__c();
        selectedInstallSite = 'All Install Sites';
        selectedProduct = '-- SELECT --';
        selectedLicense = '-- SELECT --';
        selectedSoldToAccountId = '--SELECT--';
        
        getSecondaryPickVals();
        
        licenseSummaryData = new List<LicenseSummaryWrapper>();
        addOnSummaryData = new List<LicenseSummaryWrapper>();
        subscriptionSummaryData = new List<LicenseSummaryWrapper>();
    }
    
    
    public void populateNonOrdered(){
        prodlineKeys = fetchProductKeys(TRUE);
        nonOrderedLicenses = new Map<String,List<NonOrderedLicense>>();
        hasLicense = hasAddon = hasFeature = false;
        validVersion = Double.ValueOf(products.get(selectedProdLine).ProductLine_Version__c) > 3.0 ? TRUE : FALSE;
        if(prodlineKeys.keyset().size()>0){  system.debug('inside populateNonOrdered');
            for(String key : prodlineKeys.keyset())
                if(nonOrderedLicenses.containsKey(prodlineKeys.get(key))){
                    List<NonOrderedLicense> keys = nonOrderedLicenses.get(prodlineKeys.get(key));
                    License temp = new License(key,'30','10',keyDescription.get(key),prodlineKeys.get(key));
                    keys.add(new NonOrderedLicense(temp,FALSE));
                }
            else{
                License temp = new License(key,'30','10',keyDescription.get(key),prodlineKeys.get(key));
                nonOrderedLicenses.put(prodlineKeys.get(key),new List<NonOrderedLicense>{new NonOrderedLicense(temp,FALSE)});
                
                if(!hasLicense && prodlineKeys.get(key).equalsIgnoreCase('License'))
                    hasLicense = true;
                if(!hasAddon && prodlineKeys.get(key).equalsIgnoreCase('Addon License'))
                    hasAddon = true;
                if(!hasFeature && prodlineKeys.get(key).equalsIgnoreCase('Feature'))
                    hasFeature = true;        
            }     
            pageBlock = 'NonOrdered';
        }
        else
            pageBlock='NoServer';   
    }
    
    public void prepareProductLineLicenses(){
        licensePickValues = new Map<String,List<SelectOption>>();
        tempPickValues = new Map<String,List<SelectOption>>();
        Set<Id> ProductLineIds = new Set<Id>();
        if(products.values().size()>0){
            for(LMS_ProductLine__c line: products.values())
                productLineIds.add(line.id);
            
            List<LMS_ProductLineTypes__c> plTypes = [SELECT Id, LicenseType__c,LicenseType__r.name, ProductLine__c,productLine__r.name from LMS_ProductLineTypes__c where productLine__c =:productLineIds];
            
            if(plTypes.size()>0)
                for(LMS_ProductLineTypes__c types: plTypes){
                    if(licensePickValues.containsKey(types.ProductLine__r.Name)){
                        List<SelectOption> options = licensePickValues.get(types.ProductLine__r.Name);    
                        options.add(new selectOption(types.LicenseType__r.name,types.LicenseType__r.name));
                    }
                    else{
                        List<SelectOption> options = new List<SelectOption>(); 
                        options.add(new selectOption(types.LicenseType__r.name,types.LicenseType__r.name));
                        licensePickValues.put(types.ProductLine__r.Name,options);
                    }
                    
                    if(userType.equalsIgnoreCase('Internal')) 
                        if(!tempPickValues.containsKey(types.LicenseType__r.name)){
                            List<SelectOption> options = new List<SelectOption>();
                            for(String Str : internalLicenses.keyset())                          
                                options.add(new selectOption(Str,Str));
                            tempPickValues.put(types.LicenseType__r.name,options);
                        }    
                }        
        }
    }
    
    public void getSecondaryPickVals(){ 
        selectProdLineList = new List<selectOption>();
        selectedProdLine = '-- SELECT --';
        selectProdLineList.add(new SelectOption('-- SELECT --', '-- SELECT --'));
        if(!selectedProduct.equalsIgnoreCase('-- SELECT --'))
            for(String s : productVersion.get(selectedProduct)){
                selectProdLineList.add(new SelectOption(selectedProduct + ' ' + s, selectedProduct + ' ' + s));
                version = s;
            }    
    }
    
    public void populateOrder(){ 
        Map<String,License_Usage__c> requestedProduct = new Map<String,License_Usage__c>();
        
        for(License_Usage__c usage : [Select account__c,product__c,product__r.APN_Number__c,quantity_used__c,license_request_log__c from License_Usage__c where license_request_log__c=:log.id])
            requestedProduct.put(usage.product__r.apn_number__c,usage);
        
        List<Integer> index = new List<Integer>();  
      //  for(LicenseSummaryWrapper wrapperRec : licenseSummaryData)
      if(licenseSummaryData!=null && licenseSummaryData.size()>0){
       for(Integer i = licenseSummaryData.size()-1;i>=0;--i){
           LicenseSummaryWrapper wrapperRec=licenseSummaryData[i];
           
           System.debug('Part Number'+wrapperRec.partNumber+'available'+wrapperRec.available);
            if(requestedProduct.containsKey(wrapperRec.partNumber)){
                if(wrapperRec.available>0){
                    inputs.selectedServer = wrapperRec.partNumber;
                    wrapperRec.isselected=true;
                    wrapperRec.orderedQty = (requestedProduct.get(wrapperRec.partNumber).quantity_used__c).intValue();
                }
                else{
                  licenseSummaryData.remove(i);  
                  //  index.add(licenseSummaryData.indexOf(wrapperRec));
                }
            }
        else if(((!requestedProduct.containsKey(wrapperRec.partNumber)) && wrapperRec.available<=0)){ 
            licenseSummaryData.remove(i);  
           // index.add(licenseSummaryData.indexOf(wrapperRec));
        }
    }}
      /*  for(Integer ind : index)
            licenseSummaryData.remove(ind); */  
        
        if(licenseSummaryData.size()>0){
            displaySummary = true;
        }   
        else{
            pageBlock = 'NoServer';
            displaySummary = False;
        }
        
        index = new List<Integer>();  
      //  for(LicenseSummaryWrapper wrapperRec : addonSummaryData){ 
          if(addonSummaryData!=null && addonSummaryData.size()>0){
          for(Integer i = addonSummaryData.size()-1;i>=0;--i){
             LicenseSummaryWrapper wrapperRec=addonSummaryData[i]; 
            if(requestedProduct.containsKey(wrapperRec.partNumber)){
                wrapperRec.isselected=true;
                if(wrapperRec.available>0){
                    wrapperRec.orderedQty = (requestedProduct.get(wrapperRec.partNumber).quantity_used__c).intValue();
                    if(wrapperRec.orderedQty > wrapperRec.available)
                        if(String.ISBLANK(updateErrMsg))
                        updateErrMsg = '<br/>'+ wrapperRec.partNumber + '<br/>';
                    else    
                        updateErrMsg = '<br/>'+ wrapperRec.partNumber + '<br/>' + updateErrMsg ;  
                }
                else{
                    addonSummaryData.remove(i); 
                   // index.add(addonSummaryData.indexOf(wrapperRec));
                }
            }   
        }}
      /*  for(Integer ind: index){
            addonSummaryData.remove(ind);
        } */         
        
        if(!String.ISBLANK(updateErrMsg)){
            updateErrMsg = 'Please review the ordering quantity for below add-on parts<br/>'+updateErrMsg; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,updateErrMsg));
        }    
        
        index = new List<Integer>();  
        //for(LicenseSummaryWrapper wrapperRec : switchoverSummaryData)
        if(switchoverSummaryData!=null && switchoverSummaryData.size()>0){
        for(Integer i = switchoverSummaryData.size()-1;i>=0;--i){
            LicenseSummaryWrapper wrapperRec=switchoverSummaryData[i]; 
            if(requestedProduct.containsKey(wrapperRec.partNumber)){
                wrapperRec.isselected=true;
                inputs.selectedSwitchover = wrapperRec.partNumber;
                if(wrapperRec.available>0){
                    wrapperRec.orderedQty = (requestedProduct.get(wrapperRec.partNumber).quantity_used__c).intValue();
                }
                else { 
                    switchoverSummaryData.remove(i); 
                   // index.add(switchoverSummaryData.indexOf(wrapperRec));
                }
            }
        else if(((!requestedProduct.containsKey(wrapperRec.partNumber)) && wrapperRec.available<=0)){ 
            index.add(switchoverSummaryData.indexOf(wrapperRec));
        }       
        }}
      /*  for(Integer ind: index){
            switchoverSummaryData.remove(ind);
        } */
        
        if(switchoverSummaryData.size()>0)
            hasSwitchOverParts = true;
        else{
            hasSwitchOverParts = false; 
            show = true;
        }       
    } 
    
    public void pageTwoCompleted(){
        if(userType.equalsIgnoreCase('Internal')) 
            for(String str: internalLicenses.keySet())  // This adds the temp licenses
            LicenseMap.put(str, LicenseMap.get(selectedLicense)); 
        system.debug('selectedLicense:'+selectedLicense+' selectedProdLine:'+selectedProdLine);
        inputs.isSIP = products.get(selectedProdLine).SIP_Product__c;
        system.debug('passed products:'+products.get(selectedProdLine));
        inputs.selectedProduct = products.get(selectedProdLine); 
        resetPaginationKey();  
        if(selectedLic.ordered__c){
            if(!inputs.requestType.equalsIgnoreCase('Dummy'))
                fetchProductServerParts(); 
            else
                fetchProductParts();    
            if(licenseSummaryData.size()>0){
                pageBlock = 'page3';
                displaySummary = TRUE;
                showSystemType = products.get(selectedProdLine).ShowSystemType__c;
                showMailConnector = products.get(selectedProdLine).ShowMailConnector__c;
                
                if(switchOverSummaryData.size()>0)
                    hasSwitchOverParts = True;
                else{
                    hasSwitchOverParts = False;   
                    show = true;
                }
                
                if(selectedLicense.equalsIgnoreCase('Production') && !inputs.isSIP)  
                    if(hasSwitchOverParts)
                    showSwitchoverMachineDetail = True;
                
                if(selectedLicense.equalsIgnoreCase('Ordered Development') && !inputs.isSIP){
                    showSwitchoverMachineDetail = True;          
                    show = False;
                }         
            }
            else{
                pageBlock = 'NoServer';
                displaySummary = False;
            }
            
        }
        else{ // nonorderedlicense request
            showSystemType = products.get(selectedProdLine).ShowSystemType__c;
            showMailConnector = products.get(selectedProdLine).ShowMailConnector__c;
            populateNonOrdered();
            if(!inputs.isSip)
                show=false;
            else
                show = true;
            hasSwitchOverParts=true;         
            isNonOrdered = true;
        }    
    }    
    
    public void dummyAction(){
        if(products.get(selectedProdLine).ProductLineName__c.equalsIgnoreCase('Interaction Media Server') && products.get(selectedProdLine).ProductLine_Version__c.equalsIgnoreCase('4.0'))
            if(mediaPartList.contains(inputs.selectedServer))
            isMedia4 = true;
        
        if(partAddonVisibility.containsKey(inputs.selectedServer))   
            if(Products.get(selectedProdLine).SIP_Product__c && partAddonVisibility.get(inputs.selectedServer))   
            isMedia4 = true; 
    }
    
    public List<SelectOption> getInstallSites(){
        return LMS_Utility.getInstallSites(endUserAccountId);
    }
    
    public void validateAddons(){
        updateErrMsg ='';
        for(LicenseSummaryWrapper wrapperRec : addonSummaryData){
            system.debug('inside validate addons:'+wrapperRec.orderedQty);
            if(wrapperRec.orderedQty > wrapperRec.available)
                updateErrMsg = '<br/>'+ wrapperRec.partNumber+ '<br/>' + updateErrMsg ;    
        }   
        if(!String.ISBLANK(updateErrMsg)){
            updateErrMsg = 'Please review the ordering quantity for below add-on parts'+updateErrMsg; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,updateErrMsg));
        }          
    }
    
    public void fetchProductParts(){
        licenseSummaryData = new List<LicenseSummaryWrapper>();
        addOnSummaryData = new List<LicenseSummaryWrapper>();
        switchoverSummaryData = new List<LicenseSummaryWrapper>();
        Map<String, Product2> partMaster = new Map<String, Product2>();
        partNumbers = new Map<String,Set<License_Snapshot__c>>(); 
        Set<String> serverpartnumbers = new Set<String>();
        //Set<String> switchoverpartnumbers = new Set<String>();
        String selectedLicenseId = selectedLic.Id;
        
        transient Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();   
        transient Map<String, Integer> licensesUsed = new Map<String, Integer>();
        version = products.get(selectedProdLine).ProductLine_Version__c;
        
        Set<String> Item_Category = LMS_Utility.getProductCategoryCodes(selectedProduct);
        Set <String> validCodes = new Set<String>{'001', '005', '007', '009', '010', '011', '012', '013', '014', '015', '016', '019', '023', '024', '025', '027', '029', '510'};
        Set<String> invalidProds = new Set<String>{'3GP%','MP%'};
        for(String str : Item_Category)
           if(!validCodes.contains(str))
                Item_Category.remove(str);
        Map<String,set<String>> exclusionmap = LMS_Utility.getExclusion('Internal', 'Product2');
        set<String> exset;
     
        String exclusionwhere='';
        for(String str:exclusionmap.keySet()){
            exset=new set<String>();
            exset= exclusionmap.get(str)  ;
                          
             for(String s:exset){
             exclusionwhere+='AND (NOT '+str+' LIKE \''+s+'\')'; 
             }
             }
            
                  
            
            

         
         if(!inputs.isSIP){ 
           exclusionwhere+=' AND (NOT APN_Number__c LIKE \''+'SY%'+'\')';  
         }     
        
        System.debug('Exclusion condition'+exclusionwhere);

        String query ='select Id,Product_Name__c,Name,Building_Block__c,APN_Number__c,perpetual_product__c,perpetual_product__r.APN_Number__c' 
                       +' from Product2 where isActive = TRUE AND offeringtype__c includes (\''+'PureConnect On Premise'+'\')'
                        +' AND item_category__c in:Item_Category AND item_version__c =:version AND (NOT APN_Number__c like :invalidProds)';
                        
        if(exclusionwhere!=''||exclusionwhere!=null)
                       query+=exclusionwhere;
                        
          System.debug('Exclusion queryn'+query);               
           List<Product2>  lstpart=Database.query(query) ;
           for(Product2 part:lstpart){          
     /*  for(Product2 part: [select Id,Product_Name__c,Name,Building_Block__c,APN_Number__c,perpetual_product__c,perpetual_product__r.APN_Number__c 
                            from Product2 
                            where isActive = TRUE 
                            AND offeringtype__c includes (: 'PureConnect On Premise') 
                            AND item_category__c in:Item_Category 
                            AND item_version__c =:version 
                            AND (NOT APN_Number__c like :invalidProds) 
                            AND (NOT APN_Number__c like :invalidProds)
                            
                            
                            Order by APN_Number__c])
                            //AND APN_Number__c<>NULL LIMIT 500])*/
        partMaster.put(part.APN_Number__c,part);}
        system.debug('1) SW-012-4.0-SA01 presence:'+partMaster.containsKey('SW-012-4.0-SA01'));
        for(License_Translations__c lt:[SELECT Id, Item_Number__c FROM License_Translations__c WHERE SIP_Product__c!=:inputs.isSIP and Item_Number__c IN :partMaster.keyset()])
            if(partMaster.containsKey(lt.Item_Number__c))
                partMaster.remove(lt.Item_Number__c);
        system.debug('2) SW-012-4.0-SA01 presence:'+partMaster.containsKey('SW-012-4.0-SA01'));
        List<LMS_ProductLine_Product_Mapping__c> productLinePartMappings = [Select id,ProductLine__c,Allow_Addons__c,Product_Part__c,Product_Item__c,LicenseType__c,LicenseType__r.name 
                                                                            from LMS_ProductLine_Product_Mapping__c 
                                                                            where ProductLine__c=:products.get(selectedProdLine).id AND Product_Item__c =:partMaster.keySet()];      
        
        //Seperating Server Part numbers
        for(LMS_ProductLine_Product_Mapping__c p : productLinePartMappings){
            if(p.LicenseType__c==selectedLicenseId){
                serverpartnumbers.add(p.product_item__c);
                String val = p.Product_Part__c+'';
                partAddonVisibility.put(p.product_item__c,p.Allow_Addons__c);
            }
        }
        
        //seperating switchover
        for(LMS_ProductLine_Product_Mapping__c p : productLinePartMappings){
            if(!serverpartnumbers.contains(p.product_item__c))
                if(p.LicenseType__r.name.equalsIgnoreCase('Switchover')){
                    switchoverpartnumbers.add(p.product_item__c);
                    String val = p.Product_Part__c+'';
                }    
        }
        
        //Cleaning irrelevant server parts and addon parts
        List<LMS_ProductLine_Product_Mapping__c> irRelevantPartMappings = [Select id,ProductLine__c,Allow_Addons__c,Product_Part__c,Product_Item__c,LicenseType__c from LMS_ProductLine_Product_Mapping__c where ProductLine__c=:products.get(selectedProdLine).id AND (LicenseType__c!=:selectedLicenseId AND LicenseType__r.name<>'Switchover')];            
        for(LMS_ProductLine_Product_Mapping__c p : irRelevantPartMappings){
            if(partMaster.containsKey(p.product_Item__c))
                partMaster.remove(p.product_item__c);
            if(serverPartNumbers.contains(p.product_item__c))
                serverPartNumbers.remove(p.Product_Item__c);
            if(switchoverpartnumbers.contains(p.Product_Item__c))
                switchoverpartnumbers.remove(p.Product_Item__c);
        }
        system.debug('1) SW-012-4.0-SA01 presence:'+partMaster.containsKey('SW-012-4.0-SA01'));
        Map<String,String> plKeys = LMS_Utility.fetchKeys(selectedProdLine);
        partNumberKeys = LMS_Utility.getPartKeyString(partMaster.keyset(), inputs.isSip);
        for(String serPart: serverpartnumbers)
            licenseSummaryData.add(new LicenseSummaryWrapper(serPart+'', partMaster.get(serPart).Name,99999,0, partNumberKeys.get(serPart),partMaster.get(serPart).id));
        
        for(String serPart: switchoverpartnumbers)
            switchoverSummaryData.add(new LicenseSummaryWrapper(serPart+'', partMaster.get(serPart).Name,99999,0, partNumberKeys.get(serPart),partMaster.get(serPart).id));
        
        for(String items: partMaster.keyset()){
            if(!(serverpartNumbers.contains(items) || switchoverpartnumbers.contains(items))){ //Non Server Parts
            addOnSummaryData.add(new LicenseSummaryWrapper(items+'', partMaster.get(items).Name,99999,0, partNumberKeys.get(items),partMaster.get(items).id));
                system.debug('1) SW-012-4.0-SA01 presence:'+items);
        
        }}
        if(addOnsummaryData.size()>0)    
            hasAddon=true;    
    }
    
    public void fetchProductServerParts(){
        licenseSummaryData = new List<LicenseSummaryWrapper>();
        addOnSummaryData = new List<LicenseSummaryWrapper>();
        subscriptionSummaryData = new List<LicenseSummaryWrapper>();
        switchoverSummaryData = new List<LicenseSummaryWrapper>();
        
        Map<String,String> partIdMappings = new Map<String,String>();
        
        String selectedLicenseId = selectedLic.Id;
        
        transient Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();   
        transient Map<String, Integer> licensesUsed = new Map<String, Integer>();
        partNumbers = new Map<String,Set<License_Snapshot__c>>(); 
        
        version = products.get(selectedProdLine).ProductLine_Version__c;
        List<License_Snapshot__c> licenseSnapShotData = new List<License_Snapshot__c>();
        /*if(userType != 'Internal' && inputs.requestType == 'Temporary')
            licenseSnapShotData = LMS_Utility.getLicenseSnapshotData(endUserAccountId, selectedSoldToAccountId, selectedProduct, version, true);
        else */
            licenseSnapShotData = LMS_Utility.getLicenseSnapshotData(endUserAccountId, selectedSoldToAccountId, selectedProduct, version);
        
        String usageQueryConditions = '';
        String installSiteQueryConditions = '';
        usageQueryConditions = usageQueryConditions + ' AND License_Request_Log__r.End_User__c = \''+endUserAccountId +'\' ';
        if(userType != 'Internal'){
            usageQueryConditions = usageQueryConditions + ' AND License_Request_Log__r.Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        }
        if(requestLogId != NULL){
            usageQueryConditions = usageQueryConditions + ' AND License_Request_Log__c != \''+requestLogId +'\' ';
        }
        
        if(selectedInstallSite != 'All Install Sites'){
            installSiteQueryConditions = installSiteQueryConditions + ' AND License_Request_Log__r.Install_Site__c = \''+selectedInstallSite+'\' ';
        }
        String usageQuery = 'SELECT License_Request_Log__r.Sold_To__c soldTo,Product__r.APN_Number__c productNumber, SUM(Quantity_Used__c) quantity '
            + 'FROM License_Usage__c WHERE License_Request_Log__r.IsActive__c = true ' + usageQueryConditions
            + 'GROUP BY License_Request_Log__r.Sold_To__c, Product__r.APN_Number__c';
        
        
        AggregateResult[] usageResults = Database.query(usageQuery);
        for (AggregateResult ar : usageResults ) {
            licensesUsed.put(String.valueOf(ar.get('soldTo')) + '-' + String.valueOf(ar.get('productNumber')), Integer.valueOf(ar.get('quantity')));
        }   
        
        for(License_Snapshot__c lsh : licenseSnapShotData){  
            if(partNumbers.containsKey(lsh.Part_Number__c)){
                Set<License_Snapshot__c> tempSnap = partNumbers.get(lsh.part_Number__c);
                tempSnap.add(lsh);
            }
            else{
                Set<License_Snapshot__c> tempSnap = new Set<License_SnapShot__c>();
                tempSnap.add(lsh);
                partNumbers.put(lsh.Part_Number__c,tempSnap);                
            }
        }
        
        
        List<LMS_ProductLine_Product_Mapping__c> productLinePartMappings = [Select id,ProductLine__c,Allow_Addons__c,Product_Part__c,Product_Item__c,LicenseType__c,LicenseType__r.name from LMS_ProductLine_Product_Mapping__c where Product_Item__c =:partNumbers.keySet() and ProductLine__c=:products.get(selectedProdLine).id];      
        
        //Seperating Server Part numbers
        
        Set<String> serverpartnumbers = new Set<String>();
        for(LMS_ProductLine_Product_Mapping__c p : productLinePartMappings){
            if(p.LicenseType__c==selectedLicenseId){
                serverpartnumbers.add(p.product_item__c);
                String val = p.Product_Part__c+'';
                partIdMappings.put(p.product_item__c,val);
                partAddonVisibility.put(p.product_item__c,p.Allow_Addons__c);
            }
        }
        
        //seperating switchover
        for(LMS_ProductLine_Product_Mapping__c p : productLinePartMappings){
            if(!partIdMappings.containsKey(p.product_item__c))
                if(p.LicenseType__r.name.equalsIgnoreCase('Switchover')){
                    switchoverpartnumbers.add(p.product_item__c);
                    String val = p.Product_Part__c+'';
                    partIdMappings.put(p.product_item__c,val);
                }    
        }
        
        //Cleaning irrelevant server parts and addon parts
        List<LMS_ProductLine_Product_Mapping__c> irRelevantPartMappings = [Select id,ProductLine__c,Allow_Addons__c,Product_Part__c,Product_Item__c,LicenseType__c from LMS_ProductLine_Product_Mapping__c where Product_Item__c =:partNumbers.keySet() and ProductLine__c=:products.get(selectedProdLine).id AND (LicenseType__c!=:selectedLicenseId AND LicenseType__r.name<>'Switchover')];            
        for(LMS_ProductLine_Product_Mapping__c p : irRelevantPartMappings)
            if(partNumbers.containsKey(p.product_Item__c))
            partNumbers.remove(p.product_item__c);
        
        for(License_Translations__c lt:[SELECT Id, Item_Number__c FROM License_Translations__c WHERE SIP_Product__c!=:inputs.isSIP and Item_Number__c IN :partnumbers.keyset()])
            if(partnumbers.containsKey(lt.Item_Number__c))
            partNumbers.remove(lt.Item_Number__c);
        
        Map<String,String> plKeys = LMS_Utility.fetchKeys(selectedProdLine);
        partNumberKeys = LMS_Utility.getPartKeyString(partNumbers.keyset(), inputs.isSip);
        
        for(String serPart: serverpartnumbers){
            if(partNumbers.containsKey(serPart))
                for(License_Snapshot__c lsh : partNumbers.get(serPart)){
                    if(String.isBlank(requestLog)){ 
                        Integer total,used;
//                        if(inputs.requestType == 'Temporary')
                        if(userType.equalsIgnoreCase('Internal'))
                            total = (lsh.Perpetual__c + lsh.Non_Perpetual__c).intValue();
                        else
                            total = lsh.Perpetual__c.intValue();       
                            //total = lsh.total__c.intValue(); 
                        
  
                        used = licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c)!= NULL ? licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c) : 0;
                        
                        Integer available = total - used;
                        
                        if(available > 0)
                            licenseSummaryData.add(new LicenseSummaryWrapper(lsh.Part_Number__c+'', lsh.Description__c, total, used, partNumberKeys.get(lsh.Part_Number__c),lsh.Product__c));
                    }
                    else
                        licenseSummaryData.add(new LicenseSummaryWrapper(lsh.Part_Number__c+'', lsh.Description__c, lsh.Total__c, licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c), partNumberKeys.get(lsh.Part_Number__c),lsh.Product__c));    
                }
        }
        
        for(String serPart: switchoverpartnumbers){
            if(partNumbers.containsKey(serPart))
                for(License_Snapshot__c lsh : partNumbers.get(serPart)){
                    if(String.isBlank(requestLog)){ 
                        Integer total, used;
                        // if(inputs.requestType == 'Temporary')
                        if(userType.equalsIgnoreCase('Internal'))
                            total = (lsh.Perpetual__c + lsh.Non_Perpetual__c).intValue();
                        else
                            total = lsh.Perpetual__c.intValue();
                            //total = lsh.total__c.intValue();    // remove this when temp is rolled out
                        
                        used = licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c)!= NULL ? licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c) : 0;
                        
                        Integer available = total - used;
                        
                        if(available > 0)
                            switchoverSummaryData.add(new LicenseSummaryWrapper(lsh.Part_Number__c+'', lsh.Description__c, total, used, partNumberKeys.get(lsh.Part_Number__c),lsh.Product__c));
                    }
                    else
                        switchoverSummaryData.add(new LicenseSummaryWrapper(lsh.Part_Number__c+'', lsh.Description__c, lsh.Total__c, licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c), partNumberKeys.get(lsh.Part_Number__c),lsh.Product__c));          
                }
        }
        
        for(String parts: partNumbers.keyset())      
            if(!partIdMappings.containsKey(parts)) //Non Server Parts
            for(License_Snapshot__c lsh : partNumbers.get(parts)){
                Integer total, used;
                // if(inputs.requestType == 'Temporary')
                if(userType.equalsIgnoreCase('Internal'))
                    total = (lsh.Perpetual__c + lsh.Non_Perpetual__c).intValue();
                else
                    total = lsh.Perpetual__c.intValue();    
                    //total = lsh.total__c.intValue();    // remove this when temp is rolled out
                
                
                used = licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c)!= NULL ? licensesUsed.get(lsh.sold_to__c+'-'+lsh.Part_Number__c) : 0;
                Integer available = total - used;
                if(available > 0){
                    addOnSummaryData.add(new LicenseSummaryWrapper(lsh.Part_Number__c+'', lsh.Description__c, total, used,  partNumberKeys.get(lsh.Part_Number__c),lsh.Product__c));
                }   
            }
        if(addOnSummaryData.size() > 0){
            hasAddon = true;   
        }
        
        if(inputs.requestType.equalsIgnoreCase('Hybrid')){
            SubscriptionSummaryData = LMSHybridLicenseController.fetchSubscriptionParts(selectedProduct,partNumbers.keySet(),inputs.isSip);
            for(LicenseSummaryWrapper subData : SubscriptionSummaryData)
                licensesUsed.put(selectedSoldToAccountId + '-' + subData.partNumber, 0);
        }
        
        if(selectedLic.use_Parent__c){
            requests = [select Id,Generation_Date__c,Generated_By__c,License_Text__c,IsActive__c,Product_Line__r.Name,Install_Site__c,License_Type__r.Name,End_User__c,Sold_To__c,Notes__c from License_Request_Log__c WHERE End_User__c = :selectedAccount.Id and Sold_To__c=:selectedSoldToAccountId and License_Type__r.Name='Production' and Install_Site__c=:selectedInstallSite and Product_Line__c=:products.get(selectedProdLine).id and isActive__c = True];
        }
        
    }
    
    public String populateLicense(){
        SIPlicense = new Map<String,String>();
        SIPFeatures = new List<String>();
        Map<String,String> plKeys;
        populatedSummaryData = new Map<String,LicenseSummaryWrapper>();
        
        hasLicense = hasAddon = hasFeature = false;
        
        if(show || (!showSwitchoverMachineDetail && !hasSwitchOverParts) ){  // this manages the switchover selection
            for(String switchPart : switchoverpartnumbers){
                integer i = 0;
                for(LicenseSummaryWrapper lw: licenseSummaryData){       
                    if(lw.partnumber.equalsIgnoreCase(switchPart)){
                        licenseSummaryData.Remove(i);
                    }  
                    i = i+1;
                }   
            }
            log.mac_address__c = log.mac_address__c.Trim();
            log.Machine_Name__c = log.Machine_Name__c.Trim();
        }
        else{               
            log.MAC_address__c = (log.MAC_address__c.Trim())+'|'+(switchHostIds.Trim());
            log.Machine_Name__c = (log.Machine_Name__c.Trim())+'|'+(switchmachineNames.Trim());
        }
        
        if(selectedLic.ordered__c){
            plKeys = LMS_Utility.fetchKeys(selectedProdLine); 
            cleanUnselected();
            inputs.LicenseUsageList.addAll(LMS_Utility.populateSummary(endUserAccountId, 'server', licenseSummaryData));
            if(!show)
                inputs.LicenseUsageList.addAll(LMS_Utility.populateSummary(endUserAccountId, 'server', switchoverSummaryData));
            if(selectedLic.Allow_Addons__c || isMedia4) 
                inputs.LicenseUsageList.addAll(LMS_Utility.populateSummary(endUserAccountId, 'addon', addOnSummaryData));      
            
            LMS_Utility.KeyCountWrapper wrap = LMS_Utility.processKeys(inputs);
            licenseLst = wrap.licenseLst;
            if(SULicensingFeatureProductLines.contains(selectedProdLine))
                wrap.featureSet.add(SULicensingFeatureKey);      
            
            if(!inputs.isSIP){
                licenseLst = LMS_Utility.sumAllLicenses(licenseLst);
                featLst = new List<LMS_LicenseGenerationRequestWrapper.Features>();
                for(String key: wrap.featureSet){
                    LMS_LicenseGenerationRequestWrapper.Features featTemp = new LMS_LicenseGenerationRequestWrapper.Features();
                    featTemp.name = key;
                    featLst.add(featTemp);
                } 
            }else{
                for(LMS_LicenseGenerationRequestWrapper.Licenses l: licenseLst) {
                    Integer qty = Integer.ValueOf(l.assigned) + Integer.ValueOf(l.pooled);
                    SIPlicense.put(l.Name,String.valueOf(qty));
                }    
                for(String str: wrap.featureSet)
                    SIPFeatures.add(str);
            }        
            
        }  
        else{
            licenselst = new List<LMS_LicenseGenerationRequestWrapper.Licenses>();
            featlst = new List<LMS_LicenseGenerationRequestWrapper.Features>(); 
            for(String type : nonOrderedLicenses.keySet()){
                if(type.equalsignorecase('License') || type.equalsignorecase('Addon License')){ //checks category
                    for(NonOrderedLicense lic:nonOrderedLicenses.get(type))
                        if(Integer.valueOf(lic.licenseObj.assigned)>0 || Integer.valueOf(lic.licenseObj.pooled)>0){
                            String keyStr = lic.licenseObj.name+ ' (Assigned:'+Integer.valueOf(lic.licenseObj.assigned)+' Pooled: '+Integer.valueOf(lic.licenseObj.pooled)+')'; 
                            if(!inputs.isSip) {
                                LMS_LicenseGenerationRequestWrapper.Licenses licen = new LMS_LicenseGenerationRequestWrapper.Licenses();
                                licen.Name = lic.licenseObj.name;
                                licen.Assigned = lic.licenseObj.assigned;
                                licen.Pooled = lic.licenseObj.pooled;
                                licenselst.add(licen);
                            }
                            else{
                                SIPlicense.put(lic.licenseObj.name,(Integer.valueOf(lic.licenseObj.assigned)+Integer.valueOf(lic.licenseObj.pooled))+'');
                            }
                            if(type.equalsIgnoreCase('License'))    hasLicense = true;
                            if(type.equalsIgnoreCase('Addon License'))    hasAddon = true;
                        }    
                }
                if(type.equalsignorecase('Feature')){
                    for(NonOrderedLicense lic:nonOrderedLicenses.get(type))
                        if(lic.isSelected || lic.licenseObj.name.equalsIgnoreCase(SULicensingFeatureKey)){
                            if(!inputs.isSip){
                                LMS_LicenseGenerationRequestWrapper.Features licen = new LMS_LicenseGenerationRequestWrapper.Features();
                                licen.Name = lic.licenseObj.name;
                                featlst.add(licen);
                            }
                            else{
                                SIPFeatures.add(lic.licenseObj.name);
                            }
                            hasFeature = true;
                        }       
                }
            }
        }        
        
        return generatePayload(); 
    }
    
    
    
    String GeneratePayload(){
        String str;
        if(!show){
                req.MachineIds = splitMultiple(log.MAC_Address__c);
                req.MachineNames = splitMultiple(log.Machine_Name__c);
                req.CombineServersIntoOneBundle = TRUE;
        }
        else{
                req.MachineIds = new List<String>{log.MAC_Address__c};
                req.MachineNames = new List<String>{log.Machine_Name__c};
                req.CombineServersIntoOneBundle = FALSE;        
        }
        if(!inputs.isSIP){
            req.AccountName=selectedAccount.Name;
            req.productName = products.get(selectedProdLine).Name;
            
            req.licenses = licenselst; 
            req.features = featlst;
            req.productVersion = products.get(selectedProdLine).ProductLine_Version__c;
            req.GenerationDate = system.now().format('yyyy-MM-dd HH:mm:ss');
            System.debug('generation date '+system.now().format('yyyy-MM-dd HH:mm:ss'));
            if(showExpiry)
                req.ExpirationDate = log.Expiration_Date__c.format('yyyy-MM-dd 15:00:00');
            else    
                req.ExpirationDate = getExpiryDate(); 
            
            if(show)
                req.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+' MAC address: '+req.MachineNames[0]+' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;
            else
                req.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+'#'+req.MachineIds[1]+' MAC address: '+req.MachineNames[0]+'#'+req.MachineNames[1]+ ' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;        
            
            req.BundleName = products.get(selectedProdLine).Name + ' Subscription';    
            if(selectedLic.Name.equalsIgnoreCase('Trial') || selectedLic.Name.equalsIgnoreCase('Trial System'))
                req.BundleType = 1;
            else
                req.BundleType=0;
            
            if(selectedLic.LicenseTypeGUID__c.equalsignorecase('257B2203-70BE-4EEE-AA93-12D5E079BF62'))
                req.BundleName = products.get(selectedProdLine).Name+' Internal Development Bundle';
            else
                req.BundleName = products.get(selectedProdLine).Name + ' '+ selectedLic.Name + ' Bundle';       
            
            req.LicenseTypeGUID=selectedLic.LicenseTypeGUID__c;
            
            if(selectedLic.Name.equalsIgnoreCase('Non-ordered Development') && products.get(selectedProdLine).ProductLine_Version__c.equalsIgnoreCase('4.0')) 
                populateNonOrderedInvalidation();   
            else if(requestLog <> NULL && products.get(selectedProdLine).ProductLine_Version__c.equalsIgnoreCase('4.0'))
                populateInvalidation(log.License_Text__c);            
            else
                ilc.InvalidatedLicenseIdentifiers = ilist;
            
            req.InvalidatedLicenseIdentifierCollection = ilc ;
            str = JSON.serialize(req);        
            system.debug('end of generatepayload():'+str);   
        }else{
            SIPreq.ProductName = products.get(selectedProdLine).Name;
            SIPreq.CompanyName = selectedAccount.Name;
            SIPFeatures.sort();
            SIPreq.licenses = SIPlicense;
            SIPreq.features = SIPFeatures;   
            if(show){
                SIPreq.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+' MAC address: '+req.MachineNames[0]+' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;
                SIPreq.MachineId = log.Mac_Address__c;
                SIPreq.MachineName = log.Machine_Name__c;
            }
            else{
                SIPreq.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+'#'+req.MachineIds[1]+' MAC address: '+req.MachineNames[0]+'#'+req.MachineNames[1]+ ' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;                       
            }    
            SIPreq.GenerationDate = system.now().format('yyyy-MM-dd HH:mm:ss');
            if(selectedLic.Name.equalsIgnoreCase('Trial') || selectedLic.Name.equalsIgnoreCase('Trial System'))
                SIPreq.BundleType= 1;
            else
                SIPreq.BundleType= 0;
            if(showExpiry)
                SIPreq.ExpirationDate = log.Expiration_Date__c.format('yyyy-MM-dd 15:00:00');             
            else
                SIPreq.ExpirationDate = getExpiryDate();             
            SIPreq.LicenseTypeGUID=selectedLic.LicenseTypeGUID__c;    
            
            if(products.get(selectedProdLine) != NULL && products.get(selectedProdLine).SIPType__c != NULL && products.get(selectedProdLine).SIPType__c.equalsIgnoreCase('Media Server') && products.get(selectedProdLine).ProductLine_Version__c.equalsIgnoreCase('4.0')) {
                List<License_Request_Log__c> mediaLicenses = [Select Id, license_text__c,Generation_Date__c from license_request_log__c where Product_Line__c =:products.get(selectedProdLine).id AND End_User__c =:selectedAccount.Id AND isActive__c=False ORDER BY Generation_Date__c];  
                Set<String> licenseTexts = new Set<String>();
                for(License_Request_Log__c l: mediaLicenses)
                    licenseTexts.add(l.license_text__c);
                populateMediaInvalidation(licenseTexts);
            }
            SIPilc.InvalidatedLicenseIdentifiers = SIPilist;       
            str = JSON.serialize(SIPreq);     
        }
        return str;   
    }
    
    public void cleanUnselected(){
        List<LicenseSummaryWrapper> tempAdds = new List<LicenseSummaryWrapper>();
        Set<String> parts = new Set<String>();
        
        for(LicenseSummaryWrapper adds:licenseSummaryData)
            if(adds.partNumber.equalsIgnoreCase(inputs.selectedServer)){
                adds.isSelected = True;
                adds.orderedQty = 1;
                tempAdds.add(adds);
                parts.add(adds.partNumber);
            }   
        LicenseSummaryData = tempAdds;
        tempAdds = new List<LicenseSummaryWrapper>();
        
        for(LicenseSummaryWrapper adds:SwitchoverSummaryData)
            if(adds.partNumber.equalsIgnoreCase(inputs.selectedSwitchover)){
                adds.isSelected = True;
                adds.orderedQty = 1;
                tempAdds.add(adds);
                parts.add(adds.partNumber);
            }   

        SwitchoverSummaryData = tempAdds;
        tempAdds = new List<LicenseSummaryWrapper>();
        
        for(LicenseSummaryWrapper adds:addonSummaryData) 
             if(adds.orderedQty > 0){
                 adds.isSelected = True;
                 tempAdds.add(adds);
                 parts.add(adds.partNumber);                  
             }   

        addonSummaryData = tempAdds;
        tempAdds = new List<LicenseSummaryWrapper>();            
        
        if(inputs.requestType.equalsIgnoreCase('Hybrid')){
            tempAdds = new List<LicenseSummaryWrapper>();
            for(LicenseSummaryWrapper adds:subscriptionSummaryData){
                if(adds.orderedQty > 0){
                    adds.isSelected = True;
                    tempAdds.add(adds);
                    parts.add(adds.partNumber);                      
                }   
            }
            addonSummaryData.addAll(tempAdds);  //Copy selected subscriptions to addon 
            subscriptionSummaryData.clear();
        }
        
        if(partNumbers <> NULL)
        for(String str: partNumbers.keySet()) //Clean unnecessary snasphot map
            if(!parts.contains(str))
            partNumbers.remove(str);
    }
    
    public void populateNonOrderedInvalidation(){
        List<String> collectedVals = new List<String>();
        List<License_Request_Log__c> requests = [Select Id, license_text__c,Generation_Date__c from license_request_log__c where Product_Line__c =:products.get(selectedProdLine).id AND End_User__c =:selectedAccount.Id AND (mac_Address__c=:log.mac_address__c OR mac_Address__c like: log.mac_address__c+'|%' or mac_Address__c like: '%|'+log.mac_Address__c or mac_address__c like: '%|'+log.mac_Address__c+'|%') ORDER BY Generation_Date__c];
        List<String> licenses = new List<String>();
        if(requests.size()>0){
            for(License_Request_Log__c l : requests)
                licenses.add(l.license_text__c);
        }  
        if(licenses.size()>0)
            collectedVals = collectLicenseIdentifiers(licenses);
        
        List<String> machineIds = splitMultiple(log.Mac_Address__c);
        
        for(String mac: machineIds){ // if any serverIdentifier matches to current request hostIds, then populate invalidation
            for(String vals : collectedVals)
                if(inputs.isSip)
                SIPilist.add(new LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers(selectedAccount.Id+'', products.get(selectedProdLine).id+'', selectedLic.id+'', vals, mac, TRUE));
            else
                ilist.add(new LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers(selectedAccount.Id+'', products.get(selectedProdLine).id+'', selectedLic.id+'', vals, mac, TRUE));    
        }
        if(ilist.size()>0) //start constructing XML
            ilc.InvalidatedLicenseIdentifiers = ilist;
        if(SIPilist.size()>0)
            SIPilc.InvalidatedLicenseIdentifiers = SIPilist;    
    }
    
    public List<String> collectLicenseIdentifiers(List<String> licenseTxts){
        List<String> identifiers = new List<String>();
        for(String xmlString : licenseTxts) {
            Dom.Document doc = new Dom.Document();
            doc.load(xmlString);
            Dom.XMLNode licenseRoot = doc.getRootElement();
            Dom.XMLNode licensefileNode;
            
            if(licenseRoot.getName()=='LicenseFiles')
                licensefileNode = licenseRoot.getChildElement('LicenseFile', null);
            else
                licensefileNode = licenseRoot;      
            
            String licenseIdentifier = licensefileNode.getAttributeValue('identifier',NULL);
            if(!String.ISBLANK(licenseIdentifier))
                identifiers.add(licenseIdentifier);
        }
        return identifiers;   
    }
    
    public void populateInvalidation(String XMLString){
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        Dom.XMLNode licenseRoot = doc.getRootElement();
        Dom.XMLNode licensefileNode;
        
        if(licenseRoot.getName()=='LicenseFiles')
            licensefileNode = licenseRoot.getChildElement('LicenseFile', null);
        else
            licensefileNode = licenseRoot;      
        
        String licenseIdentifier = licensefileNode.getAttributeValue('identifier',NULL);
        
        Dom.XMLNode serversNode = licensefileNode.getChildElement('Servers', null);
        Set<String> serverIdentifierSet = new Set<String>();
        for(Dom.XmlNode server: serversNode.getChildElements()) {
            serverIdentifierSet.add(server.getAttributeValue('identifier',NULL));
        }
        List<String> machineIds = splitMultiple(log.Mac_Address__c);
        
        
        for(String mac: machineIds){ // if any serverIdentifier matches to current request hostIds, then populate invalidation
            if(serverIdentifierSet.contains(mac))
                if(inputs.isSip)
                SIPilist.add(new LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers(selectedAccount.Id+'', products.get(selectedProdLine).id+'', selectedLic.id+'', licenseIdentifier, mac, TRUE));
            else
                ilist.add(new LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers(selectedAccount.Id+'', products.get(selectedProdLine).id+'', selectedLic.id+'', licenseIdentifier, mac, TRUE));    
        }
        
        if(ilist.size()>0) //start constructing XML
            ilc.InvalidatedLicenseIdentifiers = ilist;
        if(SIPilist.size()>0)
            SIPilc.InvalidatedLicenseIdentifiers = SIPilist;                
    }
    
    public void populateMediaInvalidation(Set<String> XMLStrings){
        Set<String> identifiers = new Set<String>(); 
        for(String xmlString : XMLStrings) {
            Dom.Document doc = new Dom.Document();
            doc.load(xmlString);
            Dom.XMLNode licenseRoot = doc.getRootElement();
            Dom.XMLNode licensefileNode;
            
            if(licenseRoot.getName()=='LicenseFiles')
                licensefileNode = licenseRoot.getChildElement('LicenseFile', null);
            else
                licensefileNode = licenseRoot;      
            
            Dom.XMLNode serversNode = licensefileNode.getChildElement('Servers', null);
            Dom.XMLNode serverNode = serversNode.getChildElement('Server', null);
            identifiers.add(serverNode.getAttributeValue('identifier',NULL));
        }
        
        for(String identity : identifiers)
            SIPilist.add(new LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers(selectedAccount.Id+'', products.get(selectedProdLine).id+'', selectedLic.id+'', identity, log.MAC_Address__c, TRUE));
        
        SIPilc.InvalidatedLicenseIdentifiers = SIPilist;                   
    }
    
    public String getExpiryDate(){
        DateTime dt = system.now();
        if(selectedLic.Name.equalsIgnoreCase('Production') || selectedLic.Name.equalsIgnoreCase('Ordered Development') || selectedLic.Name.equalsIgnoreCase('Switchover')){ // this adds expiration to 2100 only for new production license
           
           
          //  dt = Date.newInstance(2100, 1, 1);
         dt= DateTime.newInstance(2100, 1, 1, 15, 0, 0);
        } else{
            if(selectedLic.ExpiryType__c.equals('Hours'))               
                dt = dt.addHours(Integer.ValueOf(selectedLic.Expiry_Duration__c));
            
            if(selectedLic.ExpiryType__c.equals('Days'))
                dt = dt.addDays(Integer.ValueOf(selectedLic.Expiry_Duration__c));
            
            if(selectedLic.ExpiryType__c.equals('Months'))
                dt = dt.addMonths(Integer.ValueOf(selectedLic.Expiry_Duration__c));
            
            if(selectedLic.ExpiryType__c.equals('Years'))
                dt = dt.addYears(Integer.ValueOf(selectedLic.Expiry_Duration__c));
        }    

        System.debug('@@Expiry Date'+ dt.format('yyyy-MM-dd HH:mm:ss'))   ; 
        return dt.format('yyyy-MM-dd HH:mm:ss');
    }
    
    public Boolean validateHosts(){ 
        String errMsg;
        Boolean state = true;
        if(String.isBlank(log.MAC_Address__c)){
            errMsg = '<br/>Host Id <br/>';
        }
        if(String.isBlank(log.Machine_Name__c)){
            if(!String.ISBLANK(errMsg))
                errMsg = errMsg+'Machine Name <br/>';
            else
                errMsg = '<br/>Machine Name <br/>';
        }
        if(!inputs.isSip){
            if(String.isBlank(switchHostIds)){
                if(!String.ISBLANK(errMsg))
                    errMsg = errMsg + 'Switchover Host Id <br/>';                
                else
                    errMsg = '<br/>Switchover Host Id <br/>';
            }
            if(String.isBlank(switchmachineNames)){
                if(!String.ISBLANK(errMsg))
                    errMsg = errMsg + 'Switchover Machine Name <br/>';
                else      
                    errMsg = '<br/>Switchover Machine Name <br/>';
            }
        }
        if(!show)
            if(!String.ISBLANK(errMsg)){
                errMsg='Please populate missing fields below <br/>'+errMsg;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errMsg));            
                state = false;
            }
        return state;
    }
    
    public void calloutLicenseService(){
        if(!String.isblank(updateErrMsg))
            validateAddons();
        if(String.isblank(updateErrMsg)) {
            if(validateHosts())  { 
                String jsonStr;
                if(selectedLic.use_parent__c)
                    jsonStr = readLicenseValues(inputs.selectedSwitchover);
                else
                    jsonStr = populateLicense();
                if(!String.isBlank(jsonStr)){
                    http h = new http();
                    // Savepoint sp = Database.setSavepoint();
                    version = products.get(selectedProdLine).ProductLine_Version__c;
                    httpRequest reqst = new httpRequest();
                    
                    String LMSLicenseGeneratorAPIString = '';
                    String LMSLicenseGenerator_Key = '';
                    if(!inputs.isSip)
                        if(version.equalsignorecase('1.0'))
                        LMSLicenseGenerator_Key = '3.0';
                    else
                        LMSLicenseGenerator_Key = version;
                    else if(sipType.equalsIgnoreCase('Media Server'))    
                        LMSLicenseGenerator_Key = 'MS'+version;
                    else if(sipType.equalsIgnoreCase('Bulk Caller')) 
                        LMSLicenseGenerator_Key =  'SIPBulk'+version; 
                    else if(!String.ISBLANK(inputs.selectedServer) && LMS_Utility.isSIPOverride(inputs.selectedServer)) 
                        LMSLicenseGenerator_Key = 'SIPOverride'+version;      
                    else
                        LMSLicenseGenerator_Key = 'SIP'+version;   
                    
                    if(LMS_License_Generator__c.getValues(LMSLicenseGenerator_Key) != NULL){
                        LMSLicenseGeneratorAPIString = LMS_License_Generator__c.getValues(LMSLicenseGenerator_Key).api__c;  
                    } else {
                        // Setting default for SIP 
                        LMSLicenseGeneratorAPIString = LMS_License_Generator__c.getValues('SIP_NOVERSION').api__c;
                    }
                    
                   reqst.setEndpoint('callout:LMS_LicenseGeneration_Services'+LMSLicenseGeneratorAPIString);
                   //reqst.setEndPoint('callout:SubscriptionAPI'); 
                    reqst.setMethod('POST');
                    reqst.setHeader('Content-Type', 'application/json');
                    reqst.setHeader('Content-Length',''+jsonStr.length());
                    reqst.setTimeout(120000); system.debug('request in callout:'+reqst);
                    reqst.setBody(jsonStr);
                    try{
                        httpResponse res = new httpResponse();
                        res = h.send(reqst);
                        if(res.getStatusCode() == 200|| res.getStatusCode() == 201){
                            if(String.isBlank(requestLog)) {
                                if(createLog(res.getBody()))
                                    pageBlock = 'page4';
                            }
                            else{

                                clonedLog = log.clone();
                                SYstem.debug('Cloned Internal License Type'+clonedLog.Temp_License_type__c+'Internal License type'+Log.Temp_License_type__c);
                                log.IsActive__c = FALSE;
                                clonedLog.Requested_By__c = UserInfo.getUserId();
                                clonedLog.License_Text__c = cleanseXMLString(res.getBody());
                                try{
                                    update log;
                                    if(!inputs.isSIP){
                                        clonedlog.Expiration_Date__c = parseDate(req.ExpirationDate);
                                        clonedlog.Generation_Date__c = parseDate(req.GenerationDate);
                                    }
                                    else{
                                        clonedlog.Expiration_Date__c = parseDate(SIPreq.ExpirationDate);
                                        clonedlog.Generation_Date__c = parseDate(SIPreq.GenerationDate);
                                    
                                    }
                                    //clonedLog.Expiration_Date__c = parseDate(req.ExpirationDate);
                                    //clonedLog.Generation_Date__c = parseDate(req.GenerationDate);
                                    insert clonedLog;
                                    for(License_Usage__c lu: inputs.LicenseUsageList)
                                        lu.License_Request_Log__c = clonedLog.id;
                                    insert inputs.LicenseUsageList;  // inserts all the License&Addon partnumbers except server parts with qty ordered and RequestLogId        
                                    
                                    inputs.LicenseUsageList = [Select ItemNumber__c,Account__c,Product__c, product__r.apn_number__c, Product__r.Name, Product__r.Description, Quantity_Used__c, License_Request_Log__c from License_Usage__c where License_Request_Log__c =: clonedLog.id ];   
                                    pageBlock = 'page4';
                                 
                                   log = clonedLog;
                                }
                                catch(Exception e){
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Creating request log failed: '+e.getMessage())); 
                                }      
                            }   

                        }
                        else{
                            BadRequest bad = parse(res.getBody()); 
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Bad Request: '+res.getStatusCode()+' : '+bad.Message)); 
                        }
                    }catch(System.CalloutException e){
                        system.debug(e);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Service Dropped and the error occured: '+e.getMessage()));
                    }
                }else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Request doesnt have body!'));   
            }     
        } //validateHosts 
    }    
    
    public String readLicenseValues(String requestVar){
        List<LMS_LicenseGenerationRequestWrapper.Licenses> lst = new List<LMS_LicenseGenerationRequestWrapper.Licenses>();
        List<LMS_LicenseGenerationRequestWrapper.Features> feats = new List<LMS_LicenseGenerationRequestWrapper.Features>();
        
        License_Request_Log__c request = [Select id, License_text__c, Expiration_Date__c, (Select Account__c,itemNumber__c,LicenseId__c,Log_Type__c,Product__c,Product__r.Name,Quantity_Used__c from License_Usages__r) usage from license_request_log__c where id=:requestVar limit 1];
        String xmlString = request.license_text__c;
        
        for(license_usage__c l : request.License_Usages__r){
            license_usage__c tl = new license_usage__c();
            tl.Account__c = l.Account__c;
            tl.ItemNumber__c = l.ItemNumber__c;
            tl.LicenseId__c = l.LicenseId__c;
            tl.Log_Type__c = l.Log_Type__c;
            tl.Product__c = l.Product__c;
            tl.Quantity_Used__c = l.Quantity_Used__c;
            inputs.LicenseUsageList.add(tl);
        }
        
        partNumbers = new Map<String,Set<License_Snapshot__c>>();
        
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        Dom.XMLNode licenseRoot = doc.getRootElement();
        Dom.XMLNode licensefileNode;
        
        if(licenseRoot.getName()=='LicenseFiles')
            licensefileNode = licenseRoot.getChildElement('LicenseFile', null);
        else
            licensefileNode = licenseRoot;      
        Dom.XMLNode serversNode = licensefileNode.getChildElement('Servers', null); 
        Dom.XMLNode serverNode = serversNode.getChildElement('Server', null); 
        Dom.XMLNode featuresNode = serverNode.getChildElement('Features', null);
        Dom.XMLNode licensesNode = serverNode.getChildElement('Licenses', null);
        List<String> featSet = new List<String>();
        for(Dom.XmlNode feat: featuresNode.getChildElements()) {
            LMS_LicenseGenerationRequestWrapper.Features ftemp = new LMS_LicenseGenerationRequestWrapper.Features();
            ftemp.name = feat.getAttributeValue('name',NULL);
            feats.add(ftemp);
        }
        
        for(Dom.XmlNode lice: licensesNode.getChildElements()) {
            LMS_LicenseGenerationRequestWrapper.Licenses lic1 = new LMS_LicenseGenerationRequestWrapper.Licenses();   
            lic1.Name = lice.getAttributeValue('name',NULL);             
            lic1.Assigned = '0';
            lic1.Pooled = lice.getAttributeValue('value',NULL)+'';
            lst.add(lic1);
        }
        
        licenseLst = lst;
        featLst = feats;
        req.AccountName=selectedAccount.Name;
        if(!show){
            req.MachineIds = splitMultiple(log.MAC_Address__c);
            req.MachineNames = splitMultiple(log.Machine_Name__c);
            req.CombineServersIntoOneBundle = TRUE;
        }
        else{
            req.MachineIds = new List<String>{log.MAC_Address__c};
                req.MachineNames = new List<String>{log.Machine_Name__c};
                    SIPreq.MachineId = log.Mac_Address__c;
            SIPreq.MachineName = log.Machine_Name__c;
            req.CombineServersIntoOneBundle = FALSE;        
        }
        req.productName = products.get(selectedProdLine).Name;
        req.licenses = licenselst;
        req.features = featlst;
        req.productVersion = products.get(selectedProdLine).ProductLine_Version__c;
        req.GenerationDate = system.now().format('yyyy-MM-dd HH:mm:ss');
        req.ExpirationDate = getExpiryDate(); 
        req.BundleType=0;
        if(show){
            req.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+' MAC address: '+req.MachineNames[0]+' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;
        }else{
            req.Description= 'Customer Name: '+selectedAccount.Name+' Server Name: '+ req.MachineIds[0]+'#'+req.MachineIds[1]+' MAC address: '+req.MachineNames[0]+'#'+req.MachineNames[1]+ ' Date Generated: '+req.GenerationDate+' Who Generated: '+ u.Name+' Anniversary/Expiration Date: '+req.ExpirationDate+' License Type: '+selectedLic.Name;        
        } 
        if(selectedLic.LicenseTypeGUID__c.equalsignorecase('257B2203-70BE-4EEE-AA93-12D5E079BF62'))
            req.BundleName = products.get(selectedProdLine).Name+' Internal Development Bundle';
        else
            req.BundleName = products.get(selectedProdLine).Name + ' '+ selectedLic.Name + ' Bundle';    
        ilc.InvalidatedLicenseIdentifiers = ilist;
        req.InvalidatedLicenseIdentifierCollection = ilc ;
        req.LicenseTypeGUID=selectedLic.LicenseTypeGUID__c;    
        return JSON.serialize(req);
    }
    
    public Boolean createLog(String response){
        log.End_User__c = endUserAccountId; 
        log.Sold_to__c = selectedSoldToAccountId;
        
        if(!inputs.isSIP){
                log.Expiration_Date__c = parseDate(req.ExpirationDate);
                log.Generation_Date__c = parseDate(req.GenerationDate);
        }
        else{
                log.Expiration_Date__c = parseDate(SIPreq.ExpirationDate);
                log.Generation_Date__c = parseDate(SIPreq.GenerationDate);
            
        }
        
        if(requestType.equalsIgnoreCase('Temporary'))
        log.Temp_License_type__c=internalLicenses.get(selectedTempType).Name;
         /*   log.license_type__c = internalLicenses.get(selectedTempType).id;
        else*/
            log.License_Type__c = selectedLic.Id;
            
        log.Product_Line__c = products.get(selectedProdLine).Id;
        log.Requested_By__c = userinfo.getuserId();
        log.Install_Site__c = selectedInstallSite;
        log.IsActive__c = TRUE;
        log.Type__c = requestType;
        
        log.License_Text__c = cleanseXMLString(response);
        system.debug('License Text: '+Log.License_Text__c);
        try{
            insert log;
            log = [select IsActive__c,SystemType1__c,mailconnector1__c,MAC_Address__c ,Machine_Name__c, License_Text__c,End_User__c,End_User__r.Name,Sold_to__c,Expiration_Date__c,Generation_Date__c,License_Type__c,Product_Line__c,Product_Line__r.ProductLineName__c,Product_Line__r.name, Requested_By__c, Requested_By__r.Name,Install_Site__c,Install_Site__r.Name,Notes__c from License_Request_Log__c where id =: log.id];
            selectedInstallSite = log.Install_Site__r.Name;
        
            for(License_Usage__c lu: inputs.LicenseUsageList)
                lu.License_Request_Log__c = log.id;
            
            insert inputs.LicenseUsageList;  // inserts all the License&Addon partnumbers except server parts with qty ordered and RequestLogId   
            inputs.LicenseUsageList = [Select ItemNumber__c,Account__c,Product__c, product__r.apn_number__c, Product__r.Name, Product__r.Description, Quantity_Used__c, License_Request_Log__c from License_Usage__c where License_Request_Log__c =: log.id ];   
            return true;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Creating request log failed : '+e.getMessage())); 
            return false;
        }
    }
    
    public String cleanseXMLString(String xmlString){
        if(xmlString.contains('"<'))
            xmlString=xmlString.replace('\"<','<');
        if(xmlString.contains('\\"'))
            xmlString = xmlString.replace('\\"','\"');    
        if(xmlString.contains('\\n'))
            xmlString = xmlString.replace('\\n',''); 
        if(xmlString.contains('\\n\"'))
            xmlString = xmlString.replace('\\n\"','');    
        if(xmlString.contains('>\"'))
            xmlString = xmlString.replace('>\"','>');    
        Dom.Document doc = new Dom.Document();
        system.debug('inside XMLCleanse after cleanse:'+xmlString);
        doc.load(xmlString);
        //Retrieve the root element for this document.
        Dom.XMLNode licenseRoot = doc.getRootElement();
        Dom.XMLNode licensefileNode;
        if(licenseRoot.getName()=='LicenseFiles')
            licensefileNode = licenseRoot.getChildElement('LicenseFile', null);
        else
            licensefileNode = licenseRoot;      
        if(products.get(selectedProdLine).SIP_Product__c)    
            if(products.get(selectedProdLine).SIPType__c != NULL && products.get(selectedProdLine).SIPType__c.equalsIgnoreCase('Media Server')){
                Dom.XMLNode serversNode = licensefileNode.getChildElement('Servers', null);
                Dom.XMLNode serverNode = serversNode.getChildElement('Server', null);
                licensefileNode = serverNode;
            }
        licensefileNode.addChildElement('DESC',null,null).addTextNode(selectedLic.description__c);
        licensefileNode.addChildElement('USER',null,null).addTextNode(selectedAccount.Name);
        if(selectedLic.ordered__c){
            licensefileNode = LMS_Utility.addItemstoXML(licensefileNode, inputs);
        }
        xmlstring = doc.toXmlString();
        
        return xmlString;     
    }
    
    public DateTime parseDate(String dtStr){
        DateTime dt;
        if(!String.ISBLANK(dtStr)){
            String[] str = dtStr.split(' ');
            String[] newdates = str[0].split('-');
            String[] newTimes = str[1].split(':');
            dt = DateTime.newInstance(Integer.valueOf(newdates[0]),Integer.valueOf(newdates[1]),Integer.valueOf(newdates[2]),Integer.valueOf(newTimes[0]), Integer.valueOf(newTimes[1]),Integer.valueOf(newTimes[2]));
        }
        return dt;
    }
    
    public BadRequest parse(String response) {        
        BadRequest bad = (BadRequest)JSON.deserializeStrict(response,BadRequest.class);
        return bad;
    }
    
    public class License{
        public String name{get;set;}
        public String assigned{get;set;}
        public Boolean showAssigned;
        public String pooled {get;set;}
        public String description {get;set;}
        public String type;
        
        public License(String name,String assigned,String pooled,Boolean showAssigned, String type){
            this.name = name;
            this.assigned = assigned;
            this.pooled=pooled;
            this.showAssigned=showAssigned;
            this.type = type;
        }
        
        public License(String name,String assigned,String pooled,String description,String type){
            this.name = name;
            this.assigned = assigned;
            this.pooled=pooled;
            this.type=type;
            this.description = description;
        }
    }
    
    
    public class NonOrderedLicense{
        public License licenseObj{get;set;}
        public Boolean isSelected{get;set;}        
        public NonOrderedLicense(License l,Boolean isSelect){
            licenseObj = l;
            isSelected = isSelect;
        }
    } 
    
    public class BadRequest{
        public String Message;
    }
}