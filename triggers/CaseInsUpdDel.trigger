/*****************************************************
Trigger: CaseInsUpdDel
Author � Vinay Lakshmeesh
Date � 3/4/2013
Usage : Set End User and Sold using Support Access, when case is created from portal 
        ( Rashmi K - Added CaseUtil service class )
Revision History
Test class: CaseSaveController_Test
******************************************************/

trigger CaseInsUpdDel on Case (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
        
   if(Util.Bypass_Trigger_Chk)return;

  String queuePrefix = 'OOG';   //  Bypass workload calc for Queue owned cases
  Set<id> userIdsToScore = new Set<id>{};

//  INSERT  

    if (trigger.isInsert){
    
    //  ------------------------------------------------------------------------------------------------------------------------
    //  BEFORE INSERT
    //  ------------------------------------------------------------------------------------------------------------------------
    
        if(trigger.isBefore) {
            CaseUtil.getEntitlementsOnCaseSetBH(trigger.new);       
           CaseUtil.setProductSupportGroup(trigger.new, null);           
           CaseUtil.setHighestLevelOfService(trigger.new, null); 
           CaseUtil.setAutoFollowupDate(trigger.new, null);
                                  
           CaseSLTHandler.updateCaseSLTFields(null,trigger.new, trigger.isInsert);                           
        }
           
    //  ------------------------------------------------------------------------------------------------------------------------    
    //  AFTER INSERT
    //  ------------------------------------------------------------------------------------------------------------------------   
  
    }
    
//  UPDATE

    if (Trigger.isUpdate) {
    
    
    //  ------------------------------------------------------------------------------------------------------------------------
    //  AFTER UPDATE
    //  ------------------------------------------------------------------------------------------------------------------------            
        if(Trigger.isAfter){         
        }    
    
    //  ------------------------------------------------------------------------------------------------------------------------
    //  BEFORE UPDATE
    //  ------------------------------------------------------------------------------------------------------------------------        

        if(trigger.isBefore){
            //Prevent users from closing a case if there are open activities associated with the case of record type escalation
            CaseUtil.checkOpenAcivity(trigger.new, trigger.oldMap);                
            CaseUtil.setHighestLevelOfService(trigger.new, trigger.oldMap); 
             ///MS Aug 14, 2018
            CaseUtil.setProductSupportGroup(trigger.new, trigger.oldMap);  
            
            CaseUtil.setLastOwnerChangeDate(trigger.new, trigger.oldMap); 
            CaseUtil.setAutoFollowupDate(trigger.new, trigger.oldMap);    
                   
            CaseUtil.updateBusinessHours(trigger.oldMap, trigger.new);
            
           CaseSLTHandler.updateCaseSLTFields(trigger.oldMap, trigger.new, false);  
           
        } 
      } 
      
          /// do not allow delete unless profile is System Administrator
      if(trigger.isDelete){
        
        if(trigger.isBefore){
            
            /*Integer admin = [SELECT count() FROM Profile p WHERE ID in 
                              (SELECT u.ProfileId From User u WHERE ID = :UserInfo.getUserId())
                             AND p.name IN ('System Administrator','Data Admin')];
                              
            if ( admin == 0 ) {*/
            //Anju May 11 : Only users or profiles with Delete case custom permissions can delete case.
            if(!FeatureManagement.checkPermission('Delete_Case'))
            {
                for (Case c : Trigger.old) {
                    c.addError('Only Aministrator can delete a Case');
                } 
            }  
        }     
    }      
}