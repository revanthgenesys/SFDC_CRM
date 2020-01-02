public class ContractTtriggerHandler{   
    
    /*
    * @author: Ashish Goyal (09/28/2018)
    * @desc: To Update the Prmiary Quote's Contract Type for the Governing Contract
    */
    
    public static void updateOpportunityDetails(List<GCR__c> newGCRList, Map<Id, GCR__c> oldMap){
        
        Set<Id> set_GCRIds = new Set<Id>();
        for(GCR__C objGCR : newGCRList){
            if(objGCR.status__C == '10-Completed' && (oldMap == null || oldMap.get(objGCR.Id).Status__c != objGCR.Status__c) && objGCR.Opportunity__c != null && objGCR.Request_Type__c== 'Sales')
                set_GCRIds.add(objGCR.Id);
        }
        
        Map<Id, List<GCR_Content_Document_Detail__c>> map_OpptyIdListContract = new Map<id, List<GCR_Content_Document_Detail__c>>();
        Map<Id, Set<String>> map_OpptyIdLegalExc = new Map<id, Set<String>>();
        Map<Id, String> map_OpptyIdContractType = new Map<id, String>();
        Map<Id, Opportunity> map_OpportunityToUpdate = new Map<Id, Opportunity>();
        
        if(set_GCRIds.size() > 0){
            Set<Id> set_OppIds = new Set<Id>();            
            for(GCR_Content_Document_Detail__c contractDetails : [SELECT Id, GCR__r.CCDB_Subscription__c, GCR__r.Opportunity__c, Is_Governing_Contract__c, Contract_Category__c, Legal_Exceptions__c, 
                                                                    GCR__r.CCDB_Subscription__r.Contract_Effective_Date__c, GCR__r.CCDB_Subscription__r.Contract_Expiration_Date__c, Effective_Date__c, Expiration_Renewal_Date__c, Contract_Type__c 
                                                                    FROM GCR_Content_Document_Detail__c 
                                                                    WHERE IsGoverningContract__c = true 
                                                                    AND (Contract_Category__c = 'New' OR Contract_Category__c = 'Amend')
                                                                    AND GCR__c IN: set_GCRIds]){
                if(contractDetails.Contract_Category__c == 'Amend' && contractDetails.GCR__r.CCDB_Subscription__c != null && contractDetails.Is_Governing_Contract__c){
                    Opportunity oppTemp = new Opportunity(id = contractDetails.GCR__r.Opportunity__c);
                    String legalEc = '';
                    legalEc = contractDetails.Legal_Exceptions__c;
                    if(legalEc != ''){
                        oppTemp.Legal_Exceptions__c = legalEc;
                        if(!legalEc.contains('None')){
                            oppTemp.MSA_Link__c = '';
                            oppTemp.MSA_Link_Type__c = 'Custom';
                        }
                        else{
                            oppTemp.MSA_Link_Type__c = 'Standard';
                        }
                    }  
                    oppTemp.Contract_Type__c = contractDetails.Contract_Type__c;
                    oppTemp.Contract_Expiration_Date__c = contractDetails.GCR__r.CCDB_Subscription__r.Contract_Expiration_Date__c;
                    oppTemp.Contract_Effective_Date__c = contractDetails.GCR__r.CCDB_Subscription__r.Contract_Effective_Date__c;
                    oppTemp.Is_Governing_Contract__c = true;
                    map_OpportunityToUpdate.put(contractDetails.GCR__r.Opportunity__c, oppTemp);
                }
                else{
                    if(!contractDetails.Is_Governing_Contract__c){
                        if(!map_OpptyIdListContract.containsKey(contractDetails.GCR__r.Opportunity__c)){
                            map_OpptyIdListContract.put(contractDetails.GCR__r.Opportunity__c, new List<GCR_Content_Document_Detail__c>());
                        }
                        map_OpptyIdListContract.get(contractDetails.GCR__r.Opportunity__c).add(contractDetails);
                    }
                    else{
                        if(!map_OpptyIdLegalExc.containsKey(contractDetails.GCR__r.Opportunity__c)){
                            map_OpptyIdLegalExc.put(contractDetails.GCR__r.Opportunity__c, new Set<String>());
                        }
                        map_OpptyIdLegalExc.get(contractDetails.GCR__r.Opportunity__c).add(contractDetails.Legal_Exceptions__c);
                    }
                    
                    if(!map_OpptyIdContractType.containsKey(contractDetails.GCR__r.Opportunity__c)){
                        map_OpptyIdContractType.put(contractDetails.GCR__r.Opportunity__c, contractDetails.Contract_Type__c);
                    }
                }
            }
        }
        
        if(map_OpptyIdListContract.size() > 0){   
            System.debug('---map_OpportunityToUpdate- before if--'+map_OpportunityToUpdate);         
            map_OpportunityToUpdate.putAll(updateOpportunity(map_OpptyIdListContract, map_OpptyIdContractType, true));
            System.debug('---map_OpportunityToUpdate---after if--'+map_OpportunityToUpdate);
        }
        
        if(map_OpptyIdLegalExc.size() > 0){
            
            // Appropriate field needs to be mapped for the Quote for the Effective and Expiration Date. 
            
            for(Id opptyId : map_OpptyIdLegalExc.keySet()){
                Opportunity tempOpp = new Opportunity(Id = opptyId);
                tempOpp.Contract_Type__c = map_OpptyIdContractType.get(opptyId);
                String legalEc = '';
                
                if(map_OpportunityToUpdate.containsKey(opptyId)){
                    legalEc = map_OpportunityToUpdate.get(opptyId).Legal_Exceptions__c + ';';
                }
                
                for(String legalExc : map_OpptyIdLegalExc.get(opptyId)){
                    for(String legal : legalExc.split(';')){
                        if(!legalEc.contains(legal)){
                            legalEc += legal + ';';
                        }                    
                    }
                }
                if(legalEc != ''){
                    legalEc = legalEc.removeEnd(';');
                    tempOpp.Legal_Exceptions__c = legalEc;
                    if(!legalEc.contains('None')){
                        tempOpp.MSA_Link__c = '';
                        tempOpp.MSA_Link_Type__c = 'Custom';
                    }
                    else{
                        tempOpp.MSA_Link_Type__c = 'Standard';
                    }
                }                
                tempOpp.Is_Governing_Contract__c = true;
                if(map_OpportunityToUpdate.containsKey(opptyId)){
                    map_OpportunityToUpdate.get(opptyId).Legal_Exceptions__c = tempOpp.Legal_Exceptions__c;
                }
                else{
                    map_OpportunityToUpdate.put(opptyId, tempOpp);
                }
            }
            
            for(BigMachines__Quote__c quoteObj : [SELECT Id, BigMachines__Opportunity__c, Contract_Signature_Date__c, Subscription_End_Date__c 
                                                    FROM BigMachines__Quote__c 
                                                    WHERE BigMachines__Is_Primary__c = true AND BigMachines__Opportunity__c IN: map_OpptyIdLegalExc.keySet()]){
                
                Opportunity tempOpp = new Opportunity(Id = quoteObj.BigMachines__Opportunity__c);
                tempOpp.Contract_Effective_Date__c = Date.valueOf(quoteObj.Contract_Signature_Date__c);
                tempOpp.Contract_Expiration_Date__c = quoteObj.Subscription_End_Date__c;
                
                if(map_OpportunityToUpdate.containsKey(quoteObj.BigMachines__Opportunity__c)){
                    if(map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Effective_Date__c  == null || 
                            map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Effective_Date__c < tempOpp.Contract_Effective_Date__c){
                        map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Effective_Date__c = tempOpp.Contract_Effective_Date__c;
                    }
                    if(map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Expiration_Date__c == null ||
                            map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Expiration_Date__c < tempOpp.Contract_Expiration_Date__c){
                        map_OpportunityToUpdate.get(quoteObj.BigMachines__Opportunity__c).Contract_Expiration_Date__c = tempOpp.Contract_Expiration_Date__c;
                    }
                }else{
                    map_OpportunityToUpdate.put(quoteObj.BigMachines__Opportunity__c, tempOpp);
                }
            }
        }
            
        if(map_OpportunityToUpdate.size() > 0){
            System.debug('---map_OpportunityToUpdate---'+map_OpportunityToUpdate);
            update map_OpportunityToUpdate.values();
        }
        
        if(set_GCRIds.size() > 0){
            Map<Id, Opportunity> map_OpportunityToUp = new Map<Id, Opportunity>();
            Set<Id> set_OppIds = new Set<Id>(); 
            Set<Id> set_RampGCR = new Set<Id>();
            for(GCR__c objGCR : [SELECT Id, (SELECT Id FROM GCR_Details__r WHERE Contract_Category__c = 'Amend' AND Contract_Type__c = 'Service Order' AND Legal_Exceptions__c INCLUDES ('Ramp Period')) FROM GCR__C WHERE Id IN :set_GCRIds ]){
                if(objGCR.GCR_Details__r.size() > 0){
                    set_RampGCR.add(objGCR.Id);
                }
            }
            if(set_RampGCR.size() > 0){
                Map<Id, List<GCR_Content_Document_Detail__c>> map_OpptyIdListContractOthr = new Map<Id, List<GCR_Content_Document_Detail__c>>();
                for(GCR_Content_Document_Detail__c contractDetails : [SELECT Id, GCR__r.Opportunity__c, Legal_Exceptions__c, Expiration_Renewal_Date__c 
                                                                        FROM GCR_Content_Document_Detail__c 
                                                                        WHERE GCR__c IN: set_RampGCR]){
                    if(!map_OpptyIdListContractOthr.containsKey(contractDetails.GCR__r.Opportunity__c)){
                        map_OpptyIdListContractOthr.put(contractDetails.GCR__r.Opportunity__c, new List<GCR_Content_Document_Detail__c>());
                    }
                    map_OpptyIdListContractOthr.get(contractDetails.GCR__r.Opportunity__c).add(contractDetails);
                }
                if(map_OpptyIdListContractOthr.size() > 0){                    
                    map_OpportunityToUp = updateOpportunity(map_OpptyIdListContractOthr, new Map<Id, String>(), false);
                }
            }
            if(map_OpportunityToUp.size() > 0){
                update map_OpportunityToUp.values();
            }
        }
    }
    
    
    private static Map<Id, Opportunity> updateOpportunity(Map<Id, List<GCR_Content_Document_Detail__c>> map_OpptyIdListContract, Map<Id, String> map_OpptyIdContractType, boolean isAll){
        Map<Id, Opportunity> list_OpportunityToUpdate = new Map<Id, Opportunity>();
        for(Id oppId : map_OpptyIdListContract.keySet()){
            Opportunity tempOpp = new Opportunity(Id = oppId);
            String legalEc = '';
            for(GCR_Content_Document_Detail__c contrct : map_OpptyIdListContract.get(oppId)){
                if(isAll && (tempOpp.Contract_Effective_Date__c == null || tempOpp.Contract_Effective_Date__c <= contrct.Effective_Date__c)){
                    tempOpp.Contract_Effective_Date__c = contrct.Effective_Date__c;
                }
                if(tempOpp.Contract_Expiration_Date__c == null || tempOpp.Contract_Expiration_Date__c <= contrct.Expiration_Renewal_Date__c){
                    tempOpp.Contract_Expiration_Date__c = contrct.Expiration_Renewal_Date__c;
                }
                
                if(contrct.Legal_Exceptions__c != null){
                    for(String legal : contrct.Legal_Exceptions__c.split(';')){
                        if(!legalEc.contains(legal)){
                            legalEc += legal + ';';
                        }
                    }
                    legalEc = legalEc.removeEnd(';');
                }                
            }
            if(legalEc != ''){
                tempOpp.Legal_Exceptions__c = legalEc;
                if(!legalEc.contains('None')){
                    tempOpp.MSA_Link__c = '';
                    tempOpp.MSA_Link_Type__c = 'Custom';
                }
                else{
                    tempOpp.MSA_Link_Type__c = 'Standard';
                }
            }
            tempOpp.Is_Governing_Contract__c = true;
            
            if(isAll){
                tempOpp.Contract_Type__c = map_OpptyIdContractType.get(oppId);
            }
            list_OpportunityToUpdate.put(oppId, tempOpp);
        }
        return list_OpportunityToUpdate;
    }
}