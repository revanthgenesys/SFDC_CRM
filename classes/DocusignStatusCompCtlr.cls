global with sharing class DocusignStatusCompCtlr {
    
     
    global String docuId{get;set;}
     
    @remoteAction
    global static List<docusignwrapper> getDocusignStatusData(String OppId){
        
        List<docusignwrapper> lstDocusignreturn = new List<docusignwrapper>();
        
        if(OppId != '' &&  OppId != null){
            List<dsfs__DocuSign_Status__c> lstDocusign = [  Select Id , Name, dsfs__Opportunity__c, dsfs__Opportunity__r.Name , 
                                                            (Select Id, Name, CreatedDate from Attachments ) 
                                                            from dsfs__DocuSign_Status__c 
                                                            where dsfs__Opportunity__c=:OppId 
                                                            and dsfs__Envelope_Status__c=:'Completed'];
            
            for(dsfs__DocuSign_Status__c ds : lstDocusign){
                if(ds.Attachments.size() > 0){
                    for(Attachment att : ds.Attachments){
                        docusignwrapper dsr = new docusignwrapper();
                        dsr.dsName = ds.Name;
                        dsr.dsNameOpp = ds.dsfs__Opportunity__r.Name;
                        dsr.attchName = att.Name;
                        dsr.attachCreatedDate = String.valueOf(att.CreatedDate);
                        //dsr.attachEffectiveDate = String.valueOf(att.CreatedDate);
                        //dsr.attachExpirationDate = String.valueOf(att.CreatedDate);
                        dsr.attachId = att.Id;
                        dsr.oppId = ds.dsfs__Opportunity__c;
                        dsr.dsId = ds.Id;
                        lstDocusignreturn.add(dsr);
                    }
                }
            }
        }
        
        return lstDocusignreturn;
    }
    
    global class docusignwrapper{
        public String dsName{get;set;}
        public String dsNameOpp{get;set;}
        public String attchName{get;set;}
        public String attachCreatedDate{get;set;}
        public String attachEffectiveDate{get;set;}
        public String attachExpirationDate{get;set;}
        public String attachId{get;set;}
        public String oppId{get;set;}
        public String dsId{get;set;}
        
    }
}