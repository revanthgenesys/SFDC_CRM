public class PartnerPortalOptyEditController {

    private opportunity opty = new opportunity();

    public PartnerPortalOptyEditController(ApexPages.StandardController controller) {
        opty = (Opportunity)controller.getRecord();
    }
    
    public pagereference saveOpty(){
        update opty;
        return new PageReference('/partner/apex/PartnerPortalOptyDetail?Id='+opty.Id);
    }
    
    public pagereference cancelOpty(){
        return new PageReference('/partner/apex/PartnerPortalOptyDetail?Id='+opty.Id);
    }
}