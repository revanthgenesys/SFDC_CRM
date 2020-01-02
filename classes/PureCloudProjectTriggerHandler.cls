/************************************************************************************
Purpose : Handler class for triggers related to PureCloud Project object
Written By : Ranjith Punneli
Test Classes : PureCloudProjectTest
*************************************************************************************/

public without sharing class PureCloudProjectTriggerHandler {    
    
    public static void updateServicePackage(List<PureCloud_Trial__c> list_NewProjects) {
        
        Set<Id> set_QuoteIds = new Set<Id>();
        Set<String> set_AllServicePackages = new Set<String>();
        Map<Id, List<BigMachines__Quote_Product__c>> map_QuoteToQPs = new Map<Id, List<BigMachines__Quote_Product__c>>();
        
        set_AllServicePackages = PureCloudProjectUtil.getServicePackagesPicklistVals();
        
        for(PureCloud_Trial__c objNewProject : list_NewProjects) {
            set_QuoteIds.add(objNewProject.BMQuote__c);
        }
        System.debug('#####set_QuoteIds: '+set_QuoteIds);
        for(BigMachines__Quote_Product__c objQP : [SELECT Id, Name, BigMachines__Quote__c, BigMachines__Product__c, 
                                                          BigMachines__Product__r.New_Category__c
                                                   FROM BigMachines__Quote_Product__c
                                                   WHERE BigMachines__Quote__c IN :set_QuoteIds
                                                     AND Is_Overage__c = false
                                                     AND Hide_Record__c = false
                                                     AND BigMachines__Product__r.New_Category__c = 'Services']) {
            if(map_QuoteToQPs.containsKey(objQP.BigMachines__Quote__c)) {
                map_QuoteToQPs.get(objQP.BigMachines__Quote__c).add(objQP);
            }
            else {
                map_QuoteToQPs.put(objQP.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c> { objQP});
            }                
        }
        System.debug('#####map_QuoteToQPs: '+map_QuoteToQPs);
        for(PureCloud_Trial__c objNewProject : list_NewProjects) {
            objNewProject.Service_Packages__c = '';
            if(map_QuoteToQPs.containsKey(objNewProject.BMQuote__c)) {
                for(BigMachines__Quote_Product__c objQP : map_QuoteToQPs.get(objNewProject.BMQuote__c)) {
                    System.debug('#####objQP.Name: '+objQP.Name);
                    if(set_AllServicePackages.contains(objQP.Name.toLowerCase())) {
                        objNewProject.Service_Packages__c += objQP.Name + ';';
                    }
                    System.debug('#####Service_Packages__c: '+objNewProject.Service_Packages__c);
                }
            }
            objNewProject.Email_Status__c = 'Pending';
        }       
    }
    
    
     public static void afterInsertUpdate(Map<Id, PureCloud_Trial__c> newMap, Map<Id, PureCloud_Trial__c> oldMap){
        
        List<Order__c> lstPureTrial= new List<Order__c>();
        
        for(PureCloud_Trial__c pureTrial : [Select Id, PS_PM_Email__c, PS_PM_Owner_Name__c, External_Kick_Off_Date__c, Desired_Go_Live_Date__c, BMQuote__c, BMQuote__r.Order__c 
                                                from  PureCloud_Trial__c where Id In : newMap.keySet()]){
            
            if(oldMap != null){
                PureCloud_Trial__c oldPureTrial = oldMap.get(pureTrial.Id);
                if(oldPureTrial.PS_PM_Email__c != pureTrial.PS_PM_Email__c 
                    || oldPureTrial.PS_PM_Owner_Name__c != pureTrial.PS_PM_Owner_Name__c 
                    || oldPureTrial.External_Kick_Off_Date__c != pureTrial.External_Kick_Off_Date__c
                    || oldPureTrial.Desired_Go_Live_Date__c != pureTrial.Desired_Go_Live_Date__c){
                        
                        if(pureTrial.BMQuote__c != null && pureTrial.BMQuote__r.Order__c != null){
                            Order__c ord = new Order__c();
                            ord.Id = pureTrial.BMQuote__r.Order__c;
                            ord.PS_PM_Email__c = pureTrial.PS_PM_Email__c;
                            ord.PS_PM_Owner__c = pureTrial.PS_PM_Owner_Name__c;
                            ord.External_Kick_Off_Date__c = pureTrial.External_Kick_Off_Date__c;
                            ord.Desired_Go_Live_Date__c = pureTrial.Desired_Go_Live_Date__c;
                            lstPureTrial.add(ord);
                            
                        }
                    }
            }else{
                if(pureTrial.BMQuote__c != null && pureTrial.BMQuote__r.Order__c != null){
                    Order__c ord = new Order__c();
                    ord.Id = pureTrial.BMQuote__r.Order__c;
                    ord.PS_PM_Email__c = pureTrial.PS_PM_Email__c;
                    ord.PS_PM_Owner__c = pureTrial.PS_PM_Owner_Name__c;
                    ord.External_Kick_Off_Date__c = pureTrial.External_Kick_Off_Date__c;
                    ord.Desired_Go_Live_Date__c = pureTrial.Desired_Go_Live_Date__c;
                    lstPureTrial.add(ord);     
                }
            }
        }
        
        if(lstPureTrial.size() > 0){
            update lstPureTrial;
        }
    }

    //Mukunthan added below method for CCDB Req JIRA # CRMBILL-403 on 11-APR-2019
    public static void associateActivationEmailAddress(list<PureCloud_Trial__c> triggerNew){
        map<string,string> ppToQuote = new map<string,string>();
        map<string,string> quoteToAOA = new map<string,string>();
        for(PureCloud_Trial__c pprec: triggerNew){
            if(pprec.BMQuote__c != null){
                ppToQuote.put(pprec.BMQuote__c,pprec.Id);
            }
        }
        if(ppToQuote.size()>0){
            map<Id,Account_Order_Address__c> aoaLst = new map<Id,Account_Order_Address__c>([Select Id,Quote__c,PureCloud_Project__c from Account_Order_Address__c 
                                                                            where Address_Type__c = 'Activation Email' AND Quote__c IN:ppToQuote.keyset()]);
            if(aoaLst.size()>0){
                    for(Account_Order_Address__c aoaRec:aoaLst.values()){
                        aoaRec.PureCloud_Project__c = ppToQuote.get(aoaRec.Quote__c);
                    }
                    update aoaLst.values();
            }
            
        }
    }
}