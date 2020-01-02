public class LMSHybridLicenseController {
  
    public static List<LicenseSummaryWrapper> fetchSubscriptionParts(String selectedProduct, Set<String> perpetualParts, Boolean isSIP){
        List<LicenseSummaryWrapper> SubscriptionSummaryDataSub = new List<LicenseSummaryWrapper>();
        List<String> basePackage = new List<String>();
               
        Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();
        Map<String, Integer> licensesUsed = new Map<String, Integer>();
        Map<String, Set<License_Translations__c>> partTranslationsSub = new Map<String,Set<License_Translations__c>>();
        Map<String,Product2> perpetualSubscriptionMap = new Map<String,Product2>(); //perp apn, map<perpid, subscrip product
        Map<String,Product2> subscriptionPerpetualMap = new Map<String,Product2>();
        Map<String,Product2> partMasterSub = new Map<String,Product2>();
        Map<String,Set<License_Snapshot__c>> tempSnapshot = new Map<String,Set<License_Snapshot__c>>();
              
        transient Set<String> Item_Category = LMS_Utility.getProductCategoryCodes(selectedProduct);
        
        for(Product2 part: [select Id,Product_Name__c,Name,Building_Block__c,APN_Number__c,perpetual_product__c,perpetual_product__r.APN_Number__c 
                             From product2 
                             where isactive=true and offeringtype__c includes (: 'PureConnect Subscription') AND 
                             item_category__c in:Item_Category AND 
                             (NOT APN_Number__c like '3GP%') AND 
                             (NOT APN_Number__c like 'TS%') AND
                             (NOT APN_Number__c like 'TH%') AND
                             APN_Number__c<>NULL ]){
            partMasterSub.put(part.APN_Number__c,part);
            if(part.perpetual_product__c<>NULL){
                perpetualSubscriptionMap.put(part.perpetual_product__r.apn_number__c,part);
                if(part.Name.contains('Base Agent Package'))
                    basePackage.add(part.perpetual_product__r.APN_Number__c);
            }
            if(part.perpetual_product__c==NULL){
            system.debug('inside CS- Scanner:'+part.apn_number__c);
                perpetualSubscriptionMap.put(part.apn_number__c,part);
                if(!String.ISBLANK(part.Name))
                if(part.Name.contains('Base Agent Package'))
                    basePackage.add(part.APN_Number__c);
            }
        }
        //Cleansing unnecessary parts
        for(License_Translations__c lt : [SELECT Id, item_number__c, SIP_Product__c FROM License_Translations__c WHERE item_number__c IN :partMasterSub.keyset() AND SIP_Product__c <>: isSIP]){
            partMasterSub.remove(lt.item_number__c);
        }
        
        for(Product2 part: [select Id,Product_Name__c,name,Building_Block__c ,APN_Number__c,perpetual_product__c from product2 where isactive=true and apn_number__c in:perpetualSubscriptionMap.keySet()]){
            subscriptionPerpetualMap.put(perpetualSubscriptionMap.get(part.apn_number__c).apn_number__c,part);
        }
        
        
        for(License_Translations__c lt : [SELECT Id, product__c,product__r.product_name__c,product__r.Building_Block__c, Item_Number__c,License_Key__r.category__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE item_number__c IN :perpetualSubscriptionMap.keyset()]){
            LicenseAssignedPooled TempAssignedPooled = new LicenseAssignedPooled();
            /*LicenseAssignedPooled TempAssignedPooled = generateMultipliersString(perpetualSubscriptionMap.get(lt.Item_Number__c).apn_number__c,lt.License_Key__r.Key_Name__c);
            lt.Assigned_Multiplier__c = TempAssignedPooled.Assigned;
            lt.Multiplier__c = TempAssignedPooled.Pooled;*/
            TempAssignedPooled.Assigned= integer.valueof(lt.Assigned_Multiplier__c);
            TempAssignedPooled.Pooled= integer.valueof(lt.Multiplier__c);
           if(partTranslationsSub.containsKey(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c)) {
              partTranslationsSub.get(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c).add(lt);  
            }   
            else{
              Set<License_Translations__c> tset = new Set<License_translations__c>();
              tset.add(lt); 
              partTranslationsSub.put(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c,tset);
            }
               
            if(partNumberKeys.containsKey(lt.Item_Number__c)){
                partNumberKeys.get(lt.Item_Number__c).add(lt.License_Key__r.Key_Name__c + TempAssignedPooled.getMultipliersString());   
            } else {
                partNumberKeys.put(lt.Item_Number__c, new List<String>{lt.License_Key__r.Key_Name__c + TempAssignedPooled.getMultipliersString()}) ;   
            }
        }
        
        for(String items: partMasterSub.keyset()){ system.debug('items:'+items);
                if(perpetualSubscriptionMap.containsKey(items))
                    SubscriptionSummaryDataSub.add(new LicenseSummaryWrapper(items+'', perpetualSubscriptionMap.get(items).Name,99999,0, partNumberKeys.get(items),perpetualSubscriptionMap.get(items).id));
                else
                    SubscriptionSummaryDataSub.add(new LicenseSummaryWrapper(items+'', partMasterSub.get(items).Name,99999,0, partNumberKeys.get(subscriptionPerpetualMap.get(items).apn_number__c),partMasterSub.get(items).id));    
              
        }   
       return SubscriptionSummaryDataSub; 
    }
    
    public Static Map<String, Set<License_Translations__c>> getSubscriptionTranslations(String selectedProduct, Set<String> subscriptionParts){
        Map<String, Set<License_Translations__c>> partTranslationsSub = new Map<String, Set<License_Translations__c>>();
        Map<String,Product2> perpetualSubscriptionMap = new Map<String,Product2>(); //perp apn, map<perpid, subscrip product
        
        Set<String> Item_Category = LMS_Utility.getProductCategoryCodes(selectedProduct);
        
         for(Product2 part: [select Id,Product_Name__c,Name,Building_Block__c,APN_Number__c,perpetual_product__c,perpetual_product__r.APN_Number__c from product2 where isactive=true and offeringtype__c includes (: 'PureConnect Subscription') and item_category__c in:Item_Category and (NOT APN_Number__c like '3GP%') AND APN_Number__c IN :subscriptionParts]){
            if(part.perpetual_product__c<>NULL){
                //if(subscriptionParts.contains(part.perpetual_product__r.apn_number__c))
                perpetualSubscriptionMap.put(part.perpetual_product__r.apn_number__c,part);
            }
            if(part.perpetual_product__c==NULL){
               // if(subscriptionParts.contains(part.apn_number__c))
                perpetualSubscriptionMap.put(part.apn_number__c,part);
            }
        }
        
        for(License_Translations__c lt : [SELECT Id, product__c,product__r.product_name__c,product__r.Building_Block__c, Item_Number__c,License_Key__r.category__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE item_number__c IN :perpetualSubscriptionMap.keyset()]){
            LicenseAssignedPooled TempAssignedPooled = generateMultipliersString(perpetualSubscriptionMap.get(lt.Item_Number__c).apn_number__c,lt.License_Key__r.Key_Name__c);
            //lt.Assigned_Multiplier__c = TempAssignedPooled.Assigned;
            //lt.Multiplier__c = TempAssignedPooled.Pooled;    

           if(partTranslationsSub.containsKey(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c)) {
              partTranslationsSub.get(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c).add(lt);  
            }   
            else{
              Set<License_Translations__c> tset = new Set<License_translations__c>();
              tset.add(lt); 
              partTranslationsSub.put(perpetualSubscriptionMap.get(lt.item_number__c).apn_number__c,tset);
            }
         }   
         return partTranslationsSub;   
    }
    
    public static Map<String,Set<License_Snapshot__c>> getSubscriptionSnapshot(String selectedProduct, Set<String> SubscriptionParts, String SoldToAccountId){
        
        Map<String,Set<License_Snapshot__c>> tempSnapshot = new Map<String,Set<License_Snapshot__c>>();
      
        for(Product2 part: [select Id,Product_Name__c,name,Building_Block__c ,APN_Number__c,perpetual_product__c from product2 where isactive=true and apn_number__c in:SubscriptionParts]){
            License_Snapshot__c snap = new License_Snapshot__c();
            snap.Part_Number__c = part.apn_number__c;
            snap.Product__c= part.id;
            snap.Perpetual__c  = 99999;
            snap.Non_Perpetual__c = 0;
            snap.sold_to__c = SoldToAccountId; 
            Set<license_Snapshot__c> temps = new Set<license_snapshot__c>{snap};
            tempSnapshot.put(part.apn_number__c, temps);
        }
       return tempSnapshot; 
    } 
    
   /*   Static Map<String,LMS_LicenseGenerationRequestWrapper.Licenses> sumAllLicenses(List<LMS_LicenseGenerationRequestWrapper.Licenses> SubscriptionLicenseLst, Map<String,LicenseAssignedPooled> licenseKeys){
        Map<String,LMS_LicenseGenerationRequestWrapper.Licenses> licenselsts= new Map<String,LMS_LicenseGenerationRequestWrapper.Licenses>();
        Map<String,SubscriptionRequestWrapper.Licenses> sublicenselsts= new Map<String,SubscriptionRequestWrapper.Licenses>();
       
        for(LMS_LicenseGenerationRequestWrapper.Licenses license: SubscriptionLicenseLst){
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
         return licenselsts;
     }*/
      
    Static LicenseAssignedPooled generateMultipliersString(String APN, String key){
      String multipliersString;  
      Set<String> assignedGenericKeys = new Set<String>{'I3_LICENSE_BASIC_STATION'}; //This always has assigned =1 irrespective of concurrent / nonconcurrent
      Set<String> pooledGenericKeys = new Set<String>{'I3_LICENSE_EXTERNAL_CALL_PORTS','I3_LICENSE_FAX_SESSION'};  
      LicenseAssignedPooled lic = new LicenseAssignedPooled();
      lic.name = key;
      if(APN.contains('-C-') || APN.endsWith('-C')){
        lic.assigned = 0;
        lic.pooled = 1;
      }
      else{
        lic.assigned = 1;
        lic.pooled = 0;
      }
      
      if(assignedGenericKeys.contains(key)){
        lic.assigned = 1;
        lic.pooled = 0;
      }
      if(pooledGenericKeys.contains(key)){
        lic.assigned = 0;
        lic.pooled = 1;
      }
      return lic;
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
  
}