public class ContactsListWithUserInfoController {

   public String contactSearchEmail {get; set;}
   public String contactSearchName {get; set;}
   public String acctSearchName {get; set;}
   public List<wrapContact> wrapContList {get; set;} 
   /// page ContactsUpdateAccount
   public String fromAccntId {get; set;}
   public String fromAccntName {get; set;}
   public Contact dummyCont {get; set;}
   public String contStatus {get; set;}
    
   public ContactsListWithUserInfoController() {
        wrapContList = new List<wrapContact>();
        
        /// page ContactsUpdateAccount
        fromAccntId =  ApexPages.currentPage().getParameters().get('acctid'); 
        if ( fromAccntId != null && fromAccntId != '' ) {
        	List<Account> acctlst = [SELECT Name FROM Account WHERE Id = :fromAccntId];
        	if ( !acctlst.isEmpty() )
        	   fromAccntName = acctlst[0].Name;
        }   
        dummyCont = new Contact();
        contStatus = 'none';
    }
    
    public void getByEmail () {
       contactSearchName = '';
       acctSearchName = '';
       getContacts ();
    }
    
    public void getByName() {
       contactSearchEmail = '';
       acctSearchName  = '';
       getContacts ();
    }
    
    public void getByAcct() {
       contactSearchEmail = '';
       contactSearchName = '';
       getContacts ();
    }
    
    public void getContacts () {
         String searchStr;
         if ( contactSearchName != null && contactSearchName != '' )  {
             searchStr = '\'' + contactSearchName + '\' ';
             processQuery (' Name = ' + searchStr );
         }
         else if ( contactSearchEmail != null && contactSearchEmail != '' ) {                                                   
               searchStr = '\'%' + contactSearchEmail + '%\' ';
               processQuery (' Email LIKE ' + searchStr );
         }
         else if ( acctSearchName != null && acctSearchName != '' ) {                                                   
               searchStr = '\'%' + acctSearchName + '%\' ';
               processQuery (' Account.Name LIKE ' + searchStr );
         }
         else if ( fromAccntId != null && fromAccntId != '' ) {
         	 /// page ContactsUpdateAccount
         	 processQuery (' AccountId = \'' + fromAccntId +  '\' ');
         }
         return;
    }
    
    public void processQuery (String whereStr) {
          wrapContList.clear(); 
          sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
          String sortBy = sortField.equals('isWebEnabled') ? 'Name' : sortField;
            
          String searchQuery = 'SELECT Id, Name, Email, Account.Name, Country__c, Designated_Contact__c, Status__c, ' +
                                ' Read_Only_Total_SA_Records__c ' +
                                    'FROM Contact ' +                                    
                                    'WHERE ' + whereStr +
                                    'ORDER BY ' + sortBy + ' ' + sortDir + ' NULLS LAST LIMIT 500';
        
               List<Contact> contLstS = Database.query(searchQuery );
               
               if ( !contLstS.isEmpty() )  {
                  Map<ID, User> usrMap = new Map<ID, User>();
                  List<User> usrList = [SELECT ContactId, Id, Username, LastLoginDate FROM user WHERE ContactId IN :contLstS];  
                  if ( !usrList.isEmpty() ) {
                        for (User usr : usrList )
                          usrMap.put( usr.ContactId, usr );
                  }             
                             
                  for(Contact cont :  contLstS ) {
                        wrapContList.add( new wrapContact (this, cont, usrMap.get(cont.Id)) ); 
                  }
                  
                  if ( sortField.equals('isWebEnabled') ) 
                         wrapContList.sort();
               }                                                                        
      } 
      
      public class wrapContact implements Comparable {
         public Contact contact {get; set;}
         public String isWebEnabled {get; set;}
         public Datetime lastLogin {get; set;}
         public String username {get; set;}
         public ID usrId {get; set;}
         public Boolean isSelected {get; set;}
         private ContactsListWithUserInfoController outerCl;
    
         public wrapContact(ContactsListWithUserInfoController outerCl, Contact c, User usr) {         
                contact = c; 
                isWebEnabled = 'No';
                
                if ( usr != null )  {          
                        isWebEnabled = 'Yes';
                        lastLogin = usr.LastLoginDate;
                        username = usr.username;
                        usrId = usr.Id;
                }
                this.outerCl = outerCl;
        }
         
         public Integer compareTo(Object compareTo)  {
                wrapContact wrCon = (wrapContact)compareTo;
      
                if ( outerCl.sortDir == 'asc' )  {
                                if ( isWebEnabled == 'No' )  return 0;                        
                                if ( isWebEnabled == 'Yes' )  return 1; 
                } 
                else {
                        if ( isWebEnabled == 'No' )  return 1;                        
                                if ( isWebEnabled == 'Yes' )  return 0; 
                }     
                return -1;        
         }
      }
      
   public void updateContacts() {
   	  if ( wrapContList.isEmpty() )  {
   	  	 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at least one Contact.'));
         return;
   	  }
   	  if ( dummyCont.AccountId == null ) {
   	  	 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select target Account.'));
         return;
   	  }
   	  
   	  Integer updNum=0, errNum=0, totalSelected=0;
      String messg ='', errMsg='';
      List<Contact> updContacts = new List<Contact>();                
   	  for ( wrapContact wc : wrapContList )  {
    
            if ( wc.isSelected ) {
            	Contact cont = new Contact(Id = wc.contact.Id, AccountId = dummyCont.AccountId);
            	if ( contStatus != 'none' && contStatus != null )
            	     cont.Status__c = contStatus;
            	     
                updContacts.add(cont);
                totalSelected++;              
            }
   	  }
   	  
   	  if ( totalSelected == 0 ) {
   	  	 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at least one Contact.'));
         return;
   	  }
   	  
   	  if ( !updContacts.isEmpty() ) {
           List<Database.SaveResult> insResults = Database.update(updContacts, false);                                                                          
           for (Database.SaveResult result : insResults) {
                    if (result.isSuccess()) 
                         updNum++;
                    else {
                        errNum++;
                        errMsg += result.getErrors()[0].getMessage() + '\n';
                    }
           }
       }
       messg = 'Out of total ' + totalSelected + ' Contacts selected:  ';
       messg += updNum + ' Contacts updated successfully; ';                         
       if ( errNum > 0 )
           messg += errNum + ' Failed due to error';
       
       getContacts();                  
       ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, messg));              
   	
   	   return;
   }
             
   public String sortDir {
        get  { 
                if (sortDir == null) {  
                        sortDir = 'desc'; 
                } return sortDir;
        }
        set;
    }
    
   public String sortField {
        get  {              
                if (sortField == null) {
                        sortField = 'Name'; 
                } 
                return sortField;  
        }
        set;
    }
    
}