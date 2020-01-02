// Class introduced iTracks 23110
public class CloudBillingUtil {
    
    //Nitin - Code Block Jun 19 - Starts Here 
    public static Map<Id, Id> map_QtChrgeDtlToPrdRtPlChrge { get; set; }
    public static Map<Id, zqu__QuoteRatePlanCharge__c> map_PrdRtPlChrgeToQtRtPlChrge { get; set; } 
    public static Map<Id,Id> map_ProdIdToQPId { get; set; }
    public static Map<Id, zqu__QuoteChargeDetail__c> map_QPIdToQPRecord { get; set; }   
    //Nitin - Code Block Jun 19 - Ends Here
    
    public static string strOfferingTypeforSub;
    public static string strPricingModel;
    
 /* Yuvaraj toomanysoql  public static final ID CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Cloud_Billing_Report_Instance__c'
                                                                          AND DeveloperName = 'ETL_Detail_Report'].id;*/
    
	public static final ID CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID =  Schema.SObjectType.Cloud_Billing_Report_Instance__c.getRecordTypeInfosByDeveloperName().get('ETL_Detail_Report').getRecordTypeId();
    // iTracks 23110
    // Function assumes you will only need rates from within a single month.
    // Genesys has been changing the rates years so this still works
    // Corporate Wide 
    public static Map<String,Decimal> getCurrencyConversionRates(Date activityDate, Boolean blnUseBillingConversionRate) {
        Map<String,Decimal> map_ConversionRates = new Map<String,Decimal>();
        
        
        if (blnUseBillingConversionRate) {
            System.debug('CloudBillingUtil.getCurrencyConversionRates: Using New Conversion table for date ' + activityDate);
            // New code for Billing_Conversion_Rate__c object
            List<Billing_Conversion_Rate__c > list_curr = [SELECT To_Currency_Code__c,Average_Conversion_Rate__c FROM Billing_Conversion_Rate__c 
                                                           WHERE From_Date__c = :activityDate
                                                           and CurrencyIsoCode = 'USD'
                                                          ];
            if (list_curr.size() == 0) {
                System.Debug('CloudBillingUtil.getCurrencyConversionRates: No Billing_Conversion_Rate__c conversion rates for activity date ' + activityDate);
            }
            for(Billing_Conversion_Rate__c  curr: list_curr) {
                System.Debug('CloudBillingUtil.getCurrencyConversionRates: Put IsoCode:Billing_Conversion_Rate__c ' + curr.To_Currency_Code__c + ' ' + curr.Average_Conversion_Rate__c);
                map_ConversionRates.put(curr.To_Currency_Code__c, curr.Average_Conversion_Rate__c);
            }
            
        } else {
            // Old code for Cloud Billing original object Cloud_Currency_Conversion__c
            List<Cloud_Currency_Conversion__c> list_curr = [SELECT IsoCode__c,ConversionRate__c FROM Cloud_Currency_Conversion__c
                                                            WHERE StartDate__c <= :activityDate AND NextStartDate__c > :activityDate];
            if (list_curr.size() == 0) {
                System.Debug('No Cloud_Currency_Conversion__c conversion rates for activity date ' + activityDate);
            }
            for(Cloud_Currency_Conversion__c curr: list_curr) {
                System.Debug('Put IsoCode:Cloud_Currency_Conversion__c ' + curr.IsoCode__c + ' ' + curr.ConversionRate__c);
                map_ConversionRates.put(curr.IsoCode__c, curr.ConversionRate__c);
            }
        }        
        return map_ConversionRates;
    }
    // iTracks 23110
    public static Map<String,Decimal> getCurrencyConversionRates() {
        Map<String,Decimal> map_ConversionRates = new Map<String,Decimal>();
        for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType]) {
            map_ConversionRates.put(curr.IsoCode,curr.ConversionRate); 
        }
        return map_ConversionRates;
    }
    
    // iTracks 25080
    public static Decimal getTotalQuantity(List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth, String strAggregationModel) {
        System.Debug('CloudBillingUtil.getTotalQuantity:  strAggregationModel ' + strAggregationModel);
        if (list_ContractTierSetMonth == null) {
            System.Debug('CloudBillingUtil.getTotalQuantity: list_ContractTierSetMonth null return 0');
            return 0;
        }
        if (strAggregationModel == 'Max Per Month') {
            Decimal decMax = 0;
            for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
                System.debug('CloudBillingUtil.getTotalQuantity: objCTSM.Max_Usage__c ' + objCTSM.Max_Usage__c);
                if (objCTSM.Total_Usage__c > decMax) {
                    System.debug('CloudBillingUtil.getTotalQuantity: ' + objCTSM.Id + ' Maxing Max_Usage__c ' + objCTSM.Max_Usage__c);
                    decMax = objCTSM.Max_Usage__c;
                } else {
                    System.debug('CloudBillingUtil.getTotalQuantity: Ignore ' + objCTSM.Id + ' Not Max ' + objCTSM.Max_Usage__c);
                }
            }
            return decMax;
        } else if (strAggregationModel == 'Sum of Max Per Region Per Month') {
            Decimal decMaxAP = 0;
            Decimal decMaxEU = 0;
            Decimal decMaxUS = 0;
            for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
                if (objCTSM.Max_Usage_AP__c != null && objCTSM.Max_Usage_AP__c > decMaxAP) {
                    System.debug('CloudBillingUtil.getTotalQuantity: ' + objCTSM.Id + ' Maxing Max_Usage_AP__c ' + objCTSM.Max_Usage_AP__c);
                    decMaxAP = objCTSM.Max_Usage_AP__c;
                }
                if (objCTSM.Max_Usage_EU__c != null && objCTSM.Max_Usage_EU__c > decMaxEU) {
                    System.debug('CloudBillingUtil.getTotalQuantity: ' + objCTSM.Id + ' Maxing Max_Usage_EU__c ' + objCTSM.Max_Usage_EU__c);
                    decMaxEU = objCTSM.Max_Usage_EU__c;
                }
                if (objCTSM.Max_Usage_US__c != null && objCTSM.Max_Usage_US__c > decMaxUS) {
                    System.debug('CloudBillingUtil.getTotalQuantity: ' + objCTSM.Id + ' Maxing Max_Usage_US__c ' + objCTSM.Max_Usage_US__c);
                    decMaxUS = objCTSM.Max_Usage_US__c;
                }
            }
            System.debug('CloudBillingUtil.getTotalQuantity: Sum decMaxAP:' + decMaxAP + ' + decMaxEU:' + decMaxEU + ' + decMaxUS:' + decMaxUS + ' = ' + decMaxAP + decMaxEU + decMaxUS);
            return decMaxAP + decMaxEU + decMaxUS;
        }
        else if (strAggregationModel == 'Average') {
            Decimal decSumUsage = 0;
            Decimal decSumCount = 0;
            for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
                System.debug('CloudBillingUtil.getTotalQuantity: objCTSM.Sum_Usage__c ' + objCTSM.Sum_Usage__c + 'objCTSM.Sum_Count__c ' + objCTSM.Sum_Count__c);
                decSumUsage += objCTSM.Sum_Usage__c;
                decSumCount += objCTSM.Sum_Count__c;
            }
            if (decSumUsage == 0 || decSumCount == 0) {
                return 0;
            }
            Decimal decAverage = decSumUsage / decSumCount;
            System.debug('CloudBillingUtil.getTotalQuantity: decSumUsage ' + decSumUsage + ' decSumCount ' + decSumCount + ' decAverage ' + decAverage);
            return decAverage;
        }
        
        // Drop out of logic therefore sum the quantity for all others and default
        Decimal decTotal = 0;
        for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
            System.debug('CloudBillingUtil.getTotalQuantity: ' + objCTSM.Id + ' Adding Total_Usage__c ' + objCTSM.Total_Usage__c);
            decTotal += objCTSM.Total_Usage__c;        
        }
        return decTotal;
    }
    
    public static Decimal getCount(List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth) {
        Decimal decTotal = 0;
        for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
            System.debug('CloudBillingUtil.getCount: ' + objCTSM.Id + ' Adding Sum_Count__c ' + objCTSM.Sum_Count__c);
            decTotal += objCTSM.Sum_Count__c;        
        }
        return decTotal;
    }
    
    // iTracks 25080
    public static Decimal getTotalOutboundCallsCost(List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth) {
        Decimal decTotal = 0;
        for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
            System.debug('CloudBillingUtil: ' + objCTSM.Id + ' Adding Total_Outbound_Calls_Cost__c ' + objCTSM.Total_Outbound_Calls_Cost__c);
            decTotal += objCTSM.Total_Outbound_Calls_Cost__c;        
        }
        return decTotal;
    }
    
    
    // iTracks 25080
    public static Decimal getTotalInboundCallsCost(List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth) {
        Decimal decTotal = 0;
        for (Contract_Tier_Set_Month__c objCTSM : list_ContractTierSetMonth) {
            System.debug('CloudBillingUtil: ' + objCTSM.Id + ' Adding Total_Inbound_Calls_Cost__c ' + objCTSM.Total_Inbound_Calls_Cost__c);
            decTotal += objCTSM.Total_Inbound_Calls_Cost__c;        
        }
        return decTotal;
    }
    
    
    public static Cloud_Billing_Log__c createNewCloudBillingLog(String strType, String strStatus) {
        Cloud_Billing_Log__c objLog = new Cloud_Billing_Log__c();
        objLog.Type__c = strType;
        objLog.Status__c = strStatus;
        objLog.Time__c = DateTime.now();
        objLog.User__c = UserInfo.getUserId();
        return objLog;
    }
    
    public static Date dateMaxDate() {
        System.Debug ('Util:dateMaxDate');
        return Date.newInstance(4000, 12, 31);
    }
    public static Date dateMinDate() {
        System.Debug ('Util:dateMinDate');
        return Date.newInstance(1700, 1, 1);
    }
    
    // Returns true if the "one" date sets overlap the "two" dates. Requires all dates be non-null and that the start dates are before the end dates.
    public static Boolean blnDatesOverlap(Date oneStart, Date oneEnd, Date twoStart, Date twoEnd) {
        System.Debug ('CloudBillingUtil:blnDatesOverlap: oneStart:' + oneStart + ' oneEnd:' + oneEnd + ' twoStart:' + twoStart + ' twoEnd:' + twoEnd);
        if (oneStart == null) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: Convert oneStart to min date');
            oneStart = CloudBillingUtil.dateMinDate();
        }
        if (oneEnd == null) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: Convert oneEnd to max date');
            oneEnd = CloudBillingUtil.dateMaxDate();
        }
        if (twoStart == null) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: Convert twoStart to min date');
            twoStart = CloudBillingUtil.dateMinDate();
        }
        if (twoEnd == null) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: Convert twoEnd to max date');
            twoEnd = CloudBillingUtil.dateMaxDate();
        }
        
        // Confirm starts are earlier than ends
        if (oneStart > oneEnd) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: oneStart > oneEnd: true');
            return true;
        }
        if (twoStart > twoEnd) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: twoStart > twoEnd: true');
            return true;
        }
        
        // We know oneStart <= oneEnd and twoStart <= twoEnd
        // As long as the start of one pair of dates is greater than the end of the other, we know the dates do not overlap.
        if (oneStart >= twoEnd) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: oneStart >= twoEnd: false');
            return false;
        }
        if (twoStart >= oneEnd) {
            System.Debug('CloudBillingUtil:blnDatesOverlap: twoStart >= oneEnd: false');
            return false;
        }
        
        System.debug('CloudBillingUtil:blnDatesOverlap: Dropped out of logic');
        return true;
    }
    
    public static Boolean blnIsRatingJobRunning() {
        String strSOQL = 'select Id, Status from AsyncApexJob where ApexClassId in (' + Label.Cloud_Billing_Rating_Job_Id_List + ') ';
        strSOQL = strSOQL + 'and Status not in (' + Label.Cloud_Billing_Apex_Job_Status_Ignore + ')';
        System.debug('CloudBillingUtil.blnIsRatingJobRunning strSOQL ' + strSOQL);
        List<AsyncApexJob> listAsyncApexJob = Database.query(strSOQL);
        if (listAsyncApexJob.size() > 0) {
            String strQueryHelper = '';
            for (AsyncApexJob j : listAsyncApexJob) {
                System.debug('CloudBillingUtil.blnIsRatingJobRunning Forbidding based on Job Id ' + j.Id + ' Status ' + j.Status);
                strQueryHelper = strQueryHelper + '\'' + j.Id + '\',';
            }
            System.Debug('CloudBillingUtil.blnIsRatingJobRunning strQueryHelper: ' + strQueryHelper);
            return true;
        }
        return false;
    }
    
    public static String formatDateMMDDYYYY(Date d) {
        return d.month() + '/' + d.day() + '/' +  + '/' + d.year();
    }
    
    // Use Cloud_Deployment__c fields BE_Tenant_Id_Hash__c and PE_Subscriber_Id_Hash__c to search for the appropriate Account/GARN
    public static void populateGARNCodesFromCloudDeployment(List<Rolled_Up_Usage_Data__c> list_RolledUpUsageData)
    {
        Set<String> set_PlatformIds = new Set<String>();
        Map<String,String> map_PlatformIdToGARNCode = new Map<String,String>();
        for(Rolled_Up_Usage_Data__c objRollUpData : list_RolledUpUsageData)
        {
            if(String.isNotBlank(objRollUpData.Platform_Id_Hash__c)) {
                if (!set_PlatformIds.contains(objRollUpData.Platform_Id_Hash__c)) {
                    System.debug('Util: Push ' + objRollUpData.Platform_Id_Hash__c + ' for RUUD ' + objRollUpData.Id);
                    set_PlatformIds.add(objRollUpData.Platform_Id_Hash__c);
                }
            }
        }
        
        for (Cloud_Deployment__c cd : [SELECT Account__r.Name,Account__r.SAP_Account_Code__c,
                                       BE_Tenant_Id_Hash__c,PE_Subscriber_Id_Hash__c,Portico_Platform_Id_Hash__c,
                                       PureConnect_ID_Hash__c, 
                                       PureCloud_OrgID_Hash__c, Billing_Platform_Id_Hash__c
                                       FROM Cloud_Deployment__c 
                                       WHERE BE_Tenant_Id_Hash__c IN :set_PlatformIds
                                       OR PE_Subscriber_Id_Hash__c IN :set_PlatformIds
                                       OR Portico_Platform_Id_Hash__c IN :set_PlatformIds
                                       OR PureConnect_ID_Hash__c IN :set_PlatformIds
                                       OR PureCloud_OrgID_Hash__c IN :set_PlatformIds
                                       OR Billing_Platform_Id_Hash__c IN :set_PlatformIds
                                       ])
        {
            System.debug('Util: Push Cloud Deployment Hashes ' + cd.BE_Tenant_Id_Hash__c + ' and ' + cd.PE_Subscriber_Id_Hash__c + ' and ' + cd.Portico_Platform_Id_Hash__c +
                         ' for Account ' + cd.Account__r.Name + ' GARN ' + cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.BE_Tenant_Id_Hash__c,cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.PE_Subscriber_Id_Hash__c,cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.Portico_Platform_Id_Hash__c,cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.PureConnect_ID_Hash__c,cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.PureCloud_OrgID_Hash__c,cd.Account__r.SAP_Account_Code__c);
            //map_PlatformIdToGARNCode.put(cd.PureConnect_Subscription_OrgID_Hash__c,cd.Account__r.SAP_Account_Code__c);
            //map_PlatformIdToGARNCode.put(cd.PureEngage_Subscription_OrgID_Hash__c,cd.Account__r.SAP_Account_Code__c);
            map_PlatformIdToGARNCode.put(cd.Billing_Platform_Id_Hash__c,cd.Account__r.SAP_Account_Code__c); //Adding New Billing Platfrom Id to Platform ID
        }
        
        for(Rolled_Up_Usage_Data__c objRollUpData : list_RolledUpUsageData)
        {
            if(map_PlatformIdToGARNCode.containsKey(objRollUpData.Platform_Id_Hash__c)) {
                objRollUpData.GARN_Account_Code__c = map_PlatformIdToGARNCode.get(objRollUpData.Platform_Id_Hash__c);
                System.debug('Util: Got GARN ' + objRollUpData.GARN_Account_Code__c + ' for hash ' + objRollUpData.Platform_Id_Hash__c);
            } else {
                System.debug('Util: Assigning Null to the GARN for RUUD Id ' + objRollUpData.Id);
                objRollUpData.GARN_Account_Code__c = null;
            }
        }
    }
    
    // iTracks 25080
    public static Map<String, Cloud_Deployment__c> getMapCloudDeploymentfromHashes(Set<String> set_PlatformIdHashes) {
        System.debug('CloudBillingUtil.getMapCloudDeploymentfromHashes: set_PlatformIdHashes ' + set_PlatformIdHashes);
        List<Cloud_Deployment__c> list_CloudDeployment = [SELECT Name, PE_Subscriber_Id_Hash__c, BE_Tenant_Id_Hash__c, Portico_Platform_Id_Hash__c,
                                                          PureConnect_ID_Hash__c, 
                                                          PureCloud_OrgID_Hash__c,
                                                          Cloud_Billing_Contract__r.Id,Billing_Platform_Id_Hash__c,
                                                          (SELECT Contract__c from Cloud_Deployment_To_Contract_Junctions__r)
                                                          FROM Cloud_Deployment__c
                                                          WHERE BE_Tenant_Id_Hash__c in :set_PlatformIdHashes OR
                                                          PE_Subscriber_Id_Hash__c in :set_PlatformIdHashes OR
                                                          Portico_Platform_Id_Hash__c IN :set_PlatformIdHashes OR
                                                          PureConnect_ID_Hash__c in :set_PlatformIdHashes OR
                                                          PureCloud_OrgID_Hash__c in :set_PlatformIdHashes OR
                                                          Billing_Platform_Id_Hash__c in :set_PlatformIdHashes];
        System.debug('CloudBillingUtil: PlatformId list_CloudDeployment returned size ' + list_CloudDeployment.size());
        Map<String, Cloud_Deployment__c> map_PlatformIdHashToCloudDeployment = new Map<String, Cloud_Deployment__c>();
        for (Cloud_Deployment__c obj_CloudDeployment : list_CloudDeployment) {
            if (obj_CloudDeployment.BE_Tenant_Id_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.BE_Tenant_Id_Hash__c)) {
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.BE_Tenant_Id_Hash__c, obj_CloudDeployment);
            }
            if (obj_CloudDeployment.PE_Subscriber_Id_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.PE_Subscriber_Id_Hash__c)) {
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.PE_Subscriber_Id_Hash__c, obj_CloudDeployment);
            }
            if (obj_CloudDeployment.Portico_Platform_Id_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.Portico_Platform_Id_Hash__c)) {
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.Portico_Platform_Id_Hash__c, obj_CloudDeployment);
            }
            if (obj_CloudDeployment.PureConnect_ID_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.PureConnect_ID_Hash__c)) {
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.PureConnect_ID_Hash__c, obj_CloudDeployment);
            }
            if (obj_CloudDeployment.PureCloud_OrgID_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.PureCloud_OrgID_Hash__c)) {
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.PureCloud_OrgID_Hash__c, obj_CloudDeployment);
            }
            if (obj_CloudDeployment.Billing_Platform_Id_Hash__c != null && !map_PlatformIdHashToCloudDeployment.containsKey(obj_CloudDeployment.Billing_Platform_Id_Hash__c)) {//Add Billing Platform Id to Platform Id collection
                map_PlatformIdHashToCloudDeployment.put(obj_CloudDeployment.Billing_Platform_Id_Hash__c, obj_CloudDeployment);
            }
        }
        return map_PlatformIdHashToCloudDeployment;
    }
    
    public static Boolean blnIsPureCloudVoice(Rolled_Up_Usage_Data__c objRollUpData) {
        if (objRollUpData.Source_Name__c == 'PCL') {
            if (objRollUpData.Activity_Type__c == 0 ||
                objRollUpData.Activity_Type__c == 4 ||
                objRollUpData.Activity_Type__c == 10 ||
                objRollUpData.Activity_Type__c == 11) {
                    return true;
                }
        }
        return false;
    }
    
    // iTracks 25080
    public static List<String> populateListContractIdServiceId(Rolled_Up_Usage_Data__c objRollUpData, Map<String, Cloud_Deployment__c> map_PlatformIdHashToCloudDeployment, Boolean blnDefault) {
        System.debug('CloudBillingUtil.populateListContractIdServiceId: PlatformId Checking for Hash ' + objRollUpData.Platform_Id_Hash__c + ' go get contract id service identifier');
        List<String> list_PlatformIdHashContractIdServiceIdentifier = new List<String>();
        if (map_PlatformIdHashToCloudDeployment.containsKey(objRollUpData.Platform_Id_Hash__c)) {
            System.debug('CloudBillingUtil.populateListContractIdServiceId: PlatformId Got Hash ' + objRollUpData.Platform_Id_Hash__c);
            Cloud_Deployment__c obj_CloudDeployment = map_PlatformIdHashToCloudDeployment.get(objRollUpData.Platform_Id_Hash__c);
            if (obj_CloudDeployment != null &&
                obj_CloudDeployment.Cloud_Deployment_To_Contract_Junctions__r != null &
                obj_CloudDeployment.Cloud_Deployment_To_Contract_Junctions__r.size() > 0)
            {
                for (Cloud_Deployment_To_Contract_Junction__c objJunction : obj_CloudDeployment.Cloud_Deployment_To_Contract_Junctions__r) {
                    String strContractIdServiceIdentifier;
                    String strContractIdServiceIdentifierDefault;
                    
                    // If PureCloud platform, use alternative service identifier 
                    if (blnIsPureCloudVoice(objRollUpData)) {
                        strContractIdServiceIdentifier = objJunction.Contract__c + '#' + objRollUpData.PCV_Service_Identifier__c;
                        strContractIdServiceIdentifierDefault = objJunction.Contract__c + '#' + objRollUpData.PCV_Service_Identifier_Default__c;
                    } else {
                        strContractIdServiceIdentifier = objJunction.Contract__c + '#' + objRollUpData.Service_Identifier__c;
                        strContractIdServiceIdentifierDefault = objJunction.Contract__c + '#' + objRollUpData.Service_Identifier_Default__c;
                    }
                    System.debug('CloudBillingUtil.populateListContractIdServiceId: Adding strContractIdServiceIdentifier ' + strContractIdServiceIdentifier +
                                 ' and strContractIdServiceIdentifierDefault ' + strContractIdServiceIdentifierDefault);
                    // If we did not request default, push the standard ID
                    if (!blnDefault) list_PlatformIdHashContractIdServiceIdentifier.add(strContractIdServiceIdentifier);
                    // We asked for the default, push the default ID
                    else list_PlatformIdHashContractIdServiceIdentifier.add(strContractIdServiceIdentifierDefault);
                }
            } else {
                objRollUpData.Contract_Id_Service_Identifier__c = 'Cloud Deployment not assigned to contract';
            }
        } else {
            System.Debug ('CloudBillingUtil.populateListContractIdServiceId: map_PlatformIdHashToCloudDeployment does not contain hash for RUUD ' + objRollUpData);
        }
        
        return list_PlatformIdHashContractIdServiceIdentifier;
    }
    
    private static List<Cloud_Billing_Report_Instance__c> createCloudBillingReportInstances(Cloud_Billing_Report_Request__c objReportRequest,
                                                                                            Set<String> set_existingReportDateHashes,
                                                                                            Date dtReportDate) 
    {
        List<String> listReportTypes = objReportRequest.Report_Type__c.split(';');
        List<Cloud_Billing_Report_Instance__c> listCloudBillingReportInstance = new List<Cloud_Billing_Report_Instance__c>();
        for (String strReportType : listReportTypes) {
            String strNewReportHash = dtReportDate.month() + '#' + dtReportDate.year() + '#' + strReportType;
            if (!set_existingReportDateHashes.contains(strNewReportHash)) {
                System.debug('CloudBillingUtil.createCloudBillingReportInstances strNewReportHash ' + strNewReportHash);
                Cloud_Billing_Report_Instance__c objCloudBillingReportInstance = new Cloud_Billing_Report_Instance__c(
                    Cloud_Billing_Report_Request__c = objReportRequest.Id,
                    Month__c = String.valueOf(dtReportDate.month()),
                    Year__c = String.valueOf(dtReportDate.year()),
                    Report_Type__c = strReportType,
                    Platform_Id_List__c = objReportRequest.Platform_Id_List__c,
                    Status__c = 'Submitted',
                    RecordTypeID = CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID
                );
                listCloudBillingReportInstance.add(objCloudBillingReportInstance);
                System.debug('CloudBillingUtil.createCloudBillingReportInstances for ' + objReportRequest.Account_Name__c + ' objCloudBillingReportInstance '+ objCloudBillingReportInstance);
            } else {
                System.debug('CloudBillingUtil.createCloudBillingReportInstances strNewReportHash ' + strNewReportHash + ' exists, do not create new report');
            }
            
        }
        return listCloudBillingReportInstance;
    }
    
    public static List<Cloud_Billing_Report_Instance__c> runCloudBillingReportRequests(CloudBillingData info) {
        Date dtReportMonth = Date.newInstance(Integer.valueOf(info.year), Integer.valueOf(info.month), 1);
        System.Debug('runCloudBillingReportRequests dtReportMonth ' + dtReportMonth);
        String strQuery = 'select Id, Start_Date__c, End_Date__c, Report_Type__c, Platform_Id_List__c,Account_Name__c,'+
            '(select Report_Instance_Hash__c from Cloud_Billing_Report_Instances__r order by Year__c desc, Month__c desc) '+
            'from Cloud_Billing_Report_Request__c where Start_Date__c <= :dtReportMonth and End_Date__c >= :dtReportMonth';
        if(String.isNotBlank(info.contractId)) {
            String strContractId = info.contractId;
            strQuery += ' AND Contract__c = :strContractId';
        }
        if(String.isNotBlank(info.subsidiary) && info.subsidiary != 'All') {
            String strSubsidiary = info.subsidiary;
            strQuery += ' AND Contract__r.Account_Name__r.Subsidary__r.Name = :strSubsidiary';
        }
        if(String.isNotBlank(info.region) && info.region != 'All') {
            String strRegion = info.region;
            strQuery += ' AND Contract__r.Account_Name__r.Country__r.Region__c = :strRegion';
        }
        if(String.isNotBlank(info.edition) && info.edition != 'All') {
            System.debug('Adding strEdition:[' + info.edition + ']');
            String strEdition = info.edition;
            strQuery += ' AND Contract__r.Product_Group__c = :strEdition';
        }
        
        strQuery += ' order by End_Date__c desc, Start_Date__c desc';
        
        System.debug('CloudBillingUtil.runCloudBillingReportRequests strQuery ' + strQuery + ' info.contractId=' + info.contractId);
        List<Cloud_Billing_Report_Request__c> list_CloudReportRequests = (List<Cloud_Billing_Report_Request__c>)Database.query(strQuery);
        
        List<Cloud_Billing_Report_Instance__c> listNewReportInstancesToInsert = new List<Cloud_Billing_Report_Instance__c>();
        for (Cloud_Billing_Report_Request__c objReportRequest : list_CloudReportRequests) {
            System.Debug('CloudBillingUtil.runCloudBillingReportRequests: Account ' + objReportRequest.Account_Name__c + ' Start_Date__c ' + objReportRequest.Start_Date__c + 
                         ' End_Date__c ' + objReportRequest.End_Date__c + ' Report_Type__c ' + objReportRequest.Report_Type__c +
                         ' Platform_Id_List__c ' + objReportRequest.Platform_Id_List__c);
            Set<String> set_existingReportDateHashes = new Set<String>();
            for (Cloud_Billing_Report_Instance__c objReportInstance : objReportRequest.Cloud_Billing_Report_Instances__r) {
                System.Debug('Util.runCloudBillingReportRequests: Add existing Date Hash strDateHash ' + objReportInstance.Report_Instance_Hash__c);
                set_existingReportDateHashes.add(objReportInstance.Report_Instance_Hash__c);
            }
            List<Cloud_Billing_Report_Instance__c> listNewReportInstances = createCloudBillingReportInstances(objReportRequest, set_existingReportDateHashes, dtReportMonth);
            listNewReportInstancesToInsert.addAll(listNewReportInstances);
        }
        insert listNewReportInstancesToInsert;
        return listNewReportInstancesToInsert;
    }
    
    public static Cloud_Billing_Exception__c createNewBillingException(String strDescription, Rolled_Up_Usage_Data__c objRollUpData, Service__c objService, Id idContract) 
    {
        Cloud_Billing_Exception__c objBillingException = new Cloud_Billing_Exception__c();
        objBillingException.Exception_Type__c = objRollUpData.Exception_Type__c;
        objBillingException.Description__c = strDescription;
        objBillingException.Rolled_Up_Usage_Data__c = objRollUpData.Id;
        objBillingException.Contract__c = idContract;
        // Storing Service Info if available
        objBillingException.Service__c = objService != null ? objService.Id : null;
        
        return objBillingException;
    }
    
    
    //Nitin - Code Block Jun 19 - Starts Here 
    public static void resetServiceInfoFromQuote(GCR_Content_Document_Detail__c objContract,string strOfferingType)
    {
        //Rony Joseph-If PCS or PES invoke new method for Contract generation
        if(strOfferingType != null && strOfferingType.contains('Subscription')) { //objContract.Quote__r.Offering_Type__C.contains('Subscription') ||
            createContractForSubscription(objContract);
        }
        else{
            resetStaticVariables();
            // DB Save-point
            Savepoint objSP = Database.setSavepoint();
            try
            {       
                if(objContract.Quote__c != null)
                {
                    // Querying existing Tier Sets
                    List<Contract_Tier_Set__c> list_TierSetsToDelete = [SELECT Id FROM Contract_Tier_Set__c 
                                                                        WHERE Contract__c = :objContract.Id];
                    // Deleting existing Tier Sets as Tier Set Info will be created freshly
                    if(!list_TierSetsToDelete.isEmpty())
                        delete list_TierSetsToDelete;
                    
                    map_ProdIdToQPId = new Map<Id,Id>();
                    Map<Id,BigMachines__Quote_Product__c> map_QPIdToQPRecord = new Map<Id,BigMachines__Quote_Product__c>([SELECT Id,BigMachines__Product__c,
                                                                                                                          BigMachines__Product__r.Name, BigMachines__Product__r.Billing_Category__c,
                                                                                                                          BigMachines__Quantity__c,Net_Unit_Price__c FROM BigMachines__Quote_Product__c
                                                                                                                          WHERE BigMachines__Quote__c = :objContract.Quote__c AND BigMachines__Product__r.Type__c != 'Genesys Care'
                                                                                                                          AND Bundle__c = null]);
                    system.debug('map_QPIdToQPRecord'+map_QPIdToQPRecord);
                    // Dummy code for future development
                    System.Debug('Contract ' + objContract);
                    if(objContract.Product_Group__c == 'PureConnect') {
                        Boolean blnIsTelcoContract = objContract.Contract_Type__c == 'Cloud Billing - Telco';
                        for(BigMachines__Quote_Product__c objQP : map_QPIdToQPRecord.values()) {
                            if (blnIsTelcoContract && objQP.BigMachines__Product__r.Billing_Category__c != 'Telco') {
                                // Remove this Product from the Map
                            }
                            if (!blnIsTelcoContract && objQP.BigMachines__Product__r.Billing_Category__c == 'Telco') {
                                // Remove this Product from the Map
                            }
                        }
                    }
                    
                    // Fetching Quote Products and creating a map of Product Id to Quote Product Id
                    for(BigMachines__Quote_Product__c objQP : map_QPIdToQPRecord.values()) {
                        System.Debug('resetServiceInfoFromQuote: Adding Quote Product BigMachines__Quote_Product__c ' + objQP);
                        map_ProdIdToQPId.put(objQP.BigMachines__Product__c,objQP.Id);
                    }
                    
                    if(!map_ProdIdToQPId.isEmpty())
                    {
                        System.debug('NKC debug map_ProdIdToQPId.keySet() ['+map_ProdIdToQPId+']');
                        // Fetching Tier Set Configuration info from Products associated with the Quote
                        List<Product_Tier_Set__c> list_ProductTierSets = [SELECT Name,Product__c,Aggregation_Model__c,Units_Type__c,
                                                                          (SELECT From__c,To__c,Price__c FROM Product_Tier_Ranges__r),
                                                                          (SELECT Service__c,Service__r.Use_Calling_Rates__c FROM Product_Tier_Set_Services__r),
                                                                          (SELECT Amount__c,Charge_Description__c,External_Note__c,Type__c FROM Product_Recurring_Charges__r)
                                                                          FROM Product_Tier_Set__c WHERE Product__c IN :map_ProdIdToQPId.keySet()];
                        System.debug('list_ProductTierSets'+list_ProductTierSets+objContract);
                        // Creating Contract Tier Sets
                        List<Contract_Tier_Set__c> list_ContractTierSetsToInsert = new List<Contract_Tier_Set__c>();
                        
                        if(!list_ProductTierSets.isEmpty())
                        {
                            list_ContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(list_ProductTierSets, objContract));
                            
                            // Contract Tier Sets
                            if(!list_ContractTierSetsToInsert.isEmpty())
                                insert list_ContractTierSetsToInsert;
                            
                            Integer i=0;
                            List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
                            List<Contract_Service__c> list_ContractServicesToInsert = new List<Contract_Service__c>();
                            List<Contract_Recurring_Charge__c> list_ContractRecChargesToInsert = new List<Contract_Recurring_Charge__c>();
                            System.debug('list_ContractTierSetsToInsert'+list_ContractTierSetsToInsert);
                            for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSetsToInsert)
                            {
                                System.Debug('resetServiceInfoFromQuote: checking for product id ' + objContractTierSet.Quote_Product__c);
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c))
                                {
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    System.debug('resetServiceInfoFromQuote: got quote product ' + objRelatedQP);
                                    System.debug('resetServiceInfoFromQuote: objContract.Quote__r ' + objContract.Quote__c);
                                    System.debug('resetServiceInfoFromQuote: objContract.Quote__r.Offering_Type__C ' + objContract.Quote__r.Offering_Type__C);
                                    System.debug('resetServiceInfoFromQuote: strOfferingType ' + strOfferingType);
                                    Boolean blnIsSubscription = false;
                                    if (objContract != null &&
                                        objContract.Quote__r != null &&
                                        objContract.Quote__r.Offering_Type__c != null &&
                                        objContract.Quote__r.Offering_Type__c.contains('Subscription')) blnIsSubscription = true;
                                    if (strOfferingType != null && strOfferingType.contains('Subscription')) blnIsSubscription = true;
                                    if(!blnIsSubscription) {
                                        System.debug('resetServiceInfoFromQuote: Not Subscription, setting up tier range');
                                        list_ContractTRsToInsert.addAll(setupContractTierRange(list_ProductTierSets[i].Product_Tier_Ranges__r , 
                                                                                               objContractTierSet,  objContract));
                                        
                                        // If there are no default ranges then system intelligently creates ranges
                                        if(list_ProductTierSets[i].Product_Tier_Ranges__r.isEmpty())
                                        {
                                            
                                            list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                           objRelatedQP.Net_Unit_Price__c , objContract.Quote__r.CurrencyISOCode));
                                            list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , 999999999999.0, 
                                                                                                           objRelatedQP.Net_Unit_Price__c , objContract.Quote__r.CurrencyISOCode));
                                            
                                        }
                                    }
                                    else
                                    {
                                        System.debug('resetServiceInfoFromQuote: Subscription, setting up tier range');

                                        list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                       0 , objContract.Quote__r.CurrencyISOCode));
                                        list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , (objRelatedQP.BigMachines__Quantity__c*1.25).round(System.RoundingMode.UP), 
                                                                                                       objRelatedQP.Net_Unit_Price__c*1.30, objContract.Quote__r.CurrencyISOCode));
                                        list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , (objRelatedQP.BigMachines__Quantity__c*1.25).round(System.RoundingMode.UP)+1 , 999999999999.0, 
                                                                                                       objRelatedQP.Net_Unit_Price__c*1.30, objContract.Quote__r.CurrencyISOCode));
                                        
                                    }
                                    
                                    // Creating Contract Services
                                    for(Product_Tier_Set_Service__c  objProdTSS : list_ProductTierSets[i].Product_Tier_Set_Services__r)
                                    {
                                        Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                        objContService.Service__c = objProdTSS.Service__c;
                                        objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                        objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                        list_ContractServicesToInsert.add(objContService);
                                    }
                                    // Creating Contract Recurring Charges
                                    for(Product_Recurring_Charge__c  objProdRC : list_ProductTierSets[i].Product_Recurring_Charges__r)
                                    {
                                        Contract_Recurring_Charge__c objContRecCharge = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                        // Populate default price if there is one
                                        if(objProdRC.Amount__c != null)
                                            objContRecCharge.Amount__c = objProdRC.Amount__c;
                                        else
                                            objContRecCharge.Amount__c = objRelatedQP.BigMachines__Quantity__c * objRelatedQP.Net_Unit_Price__c;
                                        
                                        objContRecCharge.Charge_Description__c = objProdRC.Charge_Description__c;
                                        objContRecCharge.External_Note__c = objProdRC.External_Note__c;
                                        objContRecCharge.Type__c = objProdRC.Type__c;
                                        objContRecCharge.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                        list_ContractRecChargesToInsert.add(objContRecCharge);
                                    }
                                }
                                i++;
                            }
                            
                            // Contract Tier Ranges
                            if(!list_ContractTRsToInsert.isEmpty())
                                insert list_ContractTRsToInsert;
                            
                            // Contract Services
                            if(!list_ContractServicesToInsert.isEmpty())
                                insert list_ContractServicesToInsert;
                            
                            // Contract Recurring Charges
                            if(!list_ContractRecChargesToInsert.isEmpty())
                                insert list_ContractRecChargesToInsert;
                        }
                        // New code to create blank Trier Sets for products without Product_Tier_Set__c entries. Subsequent code is
                        // based on Products WITH Product_Tier_Set__c entries.
                        Map<Id, Product_Tier_Set__c> map_ProductTierSets = new Map<Id, Product_Tier_Set__c>();
                        for (Product_Tier_Set__c objProductTierSet : list_ProductTierSets) map_ProductTierSets.put(objProductTierSet.Product__c, objProductTierSet);
                        for(BigMachines__Quote_Product__c objQP : map_QPIdToQPRecord.values()) {
                            if (!map_ProductTierSets.containsKey(objQP.BigMachines__Product__c)) {
                                // Create "blank" Tier Set
                                Contract_Tier_Set__c objContractTierSet = new Contract_Tier_Set__c(Contract__c = objContract.Id);
                                objContractTierSet.Quote_Product__c = map_ProdIdToQPId.get(objQP.BigMachines__Product__c);
                                BigMachines__Quote_Product__c objQuoteProduct = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                objContractTierSet.Name = objQuoteProduct.BigMachines__Product__r.Name;
                                objContractTierSet.Units_Type__c = 'Messages/Seats/Ports';
                                list_ContractTierSetsToInsert.add(objContractTierSet);
                            }
                        }
                        upsert list_ContractTierSetsToInsert;
                    }
                }
                //Logic to handle Zuora Quotes
                else if(objContract.Zuora_Quote__c != null) {
                    // Querying existing Tier Sets
                    List<Contract_Tier_Set__c> list_TierSetsToDelete = [SELECT Id FROM Contract_Tier_Set__c 
                                                                        WHERE Contract__c = :objContract.Id];
                    // Deleting existing Tier Sets as Tier Set Info will be created freshly
                    if(!list_TierSetsToDelete.isEmpty())
                        delete list_TierSetsToDelete;                    
                    
                    buildZuoraQuoteInfo(objContract);
                    List<Contract_Tier_Set__c> list_ContractTierSetsToInsert = new List<Contract_Tier_Set__c>();
                    if(!map_ProdIdToQPId.isEmpty()) {
                        // Fetching Tier Set Configuration info from Products associated with the Quote
                        List<Product_Tier_Set__c> list_ProductTierSets = [SELECT Name,Product__c,Aggregation_Model__c,Units_Type__c,
                                                                          (SELECT From__c, To__c, Price__c FROM Product_Tier_Ranges__r),
                                                                          (SELECT Service__c, Service__r.Use_Calling_Rates__c FROM Product_Tier_Set_Services__r),
                                                                          (SELECT Amount__c, Charge_Description__c, External_Note__c, Type__c FROM Product_Recurring_Charges__r)
                                                                          FROM Product_Tier_Set__c WHERE Product__c IN :map_ProdIdToQPId.keySet()];
                        System.debug('######'+list_ProductTierSets.size());
                        if(!list_ProductTierSets.isEmpty()) { 
                            list_ContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(list_ProductTierSets, objContract));
                            
                            // Contract Tier Sets
                            if(!list_ContractTierSetsToInsert.isEmpty())
                                insert list_ContractTierSetsToInsert;
                            System.debug('######'+list_ContractTierSetsToInsert.size());
                            Integer i=0;
                            List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
                            List<Contract_Service__c> list_ContractServicesToInsert = new List<Contract_Service__c>();
                            List<Contract_Recurring_Charge__c> list_ContractRecChargesToInsert = new List<Contract_Recurring_Charge__c>();
                            
                            for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSetsToInsert) {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Charge_Detail__c)) {
                                    zqu__QuoteChargeDetail__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Charge_Detail__c);
                                    zqu__QuoteRatePlanCharge__c objRelatedQRPC = map_PrdRtPlChrgeToQtRtPlChrge.get(map_QtChrgeDtlToPrdRtPlChrge.get(objRelatedQP.Id));
                                    // Creating Contract Tier Ranges if default ranges are present
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRange(list_ProductTierSets[i].Product_Tier_Ranges__r , 
                                                                                           objContractTierSet,  objContract));
                                    
                                    // If there are no default ranges then system intelligently creates ranges
                                    if(list_ProductTierSets[i].Product_Tier_Ranges__r == NULL) {                                    
                                        if(objRelatedQRPC.zqu__Quantity__c != null && objRelatedQRPC.zqu__Quantity__c > 0) {
                                            list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , Integer.valueOf(objRelatedQRPC.zqu__Quantity__c), 
                                                                                                           objRelatedQRPC.zqu__EffectivePrice__c , objContract.Zuora_Quote__r.CurrencyISOCode));
                                            
                                            list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , Integer.valueOf(objRelatedQRPC.zqu__Quantity__c) + 1 , 999999999999.0, 
                                                                                                           objRelatedQRPC.zqu__EffectivePrice__c , objContract.Zuora_Quote__r.CurrencyISOCode));
                                            
                                        }
                                        else {
                                            list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , 999999999999.0, 
                                                                                                           objRelatedQRPC.zqu__EffectivePrice__c , objContract.Zuora_Quote__r.CurrencyISOCode));
                                        }                                    
                                    }
                                    // Creating Contract Services
                                    for(Product_Tier_Set_Service__c  objProdTSS : list_ProductTierSets[i].Product_Tier_Set_Services__r) {
                                        Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                        objContService.Service__c = objProdTSS.Service__c;
                                        objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                        objContService.CurrencyISOCode = objContract.Zuora_Quote__r.CurrencyISOCode;
                                        list_ContractServicesToInsert.add(objContService);
                                    }
                                    // Creating Contract Recurring Charges
                                    for(Product_Recurring_Charge__c  objProdRC : list_ProductTierSets[i].Product_Recurring_Charges__r)
                                    {                                    
                                        Contract_Recurring_Charge__c objContRecCharge = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                        // Populate default price if there is one
                                        if(objProdRC.Amount__c != null)
                                            objContRecCharge.Amount__c = objProdRC.Amount__c;
                                        else
                                            objContRecCharge.Amount__c = Integer.valueOf(objRelatedQRPC.zqu__Quantity__c) * objRelatedQRPC.zqu__EffectivePrice__c;
                                        
                                        objContRecCharge.Charge_Description__c = objProdRC.Charge_Description__c;
                                        objContRecCharge.External_Note__c = objProdRC.External_Note__c;
                                        objContRecCharge.Type__c = objProdRC.Type__c;
                                        objContRecCharge.CurrencyISOCode = objContract.Zuora_Quote__r.CurrencyISOCode;
                                        list_ContractRecChargesToInsert.add(objContRecCharge);
                                    }
                                }
                                i++;
                            }
                            
                            System.debug('######'+list_ContractTRsToInsert.size());
                            System.debug('######'+list_ContractServicesToInsert.size());
                            System.debug('######'+list_ContractRecChargesToInsert.size());
                            // Contract Tier Ranges
                            if(!list_ContractTRsToInsert.isEmpty())
                                insert list_ContractTRsToInsert;
                            
                            // Contract Services
                            if(!list_ContractServicesToInsert.isEmpty())
                                insert list_ContractServicesToInsert;
                            
                            // Contract Recurring Charges
                            if(!list_ContractRecChargesToInsert.isEmpty())
                                insert list_ContractRecChargesToInsert;
                        }
                        // New code to create blank Trier Sets for products without Product_Tier_Set__c entries. Subsequent code is
                        // based on Products WITH Product_Tier_Set__c entries.
                        Map<Id, Product_Tier_Set__c> map_ProductTierSets = new Map<Id, Product_Tier_Set__c>();
                        for (Product_Tier_Set__c objProductTierSet : list_ProductTierSets) map_ProductTierSets.put(objProductTierSet.Product__c, objProductTierSet);
                        for(zqu__QuoteChargeDetail__c objQP : map_QPIdToQPRecord.values()) {
                            if (!map_ProductTierSets.containsKey(objQP.zqu__ProductRatePlan__r.zqu__Product__c)) {
                                System.Debug('No Product Tier Set for Quote Charge Detail ' + objQP);
                                // Create "blank" Tier Set
                                Contract_Tier_Set__c objContractTierSet = new Contract_Tier_Set__c(Contract__c = objContract.Id);
                                objContractTierSet.Quote_Charge_Detail__c = map_ProdIdToQPId.get(objQP.zqu__ProductRatePlan__r.zqu__Product__c);
                                System.Debug('Zuora search for Quote Product ' + objContractTierSet.Quote_Product__c);
                                zqu__QuoteChargeDetail__c objQuoteChargeDetail = map_QPIdToQPRecord.get(objContractTierSet.Quote_Charge_Detail__c);
                                objContractTierSet.Name = objQuoteChargeDetail.zqu__ProductRatePlan__r.zqu__Product__r.Name;
                                objContractTierSet.Units_Type__c = 'Messages/Seats/Ports';
                                list_ContractTierSetsToInsert.add(objContractTierSet);
                            }
                        }
                        upsert list_ContractTierSetsToInsert;
                    }                
                }            
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contract does not have a quote associated with it.'));
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                // Roll back changes in case of DML failure
                Database.rollback(objSP);
            }
        }
    }
    
    //Rony Joseph - Code Block Mar 08 2018 - Starts Here 
    //***Method used to create contracts for PureEngage or PureConnect Subscription
    public static void createContractForSubscription(GCR_Content_Document_Detail__c objContract)
    {
        resetStaticVariables();
        
        //Storing the bursting %, by default 25%, but other value can be given in quote.
        GCR_Content_Document_Detail__c objContractforCalculation = [SELECT id,Quote__r.Overage_Allowance__c,Quote__r.Overage_Allowance_Other__c,Quote__r.Overage_Price_Premium__c
                                                                    FROM GCR_Content_Document_Detail__c 
                                                                    WHERE id  = :objContract.id];
        Decimal decBurstpercentage =  objContractforCalculation.Quote__r.Overage_Allowance__c == 'Other' ? objContractforCalculation.Quote__r.Overage_Allowance_Other__c == null ? 1.25 : (objContractforCalculation.Quote__r.Overage_Allowance_Other__c / 100) + 1 : 1.25;
        Decimal decOveragePremium = objContractforCalculation.Quote__r.Overage_Price_Premium__c == null ? 1.30 : 1 + (objContractforCalculation.Quote__r.Overage_Price_Premium__c / 100);

        // DB Save-point
        Savepoint objSP = Database.setSavepoint();
        try
        {   
            System.debug('objContract'+objContract);
            if(objContract.Quote__c != null)
            {
                if(strPricingModel == null){
                    strPricingModel = '';
                }
                // Querying existing Tier Sets
                List<Contract_Tier_Set__c> list_TierSetsToDelete = [SELECT Id FROM Contract_Tier_Set__c 
                                                                    WHERE Contract__c = :objContract.Id];
                // Deleting existing Tier Sets as Tier Set Info will be created freshly
                if(!list_TierSetsToDelete.isEmpty())
                    delete list_TierSetsToDelete;
                
                map_ProdIdToQPId = new Map<Id,Id>();
                Map<Id,BigMachines__Quote_Product__c> map_QPIdToQPRecord = new Map<Id,BigMachines__Quote_Product__c>([SELECT Id,BigMachines__Product__c,
                                                                                                                      BigMachines__Product__r.Name, BigMachines__Product__r.Billing_Category__c,
                                                                                                                      BigMachines__Quantity__c,Net_Unit_Price_1_Per_Month__c FROM BigMachines__Quote_Product__c
                                                                                                                      WHERE BigMachines__Quote__c = :objContract.Quote__c AND BigMachines__Product__r.Type__c != 'Genesys Care']);
                
                System.debug('map_QPIdToQPRecord'+map_QPIdToQPRecord);
                // Fetching Quote Products and creating a map of Product Id to Quote Product Id
                for(BigMachines__Quote_Product__c objQP : map_QPIdToQPRecord.values())
                    map_ProdIdToQPId.put(objQP.BigMachines__Product__c,objQP.Id);
                
                if(!map_ProdIdToQPId.isEmpty())
                {
                    System.debug('map_ProdIdToQPId'+map_ProdIdToQPId);
                    // Fetching Tier Set Configuration info from Products associated with the Quote
                    List<Product_Tier_Set__c> list_ProductTierSets = [SELECT Id,Name,Product__c,Product__r.Name,Product__r.Pricing_Model__c,Aggregation_Model__c,Units_Type__c,Product__r.Burstable_or_Non_Burstable__c,
                                                                      (SELECT From__c,To__c,Price__c FROM Product_Tier_Ranges__r),
                                                                      (SELECT Service__c,Service__r.Use_Calling_Rates__c,service__r.Usage_Type__c,service__r.Service_Type_Value__c FROM Product_Tier_Set_Services__r),
                                                                      (SELECT Amount__c,Charge_Description__c,External_Note__c,Type__c FROM Product_Recurring_Charges__r)
                                                                      FROM Product_Tier_Set__c WHERE Product__c IN :map_ProdIdToQPId.keySet() and Product__r.Burstable_or_Non_Burstable__c = true];
                    System.debug('list_ProductTierSets'+list_ProductTierSets);   
                    
                    if(objContract.Quote__r.Offering_Type__C == 'PureEngage Subscription'||strOfferingTypeforSub== 'PureEngage Subscription') {
                        //Map containing Product Id to User Product Tier Sets
                        Map<Id,Product_Tier_Set__c> map_IdtoUserPTS = new Map<Id,Product_Tier_Set__c> ();
                        //Map containing Product Id to Concurrent Product Tier Sets
                        Map<Id,Product_Tier_Set__c> map_IdtoConcurrentPTS = new Map<Id,Product_Tier_Set__c> ();
                        //Map containing Product Id to None Product Tier Sets
                        Map<Id,Product_Tier_Set__c> map_IdtoNonePTS = new Map<Id,Product_Tier_Set__c> ();
                        //Map containing Product Id to Concurrent Product Tier Sets
                        Map<Id,Product_Tier_Set__c> map_basePackageMap = new Map<Id,Product_Tier_Set__c> ();
                        //Map containing Product Id to Product Tier Service Sets
                        Map<Id,list<Product_Tier_Set_Service__c>> map_ptsidtoptss = new Map<Id,list<Product_Tier_Set_Service__c>>();
                        //Map containing Product Id to Base Bckage Product Tier Service Sets
                        Map<Id,list<Product_Tier_Set_Service__c>> map_ptsidtoptssBase = new Map<Id,list<Product_Tier_Set_Service__c>>();
                        //List of seperated User type Contract Tier Sets to insert
                        List<Contract_Tier_Set__c> list_userContractTierSetsToInsert = new List<Contract_Tier_Set__c> ();
                        //List of seperated Concurrent type Contract Tier Sets to insert
                        List<Contract_Tier_Set__c> list_concurrentContractTierSetsToInsert = new List<Contract_Tier_Set__c> ();
                        //List of seperated Non-user non-Concurrent type Contract Tier Sets to insert
                        List<Contract_Tier_Set__c> list_noneContractTierSetsToInsert = new List<Contract_Tier_Set__c> ();
                        //List of base package Contract Tier Sets to insert
                        List<Contract_Tier_Set__c> list_basepackagelist = new List<Contract_Tier_Set__c> ();
                        //List of Contract Tier Services to insert
                        List<Contract_Service__c> list_ContractServicesToInsert = new List<Contract_Service__c>();
                        
                        Set<ID> setBaseServiceID = new Set<ID>();
                        
                        BigMachines__Quote__c objQuote = [select Pricing_Model__c from BigMachines__Quote__c  where id =:objContract.Quote__c ];
                        integer i=0;
                        for(Product_Tier_Set__c objPTS:list_ProductTierSets){   
                            system.debug('objPTS'+ objPTS);
                            if((objPTS.Product__r.Pricing_Model__c.contains('User'))||(objPTS.Product__r.Pricing_Model__c.contains('Concurrent'))) {
                                if(objPTS.name.contains('PureEngage Base Package - Others'))
                                    map_PTSIdtoPTSSBase.put(map_ProdIdToQPId.get(objPTS.Product__c),list_ProductTierSets[i].Product_Tier_Set_Services__r);
                                else    
                                    map_PTSIdtoPTSS.put(map_ProdIdToQPId.get(objPTS.Product__c),list_ProductTierSets[i].Product_Tier_Set_Services__r);
                                system.debug('map_ptsidtoptss'+ map_ptsidtoptss);
                                if(objPTS.Product_Tier_Set_Services__r.size()==0) {
                                    map_IdtoNonePTS.put(objPTS.product__c,objPTS);
                                }
                                for(Product_Tier_Set_Service__c  objProdTSS : objPTS.Product_Tier_Set_Services__r)
                                {
                                    System.debug('objProdTSS'+objProdTSS );
                                    System.debug('objProdTSS.service__r.Usage_Type__c'+objProdTSS.service__r.Usage_Type__c );
                                    if(!objPTS.name.contains('PureEngage Base Package - Others'))
                                    {
                                        //Anju / Eric If Service's Service Type Value = 19...we want to insert it with prices regardless of User/Concurrent in the Quote
                                        if (objProdTSS.service__r.Service_Type_Value__c == 19 /**/) {
                                            // ECD
                                            // !!Price this service!!
                                            //list_NoneContractTierSetsToInsert or map_IdtoNonePTS
                                            if(objQuote.Pricing_Model__c.contains('User'))
                                                map_IdtoUserPTS.put(objPTS.product__c,objPTS);
                                            if(objQuote.Pricing_Model__c.contains('Concurrent'))
                                                map_IdtoConcurrentPTS.put(objPTS.product__c,objPTS);
                                        }
                                        else if(objProdTSS.service__r.Usage_Type__c == 2 && !objPTS.name.contains('PureEngage Base Package')) {
                                            map_IdtoUserPTS.put(objPTS.product__c,objPTS);}
                                        else if(objProdTSS.service__r.Usage_Type__c == 1 && !objPTS.name.contains('PureEngage Base Package')){
                                            map_IdtoConcurrentPTS.put(objPTS.product__c,objPTS);}
                                        // Service does not have Usage Type Designation. Insert it with pricing.
                                        // Therefore put it into map that will be priced based on the pricing model
                                        else if (objQuote.Pricing_Model__c.contains('User')) {
                                            map_IdtoUserPTS.put(objPTS.product__c,objPTS);
                                            if(objPTS.name.contains('PureEngage Base Package') )
                                                setBaseServiceID.add(objProdTSS.Service__c);
                                        }
                                        else if (objQuote.Pricing_Model__c.contains('Concurrent')) {
                                            map_idtoconcurrentpts.put(objPTS.product__c,objPTS);
                                            if(objPTS.name.contains('PureEngage Base Package') )
                                                setBaseServiceID.add(objProdTSS.Service__c);
                                        }
                                        System.debug(setBaseServiceID);
                                    }
                                    else
                                    {
                                        System.debug( objQuote.Pricing_Model__c + '' + objProdTSS.service__r.Usage_Type__c + '' + setBaseServiceID);
                                        if (objQuote.Pricing_Model__c.contains('User') && objProdTSS.service__r.Usage_Type__c == 2 && !setBaseServiceID.contains(objProdTSS.service__c))
                                            map_basePackageMap.put(objPTS.product__c,objPTS);
                                        if (objQuote.Pricing_Model__c.contains('Concurrent') && objProdTSS.service__r.Usage_Type__c == 1 && !setBaseServiceID.contains(objProdTSS.service__c))
                                            map_basePackageMap.put(objPTS.product__c,objPTS);
                                        System.debug(map_basePackageMap);
                                    }
                                    
                                    
                                    
                                }
                                
                            }
                            i++;
                        }
                        System.debug('map_idtouserpts'+map_idtouserpts+'map_idtoconcurrentpts'+map_idtoconcurrentpts);
                        list_UserContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(map_idtouserpts.values(),objContract));
                        list_ConcurrentContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(map_idtoconcurrentpts.values(),objContract));   
                        list_NoneContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(map_IdtoNonePTS.values(),objContract));
                        list_BasePackageList.addall(getContractTierSetsByProductTierSets(map_basePackageMap.values(),objContract));
                        
                        //inserting all the contract tier sets
                        insert list_UserContractTierSetsToInsert;
                        insert list_ConcurrentContractTierSetsToInsert;
                        insert list_NoneContractTierSetsToInsert;
                        insert list_BasepackageList;
                        
                        System.debug('list_userContractTierSetsToInserts'+list_userContractTierSetsToInsert+'list_concurrentContractTierSetsToInsert'+list_concurrentContractTierSetsToInsert);
                        //List of Contract Tier Ranges to insert
                        List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
                        //Creation for Tier Ranges for Non-User Non-Concurrent Tier Sets
                        for(Contract_Tier_Set__c objContractTierSet : list_noneContractTierSetsToInsert)
                        {
                            if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)) {
                                
                                BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                
                                System.debug('QuoteProduct'+objRelatedQP);
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                               0 , objContract.Quote__r.CurrencyISOCode));
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP), 
                                                                                               objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP)+1 , 999999999999.0, 
                                                                                               objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                
                            }
                        }
                        //Creation of Contract Tier Ranges if the Pricing Model of the Quote is User
                        if(objQuote.Pricing_Model__c.contains('User'))
                        {
                            for(Contract_Tier_Set__c objContractTierSet : list_UserContractTierSetsToInsert)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)){
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP), 
                                                                                                   objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP)+1 , 999999999999.0, 
                                                                                                   objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                    
                                    for(Product_Tier_Set_Service__c  objProdTSS : map_PTSIdtoPTSS.get(objContractTierSet.Quote_Product__c))
                                    {   //Creating Contract tier services for service with usage type as 2
                                        if(objProdTSS.service__r.Usage_Type__c == 2 || objProdTSS.service__r.Usage_Type__c == null || objProdTSS.service__r.Service_Type_Value__c == 19) {
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }
                                    }
                                }
                            }
                            //Creating of Concurrent Contract Tier Ranges with zero values
                            for(Contract_Tier_Set__c objContractTierSet : list_ConcurrentContractTierSetsToInsert)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)){
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    for(Product_Tier_Set_Service__c  objProdTSS : map_ptsidtoptss.get(objContractTierSet.Quote_Product__c))
                                    {//Creation of Concurrent Contract Tier Services
                                        if(objProdTSS.service__r.Usage_Type__c == 1) {
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }
                                    }
                                    
                                }
                            }
                            //Creation of Contract Tier Sets and Tier Services for Base Package Products
                            for(Contract_Tier_Set__c objContractTierSet : list_basepackagelist)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)) {
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , 999999999999.0, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    for(Product_Tier_Set_Service__c  objProdTSS : map_ptsidtoptssBase.get(objContractTierSet.Quote_Product__c))
                                    {
                                        if(!setBaseServiceID.contains(objProdTSS.service__c)) {
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }
                                    }
                                    
                                }
                            }
                            
                        }    
                        //Creation of Contract Tier Sets and Services if the Pricing Model of the Quote is Concurrent
                        else if(objQuote.Pricing_Model__c.contains('Concurrent'))   
                        {
                            for(Contract_Tier_Set__c objContractTierSet : list_ConcurrentContractTierSetsToInsert)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)) {
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP), 
                                                                                                   objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP)+1 , 999999999999.0, 
                                                                                                   objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                    for(Product_Tier_Set_Service__c  objProdTSS :map_ptsidtoptss.get(objContractTierSet.Quote_Product__c))
                                    {  //Creation of Contract Tier Service Sets if usage type is 1
                                        if(objProdTSS.service__r.Usage_Type__c == 1 || objProdTSS.service__r.Usage_Type__c == null){
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }      
                                    }
                                }
                            }
                            for(Contract_Tier_Set__c objContractTierSet : list_UserContractTierSetsToInsert)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)){
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    for(Product_Tier_Set_Service__c  objProdTSS : map_PTSidtoPTSS.get(objContractTierSet.Quote_Product__c))
                                    {//Creation of User Contract Tier Service Sets if usage type is 2
                                        if(objProdTSS.service__r.Usage_Type__c == 2 || objProdTSS.service__r.Service_Type_Value__c == 19) {
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }     
                                    }
                                    
                                }
                            }
                            //Creation of Contract Tier Sets for Base Package Products
                            for(Contract_Tier_Set__c objContractTierSet : list_BasePackageList)
                            {
                                if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c)){
                                    
                                    BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                    
                                    list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , 999999999999.0, 
                                                                                                   0 , objContract.Quote__r.CurrencyISOCode));
                                    for(Product_Tier_Set_Service__c  objProdTSS : map_ptsidtoptssBase.get(objContractTierSet.Quote_Product__c))
                                    {
                                        
                                        if(!setBaseServiceID.contains(objProdTSS.service__c)){
                                            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                            objContService.Service__c = objProdTSS.Service__c;
                                            objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                            objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                            list_ContractServicesToInsert.add(objContService);
                                        }
                                    }
                                    
                                }
                            }
                        }                       
                        //insertion of Contract Tier Sets
                        if(!list_ContractTRsToInsert.isEmpty())
                        {
                            System.debug('list_ContractTRsToInsert'+list_ContractTRsToInsert);
                            insert list_ContractTRsToInsert;
                        }
                        //insertion of Contract Tier Services
                        if(!list_ContractServicesToInsert.isEmpty())
                        {
                            System.debug('list_ContractServicesToInsert'+list_ContractServicesToInsert);
                            insert list_ContractServicesToInsert;
                        }
                        
                    }   
                    //Creation of Contract Tier Sets and Services if Offering type does not contain PureEngageSubscription
                    else{  
                        // Creating Contract Tier Sets
                        List<Contract_Tier_Set__c> list_ContractTierSetsToInsert = new List<Contract_Tier_Set__c>();
                        if(!list_ProductTierSets.isEmpty())
                            list_ContractTierSetsToInsert.addAll(getContractTierSetsByProductTierSets(list_ProductTierSets, objContract));
                        
                        // Contract Tier Sets
                        if(!list_ContractTierSetsToInsert.isEmpty())
                            insert list_ContractTierSetsToInsert;
                        
                        Integer i=0;
                        List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
                        List<Contract_Service__c> list_ContractServicesToInsert = new List<Contract_Service__c>();
                        List<Contract_Recurring_Charge__c> list_ContractRecChargesToInsert = new List<Contract_Recurring_Charge__c>();
                        
                        for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSetsToInsert)
                        {
                            if(map_QPIdToQPRecord.containsKey(objContractTierSet.Quote_Product__c))
                            {
                                BigMachines__Quote_Product__c objRelatedQP = map_QPIdToQPRecord.get(objContractTierSet.Quote_Product__c);
                                
                                
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , 0 , objRelatedQP.BigMachines__Quantity__c, 
                                                                                               0 , objContract.Quote__r.CurrencyISOCode));
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , objRelatedQP.BigMachines__Quantity__c + 1 , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP), 
                                                                                               objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                list_ContractTRsToInsert.addAll(setupContractTierRangeForEmpty(objContractTierSet , (objRelatedQP.BigMachines__Quantity__c * decBurstpercentage).round(System.RoundingMode.UP)+1 , 999999999999.0, 
                                                                                               objRelatedQP.Net_Unit_Price_1_Per_Month__c * decOveragePremium, objContract.Quote__r.CurrencyISOCode));
                                
                                // Creating Contract Services
                                for(Product_Tier_Set_Service__c  objProdTSS : list_ProductTierSets[i].Product_Tier_Set_Services__r)
                                {
                                    Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                                    objContService.Service__c = objProdTSS.Service__c;
                                    objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                                    objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                                    list_ContractServicesToInsert.add(objContService);
                                }
                                
                            }
                            i++;
                        }
                        
                        // Contract Tier Ranges
                        if(!list_ContractTRsToInsert.isEmpty())
                            insert list_ContractTRsToInsert;
                        
                        // Contract Services
                        if(!list_ContractServicesToInsert.isEmpty())
                            insert list_ContractServicesToInsert;
                        
                        
                    }
                    
                }
                
            }         
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contract does not have a quote associated with it.'));
        }
        catch(Exception ex)
        {
            System.debug('Error message'+ex.getMessage()+'\n'+ex.getStackTraceString());
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
        
    }
    //Rony Joseph - Code Block Mar 08 2018 - Ends Here 
    //*** Method to load quantity and price for Zuora Quotes
    public static void buildZuoraQuoteInfo(GCR_Content_Document_Detail__c objContract) {
        if(objContract.Contract_Type__c != 'Cloud Billing - Telco') {            
            map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>(
                [SELECT zqu__ProductRatePlanCharge__r.zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                 zqu__ProductRatePlan__r.zqu__Product__r.Type__c, zqu__Quote__c, zqu__BillingTax__c,
                 zqu__ProductRatePlan__r.zqu__Product__c, zqu__ProductRatePlan__r.zqu__Product__r.Name,
                 zqu__BillingSubtotal__c, zqu__BillingTotal__c, zqu__BillingDiscount__c
                 FROM zqu__QuoteChargeDetail__c
                 WHERE zqu__Quote__c = :objContract.Zuora_Quote__c
                 AND zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c != 'Voice Services']);            
            
        }
        else {
            map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>(
                [SELECT zqu__ProductRatePlanCharge__r.zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                 zqu__ProductRatePlan__r.zqu__Product__r.Type__c, zqu__Quote__c, zqu__BillingTax__c,
                 zqu__ProductRatePlan__r.zqu__Product__c, zqu__ProductRatePlan__r.zqu__Product__r.Name,
                 zqu__BillingSubtotal__c, zqu__BillingTotal__c, zqu__BillingDiscount__c
                 FROM zqu__QuoteChargeDetail__c
                 WHERE zqu__Quote__c = :objContract.Zuora_Quote__c
                 AND zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c = 'Voice Services']);
        }  
        
        for(zqu__QuoteChargeDetail__c objQtChrgeDtl : map_QPIdToQPRecord.values()) {
            //Build a map between Quote Charge Detail and Product Rate Plan
            map_QtChrgeDtlToPrdRtPlChrge.put(objQtChrgeDtl.Id, objQtChrgeDtl.zqu__ProductRatePlanCharge__c);
            map_ProdIdToQPId.put(objQtChrgeDtl.zqu__ProductRatePlan__r.zqu__Product__c, objQtChrgeDtl.Id);                         
        }
        
        //Build a map between product rate plan and quote rate plan charge
        for(zqu__QuoteRatePlanCharge__c objQtRtPlChrg : [SELECT Id, zqu__Discount__c, zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                                                         zqu__EffectivePrice__c, zqu__Quantity__c, zqu__UOM__c
                                                         FROM zqu__QuoteRatePlanCharge__c 
                                                         WHERE zqu__ProductRatePlanCharge__c IN :map_QtChrgeDtlToPrdRtPlChrge.values()
                                                         AND zqu__QuoteRatePlan__r.zqu__Quote__c =: objContract.Zuora_Quote__c]) {            
                                                             map_PrdRtPlChrgeToQtRtPlChrge.put(objQtRtPlChrg.zqu__ProductRatePlanCharge__c, objQtRtPlChrg);
                                                         }
        
        System.debug('######'+map_QPIdToQPRecord.size());
        System.debug('######'+map_QtChrgeDtlToPrdRtPlChrge.size());
        System.debug('######'+map_PrdRtPlChrgeToQtRtPlChrge.size());
        System.debug('######'+map_ProdIdToQPId.size());        
    }
    
    private static void resetStaticVariables(){
        map_QtChrgeDtlToPrdRtPlChrge = new Map<Id, Id>();
        map_PrdRtPlChrgeToQtRtPlChrge = new Map<Id, zqu__QuoteRatePlanCharge__c>(); 
        map_ProdIdToQPId = new Map<Id,Id>();
        map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>();  
    }
    //Nitin - Code Block Jun 19 - Ends Here 
    //
    //Added by Vijay - Oct 17th - Start
    public static List<Contract_Tier_Set__c>  getContractTierSetsByProductTierSets(List<Product_Tier_Set__c> list_ProductTierSets, 
                                                                                   GCR_Content_Document_Detail__c objContract )
    {
        List<Contract_Tier_Set__c> list_ContractTierSetsToInsert = new List<Contract_Tier_Set__c>(); 
        for(Product_Tier_Set__c objProdTierSet : list_ProductTierSets) {
            Contract_Tier_Set__c objContractTierSet = new Contract_Tier_Set__c(Contract__c = objContract.Id);
            objContractTierSet.Name = objProdTierSet.Name;
            objContractTierSet.Aggregation_Model__c = objProdTierSet.Aggregation_Model__c;
            objContractTierSet.Units_Type__c = objProdTierSet.Units_Type__c;
            objContractTierSet.CurrencyISOCode = objContract.Quote__c == NULL ?  objContract.Zuora_Quote__r.CurrencyISOCode : 
            objContract.Quote__r.CurrencyISOCode;
            // Associating corresponding Quote Product to the Tier Set
            System.debug('map_ProdIdToQPId'+map_ProdIdToQPId);
            objContractTierSet.Quote_Charge_Detail__c = objContract.Zuora_Quote__c != null ? map_ProdIdToQPId.get(objProdTierSet.Product__c) : null;
            objContractTierSet.Quote_Product__c = objContract.Quote__c != null ? map_ProdIdToQPId.get(objProdTierSet.Product__c) : null;
            objContractTierSet.Product__c = objContract.Quote__c != null ? objProdTierSet.Product__c : null;
            System.Debug('getContractTierSetsByProductTierSets: Adding Tier Set ' + objContractTierSet);
            list_ContractTierSetsToInsert.add(objContractTierSet);
        }
        return list_ContractTierSetsToInsert;
    }
    
    public static List<Contract_Tier_Range__c> setupContractTierRange( List<Product_Tier_Range__c> list_ProductTR, Contract_Tier_Set__c objContractTierSet, 
                                                                      GCR_Content_Document_Detail__c objContract)
    {
        List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
        for(Product_Tier_Range__c  objProdTR : list_ProductTR) {
            Contract_Tier_Range__c objContractTR = new Contract_Tier_Range__c(Contract_Tier_Set__c = objContractTierSet.Id);
            objContractTR.From__c = objProdTR.From__c;
            objContractTR.To__c = objProdTR.To__c;
            objContractTR.Price__c = objProdTR.Price__c;
            objContractTR.CurrencyISOCode = objContract.Quote__c == NULL ?  objContract.Zuora_Quote__r.CurrencyISOCode : 
            objContract.Quote__r.CurrencyISOCode;
            list_ContractTRsToInsert.add(objContractTR);
        }
        return list_ContractTRsToInsert; 
    }
    
    public static List<Contract_Tier_Range__c> setupContractTierRangeForEmpty(Contract_Tier_Set__c objContractTierSet,  decimal decFrom, decimal decTo,
                                                                              decimal netPrice, String CurrencyCode)
    {
        List<Contract_Tier_Range__c> list_ContractTRsToInsert = new List<Contract_Tier_Range__c>();
        Contract_Tier_Range__c objContractTR = new Contract_Tier_Range__c(Contract_Tier_Set__c = objContractTierSet.Id);
        objContractTR.From__c = decFrom;
        objContractTR.To__c = decTo;
        objContractTR.Price__c = netPrice;
        objContractTR.CurrencyISOCode = CurrencyCode;
        list_ContractTRsToInsert.add(objContractTR);
        return list_ContractTRsToInsert;
    }
    //Added by Vijay - Oct 17th - End
    //
    // Added by Vijay - CRMBILL -166. Oct 6th 2017 - Start
    // This method will check the condition from custom label and set up PureCloud Condition.
    public static boolean blnAllowRateOverride(String strSourceName, String strSourceList){
        if(strSourceList == 'NONE'){
            return false;
        }else if(strSourceList == 'ALL'){
            return true;
        }
        Set<String> set_SourceNameCheck = getSetOfStringsByCommaSeperated(strSourceList);
        return set_SourceNameCheck.contains(strSourceName);
    }    
    
    public static set<String> getSetOfStringsByCommaSeperated(String strLabel){
        Set<String> set_Strings = new Set<String>();
        String strCommaSepSourceNames = strLabel;
        if(strCommaSepSourceNames.contains(',')){
            set_Strings.addAll(strCommaSepSourceNames.split(','));
        }else{
            set_Strings.add(strCommaSepSourceNames);
        }
        return set_Strings;
    }
    // Added by Vijay - CRMBILL -166. Oct 6th 2017 - End
    
    public static String getSureTaxProductAPNFromResponseCode(String strResponseCode, String strOfferingPrefix) {
        String strProductAPN = 'Response Code ' + strResponseCode + ' not mapped';
        if(SureTax_Settings__c.getInstance(strResponseCode) != NULL) {
            strProductAPN = SureTax_Settings__c.getInstance(strResponseCode).Product_APN__c;
        }
        return strOfferingPrefix + '-' + strProductAPN;
    }
    
    public static Map<String, Product2> getMapOfferingAPNNumberToProduct(Set<String> setTaxProductAPNs) {
        System.Debug('CloudBilling.getMapOfferingAPNNumberToProduct setTaxProductAPNs ' + setTaxProductAPNs);
        List<Product2> listTaxProducts = [select Id, Name, APN_Number__c, Unit_Of_Measure__c from Product2 where APN_Number__c in :setTaxProductAPNs];
        Map<String, Product2> map_ProductAPNToProduct = new Map<String, Product2>();
        for (Product2 objProduct : listTaxProducts) {
            map_ProductAPNToProduct.put(objProduct.APN_Number__c, objProduct);
        }
        return map_ProductAPNToProduct;
    }
    private static String appendNextOption(String strOptions, String strNextOption) {
        if (String.isBlank(strOptions)) {
            return strNextOption;
        } else {
            return strOptions + ',' + strNextOption;
        }
    }
    public static String populateJobLogOptions(CloudBillingData objCloudBillingData) {
        if (objCloudBillingData == null) {
            return null;
        }
        String strOptions;
        if (objCloudBillingData.contractId != null) {
            strOptions = appendNextOption(strOptions, 'ContractId:' + objCloudBillingData.contractId);
        }
        if (objCloudBillingData.subsidiary != null) {
            strOptions = appendNextOption(strOptions, 'Subsidiary ' + objCloudBillingData.subsidiary);
        }
        if (objCloudBillingData.region != null) {
            strOptions = appendNextOption(strOptions, 'Region ' + objCloudBillingData.region);
        }
        if (objCloudBillingData.edition != null) {
            strOptions = appendNextOption(strOptions, 'Edition ' + objCloudBillingData.edition);
        }
        return strOptions;
    }
    
    //Added by Rony Joseph - March 29 2018 -Start
    //Auto generation of Contract from Master Orders
    public static void createBillingContract(list<Order__c> list_MasterOrders)
    {
        try{
            //List of Quote Id's from the Master Orders
            List<Id> list_QuoteIds = new List<Id>();
            //Map from Order ID to the Contract
            Map<Id,GCR_Content_Document_Detail__c> map_IdtoContract = new Map<Id,GCR_Content_Document_Detail__c>(); 
            //Map from Order ID to the Account Address
            Map<Id,Account_Order_Address__c> map_IdtoAddress = new Map<Id,Account_Order_Address__c>();
            
            for(order__C objOrder: list_MasterOrders) {
                if(objOrder.Quote__c!=null)
                    list_QuoteIds.add(objOrder.Quote__c);
            }
            
            //Obtaining Quote detials that are related to Master Orders and putting them in a map.
            Map<Id,BigMachines__Quote__c> map_IdtoQuote = new map<Id,BigMachines__Quote__c>([Select id,End_User_ID__c,Pricing_Model__c,Usage_Data_Submission_Method__c,Contracts__c from BigMachines__Quote__c where id in :list_QuoteIds]);
            
            for(order__C objOrder: list_MasterOrders) 
                list_QuoteIds.add(map_IdtoQuote.get(objOrder.Quote__c).End_User_ID__c);
            
            List<GCR_Content_Document_Detail__c> list_ExistingContract = [SELECT Name,Quote__r.order__c 
                                                                          FROM GCR_Content_Document_Detail__c 
                                                                          WHERE Status__c = 'Approved' 
                                                                          AND Account_Name__c in :list_QuoteIds
                                                                          AND Document_Name__c = 'Cloud Billing Contract' ];
            
            for(GCR_Content_Document_Detail__c objContract:list_ExistingContract)    {
                map_IdtoContract.put(objContract.Quote__r.order__c ,objContract);
            }
            
            List<Account_Order_Address__c> list_BillingAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                                  Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c,Attention_To__c, Order__c, Quote__c, Zuora_Quote__c,Quote__r.order__c,Zuora_Quote__r.order__c
                                                                  FROM Account_Order_Address__c WHERE ( Quote__c  in :list_QuoteIds) 
                                                                  and Address_Type__c = 'Bill To'];             
            
            for(Account_Order_Address__c objAccountAddress:list_BillingAddress){
                if(objAccountAddress.Zuora_Quote__c != null)
                    map_IdtoAddress.put(objAccountAddress.Zuora_Quote__r.order__c,objAccountAddress);
                else
                    map_IdtoAddress.put(objAccountAddress.Quote__r.order__c,objAccountAddress);
            }
            
            for(order__C objOrder: list_MasterOrders) {
                
                strOfferingTypeforSub = objOrder.Offering_Type__c;
                
                //For busrting quote's order, no contract created
                if(!map_IdtoContract.containsKey(objOrder.id) && map_IdtoQuote.get(objOrder.Quote__c).Contracts__c == null) {
                    // Creating Cloud Billing Contract
                    List<GCR_Content_Document_Detail__c> list_NewContracts = new List<GCR_Content_Document_Detail__c>();
                    GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
                    objContract.Account_Name__c = objOrder.Quote__c != null ? map_IdtoQuote.get(objOrder.Quote__c).End_User_ID__c :null;
                    objContract.Usage_Data_Submission_Method__c = objOrder.Quote__c != null ? map_IdtoQuote.get(objOrder.Quote__c).Usage_Data_Submission_Method__c :'Automated';
                    objContract.Document_Name__c = 'Cloud Billing Contract';
                    objContract.Quote__c = objOrder.Quote__c;
                    objContract.PO__c = objOrder.PO_Number__c;
                    objContract.Order_Date_Option__c = 'Last Day of Usage Month';
                    objContract.Status__c = 'New';
                    objContract.Active__c = true;
                    strPricingModel = map_IdtoQuote.get(objOrder.Quote__c).Pricing_Model__c;
                    list_NewContracts.add(objContract);                    
                    insert list_NewContracts;
                    
                    //Creating Account Addresses
                    List<Account_Order_Address__c> list_Acc_Add_new = new List<Account_Order_Address__c>();                    
                    for(GCR_Content_Document_Detail__c objConrtact : list_NewContracts ) {                        
                        Account_Order_Address__c objAddress = new Account_Order_Address__c();                        
                        objAddress =   map_IdtoAddress.get(objOrder.Id);        
                        objAddress.Id = NULL;
                        objAddress.GCR_Content_Document_Detail__c = objConrtact.Id;
                        objAddress.Order__c = objOrder.Id;
                        objAddress.CurrencyIsoCode = objOrder.CurrencyIsoCode;
                        objAddress.Address_Type__c = 'Bill To';
                        list_Acc_Add_new.add(objAddress);
                        
                        CloudBillingUtil.resetServiceInfoFromQuote(objConrtact,strOfferingTypeforSub);  
                        
                    }
                    //Insert the new address
                    Insert list_Acc_Add_new;
                    
                    // Update Order synced flag
                    objOrder.Synced_with_Contract__c = true;
                    
                }
            }              
        }       
        catch(Exception ex)
        {
            System.debug('Error'+ex.getMessage()+'\n'+ex.getStackTraceString());
        }
    } 
    //Added by Rony Joseph - March 29 2018 -End
    
    public static Boolean isBillingLastMonth(String strOffering) {
        String strOfferingList;
        if(Test.isRunningTest()) {
            strOfferingList = 'PureConnect,OtherOffering';
        } else {
            strOfferingList = Label.Billing_Offerings_Data_Starts_Last_Month;
        }
        return CloudBillingUtil.getSetOfStringsByCommaSeperated(strOfferingList).contains(strOffering);
    }
    public static Cloud_Billing_Log__c getLogLastMonth(Cloud_Billing_Log__c objThisMonthLog) {
        String strDay = '1';
        if (objThisMonthLog.Day__c != null) {
            strDay = objThisMonthLog.Day__c;
        }
        Date dtDateThisMonth = Date.newInstance(Integer.valueOf(objThisMonthLog.Year__c), Integer.valueOf(objThisMonthLog.Month__c), Integer.valueOf(strDay));
        Date dtDateLastMonth = dtDateThisMonth.addMonths(-1);
		Cloud_Billing_Log__c objLastMonthLog = new Cloud_Billing_Log__c(Year__c = String.valueOf(dtDateLastMonth.year()),
                                                                    Month__c = String.valueOf(dtDateLastMonth.month()),
                                                                    Day__c = String.valueOf(dtDateLastMonth.day())
                                                                       );
        System.Debug('CloudBillingUtil.getLogLastMonth : objThisMonthLog ' + objThisMonthLog + ' objLastMonthLog ' + objLastMonthLog);
        return objLastMonthLog;
    }
    public static Map<Id, Subscription__c> getMapMasterOrderIdToActiveSubscription(List<Id> list_masterOrderIds) {
        Map<Id, Subscription__c> mapMasterOrderIdToActiveSubscription = new Map<Id, Subscription__c>();
        List<Order__c> listMasterOrders = [select Id,
                                           (select Start_Date__c from Subscriptions__r where Status__c = 'Active' Order By CreatedDate desc) // ciritcal as the [0] element will be the one
                                           from Order__c where Id in :list_masterOrderIds];
        for (Order__c objMasterOrder : listMasterOrders) {
            if (objMasterOrder.Subscriptions__r != null && objMasterOrder.Subscriptions__r.size() > 0) {
                mapMasterOrderIdToActiveSubscription.put(objMasterOrder.Id, objMasterOrder.Subscriptions__r[0]);
            }
        }
        return mapMasterOrderIdToActiveSubscription;
    }
}