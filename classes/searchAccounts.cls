public without sharing class searchAccounts 
{
public account a1{get;set;}

    public searchAccounts(ApexPages.StandardController controller)
    {
       a1=new account();
       isShownButton=false;
    }
        public boolean isShownButton{get;set;}
        //public Pagereference pageredir(){ Pagereference newpage = new Pagereference ('/001/e?nooverride=1&retURL=/001/o'); newpage.setRedirect(true); return newpage;}  
      
        public Pagereference pageredir(){ 
          User objU = [Select id,Segment__c from User where id =: UserInfo.getUserId()];
        //Pagereference newpage = new Pagereference ('/setup/ui/recordtypeselect.jsp?ent=Account');
            Pagereference newpage;
         if(apexPages.currentPage().getParameters().get('recordtype')!=null)
         //newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&ent=Account&RecordType='+apexPages.currentPage().getParameters().get('recordtype'));
         newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&ent=Account&00N0B000005y0fJ='+objU.Segment__c+'&00N0B0000065fgW='+objU.Segment__c +'&RecordType='+apexPages.currentPage().getParameters().get('recordtype'));
         else
         //newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&ent=Account&RecordType=012U0000000Le3h');
         //LIAM -- BLOCKED OFF 9.5 --  newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&ent=Account&RecordType=012U0000000Le3h&00N0B000005y0fJ='+objU.Segment__c+'&00N0B0000065fgW='+objU.Segment__c +'');
         //LIAM -- CLONE OF LINE ABOVE --> Record Type = PreProsp -- newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&ent=Account&RecordType=0120t000000Dkc4&00N0B000005y0fJ='+objU.Segment__c+'&00N0B0000065fgW='+objU.Segment__c +'');
         newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&RecordType=0120r0000004qbGAAQ&ent=Account'); // ADDED BY LIAM 9.5 -- 10.17 this is the preprospect id in uat. This is the one to be used for UAT.
         //newpage = new Pagereference ('/001/e?retURL=%2F001%2Fo&RecordType=0121T000000gmjoQAA&ent=Account'); // added by liam 10.17 -- this id is the preprospect id in prod.
         newpage.getParameters().put('nooverride','1');
         newpage.setRedirect(true); return newpage;}  

        public String name {get; set;}
        public String Id {get; set;}
        public String MDId {get; set;} 
        public String street {get; set;}
        public String city { get; set; }
        public String state{ get; set; }
        public String zipCode{ get; set; }
        public String country{ get; set; }
        public String DunsNumber{ get; set; }
        public String sapCode{ get; set; }
        public String subsidiary{ get; set; }
        public XMLDom dom;   
        public XMLDom addressDom;  
        public string resultcount{ get; set; }
        public integer resultCountinteger{ get; set; }
        
        public void dosearch(){
         if (a1.name==null&&a1.Country__c==null&&a1.subsidary__c==null&&a1.city__c==null){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please enter the search criteria'));}
        else
        isShownButton=true;}
       
        public set<string> empnum_set;
        public set<string> acc_sapcode_set;
        
        public List<Acc> accs { get; set; }
  
        Public List <acc> addaccountid=new List<acc> ();

        public class Acc {
        public String name {get; set;}
        public String Id {get; set;}
        public String MDId {get; set;} 
        public String street {get; set;}
        public String city { get; set; }
        public String state{ get; set; }
        public String zipCode{ get; set; }
        public String country{ get; set; }
        public string RecordType{get;set;}
        public string Type{get;set;}
        public String DunsNumber{ get; set; }
        public String sapCode{ get; set; }
        public String subsidiary{ get; set; }
        public string EmpNum{get;set;}
        public string OwnerName{get;set;}
        public string OwnerID{get;set;}
        public string status{get;set;}
    }
        
    public searchAccounts() {
        accs = new List<Acc>();
    }
    
    public pagereference insertAccount(){
        string MDId=apexPages.currentPage().getParameters().get('MDId');
        string SalesforceId=apexPages.currentPage().getParameters().get('SalesforceId');
        integer i=0;
        acc ac;
        pageReference pg;
        
        if(SalesforceId!=null && SalesforceId!=''){
            pg=new pageReference('/'+SalesforceId+'/e?retURL=/'+SalesforceId);  
        }else{
            for(acc a:addaccountid){
                i++;
                if(a.MdId==MDId){ac=addaccountid.get(i-1);}  
            }
            If (ac!=null){
                 account newAcc=new account();
                 newAcc.name=ac.name;
                 newAcc.street1__c=ac.street;
                 newAcc.zipCode__c=ac.zipCode;
                 newAcc.city__c=ac.city;
                 newAcc.Subsidary__c=ac.subsidiary;
                 newAcc.country__c=ac.country;
                 newAcc.DunsNumber=ac.DunsNumber;
                 newAcc.SAP_Code__c=ac.sapCode;

                 insert newAcc; 
                 pg = new pageReference('/'+newAcc.id);
                 pg.setRedirect(true);
             }
        }
        return pg;
    }

    //##############################    
    // WS Callout to Search Account in MDM System
    //##############################   
        public List<Acc> getAccounts() {
        addaccountid=new List<acc> ();
        if (a1.name==null&&a1.Country__c==null&&a1.subsidary__c==null&&a1.city__c==null){return null;}
        accs = new List<Acc>();
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String body='';
        String addressBody='';
//        String username = 'genesyslabs-E17Z4Z';
  //      String password = '793bf884-72aa-4506-b617-02efe8f9a0fd';
         String username = 'raj.nallamotu@genesyslab.com';
        String password = 'sriraj123';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        string query;            

    
    string name = '%' + a1.Name + '%';
     Id partyRecid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party Account').getRecordTypeId();
     Id groupRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account - Customer').getRecordTypeId();
     
    for(Account sfdcacc:[Select id,ownerid,owner.name, name,Street1__c,zipCode__c,city__c,StateProvince__c,status__c,Subsidary__r.name,country__r.name,SAP_Account_Code__c,RecordType.Name,Type from account where name like :name
    and recordtypeid <>:partyRecid and recordtypeid <>:groupRecId   and status__c <> 'Merged']){
        Acc acc = new Acc();
            acc.id = sfdcacc.id;
             acc.name= sfdcacc.name;
                 acc.street =sfdcacc.Street1__c;
                 acc.zipCode=sfdcacc.zipCode__c;
                 acc.city=sfdcacc.city__c;
                 acc.subsidiary=sfdcacc.Subsidary__r.name;
                 acc.country=sfdcacc.country__r.name;
                 acc.state = sfdcacc.StateProvince__c;
                 acc.sapCode=sfdcacc.SAP_Account_Code__c;
                 acc.ownerid = sfdcacc.ownerid;
                 acc.ownername = sfdcacc.owner.name;
                 acc.status = sfdcacc.status__c;
                 acc.RecordType = sfdcacc.RecordType.Name;
                 acc.Type = sfdcacc.Type;
                 
        accs.add(acc);       
        system.debug('++inside loop' + sfdcacc.name);
        } 
    
        system.debug('-------------------------------authorizationHeader-----------------------------------------------'+authorizationHeader);
        

/*             
            query = '<RecordQueryRequest limit="200">'+
            '<Filter>'+
            '<matchrule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="GroupingRule" operator="AND">';

            IF(a1.Name!=NULL)
            {
                query=query+'<nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH">'+
                '<input xsi:type="StaticRuleInput" value="'+a1.Name+'"/>'+
                '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="ACCOUNT_NAME"/>'+
                '</nestedExpression>';
            }             
            IF(a1.country__c!=NULL){
                List<Country__c> country = [select Name from Country__c where Country__c.Id = :a1.country__c];               
                query=query+'<nestedExpression xsi:type="ExpressionRule" operator="EQUALS">'+
                    '<input xsi:type="StaticRuleInput" value="'+country[0].Name+'"/>'+
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="COUNTRY"/>'+
                    '</nestedExpression>';
            }
            
            //IF(a1.subsidary__c!=NULL){
                //List<Subsidary__c> subsidary = [select Name from Subsidary__c where Subsidary__c.Id = :a1.subsidary__c];               
                query=query+'<nestedExpression xsi:type="GroupingRule " operator="OR">';
                query=query+'<nestedExpression xsi:type="ExpressionRule" operator="EQUALS">'+
                   // '<input xsi:type="StaticRuleInput" value="'+subsidary[0].Name+'"/>'+
                    '<input xsi:type="StaticRuleInput"  value="8100"/>'+  
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/>'+
                    '</nestedExpression>';
                     query=query+'<nestedExpression xsi:type="ExpressionRule" operator="EQUALS">'+                  
                    '<input xsi:type="StaticRuleInput"  value="8110"/>'+  
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/>'+
                    '</nestedExpression>';
                     query=query+'<nestedExpression xsi:type="ExpressionRule" operator="EQUALS">'+                  
                    '<input xsi:type="StaticRuleInput"  value="8325"/>'+  
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/>'+
                    '</nestedExpression>';
                       query=query+'<nestedExpression xsi:type="ExpressionRule" operator="EQUALS">'+                  
                    '<input xsi:type="StaticRuleInput"  value="8420"/>'+  
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/>'+
                    '</nestedExpression></nestedExpression>';
           // }
            
            
            IF(a1.city__c!=NULL){       
                query=query+'<nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH">'+
                    '<input xsi:type="StaticRuleInput" value="'+a1.city__c+'"/>'+
                    '<input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="PRIMARY_CITY"/>'+
                    '</nestedExpression>';
            }            

            query=query+
            '</matchrule>'+
            '</Filter>'+
            '</RecordQueryRequest>'; */
         
      
         query = '<?xml version="1.0" encoding="utf-8"?><mdm:RecordQueryRequest xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200">'+
            '<mdm:filter>'+
            '<mdm:expression xsi:type="mdm:GroupingExpression" operator="AND">';

            IF(a1.Name!=NULL)
            {

              
        
     
                query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH">'+
                '<mdm:argument>'+a1.Name+'</mdm:argument>'+
                '</mdm:nestedExpression>';
            }             
          IF(a1.country__c!=NULL){
                List<Country__c> country = [select Name from Country__c where Country__c.Id = :a1.country__c];               
                query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/country"  operator="STARTS_WITH">'+
                    '<mdm:argument>'+country[0].Name+'</mdm:argument>'+
                    '</mdm:nestedExpression>';
            }
            
                  
                query=query+'<mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR">';
                query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH">'+
                    '<mdm:argument>8100</mdm:argument>'+
                    '</mdm:nestedExpression>';
                 query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH">'+
                    '<mdm:argument>8110</mdm:argument>'+
                    '</mdm:nestedExpression>';
                 query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH">'+
                    '<mdm:argument>8325</mdm:argument>'+
                    '</mdm:nestedExpression>';
                  query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH">'+
                    '<mdm:argument>8420</mdm:argument>'+
                    '</mdm:nestedExpression>';   
                    query=query+'</mdm:Expression>';
          
             
            
            IF(a1.city__c!=NULL){       
                query=query+'<mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH">'+
                    '<mdm:argument>'+a1.city__c+'</mdm:argument>'+
                    '</mdm:nestedExpression>';
            }           

            query=query+
            ' </mdm:expression></mdm:filter></mdm:RecordQueryRequest>';
         
         
    System.debug('+++++++Query' + query); 
    
            
        request.setMethod('POST');
       request.setEndPoint('https://api.boomi.com/mdm/api/rest/v1/genesyslabs-E17Z4Z/repositories/1577fc7d-fd11-4f90-a562-fdd491357b6b/universes/fb7aacdb-c5bb-4459-98d7-3bb376620957/records');
       //request.setEndPoint('https://mdm.boomi.com/mdm/universes/fb7aacdb-c5bb-4459-98d7-3bb376620957/records/query');
       // request.setEndPoint('https://mdm.api.platform.boomi.com/mdm/api/rest/v1/genesyslabs-E17Z4Z/repositories/1577fc7d-fd11-4f90-a562-fdd491357b6b/universes/fb7aacdb-c5bb-4459-98d7-3bb376620957/records');
        request.setBody(query); 
        // Make callout
       HttpResponse response = httpProtocol.send(request);
       system.debug('+++++response'+ response);  
      
       // HttpResponse response;
        try {            
            if(response!=null && response.getBody()!=null) 
             {
                // Parse XML Results to a List of objects
                body=response.getBody();
                
                system.debug('--------------------------body----------------------'+body);
                
                dom=new XMLDom(body);            
                
       
                for( xmldom.element f: dom.getElementsByTagName('RecordQueryResponse'))
                        {
                        resultCount=(string)f.getAttribute('resultCount');
                        system.debug('++++++resultCount' + resultCount);
                        empnum_set = new set<string>();
                        acc_sapcode_set = new set<string>();

                         
                        integer resultCountinteger= integer.valueOf(resultCount);
                        If (resultCountinteger>=100)       
                            {     
                             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Search criteria you have entered is returning more than 100 records, Please modify your search criteria and then search again.');
                             ApexPages.addMessage(myMsg);
                            }
                        Else
                            {
                            List<string> ids= New List <string> (); 
                            for( xmldom.element e: dom.getElementsByTagName('customer'))
                               {                    
                                   //String subsidiary = (String)e.getvalue('subsidiary');
                                   //String sapCode = (String)e.getvalue('ERP_ID');
                                   system.debug('++++++xmldom.element' + (String)e.getvalue('account_name'));
                                   Acc acc = new Acc();
                                   acc.MdId=(String)e.getvalue('id');          
                                    acc.name=(String)e.getvalue('account_name');                                    
                                    acc.DunsNumber=(String)e.getvalue('duns_number');
                                    acc.sapCode=(String)e.getvalue('genesys_account_reference_number');
                                    acc.subsidiary=(String)e.getvalue('subsidiary');                                    
                                    acc.street=(String)e.getvalue('address_1');                                   
                                    acc.city=(String)e.getvalue('city');                                  
                                    acc.state=(String)e.getvalue('state_province');
                                    acc.zipCode=(String)e.getvalue('postal_code'); 
                                    acc.country=(String)e.getValue('country');
                                    acc.EmpNum= (String)e.getValue('account_owner');
                                    String addressGRID = e.getvalue('recordid');
                                    if(acc.EmpNum != null && acc.EmpNum != '')
                                    empnum_set.add(acc.EmpNum);
                                    acc_sapcode_set.add(acc.sapCode);                                                                       
                                    accs.add(acc);         
                                 }

         
      Map<string,string> ownername_map = new Map<string,string>() ; //based on employee number and ownername
      Map<string,string> ownerid_map = new Map<string,string>() ;
      system.debug('++++++xmldom.element' + empnum_set);
    
      for(user obj: [select id, employeenumber, name from user where employeenumber in:empnum_set]){
        ownername_map.put(obj.employeenumber,obj.name);
        ownerid_map.put(obj.employeenumber,obj.id);
       system.debug('++++++obj.employeenumber' + obj.employeenumber);
        
      }
       
       system.debug('Account size' + accs.size() + accs);  
      
        Map <string,id> idmap=new map<string,id> ();

                               
         //old code to go off of legacy SAP_Code__c field... do we need to merge these?                                 
//        for(account a :[Select id,SAP_Code__c from account where SAP_Code__c in:acc_sapcode_set]) {  
//          idmap.put(a.SAP_Code__c,a.id);  
        
        //new code to go off of SAP_Account_Code field which will be unique                                
       for(account a :[Select id,SAP_Account_Code__c from account where SAP_Account_Code__c in:acc_sapcode_set]) {  
          idmap.put(a.SAP_Account_Code__c,a.id);        
            



        
        }
        
        for(Acc wp :accs) {
            if(idmap.containskey(wp.sapCode)){
                wp.id=idmap.get(wp.sapCode);
            }
            
            if(wp.EmpNum!= null){
            wp.OwnerName = ownername_map.get(wp.EmpNum);
            wp.OwnerID = ownerid_map.get(wp.EmpNum);
            }
            addaccountid.add(wp);

         } 
                            } 
                        }
            }
            }
     catch (Exception e) 
                {
                system.debug(e);
                 }
         return addaccountid;  
                 }
}  
    //#################################