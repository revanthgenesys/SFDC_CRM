/*
    Naresh Kumar
    Populates fields on Opportunity

    04/03/2017    Swastika Rajkhowa    Update Gainsight Relationship Type
    Description   : Class is called from Opportunity trigger (before insert and before update) to assign Gainsight Relationship Type value on the basis of Platform type, offering Type, Primary solution
    Test Class    : OpportunityFieldPopulationHelper_Test

    Oct 2018      Nik Mills - Updated with additional GU items, and also included details of test class for deployment/code coverage
*/
public without sharing class OpportunityFieldPopulationHelper {

    public static void populateFieldsOnInsert(List < Opportunity > newList) {
        Map < Id, Account > mapAccIdVsAccount = new Map < Id, Account > ();
        Set < Id > accIds = new Set < Id > ();
        for (Opportunity eachOpp: newList) {
            accIds.add(eachOpp.accountId);
        }
        /* Updated by Lokesh Pareek - Added  field PC_Contracted_Maintenance_Start_Date__c */
        List < Account > oppAccounts = [SELECT id, Genesys_Care_Offering__c, Genesys_Care_Ops__c, Genesys_Care_specialist__c,PC_Contracted_Maintenance_Start_Date__c
            FROM Account WHERE id IN: accIds];
        for (Account eachAcc: oppAccounts) {
            mapAccIdVsAccount.put(eachAcc.id, eachAcc);
        }
       /* List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME
        ];*/

        //Id rtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME).getRecordTypeId();
        ID cloudRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cloud_Renewal').getRecordTypeId();
        // Added by Kartik as requested by Vivek for Populating Genesys care fields for Cloud Renewal.
        for (Opportunity eachOpp: newList) {
            /* Lokesh - Dec 02, 2019
            ** Update condition from
            ** if ((eachOpp.RecordTypeId == rtypeId || eachOpp.RecordTypeId == cloudRecType) && mapAccIdVsAccount.get(eachOpp.accountId) != null)
            ** Description - ServiceContractUtils.createRenewalOpportunities method handles the renewal opportunity creation
            ** and this trigger logic was overriding the field population logic. Now for renewal opportunity field population is
            ** handled at one place in ServiceContractUtil.cls
            */
            if (eachOpp.RecordTypeId == cloudRecType && mapAccIdVsAccount.get(eachOpp.accountId) != null) {
                //Lokesh Dec 02, 2019 - Commented field population logic - Quote_Genesys_Care__c [Now handled in ServiceContractUtil.createRenewalOpportunity]
                //if(eachOpp.RecordTypeId != cloudRecType){eachOpp.Quote_Genesys_Care__c = mapAccIdVsAccount.get(eachOpp.accountId).Genesys_Care_Offering__c;}
                eachOpp.Quote_Mtce_Ops__c = mapAccIdVsAccount.get(eachOpp.accountId).Genesys_Care_Ops__c;
                eachOpp.Gene_Care_Specialist__c = mapAccIdVsAccount.get(eachOpp.accountId).Genesys_Care_specialist__c;
            }
        }
    }

    public static void updateOpportunityTypeOnNewLogoCloseWon(List < Opportunity > newList, Map < Id, Opportunity > oldMap) {
        Set < Id > accountIds = new Set < Id > ();
        Set < Id > oppIds = new Set < Id > ();
        //Looping over each Opportunity
        for (Opportunity eachOpp: newList) {
            if (eachOpp.Type == 'New logo' &&
                (eachOpp.StageName == '6.Closed' && eachOpp.Win_Loss_Status__c == 'Won' &&
                    (oldMap.get(eachOpp.id).StageName != '6.Closed' || eachOpp.Win_Loss_Status__c != 'Won'))) {
                accountIds.add(eachOpp.accountId);
                oppIds.add(eachOpp.id);
            }
        }
        if (accountIds.isEmpty())
            return;
        List < Opportunity > oppsToBeUpdated = [SELECT Type FROM Opportunity WHERE accountId =: accountIds
            AND id NOT IN: oppIds AND StageName != '6.Closed'
            AND Type = 'New logo'
        ];
        //Looping over opps to be updated
        for (Opportunity eachOpp: oppsToBeUpdated) {
            eachOpp.Type = 'Existing Business - Cross Sell';
        }
        Util.Bypass_Trigger_Chk = true;
        update oppsToBeUpdated;
        Util.Bypass_Trigger_Chk = false;
    }


        //25-10-19 Muthu Added below code for DSR Enhancement

    public static void updateFCCROnClosedLost(List < Opportunity > newList, Map < Id, Opportunity > oldMap) {
        Set < Id > oppIds = new Set < Id > ();
        //Looping over each Opportunity
        for (Opportunity eachOpp: newList) {
            if (eachOpp.StageName == '6.Closed' && eachOpp.Win_Loss_Status__c == 'Lost' &&
                    (oldMap.get(eachOpp.id).StageName != '6.Closed' || eachOpp.Win_Loss_Status__c != 'Lost')) {
                      oppIds.add(eachOpp.Id);
            }
        }
        if(oppIds.size()>0){
            updateFCCR FCCRList = new updateFCCR(oppIds);
            // enqueue the job for processing
            ID jobID = System.enqueueJob(FCCRList);
            system.debug('<----Job_ID---->: '+jobID);

        }
     }

    //25-10-19 Muthu Code ends here

    public static void updateLegalContractStatus(List <Opportunity> newList, Map <Id, Opportunity> oldMap) {
        Set<Id> setOfOppIds = new Set<Id> ();
        //Looping over each Opportunity
        for (Opportunity eachOpp: newList) {
            Opportunity oldOpp = oldMap.get(eachOpp.id);
            if((eachOpp.ForecastStatus__c == '0.Booked' && eachOpp.Win_Loss_Status__c == 'Won') &&
                (oldOpp.ForecastStatus__c != '0.Booked' || oldOpp.Win_Loss_Status__c != 'Won')){
                setOfOppIds.add(eachOpp.id);
            }
        }
        if (setOfOppIds.isEmpty())
            return;

        List<GCR_Content_Document_Detail__c> listOfContracts = [SELECT id, Quote__c, Status__c FROM GCR_Content_Document_Detail__c
            WHERE Opportunity__c IN : setOfOppIds];

        if(listOfContracts.isEmpty())
            return;

        for(GCR_Content_Document_Detail__c eachContract : listOfContracts)
               eachContract.Status__c = 'Final';

        Util.Bypass_Trigger_Chk = true;
        update listOfContracts;
        Util.Bypass_Trigger_Chk = false;
    }

    public static void createContactRole(List < Opportunity > opps) {
        List < OpportunityContactRole > newRolesToBeInserted = new List < OpportunityContactRole > ();
        for (Opportunity eachOpp: opps) {
            if (eachOpp.Associated_Contact_Record_Id__c == null)
                continue;
            OpportunityContactRole newRole = new OpportunityContactRole();
            newRole.ContactId = eachOpp.Associated_Contact_Record_Id__c;
            newRole.OpportunityId = eachOpp.id;
            newRole.Role = 'Approver';
            newRole.IsPrimary = true;
            newRolesToBeInserted.add(newRole);
        }
        if (!newRolesToBeInserted.isEmpty())
            insert newRolesToBeInserted;
    }

    public static void populateParentOppDetails(List < Opportunity > newOpps, Map < Id, Opportunity > oldMap) {
        Map < Id, Opportunity > mapOppParentIdVsParentOpp = new Map < Id, Opportunity > ();
        Map < Id, Opportunity > mapCurrentOpps = new Map < Id, Opportunity > ();
        Set < Id > accountIds = new Set < Id > ();
        Set < Id > oppIds = new Set < Id > ();
      //  Id psRecordTypeID;
    /*    List < RecordType > psRecordType = [SELECT id FROM RecordType WHERE SObjectType = 'Opportunity'
            AND DeveloperName =: 'Professional_Services'
        ];
        if (psRecordType.isEmpty()) {
            TriggerFlowManager.POPULATE_PARENT_OPP_FIELDS = false;
            return;
        }*/
       Id psRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();


      //  Id guRecordTypeID;
      /*  List < RecordType > guRecordType = [SELECT id FROM RecordType WHERE SObjectType = 'Opportunity'
            AND DeveloperName =: 'Genesys_University'];
        if (guRecordType.isEmpty()) {
            TriggerFlowManager.POPULATE_PARENT_OPP_FIELDS = false;
            return;
        }*/
       Id guRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Genesys_University').getRecordTypeId();


        //
        for (Opportunity eachOpp: newOpps) {
            oppIds.add(eachOpp.id);
            if ((eachOpp.RecordTypeId == psRecordTypeID || eachOpp.RecordTypeId == guRecordTypeID) && eachOpp.ParentOpportunity__c != null) {
                mapOppParentIdVsParentOpp.put(eachOpp.ParentOpportunity__c, null);
                mapCurrentOpps.put(eachOpp.id, null);
            }
            if ((eachOpp.RecordTypeId == psRecordTypeID || eachOpp.RecordTypeId == guRecordTypeID) && eachOpp.AccountId != null) {
                accountIds.add(eachOpp.AccountId);
            }
        }
        if (mapOppParentIdVsParentOpp.keyset().isEmpty() && accountIds.isEmpty()) {
            TriggerFlowManager.POPULATE_PARENT_OPP_FIELDS = false;
            return;
        }
        //List<Contact> contacts = [SELECT id, AccountId FROM Contact WHERE id IN : mapContactIdVsAccountId.keyset()];
        //for(Contact eachContact : contacts){
        //  mapContactIdVsAccountId.put(eachContact.id, eachContact.AccountId);
        //}
        Map < Id, Account > mapAccIdVsAccount = new Map < Id, Account > ([SELECT ownerId, Country__c FROM Account WHERE id in: accountIds]);
        List < Opportunity > parentOpps = [SELECT id, AccountId, AE_Name__c, License_Amount__c, Country__c, Sold_To_Country__c, BusinessPartner__c,
            BusinessPartner__r.Country__c,
            Direct_Sales__c, NumberofAgents__c, ownerId, Contact__c, Account.ownerid, Account.Country__c FROM Opportunity WHERE id IN: mapOppParentIdVsParentOpp.keyset()
        ];
        newOpps = [SELECT RecordTypeId, BusinessPartner__r.Country__c, ParentOpportunity__c, BusinessPartner__c, Contact__c, Direct_Sales__c,
            Country__c, AccountId, PS_Region__c, Sold_To_Country__r.Name, BusinessPartner__r.Country__r.Name, country__r.Name
            FROM Opportunity WHERE id IN: oppIds
        ];


        for (Opportunity eachOpp: parentOpps) {
            mapOppParentIdVsParentOpp.put(eachOpp.id, eachOpp);
        }

        List < Opportunity > currOpps = [select id, Account.ownerid, Account.Country__c, Account.Country__r.Name from opportunity where id in: newOpps];
        for (Opportunity currOpp: currOpps) {
            mapCurrentOpps.put(currOpp.id, currOpp);
        }




        List < OpportunityTeamMember > oppTMToBeAdded = new List < OpportunityTeamMember > ();
        List < Opportunity > oppsToBeUpdated = new List < Opportunity > ();
        for (Opportunity eachOpp: newOpps) {

            if (eachOpp.RecordTypeId == psRecordTypeID || eachOpp.RecordTypeId == guRecordTypeID) {
                String OppUpdateSoldToCountryName;
                Opportunity parentOpp = mapOppParentIdVsParentOpp.get(eachOpp.ParentOpportunity__c);
                Opportunity currOpp = mapCurrentOpps.get(eachOpp.id);
                Opportunity oppToUpdate = new Opportunity(id = eachOpp.id);
                oppToUpdate.AE_Name__c = currOpp.Account.ownerid;
                oppToUpdate.Country__c = currOpp.Account.Country__c;

                if (eachOpp.Direct_Sales__c) {
                    oppToUpdate.Sold_To_Country__c = currOpp.Account.Country__c;
                    OppUpdateSoldToCountryName = currOpp.Account.Country__r.Name;
                    oppToUpdate.BusinessPartner__c = currOpp.Account.id;
                }

                if (oldMap == null && eachOpp.ParentOpportunity__c != null) {
                    //oppToUpdate.Sold_To_Country__c = parentOpp.Sold_To_Country__c;
                    //oppToUpdate.AccountId = parentOpp.AccountId;
                    //oppToUpdate.Contact__c = parentOpp.Contact__c;
                    oppToUpdate.License_Amount__c = parentOpp.License_Amount__c;
                    oppToUpdate.Direct_Sales__c = parentOpp.Direct_Sales__c;

                    oppToUpdate.BusinessPartner__c = parentOpp.BusinessPartner__c;
                    oppToUpdate.NumberofAgents__c = parentOpp.NumberofAgents__c;

                    OpportunityTeamMember newTM = new OpportunityTeamMember();
                    newTM.OpportunityId = oppToUpdate.id;
                    newTM.TeamMemberRole = 'Team Role';
                    newTM.UserId = parentOpp.ownerId;
                    oppTMToBeAdded.add(newTM);
                }

                // NikM: May2017 - Added to set Sold to country from business partner if this is a new record (no previous map from trigger)
                if (eachOpp.BusinessPartner__c != null && oldMap == null) {
                    oppToUpdate.Sold_To_Country__c = eachOpp.BusinessPartner__r.Country__c;
                    OppUpdateSoldToCountryName = eachOpp.BusinessPartner__r.Country__r.Name;
                    System.debug('NLM debug oppToUpdate.Sold_To_Country__c [' + oppToUpdate.Sold_To_Country__c + ']');
                }

                if (eachOpp.BusinessPartner__c != null && oldMap != null && eachOpp.Sold_To_Country__c == null) {
                    oppToUpdate.Sold_To_Country__c = eachOpp.BusinessPartner__r.Country__c;
                    OppUpdateSoldToCountryName = eachOpp.BusinessPartner__r.Country__r.Name;
                    System.debug('NLM debug oppToUpdate.Sold_To_Country__c [' + oppToUpdate.Sold_To_Country__c + ']');
                }

                if (eachOpp.BusinessPartner__c != null && oldMap != null && eachOpp.BusinessPartner__c != oldMap.get(eachOpp.id).BusinessPartner__c) {
                    oppToUpdate.Sold_To_Country__c = eachOpp.BusinessPartner__r.Country__c;
                    OppUpdateSoldToCountryName = eachOpp.BusinessPartner__r.Country__r.Name;

                    System.debug('NKC debug oppToUpdate.Sold_To_Country__c [' + oppToUpdate.Sold_To_Country__c + ']');
                }

                if (eachOpp.Direct_Sales__c && oldMap != null && eachOpp.Direct_Sales__c != oldMap.get(eachOpp.id).Direct_Sales__c) {
                    oppToUpdate.BusinessPartner__c = eachOpp.accountId;
                    oppToUpdate.Sold_To_Country__c = eachOpp.Country__c;
                    OppUpdateSoldToCountryName = eachOpp.Country__r.Name;
                }

                // NikM: Jun 2017 - (req#33997) - Check the region and sold to country now, and if necessary set the PS Oppty Subsidiary override field
                // The following PS Subsidiary override is no longer required as this will be handled within PureProject going forward (NikM: Jan2019)

                // Additional check to only execute override for PS opportunities (not GU)
                //if (eachOpp.RecordTypeId == psRecordTypeID){
                //    for (PS_Oppty_Subsidiary_Overrides__c PSOppSubsidiaryOverrides: PS_Oppty_Subsidiary_Overrides__c.getall().values()) {
                //        if (OppUpdateSoldToCountryName != null && eachOpp.Sold_To_Country__r.Name != null && eachOpp.Sold_To_Country__r.Name != OppUpdateSoldToCountryName) {
                //            System.Debug('NLM debug - sold to country on update is not null, sold to country on opp is not null, and they do not match');
                //            if (PSOppSubsidiaryOverrides.Country__c == OppUpdateSoldToCountryName) {
                //                // Sold to country has been matched, so we should now update the subsidiary override on the PS Opportunity with the value from the
                //                // custom settings. Note that Region could be matched but is not currently required.
                //                oppToUpdate.PS_Subsidiary_Override__c = PSOppSubsidiaryOverrides.Subsidiary_Override__c;
                //                System.debug('NLM debug OppRegion [' + eachOpp.PS_Region__c + '], OppSoldToCountry [' + eachOpp.Sold_To_Country__r.Name + '], OppUpdateSoldToCountryName is [' + OppUpdateSoldToCountryName + '], Subsidiary Override found and set to [' + PSOppSubsidiaryOverrides.Subsidiary_Override__c + ']');
                //            }
                //        } else {
                //            if (PSOppSubsidiaryOverrides.Country__c == eachOpp.Sold_To_Country__r.Name || (eachOpp.Sold_To_Country__c == null && PSOppSubsidiaryOverrides.Country__c == OppUpdateSoldToCountryName)) {
                //                // Sold to country has been matched, so we should now update the subsidiary override on the PS Opportunity with the value from the
                //               // custom settings. Note that Region could be matched but is not currently required.
                //                oppToUpdate.PS_Subsidiary_Override__c = PSOppSubsidiaryOverrides.Subsidiary_Override__c;
                //                System.debug('NLM debug OppRegion [' + eachOpp.PS_Region__c + '], OppSoldToCountry [' + eachOpp.Sold_To_Country__r.Name + '], OppUpdateSoldToCountryName is [' + OppUpdateSoldToCountryName + '], Subsidiary Override found and set to [' + PSOppSubsidiaryOverrides.Subsidiary_Override__c + ']');
                //            }
                //        }
                //    }
                //}

                oppsToBeUpdated.add(oppToUpdate);
            }
            // The following else clause is commented out as it was never being called anyway
            // else if ((eachOpp.RecordTypeId == psRecordTypeID || eachOpp.RecordTypeId == guRecordTypeID) && eachOpp.ParentOpportunity__c == null && eachOpp.AccountId != null) {
            //    Opportunity oppToUpdate = new Opportunity(id = eachOpp.id);
            //    System.debug('NKC debug oldMap [' + oldMap + ']');
            //    if (oldMap == null) {
            //        //oppToUpdate.AccountId = mapContactIdVsAccountId.get(eachOpp.Contact__c);
            //        oppToUpdate.AccountId = eachOpp.AccountId;
            //        oppToUpdate.AE_Name__c = mapAccIdVsAccount.get(oppToUpdate.AccountId).ownerId;
            //        oppToUpdate.Country__c = mapAccIdVsAccount.get(oppToUpdate.AccountId).Country__c;
            //        if (eachOpp.BusinessPartner__c != null)
            //            oppToUpdate.Sold_To_Country__c = eachOpp.BusinessPartner__r.Country__c;
            //        System.debug('NKC debug eachOpp.Direct_Sales__c [' + eachOpp.Direct_Sales__c + ']');
            //        if (eachOpp.Direct_Sales__c) {
            //            System.debug('NKC debug oppToUpdate.Country__c [' + oppToUpdate.Country__c + ']');
            //            oppToUpdate.Sold_To_Country__c = oppToUpdate.Country__c;
            //            oppToUpdate.BusinessPartner__c = oppToUpdate.AccountId;
            //        }
            //    }
            //    if (eachOpp.BusinessPartner__c != null && oldMap != null && (oppToUpdate.Sold_To_Country__c == null || eachOpp.BusinessPartner__c != oldMap.get(eachOpp.id).BusinessPartner__c)) {
            //        oppToUpdate.Sold_To_Country__c = eachOpp.BusinessPartner__r.Country__c;
            //        System.debug('NKC debug oppToUpdate.Sold_To_Country__c [' + oppToUpdate.Sold_To_Country__c + ']');
            //    }
            //    if (eachOpp.Direct_Sales__c && oldMap != null && eachOpp.Direct_Sales__c != oldMap.get(eachOpp.id).Direct_Sales__c) {
            //        oppToUpdate.BusinessPartner__c = eachOpp.accountId;
            //        oppToUpdate.Sold_To_Country__c = eachOpp.Country__c;
            //    }
            //    oppsToBeUpdated.add(oppToUpdate);
            //}
        }
        if (!oppsToBeUpdated.isEmpty()) {
            TriggerFlowManager.POPULATE_PARENT_OPP_FIELDS = false;
            update oppsToBeUpdated;
        }
        if (!oppTMToBeAdded.isEmpty())
            insert oppTMToBeAdded;

    }

    public static void updateTotalsOnTermChange(Map < Id, Opportunity > newMap, Map < Id, Opportunity > oldMap) {
        if(!TriggerFlowManager.OPP_TOTAL_UPDATE_ON_TERM_CHANGE)
            return;
        /*
        Map<Id, Map<Id, OpportunityLineItem>> mapOppIdVsMapIdVsOppLineItem = new Map<Id, Map<Id, OpportunityLineItem>>();
        List<OpportunityLineItem> oppLineItems = [SELECT id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN : newMap.keyset()];
        if(oppLineItems.isEmpty())
            return;
        for(OpportunityLineItem eachLineItem : oppLineItems){
            if(mapOppIdVsMapIdVsOppLineItem.get(eachLineItem.opportunityId) == null){
                Map<Id, OpportunityLineItem> newMap1 = new Map<Id, OpportunityLineItem>();
                newMap1.put(eachLineItem.id, eachLineItem);
                mapOppIdVsMapIdVsOppLineItem.put(eachLineItem.opportunityId, newMap1);
            }
            else{
                Map<Id, OpportunityLineItem> existingMap = mapOppIdVsMapIdVsOppLineItem.get(eachLineItem.opportunityId);
                existingMap.put(eachLineItem.id, eachLineItem);
                mapOppIdVsMapIdVsOppLineItem.put(eachLineItem.opportunityId, existingMap);
            }
        }
        System.debug('NKC debug mapOppIdVsMapIdVsOppLineItem ['+mapOppIdVsMapIdVsOppLineItem+']');
        for(Opportunity eachOpp : newMap.values()){
            if(eachOpp.Term_Commitment__c != oldMap.get(eachOpp.id).Term_Commitment__c){
                Map<Id, OpportunityLineItem> mapOppLineItems = mapOppIdVsMapIdVsOppLineItem.get(eachOpp.id);
                UpdateTotalsOnOppFromOpportunityProduct.updateTotalsOnOpp(mapOppLineItems);
            }
        }*/
        system.debug('+++++Opp helper class++++');
        Map < Id, OpportunityLineItem > map_OpptyProducts = new Map < Id, OpportunityLineItem > ();
        List < OpportunityLineItem > list_OpptyProducts = [SELECT id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: newMap.keyset()];
        Map < Id, Opportunity > map_Oppty = new Map < Id, Opportunity > ([SELECT Id,
            (SELECT Id FROM BigMachines__BigMachines_Quotes__r WHERE BigMachines__Is_Primary__c = true LIMIT 1)
            FROM Opportunity WHERE Id IN: newMap.keyset()
        ]);

        for (OpportunityLineItem objOLI: list_OpptyProducts) {
            if (map_Oppty.get(objOLI.OpportunityId).BigMachines__BigMachines_Quotes__r.isEmpty() &&
                newMap.get(objOLI.OpportunityId).Term_Commitment__c != oldMap.get(objOLI.OpportunityId).Term_Commitment__c) {
                map_OpptyProducts.put(objOLI.Id, objOLI);
            }
        }

        if (!map_OpptyProducts.isEmpty())
            UpdateTotalsOnOppFromOpportunityProduct.updateTotalsOnOpp(map_OpptyProducts);
        TriggerFlowManager.OPP_TOTAL_UPDATE_ON_TERM_CHANGE = false;
    }

    public static void shareQuoteAccess(Map < Id, Opportunity > newMap, Map < Id, Opportunity > oldMap) {
        Map < Id, Opportunity > oppIdVsOpp = new Map < Id, Opportunity > ();
        //Looping over each opportunity
        for (Opportunity eachOpp: newMap.values()) {
            //If owner is changed
            if (eachOpp.ownerId != oldMap.get(eachOpp.id).ownerId) {
                oppIdVsOpp.put(eachOpp.id, eachOpp);
            }
        }
        if (!oppIdVsOpp.isEmpty())
            shareQuoteAccessForOpps(oppIdVsOpp, null);
    }

    public static void shareQuoteAccess(List < Account > newList, Map < Id, Account > oldMap) {
        Map < Id, Account > mapIdVsAccount = new Map < Id, Account > ();
        //Looping over each opportunity
        for (Account eachAccount: newList) {
            //If owner is changed
            if (eachAccount.ownerId != oldMap.get(eachAccount.id).ownerId) {
                mapIdVsAccount.put(eachAccount.id, eachAccount);
            }
        }
        if (!mapIdVsAccount.isEmpty()) {
            Map < Id, Opportunity > oppIdVsOpp = new Map < Id, Opportunity > ([SELECT id FROM Opportunity WHERE AccountId IN: mapIdVsAccount.keyset()]);
            shareQuoteAccessForOpps(oppIdVsOpp, mapIdVsAccount);
        }
    }

    private static void shareQuoteAccessForOpps(Map < Id, Opportunity > oppIdVsOpp, Map < Id, Account > mapIdVsAccount) {
        List < BigMachines__Quote__c > quotes = [SELECT BigMachines__Opportunity__c, ownerId, BigMachines__Opportunity__r.AccountId
            FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: oppIdVsOpp.keyset()
        ];
        Map < Id, List < BigMachines__Quote__c >> mapOfOppIdVsQuotes = new Map < Id, List < BigMachines__Quote__c >> ();
        //Looping over each quote and populating map
        for (BigMachines__Quote__c eachQuote: quotes) {
            if (mapOfOppIdVsQuotes.get(eachQuote.BigMachines__Opportunity__c) == null) {
                List < BigMachines__Quote__c > newList = new List < BigMachines__Quote__c > ();
                newList.add(eachQuote);
                mapOfOppIdVsQuotes.put(eachQuote.BigMachines__Opportunity__c, newList);
            } else {
                mapOfOppIdVsQuotes.get(eachQuote.BigMachines__Opportunity__c).add(eachQuote);
            }
        }

        List < BigMachines__Quote__Share > quoteShareToBeInserted = new List < BigMachines__Quote__Share > ();
        //Looping over each opportunity
        for (Id eachOppId: oppIdVsOpp.keyset()) {
            List < BigMachines__Quote__c > quotes1 = mapOfOppIdVsQuotes.get(eachOppId);
            if (quotes1 == null)
                continue;
            for (BigMachines__Quote__c eachQuote: quotes1) {
                BigMachines__Quote__Share quoteShare = new BigMachines__Quote__Share();
                quoteShare.ParentId = eachQuote.id;
                if (mapIdVsAccount == null)
                    quoteShare.UserOrGroupId = oppIdVsOpp.get(eachQuote.BigMachines__Opportunity__c).ownerId;
                else
                    quoteShare.UserOrGroupId = mapIdVsAccount.get(eachQuote.BigMachines__Opportunity__r.AccountId).ownerId;
                quoteShare.AccessLevel = 'Edit';
                quoteShare.RowCause = Schema.BigMachines__Quote__Share.RowCause.Manual;
                quoteShareToBeInserted.add(quoteShare);
            }
        }
        try {
            List < Database.SaveResult > listOfResults = Database.insert(quoteShareToBeInserted);
        } catch (Exception ex) {}
    }
    //Added by Swastika on 04/03/2017 to assign GainSight Relation type <start>
    public static void updateGainsightRelation(List < Opportunity > newOpp) {
        for (Opportunity eachOpp: newOpp) {

            if (eachOpp.Primary_Line_of_Business__c == 'Cloud' && eachOpp.Lines_of_Businesses__c == 'PureEngage' && eachOpp.Primary_Solution__c != null && !eachOpp.Primary_Solution__c.Contains('Outbound'))
                eachOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';

            else if (eachOpp.Primary_Line_of_Business__c == 'Cloud' && eachOpp.Lines_of_Businesses__c == 'PureEngage' && eachOpp.Primary_Solution__c != null && eachOpp.Primary_Solution__c.Contains('Outbound'))
                eachOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound';

            else if (eachOpp.Lines_of_Businesses__c == 'Premier Edition')
                eachOpp.Gainsight_Relationship_Type__c = 'Premier Edition';
            else if (eachOpp.Lines_of_Businesses__c == 'PureCloud')
                eachOpp.Gainsight_Relationship_Type__c = 'PureCloud';
            else if (eachOpp.Primary_Line_of_Business__c == 'Cloud' && eachOpp.Lines_of_Businesses__c == 'PureConnect')
                eachOpp.Gainsight_Relationship_Type__c = 'PureConnect Cloud';
            else if (eachOpp.Primary_Line_of_Business__c == 'On Premise' && eachOpp.Lines_of_Businesses__c == 'PureConnect')
                eachOpp.Gainsight_Relationship_Type__c = 'PureConnect Premise';
            else if (eachOpp.Primary_Line_of_Business__c == 'On Premise' && eachOpp.Lines_of_Businesses__c == 'PureEngage')
                eachOpp.Gainsight_Relationship_Type__c = 'PureEngage Premise';
        }
    }
    //Added by Swastika on 04/03/2017 to assign GainSight Relation type <end>

    public static void updateOpportunityRecordType(Map < id, Opportunity > newMap, Map < Id, Opportunity > oldMap) {
        List < Opportunity > list_OfOpportunity = newMap.values();
        List < Opportunity > list_OfOpportunityToBeUpdated = new List < Opportunity > ();
        //Looping over each Opportunity
        for (Opportunity eachOpp: list_OfOpportunity) {
            System.debug('NKC debug eachOpp.Forecast_Opportunity__c [' + eachOpp.Forecast_Opportunity__c + ']');
            System.debug('NKC debug oldMap.get(eachOpp.id).Forecast_Opportunity__c [' + oldMap.get(eachOpp.id).Forecast_Opportunity__c + ']');
            //Forecast opportunity checkbox is checked
            if (eachOpp.Forecast_Opportunity__c && !oldMap.get(eachOpp.id).Forecast_Opportunity__c) {
                list_OfOpportunityToBeUpdated.add(new Opportunity(id = eachOpp.id, recordTypeId = getRecTypeId('GEN_Opportunity_Record_Type_New')));
            } else if (!eachOpp.Forecast_Opportunity__c && oldMap.get(eachOpp.id).Forecast_Opportunity__c && eachOpp.BusinessPartner__c != null) {
                list_OfOpportunityToBeUpdated.add(new Opportunity(id = eachOpp.id, recordTypeId = getRecTypeId('Partner_Opportunity')));
            }
        }
        if (!list_OfOpportunityToBeUpdated.isEmpty())
            update list_OfOpportunityToBeUpdated;
    }

    private static ID getRecTypeId(String recordTypeName) {
        List < RecordType > recTp = [SELECT ID FROM RecordType WHERE DeveloperName =: recordTypeName AND SObjectType = 'Opportunity'];
        if (!recTp.isEmpty())
            return recTp[0].Id;
        else
            return null;
    }




}