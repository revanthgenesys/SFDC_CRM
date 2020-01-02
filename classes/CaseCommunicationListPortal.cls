public class CaseCommunicationListPortal {
    
    public String caseId;
    public transient List<Communication> comall;
    
    public CaseCommunicationListPortal (CaseDetailController detcontr) {
        caseId = detcontr.caseId;
        getUpdates();
    }
    
    public CaseCommunicationListPortal() {}
    
    public List<Communication> getComall() {
            getUpdates() ;  
            return comall;      
    }
        
    public void setCaseId(String ParentCaseID) {
        caseId = ParentCaseID;
    }
    public String getCaseId() {
        return caseId;
    }
    
    public void getUpdates() {  
        comall = new List<Communication>();
        
        List<CaseFeed> cfs = getCaseFeedPost();
        for ( CaseFeed cf : cfs ) 
           comall.add( new Communication(cf) );
        
        List<EmailMessage> ems = getEmailMessages();
        for ( EmailMessage em : ems ) 
           comall.add( new Communication(em) );
           
        comall.sort();
    }
    
    public class Communication implements Comparable {
        public String commType {get; set;}
        public DateTime dt {get; set;}
        public String crtdBy {get; set;}
        public String updBody {get; set;}
        public String updId {get; set;}
        public String tp {get; set;}
        public Boolean Internal {get; set;}
        
        public Communication (CaseFeed csfd) {
            tp = 'upd';
            commType = 'Post';
            dt = csfd.CreatedDate;
            crtdBy = csfd.CreatedBy.Name;

            String profName = csfd.CreatedBy.Profile.Name;           
            Internal = String.isNotBlank(profName) && profName.contains('Portal') ? false : true;
                        
            if( String.isNotBlank(csfd.Body) && csfd.Body.length() > 800)              
                 updBody = csfd.Body.left(800) + ' ....';
            else
                updBody = csfd.Body;
                
            updId = csfd.Id;
        }
        
        public Communication (EmailMessage emsg) {
            tp = 'em';
            commType = 'Email';
            //outbound email classified as Internal, Inbound classified as External
            Internal = emsg.Incoming ? false : true;            
            crtdBy = emsg.Incoming ? emsg.FromName : emsg.CreatedBy.Name;
            updBody = emsg.Subject; 
            dt = emsg.CreatedDate;
            updId = emsg.Id;
            
        }
        
        public Integer compareTo(Object compareTo) {
            Communication compTo = (Communication)compareTo;
            if (dt == compTo.dt) return 0;
            if (dt < compTo.dt) return 1;
            return -1;
        }       
    }
    
    public List<CaseFeed> getCaseFeedPost() {
        List<CaseFeed> csfeeds = new List<CaseFeed>();
        if ( !String.isBlank(caseId) ) {
            csfeeds = [SELECT id, Body, CreatedById, CreatedDate, CreatedBy.Name, CreatedBy.Profile.Name FROM CaseFeed 
                       WHERE ParentId = :caseId
                         AND Type IN ('TextPost', 'LinkPost') AND Visibility = 'AllUsers'];
        }               
        return csfeeds;
    }
    
    public List<EmailMessage> getEmailMessages() {
        /// Emails after case update redesign Oct 28
        List<EmailMessage> msgs = new List<EmailMessage>();
        if ( !String.isBlank(caseId) ) {
            msgs = [SELECT Id, Subject, Incoming, FromName, FromAddress, CreatedById, CreatedDate, CreatedBy.Name FROM EmailMessage
                    WHERE ParentId = :caseId AND CreatedDate > 2017-10-29T23:01:01+01:00
                      AND IsExternallyVisible = true];          
        }
        return msgs;        
    }
}