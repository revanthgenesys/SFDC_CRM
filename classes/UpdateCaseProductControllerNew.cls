public without sharing class UpdateCaseProductControllerNew {
        private String caseId {get;set;}
        public case currentCase {get;set;}
        public List<SelectOption> prodLines {get;set;}
        public List<SelectOption> prods {get;set;}
        public List<SelectOption> majorVersions {get;set;}
        public List<SelectOption> components {get;set;}
        public List<SelectOption> productVersions {get;set;}
        public List<SelectOption> cloudDeployments {get;set;}    
        public String selectedCloudOffering {get;set;}
        public String selectedCloudProduct {get; set;}
        public Boolean showSaveButton {get;set;}        
        public Boolean disableProductLine {get;set;}
        public Boolean disableProduct {get;set;}
        public Boolean disableComponent {get;set;}
        public Boolean disableProdVersion {get;set;}
        public Boolean disableMajorVersion {get;set;}
        public Boolean isProductNotFound {get;set;}
        public Boolean isContactSelected {get;set;}
        public Boolean isNewCase {get;set;}
        public Boolean isPortal {get;set;}
        public Boolean displayCaseFields {get;set;}
        public Boolean isSaas {get;set;}
        public String contactName {get;set;}
        public String endUserName {get;set;}
        public String soldToName {get;set;}     
        public String caseType {get;set;}
        public string ivr_contact {get;set;}
      public string ivr_SoldTo {get;set;}
      public string ivr_Productline {get;set;}
      public string ivr_Product {get;set;}
      public string caseRecordTypeName {get;set;}
      public string buttonLabel {get;set;}
      public string contactId {get;set;}
      public Boolean isPortalCloudUser {get; set;}
      public Boolean isCaseCloud {get; set;}
        private String recordTypeId;
        public List<Selectoption> priorities {get;set;}
        public String selectedProductLine {get;set;}
        public String selectedProduct {get;set;}
        public String selectedComponent {get;set;}
        public String selectedVersion {get;set;}
        public List<Selectoption> maintenanceQueues {get; private set;}
        private Map<ID, Cloud_Deployment__c> cloudDeplMap;
        private String KBSearchQueries = '';        
        private String errorMsg = '';
        public String deplId {get; set;}
        
     public UpdateCaseProductControllerNew(ApexPages.StandardController stdController) {
                showSaveButton = false;
                disableComponent = false;
                disableMajorVersion = false;
                disableProduct = false;
                disableProductLine = false;
                disableProdVersion = false;
                isProductNotFound = false;
                isNewCase = false;
                isPortal = false;
                isContactSelected = false;
                displayCaseFields = false; 
                selectedProductLine = '';             
                caseId = stdController.getId();
 
          if (caseId == null)  {
                   currentCase = new Case(); 
                   currentCase.contactId = null;
                   currentCase.Sub_Status__c = 'New';
                   isNewCase = true;
                   buttonLabel = 'Next';
                   
                   recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');                                      
                   RecordType rType = [SELECT DeveloperName, Name FROM RecordType WHERE id =: recordTypeId LIMIT 1];
                   caseType = rType.DeveloperName;                 
                   currentCase.recordTypeId = rType.id;
                   caseRecordTypeName = rType.Name;
                   
                   isCaseCloud = ApexPages.currentPage().getParameters().get('ct') == 'Cloud' ? true : false;
                   deplId = ApexPages.currentPage().getParameters().get('dpl');                   
                   
                   // single SA
                   String StId = ApexPages.currentPage().getParameters().get('stid');
                   String EuId = ApexPages.currentPage().getParameters().get('euid');   
                   String StName = ApexPages.currentPage().getParameters().get('stnm');
                   String EuName = ApexPages.currentPage().getParameters().get('eunm');
                   if (StId != '' && EuId != '' && StName != '' && EuName != '') {
                          currentCase.End_User_Account__c = EuId;
                          currentCase.Sold_To_Account__c = StId;
                          currentCase.AccountId = EuId;
                          endUserName = EuName;
                          soldToName = StName;
                   }
                                                           
                        /*
                       * KB Search Feature
                       
                   if(ApexPages.currentPage().getParameters().get('questions') != null && ApexPages.currentPage().getParameters().get('questions') != ''){
                        currentCase.Description = ApexPages.currentPage().getParameters().get('questions');
                        if(caseType == 'Genesys_Feature_Request_Case'){
                            currentCase.Feature_Description__c = ApexPages.currentPage().getParameters().get('questions');
                        }                   
                    } 
                    
                    */
                    
                   if(rType.DeveloperName == 'Genesys_Feature_Request_Case')
                          currentCase.Origin = 'Phone';                                                   
            }
            else{ 
                  currentCase = [SELECT id, ContactId, Contact.Name, End_User_Account__c, End_User_Account__r.Name, 
                                  Sold_To_Account__r.Name, Sold_To_Account__c, Product_Line__c, Support_Product__c, 
                                  Component__c, Product_Version__c, Un_entitled_product_reason__c, Major_Release__c, 
                                  Major_Release1__c, RecordType.DeveloperName, RecordType.Name, Non_Entitled_Product_Selected__c,
                                  Cloud_Offering__c, Cloud_Product__c,Environment_Type__c,Deployment_Type__c, Cloud_Deployment__c,
                                  Security_Threat__c, Project_Stage__c, External_Ref__c
                                  FROM Case WHERE id =: caseId];
                                       
                  caseType = currentCase.RecordType.DeveloperName;
                  caseRecordTypeName = currentCase.RecordType.Name;
                  buttonLabel = 'Save';
            }
        
            isPortalCloudUser = ContactUtil.isCloudUser() && isCaseCloud ? true : false;
             
            isPortal = ContactUtil.isPortalUser() ? true : false;
            if (isPortal) 
               currentCase.Origin='WEB';
      
            if (isPortal || (caseType == 'Genesys_Feature_Request_Case' && isNewCase))  {
                isContactSelected = true;
                currentCase.ContactId = ContactUtil.getUserContactId();
                contactId = ContactUtil.getUserContactId();
                priorities = new List<Selectoption>();
                priorities.add(new SelectOption('2-High','2-High'));
                priorities.add(new SelectOption('3-Medium','3-Medium'));
                priorities.add(new SelectOption('4-Low','4-Low'));
                if(caseType == 'Genesys_Admin_Case'){
                  currentCase.Priority = '3-Medium';
                    currentCase.Sub_Status__c = 'New';
                }
                else{
                  currentCase.Priority = '4-Low';
                }
            }
            
            if(!isNewCase)  {
                 contactName = currentCase.Contact.Name;
                 endUserName = currentCase.End_User_Account__r.Name;
                 soldToName = currentCase.Sold_To_Account__r.Name;
            }

           prodLines = new List<SelectOption>();
           prods = new List<SelectOption>();         
           SelectOption item = new SelectOption('', 'None');
           prods.add(item);
           majorVersions = new List<SelectOption>();
           majorVersions.add(item);
           components = new List<SelectOption>();
           components.add(item);
           productVersions = new List<SelectOption>();
           populateFields();               
           currentCase.Un_entitled_product_reason__c = null;           
           populateSelectedUntitlementProducts();
     
           if (isNewCase && isCaseCloud)  
                   setCloudDefaults();          
   }
             
   private void setCloudDefaults() {  
                            
            if ( isNewCase )  {
             
                List<Support_Product__c> cloudProdLine = CaseUtil.getCloudProdLine();  
                List<Support_Product__c> cloudProd = CaseUtil.getCloudProducts(cloudProdLine[0]);                                  
                       
               if ( isPortalCloudUser && (cloudProdLine.isEmpty() || cloudProd.isEmpty()) )
                       errorMsg = 'We are encountering technical issues, please contact Genesys Technical Support.';
               else { 
                    currentCase.Product_Line__c = cloudProdLine[0].Id;
                    currentCase.Support_Product__c = cloudProd[0].Id;
               } 
                                 
               currentCase.Major_Release1__c = 'Unknown'; 
               currentCase.OS__c = 'N/A';  
               currentCase.Deployment_Type__c = 'Cloud';             
               currentCase.Environment_Type__c = 'Production';                             
           } 
         
         /* Portal */
           if ( deplId != null ) {
                     List<Cloud_Deployment__c> clDeplLst = [SELECT Id, Account__c, Sold_To_Account__c, Cloud_Offering__c 
                                                            FROM Cloud_Deployment__c 
                                                            WHERE Id =:deplId];
                 if ( !clDeplLst.isEmpty() )  {  
                             currentCase.Cloud_Deployment__c = deplId;                    
                         currentCase.Cloud_Offering__c  = clDeplLst[0].Cloud_Offering__c;  
                         currentCase.AccountId = clDeplLst[0].Account__c;
                         currentCase.End_User_Account__c = clDeplLst[0].Account__c;
                         currentCase.Sold_To_Account__c = clDeplLst[0].Sold_To_Account__c == null ? clDeplLst[0].Account__c : clDeplLst[0].Sold_To_Account__c;                                         
                 }
           }
           
           return;
                   
        }
        
        private void populateSelectedUntitlementProducts(){
          SelectOption item;
          Boolean itemExists;
          if(currentCase.Product_Line__c != null){
            itemExists = false;
            for(SelectOption eachItem : prodLines){
          if(eachItem.getValue() != '' && eachItem.getValue() == currentCase.Product_Line__c)  {
            itemExists = true;
            break;
          }
        }
        if(!itemExists){
              Support_Product__c eachSP = [SELECT id, Name FROM Support_Product__c WHERE id =: currentCase.Product_Line__c];
          item = new SelectOption(eachSP.id, eachSP.Name);        
          prodLines.add(item);          
        }
          }
          if(currentCase.Support_Product__c != null){
            itemExists = false;
            for(SelectOption eachItem : prods){
          if(eachItem.getValue() != '' && eachItem.getValue() == currentCase.Support_Product__c){
            itemExists = true;
            break;
          }
        }
        if(!itemExists){
              Support_Product__c eachSP = [SELECT id, Name FROM Support_Product__c WHERE id =: currentCase.Support_Product__c];
          item = new SelectOption(eachSP.id, eachSP.Name);
          prods.add(item);          
        }
          }
          if(currentCase.Component__c != null){
            itemExists = false;
            for(SelectOption eachItem : components){
          if(eachItem.getValue() != '' && eachItem.getValue() == currentCase.Component__c){
            itemExists = true;
            break;
          }
        }
        if(!itemExists){
              Support_Product__c eachSP = [SELECT id, Name FROM Support_Product__c WHERE id =: currentCase.Component__c];
          item = new SelectOption(eachSP.id, eachSP.Name);
          components.add(item);          
        }            
          }
          if(currentCase.Product_Version__c != null){
            itemExists = false;
            for(SelectOption eachItem : productVersions){
          if(eachItem.getValue() != '' && eachItem.getValue() == currentCase.Product_Version__c){
            itemExists = true;
            break;
          }
        }
        if(!itemExists){
              Product_Version__c eachSP = [SELECT id, Name FROM Product_Version__c WHERE id =: currentCase.Product_Version__c];
              item = new SelectOption(eachSP.id, eachSP.Name);
              productVersions.add(item);          
        }            
          }
       if(currentCase.Major_Release1__c != null){
            itemExists = false;
            for(SelectOption eachItem : majorVersions){
                 if(eachItem.getValue() != '' && eachItem.getValue() == currentCase.Major_Release1__c){
                     itemExists = true;
                     break;
              }
          }
        if(!itemExists){
              Set<Id> componentIds = new Set<Id>();
              for(Support_Product__c eachSP : [SELECT id FROM Support_Product__c WHERE 
                                                Product_Type__c IN ('Component','Third Party') AND
                          Parent_Product__c =: currentCase.Support_Product__c AND Customer_Available__c = true]){
            componentIds.add(eachSP.id);
          }
              for(Product_Version__c eachSP : [SELECT id, Major_Release__c FROM Product_Version__c WHERE Parent_Product__c =: currentCase.Component__c]){
                if(eachSP.Major_Release__c != null){
              if(eachSP.Major_Release__c == 'Uns')
                item = new SelectOption(eachSP.Major_Release__c, 'Unknown');
              else
                item = new SelectOption(eachSP.Major_Release__c, eachSP.Major_Release__c);
                }
              }
          majorVersions.add(item);
        }        
          }          
        }
        
        public pageReference cancel(){
          if(currentCase.id == null)
            return new pageReference('/500/o');
          else
            return new pageReference('/' + currentCase.id);
        }
        
        public void setContact(){
                //currentCase.ContactId = contactId;
                System.debug('NKC debug contactName ['+contactName+']');
                System.debug('NKC debug currentCase.ContactId ['+currentCase.ContactId+']');
                if(isPortal){
                    if(isProductNotFound){
                        if(endUserName == null || endUserName == '' || soldToName == null || soldToName == ''){
                              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'End User and Sold To fields are mandatory to select.');
                              ApexPages.addMessage(errorMessage);
                              isProductNotFound = false;
                              return ;
                         }       
                        RecordType rt =  [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE DeveloperName = 'Genesys_Admin_Case' AND SobjectType = 'Case'][0];
                        currentCase.RecordTypeId = rt.Id;
                        caseType = 'Genesys_Admin_Case';
                        return;
                    }
                    if(contactId != null && contactId != '')                        
                         isContactSelected = true;                
                    else
                         isContactSelected = false; 
                }
                populateFields();                                         
        }
        
        public void populateFields(){
                prodLines.clear();
                prods.clear();
                majorVersions.clear();
                components.clear();
                productVersions.clear();
                disableComponent = false;
                disableMajorVersion = false;
                disableProduct = false;
                disableProductLine = false;
                disableProdVersion = false;                
                if(endUserName != null && endUserName != '' && soldToName != null 
                        && soldToName != '' && ((contactName != null && contactName != '') || (contactId != null)) ){                                                     
                        populateProdLines();
                        populatesProds();
                        populateMajorVersion();
                        populatesComponents();
                        populatesProductVersions();
                        if(isProductNotFound){
                                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Now all the products are available, please find your product now.');
                        ApexPages.addMessage(errorMessage);             
                        }                     
                }
                
                if(components.isEmpty())
                        disableComponent = true;
                if(majorVersions.isEmpty())
                        disableMajorVersion = true;             
                if(prods.isEmpty())
                        disableProduct = true;
                if(prodLines.isEmpty())
                        disableProductLine = true;
                if(productVersions.isEmpty())
                        disableProdVersion = true; 
                populateSelectedUntitlementProducts();        
        }
        
        public void populateProdLines(){        
                        
                prodLines = UpdateCaseProductControllerHelper.fetchProdLines(currentCase, isProductNotFound);           
        }
        
        public void populatesProds(){
            for(SelectOption eachItem : prodLines){
              String id = currentCase.Product_Line__c;
              if(eachItem.getValue() == id)           
                selectedProductLine = eachItem.getLabel(); 
            }
                prods = UpdateCaseProductControllerHelper.fetchProds(currentCase,isProductNotFound);
                majorVersions.clear();
                components.clear();
                productVersions.clear();
                SelectOption item = new SelectOption('', 'None');
                majorVersions.add(item);
                components.add(item);           
                productVersions.add(item);              
        }
        public void setVersion(){
            for(SelectOption eachItem : productVersions){
              String id = currentCase.Product_Version__c;
              if(eachItem.getValue() == id)           
                selectedVersion = eachItem.getLabel(); 
            }
        }
        public void populateMajorVersion(){
            for(SelectOption eachItem : prods){
              String id = currentCase.Support_Product__c;
              if(eachItem.getValue() == id)           
                 selectedProduct = eachItem.getLabel(); 
            }            
                System.debug('NKC debug currentCase.Product_Line__c ['+currentCase.Product_Line__c+']');
                if(currentCase.Product_Line__c == null){
                        currentCase.Product_Line__c = UpdateCaseProductControllerHelper.getProductLineId(currentCase);
                        populatesProds();
                }
                majorVersions = UpdateCaseProductControllerHelper.fetchMajorVersions(currentCase);
                components.clear();
                productVersions.clear();
                SelectOption item = new SelectOption('', 'None');
                productVersions.add(item);
        }
        public void populatesComponents(){              
                components = UpdateCaseProductControllerHelper.fetchComponents(currentCase);
                productVersions.clear();
                SelectOption item = new SelectOption('', 'None');
                productVersions.add(item);
                if ((null != currentCase.Major_Release1__c) && (null != currentCase.Component__c)) {
                        productVersions = UpdateCaseProductControllerHelper.fetchProductVersion(currentCase);
                }               
        }
        public void populatesProductVersions(){ 
            for(SelectOption eachItem : components){
              String id = currentCase.Component__c;
              if(eachItem.getValue() == id)           
                selectedComponent = eachItem.getLabel(); 
            }
                productVersions = UpdateCaseProductControllerHelper.fetchProductVersion(currentCase);
        }       
        public pageReference next(){
                if ( isPortalCloudUser && errorMsg != '' )  {
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                    ApexPages.addMessage(errorMessage);
                    return null;
                }
                if ( isPortalCloudUser && caseType == 'Genesys_Product_Case' && (currentCase.Cloud_Offering__c == null || currentCase.Cloud_Product__c == null)) {
                        String msg = 'Please select Cloud Offering and Cloud Products.';
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                    ApexPages.addMessage(errorMessage);
                    return null;
                }                    
                Set<String> productIds = new Set<String>();
                if(caseType != 'Genesys_Admin_Case' && caseType != 'Genesys_Escalation_Case'){
                  if(endUserName == null || endUserName == '' || soldToName == null 
                          || soldToName == '' || ((contactName == null || contactName == '') && !isPortal)){
                          String msg;
                          if(isPortal)
                                  msg = 'End User and Sold To fields are mandatory to select.';
                          else
                                  msg = 'Contact, End User Account and Sold To Account fields are mandatory to select.';
                          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                          ApexPages.addMessage(errorMessage);
                          return null;
                  }
                }
                if(caseType != 'Genesys_Admin_Case' && caseType != 'Genesys_Escalation_Case' && (currentCase.Support_Product__c == null || currentCase.Product_Line__c == null || currentCase.Major_Release1__c == null)){
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Product, Product Line and Major Release fields are mandatory to select.');
                    ApexPages.addMessage(errorMessage);
                    return null;
                }
                if(caseType != 'Genesys_Admin_Case' && caseType != 'Genesys_Escalation_Case' && (currentCase.Component__c != null && currentCase.Product_Version__c == null)){
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Version field is mandatory to select if you have selected component.');
                    ApexPages.addMessage(errorMessage);
                    return null;
                }
                if(caseType != 'Genesys_Admin_Case' && caseType != 'Genesys_Escalation_Case' ){
                        for(Product_Mapping__c eachPM : [SELECT id, Sellable_Item__c FROM Product_Mapping__c WHERE Product__c =: currentCase.Support_Product__c]){
                                productIds.add(eachPM.Sellable_Item__c);
                        }
                        if(isNewCase){
                                currentCase.RecordTypeId = recordTypeId;
                        }
                        List<ContractLineItem> contractLineItems = [SELECT id FROM ContractLineItem WHERE PriceBookEntry.Product2Id in : productIds AND Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
                                AND ServiceContractId in (SELECT id FROM ServiceContract WHERE End_User_Name__c =: currentCase.End_User_Account__c AND 
                        Sold_To_Name__c =: currentCase.Sold_To_Account__c)];
                      
                }
                //currentCase.Non_Entitled_Product_Selected__c = false;
                displayCaseFields = true;               
                System.debug('NKC debug displayCaseFields ['+displayCaseFields+']');
                if(isNewCase)
                        return goToFRCasePage();
                else
                        return saveCase();
        }       
        public PageReference save(){
                if(currentCase.Un_entitled_product_reason__c == null || currentCase.Un_entitled_product_reason__c == ''){
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide the reason.');
                        ApexPages.addMessage(errorMessage);
                        return null;
                }       
                currentCase.Non_Entitled_Product_Selected__c = true;
                displayCaseFields = true;
                if(isNewCase)
                        return goToFRCasePage();
                else
                        return saveCase();
        }       
        public PageReference goToFRCasePage(){
                if(displayCaseFields){
                    String params;
                    String recordType;
                    PageReference pr;
                    String url;
                      if(isPortal && isProductNotFound)
                        recordType = currentCase.RecordTypeId;
                      else
                          recordType = Apexpages.currentPage().getParameters().get('RecordType');                          
                    if(caseType == 'Genesys_Escalation_Case' || caseType == 'Genesys_Optimization_Case' || caseType == 'Genesys_Outage' ) {
                      
                      if(currentCase.Major_Release1__c != null)
                        currentCase.Major_Release1__c = currentCase.Major_Release1__c.replace('Unknown', 'Unspecified');
                      if(selectedComponent != null)
                        selectedComponent = selectedComponent.replace('Unknown', 'Unspecified');
                      if(selectedVersion != null)
                        selectedVersion = selectedVersion.replace('Unknown', 'Unspecified');
                      if(selectedComponent == null)
                        selectedComponent = '';
                      if(selectedVersion == null)
                        selectedVersion = '';
                      params = '&cas3=' + contactName + '&cas3_lkid=' + currentCase.ContactId;
                      params += '&' + Label.Case_End_User_Field + '=' + endUserName  + '&' + Label.Case_End_User_Field + '_lkid=' + currentCase.End_User_Account__c;
                      params += '&' + Label.Case_Sold_To_Field + '=' + soldToName  + '&' + Label.Case_Sold_To_Field + '_lkid=' + currentCase.Sold_To_Account__c;
                      params += '&' + Label.Case_Product_Line_Field + '=' + selectedProductLine  + '&' + Label.Case_Product_Line_Field + '_lkid=' + currentCase.Product_Line__c;
                      params += '&' + Label.Case_Product_Field + '=' + selectedProduct  + '&' + Label.Case_Product_Field + '_lkid=' + currentCase.Support_Product__c;
                      params += '&' + Label.Case_Component_Field + '=' + selectedComponent  + '&' + Label.Case_Component_Field + '_lkid=' + currentCase.Component__c;
                      params += '&' + Label.Case_Version_Field + '=' + selectedVersion  + '&' + Label.Case_Version_Field + '_lkid=' + currentCase.Product_Version__c;
                      params += '&' + Label.Case_Major_Release_Field + '=' + currentCase.Major_Release1__c;                            
                      
                         /*
                         * KB Search Feature
                         *
                         if(ApexPages.currentPage().getParameters().get('questions') != null && ApexPages.currentPage().getParameters().get('questions') != ''){
                                                KBSearchQueries = '&questions='+ApexPages.currentPage().getParameters().get('questions');
                                              }   
                         */     
                          
                          url = '/500/e?RecordType='+recordType+'&ent=Case&nooverride=1' + params + KBSearchQueries;
                          pr = new PageReference(url);
                          pr.setRedirect(true);   
                         
                          pr.setRedirect(true);                   
                      return pr;
                    }
                    else{
                          params = '&page=2&cont=' + currentCase.ContactId + '&eu=' + currentCase.End_User_Account__c + '&sto='+currentCase.Sold_To_Account__c + 
                          '&pl='+currentCase.Product_Line__c + '&cm='+currentCase.Component__c+'&pv='+currentCase.Product_Version__c + '&sp=' + currentCase.Support_Product__c +
                          '&mr=' + currentCase.Major_Release1__c + '&clOf=' + currentCase.Cloud_Offering__c + '&clPr=' + currentCase.Cloud_Product__c;
        
                          /*
                         * KB Search Feature
                         *
                         if(ApexPages.currentPage().getParameters().get('questions') != null && ApexPages.currentPage().getParameters().get('questions') != ''){
                                                KBSearchQueries = '&questions='+ApexPages.currentPage().getParameters().get('questions');
                                              }   
                         */                        
                          //url = '/'+(Site.getCurrentSiteUrl() != null && Site.getCurrentSiteUrl().contains('/customercare/') ? 'customercare':'apex')+'/PortalNewFRCase?RecordType=' + recordType + params + KBSearchQueries;
                         //url = '/'+(Site.getBaseUrl()!= null && Site.getBaseUrl().contains('/customercare/') ? 'customercare':'apex')+'/PortalNewFRCase?RecordType=' + recordType + params + KBSearchQueries;
                          url = '/apex/PortalNewFRCase?RecordType=' + recordType + params + KBSearchQueries;
                          pr = new PageReference(url);
                          pr.setRedirect(true);                   
                      return pr;
                    }                              
                }
                return null;
        }
        public PageReference saveCase(){
                if(Apexpages.currentPage().getParameters().get('page') != null && Apexpages.currentPage().getParameters().get('page') == '2'){
                        currentCase.RecordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
                if(Apexpages.currentPage().getParameters().get('cont') != 'null' && Apexpages.currentPage().getParameters().get('cont') != '')
                        currentCase.contactId = Apexpages.currentPage().getParameters().get('cont');
                if(Apexpages.currentPage().getParameters().get('eu') != 'null' && Apexpages.currentPage().getParameters().get('eu') != '')
                        currentCase.End_User_Account__c = Apexpages.currentPage().getParameters().get('eu');
                if(Apexpages.currentPage().getParameters().get('sto') != 'null' && Apexpages.currentPage().getParameters().get('sto') != '')
                        currentCase.Sold_To_Account__c = Apexpages.currentPage().getParameters().get('sto');
                if(Apexpages.currentPage().getParameters().get('pl') != 'null')
                        currentCase.Product_Line__c = Apexpages.currentPage().getParameters().get('pl');
                if(Apexpages.currentPage().getParameters().get('cm') != 'null')
                        currentCase.Component__c = Apexpages.currentPage().getParameters().get('cm');
                if(Apexpages.currentPage().getParameters().get('pv') != 'null')
                        currentCase.Product_Version__c = Apexpages.currentPage().getParameters().get('pv');
                if(Apexpages.currentPage().getParameters().get('sp') != 'null')
                        currentCase.Support_Product__c = Apexpages.currentPage().getParameters().get('sp');
                if(currentCase.Feature_Description__c != null && currentCase.Feature_Description__c != ''){
                        currentCase.Description = currentCase.Feature_Description__c;
                        currentCase.Feature_Description__c = null;
                }
                if(Apexpages.currentPage().getParameters().get('mr') != 'null')
                        currentCase.Major_Release1__c = Apexpages.currentPage().getParameters().get('mr');
            
            
               if(Apexpages.currentPage().getParameters().get('clOf') != 'null')
                       currentCase.Cloud_Offering__c = Apexpages.currentPage().getParameters().get('clOf');
                if(Apexpages.currentPage().getParameters().get('clPr') != 'null')
                       currentCase.Cloud_Product__c = Apexpages.currentPage().getParameters().get('clPr'); 
        }
  
        try {
            if(isNewCase)  {
                 /// portal, field Case Sub-Type, option Cloud Service Order. Future: remove the option
                 if ( isPortal && currentCase.Problem_Sub_Type__c == 'Cloud Service Order' && currentCase.Service_Request_Type__c == null )
                    currentCase.Service_Request_Type__c = 'Other';
                
                    insert currentCase;
            }
            else
                    update currentCase;
        }
        catch (System.DmlException e) {                        
            return null;
        }
 
        PageReference pr = new PageReference('/'+currentCase.id);
        
        if(isPortal)
           pr = new PageReference('/customercare/CaseDetail?id='+currentCase.id);
          
        pr.setRedirect(true);
        return pr;
        }
        
        public Pagereference lazyLoad(){
        
       //Lines added by Ankit on 5/25
       if(ApexPages.currentPage().getParameters().get('isSaas')!=null){
                isSaaS = true;
         
                if(Apexpages.currentPage().getParameters().get('sto') != 'null')
                        currentCase.Sold_To_Account__c = Apexpages.currentPage().getParameters().get('sto');
                if(Apexpages.currentPage().getParameters().get('pl') != 'null'){
                        currentCase.Product_Line__c = Apexpages.currentPage().getParameters().get('pl');
                        ivr_Productline = [select name from Support_Product__c where id=:currentCase.Product_Line__c].name;
                }
                if(Apexpages.currentPage().getParameters().get('cm') != 'null')
                        currentCase.Component__c = Apexpages.currentPage().getParameters().get('cm');
                if(Apexpages.currentPage().getParameters().get('pv') != 'null')
                        currentCase.Product_Version__c = Apexpages.currentPage().getParameters().get('pv');
                if(Apexpages.currentPage().getParameters().get('sp') != 'null'){
                        currentCase.Support_Product__c = Apexpages.currentPage().getParameters().get('sp');
                        ivr_Product = [select name from Support_Product__c where id=:currentCase.Support_Product__c].name;
                }
                if(Apexpages.currentPage().getParameters().get('conid') != 'null'){
                        currentCase.ContactId = Apexpages.currentPage().getParameters().get('conid');
                        ivr_contact= [Select name from contact where id=:currentCase.ContactId].name;
                }
        
        if(currentCase.Sold_To_Account__c!=null){
                soldToName = [Select name from account where id=:currentCase.Sold_To_Account__c].name;
                ivr_SoldTo = soldToName;
        }
        
       if(Apexpages.currentPage().getParameters().get('sp') == 'null'){// If product is not found, create a admin case for portal user
             RecordType rt =  [SELECT DeveloperName,Id,
                                      SobjectType 
                               FROM   RecordType 
                               WHERE  DeveloperName = 'Genesys_Admin_Case' 
                                      AND SobjectType = 'Case'][0];
            currentCase.RecordTypeId = rt.Id;// Admin Case 
        }
                           
       }//Ankit modifications end here
       
        //06/19/2013 Naresh Kumar
        //Now this page is handling all kind of record types
        if(caseType != 'Genesys_Product_Case' && caseType != 'Genesys_Admin_Case' && 
           caseType != 'Genesys_Feature_Request_Case' && caseType != 'Genesys_Escalation_Case' 
           && caseType != 'Genesys_Outage' && caseType != 'Genesys_Optimization_Case'
        && isNewCase){
                recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            String urlToSend = '/500/e?RecordType='+recordTypeId+'&ent=Case&nooverride=1';
            PageReference p = new Pagereference(urlToSend);
            return p;
        }
        
        return null;
    }
        
     public PageReference saveNewCloudCaseInternal()  {
        /* different than Portal because it has to cover the update */
        if ( currentCase.Cloud_Deployment__c == null )
           return null;
           
          List<Cloud_Deployment__c> clDeplLst = [SELECT Account__c, Sold_To_Account__c, Cloud_Offering__c FROM Cloud_Deployment__c 
                                                 WHERE Id =:currentCase.Cloud_Deployment__c];
          if ( !clDeplLst.isEmpty() )  {
                  currentCase.AccountId = clDeplLst[0].Account__c;
                  currentCase.End_User_Account__c = clDeplLst[0].Account__c;
                  currentCase.Sold_To_Account__c = clDeplLst[0].Sold_To_Account__c;
                  
                  if ( clDeplLst[0].Cloud_Offering__c != null && currentCase.Cloud_offering__c != clDeplLst[0].Cloud_Offering__c ) {
                            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 
                              'The Cloud Offering selected does not match the Cloud Offering assigned to the Cloud Deployment - ' + 
                              clDeplLst[0].Cloud_Offering__c + '. Please correct the value.');
                        ApexPages.addMessage(errorMessage);
                        return null;
                  }
          }
          
        currentCase.Deployment_Type__c = 'Cloud';
        
        if (isNewCase)
                insert currentCase;
        else
            update currentCase;
            
        return new PageReference('/' + currentCase.id);
 
     }
}