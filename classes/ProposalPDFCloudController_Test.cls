@isTest(SeeAllData = true)
private class ProposalPDFCloudController_Test 
{
    @isTest 
    static void testOutput() 
    {
        Util.Bypass_Trigger_Chk = true;
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c(Name = 'Test Quote1');
        objTestQuote.Offering_Type__c = 'Business Edition';
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        insert objTestQuote;
        
        BigMachines__Quote_Product__c objTestQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objTestQuote.Id,
                            BigMachines__Quantity__c = 1,BigMachines__Sales_Price__c = 100,Product_Group__c = 'Workforce Optimization');
        insert objTestQP;
        
        Test.setCurrentPage(new PageReference('/apex/ProposalPDFCloud?id=' + objTestQuote.Id));
        ProposalPDFCloudController objPDFCont = new ProposalPDFCloudController();
        
        objTestQuote.Offering_Type__c = 'Premier Edition';
        update objTestQuote;
        
        Test.setCurrentPage(new PageReference('/apex/ProposalPDFCloud?id=' + objTestQuote.Id));
        objPDFCont = new ProposalPDFCloudController();
        
    }
}