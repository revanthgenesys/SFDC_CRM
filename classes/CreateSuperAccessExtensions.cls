public class CreateSuperAccessExtensions {
    public Id contactId{get;set;}
    public Support_Access__c supportAccess {get; set;}
    public Boolean showInactive {get;set;}
    public Boolean isSrvContractPg {get;set;} 
    public String servContractId; 
 
    
    public Boolean isContactIdNull {
            get{
                return ((contactId == null) && (supportAccess.Id ==null));}
            set;}
    public List<Util.Wrappers> scs {get;set;}
    public String endUserAccName {get{
        if(endUserAccName == '' || endUserAccName == null) endUserAccId = null;
                        return endUserAccName;} set;}
    public String endUserAccId {get{
                                if(endUserAccName!=''){
                                    List<ServiceContract> scs = [Select End_User_Name__c, End_User_Name__r.Name 
                                                                 from ServiceContract 
                                                                 where End_User_Name__r.Name Like :endUserAccName 
                                                                 and (Agreement_Status__c = 'Active' or Agreement_Status__c = 'Pending' or Agreement_Status__c = 'In Negotiation')];
                                    if(scs.size() == 1)
                                        endUserAccId = scs[0].End_User_Name__c;
                                }
                                return endUserAccId;
                                } set;}
                                
    public string soldToAccName {get{
                        if(soldToAccName == '' || soldToAccName == null) soldToAccId = null;
                        return soldToAccName;
                        }set;}
    public String soldToAccId {get{
                                  if(soldToAccName != ''){
                                    List<ServiceContract> scs = [Select Sold_To_Name__c, Sold_To_Name__r.Name  
                                                                 from ServiceContract 
                                                                 where Sold_To_Name__r.Name Like :soldToAccName
                                                                 and (Agreement_Status__c = 'Active' or Agreement_Status__c = 'Pending' or Agreement_Status__c = 'In Negotiation')];
                                    if(scs.size() == 1)
                                        soldToAccId = scs[0].Sold_To_Name__c;
                                  }
                                  return soldToAccId;
                                }set;}
    
    public Boolean hasServiceContracts{get;private set;}
    public string fields {get{
                                return 'Id,Name,City__c,StateProvince__c,Country__c';}
                           set;}
    public List<Account> accounts {get;set;}
    
    public string query {get{
        if( null == query || ''.equals(query) ) {
            query = ' and (Agreement_Status__c=\'Active\' or Agreement_Status__c=\'Pending\' or Agreement_Status__c = \'In Negotiation\') ';
        }
        return query;
    }
    set;}
    
    public CreateSuperAccessExtensions(ApexPages.StandardController con){
        supportAccess = (Support_Access__c) con.getRecord();
        isSrvContractPg = false;
        String urlId = ApexPages.currentPage().getParameters().get('contactId');
        servContractId = ApexPages.currentPage().getParameters().get('retURL');
        
        system.debug('--servContractId'+servContractId);
                    
        if(servContractId != null){
            servContractId = servContractId.remove('/');
            String keyCode  = servContractId.subString(0,3);

            if (keyCode == ServiceContract.sObjectType.getDescribe().getKeyPrefix()){
               isSrvContractPg = true;
               ServiceContract sc = [SELECT End_User_Name__c,  Sold_To_Name__c, End_User_Name__r.Name, 
                                            Sold_To_Name__r.Name 
                                     FROM   ServiceContract
                                     WHERE  id = :servContractId][0];
                soldToAccName = sc.Sold_To_Name__r.Name;
                soldToAccId = sc.Sold_To_Name__c;
                endUserAccName = sc.End_User_Name__r.Name;
                endUserAccId = sc.End_User_Name__c;                                
            }
            
        }
        
        if(urlId != null && urlId != ''){
            contactId = urlId;
            supportAccess = new Support_Access__c();
            supportAccess.contact__c = contactId;
        }else if(supportAccess.Id != null){
            supportAccess = [Select Id, End_User_Account__c, Sold_To_Account__c, Sold_To_Account__r.Name, 
                                    System_Integrator__c, System_Integrator__r.Name, End_User_Account__r.Name, Support_Blocked__c,
                                    Support_Owner__c, Support_Owner__r.Name, Contact_Role__c, Status__c, contact__c, 
                                    Expiration_Date__c, Maintenance_Terminated_Flag__c, SR_Access_Level__c, Status_Comment__c, Case_Number__c
                             from Support_Access__c where Id =:supportAccess.Id];
            endUserAccName =supportAccess.End_User_Account__r.Name;
            endUserAccId = supportAccess.End_User_Account__c;
            soldToAccId = supportAccess.Sold_To_Account__c;
            soldToAccName = supportAccess.Sold_To_Account__r.Name;

            getServiceContracts();
        }else{
            
        }
            
    }
    
    
    public pageReference next(){
        contactId = supportAccess.Contact__c;
        if(isSrvContractPg){
            getServiceContracts();
        }
        return null;
    }
    
   
    public Pagereference getServiceContracts(){
        scs = new List<Util.Wrappers>();
        if(contactId == null && supportAccess.Id != null){
            for(Support_Access__c sa : [Select Id, Service_Contract__c, Service_Contract__r.Name, Service_Contract__r.End_User_Name__c,
                                               Service_Contract__r.Sold_To_Name__c, Service_Contract__r.Agreement_Status__c, 
                                               Service_Contract__r.StartDate, Service_Contract__r.EndDate, Service_Contract__r.Service_Contract_Type__c 
                                          from Support_Access__c 
                                          where Id=:supportAccess.Id]){
                        Util.Wrappers w = new Util.Wrappers(new ServiceContract( Id= sa.Service_Contract__c, Name=sa.Service_Contract__r.Name, 
                                                                       End_User_Name__c = sa.Service_Contract__r.End_User_Name__c, 
                                                                       Agreement_Status__c = sa.Service_Contract__r.Agreement_Status__c, 
                                                                       StartDate = (Date)sa.Service_Contract__r.StartDate, EndDate = (Date)sa.Service_Contract__r.EndDate,
                                                                       Service_Contract_Type__c = sa.Service_Contract__r.Service_Contract_Type__c ));
                                                                       
                        w.isSelected= true;
                        scs.add(w);                         
                }
        }
        else{
            String baseQuery = 'Select Id, Name, End_User_Name__c,Sold_To_Name__c, Agreement_Status__c, StartDate, EndDate, Service_Contract_Type__c '+
                                       ', (Select Id, Contact__c From Support_Access__r where Contact__c =:contactId) from ServiceContract'+
                                       //' from ServiceContract'+
                                       ' where End_User_Name__c = :endUserAccId and Sold_To_Name__c = :soldToAccId';
            if(isSrvContractPg){
                baseQuery += ' and Id=:servContractId';
            }
            system.debug('--baseQuery'+baseQuery);
            if(endUserAccId != null && soldToAccId != null){
                String query ='';
                if( !showInactive )
                    query =  baseQuery + ' and (Agreement_Status__c=\'Active\' or Agreement_Status__c=\'Pending\' or Agreement_Status__c = \'In Negotiation\')';
                else query = baseQuery;
                system.debug(query);
                for(ServiceContract sc : Database.query( query )){
                    if(sc.Support_Access__r == null || sc.Support_Access__r.isEmpty())
                        scs.add(new Util.Wrappers(sc));                         
                }
            }
        }
        if(!scs.isEmpty()) hasServiceContracts = true;
        else 
            if( soldToAccId != null && endUserAccId != null) 
                Apexpages.addMessage( new Apexpages.Message( Apexpages.Severity.ERROR, 'You already have access for all Active / Pending Service Contracts for this combination.') );
        return null;
    }
    
    public PageReference save(){
        List<Support_Access__c> sasToInsert = new List<Support_Access__c>();
        if( scs!=null ){
            for(Util.Wrappers w : scs){
                if(w.isSelected){
                    Support_Access__c sa ;
                    ServiceContract sc = (ServiceContract)w.obj;
                    // in edit page
                    if(contactId == null)
                        sa = new Support_Access__c(Id = supportAccess.Id);
                    else{ 
                        sa = new Support_Access__c();
                        sa.Contact__c = supportAccess.Contact__c;
                    }
                    sa.Status_Comment__c = supportAccess.Status_Comment__c;                         
                    sa.Expiration_Date__c = supportAccess.Expiration_Date__c;
                    sa.End_User_Account__c = endUserAccId;
                    sa.Sold_To_Account__c = soldToAccId;
                    sa.Service_Contract__c = sc.Id;
                    sa.Status__c = sc.Agreement_Status__c;
                    sa.SR_Access_Level__c = supportAccess.SR_Access_Level__c;
                    sa.Support_Blocked__c = supportAccess.Support_Blocked__c;
                    sa.Status__c = supportAccess.Status__c;
                    sa.Case_Number__c = supportAccess.Case_Number__c;
                    system.debug(sa);
                    sasToInsert.add( sa );
                }
            }
        }
        try{
            if(!sasToInsert.isEmpty())
                upsert sasToInsert;
            else {
                Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR, 'Please select at least one service contract for this End User/Sold To Combination'));
                return null;
            }
        }catch(DmlException ex){
            String error = '';
            for(Integer i=0; i<ex.getNumDml(); i++){
                error = ex.getDmlMessage(i) + '. ';
            }
            if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                String dupErrMsg = ex.getDmlMessage(0);
                String recName = [SELECT NAME 
                                  FROM   Support_Access__c 
                                  WHERE  Id =:dupErrMsg.right(15)][0].Name;
                Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR, 'Duplicates value on record: <a href="'+'/'+dupErrMsg.right(15)+'" target="_blank">'+recName+'</a>'));
            }else{
              Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR, error));
            }
            return null;
        }
        if(isSrvContractPg){
            return new PageReference('/'+ servContractId);
        }
        if(contactId != null)
            return new PageReference('/'+contactId);
        else return new PageReference('/'+ supportAccess.Id);
        
    }
    
     public PageReference test(){
        return null;
    }
    
    public PageReference cancel(){
        String retURL = Apexpages.currentPage().getParameters().get('retURL');
        if(retURL != null){
            return new PageReference('/'+ retURL);
        }
        if(supportAccess.Contact__c != null)
            return new PageReference('/'+ supportAccess.Contact__c);
        else{
            Schema.DescribeSObjectResult sa = Support_Access__c.SobjectType.getDescribe();
            return new PageReference('/' + sa.getKeyPrefix());
        }
    }
}