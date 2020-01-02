@isTest
public class BatchReRateUsageDataTest {
    @isTest
    static void testBatchReRateUsageDataNoJobLog(){
        List<Rolled_Up_Usage_Data__c> list_ruud = CloudBillingTestUtil.insertRuud();
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(list_ruud);
        Id acctId = objContract.Account_Name__c;
        CloudBillingTestUtil.insertServiceUsages(objContract);
        Date dtStart = date.newInstance(System.today().year(), System.today().month(),objContract.Pricing_Start_Date__c.day());
        Date dtEnd = dtStart.addDays(Date.daysInMonth(System.today().year(),System.today().month()));
        Test.startTest();
        BatchReRateUsageData objBatch = new BatchReRateUsageData(dtStart, dtEnd, acctId);
        //***when test class is executed the batch limit should be restricted*/
        Database.executeBatch(objBatch, 200);
        Test.stopTest();
    }
    @isTest
    static void testBatchReRateUsageData(){
        
        List<Rolled_Up_Usage_Data__c> list_ruud = CloudBillingTestUtil.insertRuud();
        System.debug('testContractCreationAndRating.list_ruud: ' + list_ruud);
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(list_ruud);

        if (list_ruud == null || list_ruud.size() == 0) {
            System.Assert(false, 'No RUUD Records');
            return;
        }
        Rolled_Up_Usage_Data__c objRUUD = list_ruud[0];
        System.Debug('objRUUD ' + objRUUD);
        objRUUD.Processed__c = true;
        update objRUUD;

        List<Contract_Tier_Set__c> listCTS = [select Id from Contract_Tier_Set__c limit 1];
        if (listCTS == null || listCTS.size() == 0) {
            System.Assert(false, 'No Contract Tier Set Records');
            return;
        }
        Contract_Tier_Set__c objCTS = listCTS[0];

        Contract_Tier_Set_Period__c objCTSP = new Contract_Tier_Set_Period__c(Contract_Tier_Set__c = objCTS.id);
        insert objCTSP;

        Contract_Tier_Set_Month__c objCTSM = new Contract_Tier_Set_Month__c(Contract_Tier_Set__c = objCTS.id,
                                                                            Contract_Tier_Set_Period__c = objCTSP.id);
        insert objCTSM;

        List<Service_Usage__c> listSU = CloudBillingTestUtil.insertServiceUsages(objContract);
        if (listSU == null || listSU.size() == 0) {
            System.assert(false, 'No Service USage');
            return;
        }
        List<Service_Usage_Tax__c> listServiceUsageTaxToInsert = new List<Service_Usage_Tax__c>();
        DateTime dtEarliest;
        DateTime dtLatest;
        for (Service_Usage__c objSU : listSU) {
            objSU.Rolled_Up_Usage_Data__c = objRUUD.id;
            DateTime dt = objRUUD.Start_Time__c;
            if (dtEarliest == null || dt < dtEarliest) dtEarliest = dt;
            if (dtLatest == null || dt > dtLatest) dtLatest = dt;
            objSU.Start_Time__c = objRUUD.Start_Time__c;
            objSU.Contract_Tier_Set_Month__c = objCTSM.id;
            Service_Usage_Tax__c objSuTax = new Service_Usage_Tax__c(Tax_Type_Code__c='100',
                                                                     Tax_Amount__c=.5,
                                                                     Service_Usage__c = objSU.Id);
            listServiceUsageTaxToInsert.add(objSuTax);
            Service_Usage_Tax__c objSuTax2 = new Service_Usage_Tax__c(Tax_Type_Code__c='110',
                                                                      Tax_Amount__c=.75,
                                                                      Rolled_Up_Usage_Data__c = objSU.Rolled_Up_Usage_Data__c,
                                                                      Service_Usage__c = objSU.Id);
            listServiceUsageTaxToInsert.add(objSuTax2);
        }
        update listSU;
        insert listServiceUsageTaxToInsert;
        
        List<Service_Usage__c> listSUcheck = [
            SELECT Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Account_Name__c, Start_Time__c
            FROM Service_Usage__c
        ];
        for (Service_Usage__c objSUcheck : listSUcheck) {
            System.debug('SU account ' + objSUcheck.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Account_Name__c);
            System.debug('SU start time ' + objSUcheck.Start_Time__c);
        }
        Cloud_Billing_Exception__c objCloudBillingException = new Cloud_Billing_Exception__c(Rolled_Up_Usage_Data__c = objRUUD.Id);
        insert objCloudBillingException;
        
        Date dtStart = dtEarliest.date().addDays(-1);
        Date dtEnd = dtLatest.date().addDays(1);
        
        Cloud_Billing_Log__c objLog = new Cloud_Billing_Log__c(Type__c = 'Re-Rate',Time__c = DateTime.now(), Status__c = 'Submitted',
                                                               Start_Date__c = dtStart,End_Date__c = dtEnd,Account__c = objContract.Account_Name__c);
        System.Debug('Job Log ' + objLog);        
        insert objLog;
        
        // Invoke batch Job to process Usage Data
        Test.startTest();
        BatchReRateUsageData objBatch = new BatchReRateUsageData(dtStart, dtEnd, objContract.Account_Name__c);
        objBatch.objJobLog = objLog;
        //***when test class is executed the batch limit should be restricted*/
        Database.executeBatch(objBatch, 200);
        Test.stopTest();
    }

}