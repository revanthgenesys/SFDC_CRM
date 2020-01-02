public class SmartFinderController {
    
    public SmartFinderController(){
    }

    
    public String getSmartURL(){
        List<DSRDataDefinition__c> dsrdata=[select header__C,URL__c from DSRDataDefinition__c where header__c='Smart Finder'];
        return dsrdata[0].URL__c;
        
    }
}