public class NewSubscriptionComponentController {
    public String pageBlock {get; set;}
    @TestVisible Map<String,LMS_ProductLine__c> products;
    public Static List<String> orderKeys {get;set;} 
    public Contact accountSelection {get; set;}
    public String paginationKey {get;set;}
    Map<String,String> productType;
    public Boolean isSIP{get;set;}
    public Boolean showMailConnector{get;set;}
    public Map<String,String> licenseCompleteString {get;set;}
    public Set<String> mediaServerKeys = new Set<String> {'I3_FEATURE_MEDIASERVER_VIRTUALIZATION','I3_FEATURE_MEDIASERVER_DEVELOPMENT_LICENSE'}; 
    public Boolean show{get;set;}
    public Boolean showSystemType{get;set;}
    public Boolean hasLicense {get ;set;} 
    public Boolean hasAddon {get;set;}
    public Boolean hasFeature {get;set;}
    @TestVisible Map<String,String> SIPlicense ; 
    @TestVisible List<String> SIPFeatures;
    public Boolean newApi {Get; Set;}
    Map<String, SubscriptionKeyOverride__c> keyOverrideMap; String SULicensingFeatureKey = 'I3_FEATURE_SU_ALLOWED';
    Map<String,String> concurrentTrackingKeys = new Map<String,String>{'Automated'=>'I3_FEATURE_USAGE_TRACKING_UPLOAD','Manual'=>'I3_FEATURE_USAGE_TRACKING_LOCAL'};
    // String authKey = 'yNRuU@Stj7~^2LBuz=sKV>Tp-)Z[[+%$';
    public String selectedProdLine;
    public String selectedProductLine {get; 
        set{
            if(value.equalsIgnoreCase('Tracking API')){
                selectedProdLine = 'CIC 4.0';
                newApi = true;
                isSip = False;
          }
          else{
              selectedProdLine = value;
              newApi = false;
          }
         selectedProductLine = value;
        }
    }

    
    public String selectedServer{get;set;}
    public String urlPrefix {get; set;}
        
    public List<LicenseSummaryWrapper> licenseSummaryData {get; set;}
    public List<LicenseSummaryWrapper> addOnSummaryData {get; set;}

    public LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest req {get;set;}
    public LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest SIPreq;
    public SubscriptionRequestWrapper.SubscriptionRequest subscriptionReq; 
    public Subscription_Request_Log__c log {get;set;}
    public Map<String,Set<License_Translations__c>> partTranslations;
    public String selectedProduct {get;set;}     

    public boolean displaySummary {get; set;}
    public String switchHostIds {get;set;}
    public String switchmachineNames {get;set;}
    
    Order__c o;    
    @TestVisible List<License_Usage__c> LicenseUsageList;
    @TestVisible Map<String,Product2> populatedPartProducts; //ordered partnumber, product2
    public Account selectedAccount {get; set;}
    
     Map<String,Product2> perpetualSubscriptionMap; //perp apn, map<perpid, subscrip product
     Map<String,Product2> subscriptionPerpetualMap;
     @TestVisible Map<String,Product2> partMaster ;  
     List<LMS_LicenseGenerationRequestWrapper.Features> featLst;
     List<LMS_LicenseGenerationRequestWrapper.Licenses> licenseLst;  
     LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection ilc= new LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection();
     List<LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers> ilist = new List<LMS_LicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers>();
     
     List<SubscriptionRequestWrapper.Licenses> subscriptionLicenseLst;
     List<SubscriptionRequestWrapper.Features> subscriptionFeatLst; 
     SubscriptionRequestWrapper.InvalidatedLicenseIdentifierCollection silc= new SubscriptionRequestWrapper.InvalidatedLicenseIdentifierCollection();
     List<SubscriptionRequestWrapper.InvalidatedLicenseIdentifiers> silist = new List<SubscriptionRequestWrapper.InvalidatedLicenseIdentifiers>();
     List<SubscriptionRequestWrapper.DisplayInfo> dispList = new List<SubscriptionRequestWrapper.DisplayInfo>();
     LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection SIPilc= new LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifierCollection();
        List<LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers> SIPilist = new List<LMS_SIPLicenseGenerationRequestWrapper.InvalidatedLicenseIdentifiers>();
    
    String version;
    
    public User u {get;set;}
    public String soldToAccountId{get; set;}   
    Map<String,List<SelectOption>> licensePickValues;
    
        
    List<SelectOption> LicenseTypes;
    Set<String> switchoverpartnumbers;
    List<LMS_ProductLine__c> eligibleProductList;
    Map<String,String> serverProdMappings;  //ServerPartnumber, ProductId map
    Map<String,LicenseSummaryWrapper> populatedSummaryData; //partnumber, LicenseSummaryWrapper
    Map<String,License_Usage__c> requestedProduct;
    
    public String selectedLicense {get; set{
        system.debug('iside License set:'+value);
        selectedLicense = value;
    }
    }
    
    public String endUserAccountId  {get;
    set{ 
         if(selectedAccount==NULL || selectedAccount.Id != value){
             selectedAccount = [Select id,name,SAP_Account_Code__c from account where id=:value Limit 1]; 
             refresh();
         }
         endUserAccountId = value;      
      }
    }
    
    public LMS_License_Types__c selectedLic{
        get{
            selectedLic = [Select Id,Description__c,Name,LicenseTypeGUID__c,Expiry_Duration__c,ExpiryType__c,Leagcy_Id__c,Ordered__c FROM LMS_License_Types__c where Name=:selectedLicense LIMIT 1];
            return selectedLic;
        }
        set;
    }
    
    public List<SelectOption> productLines{get{
        if(productLines==NULL)
           productLines = prepareProductLines();
        return productLines;   
    } set;}
    
    public List<SelectOption> prepareProductLines(){
            productLines = new List<SelectOption>(); 
            productLines.add(new SelectOption('-- SELECT --','-- SELECT --'));
            for(LMS_ProductLine__c pline : [Select Id, Name, Product_Name__c, isActive__c from LMS_ProductLine__c where isActive__c = true and ProductLine_Version__c='4.0'])   
              productLines.add(new SelectOption(pline.Name,pline.Name));  
            productLines.add(new SelectOption('Tracking API','Tracking API'));     
            return productLines;        
        } 
    
    public Map<String,String> partNumbers;
    public Static String noKeyStr{get{
    return 'This item is legally licensed however no license string appears to \'key\' the item in the product.';
    }set;} 
    
    public Map<String,String> keyDescription;
    public BigMachines__Quote__c orderOpt {get;set;}
  
    BigMachines__Quote__c quoteOpted;
    Id deploymentId;
    Cloud_Deployment__c deployment;
    
    
    Public NewSubscriptionComponentController(){
        u = [SELECT id, ContactId, Name, Contact.AccountId,Contact.Name, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];   
        products = new Map<String,LMS_ProductLine__c>();
        newApi = False;
        accountSelection = new Contact();
        orderOpt = new BigMachines__Quote__c();
        quoteOpted = new BigMachines__Quote__c();
        partMaster = new Map<String,Product2>();
        pageBlock = 'page1';
        show=false; 
        isSIP = false;
        displaySummary = true;
        orderKeys=  new List<String>{'License','Addon License','Feature'};    
        LicenseUsageList = new List<License_Usage__c>();
        req = new LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();
        SIPreq = new LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();  
        subscriptionReq = new SubscriptionRequestWrapper.SubscriptionRequest(); 
        log = new Subscription_Request_Log__c();
        selectedLic = new LMS_License_Types__c();
        //selectedProduct = 'CIC';
        selectedLicense = 'Production';
        //selectedProdLine = 'CIC 4.0';
       
   }
   
   public List<String> splitMultiple(String machines){
     machines = machines.replace('|',',');
     return  machines.split(',');        
   }
   
    
   public void refresh(){
        LicenseUsageList = new List<License_Usage__c>();
        orderOpt = new BigMachines__Quote__c();
        quoteOpted = new BigMachines__Quote__c();
        
        if(licenseSummaryData <> NULL)
            licenseSummaryData.clear();
        if(addOnSummaryData <> NULL)    
            addOnSummaryData.clear();
        req = new LMS_LicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();
        SIPreq = new LMS_SIPLicenseGenerationRequestWrapper.LMS_LicenseGenerationRequest();  
        subscriptionReq = new SubscriptionRequestWrapper.SubscriptionRequest(); 
        log = new Subscription_Request_Log__c();
        LicenseUsageList = new List<License_Usage__c>();
        switchHostIds ='';
        switchmachineNames = '';
        pageBlock = 'page1';
        show = false;
        newApi = false;
        selectedProductLine = '-- SELECT --';
        selectedProduct = '';
        //pageTwoCompleted();
   }
   
   
    public void pageTwoCompleted(){
        if(String.IsNotBlank(accountSelection.accountId)){
        
          keyOverrideMap = new Map<String, SubscriptionKeyOverride__c>();
          List<SubscriptionKeyOverride__c> keyOverride = SubscriptionKeyOverride__c.getAll().values();
          for(SubscriptionKeyOverride__c val: keyOverride)
              keyOverrideMap.put(val.key__c,val);

          LMS_ProductLine__c ProdLine = [Select id,Name,ShowMailConnector__c,ShowSystemType__c,SIP_Product__c,SIPType__c,ProductLineName__c,ProductLine_Version__c from LMS_ProductLine__c where isActive__c= TRUE and Name =:selectedProdLine];
               products.put(ProdLine.Name,ProdLine);  
          selectedProduct = products.get(selectedProdLine).ProductLineName__c;
          isSIP = products.get(selectedProdLine).SIP_Product__c;
          show = isSip;
          selectedAccount = [Select Id,Name,type,SAP_Account_Code__c,AWS_access_key__c,AWS_Secret_Key__c from Account where id=: accountSelection.accountId limit 1];
          if(newAPI)
              if(String.isBlank(selectedAccount.AWS_access_Key__c) || String.isBlank(selectedAccount.AWS_Secret_Key__c))
                generateKey(selectedAccount.SAP_Account_Code__c,'','username');
          resetPaginationKey();
          fetchProductServerParts();
          pageBlock = 'page3';
          displaySummary = TRUE;
              
            
          }
          else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select an account')); 
          
    }    
    
    public void dummyAction(){
      
    }

   public String encrypt(String str){
     Map<String,String> encKeys = LMS_Utility.processEncryption(str);
     String key = (new list<string>(encKeys.keyset())[0]);
     List<String> vals = encKeys.Values();
     return key+vals[0];
   }

   public String decrypt(String str){
    List<String> kv = str.split('==');
    kv[0] = kv[0]+'==';
    return LMS_Utility.processDecryption(kv[0],kv[1]);
   } 

    public void generateKey(String name,String userName, String type){
    String accessKey, authKey, secretKey,payload;
    try{
        NamedCredential n =[SELECT DeveloperName,Endpoint,Id,MasterLabel,PrincipalType 
                            FROM NamedCredential
                            where DeveloperName ='AWS_IAM_Key'];
        authKey = LMS_License_Generator__c.getValues(n.Endpoint).api__c;
    }
    catch(Exception e){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please check the Named Creds & Custom setting has endpoint configured')); 
    }
    http h = new http();
    httpRequest reqst = new httpRequest();
    reqst.setMethod('POST');
    reqst.setHeader('Authorization', authKey);
    reqst.setHeader('Content-Type', 'application/json');
    reqst.setTimeout(120000);               

    if(type.equalsIgnoreCase('username'))
      reqst.setEndPoint('callout:AWS_IAM_Key'+'/iam/user/');   
    else 
      reqst.setEndPoint('callout:AWS_IAM_Key'+'/s3/object/');   

    try{
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
      gen.writeStringField(type, name);
      if(type.equalsIgnoreCase('object'))
          gen.writeStringField('username', userName);
      gen.writeEndObject();
      payload = gen.getAsString();
        system.debug('payload:'+payload);
      reqst.setBody(payload);
      system.debug('inside genereateKey payload:'+reqst.getBody());
      reqst.setHeader('Content-Length',''+payload.length());

      httpResponse res = new httpResponse();
      
      res = h.send(reqst);
      system.debug(Logginglevel.error,'resp: '+res.getStatusCode());
      
      if(res.getStatusCode() == 200|| res.getStatusCode() == 201){
        system.debug('inside success:'+res.getBody());
        if(type.equalsIgnoreCase('username')){
        JSONParser parser = JSON.createParser(res.getBody());
        system.debug('resp: '+res.getBody());
          while (parser.nextToken() != null) {
              system.debug('inside parser.nextToken: '+parser.getCurrentToken()+' : '+parser.getText());
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'AccessKeyId')) {
                    parser.nextToken();
                    accessKey = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SecretAccessKey')) {
                    parser.nextToken();
                    secretKey = parser.getText();
                }
          }       
        selectedAccount.AWS_access_key__c = encrypt(accessKey);
        selectedAccount.AWS_Secret_Key__c = encrypt(secretKey);
        update selectedAccount;
        }
      }
      else
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,res.getstatusCode()+' : '+res.getBody())); 
    }
    catch(Exception e){
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage())); 
    } 
   }
    
   
    public void fetchProductServerParts(){
        licenseSummaryData = new List<LicenseSummaryWrapper>();
        addOnSummaryData = new List<LicenseSummaryWrapper>();

        serverProdMappings = new Map<String,String>();
        partNumbers = new Map<String,String>();
        List<String> basePackage = new List<String>();
        String selectedLicenseId = selectedLic.Id;
               
        Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();
        Map<String, Integer> licensesUsed = new Map<String, Integer>();
        partTranslations = new Map<String,Set<License_Translations__c>>();
        perpetualSubscriptionMap = new Map<String,Product2>(); //perp apn, map<perpid, subscrip product
        subscriptionPerpetualMap = new Map<String,Product2>();
        partMaster = new Map<String,Product2>();
              
        Set<String> Item_Category = LMS_Utility.getProductCategoryCodes(selectedProduct);
                
         for(Product2 part: [select Id,Product_Name__c,Product_Sub_category__c,Name,Building_Block__c,APN_Number__c,perpetual_product__c,perpetual_product__r.APN_Number__c 
                             From product2 
                             where isactive=true and offeringtype__c includes (: 'PureConnect Subscription') AND 
                             item_category__c in:Item_Category AND 
                             (NOT APN_Number__c like '3GP%') AND 
                             (NOT APN_Number__c like 'TS%') AND
                             (NOT APN_Number__c like 'TH%') AND
                             APN_Number__c<>NULL ]){
            partMaster.put(part.APN_Number__c,part);
            if(part.perpetual_product__c<>NULL){
                perpetualSubscriptionMap.put(part.perpetual_product__r.apn_number__c,part);
                if(newApi && part.Name.contains('Base Agent Package'))
                    basePackage.add(part.perpetual_product__r.APN_Number__c);
            }
            if(part.perpetual_product__c==NULL){
                perpetualSubscriptionMap.put(part.apn_number__c,part);
                if(!String.ISBLANK(part.Name))
                if(newApi && part.Name.contains('Base Agent Package'))
                    basePackage.add(part.APN_Number__c);
            }
        }
        
        //Cleansing unnecessary parts
        for(License_Translations__c lt : [SELECT Id, item_number__c, SIP_Product__c FROM License_Translations__c WHERE item_number__c IN :partMaster.keyset() AND SIP_Product__c <>: isSIP]){
            //perpetualSubscriptionMap.remove(lt.item_number__c);
            partMaster.remove(lt.item_number__c);
        }
        
        for(Product2 part: [select Id,Product_Name__c,name,Building_Block__c ,APN_Number__c,perpetual_product__c from product2 where isactive=true and apn_number__c in:perpetualSubscriptionMap.keySet()]){
            subscriptionPerpetualMap.put(perpetualSubscriptionMap.get(part.apn_number__c).apn_number__c,part);
        }
        
        Set<String> serverpartnumbers = new Set<String>();
        for(String p : basePackage){
               serverpartnumbers.add(perpetualSubscriptionMap.get(p).apn_number__c);
               serverProdMappings.put(perpetualSubscriptionMap.get(p).apn_number__c,perpetualSubscriptionMap.get(p).id);
        }
        
        for(License_Translations__c lt : [SELECT Id, product__c,product__r.product_name__c,product__r.Building_Block__c, Item_Number__c,License_Key__r.category__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE item_number__c IN :perpetualSubscriptionMap.keyset()]){
            LicenseAssignedPooled TempAssignedPooled = generateMultipliersString(lt,perpetualSubscriptionMap.get(lt.Item_Number__c));
            lt.Assigned_Multiplier__c = TempAssignedPooled.Assigned;
            lt.Multiplier__c = TempAssignedPooled.Pooled;    
            
            if(partTranslations.containsKey(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c)) {
              partTranslations.get(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c).add(lt);  
            }   
            else{
              Set<License_Translations__c> tset = new Set<License_translations__c>();
              tset.add(lt); 
              partTranslations.put(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c,tset);
            }
            
            if(partNumberKeys.containsKey(lt.Item_Number__c)){
                partNumberKeys.get(lt.Item_Number__c).add(lt.License_Key__r.Key_Name__c + TempAssignedPooled.getMultipliersString());   
            } else {
                partNumberKeys.put(lt.Item_Number__c, new List<String>{lt.License_Key__r.Key_Name__c + TempAssignedPooled.getMultipliersString()}) ;   
            }
        }

               
        for(String serPart: serverpartnumbers){
            if(serverProdMappings.containsKey(serPart)){
                if(perpetualSubscriptionMap.containsKey(serPart)) //if cs part
                      licenseSummaryData.add(new LicenseSummaryWrapper(serPart+'', perpetualSubscriptionMap.get(serPart).Name,99999,0, partNumberKeys.get(serPart),perpetualSubscriptionMap.get(serPart).id));
                else
                      licenseSummaryData.add(new LicenseSummaryWrapper(serPart+'', partMaster.get(serPart).Name,99999,0, partNumberKeys.get(subscriptionPerpetualMap.get(serPart).apn_number__c),partMaster.get(serPart).id));    
            }
        }

        for(String items: partMaster.keyset()){
            if(!serverProdMappings.containsKey(items)){ //Non Server Parts
                if(perpetualSubscriptionMap.containsKey(items))
                    addOnSummaryData.add(new LicenseSummaryWrapper(items+'', perpetualSubscriptionMap.get(items).Name,99999,0, partNumberKeys.get(items),perpetualSubscriptionMap.get(items).id));
                else
                    addOnSummaryData.add(new LicenseSummaryWrapper(items+'', partMaster.get(items).Name,99999,0, partNumberKeys.get(subscriptionPerpetualMap.get(items).apn_number__c),partMaster.get(items).id));    
             }   
        }   
        
        if(addOnsummaryData.size()>0)    
            hasAddon=true;
    }
      
   LicenseAssignedPooled generateMultipliersString(License_Translations__c lt, Product2 prod){
      String multipliersString;  
      LicenseAssignedPooled lic = new LicenseAssignedPooled();
      lic.name = lt.License_Key__r.Key_Name__c;
      
    //  if(prod.Product_Sub_category__c<>NULL && prod.Product_Sub_category__c.equalsIgnoreCase('Development')){
      system.debug('inside dev prod name:'+prod.Name);  
          lic.assigned = Integer.valueOf(lt.Assigned_Multiplier__c);
        lic.pooled = Integer.valueOf(lt.Multiplier__c);
      //}
    /*  else if(prod.APN_Number__c.contains('-C-')){
        //multipliersString = ' (0 assigned,  1 pooled) ';
        lic.assigned = 0;
        lic.pooled = 1;
      }
      else{
        lic.assigned = 1;
        lic.pooled = 0;
        System.debug('License assigned hit---->');
      }*/
      
    if(keyOverrideMap.containsKey(lt.License_Key__r.Key_Name__c)){
        lic.assigned = Integer.valueOf(keyOverrideMap.get(lt.License_Key__r.Key_Name__c).assigned__c);
        lic.pooled = Integer.valueOf(keyOverrideMap.get(lt.License_Key__r.Key_Name__c).pooled__c);
    }
    
      return lic;
    }


      public String populateLicense(){
         licenseLst = new List<LMS_LicenseGenerationRequestWrapper.Licenses>();
         featLst = new List<LMS_LicenseGenerationRequestWrapper.Features>();
         subscriptionLicenseLst = new List<SubscriptionRequestWrapper.Licenses>();
         subscriptionFeatLst = new List<SubscriptionRequestWrapper.Features>();
         populatedPartProducts = new Map<String,Product2>();
         SIPlicense = new Map<String,String>();
         SIPFeatures = new List<String>();
        
         deployment = [Select Id, Usage_Tracking__c from cloud_Deployment__c where id=:log.cloud_Deployment__c];

        Map<String,String> plKeys;
        populatedSummaryData = new Map<String,LicenseSummaryWrapper>();
         
          if(show){  // this manages the switchover selection
            log.mac_address__c = log.mac_address__c.Trim();
            log.Machine_Name__c = log.Machine_Name__c.Trim();
          }
          else{
            log.mac_address__c = (log.mac_address__c.Trim())+'|'+(switchHostIds.Trim());
            log.Machine_Name__c = (log.Machine_Name__c.Trim())+'|'+(switchmachineNames.Trim());
          }
          
         
         List<String> apnNumbers = new List<String>();
         plKeys = LMS_Utility.fetchKeys(selectedProdLine); 
            
         for(LicenseSummaryWrapper adds:licenseSummaryData)
                      if(adds.orderedQty > 0) {
                          adds.isSelected = True;
                          selectedServer = adds.partnumber;
                      }    
                      else
                          adds.isSelected = False;    
         
 
               LicenseUsageList.addAll(LMS_Utility.populateSubscriptionSummary(endUserAccountId,'Server',selectedServer, licenseSummaryData, serverProdMappings,partMaster));
             
               LicenseUsageList.addAll(LMS_Utility.populateSubscriptionSummary(endUserAccountId,'addon','', addonSummaryData, Null,partMaster));
             
            
            for(License_Usage__c l : LicenseUsageList){
                apnNumbers.add(l.itemnumber__c);
            }
            
            for(Product2 p:[SELECT id,Name,APN_Number__c,Description,(select id,LicenseType__c from ProductLineProducts__r) productLineProduct from Product2 where APN_Number__c in: apnNumbers]){
                populatedPartProducts.put(p.APN_Number__c,p);
            }

        processKeys();       
        GeneratePayload();
        String str;
          if(!newAPI){
            if(isSIP)
             str = JSON.serialize(SIPreq);
            else    
             str = JSON.serialize(req);
          }   
          else
            str = JSON.serialize(subscriptionReq);    
        system.debug(Logginglevel.ERROR,'new json: '+str);
        return str;
    } 
    
    public void GeneratePayload(){
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
            if(!newApi) {
                if(!isSip){
                    req.AccountName=selectedAccount.Name;                 
                    req.productName = products.get(selectedProdLine).Name;
                    req.licenses = licenselst;
                    req.features = featlst;
                    req.productVersion = '4.0';
                    req.Description= selectedLic.Description__c;
                    req.GenerationDate = system.now().formatGMT('yyyy-MM-dd HH:mm:ss');
                    req.ExpirationDate = log.Expiration_Date__c.formatGMT('yyyy-MM-dd HH:mm:ss'); 
                    req.BundleName = products.get(selectedProdLine).Name + ' Subscription';      
                    req.BundleType= Integer.valueOf(selectedLic.Leagcy_Id__c);
                    req.LicenseTypeGUID=selectedLic.LicenseTypeGUID__c;     
                    ilc.InvalidatedLicenseIdentifiers = ilist;
                    req.InvalidatedLicenseIdentifierCollection = ilc ;   
                }
                else{
                    SIPreq.ProductName = products.get(selectedProdLine).Name;
                    SIPreq.CompanyName = selectedAccount.Name;
                    SIPreq.VersionNumber = products.get(selectedProdLine).ProductLine_Version__c;
                    SIPFeatures.sort();
                    SIPreq.licenses = SIPlicense;
                    SIPreq.features = SIPFeatures;   
                    SIPreq.Description= selectedLic.Description__c;
                    SIPreq.GenerationDate = system.now().format('yyyy-MM-dd HH:mm:ss');
                    SIPreq.ExpirationDate = log.Expiration_Date__c.formatGMT('yyyy-MM-dd HH:mm:ss'); 
                    SIPreq.BundleType = 0;
                    SIPreq.LicenseTypeGUID=selectedLic.LicenseTypeGUID__c; 
                    SIPilc.InvalidatedLicenseIdentifiers = SIPilist;
                    SIPreq.InvalidatedLicenseIdentifierCollection = SIPilc ;
                }
              
            }else{
                system.debug('deployment in generatepayload:'+deployment.Usage_Tracking__c);
                subscriptionReq.AccountName = selectedAccount.Name;
                subscriptionReq.CompanyIdentifier = deployment.Id;
                subscriptionReq.GenesysIdentifier = selectedAccount.SAP_Account_Code__c;
              if(deployment.usage_tracking__c<>NULL && deployment.usage_tracking__c.equalsIgnoreCase('Automated')){
                  subscriptionReq.S3UserName = decrypt(selectedAccount.AWS_Access_key__c);
                  subscriptionReq.S3UserPassword= decrypt(selectedAccount.AWS_Secret_key__c);
                }
                else{
                 subscriptionReq.S3UserName = 'Not Used';
                 subscriptionReq.S3UserPassword= 'Not Used'; 
                }
                subscriptionReq.ProductName = products.get(selectedProdLine).Name;
                subscriptionReq.ProductVersion = '4.0';
                subscriptionReq.Description = selectedLic.Description__c;
                subscriptionReq.GenerationDate = system.now().formatGMT('yyyy-MM-dd HH:mm:ss');
                subscriptionReq.ExpirationDate = log.Expiration_Date__c.formatGMT('yyyy-MM-dd HH:mm:ss'); 
                subscriptionReq.BundleType= Integer.valueOf(selectedLic.Leagcy_Id__c);        
                silc.InvalidatedLicenseIdentifiers = silist;
                subscriptionReq.InvalidatedLicenseIdentifierCollection = silc ;
                subscriptionReq.Licenses = subscriptionLicenseLst;
                subscriptionReq.Features = subscriptionFeatLst;
                subscriptionReq.BundleName = products.get(selectedProdLine).Name + ' '+ ' Subscription';    
                if(!show){
                    List<String> macIds = splitMultiple(Log.MAC_Address__c);
                    List<String> macNames = splitMultiple(Log.Machine_Name__c);
                    subscriptionReq.Servers = new List<SubscriptionRequestWrapper.Servers>{new SubscriptionRequestWrapper.Servers(macIds[0],macNames[0]),new SubscriptionRequestWrapper.Servers(macIds[1],macNames[1])};
                }
                else{
                    subscriptionReq.Servers = new List<SubscriptionRequestWrapper.Servers>{new SubscriptionRequestWrapper.Servers(log.MAC_Address__c,log.Machine_Name__c)};
                }
                addDisplayInfo();
              //  subscriptionReq.DisplayInfo=;
            }    
        
    }
     
      @TestVisible void addDisplayInfo(){
      Set<String> featureSet = new Set<String>();

        List<SubscriptionRequestWrapper.Parts> partsList = new List<SubscriptionRequestWrapper.Parts>();
          for(License_Usage__c lw: LicenseUsageList){ 
             if(partTranslations.containsKey(lw.itemnumber__c)){
                 Set<License_Translations__c> temp = partTranslations.get(lw.itemnumber__c);     
                 List<SubscriptionRequestWrapper.Licenses> templicenseLst = new List<SubscriptionRequestWrapper.Licenses>(); 
                 List<SubscriptionRequestWrapper.Features> tempfeatLst = new List<SubscriptionRequestWrapper.Features>();
                 for(License_Translations__c lt: temp){
                    if(!lt.License_Key__r.category__c.equalsIgnoreCase('Feature')){
                        SubscriptionRequestWrapper.Licenses lic = new SubscriptionRequestWrapper.Licenses();
                        lic.Name = lt.License_Key__r.Key_Name__c;             
                        lic.Assigned = Integer.ValueOf((lt.Assigned_Multiplier__c*lw.Quantity_Used__c)) +'';
                        lic.Pooled = Integer.ValueOf((lt.Multiplier__c*lw.Quantity_Used__c))+'';
                        templicenseLst.add(lic);
                    }
                    else 
                        featureSet.add(lt.License_Key__r.Key_Name__c);
                }
                
                featureSet.add(SULicensingFeatureKey);    
                for(String featKey : featureSet){
                    SubscriptionRequestWrapper.Features feat = new SubscriptionRequestWrapper.Features(featKey);
                    tempfeatLst.add(feat);
                }    
                
                SubscriptionRequestWrapper.Parts part = new SubscriptionRequestWrapper.Parts(lw.itemnumber__c,partMaster.get(lw.itemnumber__c).Name,String.ValueOf(lw.quantity_used__c),tempfeatLst,templicenseLst);
                partsList.add(part);
             }       
          }
          SubscriptionReq.DisplayInfo = new List<SubscriptionRequestWrapper.DisplayInfo>{new SubscriptionRequestWrapper.DisplayInfo(selectedLic.Description__c, u.contact.Name, partsList)};
      }  

      @TestVisible void processKeys(){
      Set<String> featureSet = new Set<String>();
      featLst = new List<LMS_LicenseGenerationRequestWrapper.Features>();
      licenseLst = new List<LMS_LicenseGenerationRequestWrapper.Licenses>();   
      
      Integer multiplier = 0; // this will be based on ordered qty of application session part
        for(License_Usage__c lw: LicenseUsageList){ 
              if(partTranslations.containsKey(lw.itemnumber__c)){
                 Set<License_Translations__c> temp = partTranslations.get(lw.itemnumber__c);     
                 for(License_Translations__c lt: temp){
                    if(!lt.License_Key__r.category__c.equalsIgnoreCase('Feature')){
                            LMS_LicenseGenerationRequestWrapper.Licenses lic = new LMS_LicenseGenerationRequestWrapper.Licenses();   
                            lic.Name = lt.License_Key__r.Key_Name__c;  
                           
                             lic.Assigned = (Integer.ValueOf(lt.Assigned_Multiplier__c) * lw.Quantity_Used__c) +'';
                             lic.Pooled = (Integer.ValueOf(lt.Multiplier__c) * lw.Quantity_Used__c) +'';
                             licenseLst.add(lic);
                            system.debug('lt.Multiplier__c'+lt.Multiplier__c+'lt.Assigned_Multiplier__c'+lt.Assigned_Multiplier__c+'lw.itemnumber:'+lt.id+lw.itemnumber__c+' key:'+lt.License_Key__r.Key_Name__c+' assigned:'+lic.assigned+' pooled:'+lic.pooled+' Quantity_Used__c:'+lw.Quantity_Used__c);
                     
                              if(isSip){
                                Integer assignedVal = (Integer.ValueOf(lt.Assigned_Multiplier__c) * Integer.ValueOf(lw.Quantity_Used__c));
                                Integer pooledVal = (Integer.ValueOf(lt.Multiplier__c) * Integer.ValueOf(lw.Quantity_Used__c));
                                Integer qty = assignedVal + pooledVal;
                                  if(SIPlicense.containsKey(lt.License_Key__r.Key_Name__c)){
                                    qty = qty + Integer.valueOf(SIPlicense.get(lt.License_Key__r.Key_Name__c));    
                                    SIPlicense.put(lt.License_Key__r.Key_Name__c,String.valueOf(qty));  
                                  }
                                  else{                                      
                                    SIPlicense.put(lt.License_Key__r.Key_Name__c,String.valueOf(qty));
                                    system.debug('inside SIP license:'+ qty);
                                  }    
                             }     
                    }
                    else{
                        if(isSIP)
                            SIPFeatures.add(lt.License_Key__r.Key_Name__c);
                        featureSet.add(lt.License_Key__r.Key_Name__c);
                        }
                 }
             }
            
            if(newApi)
                if(concurrentTrackingKeys.containsKey(deployment.Usage_Tracking__c))
                   featureSet.add(concurrentTrackingKeys.get(deployment.usage_tracking__c));
       }      
        
        sumAllLicenses();
        if(selectedProdLine.equalsIgnoreCase('CIC 4.0'))
            featureSet.add(SULicensingFeatureKey);
        if(selectedProdLine.equalsIgnoreCase('Interaction Media Server 4.0'))
            featureSet.addAll(mediaServerKeys);
        for(String featKey : featureSet){
            LMS_LicenseGenerationRequestWrapper.Features feat = new LMS_LicenseGenerationRequestWrapper.Features();
            feat.Name = featKey;
            featLst.add(feat);

            SubscriptionRequestWrapper.Features subfeat = new SubscriptionRequestWrapper.Features(featKey);
            subscriptionFeatLst.add(subfeat);
        }
     }
     
      @TestVisible void sumAllLicenses(){
        Map<String,LicenseAssignedPooled> licenseKeys = new Map<String,LicenseAssignedPooled>();
        Map<String,LMS_LicenseGenerationRequestWrapper.Licenses> licenselsts= new Map<String,LMS_LicenseGenerationRequestWrapper.Licenses>();
        Map<String,SubscriptionRequestWrapper.Licenses> sublicenselsts= new Map<String,SubscriptionRequestWrapper.Licenses>();
        
        if(!isSip){
        for(LMS_LicenseGenerationRequestWrapper.Licenses license: licenseLst){
        system.debug('inside sumAllLicense:'+license+newAPI);
            if(!newAPI){
                system.debug('inside CIC 4 API');
                if(licensekeys.containsKey(license.name)){
                     system.debug('inside licenseKeys containsKey: '+license.name+' license.assigned: '+license.assigned+' license.pooled:'+license.pooled);                   
                    Integer assigned = Integer.ValueOf(license.assigned) + licenseKeys.get(license.name).assigned;
                    Integer pooled = Integer.ValueOf(license.pooled) + licenseKeys.get(license.name).pooled;
                    licenseKeys.get(license.name).assigned = assigned;
                    licenseKeys.get(license.name).pooled = pooled;
                    license.assigned = assigned+'';
                    license.pooled = pooled+'';
                    
                    LMS_LicenseGenerationRequestWrapper.Licenses temp = new LMS_LicenseGenerationRequestWrapper.Licenses();
                    temp.Name=license.name;
                    temp.Assigned = assigned+'';
                    temp.Pooled = pooled+'';
                    if((assigned + pooled) > 0)
                        licenselsts.put(license.name,temp);
                    system.debug('thiyag after adding keySum:'+license.name+ license.assigned+':'+license.pooled);
                }
                else{
                    system.debug('inside first time');
                    licenseKeys.put(license.name,new LicenseAssignedPooled(license.name,Integer.valueOf(license.assigned),Integer.valueOf(license.pooled)));
                    LMS_LicenseGenerationRequestWrapper.Licenses temp = new LMS_LicenseGenerationRequestWrapper.Licenses();
                    temp.Name=license.name;
                    temp.assigned = license.assigned;
                    temp.pooled = license.pooled;
                    if((Integer.valueOf(license.assigned)+Integer.valueOf(license.pooled)) > 0)
                        licenselsts.put(license.name,temp);
                }
            }
            else{
                system.debug('inside New api');
                 if(licensekeys.containsKey(license.name)){
                    system.debug('inside licenseKeys containsKey: '+license.name+' license.assigned: '+license.assigned+' license.pooled:'+license.pooled);                   
                    Integer assigned = Integer.ValueOf(license.assigned) + licenseKeys.get(license.name).assigned;
                    Integer pooled = Integer.ValueOf(license.pooled) + licenseKeys.get(license.name).pooled;
                    system.debug('after adding with licenseKeys.assigned: '+licenseKeys.get(license.name).assigned+' value is:'+assigned);
                    system.debug('after adding with licenseKeys.pooled: '+licenseKeys.get(license.name).pooled+' value is: '+pooled);
                    licenseKeys.get(license.name).assigned = assigned;
                    licenseKeys.get(license.name).pooled = pooled;
                   
                    
                    SubscriptionRequestWrapper.Licenses temp = new SubscriptionRequestWrapper.Licenses();
                    temp.Name=license.name;
                    temp.assigned = assigned+'';
                    temp.pooled = pooled+'';        
                    if((assigned + pooled) > 0)       
                      sublicenselsts.put(license.name,temp);
                    
                }
                else{
                    system.debug('inside first time');
                    licenseKeys.put(license.name,new LicenseAssignedPooled(license.name,Integer.valueOf(license.assigned),Integer.valueOf(license.pooled)));
                    SubscriptionRequestWrapper.Licenses temp = new SubscriptionRequestWrapper.Licenses();
                    temp.Name=license.name;
                    temp.assigned = license.assigned;
                    temp.pooled = license.pooled;       
                    if((Integer.valueOf(license.assigned)+Integer.valueOf(license.pooled)) > 0)           
                      sublicenselsts.put(license.name,temp);
                }
            }
          }  
       }
        
        if(licenselsts.size()>0) licenselst = licenselsts.values();
        if(sublicenselsts.size()>0) subscriptionLicenseLst = sublicenselsts.values();
    }
   
   public void resetPaginationKey(){
      paginationKey = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
   }
    
  public void createDeployment(){ 

       System.debug('Mac name'+log.Machine_Name__c);
      o = new Order__c();
      try{

            deployment = new cloud_deployment__c();

                o = [Select Id, Original_Parent_Order1__c from Order__c where Id =:Orderopt.order__c];
                SYstem.debug('Order Id'+o.Id);
          List<Subscription__c> lstsubs=[SELECT Id, cloud_deployment__c FROM Subscription__c where Order__c=:Orderopt.order__c and Status__c='Active' limit 1];
          if(lstsubs.size()>0 )
          {
              if(lstsubs[0].cloud_deployment__c!=null){
           
                          log.Cloud_Deployment__c  = lstsubs[0].cloud_deployment__c;  }    
              
          }
          
          
          
              /*    if(o.Original_Parent_Order1__c<>NULL){
                      lstquote = [Select Id,order__c,Usage_Data_Submission_Method__c from BigMachines__Quote__c where order__c =: o.Original_Parent_Order1__c LIMIT 1];               
                      List<Cloud_Deployment__c> cltemps = new List<Cloud_Deployment__c>();
                      cltemps = [select Id,name,account__c,quote__c,order__c,usage_tracking__c from Cloud_Deployment__c where order__c = : o.Original_Parent_Order1__c limit 1];
                      if(cltemps.size()>0)
                        deployment = cltemps[0];                    
                  }
                  else{
                      lstquote = [Select Id,order__c,Usage_Data_Submission_Method__c from BigMachines__Quote__c where order__c =: o.id LIMIT 1];             
                      List<Cloud_Deployment__c> cltemps = new List<Cloud_Deployment__c>();
                      cltemps = [select Id,name,account__c,quote__c,order__c,usage_tracking__c from Cloud_Deployment__c where order__c = : o.id limit 1];
                      if(cltemps.size()>0)
                        deployment = cltemps[0];
                 // }

                  if(lstquote.isempty()){

                      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The Selected Order does not have valid quote associated with it ')); 
                      return;
                  } */             
               
             /* Commenting cloud deployment record creation as it is automated now
                 if(deployment.id == NULL || deployment == NULL){
                  deployment.order__c = log.subscription_order__c; 
                  deployment.quote__c = lstquote[0].id;  
                  deployment.Name = selectedAccount.Name;
                  deployment.Account__c = selectedAccount.Id;
                  deployment.Cloud_Platform__c = 'PureConnect Subscription';   
                  deployment.Support_Status__c = 'Billing Only'; 
                
                  Database.SaveResult sr = Database.insert(deployment);
              
                  if(sr.isSuccess()){
                      System.debug('Deployment Id'+sr.getId());
                        deployment.id = sr.getId();
                  }
                }

*/
                   
                          
          
          
                     System.debug('Inside Catch'+log.Cloud_Deployment__c );
      
        system.debug('before calling genereateKey:'+log.cloud_deployment__c);        
      }catch(Exception e){
          System.debug('Inside Catch'+e.getMessage() ); 
         
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage())); 
      }
    /*  finally {
          if(deployment.id <> NULL)
          log.Cloud_Deployment__c = deployment.id;  

          System.debug('Inside Catch'+log.Cloud_Deployment__c ); 
      }*/
   }

    public void calloutLicenseService(){
     //   orderedItemsUsed = new Set<String>();
      String jsonStr, LMSLicenseGenerator_Key;
      try{
         if(log.Cloud_Deployment__c!=NULL){
            if(newAPI)
                generateKey(log.Cloud_Deployment__c,selectedAccount.SAP_Account_Code__c,'object');
            jsonStr = populateLicense();
         }else
            throw new DeploymentException();

        if(!String.isBlank(jsonStr)){ 
            system.debug('jsonStr:'+jsonStr);
            http h = new http();
            version = products.get(selectedProdLine).ProductLine_Version__c;
            httpRequest reqst = new httpRequest();
             
            if(!newAPI){
                if(products.get(selectedProdLine).SIP_Product__c){
                        String sipType = products.get(selectedProdLine).SIPType__c;
                        
                        if(sipType.equalsIgnoreCase('Media Server'))
                            LMSLicenseGenerator_Key = 'MS'+version;
                        else
                            LMSLicenseGenerator_Key = 'SIP'+version;
                }else
                        LMSLicenseGenerator_Key = version;
                
                    if(LMS_License_Generator__c.getValues(LMSLicenseGenerator_Key) != NULL){
                       String LMSLicenseGeneratorAPIString = LMS_License_Generator__c.getValues(LMSLicenseGenerator_Key).api__c;  
                       reqst.setEndpoint('callout:LMS_LicenseGeneration_Services'+LMSLicenseGeneratorAPIString);
                    }    
            }else
                    reqst.setEndPoint('callout:SubscriptionAPI');    
                
                          
                reqst.setMethod('POST');
                reqst.setHeader('Content-Type', 'application/json');
                reqst.setHeader('Content-Length',''+jsonStr.length());
                reqst.setTimeout(120000);
                reqst.setBody(jsonStr);
                try{
                    httpResponse res = new httpResponse();
                    res = h.send(reqst);
                  
                    if(res.getStatusCode() == 200|| res.getStatusCode() == 201){
                        IF(createLog(res.getBody()))
                                pageBlock = 'page4';
                    }                
                    else
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Unsuccessful Callout: '+res.getStatusCode()+' : '+res.getBody())); 
                }catch(System.CalloutException e){
                    system.debug(e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Service Dropped and the error occured: '+e.getMessage()));
                }
        }else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Request doesnt have body!'));   

       }
        catch(DeploymentException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Issue creating deployment <br/> 1. Check if the selected Order has subscription with Cloud deployment <br/> 2.Check the AWS services are up and running.')); 
        }      
    }    
    
    
    public Boolean createLog(String response){
        log.End_User__c = selectedAccount.Id; 
        log.Sold_to__c = selectedAccount.Id;
        if(!newAPI){
            if(!isSIP){
                log.Expiration_Date__c = parseDate(req.ExpirationDate);
                log.Generation_Date__c = parseDate(req.GenerationDate);
            }
            else{
                log.Expiration_Date__c = parseDate(SIPreq.ExpirationDate);
                log.Generation_Date__c = parseDate(SIPreq.GenerationDate);
            
            }    
        }
        else{
            log.Expiration_Date__c = parseDate(SubscriptionReq.ExpirationDate);
            log.Generation_Date__c = parseDate(SubscriptionReq.GenerationDate);
        }    
        log.License_Type__c = selectedLic.Id;
        log.Product_Line__c = products.get(selectedProdLine).Id;
        log.Requested_By__c = userinfo.getuserId();
        //log.Install_Site__c = selectedInstallSite;
        log.IsActive__c = TRUE;
        log.License_Text__c = cleanseXMLString(response);
        try{
            insert log;
            log = [select IsActive__c,System_Type__c,mail_connector__c,MAC_Address__c ,Machine_Name__c, License_Text__c,End_User__c,End_User__r.Name,Sold_to__c,Expiration_Date__c,Generation_Date__c,License_Type__c,Product_Line__c,Product_Line__r.ProductLineName__c,Product_Line__r.name, Requested_By__c, Requested_By__r.Name from subscription_request_log__c where id =: log.id];
            for(License_Usage__c lu: LicenseUsageList) {
      //          orderedItemsUsed.add(lu.ItemNumber__c + '  ' + populatedPartProducts.get(lu.ItemNumber__c).Description + ' ( ' + lu.Quantity_Used__c.intValue() + ' )');
                lu.subscription_request_log__c = log.id;
            }    
            insert LicenseUsageList;  // inserts all the License&Addon partnumbers except server parts with qty ordered and RequestLogId    
            return true;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Creating request log failed: '+e.getMessage())); 
            return false;
        }
    }
    
     public String cleanseXMLString(String xmlString){ 
        system.debug('xmlString:'+xmlString);
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

           // if(!newAPI) {   
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
               
                
               // Dom.XMLNode licensefileNode = licenseFiles.getChildElement('LicenseFile', null);
                licensefileNode.addChildElement('DESC',null,null).addTextNode(selectedLic.description__c);
                licensefileNode.addChildElement('USER',null,null).addTextNode(selectedAccount.Name);
                
                    Dom.XMLNode items = licensefileNode.addChildElement('ITEMS',null,null);
                       
                       for(License_Usage__c lw: LicenseUsageList){    
                            Dom.XMLNode item = items.addChildElement('ITEM',null,null);
                            item.setAttribute('id',lw.itemnumber__c);
                            item.setAttribute('name',populatedPartProducts.get(lw.itemnumber__c).Name);
                            item.setAttribute('quantity',String.valueOf(lw.Quantity_Used__c));
                            
                            Dom.XMLNode products = item.addChildElement('PRODUCTS',null,null);
                            if(partTranslations.containsKey(lw.itemnumber__c)){
                                Set<License_Translations__c> temp = partTranslations.get(lw.itemnumber__c);
                                for(License_Translations__c lt: temp){
                                    Dom.XMLNode product = products.addChildElement('PRODUCT',null,null);
                                                                             
                                        if(!lt.License_Key__r.category__c.equalsIgnoreCase('Feature')){
                                            product.setAttribute('name',lt.License_Key__r.Key_Name__c);
                                            if(lt.Show_Assigned_Multiplier__c) {
                                                product.setAttribute('assigned',Integer.valueOf(lt.Assigned_Multiplier__c)+'');
                                                product.setAttribute('pooled',Integer.valueOf(lt.Multiplier__c)+'');
                                             }   
                                                    product.setAttribute('quantity',String.valueOf((Integer.valueOf(lt.Assigned_Multiplier__c) + Integer.valueOf(lt.Multiplier__c))*Integer.ValueOf(lw.Quantity_Used__c)));
                                        }
                                        else{
                                             product.setAttribute('name',lt.License_Key__r.Key_Name__c);

                                        }
                                }
                           }
                           else{
                               Dom.XMLNode product = products.addChildElement('PRODUCT',null,null);
                           } 
                    } 
              
              xmlstring = doc.toXmlString();
            return xmlString;     
        }
    
    public DateTime parseDate(String dtStr){ system.debug('inside parseDate:'+dtStr);
        DateTime dt;
        if(!String.ISBLANK(dtStr)){
            String[] str = dtStr.split(' ');
            String[] newdates = str[0].split('-');
            String[] newTimes = str[1].split(':');
            dt = DateTime.newInstance(Integer.valueOf(newdates[0]),Integer.valueOf(newdates[1]),Integer.valueOf(newdates[2]),Integer.valueOf(newTimes[0]), Integer.valueOf(newTimes[1]),Integer.valueOf(newTimes[2]));
        }
        return dt;
    }
    
    
    
    public Class LicenseAssignedPooled{
       public String name;
       public Integer assigned;
       public Integer pooled;
        public LicenseAssignedPooled(){}
        public LicenseAssignedPooled(String name,Integer assigned,Integer pooled){
            this.name = name;
            this.assigned = assigned;
            this.pooled=pooled;
        }

       public String getMultipliersString(){
          return ' ( '+assigned+' assigned, '+pooled+' pooled) '; 
        }
   }  
  public class DeploymentException extends Exception {}

}