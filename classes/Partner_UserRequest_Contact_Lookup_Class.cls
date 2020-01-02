public with sharing class Partner_UserRequest_Contact_Lookup_Class {
	public String objName {get;set;}
    public String objPrefix {get;set;}
    public String[] fieldAPINames {get;set;}
    public List<String> fieldNames {get;set;}
    public String searchText {get;set;}
    public string searchStr {get;set;}
    public String acntId {get;set;}
    public string emailAdr {get;set;}
    public string accountId {get;set;}
    public string query {get;set;}
    public List<Contact> cntList {get;set;}
    public Set<Id> allAcnts = new Set<Id>();
    
    public List<Contact> objects {get;set;}
     /*   {
        objects=new set<Sobject>();
        
        if((searchStr != null ) || (queryStr != null && queryStr != '')) {
            if(query == null || query == ''){
                query = 'Select ';
                for(integer i=0; i<fieldAPINames.size();i++)
                    query+=  fieldAPINames[i] + ',';
                
                query = query.substring(0, query.length()-1);
                query += ' from '+ objName +' where '; 
                if(role!='')
                    query += 'Email';
            }
                        

            Set<id> allAcnts = new Set<id>();
            List<Account> parentAccountId = [SELECT id,ParentId,Name FROM Account WHERE id =:queryStr limit 1];
            
            system.debug('-----------------------------------parentAccountId--------------------------------------------------'+parentAccountId);
            
            
            if(parentAccountId.isEmpty())
            {
             allAcnts.add(queryStr);
            }else
            {
            	allAcnts.add(parentAccountId[0].ParentId);
            	for(Account eachAcnt : [Select Id,Name From Account WHERE ParentId =:parentAccountId[0].ParentId])
            	{
            	 allAcnts.add(eachAcnt.id);	            		
            	}
            }
            
           system.debug('-----------------------------------allAcnts--------------------------------------------------'+allAcnts);
           
           system.debug('-----------------------------------searchStr--------------------------------------------------'+searchStr);
           
            
  
        //   String dbQuery = query + '= \'' + String.escapeSingleQuotes(role) + '\' And AccountId = \'' +queryStr+'\' limit 100';
            
            objects.addAll(returnContactList(searchStr,))
            
            
            System.debug('NKC debug dbQuery ['+dbQuery+']');
            if(role == ''){
                List<Sobject> accounts=Database.query(dbQuery);
                Set<string> accountNames = new Set<string>();
                for (Sobject acc : accounts){
                    SObject account = acc.getSObject(role);
                    String name = (String) account.get('name'); 
                    //String roleName = (string)acc.get(role +'.Name');
                    if(!accountNames.contains(name)){
                        objects.add(acc);
                        accountNames.add(name);
                    }
                }
            }else objects.addAll(Database.query(dbQuery));
        }
        return objects;}
      set;} */
            
    public List<Contact> returnContactList(String searchText,String email, Set<id> allAcnts)
    {
      List<Contact> contactList = new List<Contact>();
      String query = returnQuery(searchText,email,allAcnts);
      contactList = Database.query(query);
      
      System.debug('-----------------------------------contactList--------------------------------------------------'+contactList);      
      
      return contactList;
    }
    
    public String returnQuery(String searchText,String email, Set<id> allAcnts)
    {
    	string query = '';
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(searchText );
      
      if(allAcnts.size() > 0)  
      {
	      if(searchText != '')
	      {
	      	if(!MyMatcher.matches()){
	      	   query += 'Select Id,Name,Email,AccountId,Account.Country__r.Name,Account.SAP_Code__c,Account.Type from Contact where Name Like \'%'+searchText+'%\' And AccountId IN :allAcnts order by CreatedDate desc';
	      	}else
	      	{
	      	   query += 'Select Id,Name,Email,AccountId,Account.Country__r.Name,Account.SAP_Code__c,Account.Type from Contact where Email Like \'%'+searchText+'%\' And AccountId IN :allAcnts order by CreatedDate desc';
	      	}
	      }else{
	        query += 'Select Id,Name,Email,AccountId,Account.Country__r.Name,Account.SAP_Code__c,Account.Type from Contact where Email'+ '= \''+email+'\'And AccountId IN :allAcnts order by CreatedDate desc';
	      }
      }else{
      	    query += 'Select Id,Name,Email,AccountId,Account.Country__r.Name,Account.SAP_Code__c,Account.Type where Email'+ '= \''+email+'\' order by CreatedDate desc';
      }
      
      System.debug('-----------------------------------allAcnts--------------------------------------------------'+allAcnts);      
      
      System.debug('-----------------------------------query--------------------------------------------------'+query);      
      return query;
    }
    
    public void searchContact()
    {
    	objects = new List<Contact>();
    	objects.addAll(returnContactList(searchStr,emailAdr,allAcnts));
    	system.debug('---------------------------inside button click------------------------------');    	
    }                                       
                                                  
    public Partner_UserRequest_Contact_Lookup_Class(){
            searchStr = Apexpages.currentPage().getParameters().get('searchText');
            fieldAPINames = 'Id,Name,Email,AccountId,Account.Country__r.Name,Account.SAP_Code__c,Account.Type'.split(',');
            objPrefix = Apexpages.currentPage().getParameters().get('op');
            emailAdr = Apexpages.currentPage().getParameters().get('role');
            accountId = Apexpages.currentPage().getParameters().get('query');
            objects = new List<Contact>();
            
            system.debug('-----------------------------------allAcnts--------------------------------------------------'+allAcnts);
           
            system.debug('-----------------------------------searchStr--------------------------------------------------'+searchStr);      
           
            system.debug('-----------------------------------emailAdr--------------------------------------------------'+emailAdr);   
           
            system.debug('-----------------------------------accountId--------------------------------------------------'+accountId);   
                      
            if(accountId!= '')
            {
           	  allAcnts.add(accountId);           	
            }
           
       
       /*   List<Account> parentAccountId = [SELECT id,ParentId,Name FROM Account WHERE id =:accountId limit 1];
            
            system.debug('-----------------------------------parentAccountId--------------------------------------------------'+parentAccountId);
            
            if(parentAccountId.isEmpty())
            {
               if(accountId!= '')
               allAcnts.add(accountId);
            }else
            {
            	if(parentAccountId[0].ParentId != null)
            	{
	            	allAcnts.add(parentAccountId[0].ParentId);
	            	for(Account eachAcnt : [Select Id,Name From Account WHERE ParentId =:parentAccountId[0].ParentId and ParentId!=null ])
	            	{
	            	 allAcnts.add(eachAcnt.id);	            		
	            	}
            	}else{
            	    allAcnts.add(parentAccountId[0].id);
            	}
            }
        
        */
         
        system.debug('-----------------------------------allAcnts--------------------------------------------------'+allAcnts);
                                         
        objects.addAll(returnContactList('',emailAdr,allAcnts));
           
        system.debug('-----------------------------------objects--------------------------------------------------'+objects);            
           
        objName = 'Contact';
        fieldNames = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema ;
        objSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        for(String fname : fieldAPINames){
           // fieldNames.add(fieldMap.get(fname).getDescribe().getLabel());//It provides to get the object fields label.
        }
    }
}