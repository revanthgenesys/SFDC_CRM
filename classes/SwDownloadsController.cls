public with sharing class SwDownloadsController extends DynamicListOffsetController {

      public Id contactId {get;set;}
      public Boolean isReadOnlyProfile {get;set;}
      public String endUserAccId {get; set;}
      public String soldToAccId {get; set;}
      public String endUserName {get;set;}
      public String soldToName {get;set;}  
                     
      private Map<Id,String> prodMap = new Map<Id,String>();

        private transient List<Software_Download__c> listofSwDload ;       
        private String tempQ ;

        public List<Software_Download__c> softwares {get;set;}
        public Boolean showPagination {get;set;}
        public String downloadType {get; set;}       
        /*
                The variables below map to the filters on Software Downloads page 
        */
        public String version {get;set;}        
        public String lang {get;set;}
        public String mjrRlease {get;set;}
        public boolean isEndSoldToSelected {get;set;}
        public boolean acceptTnc {get;set;}
        public String sdLoadId {get;set;}

        public boolean includeSwRelShipCntrl {get;set;}
    
        public List<SelectOption> products {get; set;}
        public List<SelectOption> majorVersions {get;set;}
        public List<SelectOption> languages {get;set;}        
        public List<SelectOption> components {get;set;}
        public List<SelectOption> productVersions {get;set;}
        public List<SelectOption> osVersions {get;set;} 

        public Boolean disableProduct {get;set;}
        public Boolean disableComponent {get;set;}
        public Boolean disableProdVersion {get;set;}
        public Boolean disableMajorVersion {get;set;}
        public Boolean disableLanguage {get;set;}
        public Boolean disableOSVersion {get;set;}  
                      
        public String selectedProduct {get;set;}
        public String selectedComponent {get;set;}
        public String selectedProductVersion {get;set;}
        public String selectedOSVersion {get;set;}
        public String selectedLanguage {get;set;}
        public String selectedMajorRelease {get;set;}
        private Boolean isInternalUser;

   public SwDownloadsController() {
        // Calling constructor of the DynamicListOffsetController.       
       super();
       
       this.sortColumn = 'Publish_Date__c';
       this.sortAsc = false;
       showPagination = false;
       includeSwRelShipCntrl = false; 
        acceptTnc = false;
        listofSwDload = new List<Software_Download__c>();
        Map<Id,String> mapOfAccntIdName = new Map<Id, String>();
        isEndSoldToSelected = false;        
        downloadType = 'IP';
        isInternalUser = false;
        isReadOnlyProfile = false;
        
        products = new List<SelectOption>();  
   }
   
  public void setContact() {
           List<Support_Access__c> suppAccLst; 
           if ( ContactUtil.isPortalUser() && ContactUtil.isPremiseUser() )  {
                
                 List<User> usr = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];        
             contactId = usr[0].ContactId;           
             suppAccLst = ContactUtil.getRWSupprtAccLstByContact(usr[0].ContactId);
     
             if ( suppAccLst != null && suppAccLst.size() == 1 ) {              
                endUserAccId  = suppAccLst[0].End_User_Account__c;
                endUserName   = suppAccLst[0].End_User_Account__r.Name;
                        soldToAccId   = suppAccLst[0].Sold_To_Account__c;
                        soldToName    = suppAccLst[0].Sold_To_Account__r.Name;
                isEndSoldToSelected = true; 
                
                populateProductOptions();
             }  
        }  
        
        if ( suppAccLst == null || suppAccLst.isEmpty() )
                 isReadOnlyProfile = true;
  }
  
  public PageReference setInternalStEu()  {
           isInternalUser = true;
       List<Account> genericCustomerAccount = [SELECT id FROM Account WHERE Name = 'Genesys Generic Customer'];
       
       if (!genericCustomerAccount.isEmpty())  {
             endUserAccId = genericCustomerAccount[0].id;
             soldToAccId = genericCustomerAccount[0].id;    
             endUserName = 'Genesys Generic Customer';
             soldToName = 'Genesys Generic Customer';           
             populateProductOptions();
       }
       return null;
 }
        
  private void clearSelections() {         
       if ( components != null )  components.clear();
                                
       if (majorVersions != null ) majorVersions.clear();
                                
       if ( productVersions != null )  productVersions.clear();
                                
       if ( languages != null )  languages.clear();
                                
       if ( osVersions != null ) osVersions.clear();
                                                               
       softwares = new List<Software_Download__c>();
       showPagination = false;  
            
       selectedComponent = null;
       selectedMajorRelease = null;
       selectedProductVersion = null;
       selectedLanguage = null;
       selectedOSVersion = null;                 
  }
  
   public void populateAllOnProdChange() {        
           clearSelections();
            
       if ( selectedProduct == null || selectedProduct == '' )  {
           populateProductOptions();
       }
       else {   
                   populateAllSelectOptions();
       }
   }

   public void populateAllSelectOptions()  {    
            getSWDownloads();
            
            Set<String> uniqueValuesProducts = new Set<String>();
        Set<String> uniqueValuesMajorRelease = new Set<String>();
        Set<String> uniqueValuesComponent = new Set<String>();
        Set<String> uniqueValuesLanguage = new Set<String>();
        Set<String> uniqueValuesVersion = new Set<String>();
        Set<String> uniqueValuesOSVersion = new Set<String>();              
        SelectOption item = new SelectOption('', 'All');
        
        majorVersions = new List<SelectOption>();
        majorVersions.add(item);
        
        components = new List<SelectOption>();
        components.add(item);
        
        productVersions = new List<SelectOption>();
        productVersions.add(item);
        
        languages = new List<SelectOption>();
        languages.add(item);
        
        osVersions = new List<SelectOption>();
        osVersions.add(item);
  
        for ( Software_Download__c sw : listofSwDload )  { 
  
                if (sw.Major_Release__c != null && !uniqueValuesMajorRelease.contains(sw.Major_Release__c) ) {
                        uniqueValuesMajorRelease.add(sw.Major_Release__c);
                        if (majorVersions.size() < 1000)
                               majorVersions.add(new SelectOption(sw.Major_Release__c, sw.Major_Release__c));
                }                
                if (sw.Product_Component__c != null ) {
                        if (components.size() < 1000)
                           components.add(new SelectOption(sw.Product_Component__c, sw.Product_Component__r.Name));
                }
                if (sw.Localization__c != null && !uniqueValuesLanguage.contains(sw.Localization__c) ) {
                        uniqueValuesLanguage.add(sw.Localization__c);
                            languages.add(new SelectOption(sw.Localization__c, sw.Localization__c));
                }
                if(sw.Version__c != null && !uniqueValuesVersion.contains(sw.Version__c)) {
                        uniqueValuesVersion.add(sw.Version__c);
                        if(productVersions.size() < 1000)
                                 productVersions.add(new SelectOption(sw.Version__c, sw.Version__c));
                }
                if(sw.Operating_Systam__c != null && !uniqueValuesOSVersion.contains(sw.Operating_Systam__c)) {
                        uniqueValuesOSVersion.add(sw.Operating_Systam__c);
                        if(osVersions.size() < 1000)
                             osVersions.add(new SelectOption(sw.Operating_Systam__c, sw.Operating_Systam__c));
                }                
            }  

            majorVersions = sortListValues(majorVersions, false);    
            components = sortListValues(components, true);    
            languages = sortListValues(languages, true);    
            productVersions = sortListValues(productVersions, false);    
            osVersions = sortListValues(osVersions, true);
            Integer i = 0, enuPos = -1;
            for(SelectOption eachItem : languages){
                if(eachItem.getLabel() == 'ENU')
                        enuPos = i;
                i ++ ;
            }
            List<SelectOption> newList = new List<SelectOption>();
            if(enuPos != -1){
                newList.add(languages.get(0));
                newList.add(languages.get(enuPos));                             
                languages.remove(enuPos);
                languages.remove(0);
            }            
            
            for(SelectOption eachItem : languages){
                newList.add(eachItem);
            }
            languages.clear();
            for(SelectOption eachItem : newList){
                languages.add(eachItem);
            }
            
       return;            
        
   }  
  
   private void getSWDownloads()  {
         
       prodMap = new Map<Id, String>();
       for (SelectOption eachItem : products) {
            if( eachItem.getValue() != null && eachItem.getValue() != '' )
                  prodMap.put(eachItem.getValue(), eachItem.getLabel());  
       }
                        
       SET<ID> keys = prodMap.keySet();
       String whereClause;
                
       String q = 'SELECT CD_DVD_Name__c, TruncatedComponentName__c, Image_Type__c,Contolled__c,' +
                           'File_Size_KBs__c ,Release_Type__c ,Is_Latest_Version__c,File_Type__c,' +
                            'Product__r.Name,Product_Component__r.Name,Support_Product__r.Name, Download_Type__c,' +
                            'File_Date__c,File_Name__c,File_URL__c,Id,Localization__c,Major_Release__c,Name,' +
                            'Operating_Systam__c,OwnerId,Product_Component__c,Publish_Date__c,Support_Product__c,' +
                            'Version__c FROM Software_Download__c ' +
                            'where (Expiration_Date__c = null OR Expiration_Date__c > TODAY) AND Product__c IN ';
       q+=':keys ';
       whereClause = 'where (Expiration_Date__c = null OR Expiration_Date__c > TODAY) AND Product__c IN '+ 
                               formInQueryString(keys);
                               
       if (selectedProduct !=null)  {
            whereClause += ' and Product__c = '+'\''+ selectedProduct +'\'';
             q +=' and Product__c = :selectedProduct';
                        
       }
   
       if (selectedComponent != null) {
            whereClause += ' and Product_Component__c = '+'\''+ selectedComponent +'\'';
            q +=' and Product_Component__c = :selectedComponent';
       }
                
       if (selectedMajorRelease != null)  {
             whereClause += ' and Major_Release__c = '+'\''+ selectedMajorRelease +'\'';
             q +=' and Major_Release__c= :selectedMajorRelease';
       }
                
       if (selectedProductVersion != null) {
              whereClause += ' and Version__c = '+'\''+ selectedProductVersion +'\'';
              q +=' and Version__c =: selectedProductVersion';
       }
                
       if (selectedOSVersion !=null) {
              whereClause += ' and Operating_Systam__c = '+'\''+ selectedOSVersion +'\'';
              q+=' and Operating_Systam__c =:selectedOSVersion';
       }
                
       if (selectedLanguage != null) {
              whereClause += ' and Localization__c = '+'\''+ selectedLanguage +'\'';
              q+=' and Localization__c =:selectedLanguage';
       }

       if (downloadType != 'IP') {
             whereClause += ' and Download_Type__c =\'CD\'';
             q+=' and (Download_Type__c =\'CD\' or Download_Type__c =\'DVD\' or Download_Type__c =\'ISO\')';
        }
        else   {
            whereClause += ' and Download_Type__c !=\'CD\'';
             q+=' and (Download_Type__c =\'IP-GA\' or Download_Type__c =\'IP-HotFix\' or Download_Type__c =\'IP-Update\')';
        }
                 
        if (!includeSwRelShipCntrl)  {
            whereClause += ' and Contolled__c = False';
             q+=' and Contolled__c =False';
       }
                
       listofSwDload = new List<Software_Download__c>();
       if( !keys.isEmpty() ) {                  
              listofSwDload = Database.query(q);                      
       }

       this.activated = true;
 
        tempQ = 'SELECT Product__c,Product__r.Name FROM Software_Download__c ' + whereClause + 
                            ' group by Product__c,Product__r.Name';
 
        //Change Query to filter software downloads table 
       this.pageSize = 20;
       if( !keys.isEmpty() ) {
                showPagination = true;
                                
                this.ChangeQuery('SELECT CD_DVD_Name__c ,TruncatedComponentName__c , Image_Type__c,Contolled__c,File_Size_KBs__c ,' +
                                 ' Release_Type__c ,Is_Latest_Version__c,File_Type__c,Product__r.Name,' +
                                 ' Product_Component__r.Name,Support_Product__r.Name, Download_Type__c,File_Date__c,' +
                                 ' File_Name__c,File_URL__c,Id,Localization__c,Major_Release__c,Name,Operating_Systam__c,' +
                                 ' OwnerId,Product_Component__c,Publish_Date__c,Support_Product__c,Version__c ' +
                                 ' FROM Software_Download__c', 'Software_Download__c', whereClause );
              
               this.resetResultSize(listofSwDload.size());
        }
  
         populateSoftwares();
   } 
   
   private String formInQueryString(Set<Id> keys){
        String inQueryString;
        inQueryString = '(';
        
        for(Id k:keys){  
              if(k!=null){
                   inQueryString = inQueryString +'\''+ k +'\',';
             }                       
        }
        
        if(inQueryString!= '('){
                 inQueryString = inQueryString.removeEnd(',') + ')';
        }else{                       
                 inQueryString   = '(\'\')';
        }
                
        return inQueryString;
   }           
   
   public void populateSoftwares()  {
       softwares = (List<Software_Download__c>) getRecords();
       
   }
        
  public void populateProductOptions() {
           selectedProduct = null;
           products.clear();
           clearSelections();
        
           if ( endUserAccId != null && endUserAccId != '' && soldToAccId != null && soldToAccId != '' )  {
                     isEndSoldToSelected = true;
                     List<Support_Product__c> suppProducts = new List<Support_Product__c>();
  
                     if ( isInternalUser ) {
                  suppProducts = SupportAccessProductSelector.getProductsAccessAll();
                     } 
                     else {
                          suppProducts = SupportAccessProductSelector.getProductsByStEu(soldToAccId, endUserAccId);
                     }         
                        
                        // products.add( new SelectOption('', '--None--') );     
                     products.add( new SelectOption('', 'All') );
                         for (Support_Product__c eachSP: suppProducts )  {
                  products.add( new SelectOption(eachSP.id, eachSP.Name) );                  
             }
            
             if( ! products.isEmpty() )   {
                disableProduct = false;  
             } 
            
            ///comment for the None option 
            getSWDownloads();         
           }       
           return;
   }
   
   private List<SelectOption> sortListValues(List<SelectOption> items, Boolean ascending) {
         Map<String, String> mapSort = new Map<String, String>();
         for (SelectOption eachOption : items)  {
              if (eachOption.getLabel() != 'All')
                       mapSort.put(eachOption.getLabel(), eachOption.getValue());
         }
         Set<String> keySet = mapSort.keyset();
         List<String> keyList = new List<String>();
         for (String item : keySet )  {
                keyList.add(item);
         }
         keyList.sort();
         List<SelectOption> sortedItems = new List<SelectOption>();
       
         sortedItems.add(new SelectOption('','All'));
         if (ascending) {
               for (String eachItem : keyList) {
                      sortedItems.add(new SelectOption(mapSort.get(eachItem), eachItem));
                }
         }
          else {
                for (Integer i = keyList.size() - 1; i >= 0 ; i-- ) {
                      String eachItem = keyList[i];
                      sortedItems.add(new SelectOption(mapSort.get(eachItem), eachItem));
                }
        }
        return sortedItems;
   }

   public pageReference lazyLoad(){
       activated = true;
       return null;
   }  
       
}