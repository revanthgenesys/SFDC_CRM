public class CoTermProcessController {
    
    public Account endUserAcc {get
        
                                { system.debug(endUserAcc.Name);
                                    if(endUserAcc==null && (endUserAcc.Name!='' || endUserAcc.Name!=null)){
                                    List<Account> accts = [Select Id, Name from Account where Name Like :endUserAcc.Name];
                                    if(accts.size() == 1)
                                        endUserAcc = accts[0];
                                        system.debug(endUserAcc);
                                  }
                                 return endUserAcc;
                                }
                                set;}
    public Account soldToAcc {get
                                { if(soldToAcc==null && (soldToAcc.Name!='' || soldToAcc.Name!=null)){
                                    List<Account> accts = [Select Id, Name from Account where Name Like :soldToAcc.Name];
                                    if(accts.size() == 1)
                                        soldToAcc = accts[0];
                                        system.debug(soldToAcc);
                                  }
                                 return soldToAcc;
                                }
                                set;}
    
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
                               
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
            String baseQuery = 'Select Order__r.Opportunity__c, Order__r.Opportunity__r.Name, Renewal_Opportunity__r.RecordType.Name, Renewal_Opportunity__r.RecordTypeId, '+
            						//Renewal_Opportunity__r.ParentOpportunity__c, 
                                  'Order__r.Opportunity__r.Co_Term_Opportunity__c,'+
                                  'Id, Name, End_User_Name__c,'+ 
                                  'Sold_To_Name__c, StartDate, Order__c, '+
                                  'Agreement_Number__c, PO_Number__c,' + 
                                  'Sales_Org__c, Japan_Invoice__c, Sold_To_Name__r.Name, '+
                                  'Status, Support_Owner__c, System_Integrator__c, Support_Owner__r.Name, ' +
                                  'Billing_Date__c, Maintenance_Amount__c, '+
                                  'Big_Six__c, Agreement_Status__c, SG2_Region__c, VSOE_Segment__c, '+
                                  'EndDate, Quote__c, Quote_Name__c,Quote_Name__r.Name, Renewal_Opportunity__r.BusinessPartner__c, Renewal_Opportunity__r.AccountId, '+
                                  'Co_Term_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__c '+
                          'from ServiceContract ' +
                          
                          'where '+ //Renewal_Opportunity__c != \'\' and ' +
                          'Agreement_Status__c != \'Pending\'  ' ;                           
                            
        return baseQuery;
    }
    
    public String query {
        get {
            String oppIdStr = '';
                for(Id oppId : oppIds)
                    oppIdStr+= '\''+ oppId + '\''+ ',';
                oppIdStr = oppIdStr.substring(0, oppIdStr.length()-1);
                string sortFullExp = sortExpression  + ' ' + sortDirection; 
                query = getbaseQuery() ;
                 system.debug(soldToAcc);
                if(soldToAcc != null && soldToAcc.Name!='' && soldToAcc.Name!=null)
                  query+= ' and Sold_To_Name__c= \'' + soldToAcc.Id +'\'';
                  system.debug(endUserAcc);
                if(endUserAcc != null && endUserAcc.Name!='' && endUserAcc.Name!=null)
                   query +=' and End_User_Name__c = \'' + endUserAcc.Id +'\'';
                query+= ' and Co_Term_Opportunity__c != \'' + opp.Id + '\'' +  
                        ' and Id NOT IN ('+ oppIdStr +')'+
                        ' order by ' + sortFullExp +
                        ' LIMIT 100' ;
                                system.debug(query);
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
    
    public List<Util.Wrappers> getCoTermedScs() {
        system.debug('in here');
            if(coTermedScs== null || (endUserAcc!=null && soldToAcc!=null)){
                String q = getbaseQuery() +  ' and Co_Term_Opportunity__c = \'' + opp.Id + '\'' ;
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
    
    
    public CoTermProcessController (ApexPages.StandardController stdController) {
        if(opp == null) {
            oppIds = new Set<Id>();
            opp = [Select Id, Name, AccountId, Account.Name, RecordType.Name, BusinessPartner__c, BusinessPartner__r.Name 
                   from Opportunity 
                   where Id =:(Id)(stdController.getRecord()).Id][0];
            endUserAcc = new Account( Id = opp.AccountId, Name = opp.Account.Name );
            soldToAcc = new Account( Id = opp.BusinessPartner__c ,Name = opp.BusinessPartner__r.Name );
            oppIds.add(opp.Id);
        }
        p.getWrappers();
        getCoTermedScs();
        
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
        if(!scsToUpdate.isEmpty()){
            for(ServiceContract sc : scsToUpdate){
                //o.Co_Term_Opportunity__c = opp.Id;
             // scsToUpdate.add(new ServiceContract(Id=sc.Id, Co_Term_Opportunity__c = opp.Id));
                //if(sc.Renewal_Opportunity__c != null)
                if(sc.Order__r.Opportunity__c != null)
                    oppsToUpdate.add(new Opportunity(Id=sc.Order__r.Opportunity__c, Co_Term_Opportunity__c = opp.Id));
                if(sc.Renewal_Opportunity__c != null)
                    oppsToUpdate.add(new Opportunity(Id=sc.Renewal_Opportunity__c, StageName='13.Closed-Co-termed'));
            }
            List<ServiceContract> scs = new List<ServiceContract>();
            scs.addAll(scsToUpdate);
            system.debug(scs);
            if(!scs.isEmpty())
                update scs;
            system.debug(oppsToUpdate);
            if(!oppsToUpdate.isEmpty())
                update oppsToUpdate;
                
            ServiceContractUtil.updateContractlineItems(scs, true);
            p.getWrappers();
            selectedWrappers.clear();
            selectedWrappers.addAll(unCotermedWrappers);
            getCoTermedScs();
        }
        return null;
    }
    
    public PageReference cancel(){
        return new PageReference('/'+opp.Id);
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
        for(Util.Wrappers w : coTermedScs){
            if(w.isSelected)
            {
                ServiceContract sc = (ServiceContract) w.obj;
                oppIds.remove(sc.Id);
                sc.Co_Term_Opportunity__c = null;
                scsToUpdate.add(sc);
                oppsToUpdate.add(new Opportunity(Id=sc.Renewal_Opportunity__c, Co_Term_Opportunity__c = null));
            }
        }
        system.debug(opp.Id);
        try{
            if(!scsToUpdate.isEmpty())
                update scsToUpdate;
             if(!scsToUpdate.isEmpty())
                update oppsToUpdate;
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