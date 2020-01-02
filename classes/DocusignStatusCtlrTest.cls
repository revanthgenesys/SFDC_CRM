@isTest(seealldata=true)
private class DocusignStatusCtlrTest {

    private static testMethod void first() {
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Opportunity__c = testOpp.Id;
        ds.dsfs__Envelope_Status__c = 'Completed';
        insert ds;
        
        Attachment att = new Attachment();
        att.ParentID = ds.Id;
        att.Body = Blob.valueOf('Test');
        att.Name = 'Test';
        insert att;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
        DocusignStatusOppCtlr opp  = new DocusignStatusOppCtlr(sc);
        DocusignStatusCompCtlr.getDocusignStatusData(testOpp.Id);
    }
    
    private static testMethod void second() {
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        
        Order__c o = new Order__c();
        o.Maintenance_Start__c = Date.today();
        o.Maintenance_End__c = Date.today().addYears(1);
        o.Opportunity__c = testOpp.Id;
        o.Numb_of_Maint_Months__c = 12;
        insert o;
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Opportunity__c = testOpp.Id;
        ds.dsfs__Envelope_Status__c = 'Completed';
        insert ds;
        
        Attachment att = new Attachment();
        att.ParentID = ds.Id;
        att.Body = Blob.valueOf('Test');
        att.Name = 'Test';
        insert att;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        DocusignStatusOrderCtlr opp  = new DocusignStatusOrderCtlr(sc);
        
    }

}