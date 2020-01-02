public class CreateSupportAccessController{
    public Contact newContact {get; set;}
    public Contact existingContact {get; set;}  
    public List<Util.Wrappers> accessRecords {get; set;}
    public List<Support_Access__c> newAccessRecords {get; set;}
    public Boolean showInactive {get;set;}
    
    public string fields {get{
                                return 'id,Name,Status__c,Email,Designated_Contact__c,Employer__c' ;}set;}
    public CreateSupportAccessController(){
        newContact = new Contact();
        existingContact = new Contact();
        accessRecords = new List<Util.Wrappers>();
        newAccessRecords = new List<Support_Access__c>();
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
  
        String query = 'SELECT Id, Name, SR_Access_Level__c, Status__c, End_User_Account__c, Sold_To_Account__c, ' + 
                       'Service_Contract_Status__c, Back_Office_Account__c ' +
                       'FROM Support_Access__c WHERE Contact__c = \''+ existingContact.Id + '\'';
    
       if( !showInactive )
           query += ' and Status__c != \'Active \'';
     
    
        system.debug( query );
        for(Support_Access__c a :  Database.query( query ) ){
            accessRecords.add(new Util.Wrappers (a));
        }
        if(accessRecords.isEmpty()){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'There are no support access records for this End User/Sold To Combination.'));
            return null;
        }
        return null;
    }
    
    public PageReference createAccessRecords(){
        Boolean skip=false;
        String msg='';
        List<Support_Access__c> existingAccess = new List<Support_Access__c>();

       existingAccess = [SELECT Back_Office_Account__c, Sold_To_Account__r.Name, End_User_Account__r.Name, Name FROM Support_Access__c WHERE Contact__c= :newContact.Id];
             
        for(Util.Wrappers a : accessRecords){
            if(a.isSelected) {
 
                Support_Access__c accessRec = new Support_Access__c(
                                                      Status__c = (String) a.obj.get('Status__c'),                      
                                                      SR_Access_Level__c =(String) a.obj.get('SR_Access_Level__c'), 
                                                      Back_Office_Account__c = (Id) a.obj.get('Back_Office_Account__c'),
                                                      Contact__c = newContact.Id ); 
                
                if ( !existingAccess.isEmpty() )  {
                                    skip=false;
                        for ( Integer i=0; i < existingAccess.size(); i++ ) {
                           if ( accessRec.Back_Office_Account__c == existingAccess[i].Back_Office_Account__c ) {                         
                                  msg += 'ST/EU: ' + existingAccess[i].Sold_To_Account__r.Name + ' / ' + existingAccess[i].End_User_Account__r.Name + '; ';
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
                    newAccessRecords = [SELECT Id, Name, Sold_To_Account__c, End_User_Account__c, Contact__c, Contact_Role__c, Service_Contract_Status__c,                                            
                                           SR_Access_Level__c, Status__c, Back_Office_Account__c  
                                    FROM Support_Access__c WHERE Id In :newAccessRecords];
                
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
        PageReference p = new PageReference('/a0m');
        p.setRedirect(true);    
        return p;
    }
    
}