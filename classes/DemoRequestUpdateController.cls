public class DemoRequestUpdateController {
    
    public Demo_Request__c req { get; private set; }
    public DemoRequestRelatedItems drl { get; set; }
    public Boolean showItem { get; set; }
    public Boolean showSubmit { get; set; }
    public Boolean showSelectPlatform { get; set; }
    public Boolean showItems { get; set; }
    public Boolean showNA { get; set; }
    
    public String otherProducts { get; set; }
    private String origOtherProds { get; set; }

    public DemoRequestUpdateController(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
            stdController.addFields(new List<String>{'Other_Applications__c', 'Org_URL__c', 'Request_Type__c'});
        req = (Demo_Request__c) stdController.getRecord();
        otherProducts = req.Other_Applications__c;
        origOtherProds = req.Other_Applications__c;
        if(req.Request_Type__c == 'Tradeshow') {
            showItem = false;
            showItems = false;
            showNA = true;
            return;
        }
        drl = new DemoRequestRelatedItems(req);
        showItem = true;
        showItems = true;
    }
    
    public void resetPlatform() {
        showSelectPlatform = true;
        showItems = false;
        drl.saveCurrentSelected();
    }
    
    public void submitPlatform() {
        if(drl.checkPlatform()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one platform'));
            return;
        }
        showSelectPlatform = false;
        showItems = true;
        drl.updatePlatform();
    }
    
    public PageReference submitItems() {
        if(drl.checkItems()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one item'));
            return null;
        }
        drl.saveChanges();
        system.debug('updated related items');
        if(origOtherProds != otherProducts) {
            if(otherProducts == null) otherProducts = '';
            req.Other_Applications__c = (otherProducts.length() > 255 ? otherProducts.left(255) : otherProducts);
            update req;
            system.debug('updated other applications');
        }
        showItem = false;
        return DemoRequestUtility.returnToDemo(req);
    }
    
}