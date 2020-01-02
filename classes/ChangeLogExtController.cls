public class ChangeLogExtController {

    public ChangeLogHistory__c currentRecord {get;set;}
    public List<Change_Log__c> listSearchResults {get; set;}
    public Map<String,List<Change_Log__c>> mapLogRecords {get;set;}
    public String viewComp {get;set;} 
    public Integer countLogs {get;set;} 
    public List<ChangeLogHistory__c> listRecentCLHs {get;set;}
    
    public ChangeLogExtController(ApexPages.StandardController controller) {
        viewComp = 'listRecentCLHs';
        countLogs = 0;
        //Query recent items
        listRecentCLHs =  [Select Id, Name, CreatedDate, Subject__c,  Start_Date__c, End_Date__c  FROM ChangeLogHistory__c Order By CreatedDate DESC LIMIT 10];
        this.currentRecord = (ChangeLogHistory__c)controller.getRecord();
        currentRecord.End_Date__c = system.today();
        currentRecord.Start_Date__c = currentRecord.End_Date__c - 15;
        currentRecord.Email_Sent_Date__c = system.today();
        currentRecord.Email_Recipients__c = '';
        
        List<ChangeLogRecipients__c> recepients = ChangeLogRecipients__c.getall().values();
        for(ChangeLogRecipients__c r : recepients)
                //currentRecord.Email_Recipients__c += '\'' + r.email__c + '\',';
                currentRecord.Email_Recipients__c += r.email__c + ',';
        currentRecord.Email_Recipients__c = currentRecord.Email_Recipients__c.removeEnd(',');
        
    }
    
    public PageReference doSearch() {
        viewComp = 'offerings';
        mapLogRecords = getChangelogsByOffering();
        return null;
    }
    
    public void previewandSend() {
        //prepopulate subject
        currentRecord.Subject__c = 'Changes released between '+currentRecord.Start_Date__c.format()+ ' to ' + currentRecord.End_Date__c.format();
        viewComp = 'previewandsend';
    }
     
    public Map<String,List<Change_Log__c>> getChangelogsByOffering(){
        
        //Search based on user entry
        listSearchResults =  [Select id, Name, Benefits__c, Change_Tracking__c, Description__c, 
                   Offering__c, Primary_Requester__c, Title__c,
                   Primary_Focus_Area__c, Primary_IT_contact__c, Release_Date__c From Change_Log__c 
                   where Release_Date__c >=: this.currentRecord.Start_Date__c AND Release_Date__c <=: this.currentRecord.End_Date__c];
        
        Map<String,List<Change_Log__c>> changelogsByOffering = new Map<String,List<Change_Log__c>>();
        countLogs = 0;
        for(Change_Log__c cont: listSearchResults){
            if(null == cont.Offering__c) continue;
            if(changelogsByOffering.containskey(cont.Offering__c))
                changelogsByOffering.get(cont.Offering__c).add(cont);
            else
                changelogsByOffering.put(cont.Offering__c, new List<Change_Log__c>{cont}); 
            countLogs ++;
        }
        return changelogsByOffering;
        
    }
    
    
    
    
    
    public void sendEmail(){
        

        insert currentRecord;
        
        //make image public and send
        /*PageReference p = new PageReference('http://dev-genesys.cs68.force.com/welcome/testimage');
        p.getParameters().put('id',currentRecord.id);
        system.debug(p);*/
        
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        if(currentRecord.Email_Recipients__c != null){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
            email.setSubject(currentRecord.Subject__c);
            email.setHtmlBody(currentRecord.Body__c);
            //email.setHtmlBody(EncodingUtil.base64encode(p.getContent()));
            //email.setHtmlBody(p.getContent().toString());
            List<String> toAddress = new List<String>();
            toAddress = currentRecord.Email_Recipients__c.split(',');
            
            email.setToAddresses(toAddress ); 
            emails.add(email);
        
        }
        
        
        if(emails.size() > 0)
            List<Messaging.SendEmailResult> listSearchResultss = Messaging.sendEmail(emails);
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Email sent successfully'));
                
    }
}