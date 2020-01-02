@isTest(seealldata=true)
public class DDSCloudTest {
	
	@isTest
    static void testPCDDS() {

        BigMachines__Quote__c objQuote = TestDataFactoryForDDS.prepareDataPC();
        DDSCloud.DDSCloudModel objCloudModel = new DDSCloud.DDSCloudModel();
        objCloudModel=DDSCloud.calculateRawScore(objQuote);
        List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProducts = [SELECT Id,BigMachines__Product__r.Name,BigMachines__Product__r.Unit_of_Measure__c, BigMachines__Product__r.Taxonomy_Solution__c,
                                             Extended_Price_Per_Month__c, List_Price__c, BigMachines__Quantity__c,BigMachines__Product__r.ProductSubFamily__c,
                                             BigMachines__Product__r.APN_Number__c, BigMachines__Quote__r.Offering_Type__c,BigMachines__Product__r.Type__c,
                                             BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.Product_Specific_Discount__c,Total_Discount__c,BigMachines__Product__r.Product_Group__c,
                                             BigMachines__Product__r.Product_Sub_category__c, BigMachines__Product__r.Sub_Category__c,Partner_Price__c,Disc__c,Discount__c, BigMachines__Quote__r.No_Of_Months__c
                                             FROM BigMachines__Quote_Product__c
                                             WHERE BigMachines__Quote__c = :objQuote.Id AND Hide_Record__c = FALSE AND Is_Overage__c = FALSE];

        Decimal decFinalScore = DDSCloud.fetchThirdPartyandHardwareScore(objQuote,list_BigMachinesQuoteProducts);

    }

    @isTest

    static void testPCCDDS() {
        BigMachines__Quote__c objQuote = TestDataFactoryForDDS.prepareDataPCC();
        DDSCloud.DDSCloudModel objCloudModel = new DDSCloud.DDSCloudModel();
        objCloudModel=DDSCloud.calculateRawScore(objQuote);
    }

    @isTest
    static void testScoreImpact(){
        List<Decimal>impactScore = DDSCloud.calculateScoreImpact(50,50,50,50,'PureCloud');
        System.assertEquals(impactScore.size(),5);
        List<Decimal>impactScore2 = DDSCloud.calculateScoreImpact(50,50,50,50,'PureConnect Cloud');
        System.assertEquals(impactScore2.size(),5);
        List<Decimal>impactScore3 = DDSCloud.calculateScoreImpact(50,50,50,50,'PureEngage Cloud');
        System.assertEquals(impactScore3.size(),5);
        List<Decimal>impactScore4 = DDSCloud.calculateScoreImpact(0,0,0,0,'PureCloud');
        System.assertEquals(impactScore.size(),5);
        List<Decimal>impactScore5 = DDSCloud.calculateScoreImpact(0,0,0,0,'PureConnect Cloud');
        System.assertEquals(impactScore2.size(),5);
        List<Decimal>impactScore6 = DDSCloud.calculateScoreImpact(0,0,0,50,'PureEngage Cloud');
        System.assertEquals(impactScore3.size(),5);

    }

    @isTest
    static void testFetchRawScorePC(){
        DDSCloud.DDSCloudModel objCloudModel = new DDSCloud.DDSCloudModel();
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Direct',20,30000,5);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Direct',11,150000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Direct',11,250000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Direct',11,550000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Direct',11,2500000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Indirect',5,30000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Indirect',5,150000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Indirect',5,250000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Indirect',5,550000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureCloud','Indirect',11,2500000,10);
        DDSCloud.fetchRawScore('PureCloud',objCloudModel);
        
    }

    @isTest
    static void testFetchRawScorePCC(){
        DDSCloud.DDSCloudModel objCloudModel = new DDSCloud.DDSCloudModel();
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureConnect Cloud','Direct',20,30000,5);
        DDSCloud.fetchRawScore('PureConnect Cloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureConnect Cloud','Indirect',5,30000,10);
        DDSCloud.fetchRawScore('PureConnect Cloud',objCloudModel);
        objCloudModel = TestDataFactoryForDDS.fetchDDSCloud('PureConnect Cloud','Direct',5,3000000,10);
        DDSCloud.fetchRawScore('PureConnect Cloud',objCloudModel);
    }


}