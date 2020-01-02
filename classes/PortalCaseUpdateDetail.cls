public class PortalCaseUpdateDetail {
        
        public String body {get; set;}
        public String emSubject {get; set;}
        public String fromName {get; set;}
        public String fromAddr {get; set;}
        public String toAddr {get; set;}
        public String ccAddr {get; set;}
        public DateTime crtdt {get; set;}
        public String crtname {get; set;}
        public String pageTitle {get; set;}
        public String casenum {get; set;}
        public Boolean isMessage {get; set;}
        public Boolean isInbound {get; set;}
        public String caseSubj {get; set;}
        
        public PortalCaseUpdateDetail()  {
                String updId = ApexPages.currentPage().getParameters().get('id'); 
                String caseId = ApexPages.currentPage().getParameters().get('cs');
                String updtype = ApexPages.currentPage().getParameters().get('tp'); 
                isMessage = false;
                
                        try {
                        if ( String.isNotBlank(updId) && String.isNotBlank(caseId) && updtype == 'em' ) {
                                isMessage = true;
                                /// Email Message
                                List<EmailMessage> msgs = [SELECT Parent.CaseNumber, Subject, HTMLBody, TextBody, Incoming, CreatedDate, CreatedBy.Name,
                                                                  FromName, FromAddress, CcAddress, ToAddress, Parent.Subject
                                                           FROM EmailMessage 
                                                           WHERE Id = :updId AND ParentId = :caseId AND IsExternallyVisible = true];
                                                           
                            if ( !msgs.isEmpty() ) {
                                body = String.isBlank(msgs[0].HTMLBody) ? msgs[0].TextBody : msgs[0].HTMLBody;
                                emSubject = msgs[0].Subject;
                                crtdt = msgs[0].CreatedDate;
                                crtname = msgs[0].CreatedBy.Name;
                                casenum = msgs[0].Parent.CaseNumber;
                                pageTitle = msgs[0].Incoming ? 'Inbound Email Details' : 'Outbound Email Details';
                                isInbound =  msgs[0].Incoming;
                                fromName = msgs[0].FromName;
                                fromAddr = msgs[0].FromAddress;
                                ccAddr   = msgs[0].CcAddress;
                                toAddr   = msgs[0].ToAddress;
                                caseSubj = msgs[0].Parent.Subject;
                            }
                        }
                        else if ( String.isNotBlank(updId) && String.isNotBlank(caseId) && updtype == 'upd' ) {
                                // Case Feed Post
                                List<CaseFeed> csfeeds = [SELECT Parent.CaseNumber, Body, CreatedDate, CreatedBy.Name, CreatedBy.Profile.Name,
                                                                 Parent.Subject 
                                                          FROM CaseFeed 
                                                          WHERE Id = :updId AND ParentId = :caseId
                                                              AND Type IN ('TextPost', 'LinkPost') AND Visibility = 'AllUsers'];
                            
                            if ( !csfeeds.isEmpty() )  {
                                body = csfeeds[0].Body;
                                crtdt = csfeeds[0].CreatedDate;
                                crtname = csfeeds[0].CreatedBy.Name;
                                pageTitle = csfeeds[0].CreatedBy.Profile.Name.contains('Portal') ? 'Posted by Customer' : 'Posted by Customer Care';
                                casenum = csfeeds[0].Parent.CaseNumber;
                                caseSubj = csfeeds[0].Parent.Subject;
                            }                                                                                                                                                                                                                                     
                        }
                }
                catch (Exception ex) {} 
        }       
    
}