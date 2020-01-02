@isTest
private class UpdatePCQuoteTotalsBatchOneTimeTest {

    @isTest(seealldata=true)
    static void withProdCategoryTest() {  
        Test.startTest();
            UpdatePCQuoteTotalsBatchOneTime obj = new UpdatePCQuoteTotalsBatchOneTime('New Subscription');
            DataBase.executeBatch(obj);            
        Test.stopTest();
    }
    
    @isTest(seealldata=true)
    static void withoutProdCategoryTest() {
        Id quoteId = Label.Quote_Id_For_Test_Class;
        Map<Id, Product2> map_toUpdateProds = new Map<Id, Product2>();
        List<zqu__QuoteRatePlanCharge__c> list_QtRtPlnChrges = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c
                                                                FROM zqu__QuoteRatePlanCharge__c 
                                                                WHERE zqu__QuoteRatePlan__r.zqu__quote__c = :quoteId];
        for(zqu__QuoteRatePlanCharge__c objQtRtPlnChrge : list_QtRtPlnChrges) {
            Product2 objProd = new Product2();
            objProd.Id = list_QtRtPlnChrges[0].zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c;
            objProd.Product_Category__c = '';
            map_toUpdateProds.put(objProd.Id, objProd);
        }
        update map_toUpdateProds.values();
        Test.startTest();
            UpdatePCQuoteTotalsBatchOneTime obj = new UpdatePCQuoteTotalsBatchOneTime('New Subscription');
            DataBase.executeBatch(obj);
        Test.stopTest();
    }
    /*
    @isTest(seealldata=true)
    static void amendTest() {  
        update new zqu__Quote__c(Id=Label.Quote_Id_For_Test_Class, zqu__SubscriptionType__c='Amend Subscription');
        Test.startTest();
            UpdatePCQuoteTotalsBatchOneTime obj = new UpdatePCQuoteTotalsBatchOneTime('Amend Subscription');
            DataBase.executeBatch(obj);            
        Test.stopTest();
    }
	*/
}