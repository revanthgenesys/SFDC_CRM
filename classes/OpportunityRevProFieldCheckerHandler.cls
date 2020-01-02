//
// Description: Called from within the OpportunityMain trigger before insert and before update
//   This will check the PS Opportunity and associated Opportunity Products to ensure that required RevPro data is present
//   If any data is missing, this will set a checkbox on the opportunity and also update a long text field with the details of what is missing, for reporting, diagnosis and use in the
//   Opportunity Approval process and as a gate element before sending the PS Opportunity to RevPro for creation of a Revenue Contract/Sales Order Lines
//
// Test Class : OpportunityRevProFieldCheckerHandler_Test
//
// Revisions:
//   April 2019 - Created by Nik Mills
//   June 2019 - Added new POB check for PS - Fixed Subcontractor (same as Expert Apps)
//   July 2019 - Added additional segmentation and checking for the Professional Services - Custom Build items (Treated like Expert Apps)
//   October 2019 - Added additional code for segmentation and checking of the PS Expert Apps Subscription items requirements
//   November 2019 - Added PCR Sold To and Subsidiary comparisons to parent PS Opp for enhanced RevPro checks (Enhancement R2.101)

Public without sharing Class OpportunityRevProFieldCheckerHandler
{
    public static void CheckOpportunityRevProFields(List<Opportunity> newOpps, List<Opportunity> oldOpps)
    {
        if (Util.Bypass_Trigger_Chk) return;
        
        boolean isMissingPSProjectRecord;
        boolean isMissingPSProjectRecordDates;
        boolean isMissingPSProductLine;
        boolean isMissingOLIPOB;
        boolean isMissingOLILineNum;
        boolean isOLIPOBError;
        boolean isMissingOpptyProducts;
        boolean isMissingOpptyProductTandMData;
        boolean isMissingOpptyProductFixedPercentData;
        boolean isMissingOpptyProductFixedFeeData;
        boolean isMissingOpptyProductCASData;
        boolean isMissingOpptyProductEAData;
        boolean isPCRSoldToOrSubsidMismatch;
        boolean isDebookIssue;
        boolean foundCASPOBs;
        boolean foundOtherPOBs;
        boolean isCASOnlyOppty;
        boolean isPCROpp;
        String missingRevProDetailsText;
        String parentSubsidiary;
        String childSubsidiary;
        Set <Id> parentOppIds = new Set <Id> ();
        Set <Id> currOppIds = new Set <Id> ();
        List <Opportunity> parentOpps;
        List <Opportunity> currOppsRelatedRecDetails;
    
        String oppRecTypeName;
        String parentOppRecTypeName;
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByID();
        
        for (Opportunity Opps: newOpps)
        {
            if (Opps.ParentOpportunity__c != null)
            {
                parentOppIds.add(Opps.ParentOpportunity__c);
            }
            currOppIds.add(Opps.Id);
        }
        
        if (!parentOppIds.isEmpty())
        {
            parentOpps = [SELECT Id, OpportunityNumber__c, BusinessPartner__c, BusinessPartner__r.Subsidary__r.Name, PS_Subsidiary_Override__c, RecordTypeId FROM Opportunity WHERE Id IN: parentOppIds];
        }
        
        if (!currOppIds.isEmpty())
        {
            currOppsRelatedRecDetails = [SELECT Id, BusinessPartner__r.Subsidary__r.Name FROM Opportunity WHERE Id IN: currOppIds];
        }
        
        for (Opportunity eachOpp: newOpps) 
        {
            isMissingPSProjectRecord = false;
            isMissingPSProjectRecordDates = false;
            isMissingPSProductLine = false;
            isMissingOLIPOB = false;
            isMissingOLILineNum = false;
            isOLIPOBError = false;
            isMissingOpptyProducts = false;
            isMissingOpptyProductTandMData = false;
            isMissingOpptyProductFixedPercentData = false;
            isMissingOpptyProductFixedFeeData = false;
            isMissingOpptyProductCASData = false;
            isMissingOpptyProductEAData = false;
            isCASOnlyOppty = false;
            isPCROpp = false;
            isPCRSoldToOrSubsidMismatch = false;
            isDebookIssue = false;
            foundCASPOBs = false;
            foundOtherPOBs = false;
            missingRevProDetailsText = '';
            parentSubsidiary = '';
            childSubsidiary = '';
            
            oppRecTypeName = rtMap.get(eachOpp.RecordTypeId).getName();
            
            if (oppRecTypeName == 'Professional Services') {                
                // General checks for all opportunities
                System.Debug('>>>>NikM: DEBUG: Checking PS Opportunity RevPro fields for Opportunity ' + eachOpp.OpportunityNumber__c);
                if (eachOpp.PS_Product_Line__c == '' || eachOpp.PS_Product_Line__c == null)
                {
                    isMissingPSProductLine = true;
                    missingRevProDetailsText = missingRevProDetailsText + 'Oppty Missing PS Product Line\r\n';
                }
                
                //System.Debug('>>>>NikM: DEBUG: This Opp CAS Values are: CAS Rollup Value : ' + eachOpp.PS_CAS_Value_rollup__c.setScale(2) + ', Total PS Amount : ' + eachOpp.PS_Amount_On_Premise__c.setScale(2));
                //// Check if this is a standalone CAS Opportunity only (CAS Total -= overall opportunity Total && > 0)
                //if (eachOpp.PS_CAS_Value_rollup__c.setScale(2) > 0 && eachOpp.PS_CAS_Value_rollup__c.setScale(2) == eachOpp.PS_Amount_On_Premise__c.setScale(2))
                //{
                //    isCASOnlyOppty = true;
                //}
                
                if (eachOpp.Master_Opportunity__c != null)
                {
                    isPCROpp = true;
                    // Need to resolve BusinessPartner__r lookup on child!!
                    for (Opportunity childOpp: currOppsRelatedRecDetails)
                    {
                        if (eachOpp.Id == childOpp.Id)
                        {
                            childSubsidiary = eachOpp.PS_Subsidiary_Override__c != null ? eachOpp.PS_Subsidiary_Override__c : childOpp.BusinessPartner__r.Subsidary__r.Name;
                        }
                    }
                    
                    // check through parent opps map and determine if this PCR Sold To and Subsidiary matches to the parent details.
                    for (Opportunity parentOpp: parentOpps)
                    {
                        if (parentOpp.Id == eachOpp.Master_Opportunity__c)
                        {
                            parentOppRecTypeName = rtMap.get(parentOpp.RecordTypeId).getName();
                            if (parentOppRecTypeName == 'Professional Services')
                            {
                                parentSubsidiary = parentOpp.PS_Subsidiary_Override__c != null ? parentOpp.PS_Subsidiary_Override__c : parentOpp.BusinessPartner__r.Subsidary__r.Name;
                                
                                if (parentSubsidiary != childSubsidiary)
                                {
                                    isPCRSoldToOrSubsidMismatch = true;
                                    missingRevProDetailsText = missingRevProDetailsText + 'PCR Oppty->PCR Subsidiary does not match PS Parent Subsidiary\r\n';
                                }
                                
                                if (parentOpp.BusinessPartner__c != eachOpp.BusinessPartner__c)
                                {
                                    isPCRSoldToOrSubsidMismatch = true;
                                    missingRevProDetailsText = missingRevProDetailsText + 'PCR Oppty->PCR Sold To does not match PS Parent Sold To\r\n';
                                }
                            }
                        }
                    }
                }
                
                // Specific checks for Closed/Won/Booked opportunities
                if (eachOpp.ForecastStatus__c == '0.Booked' && eachOpp.Win_Loss_Status__c == 'Won' && eachOpp.StageName == '6.Closed')
                {
                    if (eachOpp.Master_Opportunity__c == null)
                    {
                        List < Professional_Services_Project__c > psProjects = [SELECT Id, Project_Start_Date__c, Project_End_Date__c FROM Professional_Services_Project__c WHERE 
                                                                                Opportunity__c = :eachOpp.Id];

                        if (!psProjects.isEmpty())
                        {
                            // should only be one associated PS Project record
                            if (psProjects[0].Project_Start_Date__c == null)
                            {
                                isMissingPSProjectRecordDates = true;
                                missingRevProDetailsText = missingRevProDetailsText + 'Oppty->PS Project missing Project Start Date\r\n';
                            }
                            // At this time the Project End Date is not always mandatory, so commented out for now
                            //if (psProjects[0].Project_End_Date__c == null)
                            //{
                            //    isMissingPSProjectRecordDates = true;
                            //    missingRevProDetailsText = missingRevProDetailsText + 'Oppty->PS Project missing Project End Date\r\n';
                            //} 
                        }
                        else
                        {
                            isMissingPSProjectRecord = true;
                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty missing associated PS Project record\r\n';
                        }
                    }                                                                                
                                                                                
                    
                    List <OpportunityLineItem> opptyProducts = [SELECT Id, Opportunity_Product_Line_Item_ID__c, Description__c, OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Quantity__c, 
                                                                UnitPrice, TotalPrice, POB_Type__c, Product_Category__c, Linked_Oppty_Product__c, Linked_Oppty_Product_ID__c, Linked_Oppty_Product_Name__c, 
                                                                Product_Type__c, Professional_Services_Hours__c, Professional_Services_Rate__c, Professional_Services_Resource_Type__c, 
                                                                Professional_Services_SSP_Blended_Rate__c, Expert_Apps_List_Price__c, Professional_Services_Term_Months__c,
                                                                Line_Number__c, Product2.PS_Expert_Apps_Subscription_Item__c, isDebookItem__c
                                                                FROM OpportunityLineItem WHERE OpportunityId =: eachOpp.Id ];
                    
                    if (opptyProducts.isEmpty())
                    {
                        isMissingOpptyProducts = true;
                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty has no Products associated to it\r\n';
                    }
                    else
                    {
                        // Check if there are only CAS POB items on this opportunity for CAS Standalone
                        for (OpportunityLineItem casOliCheck: opptyProducts)
                        {
                            if (casOLICheck.POB_Type__c == 'PS - CAS')
                            {
                                foundCASPOBs = true;
                            }
                            if (casOLICheck.POB_Type__c != 'PS - CAS')
                            {
                                foundOtherPOBs = true;
                            }
                        }
                        if (foundCASPOBs && !foundOtherPOBs)
                        {
                            isCASOnlyOppty = true;
                            System.Debug('>>>>NikM: DEBUG: This Opp has CAS only POBs, so is CAS Standalone');
                        }
                    }
                                                                
                    for (OpportunityLineItem eachOLI: opptyProducts)
                    {
                        if (eachOLI.POB_Type__c == '' || eachOLI.POB_Type__c == null)
                        {
                                isMissingOLIPOB = true;
                                missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing POB Type\r\n';
                        }
                        if (eachOLI.Line_Number__c == null)
                        {
                                isMissingOLILineNum = true;
                                missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Line Number for RevPro\r\n';
                        }                        
                        
                        // Check if line item is negative and not flagged as a Debook item (all negatives should be debooks) - Applies to any POB
                        if (eachOLI.TotalPrice < 0 && !eachOLI.isDebookItem__c)
                        {
                            isDebookIssue = true;
                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] has negative amount and is not flagged as a Debook item\r\n';
                        }                       

                        
                        if (eachOLI.Product2.Name == 'Professional Services - Custom Build')
                        {
                                if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                {
                                    isMissingOpptyProductEAData = true;
                                    missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';                            
                                }
                                if (eachOLI.Expert_Apps_List_Price__c == null)
                                {
                                    isMissingOpptyProductEAData = true;
                                    missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Expert Apps List Price\r\n';
                                }                        
                        }
                        else
                        {
                            if (eachOLI.Product_Category__c != 'Expense')
                            {
                                // Check T&M Items
                                if (eachOLI.POB_Type__c == 'PS - T&M')
                                {
                                    if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                    {
                                        isMissingOpptyProductTandMData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';
                                    }
                                    if (eachOLI.Professional_Services_Hours__c == null || eachOLI.Professional_Services_Hours__c == 0)
                                    {
                                        isMissingOpptyProductTandMData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Hours\r\n';
                                    }
                                    if (eachOLI.Professional_Services_Rate__c == null)
                                    {
                                        isMissingOpptyProductTandMData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Rate\r\n';
                                    }
                                    if (eachOLI.Professional_Services_Resource_Type__c == '' || eachOLI.Professional_Services_Resource_Type__c == null)
                                    {
                                        isMissingOpptyProductTandMData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Resource Type\r\n';
                                    }  
                                }
                                // Check Fixed Price Items
                                if (eachOLI.POB_Type__c == 'PS - Fixed Price Percent Complete')
                                {
                                    if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                    {
                                        isMissingOpptyProductFixedPercentData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';                            
                                    }
                                    if (eachOLI.Professional_Services_Hours__c == null)
                                    {
                                        isMissingOpptyProductFixedPercentData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Hours\r\n';
                                    }
                                    if (eachOLI.Professional_Services_Rate__c == null)
                                    {
                                        isMissingOpptyProductFixedPercentData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Rate\r\n';
                                    }
                                    if (eachOLI.Professional_Services_SSP_Blended_Rate__c == null)
                                    {
                                        isMissingOpptyProductFixedPercentData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing SSP Blended Rate\r\n';
                                    }
                                }
                                // Check Fixed Fee on Date
                                if (eachOLI.POB_Type__c == 'PS - Fixed Fee on Date')
                                {
                                    if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                    {
                                        isMissingOpptyProductFixedFeeData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';  
                                    }
                                    if (eachOLI.Professional_Services_Term_Months__c == null || eachOLI.Professional_Services_Term_Months__c == 0)
                                    {
                                        isMissingOpptyProductFixedFeeData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing FFoD Term (Months)\r\n';                          
                                    }

                                    if (eachOLI.Product2.PS_Expert_Apps_Subscription_Item__c)
                                    {
                                        if (eachOLI.Expert_Apps_List_Price__c == null)
                                        {
                                            isMissingOpptyProductEAData = true;
                                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Expert Apps List Price\r\n';
                                        }                                    
                                    }
                                    else
                                    {
                                        if (eachOLI.Professional_Services_Hours__c == null)
                                        {
                                            isMissingOpptyProductFixedFeeData = true;
                                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Hours\r\n';
                                        }
                                        if (eachOLI.Professional_Services_Rate__c == null)
                                        {
                                            isMissingOpptyProductFixedFeeData = true;
                                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing PS Rate\r\n';
                                        }
                                        if (eachOLI.Professional_Services_SSP_Blended_Rate__c == null)
                                        {
                                            isMissingOpptyProductFixedFeeData = true;
                                            missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing SSP Blended Rate\r\n';
                                        }
                                    }
                                }
                                // Check Expert Apps Items
                                if (eachOLI.POB_Type__c == 'PS - Expert App' || eachOLI.POB_Type__c == 'PS - Fixed Subcontractor')
                                {
                                    if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                    {
                                        isMissingOpptyProductEAData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';                            
                                    }
                                    if (eachOLI.Expert_Apps_List_Price__c == null)
                                    {
                                        isMissingOpptyProductEAData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Expert Apps List Price\r\n';
                                    }
                                }
                                // Check CAS Items
                                if (eachOLI.POB_Type__c == 'PS - CAS')
                                {
                                    if (eachOLI.Description__c == '' || eachOLI.Description__c == null)
                                    {
                                        isMissingOpptyProductCASData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Description\r\n';                            
                                    }
                                    if (eachOLI.Linked_Oppty_Product_ID__c == null && !isCASOnlyOppty)
                                    {
                                        isMissingOpptyProductCASData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing Linked Product (EA or PS Custom Build)\r\n';                         
                                    }
                                    if (eachOLI.Professional_Services_Term_Months__c == null || eachOLI.Professional_Services_Term_Months__c == 0)
                                    {
                                        isMissingOpptyProductCASData = true;
                                        missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] missing CAS Term (Months)\r\n';                          
                                    }
                                }
                                // Check if POB is Error
                                if (eachOLI.POB_Type__c == 'Error')
                                {
                                    isOLIPOBError = true;
                                    missingRevProDetailsText = missingRevProDetailsText + 'Oppty Product [' + eachOLI.Product2.Name + '] has ERROR POB (Likely due to mapping issue)\r\n';
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                return;
            }
            
            if (isMissingOLIPOB || isMissingPSProjectRecord || isMissingPSProjectRecordDates || isMissingOpptyProducts || isMissingOpptyProductTandMData || isMissingOpptyProductFixedPercentData || 
                isMissingOpptyProductFixedFeeData || isMissingOpptyProductCASData || isMissingOpptyProductEAData|| isMissingPSProductLine || isOLIPOBError || isMissingOLILineNum || 
                isPCRSoldToOrSubsidMismatch || isDebookIssue)
            {
                eachOpp.RevPro_Required_Data_Missing__c = true;
                eachOpp.RevPro_Missing_Data_Details__c = missingRevProDetailsText;
            }
            else
            {
                eachOpp.RevPro_Required_Data_Missing__c = false;
                eachOpp.RevPro_Missing_Data_Details__c = '';
            }
        }
    }
}