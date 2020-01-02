public class CloneSupportAccessCloudController {
        
        public Contact newContact {get; set;}
    public Contact existingContact {get; set;}  
    public List<Util.Wrappers> accessRecords {get; set;}
    public List<Support_Access_Cloud__c> newAccessRecords {get; set;}
    public Boolean showInactive {get;set;}
    
    public string fields {
      get{
          return 'id,Name,Status__c,Email,Designated_Contact__c,Employer__c' ;
         }
      set;
    }
                                
    public CloneSupportAccessCloudController(){
        newContact = new Contact();
        existingContact = new Contact();
        accessRecords = new List<Util.Wrappers>();
        newAccessRecords = new List<Support_Access_Cloud__c>();
    }
    
    public PageReference findAccessRecords(){
        system.debug(existingcontact);
        system.debug(newContact);
        if((string)existingCOntact.Id == '' || (string)newCOntact.Id == '')
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select a Valid New and Existing Contacts'));
            return null;
        }
        accessRecords.clear();
  
        String query = 'SELECT Id, Name, Access_Level__c, Access_Status__c, Account_Name__c, Sold_To_Account_Name__c, ' + 
                       'Cloud_Deployment__c ' +
                       'FROM Support_Access_Cloud__c WHERE Contact__c = \''+ existingContact.Id + '\'';
    
       if( !showInactive )
           query += ' and Access_Status__c != \'Active \'';
     
    
        system.debug( query );
        for(Support_Access_Cloud__c a :  Database.query( query ) ){
            accessRecords.add(new Util.Wrappers (a));
        }
        if(accessRecords.isEmpty()){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'No Support Access records found for the specified Contact.'));
            return null;
        }
        return null;
    }
    
    public PageReference createAccessRecords(){
        Boolean skip=false;
        String msg='';
        List<Support_Access_Cloud__c> existingAccess = new List<Support_Access_Cloud__c>();

       existingAccess = [SELECT Cloud_Deployment__c, Sold_To_Account_Name__c, Account_Name__c, Name FROM Support_Access_Cloud__c WHERE Contact__c= :newContact.Id];
             
        for(Util.Wrappers a : accessRecords)  {
            if(a.isSelected) {
 
                Support_Access_Cloud__c accessRec = new Support_Access_Cloud__c (
                                                      Access_Status__c = (String) a.obj.get('Access_Status__c'),                      
                                                      Access_Level__c =(String) a.obj.get('Access_Level__c'), 
                                                      Cloud_Deployment__c = (Id) a.obj.get('Cloud_Deployment__c'),
                                                      Contact__c = newContact.Id ); 
                
                if ( !existingAccess.isEmpty() )  {
                                    skip=false;
                        for ( Integer i=0; i < existingAccess.size(); i++ ) {
                           if ( accessRec.Cloud_Deployment__c == existingAccess[i].Cloud_Deployment__c ) {                         
                                  msg += 'Cloud Deployment: ' + existingAccess[i].Cloud_Deployment__c + '; ';
                                          skip=true;
                                          break; 
                            }                              
                        }
                }
                
                if ( skip==false)
                                newAccessRecords.add(accessRec);                                                                                                   
            }                    
        }
        
        if(!newAccessRecords.isEmpty()){
                try{
                insert newAccessRecords;
                    newAccessRecords = [SELECT Id, Name, Sold_To_Account_Name__c, Account_Name__c, Contact__c,                                          
                                                Access_Level__c, Access_Status__c, Cloud_Deployment__c  
                                         FROM Support_Access_Cloud__c WHERE Id In :newAccessRecords];
                
                }catch(DmlException ex){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Error inserting access Records ' + ex.getMessage()));
                }
                
                if ( msg != '')
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'One or more already existing Support Access records have been found.' + msg));
        }
        else {
                 ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'No new support access records have been added.'));
        }
     
        return null;
    }
    
    public PageReference done(){
        PageReference p = new PageReference('/aAw');
        p.setRedirect(true);    
        return p;
    }
    
}