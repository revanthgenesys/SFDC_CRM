@isTest
private class Test_Survey_Response_Update_Lookups
{
    static testmethod void testSR()
    {    
        List<Case> lstCases = [select id,accountid,contactid from case WHERE accountid!=null and contactid!=null
                                order by createddate desc LIMIT 2];       
        if(lstCases.size()>0)
        {
            Survey_Response__c sr = new Survey_Response__c(case__c=lstCases[0].id);
            insert sr;
        }else
        {
            Account acc = TestCommon.createAccount(false);
            Contact cnt = TestCommon.createContact(acc.id);
            Case cas = new Case(status='open',subject='test',contactid=cnt.id,accountid=acc.id);
            cas.priority = '3-Medium';
            insert cas;
            Survey_Response__c sr = new Survey_Response__c(case__c=cas.id);
            insert sr;
        }
    }
    
}