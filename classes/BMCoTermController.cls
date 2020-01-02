public without sharing class BMCoTermController {
   
    public Account endUserAcc {get
        
                                { 
                                	/* system.debug(endUserAcc.Name);
                                    if(endUserAcc==null && (endUserAcc.Name!='' || endUserAcc.Name!=null)){
                                    List<Account> accts = [Select Id, Name from Account where Name Like :endUserAcc.Name];
                                    if(accts.size() == 1)
                                        endUserAcc = accts[0];
                                        system.debug(endUserAcc);
                                  } */
                                 return endUserAcc;
                                }
                                set;}
    public Account soldToAcc {get
                                { /* if(soldToAcc==null && (soldToAcc.Name!='' || soldToAcc.Name!=null)){
                                    List<Account> accts = [Select Id, Name from Account where Name Like :soldToAcc.Name];
                                    if(accts.size() == 1)
                                        soldToAcc = accts[0];
                                        system.debug(soldToAcc);
                                  } */
                                 return soldToAcc;
                                }
                                set;}
    
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    Boolean blnIsPageLoad;
                               
    public String sortExpression
    {
        get { return sortExp;}
        set{
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
    }

    public void setSortDirection(String value)
    {  
       sortDirection = value;
    }
    
    public string fields {get{
                                return 'Id,Name,SAP_Account_Code__c';}
                           set;}
                           
    final Integer pageSize = 10;
    Set<Id> oppIds ;
    public String getbaseQuery (){
        //Renewal_Opportunity__r
            String baseQuery = 'SELECT Service_Contract_Type__c,Order__r.Quote__c,Order__r.Quote__r.BigMachines__Opportunity__c, Order__r.Opportunity__c, Order__r.Opportunity__r.Name, Renewal_Opportunity__r.RecordType.Name, Renewal_Opportunity__r.RecordTypeId, '+ 
                                  'Order__r.Opportunity__r.Co_Term_Opportunity__c,'+
                                  'Id, Name, End_User_Name__c,'+ 
                                  'Sold_To_Name__c, StartDate, Order__c, '+
                                  'Agreement_Number__c, PO_Number__c,' + 
                                  'Sales_Org__c, Japan_Invoice__c, Sold_To_Name__r.Name, '+
                                  'Status, Support_Owner__c, System_Integrator__c, Support_Owner__r.Name, ' +
                                  'Billing_Date__c, Maintenance_Amount__c, '+
                                  'Big_Six__c, Agreement_Status__c, SG2_Region__c, VSOE_Segment__c, '+
                                  'EndDate, Quote__c, Quote_Name__c,Quote_Name__r.Name, Renewal_Opportunity__r.BusinessPartner__c, Renewal_Opportunity__r.AccountId, '+
                                  'Co_Term_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__c, '+
                                  'Opp_Status__c ' +
                          		'FROM ServiceContract ' +
                          		'WHERE Renewal_Opportunity__c != NULL AND '+ 
	                            'Agreement_Status__c != \'Pending\' ' +
                				// Following line is added by RAO to exclude PPU & Evaluation Type Service contracts from Co-Term Process
                		  		'AND Service_Contract_Type__C != \'PPU\' AND Service_Contract_Type__C !=  \'Evaluation\' ' ;                           
                            
        return baseQuery;
    }
    
    public String query {
        get {
            List <ServiceContract> tempServiceContract = getCoTermServiceContracts();
            String scIdStr = '';
 
              for(ServiceContract scId:tempServiceContract)
                scIdStr+= '\''+ scId.id + '\''+ ',';
              scIdStr+= '\''+  '\'';
              String oppIdStr = '';
             
              for(Id oppId : oppIds)
               oppIdStr+= '\''+ oppId + '\''+ ',';
             
                oppIdStr = oppIdStr.substring(0, oppIdStr.length()-1);
                // To sort by end date when page loads
                string sortFullExp;
                if(blnIsPageLoad)
                    sortFullExp = 'EndDate DESC NULLS LAST';
                else
                    sortFullExp = sortExpression  + ' ' + sortDirection; 
                query = getbaseQuery() ;
                 system.debug(soldToAcc);                
              
                if(quo.Search_Quote__c == null && soldToAcc != null && soldToAcc.Name!='' && soldToAcc.Name!=null)
                  query+= ' and Sold_To_Name__c= \'' + soldToAcc.Id +'\'';
                  system.debug(endUserAcc);
                if(quo.Search_Quote__c == null && endUserAcc != null && endUserAcc.Name!='' && endUserAcc.Name!=null)
                   query +=' and End_User_Name__c = \'' + endUserAcc.Id +'\'';
                if(quo.Search_Quote__c != null){
                   //Quote selectedQuote = [SELECT id FROM Quote WHERE QuoteNumber =: quo.Search_Quote__c];
                   query +=' and Id in ( SELECT Service_Contract__c FROM Quote_Service_Contracts__c WHERE Quote__c = \'' + quo.Search_Quote__c +'\') ';
                }
               
                query+= ' and Id NOT IN ('+ scIdStr +')' +
                        ' and Id NOT IN ('+ oppIdStr +')'+
                        ' order by ' + sortFullExp +
                        ' LIMIT 100' ;
                                system.debug('NK debug [' + query + ']');
                return query;
        }
        set;
    }                  
       
    public Pagination p {
        get {
            if(p == null && endUserAcc!=null && soldToAcc!=null) {
                system.debug(p);
                 p = new Pagination(query, pageSize);
            }
            return p;
        }
        set;
    }
    
    public pageReference findRelatedRecords(){
        getbaseQuery();
        p = new Pagination(query, pageSize);
        p.getWrappers();
        return null;
    }
    public List<Util.Wrappers> coTermedSCs {get;set;}
    
   public List<ServiceContract> getCoTermServiceContracts() {
     List <ServiceContract> tempServiceContract = new List<ServiceContract>();
          ServiceContract serviceCont = null;
          List <Quote_Service_Contracts__c> tempQuote = [select Service_Contract__c from Quote_Service_Contracts__c where Quote__c = :quo.id order by CreatedDate desc];
          
          if(!tempQuote.isEmpty()) {
           for(Quote_Service_Contracts__c tempsc:tempQuote) {
             if(tempsc.Service_Contract__c != null){
                serviceCont = [SELECT id from ServiceContract where id=:tempsc.Service_Contract__c];
                tempServiceContract.add(serviceCont);
             }
            }
          }
       return tempServiceContract;
    
   }
    
    public List<Util.Wrappers> getCoTermedScs() {
        system.debug('in here');
         
         List <ServiceContract> tempServiceContract = getCoTermServiceContracts();
            
            if(coTermedScs== null || (endUserAcc!=null && soldToAcc!=null)){
                String q = getbaseQuery() +  ' and id in: tempServiceContract';
                                        //  ' and Id !=\'' + opp.Id + '\''
                                        
                system.debug(q);
                coTermedScs = new List<Util.Wrappers>();
                for(ServiceContract sc: Database.query(q)){
                    coTermedScs.add(new Util.Wrappers(sc));
                }
            }
            return coTermedScs;
    }
    
    public List<Util.Wrappers> selectedWrappers {get;set;}
    
    public List<Util.Wrappers> getselectedWrappers() {
        if(selectedWrappers == null)
        selectedWrappers = new List<Util.Wrappers>();
        for(Util.Wrappers w : p.wrappers) {
            if(w.isSelected) {
                w.isMoved=true;
                selectedWrappers.add(w);
            }
        }
        return selectedWrappers;
    }
    
    
    public Opportunity opp {get;set;}
    public Boolean selected {get; set;}
    public BigMachines__Quote__c quo {get;set;}
    public String parentOppId {get;set;}
    
    public BMCoTermController (ApexPages.StandardController stdController) {
        blnIsPageLoad = true;
        if(opp == null) {
            quo =(BigMachines__Quote__c)stdController.getRecord();
            quo = [SELECT BigMachines__Opportunity__c,Name,search_quote__c from  BigMachines__Quote__c where id=:quo.id];
            
           
            oppIds = new Set<Id>();
            opp = [Select Id, Name, AccountId, Account.Name, RecordType.Name, BusinessPartner__c, BusinessPartner__r.Name 
                   from Opportunity 
                   where Id =:quo.BigMachines__Opportunity__c];
            endUserAcc = new Account( Id = opp.AccountId, Name = opp.Account.Name );
            soldToAcc = new Account( Id = opp.BusinessPartner__c ,Name = opp.BusinessPartner__r.Name );
            oppIds.add(opp.Id);
        }
        p.getWrappers();
        getCoTermedScs();
        if(ApexPages.currentPage().getParameters().get('oppId') != null){
            parentOppId = ApexPages.currentPage().getParameters().get('oppId');
        }
        
    }
    
    public PageReference submit() {
        Set<ServiceContract> scsToUpdate = new Set<ServiceContract>();
        Set<Util.Wrappers> unCotermedWrappers = new Set<Util.Wrappers>();
        for(Util.Wrappers w : selectedWrappers) {
//            if(w.isSelected ){
            if(w.isSelected && w.isMoved){
                 ServiceContract sc = (ServiceContract) w.obj;
               // oppIds.remove(sc.Id);
                sc.Co_Term_Opportunity__c = opp.Id;
                scsToUpdate.add(sc);
            }else
                unCotermedWrappers.add(w);
        }
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        List<Quote_Service_Contracts__c> quoteToUpdate = new List<Quote_Service_Contracts__c>();
        
        if(!scsToUpdate.isEmpty()){
            for(ServiceContract sc : scsToUpdate){
                //o.Co_Term_Opportunity__c = opp.Id;
             // scsToUpdate.add(new ServiceContract(Id=sc.Id, Co_Term_Opportunity__c = opp.Id));
                //if(sc.Renewal_Opportunity__c != null)
                //if(sc.Order__r.Opportunity__c != null)
                // oppsToUpdate.add(new Opportunity(Id=sc.Order__r.Opportunity__c, Co_Term_Opportunity__c = opp.Id));
                //if(sc.Renewal_Opportunity__c != null)
                  //  oppsToUpdate.add(new Opportunity(Id=sc.Renewal_Opportunity__c, StageName='13.Closed-Co-termed'));
             
               quoteToUpdate.add(new Quote_Service_Contracts__c(Name=sc.id,Quote__c = quo.id,Service_Contract__c=sc.id,Service_Contract_ID__c = sc.id) );
            
            
            }
            List<ServiceContract> scs = new List<ServiceContract>();
            scs.addAll(scsToUpdate);
            system.debug(scs);
            if(!scs.isEmpty())
                update scs;
            system.debug(oppsToUpdate);
            if(!oppsToUpdate.isEmpty())
                update oppsToUpdate;
            if(!quoteToUpdate.isEmpty())
                upsert quoteToUpdate; 
                
            ServiceContractUtil.updateContractlineItems(scs, true);
            p.getWrappers();
            selectedWrappers.clear();
            selectedWrappers.addAll(unCotermedWrappers);
            getCoTermedScs();
        }
        return null;
    }
    
    public PageReference cancel(){
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null)
            return new PageReference('/'+quo.Id);
        else
            return new PageReference(retURL);
    }
    
    public PageReference includeOpps(){
        List<ServiceContract> scs = new List<ServiceContract>();
        getSelectedWrappers();
        for(Util.Wrappers w : p.wrappers) {
            if(w.isSelected) {
                scs.add(( ServiceCOntract )w.obj);
                oppIds.add(w.obj.Id);
            }
            
        }
        p.setCon.setSelected(scs);
        p = new Pagination(query, pageSize);
        p.getWrappers();
        return null;
    }
    
    public PageReference selectAll(){
        for(Util.Wrappers w : p.wrappers) {
            w.isSelected=selected;
        }
        return null;
    }
    
    public PageReference removeCoTermedScs(){
        List<ServiceContract> scsToUpdate = new List<ServiceContract>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Quote_Service_Contracts__c> coTermDelete = new List<Quote_Service_Contracts__c>();
        Quote_Service_Contracts__c delSc = null;
        for(Util.Wrappers w : coTermedScs){
            if(w.isSelected)
            {
                ServiceContract sc = (ServiceContract) w.obj;
                oppIds.remove(sc.Id);
                delSc = [Select id from Quote_Service_Contracts__c where Service_Contract__c =:sc.id limit 1];
                
                if(delSc != null)
                 coTermDelete.add(delSc);
                
                //sc.Co_Term_Opportunity__c = null;
                //scsToUpdate.add(sc);
                //oppsToUpdate.add(new Opportunity(Id=sc.Renewal_Opportunity__c, Co_Term_Opportunity__c = null));
            }
        }
                
        system.debug(opp.Id);
        try{
            if(!scsToUpdate.isEmpty())
                update scsToUpdate;
             if(!scsToUpdate.isEmpty())
                update oppsToUpdate;
             if(!coTermDelete.isEmpty()) 
                delete coTermDelete;
        }catch(DmlException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Error removing cotermed opps - ' + ex.getMessage()));
        }
        system.debug(opp.Id);
        p = new Pagination(query, pageSize);
        p.getWrappers();
        getCoTermedScs();
        return null;
    }
    
}