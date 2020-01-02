/*
* Trigger Name       : UpdateLegalException
* Description        : This trigger is used to sync Legal Contracts to Opportunity. 
* TestClass          : UpdateLegalExceptionTest
*/
trigger UpdateLegalException on GCR__c (after insert,after update) {
     
    /*
    * @author: Ashish Goyal (10/01/2018)
    * @desc: To Update the Opportunity when legal request is marked as completed.
    *        Existing trigger code commented by Ashish
    */
    
    ContractTtriggerHandler.updateOpportunityDetails(trigger.new, trigger.oldMap);
    //added by kartik to sync ramp ext reason value with ccdb
     UpdateRampToCCDB.updateRampEXTReasonToCCDB(trigger.new, trigger.oldMap);
    
    /*Try{
        Set<Id> set_OppIds = new Set<Id>();
        List<String> list_OfferingType = Label.Offering_Type_Validation.split(',');
        for(GCR__C objGCR:Trigger.New) {
            if(objGCR.status__C =='10-Completed'  && objGCR.Opportunity__c != null  && objGCR.Request_Type__c== 'Sales' && Label.Offering_Type_Validation.contains(objGCR.Offering_Type__c))
                set_OppIds.add( objGCR.opportunity__C);
        }
        System.debug('set_OppIds'+set_OppIds);
        Map<Id,GCR__c> map_GCRtoProcess = new Map<Id,GCR__C>([select id,opportunity__c from GCR__c where opportunity__c in :set_OppIds and Offering_type__c in :list_OfferingType  and Request_Type__c = 'Sales']);
        Map<Id,Opportunity> Map_OppIdtoOpp = new Map<Id,Opportunity>([select id,Legal_Exceptions__c,Contract_Expiration_Date__c,Contract_Type__c from Opportunity where id in :set_OppIds ]); 
        Map<Id,Set<Id>> map_OppIdtoGCRId = new Map<Id,Set<Id>>();
        System.debug('Legal Request to Process:'+map_GCRtoProcess);
        System.debug('Opportunities to Process:'+Map_OppIdtoOpp);
        for(GCR__C objGCR : map_GCRtoProcess.values()){
            if(!map_OppIdtoGCRId.containskey(objGCR.opportunity__c)) {
                map_OppIdtoGCRId.put(objGCR.opportunity__c, new Set<Id>());
                map_OppIdtoGCRId.get(objGCR.opportunity__c).add(objGCR.Id);
            }
            else {
                map_OppIdtoGCRId.get(objGCR.opportunity__c).add(objGCR.Id);
            }   
        }
        System.debug('Mapping of Opportunity to Legal Request:'+map_OppIdtoGCRId);
        Map<Id,List<GCR_Content_Document_Detail__c>> map_GCRIdtoGCRDocs = new Map<Id,List<GCR_Content_Document_Detail__c>>();
        List<String> list_ContractType = Label.Contract_Type_for_Legal_DSR.Split(';');
        Map<Id,GCR_Content_Document_Detail__c> map_DocstoProcess = new Map<Id,GCR_Content_Document_Detail__c>([select id,GCR__c,Legal_Exceptions__c,Expiration_Renewal_Date__c,Effective_Date__c,Contract_Type__c,Createddate  from GCR_Content_Document_Detail__c where GCR__c in :map_GCRtoProcess.keyset() and Contract_Type__c in :list_ContractType  order by createddate desc]);
        for(GCR_Content_Document_Detail__c objGCRDoc :map_DocstoProcess.values()){
            if(!map_GCRIdtoGCRDocs.containskey(objGCRDoc.GCR__c)) {
                map_GCRIdtoGCRDocs.put(objGCRDoc.GCR__c, new List<GCR_Content_Document_Detail__c>());
                map_GCRIdtoGCRDocs.get(objGCRDoc.GCR__c).add(objGCRDoc);
            }
            else {
                map_GCRIdtoGCRDocs.get(objGCRDoc.GCR__c).add(objGCRDoc);
            }   
        }
        System.debug('Mapping of Opportunity to Legal Request:'+map_OppIdtoGCRId);  
        System.debug('Mapping of Legal Request to Docs:'+map_GCRIdtoGCRDocs);
        System.debug('Mapping of Legal Docs:'+ map_DocstoProcess);
        for(Id objOppId:map_OppIdtoGCRId.keyset()){
            String strExceptionString = (Map_OppIdtoOpp.get(objOppId).Legal_Exceptions__c != null)?(Map_OppIdtoOpp.get(objOppId).Legal_Exceptions__c+';'):'';
            Date dtContractExpDate = Map_OppIdtoOpp.get(objOppId).Contract_Expiration_Date__c;
            for(Id objGCRId:map_OppIdtoGCRId.get(objOppId)){
                System.debug('Oppid:'+objOppId);
                System.debug('List of assocaited Docs:'+map_GCRIdtoGCRDocs.get(objGCRId));
                for(GCR_Content_Document_Detail__c objGCRDoc: map_GCRIdtoGCRDocs.get(objGCRId)) {
                    if(objGCRDoc.Legal_Exceptions__c != 'None'){
                        Map_OppIdtoOpp.get(objOppId).Contract_Expiration_Date__c =  (objGCRDoc.Expiration_Renewal_Date__c != null)?objGCRDoc.Expiration_Renewal_Date__c: Map_OppIdtoOpp.get(objOppId).Contract_Expiration_Date__c; 
                        Map_OppIdtoOpp.get(objOppId).Contract_Effective_Date__c =  (objGCRDoc.Effective_Date__c != null)?objGCRDoc.Effective_Date__c: Map_OppIdtoOpp.get(objOppId).Contract_Effective_Date__c; 
                        break;
                    }
                    else
                        continue;
                }
                //Map_OppIdtoOpp.get(objOppId).Contract_Type__c =  (map_GCRIdtoGCRDocs.get(objGCRId)[0].Contract_Type__c != null)?map_GCRIdtoGCRDocs.get(objGCRId)[0].Contract_Type__c: Map_OppIdtoOpp.get(objOppId).Contract_Type__c;       
                for(GCR_Content_Document_Detail__c objGCRDoc: map_GCRIdtoGCRDocs.get(objGCRId)) {
                    Set<String> set_Exceptionlist = new Set<String>();
                    set_exceptionlist.addAll(objGCRDoc.Legal_Exceptions__c.split(';'));
                    if(set_Exceptionlist.size() > 0){
                        for(String strException:set_Exceptionlist){
                            if(!strExceptionString.contains(strexception)){
                                System.debug('Previous values for Legal Exception:'+strExceptionString);
                                System.debug('New Values to be added :'+strexception);
                                strExceptionString+=strException+';';
                            }
                            
                        }
                        strExceptionString = strExceptionString.replace('None;','');
                        Map_OppIdtoOpp.get(objOppId).Legal_Exceptions__c = (strExceptionString !=null)?strExceptionString:Map_OppIdtoOpp.get(objOppId).Legal_Exceptions__c; 
                    }
                }       
            }      
        } 
        System.debug('Opportunities to Process:'+Map_OppIdtoOpp);
        Update Map_OppIdtoOpp.values();
    }
    catch(Exception e){
        System.debug('Exception has occurred:'+e.getMessage()+'\n'+e.getTypeName()+'\nStacktrace:'+e.getStackTraceString());
    }*/
}