/*Naresh    08/29/2013  Created 

04/03/2017    Swastika Rajkhowa    Update Gainsight Relationship Type
Description   : This trigger assign Gainsight Relationship Type value on the basis of Platform type, offering Type, Primary solution
02/07/2018  Navaneetha Commented the GainSight Relationshp type
Description :Gainsight Relationship Type value on the basis of Platform type, offering Type, Primary solution has been added to 
OpportunityUtil.updatePlatformAndOfferingType method.
05/28/2019 - line 162-176 added for cloud renewal runrate calculation when its forecast status changed to 0.Booked
Code coverage use OpportunityQuotes_Test testclass.
*/
trigger OpportunityMain on Opportunity(after delete, after insert, after undelete,
                                       after update, before delete, before insert, before update) {
                                           //Naresh    08/29/2013  Code to override big six
                                           System.debug('Bypass Check' + Util.Bypass_Trigger_Chk);
                                           if (Util.Bypass_Trigger_Chk) return;
                                           
                                           /*
* Added By: Ashish Goyal (08/27/018)
* Desc: To manage the Opportunity Team Member whenever Solt To/Business Partner is populated/updated on the Opportunity
* Requested By: Debbie
*/
                                           if(trigger.isAfter && trigger.isInsert){
                                               PartnerOpportunityHelper.addOpportunityTeamMember(trigger.new, trigger.oldMap, true);
                                           }
                                           
                                           if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
                                               for (Opportunity eachOpp: trigger.new) {
                                                   if (eachOpp.Override_Big_Six__c != null) {
                                                       eachOpp.Quote_Big_Six__c = eachOpp.Override_Big_Six__c;
                                                   }
                                               }

                                               // NikM: April 2019: Added for RevPro PS Checking
                                               if (trigger.isInsert || trigger.isUpdate)
                                               {
                                                   if(checkOpportunityRecursive.runBeforeUpdateOnce())
                                                   {
                                                       OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(trigger.new, null);
                                                   }
                                               }

                                               if (trigger.isInsert) {
                                                   OpportunityFieldPopulationHelper.populateFieldsOnInsert(trigger.new);
                                               }
                                               if (trigger.isInsert)
                                                   OpportunityOwnershipHandler.updateOpportunityOwner(trigger.new, null);
                                               else
                                                   OpportunityOwnershipHandler.updateOpportunityOwner(trigger.new, trigger.oldMap);
                                               
                                               //Naresh Kumar 04/03/2018 - Populates currency lookup on opportunity
                                               if (trigger.isInsert) {
                                                   OrderFieldPopulationHelper.populateCurrnecyRateLookup(trigger.new, null);
                                                   OpportunityUtil.updatePlatformAndOfferingType(trigger.new, null);
                                               } else {
                                                   OrderFieldPopulationHelper.populateCurrnecyRateLookup(trigger.new, trigger.oldMap);
                                                   OpportunityUtil.updatePlatformAndOfferingType(trigger.new, trigger.oldMap);
                                               }
                                               
                                               //  OpportunityFieldPopulationHelper.updateGainsightRelation(Trigger.new); //Added by Swastika on 04/03/2017 to assign GainSight Relation type  
                                               
                                               if (trigger.isUpdate) {
                                                   //Added on June 25th for Calculation of Renewal Change vs Run Rate USD.
                                                   //Added on June 25th for Calculation of Renewal Change vs Run Rate USD.
                                                   Map<Id, Opportunity> map_OppIdToOpptoProcess = new Map<Id,Opportunity>();
                                                   
                                                   for(Opportunity objOpp: trigger.new){
                                                       if(objOpp.Lead_Offer__c == 'PureCloud'||objOpp.Lead_Offer__c == 'PureConnect Cloud' || objOpp.Lead_Offer__c =='PureEngage Cloud' || (objOpp.StageName== '6.Closed' && (objOpp.Lead_Offer__c == 'PureCloud' || objOpp.Lead_Offer__c == 'PureConnect Cloud' || objOpp.Lead_Offer__c =='PureEngage Cloud')))   // Added by navaneetha for runrate
                                                           // if(objOpp.Lead_Offer__c == 'PureCloud'||objOpp.Lead_Offer__c == 'PureConnect Cloud')    
                                                       {
                                                           map_OppIdToOpptoProcess.put(objOpp.Id,objOpp);
                                                       }
                                                   }
                                                   if(map_OppIdToOpptoProcess.size() > 0){OpportunityCloudUtil.updateRenewalRunRate( map_OppIdToOpptoProcess);}
                                               }
                                           }
                                           //Naresh    12/11/2013  
                                           if (trigger.isAfter && trigger.isInsert) {
                                               OpportunityFieldPopulationHelper.createContactRole(trigger.new);
                                               //Naresh 04/11/2017
                                               PartnerOpportunityHelper.populatePartnerOpportunityOnInsert(trigger.new);
                                           }
                                           //Naresh  07/10/2014
                                           if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
                                               if (TriggerFlowManager.POPULATE_PARENT_OPP_FIELDS) {
                                                   if (trigger.isInsert)
                                                       OpportunityFieldPopulationHelper.populateParentOppDetails(trigger.new, null);
                                                   else
                                                       OpportunityFieldPopulationHelper.populateParentOppDetails(trigger.new, trigger.oldMap);
                                               }
                                               // Justin Hawkins 5/16/2017 - PureCloud Monthly Mimimum and Ramp Period Mirgration from ININ
                                               // Naresh Kumar   06/20/2017  Commenting below part as we need to deploy this class to UAT. Please uncomment if needed.
                                               OpportunityPureCloudManagement.pureCloudOppManagement(Trigger.oldMap, Trigger.new);
                                           }
                                           //Naresh  04/11/2014
                                           if (trigger.isAfter && trigger.isUpdate) {
                                               
                                               //Commented by JJ on 08/20/2018 to stop creating the SC from Opportunity
                                               //As requested by Ankit and Sourav
                                               //system.debug('##Enter SC Code  -- ' + TriggerFlowManager.GENERATE_OPPORTUNITY_QUOTE_SC);
                                               /*
if (TriggerFlowManager.GENERATE_OPPORTUNITY_QUOTE_SC) {
TriggerFlowManager.GENERATE_OPPORTUNITY_QUOTE_SC = false;
system.debug('##Enter SC Condition');
CloudQuoteUtil.initCreateServiceContract(trigger.newMap, trigger.oldMap);
}
*/
                                               
                                               
                                               system.debug('+++++Opp main trigger++++');
                                               OpportunityFieldPopulationHelper.updateTotalsOnTermChange(trigger.newMap, trigger.oldMap);
                                               OpportunityFieldPopulationHelper.shareQuoteAccess(trigger.newMap, trigger.oldMap);
                                               OpportunityFieldPopulationHelper.updateOpportunityTypeOnNewLogoCloseWon(trigger.new, trigger.oldMap);
                                                //Muthu : Added code for FCCR DSR Enhancement
                                               OpportunityFieldPopulationHelper.updateFCCROnClosedLost(trigger.new, trigger.oldMap);                                               
                                               /*
* Added By: Ashish Goyal (08/16/018)
* Desc: To manage the Opportunity Team Member whenever Solt To/Business Partner is populated/updated on the Opportunity
* Requested By: Debbie
*/
                                               PartnerOpportunityHelper.addOpportunityTeamMember(trigger.new, trigger.oldMap, false);
                                               
                                               OpportunityFieldPopulationHelper.updateOpportunityRecordType(trigger.newMap, trigger.oldMap);
                                               //Updating legal contract's status if required
                                               OpportunityFieldPopulationHelper.updateLegalContractStatus(trigger.new, trigger.oldMap);
                                               //Sends notification to an alias if closed opportunity's amount is modified
                                               OpportunityPriceChangeNotificationHelper.sendClosedOppNotification(trigger.new, trigger.oldMap);
                                           }
                                           //Naresh    12/29/2015
                                           if (trigger.isAfter && trigger.isUpdate && !System.isFuture() && !System.isBatch()) {
                                               SMLHelperWTS.runSMLUpdateForOpportunityStageChange(trigger.new, trigger.oldMap);
                                           }
                                           
                                           system.debug('+++Onboarding - Automation+++');
                                           //Onboarding - Automation
                                           if (Trigger.isAfter) {
                                               //Naresh 10/06: Please fix below line of code. It is failing in case of after insert where a trigger.old[0] is not available
                                               
                                               if (Trigger.isInsert) {
                                                   //OnBoardingAndOfferingType.OnBoarding(trigger.new[0],null,Trigger.isInsert); 
                                               }
                                               if (Trigger.isUpdate) {
                                                   OnBoardingAndOfferingType.OnBoarding(trigger.new[0], trigger.old[0], false);
                                                   // Pankaj Pandey 12/04/2017 for Cloud Deployment implementation
                                                   //Commented by Ranjith on Jan 25, 2018. Cloud Deployment record creation for PureCloud is handled by PC team
                                                   //clsOpportunityTriggerHelper.CreateCloudDeployment(trigger.newmap, trigger.oldmap);
                                                   
                                                   //Naresh Kumar - Commenting as part of deployment on 06/12.
                                                   //Anju June 1 CCDB
                                                   //OpportunityUtil.UpdateLegalDealReviewonOpportuntiy(Trigger.oldMap,Trigger.newMap);
                                                   //OpportunityUtil.UpdateSubscriptionFromOpportunity(Trigger.oldMap,Trigger.newMap);
                                               }
                                           }
                                           
                                           if (trigger.isAfter && trigger.isUpdate && VariousOPPNotification.isStopDesign) {
                                               //Send email notification if OPP has SCE DSR but Design is missing 04/17/2018
                                               VariousOPPNotification.SendNotificationforMissingDesign(Trigger.newMap, Trigger.oldMap);
                                           }
                                           
                                           if (trigger.isAfter && trigger.isUpdate && VariousOPPNotification.isStopRFP) {
                                               //Send email notification is OPP is Closed and status is Merged Dedup and corresponding RFP is not completed
                                               VariousOPPNotification.RFPNotifications(Trigger.newMap, Trigger.oldMap);
                                           }
                                           
                                           if (trigger.isAfter && trigger.isUpdate) {
                                               // @Start: Changes on 5/11 as requested by Debora
                                               // @desc: To update Pre Sales Priority on DSR SC Engagement whenever it's getting update on Opportunity
                                               DSRUtility.updateOnSCEngagementToPreSalesPriority(Trigger.new, Trigger.oldMap);
                                               
                                                // Added By Ashsih (10/31/2018), on request of Debbie to send the notification to SC and SRL when OPP is closed 
                                               //with SCE DSR Status = Open and Assigned
                                               DSRUtility.sendNotificationtoSCSRL(trigger.newMap, trigger.oldMap);
                                                                                              
                                               //Added by Navaneetha
                                                Set<Id> opsId = new Set<id>();
                                              for(Opportunity objOpps: trigger.new){       
                                               if(objOpps.ForecastStatus__c != trigger.oldMap.get(objOpps.id).ForecastStatus__c){                                                                                              
                                                //if(objOpps.ForecastStatus__c == '0.Booked'&&  (objOpps.RecordTypeid == AccRecordTypeId) && (objOpps.Lead_Offer__c == 'PureCloud' || objOpps.Lead_Offer__c == 'PureConnect Cloud')){
                                                    if(objOpps.ForecastStatus__c == '0.Booked'&&  (objOpps.Lead_Offer__c == 'PureCloud' || objOpps.Lead_Offer__c == 'PureConnect Cloud')){
                                                 opsId.add(objOpps.id);  
                                                      
                                               }
                                              }
                                               }
                                               if(opsId.size()>0){
                                               OpportunityCloudUtil.updateRunRate(opsId);
                                               }
                                               //END Navaneetha
                                           }
                                           //Added for opportunity teammember
                                           if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
                                               if (Trigger.isInsert) {
                                                   Map < id, opportunity > tempoppty = new Map < id, opportunity > ();
                                                   PartnerPortalOptyRegUtil.updateopportunityteammember(trigger.new, tempoppty, 'insert');
                                               } else {
                                                   
                                                   PartnerPortalOptyRegUtil.updateopportunityteammember(trigger.new, Trigger.oldmap, 'update');
                                               }
                                           }
                                           
                                           //code end    
                                           
                                           //Added by navaneetha to update the opp close date with order creation date.
                                           //
                                           /*  if (trigger.isbefore && trigger.isupdate) {

PartnerPortalOptyRegUtil.updateopportunityclosedate(trigger.new, Trigger.oldmap);
//system.debug('Testnavaneetha2');
} */
                                           //Code ended 
                                           //Inserted for Hard delete
                                            if(trigger.isDelete && trigger.isBefore)
                                           {   
                                             ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'Delete'));
                                           }  
                                          if(trigger.isUnDelete && trigger.isAfter)
                                          {   
                                            ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.newMap,'Restore'));
                                          }                                       
                                       }