public class DemoRequestWrapper {
    
    Public Demo_Request__c request { get; set; }
    Public List<String> platforms { get; set; }
    Public List<String> products { get; set; }
    Public List<String> genCons { get; set; }
    Public List<String> integrations { get; set; }
    Public Integer leftToDecline { get; set; }
    Public Boolean hasPlatforms { get; set; } {hasPlatforms = false;}
    Public Boolean hasProducts { get; set; } {hasProducts = false;}
    Public Boolean hasGenCons { get; set; } {hasGenCons = false;}
    Public Boolean hasIntegrations { get; set; } {hasIntegrations = false;}
    Public Boolean hasRelatedItems { get; set; } {hasRelatedItems = false;}
    
    Public Integer availableCount { get; set; }
    
    public DemoRequestWrapper(Demo_Request__c req, List<String> plats, List<String> prods, List<String> gcs, List<String> ints, Integer count){
        if(plats != null || prods != null || gcs != null || ints != null) hasRelatedItems = true;
        if(plats != null){
            platforms = plats;
            hasPlatforms = true;
        }
        if(prods != null){
            products = prods;
            hasProducts = true;
        }
        if(gcs != null){
            genCons = gcs;
            hasGenCons = true;
        }
        if(ints != null){
            integrations = ints;        
            hasIntegrations = true;
        }
        leftToDecline = count;
        request = req;
    }

}