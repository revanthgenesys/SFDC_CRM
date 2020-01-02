public class SupportAccesscController {

    public boolean termsConditions { get; set; }

    public boolean isMain { get; set; }
    public String txtMsg { get; set; }
    public boolean isEdit { get; set; }
    public boolean readWriteOnly { get; set; }
    public boolean readyOnly { get; set; }
    public string descrip { get; set; }
    public String requestedAccess {get; set;}
    public String helpfulInfo {get; set;}
    public String exisingContacts {get; set;}
    public String stId {get; set;}
    public String euId {get; set;}
    public String stName {get; set;}
    public String euName {get; set;}
    public transient List<ServiceContract> srvActiveContrLst {get; private set;}
    public transient List<ServiceContract> srvClosedContrLst {get; private set;}        
    public string orderBy {get;set;} 
    public String orderByCld {get; set;}       
    public Map<String, List<Support_Access__c>> supAccessMap;
    public List<Support_Access__c> supAccessListUnique {get; set;}
    public List<Support_Access__c> supAccessListForSoldToEndUser {get; set;}
    public List<Support_Access_Cloud__c> supAccessCloudList {get; set;}
    public String saKey {get; set;}
    public Boolean selectedCloud {get; set;}
    public Boolean selectedPrem {get; set;}
  
    public Boolean linePureEngPrem {get; set;}
    public Boolean linePureEngCloud {get; set;}
    public Boolean linePureCnctPrem {get; set;}
    public Boolean linePureCnctCloud {get; set;}
    public Boolean linePureCloud {get; set;}
        
    private user usr;
    private final contact con;
    
    public PageReference ClearForm() {
        helpfulInfo = '';
        exisingContacts = '';
        requestedAccess ='';
        
        readyOnly = false;
        readWriteOnly = false ;  
        selectedCloud = false;
        selectedPrem = false;
        
        linePureEngPrem = false;
        linePureEngCloud = false;
        linePureCnctPrem = false;
        linePureCnctCloud = false;
        linePureCloud = false;
         
        return null;
    }
  
    public List<SelectOption> accessTypes {
             get{
                   accessTypes = new List<selectOption>();
                   accessTypes.add( new SelectOption( 'Read/Only', 'Read/Only' ));  
                   accessTypes.add( new SelectOption( 'Read/Write', 'Read/Write' ));
                   return accessTypes; 
             }
             set;
        }
           
     // CONSTRUCTOR
    public SupportAccesscController ()  {
                    
          usr = [ Select firstname,email, lastname,u.Contact.Email, u.Contact.AssistantPhone, u.Contact.OtherPhone, u.Contact.HomePhone, u.Contact.MobilePhone, u.Contact.Fax, u.Contact.Phone,
              u.Contact.MailingCountry, u.Contact.MailingPostalCode, u.Contact.MailingState, u.Contact.MailingCity, u.Contact.MailingStreet, u.Contact.FirstName, u.Contact.LastName,
              u.Contact.Id, u.ContactId, u.AccountId,u.contact.Account.name From User u 
              where id=:UserInfo.getUserId() and isactive=true];
              
          if(usr.contactid != null){
             List<Contact> cnts = [Select c.Street2__c, c.Street1__c,c.id, c.StateProvince__c, c.Owner.Id, c.ZipCode__c ,c.Pin__c, c.Name ,c.OwnerId, c.LastName, c.FirstName, c.Fax, c.Email,c.ContactPhone__c,
                     c.mobilephone, c.Country__r.Country__c, c.Country__c,c.Country__r.Name, c.City__c, c.Alternate_Email__c, c.Account.Name, c.AccountId From Contact c where c.Id=:usr.contactid];
               
               if ( !cnts.isEmpty() ) 
                  con = cnts[0];      
                     
            }
           orderBy = 'End_User_Account__r.Name, Sold_To_Account__r.Name';
           populateSARecords();
                
           orderByCld = 'Account_Name__c';
           getCloudSupportRecords(); 
           
           if (  Apexpages.currentPage().getParameters().get('euid') != null )
                euid = Apexpages.currentPage().getParameters().get('euid');
            if (  Apexpages.currentPage().getParameters().get('stid') != null )
                stid = Apexpages.currentPage().getParameters().get('stid');
            if (euid != '' && stid != '')
                 getSCforSTEU();
     }
    
    public void getCloudSupportRecords()  {
        supAccessCloudList = new List<Support_Access_Cloud__c>();
                
        if ( usr.contactid != null ) {
                String query = 'SELECT Cloud_Deployment__r.Name, Account_Name__c, Sold_To_Account_Name__c, CD_Platform__c, '
                               + ' Cloud_Deployment__r.Account__r.City__c, Cloud_Deployment__r.Account__r.Country__r.Name, '
                               + ' Access_Level__c, Cloud_Deployment__r.Support_Status__c, Cloud_Deployment__r.Care_Level__c '
                               + ' FROM Support_Access_Cloud__c '
                           + ' WHERE Contact__c = \''+ usr.contactid +'\' ' 
                           + ' AND Access_Status__c = \'Active\' '
                           + ' ORDER BY ' + orderByCld; 
                                                          
             supAccessCloudList = Database.query(query);
        }
    }
    
    public void populateSARecords() {
        supAccessListUnique = new List<Support_Access__c>();
        
        if (null != usr.contactid) {
            String query = 'SELECT id, Sold_To_Account__c, Sold_To_Account__r.Name, Sold_To_Account__r.City__c, Sold_To_Account__r.Country__r.Name, '
                           + ' End_User_Account__c, End_User_Account__r.Name, End_User_Account__r.City__c, End_User_Account__r.Country__r.Name, '
                           + ' SR_Access_Level__c, Service_Contract_Status__c, End_User_Account__r.SAP_Account_Code__c, Contact__r.Employer__r.Name, BOA_Platform__c '
                           + ' FROM Support_Access__c '
                           + ' WHERE Contact__c =  \''+ usr.contactid +'\' ' 
                           + ' AND Status__c = \'Active\' '
                           + ' ORDER BY  ' + orderBy;
                                  
            supAccessListUnique = Database.query(query);
        }
     }
         
    public PageReference SubmitForm() {
             if ( String.isBlank(requestedAccess) ) {
                 ApexPages.Message err = new ApexPages.Message(ApexPages.Severity.Error,'Please specify the Access Level requested.');
                 ApexPages.addMessage(err);  
                 return null;
             }
        
              try{
                      //Get the admin case record type  
                      RecordType r=[ Select Id From RecordType r where DeveloperName ='Genesys_Admin_Case'];
                                    
                   //   QueueSobject q = [Select id ,q.Queue.Name, q.QueueId From QueueSobject q where q.Queue.Name='Admin Case'];  
  
                            //create a admin case
                            case newAdminCaseReadOnly = new case();
                        //    newAdminCaseReadOnly.OwnerId = q.QueueId; 
                            newAdminCaseReadOnly.RecordTypeId = r.id;
                            
                           newAdminCaseReadOnly.origin = 'Web';
                           newAdminCaseReadOnly.reason = 'User Management';
                           newAdminCaseReadOnly.Case_Type__c ='User Role/Profile';
                           newAdminCaseReadOnly.Problem_Sub_Type__c ='Request: Add/Remove Support Access';
                           newAdminCaseReadOnly.sub_status__C ='New';
                           if (null != con) {
                               newAdminCaseReadOnly.ContactId = con.Id;
                           }
                     
                      /*
                           String envType = '';
                           if ( selectedCloud ) 
                                  envType = 'Cloud Subscriptions';  
                                  
                           if ( selectedPrem ) {
                                  envType += envType != '' ? ', ' : '';
                                  envType += 'On-Premises Licenses';  
                           }      
                        */   
                            /// Product Line
                         String prodLine = '';
                         if ( linePureEngPrem ) 
                            prodLine = 'PureEngage Premise';
                         if ( linePureEngCloud )  {
                            prodLine += prodLine != '' ? ', ' : '';
                            prodLine += 'PureEngage Cloud';
                         } 
                         if ( linePureCnctPrem )  {
                            prodLine += prodLine != '' ? ', ' : '';
                            prodLine += 'PureConnect Premise';
                         } 
                         if ( linePureCnctCloud )  {
                            prodLine += prodLine != '' ? ', ' : '';
                            prodLine += 'PureConnect Cloud';
                         } 
                         if ( linePureCloud )  {
                            prodLine += prodLine != '' ? ', ' : '';
                            prodLine += 'PureCloud';
                         } 
                            newAdminCaseReadOnly.Subject ='Customer Care Portal: Support Access Request';                    
                            newAdminCaseReadOnly.description = // 'Environment Type requested: ' + envType + '\n\n' +
                                                              'Access Requested: ' + requestedAccess + '\n\n' +
                                                              'Product Line(s): '  + prodLine + '\n\n' +
                                                              'End User/Sold To: ' + helpfulInfo + '\n\n' +
                                                              'Existing Contacts: ' + exisingContacts;  
                            insert newAdminCaseReadOnly ;
       
                   
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Your request to remove or add support access has been received and will be reviewed further by our Customer Care team.');
                       ApexPages.addMessage(myMsg);  

          
                  helpfulInfo = '';
                        exisingContacts = '';
                        requestedAccess ='';
                        
                        readyOnly = false;
                        readWriteOnly = false ;  
                        selectedCloud = false;
                        selectedPrem = false;
             
            }
           catch(System.DMLException e) {
              ApexPages.addMessages(e);
              return null;
           }
       return null; 
    }
      
     public void getSCforSTEU () {                      
        if ( stId != null && euId != null && stId != '' && euId != '' ) { 
                 ///confirm access
                 for ( Support_Access__c sa : supAccessListUnique) {
                         if ( sa.Sold_To_Account__c == stId && sa.End_User_Account__c == euId ) {
                                 stName = sa.Sold_To_Account__r.Name;
                                 euName = sa.End_User_Account__r.Name;

                             srvActiveContrLst = [SELECT Id, Name, StartDate, EndDate
                                                  FROM ServiceContract
                                                  WHERE Sold_To_Name__c = :stId
                                                    AND End_User_Name__c = :euId
                                                    AND Agreement_Status__c IN ('Active','Pending','In Negotiation')
                                                  ORDER BY EndDate DESC];
                                            
                             srvClosedContrLst = [SELECT Id, Name, StartDate, EndDate
                                                  FROM ServiceContract
                                                  WHERE Sold_To_Name__c = :stId
                                                    AND End_User_Name__c = :euId
                                                    AND Agreement_Status__c IN ('Closed','Terminated')
                                                  ORDER BY EndDate DESC LIMIT 1];
                      break;
                 }
           }
         }    
    }
    
    public PageReference goBack() {
        return new PageReference('/customercare/SupportAccess');
    }
    
}