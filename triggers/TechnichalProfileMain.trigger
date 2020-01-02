//Naresh Kumar
trigger TechnichalProfileMain on Technical_Profile__c (after insert, after update) {
    if(Util.Bypass_Trigger_Chk) return;    
    
    SMLHelperWTS.populateTechnichalProfileCompetitors(trigger.new);
    
    //Added by Swastika on Oct-18-2016 to update the score1 and score2 of SC engagement Request<start>      
    // list<Wow_Request_Form__c> list_wow=[SELECT Id,Score__c,Technical_Profile_Acknowledgement_Date__c,WoW_Status__c FROM Wow_Request_Form__c WHERE Account_Id__c=:string.valueof(trigger.new[0].Account__c).substring(0,15)];
    System.debug('trigger.new[0].Account__c = ' + trigger.new[0].Account__c); 
    list<Wow_Request_Form__c> list_wow=[SELECT Id,Score__c,Technical_Profile_Acknowledgement_Date__c,WoW_Status__c FROM Wow_Request_Form__c WHERE Opportunity_Id__r.AccountId =:trigger.new[0].Account__c];
    System.debug(LoggingLevel.INFO,'list_wow'+list_wow); 
    if(list_wow.size()>0)
        {
        for(Wow_Request_Form__c objwow: list_wow)
            {
            objwow.Score__c = (trigger.new[0].Score1__c == null ? 0 : trigger.new[0].Score1__c)  + (trigger.new[0].Score2__c == null ? 0 : trigger.new[0].Score2__c) ;
            if(objwow.WoW_Status__c!='Completed')
                objwow.Technical_Profile_Acknowledgement_Date__c= trigger.new[0].Technical_Profile_Acknowledgment_Date__c;
                objwow.ByPass_Validation_Rule__c=true;
            }
          update list_wow;  
        }
    //Added by Swastika on Oct-18-2016 to update the score1 and score2 of SC engagement Request<end>
    
    //Added by Swastika on Oct-18-2016 to update the score of POC engagement Request<start>      
    list<POC_Engagement_Request__c> list_POC=[SELECT Id,Score__c,Technical_Profile_Acknowledgement_Date__c,POC_Status__c FROM POC_Engagement_Request__c WHERE Opportunity_Id__r.AccountId =:string.valueof(trigger.new[0].Account__c).substring(0,15)];
    System.debug(LoggingLevel.INFO,'list_wow'+list_wow); 
    if(list_wow.size()>0)
        {
        for(POC_Engagement_Request__c objPOC: list_POC)
            {
            objPOC.Score__c = (trigger.new[0].Score1__c == null ? 0 : trigger.new[0].Score1__c)  + (trigger.new[0].Score2__c == null ? 0 : trigger.new[0].Score2__c) ;
            if(objPOC.POC_Status__c!='Completed')
                objPOC.Technical_Profile_Acknowledgement_Date__c= trigger.new[0].Technical_Profile_Acknowledgment_Date__c; 
            }
          update list_POC;  
        }
    //Added by Swastika on Oct-18-2016 to update the score of POC engagement Request<end>
    
    }