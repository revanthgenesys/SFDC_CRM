//Santosh Parsi  01/16/2018
public without sharing class OppurtunityActiveContractsExtension {
    public List<wrapperContracts> contracts {get;set;}
    public Id opportunityId = null;
    public OppurtunityActiveContractsExtension (ApexPages.StandardController sc){
         opportunityId = sc.getId();
         init(opportunityId);
    }
    public String strAttachmentId {get; set;}
    public String strContractId {get; set;}
    
    public void init(Id opportunityId){
        contracts = new List<wrapperContracts>();
        strContractId = '';
        strAttachmentId = '';
        
        List<GCR_Content_Document_Detail__c> contracts1 = [SELECT id, Name, Document_Name__c,GCR__r.Name,GCR__r.id,GCR__r.Status__c,CreatedBy.Name, Effective_Date__c, Expiration_Renewal_Date__c, Public_URL__c            
            FROM GCR_Content_Document_Detail__c WHERE Account_Name__c IN (SELECT Account__c FROM GCR__c where Opportunity__c=:opportunityId)
            AND (Expiration_Renewal_Date__c = NULL OR Expiration_Renewal_Date__c >: System.today())];
        Set<Id> setOfDocumentIds = new Set<Id>();
        
        for(GCR_Content_Document_Detail__c eachContact : contracts1){
            setOfDocumentIds.add(eachContact.id);
        }
        
        Map<Id, dsfs__DocuSign_Status__c> mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id, GCR_Content_Document__c FROM dsfs__DocuSign_Status__c 
            WHERE GCR_Content_Document__c =: setOfDocumentIds]);    
        Set<Id> setOfStatusIds = new Set<Id>();
        
        Map<Id, List<Id>> mapOfDocumentVsStatusIds = new Map<Id, List<Id>>();
        for(Id documentId : mapIdVsDocusignStatus.keyset()){
            System.debug('NKC debug documentId [' + documentId + ']');
            Id gcrId = mapIdVsDocusignStatus.get(documentId).GCR_Content_Document__c;
            System.debug('NKC debug gcrId [' + gcrId + ']');
            setOfStatusIds.add(documentId);
            if(mapOfDocumentVsStatusIds.get(gcrId) == null){
                List<Id> newList = new List<Id>();              
                newList.add(documentId);
                mapOfDocumentVsStatusIds.put(gcrId, newList);
            }
            else{
                mapOfDocumentVsStatusIds.get(gcrId).add(documentId);    
            }
            System.debug('NKC debug mapOfDocumentVsStatusIds [' + mapOfDocumentVsStatusIds + ']');
        }
       
       
        Map<Id, List<Attachment>> mapOfParentIdVsAttachment = new Map<Id, List<Attachment>>(); 
        List<Attachment> atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
            WHERE parentId IN : setOfStatusIds OR parentId IN : setOfDocumentIds order by id asc];
        
        for(Attachment eachAtt : atts){
            System.debug('NKC debug eachAtt.Name [' + eachAtt.Name + ']');
             
            if(mapOfParentIdVsAttachment.get(eachAtt.parentId) == null){
                List<Attachment> newList = new List<Attachment>();
                newList.add(eachAtt);
                mapOfParentIdVsAttachment.put(eachAtt.parentId, newList);
            }
            else{
                mapOfParentIdVsAttachment.get(eachAtt.parentId).add(eachAtt);
            }
        }
        
        
        for(GCR_Content_Document_Detail__c eachContact : contracts1){
            wrapperContracts newContract = new wrapperContracts();
            newContract.contract = eachContact;
            newContract.dtEffectiveDate = eachContact.Effective_Date__c;
            newContract.dtExpiryDate = eachContact.Expiration_Renewal_Date__c;
            newContract.strDocumentName = eachContact.Document_Name__c;
            newContract.strCreatedBy = eachContact.CreatedBy.Name;
            List<Attachment> atts1 ;
            List<Attachment> listOfAtts = new List<Attachment>();       
            List<Id> parentIds = mapOfDocumentVsStatusIds.get(eachContact.id);
            if(parentIds == null)
                parentIds = new List<Id>();
            parentIds.add(eachContact.id);
            for(Id eachParentId : parentIds){
                if(mapOfDocumentVsStatusIds.get(eachContact.id) == null) {
                  atts1 = mapOfParentIdVsAttachment.get(eachContact.id);
                   if(atts1 != null && !atts1.isEmpty()){
                        listOfAtts.addAll(atts1);
                    }   
                } 
                else {                  
                for(Id eachStatusId : mapOfDocumentVsStatusIds.get(eachContact.id)){
                     atts1 = mapOfParentIdVsAttachment.get(eachStatusId);
                    if(atts1 != null && !atts1.isEmpty()){
                        listOfAtts.addAll(atts1);
                    }   
                }                   
              }
            }
            
            
            if(listOfAtts.isEmpty())
                continue;
            newContract.att = listOfAtts[0];
            contracts.add(newContract);
        }
        
        //Fetching Closed Won Opportunities
        Map<Id, Opportunity> mapOfIdVsOpportunity = new Map<Id, Opportunity>();
        List<Opportunity> listOfOpps = [SELECT id, CloseDate, Term_Commitment__c 
                                               		FROM Opportunity WHERE id =: opportunityId];
        for(Opportunity eachOpp : listOfOpps){           
           	mapOfIdVsOpportunity.put(eachOpp.id, eachOpp);
        }
        
		mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id, dsfs__Opportunity__c, GCR_Content_Document__c FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Opportunity__c IN: mapOfIdVsOpportunity.keySet() ]);        
        
        mapOfParentIdVsAttachment = new Map<Id, List<Attachment>>(); 
        atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
            WHERE parentId IN : mapIdVsDocusignStatus.keyset() ORDER BY Id asc];
        
        for(Attachment eachAtt : atts){
            System.debug('NKC debug eachAtt.Name [' + eachAtt.Name + ']');             
            if(mapOfParentIdVsAttachment.get(eachAtt.parentId) == null){
                List<Attachment> newList = new List<Attachment>();
                newList.add(eachAtt);
                mapOfParentIdVsAttachment.put(eachAtt.parentId, newList);
            }
            else{
                mapOfParentIdVsAttachment.get(eachAtt.parentId).add(eachAtt);
            }
        }
        
        //Looping over each Docusign Status
        for(dsfs__DocuSign_Status__c eachStatus : mapIdVsDocusignStatus.values()){
            List<Attachment> listOfAttachments = mapOfParentIdVsAttachment.get(eachStatus.id);
            if(listOfAttachments == null)
                continue;
            for(Attachment eachAtt : listOfAttachments){
            	wrapperContracts newContract = new wrapperContracts();
                newContract.att = eachAtt;
                Opportunity objOpp = mapOfIdVsOpportunity.get(eachStatus.dsfs__Opportunity__c);               	
                newContract.strDocumentName = eachAtt.Name;
                newContract.dtEffectiveDate = objOpp.CloseDate;
                newContract.strCreatedBy = eachAtt.CreatedBy.Name;
                if(objOpp.Term_Commitment__c != null){
                    String strYears = objOpp.Term_Commitment__c.replace('Years', '').replace('Year','').replace(' ','');
                    try{
                    	Integer intYears = Integer.valueOf(strYears);
                        newContract.dtExpiryDate = newContract.dtEffectiveDate.addYears(intYears).addDays(-1);
                    }catch(Exception e){}
                }                
                newContract.strRecordType = 'Opportunity';
                contracts.add(newContract);
            }
        }
        //Primary Quote's attachments
        atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
            WHERE parentId IN (SELECT Primary_Quote__c FROM Opportunity WHERE id =: opportunityId) ORDER BY Id ASC];
        
        for(Attachment eachAtt : atts){
        	wrapperContracts newContract = new wrapperContracts();
            newContract.att = eachAtt;
            if(!listOfOpps.isEmpty()){
                Opportunity objOpp = listOfOpps[0];               	
                newContract.strDocumentName = eachAtt.Name;
                newContract.dtEffectiveDate = objOpp.CloseDate;
                newContract.strCreatedBy = eachAtt.CreatedBy.Name;
                if(objOpp.Term_Commitment__c != null){
                    String strYears = objOpp.Term_Commitment__c.replace('Years', '').replace('Year','').replace(' ','');
                    try{
                        Integer intYears = Integer.valueOf(strYears);
                        newContract.dtExpiryDate = newContract.dtEffectiveDate.addYears(intYears).addDays(-1);
                    }catch(Exception e){}                                
                    newContract.strRecordType = 'Opportunity';
                    contracts.add(newContract);
                }
            }
        }
    }
    
    public class wrapperContracts{
        public Attachment att {get;set;}
        public GCR_Content_Document_Detail__c contract {get;set;}      
        public String strDocumentName {get; set;}
        public String strRecordType {get;set;}    
        public Date dtEffectiveDate {get;set;}
        public Date dtExpiryDate {get;set;}
        public String strCreatedBy {get;set;}
    } 
    //Added By Santosh Parsi on Jan 16, 2018 -- Ends
}