/*
 * Trigger          : CaseTriggerSupportCaseCertifiedContactInfo  
 * Description      : This Trigger updates info about whether the case has been logged by Certified Contact or not. 
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 26, 2016 
 * Test Class       : CaseTriggerCaseCertifiedContactInfoTest
 *  
 */
trigger CaseTriggerSupportCaseCertifiedContactInfo  on Case (before insert) {
   if(Util.Bypass_Trigger_Chk)
       return; 
    
   String supportRecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId();
    
    Set<String> contactIDs = new Set<String>();
    // Collect all Contact Ids on the Case Objects
    Boolean isSupportCase = false;
    for(Case c : Trigger.New){
        if(c.RecordTypeId == supportRecordTypeId){
            isSupportCase = true;
            if(c.ContactId != NULL)
                contactIDS.add(c.ContactId);
        }
    }

    // if atleast one support case exits and those supports cases has contacts then process further 
    if(isSupportCase && contactIDS.size() > 0){
        Map<String, String> contactViewCentralIDsMap = new Map<String, String>();
        for(Contact con: [SELECT id, ViewCentral_ID__c FROM Contact WHERE Id IN : contactIDS]){
            if(!String.isBlank(con.ViewCentral_ID__c))
                contactViewCentralIDsMap.put(con.Id, con.ViewCentral_ID__c);
        }

        if(contactViewCentralIDsMap.size() > 0){
            Map<String, List<Partner_Certifications__c>> contactCertifications = new Map<String, List<Partner_Certifications__c>>();
            for(Partner_Certifications__c pc : [SELECT id, ViewCentral_Contact_ID__c, Test_Date__c, Expiry_Date__c FROM Partner_Certifications__c 
                                                WHERE ViewCentral_Contact_ID__c IN :contactViewCentralIDsMap.values() AND Expiry_Date__c >= TODAY])
            {
                if(contactCertifications.containsKey(pc.ViewCentral_Contact_ID__c)){
                    contactCertifications.get(pc.ViewCentral_Contact_ID__c).add(pc);
                } else {
                    contactCertifications.put(pc.ViewCentral_Contact_ID__c, new List<Partner_Certifications__c>{pc});
                }                                                     
            }
    
            for(Case c : Trigger.New){
                if(c.RecordTypeId == supportRecordTypeId){
                    if(c.ContactId != NULL && contactViewCentralIDsMap.get(c.ContactId) != NULL && contactCertifications.keySet().contains(contactViewCentralIDsMap.get(c.ContactId))){
                        c.GU_Certified_Contact__c = 'Yes';
                        c.Case_Logged_by_GU_Certified_Contact__c = 'Yes';
                    } else {
                        c.GU_Certified_Contact__c = 'No';
                        c.Case_Logged_by_GU_Certified_Contact__c = 'No'; 
                    }
                }
            }
        }
        
    }    
}