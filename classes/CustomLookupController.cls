public class CustomLookupController {
    public string searchStr {
        get;
        set {
            searchStr = value;
            if (null != value) {
                searchStr = value.trim();
            }
        }
    }
    public string obj {get;set;}
    private string accType;
    private string contactId;
    private string endUserId;
    private string soldToId;  
    private String deplId;  
    private String boaId; 
    private String portalFilter;
    private String portalReqst;
    public List<Support_Access__c> supportAccessRecords {get;set;}
    public List<Support_Access_Cloud__c> supportCloudAccessRecords {get;set;}  
    public List<Cloud_Deployment__c>  cloudDeployments {get; set;} 
    public List<Contact> contactRecords {get;set;}
    public Boolean contactsOnly {get;set;}
    public Boolean cloudContacts {get; set;}
    public Boolean searchOnlyEmployeeContacts {get;set;}
    public Boolean isPortal {get;set;}  
        
    public CustomLookupController()   {
        List<User> lstUser = [Select IsPortalEnabled From  User Where  Id = :UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;
        searchOnlyEmployeeContacts = false;        
        contactsOnly = false;
        cloudContacts = false;
        if(searchStr == null || searchStr == '')
            searchStr = Apexpages.currentPage().getParameters().get('searchText');
        if(Apexpages.currentPage().getParameters().get('obj') != null)
            obj = Apexpages.currentPage().getParameters().get('obj');
        if(Apexpages.currentPage().getParameters().get('type') != null)
            accType = Apexpages.currentPage().getParameters().get('type');
        if(Apexpages.currentPage().getParameters().get('contactId') != null)
            contactId = Apexpages.currentPage().getParameters().get('contactId');
        if(Apexpages.currentPage().getParameters().get('endUserId') != null)
            endUserId = Apexpages.currentPage().getParameters().get('endUserId');
        if(Apexpages.currentPage().getParameters().get('soldToId') != null)
            soldToId = Apexpages.currentPage().getParameters().get('soldToId');
        if(Apexpages.currentPage().getParameters().get('contactsOnly') != null)
            contactsOnly = true; 
        if(Apexpages.currentPage().getParameters().get('cloudContacts') != null)
            cloudContacts = true;   
        if( Apexpages.currentPage().getParameters().get('dplId') != null)
            deplId = Apexpages.currentPage().getParameters().get('dplId');
        if( Apexpages.currentPage().getParameters().get('boaId') != null)
            boaId = Apexpages.currentPage().getParameters().get('boaId');
        
        portalFilter = Apexpages.currentPage().getParameters().get('fltr');
        portalReqst = Apexpages.currentPage().getParameters().get('rqst');
                         
        System.debug('NKC debug searchStr ['+searchStr+']');
        go();
    }
    
    public void go(){
        if(obj == 'Contact')
            populateContactRecords();  
        else if(obj == 'Account') 
            populateAccountRecords();   
        else if ( obj == 'CloudDepl' ) 
            populateCloudDeplRecords();
    }
    
    private void populateContactRecords(){
        String query;   

        if(searchOnlyEmployeeContacts){
            query = 'SELECT id, Name, Email, Contact_Pin__c FROM Contact WHERE Account.Name = \'Genesys - Employees\' ';
            
            query += ' AND Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' '+
                'order by FirstName asc, LastName asc LIMIT 100';
            contactRecords = Database.query(query);
        }
        else if (contactsOnly) {

          query = 'SELECT id, Name, Email, Contact_Pin__c FROM Contact WHERE (AccountId =\''+endUserId+'\' OR AccountId =\''+soldToId+'\')';
          if( String.isNotBlank(searchStr) )
              query += ' AND Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' ' +
                'ORDER BY FirstName ASC LIMIT 100';            
            System.debug('NKC debug query ['+query+']');            
            contactRecords = Database.query(query);            
        }
        else if (cloudContacts) {
        
          query = 'SELECT id, Name, Email, Contact_Pin__c FROM Contact WHERE ';
          query += ' ID IN (SELECT Contact__c FROM Support_Access_Cloud__c WHERE Access_Status__c = \'Active\' AND Access_Level__c = \'Read/Write\'';
          
          if ( portalFilter != null && portalFilter.equals('cnct') )
               query += ' AND CD_Platform__c LIKE \'PureConnect%\'';               
          else if ( portalFilter != null && portalFilter.equals('pcld') )
               query += ' AND CD_Platform__c LIKE \'PureCloud%\'';
          else if ( portalFilter != null )
               query += ' AND CD_Platform__c LIKE \'PureEngage%\'';
          
          
          if ( String.isNotBlank(deplId) )
             query += ' AND Cloud_Deployment__c =\'' + deplId + '\')';
          else
             query += ')';
             
          if ( String.isNotBlank(searchStr) )  
              query += ' AND Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' ';
           
            query += ' ORDER BY Name asc LIMIT 100';   
 
 System.debug('### q= ' + query);
                              
            contactRecords = Database.query(query);        
        }
        else {
                
            query = 'SELECT Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Contact_Pin__c FROM Support_Access__c WHERE Status__c = \'Active\' ' +
                    ' AND SR_Access_Level__c = \'Read/Write\' AND Service_Contract_Status__c = \'Active\'';
                    
          if ( portalFilter != null && portalFilter.equals('cnct') )
               query += ' AND BOA_Platform__c LIKE \'PureConnect%\'';               
          else if ( portalFilter != null && portalFilter.equals('eng') )
               query += ' AND BOA_Platform__c LIKE \'PureEngage%\'';
           else if ( portalFilter != null && portalFilter.equals('mac') )
               query += ' AND BOA_Support_Package__c LIKE \'Managed%\'';
               
            if( String.isNotBlank(endUserId) )
                query += ' AND End_User_Account__c =\''+endUserId+'\'';
            
            if( String.isNotBlank(soldToId) )
                query += ' AND Sold_To_Account__c =\''+soldToId+'\'';
            
            query += ' AND Contact__r.Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' ' +
                'order by Contact__r.FirstName asc, Contact__r.LastName asc LIMIT 300';
            
            System.debug('NKC debug query ['+query+']');
            
            supportAccessRecords = Database.query(query);
            Map<Id, Support_Access__c> mapSC = new Map<Id, Support_Access__c>();
            for(Support_Access__c eachSA : supportAccessRecords) 
                mapSC.put(eachSA.Contact__c, eachSA);
            supportAccessRecords = mapSC.values();
            supportAccessRecords.sort();
        }

    }
    
    private void populateAccountRecords() {
      if ( String.isBlank(contactId) && isPortal )
    	   return;
    	
        String query;
        query = 'SELECT End_User_Account__c, End_User_Account__r.Name, End_User_Account__r.City__c, End_User_Account__r.Country__r.Name, ' +
                ' Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.City__c, Sold_To_Account__r.Country__r.Name, BOA_Platform__c, Back_Office_Account__c ' +
                ' FROM Support_Access__c WHERE  SR_Access_Level__c = \'Read/Write\' AND Status__c = \'Active\' AND Service_Contract_Status__c = \'Active\'';
        
        if ( portalFilter != null && portalFilter.equals('cnct') )
               query += ' AND BOA_Platform__c LIKE \'PureConnect%\'';               
          else if ( portalFilter != null && portalFilter.equals('eng') )
               query += ' AND BOA_Platform__c LIKE \'PureEngage%\'';
               
         if ( portalReqst != null && (portalReqst.equals('mac') || portalReqst.equals('dtprv')) )
               query += ' AND BOA_Support_Package__c LIKE \'Managed%\'';
               
        if ( isContactEmployee() == false && String.isNotBlank(contactId) )
            query += ' AND Contact__c =\''+contactId+'\'';
        
        if( String.isNotBlank(soldToId) )
            query += ' AND Sold_To_Account__c = \''+ soldToId +'\'';   
 
        query += ' AND End_User_Account__r.Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' ' +
            'order by End_User_Account__r.Name asc LIMIT 300';
        
        System.debug('NKC debug query ['+query+']');    
        
        supportAccessRecords = Database.query(query);
        Map<String, Support_Access__c> mapSC = new Map<String, Support_Access__c>();
        for(Support_Access__c eachSA : supportAccessRecords) 
            mapSC.put(eachSA.End_User_Account__c + '-' + eachSA.Sold_To_Account__c + '-' + eachSA.BOA_Platform__c, eachSA);
            
        supportAccessRecords = mapSC.values();
        supportAccessRecords.sort();
    }
    
   private void populateCloudDeplRecords() {
   	     if ( String.isBlank(contactId) && isPortal )
    	   return;
    	   
           String query;
           
           query = 'SELECT Id, Name, Cloud_Platform__c, Status__c, Account__r.Name, Account__c, Sold_To_Account__c, Access_Approval__c ' +               
               'FROM Cloud_Deployment__c WHERE Name LIKE \'%'+ String.escapeSingleQuotes(searchStr) +'%\' ' +               
                'AND ID IN ' +
               '(SELECT Cloud_Deployment__c FROM Support_Access_Cloud__c ' +
                 'WHERE Access_Level__c = \'Read/Write\' AND Access_Status__c = \'Active\' AND Deployment_Support_Status__c = \'Active\' ';
  
         if ( portalFilter != null && portalFilter.equals('cnct') )
               query += ' AND CD_Platform__c LIKE \'PureConnect%\'';               
          else if ( portalFilter != null && portalFilter.equals('pcld') )
               query += ' AND CD_Platform__c LIKE \'PureCloud%\'';
          else if ( portalFilter != null )
               query += ' AND CD_Platform__c LIKE \'PureEngage%\'';
                  
        if ( isContactEmployee() == false && String.isNotBlank(contactId) )
            query += ' AND Contact__c =\''+ contactId +'\'';
        
        query += ') ORDER BY Name LIMIT 300';
  
 System.debug('Q ' + query) ;
       
            cloudDeployments = Database.query(query);
   }
   
   private Boolean isContactEmployee() {
           Boolean isContactEmployee = false;
        List<Contact> conts = [SELECT Account.Name FROM Contact WHERE id =: contactId];
        if(conts.size() > 0 && conts[0].Account.Name == 'Genesys - Employees')
            isContactEmployee = true;
        
        return isContactEmployee;
   }
}