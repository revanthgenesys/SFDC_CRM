@isTest
public class PartnerPortalOptyEditControllerTest {
    @isTest
    public static void testmethod1(){
Opportunity op = new Opportunity();
        op.Name='op1';
        op.StageName='Open';
        op.CloseDate=system.today()+5;
        insert op;
        Apexpages.StandardController sc = new Apexpages.standardController(op);
        
        PartnerPortalOptyEditController pc=new PartnerPortalOptyEditController(sc);
        pc.saveOpty();
        pc.cancelOpty();
        
    }
}