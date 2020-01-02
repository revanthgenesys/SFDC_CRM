@isTest(SeeAllData=false)
public class CloudBillingPureCloudRRSchedulerTest {

    @TestSetup
    static void setupData() {
        Util.Bypass_Trigger_Chk = true;
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.insertPureCloudContract();
        
        List<GCR_Content_Document_Detail__c> list_contracts = [
            select Id, Status__c, Product_Group__c, Document_Name__c, Pricing_Start_Date__c, Pricing_End_Date__c
            from GCR_Content_Document_Detail__c
        ];
        for (GCR_Content_Document_Detail__c objContractView : list_contracts) {
            System.debug('Test Contract ' + objContractView);
        }

        List<Cloud_Deployment_To_Contract_Junction__c> list_junctions = CloudBillingTestUtil.setupInsertCloudDeploymentsAndJunctions(objContract);
        for (Cloud_Deployment_To_Contract_Junction__c objJunction : list_junctions) {
            System.debug ('Junction ' + objJunction);
        }
    }

    @isTest
    public static void testRequestContractsToday() {
        // Find all of the PureCloud Contracts and set their start date to today minus a year. Should fire all of the records.
        List<GCR_Content_Document_Detail__c> list_Contracts = [
            select Id from GCR_Content_Document_Detail__c where Product_Group__c = 'PureCloud'
        ];
        for (GCR_Content_Document_Detail__c objContract : list_Contracts) {
            objContract.Pricing_Start_Date__c = Date.today().addYears(-1);
        }
        update list_Contracts;
        Test.startTest();
        CloudBillingPureCloudRRScheduler objSched = new CloudBillingPureCloudRRScheduler();
        //System.schedule('Schedule', '0 0 0 0 ?', objSched);
        CloudBillingPureCloudRRScheduler.runProcess();
        Test.stopTest();
    }

    @isTest
    public static void testRequestAllContractsLastMonth() {
        CloudBillingPureCloudRRScheduler.addAllPureCloudLastMonth(true);
    }
}