Public Class LMS_Utility{
    public Static String noKeyStr = 'This item is legally licensed however no license string appears to \'key\' the item in the product.';
    public Static Set<String> SULicensingFeatureProductLines = new Set<String>{'CIC 3.0','Interaction Monitor 1.0','CIC 4.0','CIC IVR 3.0','CIC IVR 4.0','MIC 4.0'};
    public Static String SULicensingFeatureKey = 'I3_FEATURE_SU_ALLOWED';
    public LMS_Utility(){
    
    }

    public Static Map<Id,LMS_Certification__c> certificationMap = new Map<Id,LMS_Certification__c>([Select Id,Name from LMS_Certification__c]);
    
    public Static List<LMS_ProductLine__c> fetchEligibleProducts(Id contactId) {
       List<LMS_ProductLine__c> eligibleProducts = new List<LMS_ProductLine__c>(); 
       Set<String> userCertificates = getUserCertificates(contactId);    
 
       Map<Id,LMS_ProductLine__c> productLineMap = getProductLines(); //fetches active productlines         
       Map<String,List<String>> ProductRequirementsMap = getProductCertificateRequirements(productLineMap.keySet());
       Boolean isEligible;
           for(LMS_ProductLine__c prodLine : ProductLineMap.values()) 
               if(ProductRequirementsMap.containsKey(prodLine.Name)){ 
                   isEligible = FALSE;
                       for(String CertificateIds : ProductRequirementsMap.get(prodLine.Name)) 
                          if(!isEligible){
                                if(!certificateIds.contains('&#124;'))
                                      List<String> certificates = new List<String>{certificateIds};
                                      
                                      List<String> certificates = certificateIds.split('&#124;');
                                      Integer certSize = certificates.size();
                                      Integer i;

                                      for(i=0;i<certSize;i++) {
                                           if(!userCertificates.contains(certificates[i])){
                                              isEligible = FALSE; 
                                              break;
                                           }
                                           else
                                              isEligible = TRUE;
                                   }           
                         }        
                        if(isEligible)
                           eligibleProducts.add(prodLine);   
                             
             }
           for(LMS_Product_Eligibility__c e: [SELECT Id,Certificates__c,ProductLine__c,ProductLine__r.Name from LMS_Product_Eligibility__c where ProductLine__c =: productLineMap.keySet() AND Exclude_Certification__c=TRUE])    
             eligibleProducts.add(productLineMap.get(e.productLine__c));
            
         return eligibleProducts;
        }
         
    public Static Set<String> getUserCertificates(Id contactId) {
        Set<String> temp = new Set<String>();
        List<Partner_Certifications__c> certificates = [SELECT id, Account__c,Contact__c, Certification__c, Offering_Type__c  from Partner_Certifications__c where Offering_Type__c='pureconnect' and Contact__c=:contactId and Status__c = 'Completed'];
        for(Partner_Certifications__c certificate : certificates)
            temp.add(certificate.Certification__c);
        return temp;    
    }
    
    public Static  Map <Id,LMS_ProductLine__c> getProductLines(){
       return new Map <Id,LMS_ProductLine__c>([Select id,Name,ShowMailConnector__c,ShowSystemType__c,SIP_Product__c,SIPType__c,ProductLineName__c,ProductLine_Version__c from LMS_ProductLine__c where isActive__c= TRUE order by ProductLine_Version__c]) ; 
    }
    
    public Static  Map<String,List<String>> getProductCertificateRequirements(Set<ID> prodLineIds){       //fetches ProductLineName and its list of requirements
        Map<String,List<String>> ProductRequirementsMap = new Map<String,List<String>>();
        List<LMS_Product_Eligibility__c> prodEligibility = [SELECT Id,Certificates__c,ProductLine__c,ProductLine__r.Name from LMS_Product_Eligibility__c where ProductLine__c =: prodLineIds];
        system.debug('eligibilities:'+prodEligibility.size());
            for(LMS_Product_Eligibility__c rec : prodEligibility){
                if(ProductRequirementsMap.containsKey(rec.ProductLine__r.Name)){system.debug('inside reqmap.containskey: '+rec.productLine__r.name);
                    List<String> temp =  ProductRequirementsMap.get(rec.ProductLine__r.Name);
                    temp.add(rec.certificates__c);
                }
                else
                    if(rec.certificates__c<>NULL){
                        ProductRequirementsMap.put(rec.ProductLine__r.Name,new List<String>{rec.certificates__c});
                    }
           } system.debug('last ProductRequirementsMap:'+ProductRequirementsMap.containsKey('e-FAQ 2.3.1'));
        return ProductRequirementsMap;   
    }
    
        public Static Set<String> getProductCategoryNames(String productType){
         List<LMS_CategoryTranslation__c> categories = [Select Short_Name__c from LMS_CategoryTranslation__c where Product_Name__r.Name=:productType];
        Set<String> categorySet = new Set<String>();
        for(LMS_CategoryTranslation__c category:categories)
            categorySet.add(category.short_name__c);
        return categorySet;    
    }
    
    public Static Set<String> getProductCategoryCodes(String productType){
        List<LMS_CategoryTranslation__c> categories = [Select Short_Name__c,Categrory_Id__c from LMS_CategoryTranslation__c where Product_Name__r.Name=:productType];
        Set<String> categorySet = new Set<String>();
        for(LMS_CategoryTranslation__c category:categories)
            categorySet.add(category.Categrory_Id__c);
        return categorySet;    
    }
   
    public Static List<License_Snapshot__c> getLicenseSnapshotData(String endUserAccountId, String soldToAccountId, String productType, String version){
        List<License_Snapshot__c> snapshotData = new List<License_Snapshot__c>();
        String productLine = productType+' '+version;
        List<LMS_CategoryTranslation__c> categories = [Select Short_Name__c from LMS_CategoryTranslation__c where Product_Name__r.Name=:productType];
        Set<String> categorySet = new Set<String>();
        for(LMS_CategoryTranslation__c category:categories)
            categorySet.add(category.short_name__c);
        if(categorySet.size()>0)    
       
        snapshotData = [SELECT id, Part_Number__c, Product__c, Product_Category_Version__c, Description__c, Perpetual__c, Non_Perpetual__c, Total__c, Change_Date__c, Sold_To__c, Sold_To__r.Name,
                            (SELECT id, Change_Date__c, Change_Type__c, Perpetual__c, Non_Perpetual__c FROM License_Snapshot_Changes__r)
                            FROM License_Snapshot__c 
                            WHERE End_User__c = :endUserAccountId AND IsActive__c = true AND ProductCategory__c IN :categorySet AND ProductVersion__c =: version AND Sold_To__c=: soldToAccountId ORDER BY Part_Number__c];
       /* if(isTemp)
            snapshotData.addAll(getTempSnapshotData(soldToAccountId,endUserAccountId, version)); */
        return snapshotData; 
    }
    
   /* public Static List<License_Snapshot__c> getTempSnapshotData(String soldToAccountId, String endUserAccountId, String version){
        return LicenseSnapshotUtil.generateTempSnapshotRecords(soldToAccountId, endUserAccountId, version);    
    }*/  
       
    public Static List<SelectOption> getInstallSites(String endUserAccountId){
        List<SelectOption> installSites = new List<SelectOption>();
        installSites.add(new SelectOption('All Install Sites', 'All Install Sites'));
        for (LMS_Install_Site__c iSite : [SELECT Id, Name FROM LMS_Install_Site__c WHERE Account__c = :endUserAccountId AND Active__c = true ORDER BY Name]){
            installSites.add(new SelectOption(iSite.Id, iSite.Name));
        }
        return installSites;
    }
    
    public Static Map<String,String> fetchKeys(String selectedProdLine){
        List<LMS_License_Keys__c> keyList = [SELECT Id,Category__c,Description__c,Key_Name__c FROM LMS_License_Keys__c];
        Map<String,String> plKeys = new Map<String,String>();
        for(LMS_License_Keys__c pl:keyList){
            plKeys.put(pl.Key_Name__c,pl.Category__c);   
        }
        if(SULicensingFeatureProductLines.contains(selectedProdLine))
                plKeys.put(SULicensingFeatureKey,SULicensingFeatureKey);  
                
        return plKeys;
    }
    
    public Static Map<String,Set<License_Translations__c>> getPremiseTranslations(Set<String> parts, Boolean isSIP){
         Map<String,Set<License_Translations__c>> partTranslations = new Map<String,Set<License_Translations__c>>();
         for(License_Translations__c lt : [SELECT Id, Item_Number__c,License_Key__r.category__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE SIP_Product__c=:isSIP and Item_Number__c IN :parts]){
                if(partTranslations.containsKey(lt.item_number__c)) {
                  partTranslations.get(lt.Item_number__c).add(lt);  
                }   
                else{
                  Set<License_Translations__c> tset = new Set<License_translations__c>();
                  tset.add(lt); 
                  partTranslations.put(lt.item_number__c,tset);
                }
         }
         return partTranslations;
         //test
    }
    
    public Static Boolean isSIPOverride(String part){
        Set<String> SIPOverrideParts = new Set<String>();
        Boolean isOverride = False;
        for(License_Translations__c lt : [SELECT Id, Item_Number__c, Proxy_Override__c FROM License_Translations__c WHERE Item_Number__c =:part])
            if(lt.Proxy_Override__c)
               isOverride = True;
        return isOverride;        
    }
    
    public Static Map<String, List<String>> getPartKeyString(Set<String> parts, Boolean isSIP){
         Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();
         for(License_Translations__c lt : [SELECT Id, Item_Number__c,License_Key__r.category__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE SIP_Product__c=:isSIP and Item_Number__c IN :parts]){
                String multipliersString = lt.Show_Assigned_Multiplier__c == true ? lt.Assigned_Multiplier__c.intValue() + ' assigned' + ', ' : '';
                multipliersString = multipliersString + lt.Multiplier__c.intValue() + ' pooled';
                multipliersString = ' (' + multipliersString + ') ';
                
                if(partNumberKeys.containsKey(lt.Item_Number__c))
                    partNumberKeys.get(lt.Item_Number__c).add(lt.License_Key__r.Key_Name__c + multipliersString);   
                else 
                    partNumberKeys.put(lt.Item_Number__c, new List<String>{lt.License_Key__r.Key_Name__c + multipliersString}) ;    
         }
         return partNumberKeys;
   }
   
   public Static List<License_Usage__c> populateSummary(String endUserAccountId, String summaryType, List<LicenseSummaryWrapper> summaryData){
        List<License_Usage__c> LicenseUsageList = new List<License_Usage__c>();
          for(LicenseSummaryWrapper lw: summaryData){ 
            if(summaryType.equalsIgnoreCase('Server'))           
                LicenseUsageList.add(new License_Usage__c(itemnumber__c=lw.partnumber,account__c=endUserAccountId,Product__c=lw.ProductId,Quantity_Used__c=1)); 
            else
                LicenseUsageList.add(new License_Usage__c(itemnumber__c=lw.partnumber,account__c=endUserAccountId,Product__c=lw.ProductId,Quantity_Used__c=lw.orderedQty));     
            }   
        return LicenseUsageList;
   } 
    
   public Static List<License_Usage__c> populateSubscriptionSummary(String endUserAccountId,String summaryType,String selectedServer, List<LicenseSummaryWrapper> summaryData,Map<String,String> serverProdMappings,Map<String,Product2>subscriptionPerpetualMap){
      List<License_Usage__c> LicenseUsageList = new List<License_Usage__c>();
           for(LicenseSummaryWrapper lw: summaryData){
            if(summaryType.equalsIgnoreCase('Server'))  {                     
                if(lw.partnumber.equalsIgnoreCase(selectedServer)){                   
                LicenseUsageList.add(new License_Usage__c(itemnumber__c=lw.partnumber,account__c=endUserAccountId,Product__c=serverProdMappings.get(lw.partnumber),Quantity_Used__c=lw.orderedQty)); 
                }
            }else{
                if(lw.orderedQty>0){    // picks all addon items where ordered qty is entered
                LicenseUsageList.add(new License_Usage__c(itemnumber__c=lw.partnumber,account__c=endUserAccountId,Product__c=subscriptionPerpetualMap.get(lw.partnumber).id,Quantity_Used__c=lw.orderedQty));  
                }    
            }    
             
          }
       return LicenseUsageList;
   }
   
   public static List<LMS_LicenseGenerationRequestWrapper.Licenses> sumAllLicenses(List<LMS_LicenseGenerationRequestWrapper.Licenses> licenseLst){      
       Map<String,LicenseAssignedPooled> licenseKeys = new Map<String,LicenseAssignedPooled>();
       Map<String,LMS_LicenseGenerationRequestWrapper.Licenses> licenselsts= new Map<String,LMS_LicenseGenerationRequestWrapper.Licenses>();
       Map<String,SubscriptionRequestWrapper.Licenses> sublicenselsts= new Map<String,SubscriptionRequestWrapper.Licenses>();
       
       for(LMS_LicenseGenerationRequestWrapper.Licenses license: licenseLst){
           if(licensekeys.containsKey(license.name)){
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
           }
           else{
               licenseKeys.put(license.name,new LicenseAssignedPooled(license.name,Integer.valueOf(license.assigned),Integer.valueOf(license.pooled)));
               LMS_LicenseGenerationRequestWrapper.Licenses temp = new LMS_LicenseGenerationRequestWrapper.Licenses();
               temp.Name=license.name;
               temp.assigned = license.assigned;
               temp.pooled = license.pooled;
               if((Integer.valueOf(license.assigned)+Integer.valueOf(license.pooled)) > 0)
                   licenselsts.put(license.name,temp);
           }
       }
       licenselst = licenselsts.values(); 
       return licenseLst;
   }
   
   public Static Map<String,String> processEncryption(String value){ 
        Map<String,String> encryptKey = new Map<String,String>();
        Blob cryptoKey = Crypto.generateAesKey(128); 
        Blob data = Blob.valueOf(value); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data); 
        String b64Data = EncodingUtil.base64Encode(encryptedData);  
        encryptKey.put(EncodingUtil.base64Encode(cryptoKey),b64Data); 
        return encryptKey; 
    } 

    public Static String processDecryption(String key, String encryptedData){ 
        String decryptedData,expMsg; 
        Blob data = EncodingUtil.base64Decode(encryptedData); 
        Blob privateKey = EncodingUtil.base64Decode(key);  
        try{ 
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data); 
            decryptedData = dataToDecrypt.toString(); 
        } 
        catch(Exception e){ 
           expMsg = e.getMessage();  
        } 
        return (string.isEmpty(expMsg) ?  decryptedData :  null);  
    }
    
    public Static Map<String,Set<License_Translations__c>> getPartTranslations(SelectionWrapper inputs){
        Set<String> parts = LMS_Utility.getParts(inputs.LicenseUsageList);
        Map<String,Set<License_Translations__c>> partTranslations;
        system.debug('inside getPartTranlations requestType:'+inputs.requestType);
        if(inputs.requestType.equalsIgnoreCase('Regular') || inputs.requestType.equalsIgnoreCase('Dummy') || inputs.requestType.equalsIgnoreCase('Temporary'))
            partTranslations = LMS_Utility.getPremiseTranslations(parts, inputs.selectedProduct.SIP_Product__c);
        if(inputs.requestType.equalsIgnoreCase('Subscription'))
            partTranslations = LMSHybridLicenseController.getSubscriptionTranslations(inputs.selectedProduct.ProductLineName__c,parts);
        if(inputs.requestType.equalsIgnoreCase('Hybrid')) {
            partTranslations = LMS_Utility.getPremiseTranslations(parts, inputs.selectedProduct.SIP_Product__c);  
            partTranslations.putAll(LMSHybridLicenseController.getSubscriptionTranslations(inputs.selectedProduct.ProductLineName__c,parts));
        }
       return partTranslations; 
    }
    
    public Static Dom.XMLNode addItemstoXML(Dom.XMLNode licensefileNode, SelectionWrapper inputs){
      Map<String,Set<License_Translations__c>> partTranslations = LMS_Utility.getPartTranslations(inputs);
      Set<String> parts = LMS_Utility.getParts(inputs.LicenseUsageList); 
      Map<String, Product2> productMap = new Map<String, Product2>([Select APN_Number__c, Id, Name From Product2 where APN_Number__c in: parts]);
       
      Dom.XMLNode items = licensefileNode.addChildElement('ITEMS',null,null); 
       for(License_Usage__c lw: inputs.LicenseUsageList){    
            if(lw.itemnumber__c.equalsIgnoreCase(inputs.selectedServer) || lw.itemnumber__c.equalsIgnoreCase(inputs.selectedSwitchover))
                lw.Quantity_Used__c= 1;
                    Dom.XMLNode item = items.addChildElement('ITEM',null,null);
                    item.setAttribute('id',lw.itemnumber__c);
                    item.setAttribute('name',productMap.get(lw.product__c).Name);
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
                                        if(lw.itemnumber__c.equalsIgnoreCase(inputs.selectedServer) || lw.itemnumber__c.equalsIgnoreCase(inputs.selectedSwitchover))    
                                            product.setAttribute('quantity',String.valueOf(Integer.valueOf(lt.Assigned_Multiplier__c) + Integer.valueOf(lt.Multiplier__c)));
                                        else
                                            product.setAttribute('quantity',String.valueOf(lw.Quantity_Used__c));    
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
        return licensefileNode; 
    }
    
    public Static KeyCountWrapper processKeys(SelectionWrapper inputs){
      KeyCountWrapper countWrapper = new KeyCountWrapper();
      Map<String,Set<License_Translations__c>> partTranslations = LMS_Utility.getPartTranslations(inputs);
      Set<String> parts = LMS_Utility.getParts(inputs.LicenseUsageList); 
        system.debug('inside processkeys:' + partTranslations.size());
        Integer multiplier = 0; // this will be based on ordered qty of application session part
        for(License_Usage__c lw: inputs.LicenseUsageList) 
              if(partTranslations.containsKey(lw.itemnumber__c)){
                 Set<License_Translations__c> temp = partTranslations.get(lw.itemnumber__c);     
                 for(License_Translations__c lt: temp){
                    if(!lt.License_Key__r.category__c.equalsIgnoreCase('Feature')){
                            LMS_LicenseGenerationRequestWrapper.Licenses lic = new LMS_LicenseGenerationRequestWrapper.Licenses();   
                            lic.Name = lt.License_Key__r.Key_Name__c; 
                            lic.Assigned = (Integer.ValueOf(lt.Assigned_Multiplier__c) * lw.Quantity_Used__c) +'';
                            lic.Pooled = (Integer.ValueOf(lt.Multiplier__c) * lw.Quantity_Used__c) +'';
                            countWrapper.licenseLst.add(lic);
                    }
                    else
                        countWrapper.featureSet.add(lt.License_Key__r.Key_Name__c);
                    
                 }
             }
       return countWrapper;      
    }

    public class KeyCountWrapper{
        public List<LMS_LicenseGenerationRequestWrapper.Licenses> licenseLst;
        public Set<String> featureSet;
        public KeyCountWrapper(){
            licenseLst = new List<LMS_LicenseGenerationRequestWrapper.Licenses>();
            featureSet = new Set<String>();
        }
   }    
  
   public Class LicenseAssignedPooled{
           public String name;
           public Integer assigned;
           public Integer pooled;
            
            public LicenseAssignedPooled(String name,Integer assigned,Integer pooled){
                this.name = name;
                this.assigned = assigned;
                this.pooled=pooled;
            }
    }
    
    public Class SelectionWrapper{
        public String requestType;
        public LMS_ProductLine__c selectedProduct;
        public String selectedServer{get;set;}
        public String selectedswitchover{get;set;}
        public List<License_Usage__c> licenseUsageList{get;set;}
        public Boolean isSIP{get; set;}
        public String getRequestType(){
            if(licenseUsageList.size()>0)
                if(String.isNotBlank(licenseUsageList[0].License_Request_Log__c))
                    requestType = licenseUsageList[0].License_Request_Log__r.type__c;
          return requestType;
        }
        
    }
    
    public Static void updateUserMessageSetting(Boolean setVal) { 
        try {
           User usr = new User (Id = UserInfo.getUserId(), Broadcast_Partner_Message__c = setVal);
           update usr;
        }
        catch (Exception ex) {
            System.debug( ex.getMessage() );
        }
    }
    
    public Static Set<String> getParts(List<License_Usage__c> LicenseUsageList){
            Set<String> temp = new Set<String>();
            for(License_Usage__c lw: LicenseUsageList)
                  temp.add(lw.itemnumber__c);     
            return temp;      
    }

    public static Map<String,set<String>> getExclusion(String FileType,String ObjectType){
        Map<String,set<String>> exclusionmap=new Map<String,set<String>>();
        List<LMS_PartsExclusions__mdt> lstexclusion=[SELECT FieldtoQuery__c, Keywords__c FROM LMS_PartsExclusions__mdt where Object__c=:ObjectType and License_File_Type__c=:FileType ];
        for(LMS_PartsExclusions__mdt lms:lstexclusion){
        if(exclusionmap.containsKey(lms.FieldtoQuery__c)){
            System.debug('Keyword'+lms.keywords__c);
      exclusionmap.get(lms.FieldtoQuery__c).add(lms.keywords__c);
 
        }
        else{
           
            Set<String> keywordlist=new set<String>();
            keywordlist.add(lms.keywords__c);
            System.debug('Keyword'+lms.keywords__c);
            exclusionmap.put(lms.FieldtoQuery__c,keywordlist);
           
        }

        }
        return exclusionmap;
    }

    public static Boolean runningInASandbox() {
  return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
}
    
    
}