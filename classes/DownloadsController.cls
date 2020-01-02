/*
Class   : DownloadsController
Author –  Vinay Lakshmeesh
Date –    3/28/2013
Usage   : DownloadsController helps portal user to filter and choose the softwares to download
                  DynamicListOffsetController - Pagination and sorting of sotware download table
Revision History
*/

public with sharing class DownloadsController extends DynamicListOffsetController{
     
        public Id conId {get;set;}
        public String endUserAccName {get; set;}
        public string soldToAccName {get;set;}
        private Id endUserID;
        private Id soldToId;
        public Map<Id,String> prodToNameMap = new Map<Id,String>();
        public Map<Id,String> prodMap = new Map<Id,String>();
        //public Map<Id,String> prodLineMap = new Map<Id,String>();
        public Map<Id,String> componentToNameMap = new Map<Id,String>();
        private transient List<Software_Download__c> listofSwDload ;       
        private String tempQ ;
        //public transient List<Software_Download__c> listofSwDload;
        public List<Software_Download__c> softwares {get;set;}
        public List<Id> soldToAccntList = new List<Id>();
        public List<Id> endUsrAccntList = new List<Id>();
        public Boolean showPagination {get;set;}
        public Id prodId {get;set;} 
    //    public Id prodLineId {get;set;}
        public Id compId {get;set;}
        //public String dloadType ;
        public boolean isDloadTypeCD {get; set;}        
        /*
                The variables below map to the filters on Software Downloads page 
        */
        public String version {get;set;}        
        public String lang {get;set;}
        public String mjrRlease {get;set;}
        public String fileType {get;set;}
        public boolean isEndSoldToSelected {get;set;}
        public boolean acceptTnc {get;set;}
        public String sdLoadId {get;set;}
        public case currentCase {get;set;}
        public boolean includeSwRelShipCntrl {get;set;}
  //      public Set<Id> serviceContractIds;        
  //      public List<SelectOption> prodLines {get;set;}
        public List<SelectOption> prods {get;set;}
        public List<SelectOption> majorVersions {get;set;}
        public List<SelectOption> languages {get;set;}        
        public List<SelectOption> components {get;set;}
        public List<SelectOption> productVersions {get;set;}
        public List<SelectOption> osVersions {get;set;}        
        public Boolean showSaveButton {get;set;}        
//        public Boolean disableProductLine {get;set;}
        public Boolean disableProduct {get;set;}
        public Boolean disableComponent {get;set;}
        public Boolean disableProdVersion {get;set;}
        public Boolean disableMajorVersion {get;set;}
        public Boolean disableLanguage {get;set;}
        public Boolean disableOSVersion {get;set;}        
        public String endUserName {get;set;}
        public String soldToName {get;set;}   
        public String selectedProductLine {get;set;}
        public String selectedProduct {get;set;}
        public String selectedComponent {get;set;}
        public String selectedProductVersion {get;set;}
        public String selectedOSVersion {get;set;}
        public String selectedLanguage {get;set;}
        public String selectedMajorRelease {get;set;}
        public Boolean isProductNotFound;
        //public Map<Id,Set<Id>> prodLineTOProdMap = new Map<Id,Set<Id>>(); //Map of Product Line to List of Products

 
        public string query2 {get{
                //system.debug(query2);
                if((null == query2 || ''.equals(query2)) && conId != null) {
                        query2 = 'and Contact__c =\''+conId+'\' ';
                }
  
                Map<Id,String> mapOfAccntIdName = new Map<Id,String>();
              //  serviceContractIds = new Set<Id>();
                endUsrAccntList = new List<Id>();
                soldToAccntList = new List<Id>();
                          
             for(Support_Access__c sa : [SELECT Id,Name,End_User_Account__c,
                                                         Sold_To_Account__c,End_User_Account__r.Name,
                                                         Sold_To_Account__r.Name, Back_Office_Account__c
                                                         //,service_contract__c 
                                             FROM   Support_Access__c 
                                             WHERE  Contact__c =:conId
                                               and BOA_Platform__c LIKE 'PureEngage%'                                                
                                               and SR_Access_Level__c = 'Read/Write'
                                               //and Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
                                               and Service_Contract_Status__c = 'Active'
                                               and Status__c ='Active'
                                               and End_User_Account__c =: endUserId
                                               and Sold_To_Account__c =: soldToId]) {
             
                if(sa.End_User_Account__c!=null){
                        endUsrAccntList.add(sa.End_User_Account__c);
                        mapOfAccntIdName.put(sa.End_User_Account__c,sa.End_User_Account__r.Name);
                }
                
                if(sa.Sold_To_Account__c!=null){
                        soldToAccntList.add(sa.Sold_To_Account__c);
                        mapOfAccntIdName.put(sa.Sold_To_Account__c,sa.Sold_To_Account__r.Name);
                }
                
        }       
                //applyFilter(false);           
                                            
                return query2;
        }
        set;}
        
    public string fields {get{
                               return 'Id,Name,City__c,StateProvince__c,Country__c';}
                       set;}
 
 
    public String endUserAccId {get;set;}
    public String soldToAccId  {get;set;}
                
    public boolean displayTNC {get; set;}     
    
    public void closeTNC() {        
        displayTNC = false;    
    }        
   
    public void showTNC() {        
        displayTNC = true;    
    }
   
    public boolean displayNTNC {get; set;}     
    
    public void closeNTNC() {        
        displayNTNC = false;    
        }            
   
    public void showNTNC() {        
        displayNTNC = true;    
        }  
         
    private void loadCDType(){  
       /// use page parameter for portal and selected field value for internal site 
       /// to determine the type of download
    /*   Integer n  = [SELECT count() FROM Profile 
                     WHERE Name LIKE 'Genesys Portal%' AND ID= :UserInfo.getProfileId()];                                      
        if ( n>0 ) {
    */
                /// portal       
             String tmp = ApexPages.currentPage().getParameters().get('isDloadTypeCD');       
             if (tmp == 'true')
                  isDloadTypeCD = true;
             else
                 isDloadTypeCD = false;
   /*     }      
        else {
                //internal site, initialized from costructor 
                        isDloadTypeCD = false;
        }  */                        
    } 
  
/* MS 3/15/18
    public void flipInternalSiteLoadType() { 
      /// internal site, type change    
        if (isDloadTypeCD == false)
             isDloadTypeCD = true;
        else
             isDloadTypeCD = false;
        
        selectedProduct = null;     
        populateAllOnProdChange();          
    }   
*/                                      
    /*
        Method : Contructor DownloadsController
        Usage : Get all Support Access of the logged in Contact.
                        Get all the software downloads associated with the support access 
    */                                                                      
        public DownloadsController(){
        // Calling constructor of the DynamicListOffsetController.
        
            super();
       
            this.sortColumn = 'Publish_Date__c';
            this.sortAsc = false;
            showPagination = false;
           // prodLines = new List<SelectOption>();
            prods = new List<SelectOption>();   
                                           
            loadCDType(); 

            includeSwRelShipCntrl = false;            
         //   serviceContractIds = new Set<Id>();
            acceptTnc = false;
            listofSwDload = new List<Software_Download__c>();
            List<User> lstUser = [Select Id,ContactId 
                                  from   User  
                                  where  Id = :UserInfo.getUserId()];
            conId = lstUser[0].ContactId;
            currentCase = new Case();
            currentCase.ContactId = conId;
            Map<Id,String> mapOfAccntIdName = new Map<Id,String>();
            isEndSoldToSelected = false; //end user and sold to not selected
 
        autoPopulateEndUserSoldTo();
        
        
        if(endUsrAccntList!=null && soldToAccntList!=null  && endUsrAccntList.size()==1 && soldToAccntList.size()==1){
                //Prepopulate the End User and Sold to when the contact has only one support access.
                 endUserAccId = endUsrAccntList[0];
                 soldToId = soldToAccntList[0];
                 endUserID = endUsrAccntList[0];
                 endUserAccName = mapOfAccntIdName.get(endUsrAccntList[0]);
                 soldToAccId = soldToAccntList[0];
                 soldToAccName =  mapOfAccntIdName.get(soldToAccntList[0]);
                 isEndSoldToSelected = true;                
                 //applyFilter(false);                
        }
                
   }
    private void autoPopulateEndUserSoldTo(){
          List<Support_Access__c> suppAccess = [SELECT End_User_Account__c, End_User_Account__r.Name, Sold_To_Account__c, Sold_To_Account__r.Name 
                                    FROM Support_Access__c 
                                                WHERE  SR_Access_Level__c = 'Read/Write'
                                                and BOA_Platform__c LIKE 'PureEngage%'  
                                                AND Status__c = 'Active'                                                                                               
						                        //and Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
						                        and Service_Contract_Status__c = 'Active'
                                                AND Contact__c =: conId];
                        if(suppAccess.size() == 1){
                                currentCase.End_User_Account__c = suppAccess[0].End_User_Account__c;
                                endUserName = suppAccess[0].End_User_Account__r.Name;
                                currentCase.Sold_To_Account__c = suppAccess[0].Sold_To_Account__c;
                                soldToName = suppAccess[0].Sold_To_Account__r.Name;
                                setContact();                                   
                        }
                }
                
       public void setContact(){
            if(endUserName == null || endUserName == '' || soldToName == null || soldToName == ''){                         
                        prods.clear();
                        if(components != null)
                                components.clear();
                        if(majorVersions != null)
                                majorVersions.clear();
                        if(productVersions != null)
                                productVersions.clear();
                        if(languages != null)
                                languages.clear();
                        if(osVersions != null)
                                osVersions.clear();
                        softwares = new List<Software_Download__c>();
                        showPagination = false;
                        disableControls();
                        currentCase.Support_Product__c = null;
                        selectedComponent = null;
                        selectedMajorRelease = null;
                        selectedProductVersion = null;
                        selectedLanguage = null;
                        selectedOSVersion = null;
                        return;
            } 
                                  
            endUserAccId = currentCase.End_User_Account__c;
            soldToAccId = currentCase.Sold_To_Account__c;
            
            populateFields();   
            disableControls();  
        }
  
  /* MS - 3/15/18
        public PageReference loadAllRecords(){
                List<Account> genericCustomerAccount = [SELECT id FROM Account WHERE Name = 'Genesys Generic Customer'];
                if(!genericCustomerAccount.isEmpty()){
                        endUserAccId = genericCustomerAccount[0].id;
                        soldToAccId = genericCustomerAccount[0].id;
                }
                endUserName = 'showAllProducts';
                soldToName = 'showAllProducts';         
                populateFields();   
            disableControls();
            return null;
        }
   */     
        private List<SelectOption> sortListValues(List<SelectOption> items, Boolean ascending){
                Map<String, String> mapSort = new Map<String, String>();
                for(SelectOption eachOption : items){
                        if(eachOption.getLabel() != 'All')
                                mapSort.put(eachOption.getLabel(), eachOption.getValue());
                }
                Set<String> keySet = mapSort.keyset();
                List<String> keyList = new List<String>();
                for(String item : keySet)
                        keyList.add(item);
                keyList.sort();
                List<SelectOption> sortedItems = new List<SelectOption>();
                sortedItems.add(new SelectOption('','All'));
                if(ascending){
                        for(String eachItem : keyList){
                                sortedItems.add(new SelectOption(mapSort.get(eachItem), eachItem));
                        }
                }
                else{
                        for(Integer i = keyList.size() - 1; i >= 0 ; i-- ){
                                String eachItem = keyList[i];
                                sortedItems.add(new SelectOption(mapSort.get(eachItem), eachItem));
                        }
                }
                System.debug('NKC debug sortedItems ['+sortedItems+']');
        
                return sortedItems;
        }
        private void disableControls(){
                if(components != null && components.isEmpty())
                disableComponent = true;
            if(majorVersions != null && majorVersions.isEmpty())
                disableMajorVersion = true;             
            if(prods != null && prods.isEmpty())
                disableProduct = true;
  //          if(prodLines != null && prodLines.isEmpty())
   //             disableProductLine = true;
            if(productVersions != null && productVersions.isEmpty())
                disableProdVersion = true;
            if(languages != null && languages.isEmpty())
                disableLanguage = true;
            if(osVersions != null && osVersions.isEmpty())
                disableOSVersion = true;  
        }
        public void populateFields(){                   
                isProductNotFound = false;
                disableComponent = false;
                disableMajorVersion = false;
                disableProduct = false;
         //       disableProductLine = false;
                disableProdVersion = false;
                disableLanguage = false;
                disableOSVersion = false;
                isEndSoldToSelected = true;
                if(endUserName != null && endUserName != '' && soldToName != null 
                        && soldToName != ''){     
                     //   populateProdLines();
                        populatesProds();    
                        populateAll();                        
                }                        
                          
        }
         public void populateAllOnProdChange(){
                if(selectedProduct == null || selectedProduct == ''){
                        selectedComponent = null;
                        selectedLanguage = null;
                        selectedMajorRelease = null;
                        selectedOSVersion = null;
                        selectedProduct = null;
                        selectedProductLine = null;
                        selectedProductVersion = null;
                    //    populateProdLines();
                    populatesProds();
                }
            populateAll();
        }
        public void populateAll(){        
                currentCase.Component__c = selectedComponent;
                currentCase.Major_Release1__c = selectedMajorRelease;  
                currentCase.Support_Product__c = selectedProduct;
                applyFilter(true);      
                Set<String> uniqueValuesProducts = new Set<String>();
                Set<String> uniqueValuesMajorRelease = new Set<String>();
                Set<String> uniqueValuesComponent = new Set<String>();
                Set<String> uniqueValuesLanguage = new Set<String>();
                Set<String> uniqueValuesVersion = new Set<String>();
                Set<String> uniqueValuesOSVersion = new Set<String>();              
                SelectOption item = new SelectOption('', 'All');
            //prods.add(item);
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
            prods = new List<SelectOption>();
            prods.add(item);
            System.debug('NKC debug listofSwDload ['+listofSwDload+']');
            System.debug('NKC debug listofSwDload.size() ['+listofSwDload.size()+']');
            
            for(Software_Download__c sw :listofSwDload){                                
                if(sw.Product__c != null && !uniqueValuesProducts.contains(sw.Product__c)) {
                        uniqueValuesProducts.add(sw.Product__c);
                        if(prods.size() < 1000)
                                prods.add(new SelectOption(sw.Product__c, sw.Product__r.Name));
                }
                if(selectedProduct == null || selectedProduct == '')
                        continue;
                    if(sw.Major_Release__c != null && !uniqueValuesMajorRelease.contains(sw.Major_Release__c)) {
                        uniqueValuesMajorRelease.add(sw.Major_Release__c);
                        if(majorVersions.size() < 1000)
                                majorVersions.add(new SelectOption(sw.Major_Release__c, sw.Major_Release__c));
                }
                System.debug('NKC debug sw.Product_Component__c ['+sw.Product_Component__c+']');
                
                if(sw.Product_Component__c != null){// && !uniqueValuesComponent.contains(sw.Product_Component__c)) {
                        //uniqueValuesComponent.add(sw.Product_Component__c);
                        if(components.size() < 1000)
                                components.add(new SelectOption(sw.Product_Component__c, sw.Product_Component__r.Name));
                }
                if(sw.Localization__c != null && !uniqueValuesLanguage.contains(sw.Localization__c)) {
                        uniqueValuesLanguage.add(sw.Localization__c);
                        if(languages.size() < 1000)
                                languages.add(new SelectOption(sw.Localization__c, sw.Localization__c));
                }
                System.debug('NKC debug sw.Version__c ['+sw.Version__c+']');
                                            
                if(sw.Version__c != null && !uniqueValuesVersion.contains(sw.Version__c)) {
                        uniqueValuesVersion.add(sw.Version__c);
                        //if(productVersions.size() < 1000)
                        productVersions.add(new SelectOption(sw.Version__c, sw.Version__c));
                }
                if(sw.Operating_Systam__c != null && !uniqueValuesOSVersion.contains(sw.Operating_Systam__c)) {
                        uniqueValuesOSVersion.add(sw.Operating_Systam__c);
                        if(osVersions.size() < 1000)
                                osVersions.add(new SelectOption(sw.Operating_Systam__c, sw.Operating_Systam__c));
                }                
            }  
            prods = sortListValues(prods, true);
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
        }

 /** MS 3/15/18     
        public void populateProdLines(){    
       	            
                prodLines = UpdateCaseProductControllerHelper.fetchProdLines(currentCase, isProductNotFound);  
                                           
        }
 */
        public void populatesProds(){
  /** MS 3/15/18   	                   
                for(SelectOption eachItem : prodLines){
                        String id = currentCase.Product_Line__c;
                        if(eachItem.getValue() == id)           
                                selectedProductLine = eachItem.getLabel(); 
                }
                if(endUserName == 'showAllProducts'){
                        List<Support_Product__c> suppProducts =  [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product' AND Customer_Available__c = true ORDER BY Name ASC];
                        SelectOption item ; 
                         for(Support_Product__c eachSP: suppProducts){
                            item = new SelectOption(eachSP.id, eachSP.Name);
                            prods.add(item);
                        }
                }
                else{         
 
                prods = UpdateCaseProductControllerHelper.fetchProds(currentCase,isProductNotFound);
***/   
          List<Support_Product__c> suppProducts = SupportAccessProductSelector.getProductsByStEu(currentCase.Sold_To_Account__c, currentCase.End_User_Account__c);
                    prods.add( new SelectOption('', 'All') );
                     for (Support_Product__c eachSP: suppProducts )  
                  			prods.add( new SelectOption(eachSP.id, eachSP.Name) );             
            //   }
                
            if(!prods.isEmpty())   
                prods[0].setLabel('All');
                              
            applyFilter(true);             
        }
         
 
        public Pagereference queryFilter(){
                populateAll();
                return null;    
        }
   
   /*
                Method : apply filter
                Usage  : This method applies filters on Software Downloads table.
   
   */
        public void applyFilter(boolean isFirst){
                //List<Id> prodLineIdList = new List<Id>();
            system.debug('--applyFilter'+isFirst);
            
            prodToNameMap = new Map<Id,String>();
            prodMap = new Map<Id,String>();
            componentToNameMap = new Map<Id,String>();
 
                        for(SelectOption eachItem : prods){
                                if(eachItem.getValue() != null && eachItem.getValue() != '')
                                        prodMap.put(eachItem.getValue(), eachItem.getLabel());  
                        }
                        
                SET<ID> keys = prodMap.keySet();
                system.debug('--keys'+keys);    
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
                               
                Set<Id> setOfProdLineProds = new Set<Id>();
                                        
                System.debug('NKC debug selectedProduct ['+selectedProduct+']');
                if(selectedProduct !=null){
                        whereClause += ' and Product__c = '+'\''+ selectedProduct +'\'';
                        q +=' and Product__c = :selectedProduct';
                        
                }
                System.debug('NKC debug selectedComponent ['+selectedComponent+']');
                if(selectedComponent != null){
                        whereClause += ' and Product_Component__c = '+'\''+ selectedComponent +'\'';
                        q +=' and Product_Component__c = :selectedComponent';
                }
                
                if(selectedMajorRelease != null){
                        whereClause += ' and Major_Release__c = '+'\''+ selectedMajorRelease +'\'';
                        q +=' and Major_Release__c= :selectedMajorRelease';
                }
                
                if(selectedProductVersion != null){
                        whereClause += ' and Version__c = '+'\''+ selectedProductVersion +'\'';
                        q +=' and Version__c =: selectedProductVersion';
                }
                
                if(selectedOSVersion !=null){
                        whereClause += ' and Operating_Systam__c = '+'\''+ selectedOSVersion +'\'';
                        q+=' and Operating_Systam__c =:selectedOSVersion';
                }
                
                if(selectedLanguage != null){
                        whereClause += ' and Localization__c = '+'\''+ selectedLanguage +'\'';
                        q+=' and Localization__c =:selectedLanguage';
                }
                
                if(fileType!=null){
                        whereClause += ' and File_Type__c = '+'\''+fileType+'\'';
                        q+=' and File_Type__c =:fileType';
  
                }
             
                if(isDloadTypeCD){
                        whereClause += ' and Download_Type__c =\'CD\'';
                        q+=' and (Download_Type__c =\'CD\' or Download_Type__c =\'DVD\' or Download_Type__c =\'ISO\')';
                } else {
                        whereClause += ' and Download_Type__c !=\'CD\'';
                      //  q+=' and (Download_Type__c =\'IP-GA\' or Download_Type__c =\'IP-HotFix\')';
                       q+=' and Download_Type__c LIKE \'IP-%\' ';
                }
                 
                if(!includeSwRelShipCntrl){
                        whereClause += ' and Contolled__c = False';
                        q+=' and Contolled__c =False';
                }
                
                //q+= ' limit 100';               
        
                        System.debug('NKC debug q [' + q + ']');
        
                listofSwDload = new List<Software_Download__c>();
                if( !keys.isEmpty() ){                  
                        listofSwDload = Database.query(q);                      
                }

                this.activated = true;
 
                tempQ = 'SELECT Product__c,Product__r.Name FROM Software_Download__c ' + whereClause + 
                            ' group by Product__c,Product__r.Name';
                system.debug('--tempQ'+tempQ);
                
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
              
          //if( !keys.isEmpty() )
               this.resetResultSize(listofSwDload.size());
        }
        
        if(isFirst){ 
                this.first();
                        populateSoftwares();
        }
   }  
//  Cast the resultset
//  ---------------------------------------------------------------------------------------------
        public void populateSoftwares(){
                softwares = (List<Software_Download__c>) getRecords();
        }
   

    public pageReference lazyLoad(){
        activated = true;
        //populateSoftwares();
        return null;
    }
        
    public String formInQueryString(Set<Id> keys){
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
        
        
        public List<SelectOption> getFlType(){
                List<SelectOption> options = new List<Selectoption>();
                Map<String,String> rmvDup = new Map<String,String>();
                options.add(new SelectOption('','All'));
                
                if(listofSwDload == null  || prodId == null){
                    return options;
                }
                
                for(Software_Download__c sw :listofSwDload){
                        if(sw.File_Type__c!=null){
                            if(sw.File_Type__c != null) rmvDup.put(sw.File_Type__c,sw.File_Type__c);
                        }
                   }        
                  
                   for(String op:rmvDup.keySet()){
                        options.add(new SelectOption(op,rmvDup.get(op)));
                  }
                  return options; 
        }
        
        public List<SelectOption> getDtype(){
                List<SelectOption> options = new List<Selectoption>();
                Map<String,String> rmvDup = new Map<String,String>();
                options.add(new SelectOption('','All'));
                
                if(listofSwDload == null  || prodId == null){
                    return options;
                }
                
                for(Software_Download__c sw :listofSwDload){                       
                    if(sw.Download_Type__c!=null){
                        if(sw.Download_Type__c != null) rmvDup.put(sw.Download_Type__c,sw.Download_Type__c);
                    }
        }
        
        for(String op:rmvDup.keySet()){
                options.add(new SelectOption(op,rmvDup.get(op)));
        }             
                return options; 
        }               
        
      public List<SelectOption> sortListByValue( List<SelectOption> unsortedList, String sortDir, String sortType) {      
                        unsortedList.sort();
                Integer size = unsortedList.size();
                List<SelectOption> sortedList = new List<Selectoption>();
                
                sortedList.add(new SelectOption('','All'));  
                if ( sortType == 'lang' && size>1 )
                        sortedList.add(new SelectOption('ENU','ENU'));
                                                                     
                if ( sortDir == 'disc') {
                        while (size > 0 ){
                                sortedList.add(unsortedList[size-1]);
                                size--;
                        } 
                    }
                    else {
                        Integer i=0;
                        while (i < size ){                           
                                sortedList.add(unsortedList[i]);
                                i++;
                        }
                    }                                         
                return sortedList;
       }
       
      public list<selectOption> sortListByLabel( List<SelectOption> unsortedList) {
                List<SelectOption> sortedList = new List<Selectoption>();
                List<SelectOption> tempList = new List<Selectoption>();
                Integer size = unsortedList.size();
                Integer i=0;
                for (i=0; i<size; i++) {                     
                        tempList.add(new SelectOption(unsortedList[i].getLabel(), unsortedList[i].getValue()));
                }
                tempList.sort();                
                sortedList.add(new SelectOption('','All'));             
                for (i=0; i<size; i++) {
                        sortedList.add(new SelectOption(tempList[i].getLabel(), tempList[i].getValue()));
                }               
                return sortedList;
    }
}