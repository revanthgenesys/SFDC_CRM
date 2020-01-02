/*
* Class Name		: CloudBillingPureCloudRRScheduler
* Description		: This scheduler will create "PureVoice Revenue Request" record type Cloud Billing Report Instances
* 					  for the Approved Contracts with Opportunity type "PureCloud" and Current day between Pricing start
* 					  date and Pricing End Date.
* Scheduled Class	: <NIL>
* Test Class/Method: TestCloudBilling.testCloudBillingPureCloudRRScheduler()
* Util Classes		: <NIL>
* Created By		: Vijay Gopi
* Last Modified By	: Vijay Gopi
*/
global class CloudBillingPureCloudRRScheduler implements Schedulable {
    public static final ID CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Cloud_Billing_Report_Instance__c'
                                                                          AND DeveloperName = 'PureVoice_Revenue_Request'].id;
    
    global void execute(SchedulableContext SC) {
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: execute -> Start');
        runProcess();
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: execute -> End');
    }
    
    public static void runProcess(){
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: runProcess -> Start');
        List<GCR_Content_Document_Detail__c> list_Contracts ; 
        list_Contracts = getContracts();
        
        List<Cloud_Deployment__c> list_CloudDeployments ;
        if(list_Contracts.size() > 0){
            list_CloudDeployments = getCloudDeployments(list_Contracts);
        }
        
        if(list_CloudDeployments != NULL){
            System.debug('list_CloudDeployments.size() ' + list_CloudDeployments.size());
            if(list_CloudDeployments.size() > 0){
                createNewCloudBillingReportInstances(list_CloudDeployments);
            }
        }
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: runProcess -> End');
    }
    
    private static List<GCR_Content_Document_Detail__c> getActiveContracts() {
    	List<GCR_Content_Document_Detail__c> list_ActiveContracts =
            [SELECT Id, Pricing_Start_Date__c 
             FROM GCR_Content_Document_Detail__c
             WHERE Status__c = 'Approved'
             AND Product_Group__c = 'PureCloud'  
             AND Document_Name__c = 'Cloud Billing Contract'
             AND Pricing_Start_Date__c < TODAY 
             AND (Pricing_End_Date__c  >= YESTERDAY OR Pricing_End_Date__c = NULL)
            ];
         System.debug('Active PureCloud Contract Count ' + list_ActiveContracts.size());
        return list_ActiveContracts;
    }
    
    // Fetch all the approved Contracts with PureCloud type Opportunity with the today date range between Start date and End Date.
    private static List<GCR_Content_Document_Detail__c> getContracts(){
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: getContracts');
        System.debug('Today ' + Date.today());
        List<GCR_Content_Document_Detail__c> list_ActiveContracts = getActiveContracts();

        List<GCR_Content_Document_Detail__c> list_Contracts = new List<GCR_Content_Document_Detail__c>();
        for(GCR_Content_Document_Detail__c objContract : list_ActiveContracts){
            if(objContract.Pricing_Start_Date__c.day() == System.today().day()){
                System.debug('Today Contract :'+objContract);
                list_Contracts.add(objContract);
            } else {
                System.debug('NOT Today Contract :'+objContract);
            }
        }
        return list_Contracts;
    }
    private static Map<Id, GCR_Content_Document_Detail__c> getMapContractIdToContract(List<GCR_Content_Document_Detail__c> list_Contracts) {
        Map<Id, GCR_Content_Document_Detail__c> map_ContractIdToContract = new Map<Id, GCR_Content_Document_Detail__c>();
        Set<Id> set_contractIds = new Set<Id>();
        for (GCR_Content_Document_Detail__c objContract : list_Contracts) {
            map_ContractIdToContract.put(objContract.Id, objContract);
        }
        return map_ContractIdToContract;
    }
    private static Set<Id> getSetContractIds(List<GCR_Content_Document_Detail__c> list_Contracts) {
        Set<Id> set_contractIds = new Set<Id>();
        for (GCR_Content_Document_Detail__c objContract : list_Contracts) {
            set_contractIds.add(objContract.Id);
        }
        return set_contractIds;
    }
    private static Map<Id, Id> getMapCloudDeploymentToContract(List<Cloud_Deployment_To_Contract_Junction__c> list_CloudDeploymentContractJunct) {
        Map<Id, Id> map_CloudDeploymentToContract = new Map<Id, Id>();
        for (Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentContractJunct : list_CloudDeploymentContractJunct) {
            map_CloudDeploymentToContract.put(objCloudDeploymentContractJunct.Cloud_Deployment__c, objCloudDeploymentContractJunct.Contract__c);
        }
        return map_CloudDeploymentToContract;
    }
    private static List<Cloud_Deployment_To_Contract_Junction__c> getListCloudDeploymentContractJunctions(Set<Id> set_contractIds) {
        return [
            select Cloud_Deployment__c, Contract__c from Cloud_Deployment_To_Contract_Junction__c where Contract__c in :set_contractIds
        ];
    }
    
    // Fetch All the Cloud Deployments whith the associated Contracts.
    private static List<Cloud_Deployment__c> getCloudDeployments(List<GCR_Content_Document_Detail__c> list_Contracts){
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: getCloudDeployments');
        Set<Id> set_contractIds = new Set<Id>();
        for (GCR_Content_Document_Detail__c objContract : list_Contracts) {
            set_contractIds.add(objContract.Id);
        }
        List<Cloud_Deployment_To_Contract_Junction__c> list_CloudDeploymentContractJunct = getListCloudDeploymentContractJunctions(set_contractIds);
        
        Set<Id> set_cloudDeploymentIds = new Set<Id>();
        for (Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentContractJunct : list_CloudDeploymentContractJunct) {
            set_cloudDeploymentIds.add(objCloudDeploymentContractJunct.Cloud_Deployment__c);
        }
        System.debug('Searching for set of Cloud Deployments ' + set_cloudDeploymentIds);
        return [SELECT Id, PureCloud_OrgID__c 
                FROM Cloud_Deployment__c
                WHERE Id IN :set_cloudDeploymentIds];
    }
    
    // Erik With multiple cloud deployements create 1 Cloud_Billing_Report_Instance__c for each.	
    
    // Create Cloud Billing Report Instances for each Cloud Deployment.
    private static void createNewCloudBillingReportInstances(List<Cloud_Deployment__c> list_CloudDeployments){
        Date dtStartDt = Date.today().addMonths(-1);
        Date dtEndDt = Date.today().addDays(-1);
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: createNewCloudBillingReportInstances -> Start');
        List<Cloud_Billing_Report_Instance__c> list_CBReportInstances =  new List<Cloud_Billing_Report_Instance__c>();
        for(Cloud_Deployment__c objCDeployment : list_CloudDeployments){
            if (objCDeployment.PureCloud_OrgID__c != null) {
                Cloud_Billing_Report_Instance__c objCBRInstance = createNewReportInstance(objCDeployment.PureCloud_OrgID__c, dtStartDt, dtEndDt);
                objCBRInstance.RecordTypeID  		= CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID;
                objCBRInstance.Platform_Id_List__c  = objCDeployment.PureCloud_OrgID__c;
                list_CBReportInstances.add(objCBRInstance);
            } else {
                System.Debug('Cloud Deployment has null PureCloud_OrgID__c' + objCDeployment);
            }
        }
        
        System.debug('list_CBReportInstances -> '+list_CBReportInstances);
        System.debug('Inserting Start -> list_CBReportInstances');
        insert list_CBReportInstances;
        System.debug('Inserting End -> list_CBReportInstances');
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: createNewCloudBillingReportInstances -> End');
    }
    
    public static void addAllPureCloudLastMonth(Boolean blnInsert) {
        List<GCR_Content_Document_Detail__c> list_Contracts = getActiveContracts();
        Map<Id, GCR_Content_Document_Detail__c> map_ContractIdToContract = getMapContractIdToContract(list_Contracts);
        Set<Id> set_contractIds = getSetContractIds(list_Contracts);
        List<Cloud_Deployment__c> list_CloudDeployments = getCloudDeployments(list_Contracts);
        List<Cloud_Deployment_To_Contract_Junction__c> list_CloudDeploymentContractJunct = getListCloudDeploymentContractJunctions(set_contractIds);
        Map<Id, Id> map_CloudDeploymentToContract = getMapCloudDeploymentToContract(list_CloudDeploymentContractJunct);
        Date dtLastMonth = Date.today().addMonths(-1);
        Date dtTwoMonthsAgo = Date.today().addMonths(-2);
        
        System.debug('Class : CloudBillingPureCloudRRScheduler -> Method: createNewCloudBillingReportInstances -> Start');
        List<Cloud_Billing_Report_Instance__c> list_CBReportInstances =  new List<Cloud_Billing_Report_Instance__c>();
        for(Cloud_Deployment__c objCDeployment : list_CloudDeployments){
            if (objCDeployment.PureCloud_OrgID__c != null) {
                GCR_Content_Document_Detail__c objContract = map_ContractIdToContract.get(map_CloudDeploymentToContract.get(objCDeployment.Id));
                Date dtStartDt = Date.newInstance(dtLastMonth.year(), dtLastMonth.month(), objContract.Pricing_Start_Date__c.day());
                Date dtEndDt = dtStartDt.addMonths(1).addDays(-1);
                if (dtEndDt >= Date.today()) {
                    // Last month end is greater than today, so we need to go back 2 months.
                    dtStartDt = Date.newInstance(dtTwoMonthsAgo.year(), dtTwoMonthsAgo.month(), objContract.Pricing_Start_Date__c.day());
                    dtEndDt = dtStartDt.addMonths(1).addDays(-1);
                }
                Cloud_Billing_Report_Instance__c objCBRInstance = createNewReportInstance(objCDeployment.PureCloud_OrgID__c, dtStartDt, dtEndDt);
                list_CBReportInstances.add(objCBRInstance);
            } else {
                System.Debug('Cloud Deployment has null PureCloud_OrgID__c' + objCDeployment);
            }
        }
        
        System.debug('Inserting Start -> list_CBReportInstances');
        for (Cloud_Billing_Report_Instance__c objCBReportInstances : list_CBReportInstances) {
            System.Debug(objCBReportInstances);
        }
        if (blnInsert) insert list_CBReportInstances;
    }
    private static Cloud_Billing_Report_Instance__c createNewReportInstance(String strPureCloudOrgId, Date dtStartDt, Date dtEndDt) {
        Cloud_Billing_Report_Instance__c objCBRInstance = new Cloud_Billing_Report_Instance__c();
        objCBRInstance.Start_Time__c = dtStartDt;
        objCBRInstance.End_Time__c = dtEndDt;
        objCBRInstance.Status__c = 'Submitted';
        objCBRInstance.RecordTypeID = CLOUD_BILLING_REPORT_INSTANCE_RECORDTYPE_ID;
        objCBRInstance.Platform_Id_List__c  = strPureCloudOrgId;
        return objCBRInstance;
    }
}

/*                Cloud_Billing_Report_Instance__c objCBRInstance = new Cloud_Billing_Report_Instance__c();
                objCBRInstance.Status__c = 'Submitted';
                objCBRInstance.Start_Time__c = dtStartDt;
                objCBRInstance.End_Time__c = dtEndDt;
Date dtPricingStartDate = objCDeployment.Cloud_Billing_Contract__r.Pricing_Start_Date__c;
integer intDay = dtPricingStartDate.day();
integer intThisMonthDays = Date.daysInMonth(System.today().year(), System.today().month());
intDay = (intThisMonthDays < intDay) ? intThisMonthDays : intDay;

objCBRInstance.Start_Time__c 		= datetime.newInstanceGmt(System.today().year(),System.today().month(),intDay);

Time tmTime = Time.newInstance(00, 00, 00, 00);
objCBRInstance.End_Time__c 	 		= datetime.newInstanceGmt(objCBRInstance.Start_Time__c.date().addMonths(1).addDays(-1),
tmTime);
objCBRInstance.End_Time__c = (intThisMonthDays < intDay) ? objCBRInstance.End_Time__c.addDays(1) : objCBRInstance.End_Time__c;
/*
objCBRInstance.End_Time__c 	 		= datetime.newInstance(System.today().month() != 12? System.today().year() : System.today().year()+1,
System.today().month() != 12? System.today().month()+1 : 1,
dtPricingStartDate.day()-1);
*/


/*
for (GCR_Content_Document_Detail__c objContract : list_Contracts) {
System.debug('PureCloud Contract: ' + objContract);
set_contractIds.add(objContract.Id);
map_ContractIdToContract.put(objContract.Id, objContract);
}
List<Cloud_Deployment_To_Contract_Junction__c> list_CloudDeploymentContractJunct = [
select Cloud_Deployment__c, Contract__c from Cloud_Deployment_To_Contract_Junction__c where Contract__c in :set_contractIds
];
Set<Id> set_cloudDeploymentIds = new Set<Id>();
Map<Id, Id> map_CloudDeploymentToContract = new Map<Id, Id>();
for (Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentContractJunct : list_CloudDeploymentContractJunct) {
set_cloudDeploymentIds.add(objCloudDeploymentContractJunct.Cloud_Deployment__c);
map_CloudDeploymentToContract.put(objCloudDeploymentContractJunct.Cloud_Deployment__c, objCloudDeploymentContractJunct.Contract__c);
}
System.debug('Searching for set of Cloud Deployments ' + set_cloudDeploymentIds);
List<Cloud_Deployment__c> list_CloudDeployments = [SELECT Id, PureCloud_OrgID__c 
FROM Cloud_Deployment__c
WHERE Id IN :set_cloudDeploymentIds];
*/