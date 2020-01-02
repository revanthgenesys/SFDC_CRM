/*****************************************************
Class: CreateCustomerPortalCaseExtenstion
Author – Vinay Lakshmeesh
Date – 3/28/2013
Usage : Controller for VF page 'Portal_Select_Case_Type'. 
        Assists in choosing Case Type, End User, Sold To, Product and Product Line 
Revision History
*******************************************************/
public without sharing class CreateCustomerPortalCaseExtenstion {
    public Case             ca                                                  {get;set;}
    public String           caseType                                            {get;set;}
    public boolean          showDynamicFld                                      {get;set;}
    public boolean          prodFnd                                             {get;set;}
    public boolean          skip                                                {get;set;}
    public boolean          dontSkipFirstScreen                                 {get;set;}

    public List<String>     productNameList                                     {get;set;}
    public boolean          isContactChosen                                     {get;set;}
    public boolean          displayCaseFields                                   {get;set;}
    public boolean          isPortal                                            {get;set;}
    public boolean          isCaseEdit                                          {get;set;}
    public boolean          isCaseEditFirstRun;// if getter and setters are called the first time
    
    public Map<String,Id>   mapOfRecType                                         = new Map<String,Id>();
    public Map<Id,String>   prodToNameMap                                        = new Map<Id,String>();
    public Map<Id,String>   prodLineMap                                          = new Map<Id,String>();
    public Map<Id,String>   prodMap                                              = new Map<Id,String>();
 
    public Id               conId;
    public boolean          isCaNonAdmin                                         {get;set;}

    public String           endUserAccName                                       {get; set;}
    public String           prodLineNm                                           {get;set;}
    public List<Id>         endUsrAccntList                                      = new List<Id>();
    public List<Id>         soldToAccntList                                      = new List<Id>();
    public Set<Id>          serviceContractIds;
    //04/16/2013    Naresh Kumar
    public Boolean isFeatureRequestCase                                          {get;set;}
    
    public Boolean          isProdChangeValid                                    {get;set;}
    public Boolean          isInConsole                                          {get;set;}
    //Added by Ankit on 5/29
    public Boolean 			isSaaS 												 {get;set;}
    public string           ivr_contact								             {get;set;}
    public string           ivr_SoldTo								             {get;set;}
    public string           ivr_Productline								         {get;set;}
    public string           ivr_Product								             {get;set;}
    
    public List<SelectOption> probType                                           {get;set;}
	public String endUserAccId {get{
        endUserAccId = null;
        
        if(endUserAccName!='' && endUserAccName!=null && isContactChosen){
            List<Support_Access__c> sas = [SELECT End_User_Account__c, End_User_Account__r.Name 
                                           FROM   Support_Access__c 
                                           WHERE  Contact__c =:conId 
                                                  and Support_Blocked__c=false and 
                                                  SR_Access_Level__c = 'Read/Write' and
                                                  Maintenance_Terminated_Flag__c=false
                                                  and End_User_Account__r.Name Like :endUserAccName ];
            
            if(sas.size() >= 1)
                endUserAccId = sas[0].End_User_Account__c;
            }
        
        return endUserAccId;
        } set{
                 if(endUserAccId == ''){
                    endUserAccId = null;
                 }
                 
                 if(endUserAccId != ''&& endUserAccId != null){
                    ca.End_User_Account__c = endUserAccId;
                 }
             }
    }
    
    public string soldToAccName {get;set;}
    
    public String soldToAccId {get{
        soldToAccId = null;
        
        if(soldToAccName != '' && soldToAccName!=null && isContactChosen){
            List<Support_Access__c> sas = [SELECT Sold_To_Account__c, Sold_To_Account__r.Name 
                                           FROM   Support_Access__c 
                                           WHERE  Contact__c =:conId 
                                                  and Support_Blocked__c=false and 
                                                  SR_Access_Level__c = 'Read/Write' and
                                                  Maintenance_Terminated_Flag__c=false
                                                  and Sold_To_Account__r.Name Like :soldToAccName ];
            if(sas.size() >= 1)
                soldToAccId = sas[0].Sold_To_Account__c;
        }
        return soldToAccId;
        }set {
                if(soldToAccId == ''){
                    soldToAccId = null;
                }
                
                                if(soldToAccId != '' && soldToAccId != null){
                    ca.Sold_To_Account__c = soldToAccId;
                }
        }
    }
    /*
        Getter and Setter : Query
        Usage             : Query End User and Sold To (Hierarchical)
    */                          
    public string query {get{
        if((null == query || ''.equals(query)) && conId != null) {
        	query = 'and Support_Blocked__c=false and Maintenance_Terminated_Flag__c=false and SR_Access_Level__c =' +'\'Read/Write\'' +' and Contact__c =\''+conId+'\'';
        }
        
        //get Product Lines and Products in a map
        if(endUserAccId!=null && soldToAccId!=null  && isContactChosen){
                        gtProdMap();
        }
                                    
        return query;
    }
    set;}

        private void gtProdMap(){
            for(Support_Access__c sa : [SELECT Id,Name,End_User_Account__c,
                                                           Sold_To_Account__c,End_User_Account__r.Name,
                                                           Sold_To_Account__r.Name,service_contract__c 
                                        FROM   Support_Access__c 
                                        WHERE  Contact__c =:conId 
                                                   and Support_Blocked__c=false and 
                                                   SR_Access_Level__c = 'Read/Write' and
                                                   Maintenance_Terminated_Flag__c=false
                                                   and End_User_Account__c =: endUserAccId
                                                   and Sold_To_Account__c =: soldToAccId]){
                        if(sa.service_contract__c!=null){
                            serviceContractIds.add(sa.service_contract__c);
                        }
            
            }
            List<Id> prodLineId = new List<Id>();
            
            List<ContractLineItem> contrLineItemList = CreateCustPortalCaseExtnWithoutSharing.queryContractLineItem(serviceContractIds);
            
            if(contrLineItemList!=null){
                
                for(ContractLineItem c:contrLineItemList){
                    prodToNameMap.put(c.PricebookEntry.Product2Id,c.PricebookEntry.Name);               
                }
                
            } 
            
            List<Product_Mapping__c> proMapList = CreateCustPortalCaseExtnWithoutSharing.queryProductMapping(prodToNameMap.keySet());
         	
         	//Lines added by Ankit on 5/29
       	if(ApexPages.currentPage().getParameters().get('isSaas')!=null){
         	if(Apexpages.currentPage().getParameters().get('pl') != 'null')
     			ca.Product_Line__c = Apexpages.currentPage().getParameters().get('pl');
       		 	//Lines added by Ankit on 5/29
       
         		if(Apexpages.currentPage().getParameters().get('sp') != 'null')
     			ca.Support_Product__c = Apexpages.currentPage().getParameters().get('sp');
       			gtComponents();
       	}
            system.debug('--prodToNameMap'+prodToNameMap);
            system.debug('--prodLineMap'+prodLineMap);
        }

    public string fields {get{
                                return 'Id,Name,City__c,StateProvince__c,Country__c';}
                           set;}
    
    /*
        Method : Contrructor createCustomerPortalCaseExtenstion
        Usage  : Constructor to populate End Use and Sold To 
                 
    */
    public createCustomerPortalCaseExtenstion(ApexPages.StandardController stdController) {
        
        isPortal = false;
        isCaseEdit = false;
        isCaseEditFirstRun = false;
        skip = false;
        dontSkipFirstScreen = true;
        //If the page is on a change product page.
        isProdChangeValid = false;
        String isdtp = ApexPages.currentPage().getParameters().get('isdtp');
        if(isdtp != null && isdtp == 'vw'){
        	isInConsole = true;
        }else{
        	isInConsole = false;
        }
        if(stdController.getId()!=null){
                isCaseEditFirstRun = true;// set the boolean to false after getters and setters are loaded
                isCaseEdit = true;
                this.ca = [SELECT ContactId,Product_Line__c,Product_Line__r.Name,
                                  End_User_Account__c,Sold_To_Account__c,
                                  Support_Product__c,Component__c,
                                  Product_Version__c,End_User_Account__r.Name,
                                  Sold_To_Account__r.Name,Component__r.Name 
                           FROM   Case 
                           WHERE  Id=:stdController.getId()][0];
                                           
                    if(ca.ContactId!=null ) isContactChosen = true;
                        
                        endUserAccName = ca.End_User_Account__r.Name;
                        soldToAccName = ca.Sold_To_Account__r.Name;
                        endUserAccId = ca.End_User_Account__c;
                        soldToAccId = ca.Sold_To_Account__c;
                        
                        
                        
                        /*prodLine = new List<Selectoption>();
                        prodLine.add(new SelectOption('','None'));
                        
                        if(ca.Product_Line__c!=null) prodLine.add(new SelectOption(ca.Product_Line__c,ca.Product_Line__r.Name));
                        
                        components = new List<SelectOption>();
                        components.add(new SelectOption('','None'));
                
                        if(ca.Component__c != null) components.add(new SelectOption(ca.Component__c,ca.Component__r.Name));
                        
                        gtVersions();
                        system.debug('--ca'+ca);*/
        }else{
                this.ca = (Case)stdController.getRecord();
        }
        
        prodFnd = true;
        isCaNonAdmin = true;
        displayCaseFields = false;
        serviceContractIds = new Set<Id>();
        isFeatureRequestCase = false;
        List<User> lstUser = [Select Id,ContactId, IsPortalEnabled 
                              From   User  
                              Where  Id = :UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;
        
        if(isPortal){
            isContactChosen = true;
            conId = lstUser[0].ContactId;
            probType = new List<Selectoption>();
            probType.add(new SelectOption('','None'));
            probType.add(new SelectOption('2-High','2-High'));
            probType.add(new SelectOption('3-Medium','3-Medium'));
            probType.add(new SelectOption('4-Low','4-Low'));
            
            //Add priority 'Prod Down' and '1-Critical' (Portal user only)
        }else if(ca.ContactId != null){//Indicates that the page is on Change Porducts in edit mode.
            isContactChosen = true;
            conId = ca.ContactId;
            resetFilters();
        }else{
                ca.Origin = 'Phone';
                isContactChosen = false;
        }
            
        showDynamicFld = true;  
        
        if(!isCaseEdit){
            RecordType rt =  [SELECT DeveloperName,Id,
                                      SobjectType 
                               FROM   RecordType 
                               WHERE  Id = :ApexPages.currentPage().getParameters().get('RecordType')][0];
            caseType = rt.DeveloperName;
            system.debug('--caseType'+caseType);
            
            if(caseType == 'Genesys_Admin_Case'){
                isCaNonAdmin = false;
                ca.Problem_Type__c = 'Administration';
            }
            else if(caseType == 'Genesys_Feature_Request_Case'){
                isFeatureRequestCase = true;
            }
            else if(caseType== 'Genesys_Product_Case'){
                //Default the vaules before moving to the next screen
                ca.Status = 'Open';
                ca.Sub_Status__c = 'New';
                ca.Problem_Type__c = 'Product';
                ca.Problem_Sub_Type__c = 'Problem';
            }
            ca.RecordTypeId = rt.id;
        }else{
                
        }
    }       

    public Pagereference lazyLoad(){
        
       //Lines added by Ankit on 5/25
       if(ApexPages.currentPage().getParameters().get('isSaas')!=null){
       		isSaaS = true;
     		//if(Apexpages.currentPage().getParameters().get('eu') != 'null'){
     		//	ca.End_User_Account__c = Apexpages.currentPage().getParameters().get('eu');
     			//endUserAccId=ca.End_User_Account__c;
     		//}
     		if(Apexpages.currentPage().getParameters().get('sto') != 'null')
     			ca.Sold_To_Account__c = Apexpages.currentPage().getParameters().get('sto');
     		if(Apexpages.currentPage().getParameters().get('pl') != 'null'){
     			ca.Product_Line__c = Apexpages.currentPage().getParameters().get('pl');
     			ivr_Productline = [select name from Support_Product__c where id=:ca.Product_Line__c].name;
     		}
     		if(Apexpages.currentPage().getParameters().get('cm') != 'null')
     			ca.Component__c = Apexpages.currentPage().getParameters().get('cm');
     		if(Apexpages.currentPage().getParameters().get('pv') != 'null')
     			ca.Product_Version__c = Apexpages.currentPage().getParameters().get('pv');
     		if(Apexpages.currentPage().getParameters().get('sp') != 'null'){
     			ca.Support_Product__c = Apexpages.currentPage().getParameters().get('sp');
     			ivr_Product = [select name from Support_Product__c where id=:ca.Support_Product__c].name;
     		}
     		if(Apexpages.currentPage().getParameters().get('conid') != 'null'){
     			ca.ContactId = Apexpages.currentPage().getParameters().get('conid');
     			ivr_contact= [Select name from contact where id=:ca.ContactId].name;
     		}
     	
     	isContactChosen= true;
    	conId = ca.ContactId;
    	//endUserAccName = ca.End_User_Account__c;
    	if(ca.Sold_To_Account__c!=null){
    	soldToAccName = [Select name from account where id=:ca.Sold_To_Account__c].name;
    	ivr_SoldTo = soldToAccName;
    	}
     	//if(isPortal){
     	//	ca.Is_un_entitled_Product__c = false;// Set flag to False when portal user did not find entitled product
     	//}else{
     	    ca.Is_un_entitled_Product__c = skip;// Set flag to true when user did not find entitled product
     	//}
     	
 	    if(Apexpages.currentPage().getParameters().get('sp') == 'null'){// If product is not found, create a admin case for portal user
             RecordType rt =  [SELECT DeveloperName,Id,
                                      SobjectType 
                               FROM   RecordType 
                               WHERE  DeveloperName = 'Genesys_Admin_Case' 
                                      AND SobjectType = 'Case'][0];
            ca.RecordTypeId = rt.Id;// Admin Case 
        }
  		
  		/*if(ca.RecordTypeId == null)		{
  				 RecordType rt =  [SELECT DeveloperName,Id,
                                      SobjectType 
                               FROM   RecordType 
                               WHERE  DeveloperName = 'Genesys_Product_Case' 
                                      AND SobjectType = 'Case'][0];
            ca.RecordTypeId = rt.Id;// Product Case 
  		}	*/
      
    	// displayCaseFields = true;
     	//isCaseEdit = false;	
        
        //List<Group> t3Queue = [SELECT id FROM Group WHERE Type = 'Queue' AND Name = 'Tier 2 Support'];
        //if(!t3Queue.isEmpty())
     	//	ca.OwnerId = t3Queue[0].id;
     	//insert ca;
     	
     	//return new PageReference('/'+ca.Id);
 
        
       }//Ankit modifications end here
       
        if(caseType!='Genesys_Product_Case' && caseType!='Genesys_Admin_Case' && caseType!='Genesys_Feature_Request_Case'
        && isCaseEdit == false){
            String urlToSend = '/500/e?RecordType='+ca.RecordTypeId+'&ent=Case&nooverride=1';
            PageReference p = new Pagereference(urlToSend);
            return p;
        }
        
        return null;
    }
    
    public Pagereference chooseContact(){
        conId = ca.ContactId;
        ca.End_User_Account__c = null;
        soldToAccId = null;
        soldToAccName = null;
        endUserAccId = null;
        endUserAccName = null;
        ca.Sold_To_Account__c = null;
        ca.Product_Line__c = null;
        ca.Support_Product__c = null;
        ca.Component__c = null;
        ca.Product_Version__c = null;
        prodMap =  new Map<Id,String>(); 
        
        isContactChosen = true;
        return null;
    }
        
    public List<SelectOption> prodLine {get;set;}
    
    public PageReference gtProdLine(){
        
        prodLine = new List<SelectOption>();
        //prodLine.add(new SelectOption('','None'));
        
        system.debug('--R'+ca.Support_Product__c);
        //get product map on first run - Add Products 
        
        //List<SelectOption> prodLine = new List<SelectOption>();
        if(prodMap.size()!=1){
                prodLine.add(new SelectOption('','None'));
        }
        
        if((endUserAccName == null || soldToAccName == null || endUserAccName == '' || soldToAccName == '') ){
                //return prodLine;
                return null;
        }
        
        if(endUserAccId!=null && soldToAccId!=null && isCaseEdit && isCaseEditFirstRun){
                        isCaseEditFirstRun = false;// set the boolean to false after getters and setters are loaded
                        gtProdMap();
        }
        //gtProdMap();
        
        List<Id> prodLineId = new List<Id>();
        Set<String> tmp1 = new Set<String>();
        
        if(ca.Support_Product__c != null){
            tmp1.add(ca.Support_Product__c);
        }
        Set<String> tmp2 = new Set<String>();
        
        if(ca.Product_Line__c != null){
            tmp2.add(ca.Product_Line__c);
        }
        
        List<Product_Mapping__c> proMapList = CreateCustPortalCaseExtnWithoutSharing.queryProductMappingAll(prodToNameMap.keySet(),tmp1,tmp2);

        prodLineMap = new Map<Id,String>();
        prodLineId = new List<Id>();
        
        if(proMapList!=null){
            
            for(Product_Mapping__c pm: proMapList){
                prodLineId.add(pm.Product__r.Parent_Product__c);
            }            
        }
        List<Support_Product__c> supportProdList = CreateCustPortalCaseExtnWithoutSharing.querySupportProduct(prodLineId);  
            
        if(supportProdList!=null){
            
            for(Support_Product__c sp:supportProdList){
                prodLineMap.put(sp.Id,sp.Name);// Product Line Items
            }
        }   
        
        for(String prodLnId :prodLineMap.keySet()){
            prodLine.add(new SelectOption(prodLnId,prodLineMap.get(prodLnId)));
        }
        
        return null;
    }
    /*
        getter : getProds
        Usage  : Get product based on the End User and Sold To combination
    */
    public List<SelectOption> getProds() {
                
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','None'));
        
        if(!isContactChosen || (endUserAccId == null || soldToAccId == null) ){
                return options;
        }
        
        system.debug('--R2'+ca.Product_Line__c);
        List<Id> prodLineId = new List<Id>();
        Set<String> tmp1 = new Set<String>();
        if(ca.Support_Product__c != null){
            tmp1.add(ca.Support_Product__c);
        }
        
        Set<String> tmp2 = new Set<String>();
        
        if(ca.Product_Line__c != null){
            tmp2.add(ca.Product_Line__c);
        }
        List<Product_Mapping__c> proMapList = CreateCustPortalCaseExtnWithoutSharing.queryProductMappingAll(prodToNameMap.keySet(),tmp1,tmp2);

        prodMap = new Map<Id,String>();
        
        if(proMapList!=null){
            
            for(Product_Mapping__c pm: proMapList){
                prodMap.put(pm.Product__c,pm.Product__r.Name);// Product Names
            }
        }
        
        if(soldToAccId!=null || soldToAccId!=null){

            for(Id prod :prodMap.keySet()){
                options.add(new SelectOption(prod,prodMap.get(prod)));
                    
            }
            
        }
        system.debug('--options'+options);
        return options;
    }
    
    public List<SelectOption> components {get;set;}
    
    public Pagereference gtComponents(){
        components = new List<SelectOption>();
        components.add(new SelectOption('','None'));
        system.debug('In gtcomponents'+ prodMap);
        if(ca.Support_Product__c != null){
                for(Support_Product__c sp: CreateCustPortalCaseExtnWithoutSharing.querySupportProdComponent(new set<Id> {ca.Support_Product__c})){
                    components.add(new SelectOption(sp.Id,sp.Name));
                }
        }
        
        gtProdLine();
        return null;
         
    }
    
    public List<SelectOption> versions {get;set;}
    
    public Pagereference gtVersions(){
        versions = new List<Selectoption>();
        versions.add(new SelectOption('','None'));

        system.debug('--ca.Support_Product__c'+ca.Support_Product__c);
        
        if(ca.Component__c!=null){
            
            for(Product_Version__c vr: CreateCustPortalCaseExtnWithoutSharing.queryCompVersion(ca.Component__c)){
              system.debug('--vr'+vr);
              versions.add(new SelectOption(vr.Id,vr.Name));
            }
        }
        return null;
    }

    public Pagereference prNtFnd(){
        
        if(!validateFields()){
        	if(!isPortal){
                skip = false;
                dontSkipFirstScreen = true;
        	}
            return null;
        }
        
        if(!isPortal){
        	prodFnd = true;
        	loadAllFilter();
        	return null;
        }
        
        prodFnd = false;
        return null;
        
    }
    
    public void loadAllFilter(){
        
        
    	Set<Id> endUsrSet = new Set<Id>();
    	Set<Id> soldToUsrSet = new Set<Id>();
    	serviceContractIds = new Set<Id>();
    	for( Support_Access__c sas :[SELECT End_User_Account__c, Sold_To_Account__c,
    	                                    service_contract__c 
                                     FROM   Support_Access__c 
                                     WHERE  Contact__c =:conId 
                                            and Support_Blocked__c=false and 
                                            SR_Access_Level__c = 'Read/Write' and
                                            Maintenance_Terminated_Flag__c=false ]){
            
            soldToUsrSet.add(sas.Sold_To_Account__c);
            endUsrSet.add(sas.End_User_Account__c);    
	        if(sas.service_contract__c!=null){
                serviceContractIds.add(sas.service_contract__c);
	        }                                       	
        }
        List<Id> prodLineId = new List<Id>();
            
        List<ContractLineItem> contrLineItemList = CreateCustPortalCaseExtnWithoutSharing.queryContractLineItem(serviceContractIds);
        
        if(contrLineItemList!=null){
            
            for(ContractLineItem c:contrLineItemList){
                prodToNameMap.put(c.PricebookEntry.Product2Id,c.PricebookEntry.Name);               
            }
            
        } 
        
        List<Product_Mapping__c> proMapList = CreateCustPortalCaseExtnWithoutSharing.queryProductMapping(prodToNameMap.keySet());
        
        resetFilters();
        gtComponents();
        gtVersions();
        
    }
    
    /*
        Method : ValidateFields 
        Usage  : This method will not let the user to move to the next standard create case page 
                 without choosing the End User and Sold To Accounts.
    */
    public boolean validateFields(){
        
        if(ca.ContactId == null && !isPortal){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Contact is required'));
            return false;
        }
        
        if(endUserAccId == null && !(!isPortal && !isCaNonAdmin)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'End User Account is required'));
            return false;
        }
        
        if(soldToAccId == null && !(!isPortal && !isCaNonAdmin)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Sold To Account is required'));
            return false;
        }
        system.debug('--isCaNonAdmin'+isCaNonAdmin+' prodFnd' +prodFnd + ' ca.Support_Product__c'+ca.Support_Product__c);
        
        if((isCaNonAdmin && prodFnd && ca.Support_Product__c == null && (!skip || (!isPortal && dontSkipFirstScreen) ) )){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Product is required'));
            return false;
        }
        
        return true;
    }
    
    public boolean validateChangeProd(){
    	if(endUserAccId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'End User Account is required'));
            return false;
        }
        
        if(soldToAccId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Sold To Account is required'));
            return false;
        }
        
        if(ca.Support_Product__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Product is required'));
            return false;
        }
        
        return true;
    }
    
    public Pagereference resetFilters(){
        
        ca.Product_Line__c = null;
        ca.Support_Product__c = null;
        ca.Component__c = null;
        ca.Product_Version__c = null;
        prodMap =  new Map<Id,String>(); 
        prodLine = new List<Selectoption>();
        gtProdLine();
        
        return null;
    }
    
    /*
        Method : next
        Usage  : Create the Case URL to prepopulate the chosen values Portal Case Select Type Page 
    */
    public Pagereference next(){
        System.debug('NKC debug IN NEXT');
        if(!validateFields()){
            return null;
        }
        
        List<Support_Access__c> spList = [SELECT Id,Name FROM Support_Access__c WHERE End_User_Account__c =:endUserAccId  AND Sold_To_Account__c =: soldToAccId and Contact__c =:conId];

        if(isContactChosen){
            if(spList !=null && spList.size()>0) ca.Support_Access__c = spList[0].Id;
            displayCaseFields = true;        	    
        }        
        system.debug('--prodFnd'+prodFnd);
		
        return null;
    }
    public Pagereference next1(){
    	if(!validateFields()){
            return null;
        }        
        List<Support_Access__c> spList = [SELECT Id,Name FROM Support_Access__c WHERE End_User_Account__c =:endUserAccId  AND Sold_To_Account__c =: soldToAccId and Contact__c =:conId];

        if(isContactChosen){
            if(spList !=null && spList.size()>0) ca.Support_Access__c = spList[0].Id;
            displayCaseFields = true;
            
        }        
        if(displayCaseFields && isFeatureRequestCase){
			String params = '&page=2&eu=' + ca.End_User_Account__c + '&sto='+ca.Sold_To_Account__c + '&pl='+ca.Product_Line__c + '&cm='+ca.Component__c+'&pv='+ca.Product_Version__c + '&sp=' + ca.Support_Product__c;
			String recordType = Apexpages.currentPage().getParameters().get('RecordType');
			String url = '/apex/PortalNewFRCase?RecordType=' + recordType + params;    		
    		return new PageReference(url); 				
		}
		return null;
    }
    
    public Pagereference saveProdChange(){
        
        if(!validateChangeProd()){
            isProdChangeValid = false;
            return null;
        }
        
        isProdChangeValid = true;
        ca.Is_un_entitled_Product__c = skip;// Set flag to true when user did not find entitled product
        update ca;
       
        if(isInConsole){
            return new Pagereference('/' +ca.Id + '?isdtp=vw&isWsVw=true');
        }
        return new Pagereference('/' +ca.Id);
    }
    
    public Pagereference cancelProdChange(){
        isProdChangeValid = true;
        if(isInConsole){
            return new Pagereference('/' +ca.Id + '?isdtp=vw&isWsVw=true');
        }
        return new Pagereference('/' +ca.Id);
    }
    
    public Pagereference cancelCaseCreation(){
    	String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL != null){
            return new PageReference(retURL);
        }else{
        	return new PageReference('/500/o');// Service Console doesn't consist return url
        }
    }
    
    public Pagereference saveCase(){
    	if(Apexpages.currentPage().getParameters().get('page') != null && Apexpages.currentPage().getParameters().get('page') == '2'){
     		ca.RecordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
     		if(Apexpages.currentPage().getParameters().get('eu') != 'null')
     			ca.End_User_Account__c = Apexpages.currentPage().getParameters().get('eu');
     		if(Apexpages.currentPage().getParameters().get('sto') != 'null')
     			ca.Sold_To_Account__c = Apexpages.currentPage().getParameters().get('sto');
     		if(Apexpages.currentPage().getParameters().get('pl') != 'null')
     			ca.Product_Line__c = Apexpages.currentPage().getParameters().get('pl');
     		if(Apexpages.currentPage().getParameters().get('cm') != 'null')
     			ca.Component__c = Apexpages.currentPage().getParameters().get('cm');
     		if(Apexpages.currentPage().getParameters().get('pv') != 'null')
     			ca.Product_Version__c = Apexpages.currentPage().getParameters().get('pv');
     		if(Apexpages.currentPage().getParameters().get('sp') != 'null')
     			ca.Support_Product__c = Apexpages.currentPage().getParameters().get('sp');
     		ca.Description = ca.Feature_Description__c;
     		ca.Feature_Description__c = null;
     	}
     	if(isPortal && !isFeatureRequestCase && ca.Priority == null){
     		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Priority is required'));
     		return null;
     	}
     	
     	if(isPortal){
     		ca.Is_un_entitled_Product__c = false;// Set flag to False when portal user did not find entitled product
     	}else{
     	    ca.Is_un_entitled_Product__c = skip;// Set flag to true when user did not find entitled product
     	}
     	
 	    if(!prodFnd && isPortal){// If product is not found, create a admin case for portal user
             RecordType rt =  [SELECT DeveloperName,Id,
                                      SobjectType 
                               FROM   RecordType 
                               WHERE  DeveloperName = 'Genesys_Admin_Case' 
                                      AND SobjectType = 'Case'][0];
            ca.RecordTypeId = rt.Id;// Admin Case 
        }
  		
        
        //List<Group> t3Queue = [SELECT id FROM Group WHERE Type = 'Queue' AND Name = 'Tier 2 Support'];
        //if(!t3Queue.isEmpty())
     	//	ca.OwnerId = t3Queue[0].id;
     	insert ca;
     	
     	return new PageReference('/'+ca.Id);
    }  
    public boolean displayPopup {get; set;}     
    
     public void closePopup() {        
         displayPopup = false;    
     }
             
     public void showPopup() {        
         displayPopup = true;    
     }  
}