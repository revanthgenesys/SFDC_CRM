public class DemoRequestRelatedItems {
	
    private Demo_Request__c demo;
    private Demo_Request_Tracking__c track;
    public Set<Id> plats { get; private set; }
    public Set<Id> gencons { get; private set; }
    public Set<Id> prods { get; private set; }
    public Set<Id> ints { get; private set; }
    public Set<Id> sols { get; private set; }
    
    public List<Demo_Request_Platform_Junction__c> origPlat { get; private set; }
    public List<Demo_Request_Gen_Concept_Junction__c> origGen { get; private set; }
    public List<Demo_Request_Product_Junction__c> origProd { get; private set; }
    public List<Demo_Request_Integration_Junction__c > origInt { get; private set; }
    public List<Demo_Request_Contact_Junction__c> origContact { get; private set; }
    public List<Demo_Request_Solution_Taxonomy_Junction__c > origSol { get; private set; }
    
    public List<Demo_Request_Tracking_Gen_Concept_Jnctn__c> origGenT { get; private set; }
    public List<Demo_Request_Tracking_Product_Junction__c> origProdT { get; private set; }
    public List<Demo_Request_Tracking_Integration_Jnctn__c> origIntT { get; private set; }
    
    public SelectOption[] platOptSel { get; set; }
    public SelectOption[] genOptSel { get; set; }
    public SelectOption[] prodOptSel { get; set; } 
    public SelectOption[] intOptSel { get; set; } 
    public SelectOption[] solOptSel { get; set; }
    public SelectOption[] prdSolOptSel { get; set; }
    
    public SelectOption[] platSel { get; set; } 
    public SelectOption[] genSel { get; set; } 
    public SelectOption[] prodSel { get; set; }
    public SelectOption[] intSel { get; set; }
    public SelectOption[] solSel { get; set; }
    public SelectOption[] prdSolSel { get; set; }
    
    public String platformsDisplay { get; set; } 
    public String genconDisplay { get; set; }
    public String prodDisplay { get; set; }
    public String intDisplay { get; set; }
    public String solDisplay { get; set; }
    
    public DemoRequestRelatedItems() {
        createSets();
        origPlat = new List<Demo_Request_Platform_Junction__c>();
        origGen = new List<Demo_Request_Gen_Concept_Junction__c>();
        origProd = new List<Demo_Request_Product_Junction__c>();
        origInt = new List<Demo_Request_Integration_Junction__c >();
        origContact = new List<Demo_Request_Contact_Junction__c>();
        origSol = new List<Demo_Request_Solution_Taxonomy_Junction__c>();
        origGenT = new List<Demo_Request_Tracking_Gen_Concept_Jnctn__c>();
        origProdT = new List<Demo_Request_Tracking_Product_Junction__c>();
        origIntT = new List<Demo_Request_Tracking_Integration_Jnctn__c >();
        buildPlatformOptions();
        buildSolutionOptions();
        buildTrackItems();
        system.debug('Built DemoRequestRelatedItems default');
    }
    
    public DemoRequestRelatedItems(Demo_Request__c demo) {
        this.demo = demo;
        createSets();
        createOrigDemo();
        buildPlatformOptions();
        buildSolutionOptions();
        buildDemoItems();
        system.debug('Built DemoRequestRelatedItems with demo: ' + demo.Id);
    }
    
    public DemoRequestRelatedItems(Demo_Request_Tracking__c track) {
        this.track = track;
        createSets();
        createOrigTrack();
        buildTrackItems();
        system.debug('Built DemoRequestRelatedItems Track: ' + track.Id);
    }
    
    public void setDemo(Demo_Request__c demo) {
        this.demo = demo;
    }
    
    public void setTrack(Demo_Request_Tracking__c track) {
        this.track = track;
    }
    
    private void createSets() {
        plats = new Set<Id>();
        gencons = new Set<Id>();
        prods = new Set<Id>();
        ints = new Set<Id>();
        sols = new Set<Id>();
        
        platOptSel = new List<SelectOption>();
        genOptSel = new List<SelectOption>();
        prodOptSel = new List<SelectOption>();
        intOptSel = new List<SelectOption>();
        solOptSel = new List<SelectOption>();
        prdSolOptSel = new List<SelectOption>();
        
        platSel = new List<SelectOption>();
        genSel = new List<SelectOption>();
        prodSel = new List<SelectOption>();
        intSel = new List<SelectOption>();
        solSel = new List<SelectOption>();
        prdSolSel = new List<SelectOption>();
        system.debug('initiated empty related item lists');
    }
    
    private void createOrigDemo() {
        origPlat = [Select Id, Platform__r.Name, Platform__r.Id from Demo_Request_Platform_Junction__c where Demo_Request__c = :demo.Id];
        system.debug('Loaded ' + origPlat.size() + ' platforms');
        for(Demo_Request_Platform_Junction__c i : origPlat) {
            plats.add(i.Platform__r.Id);
        }
        
        origGen = [Select Id, General_Concept__r.Name, General_Concept__r.Id from Demo_Request_Gen_Concept_Junction__c where Demo_Request__c = :demo.Id];
        system.debug('Loaded ' + origGen.size() + ' gencons');
        for(Demo_Request_Gen_Concept_Junction__c i : origGen) {
            gencons.add(i.General_Concept__r.Id);
        }
        
        origProd = [Select Id, Product__r.Name, Product__r.Id from Demo_Request_Product_Junction__c where Demo_Request__c = :demo.Id];
        system.debug('Loaded ' + origProd.size() + ' products');
        for(Demo_Request_Product_Junction__c i : origProd) {
            prods.add(i.Product__r.Id);
        }
        
        origInt = [Select Id, Integration_Solution__r.Name, Integration_Solution__r.Id from Demo_Request_Integration_Junction__c where Demo_Request__c = :demo.Id];
        system.debug('Loaded ' + origInt.size() + ' integrations');
        for(Demo_Request_Integration_Junction__c i : origInt) {
            ints.add(i.Integration_Solution__r.Id);
        }
        
        origSol = [Select Id, Solution_Taxonomy__r.Name, Solution_Taxonomy__r.Id from Demo_Request_Solution_Taxonomy_Junction__c where Demo_Request__c = :demo.Id];
        system.debug('Loaded ' + origInt.size() + ' integrations');
        for(Demo_Request_Solution_Taxonomy_Junction__c s : origSol) {
            sols.add(s.Solution_Taxonomy__r.Id);
        }  
    }
    
    private void createOrigTrack() {
        origGenT = [Select Id, General_Concept__r.Name, General_Concept__r.Id from Demo_Request_Tracking_Gen_Concept_Jnctn__c where  Demo_Request_Activity_Tracking__c = :track.Id];
        system.debug('Loaded ' + origGenT.size() + ' gencons');
        Set<Id> trim = new Set<Id>();
        for(Demo_Request_Tracking_Gen_Concept_Jnctn__c i : origGenT) {
            if(trim.contains(i.General_Concept__r.Id)) continue;
            gencons.add(i.General_Concept__r.Id);
            trim.add(i.General_Concept__r.Id);
        }
        
        origProdT = [Select Id, Product__r.Name, Product__r.Id from Demo_Request_Tracking_Product_Junction__c where  Demo_Request_Activity_Tracking__c = :track.Id];
        system.debug('Loaded ' + origProdT.size() + ' products');
        for(Demo_Request_Tracking_Product_Junction__c i : origProdT) {
            if(trim.contains(i.Product__r.Id)) continue;
            prods.add(i.Product__r.Id);
            trim.add(i.Product__r.Id);
        }
        
        origIntT = [Select Id, Integration_Solution__r.Name, Integration_Solution__r.Id from Demo_Request_Tracking_Integration_Jnctn__c where Demo_Request_Activity_Tracking__c = :track.Id];
        system.debug('Loaded ' + origIntT.size() + ' integrations');
        for(Demo_Request_Tracking_Integration_Jnctn__c i : origIntT) {
            if(trim.contains(i.Integration_Solution__r.Id)) continue;
            ints.add(i.Integration_Solution__r.Id);
            trim.add(i.Integration_Solution__r.Id);
        }
        
        Date activityDate = track.Activity_Date_Time__c.dateGMT();
        origContact = [SELECT Id, Training_Date__c, Contact__r.Name, Contact__c, Training_Attended__c, Contact_Type__c FROM Demo_Request_Contact_Junction__c WHERE Demo_Request__c = :track.Demo_Request__c AND Training_Date__c = :activityDate];
        system.debug('Loaded ' + origContact.size() + ' contacts');
    }
    
    public void saveCurrentSelected() {
        prods.clear();
        gencons.clear();    
        ints.clear();
        sols.clear();
        for(SelectOption s : genSel) gencons.add(s.getValue());
        for(SelectOption s : prodSel) prods.add(s.getValue());
        for(SelectOption s : prdSolSel) prods.add(s.getValue());
        for(SelectOption s : intSel) ints.add(s.getValue());
        for(SelectOption s : solSel) sols.add(s.getValue());
        system.debug('Saved Related Items Selected');
    }
    
    public void updatePlatform() {
        plats.clear();
        for(SelectOption o : platSel) {
            plats.add(o.getValue());
        }
        sols.clear();
        for(SelectOption o : solSel) {
            sols.add(o.getValue());
        }
		setPossibleItems();
        system.debug('set platform and possible related items');
    }
    
    public void setPossibleItems(){
        //if track, all related items, else is a demo and limit by platform
        List<General_Concept_Platform_Junction__c> g;
        List<Product_Platform_Junction__c> p;
        List<Platform_Integration_Junction__c> i;
        List<Solution_Taxonomy_Product_Junction__c> s;
        
        s = [Select Solution_Taxonomy__c, Product__c, Product_Name__c
             from Solution_Taxonomy_Product_Junction__c order by Solution_Taxonomy__r.Name];
        
        if(track != null) {
            g = [Select General_Concept_Name__c, General_Concept__c, Platform__c
                 from General_Concept_Platform_Junction__c order by General_Concept_Name__c];
            p = [Select Product__c, Product_Name__c, Platform__c
                 from Product_Platform_Junction__c where Demonstrable__c = true  order by Product_Name__c];
            i = [Select Integration_Name__c, Integration_Solution__c, Platform__c
                 from Platform_Integration_Junction__c where Demonstrable__c = true order by Integration_Name__c];
        } else {
            g = [Select General_Concept_Name__c, General_Concept__c, Platform__c
                 from General_Concept_Platform_Junction__c where Platform__c in :plats order by General_Concept_Name__c];
            p = [Select Product__c, Product_Name__c, Platform__c
                 from Product_Platform_Junction__c where Platform__c in :plats and Demonstrable__c = true  order by Product_Name__c];
            i = [Select Integration_Name__c, Integration_Solution__c, Platform__c
                 from Platform_Integration_Junction__c where Platform__c in :plats and Demonstrable__c = true order by Integration_Name__c];
        }
        
        setPossibleGeneralConcepts(g);
        setPossibleProducts(p, s);
        setPossibleIntegrations(i);
        platformsDisplay = DemoRequestUtility.stringify(platSel);
        solDisplay = DemoRequestUtility.stringify(solSel);
    }
    
    private void setPossibleGeneralConcepts(List<General_Concept_Platform_Junction__c> g) {
        genSel.clear();
        genOptSel.clear();
        Set<Id> trim = new Set<Id>();
        for(General_Concept_Platform_Junction__c j : g) {
            if(trim.contains(j.General_Concept__c)) continue;
            SelectOption opt = new SelectOption(j.General_Concept__c, j.General_Concept_Name__c);
            if(gencons.contains(j.General_Concept__c)) genSel.add(opt);
            else genOptSel.add(opt);
            trim.add(j.General_Concept__c);
        }
    }
    
    private void setPossibleProducts(List<Product_Platform_Junction__c> p, List<Solution_Taxonomy_Product_Junction__c> s) {
        Set<Id> trim = new Set<Id>();
        //set all products
        prodSel.clear();
        prodOptSel.clear();
        for(Product_Platform_Junction__c j : p) {
            if(trim.contains(j.Product__c)) continue;
            SelectOption opt = new SelectOption(j.Product__c, j.Product_Name__c);
            if(prods.contains(j.Product__c)) prodSel.add(opt);
            else prodOptSel.add(opt);
            trim.add(j.Product__c);
        }
        //set solution products list
        prdSolSel.clear();
        prdSolOptSel.clear();
        Set<Id> trim2 = new Set<Id>();
        for(Solution_Taxonomy_Product_Junction__c j : s) {
            //skip products not in the platform product list
            if(!trim.contains(j.Product__c)) continue;
            if(trim2.contains(j.Product__c)) continue;
            SelectOption opt = new SelectOption(j.Product__c, j.Product_Name__c);
            if(sols.contains(j.Solution_Taxonomy__c)) {
            	if(prods.contains(j.Product__c)) prdSolSel.add(opt);
            	else prdSolOptSel.add(opt);
            }
            trim2.add(j.Product__c);
        }
    }
    
    private void setPossibleIntegrations (List<Platform_Integration_Junction__c> i) {
        intSel.clear();
        intOptSel.clear();
        Set<Id> trim = new Set<Id>();
        for(Platform_Integration_Junction__c j : i) {
            if(trim.contains(j.Integration_Solution__c)) continue;
            SelectOption opt = new SelectOption(j.Integration_Solution__c, j.Integration_Name__c);
            if(ints.contains(j.Integration_Solution__c)) intSel.add(opt);
            else intOptSel.add(opt);
            trim.add(j.Integration_Solution__c);
        }
    }
    
    public void buildPlatformOptions() {
        platSel.clear();
        platOptSel.clear();
        for(Platform__c p : [Select Name, Id from Platform__c where Active__c = true]) {
            SelectOption opt = new SelectOption(p.Id, p.Name);
            if(plats.contains(p.Id)) platSel.add(opt);
            else platOptSel.add(opt);
        }
        platformsDisplay = DemoRequestUtility.stringify(platSel);
    }
    
    public void buildSolutionOptions() {
        solSel.clear();
        solOptSel.clear();
        for(Solution_Taxonomy__c s : [Select Name, Id from Solution_Taxonomy__c where Active__c = true]) {
            SelectOption opt = new SelectOption(s.Id, s.Name);
            if(sols.contains(s.Id)) solSel.add(opt);
            else solOptSel.add(opt);
        }
         solDisplay = DemoRequestUtility.stringify(solSel);
    }
    
    private void buildDemoItems() {
        genSel.clear();
        genOptSel.clear();
        for(General_Concept_Platform_Junction__c g : [Select Id, General_Concept__r.Name, General_Concept__c from General_Concept_Platform_Junction__c where Platform__c in :plats]) {
            SelectOption opt = new SelectOption(g.General_Concept__c, g.General_Concept__r.Name);
            if(gencons.contains(g.General_Concept__c)) genSel.add(opt);
            else genOptSel.add(opt);
        }
        prodSel.clear();
        prodOptSel.clear();
        for(Product_Platform_Junction__c p : [Select Product__c, Product__r.Name from Product_Platform_Junction__c where Demonstrable__c = true and Platform__c in :plats]) {
            SelectOption opt = new SelectOption(p.Product__c, p.Product__r.Name);
            if(prods.contains(p.Product__c)) prodSel.add(opt);
            else prodOptSel.add(opt);
        }
        intSel.clear();
        intOptSel.clear();
        for(Platform_Integration_Junction__c i : [Select Integration_Solution__c, Integration_Solution__r.Name from Platform_Integration_Junction__c where Demonstrable__c = true and Platform__c in :plats]) {
            SelectOption opt = new SelectOption(i.Integration_Solution__c, i.Integration_Solution__r.Name);
            if(ints.contains(i.Integration_Solution__c)) intSel.add(opt);
            else intOptSel.add(opt);
        }
    }
    
    private void buildTrackItems() {
        genSel.clear();
        genOptSel.clear();
        Set<Id> trim = new Set<Id>();
        for(General_Concept_Platform_Junction__c g : [Select Id, General_Concept__r.Name, General_Concept__c from General_Concept_Platform_Junction__c order by General_Concept__r.Name]) {
            if(trim.contains(g.General_Concept__c)) {
                continue;
            }
            trim.add(g.General_Concept__c);
            SelectOption opt = new SelectOption(g.General_Concept__c, g.General_Concept__r.Name);
            if(gencons.contains(g.General_Concept__c)) genSel.add(opt);
            else genOptSel.add(opt);
        }
        prodSel.clear();
        prodOptSel.clear();
        for(Product_Platform_Junction__c p : [Select Product__c, Product__r.Name from Product_Platform_Junction__c where Demonstrable__c = true order by Product__r.Name]) {
            if(trim.contains(p.Product__c)) {
                continue;
            }
            trim.add(p.Product__c);
            SelectOption opt = new SelectOption(p.Product__c, p.Product__r.Name);
            if(prods.contains(p.Product__c)) prodSel.add(opt);
            else prodOptSel.add(opt);
        }
        intSel.clear();
        intOptSel.clear();
        for(Platform_Integration_Junction__c i : [Select Integration_Solution__c, Integration_Solution__r.Name from Platform_Integration_Junction__c where Demonstrable__c = true order by Integration_Solution__r.Name]) {
            if(trim.contains(i.Integration_Solution__c)) {
                continue;
            }
            trim.add(i.Integration_Solution__c);
            SelectOption opt = new SelectOption(i.Integration_Solution__c, i.Integration_Solution__r.Name);
            if(ints.contains(i.Integration_Solution__c)) intSel.add(opt);
            else intOptSel.add(opt);
        }
    }
      
    public void updateDisplay() {
        platformsDisplay = DemoRequestUtility.stringify(platSel);
        genconDisplay = DemoRequestUtility.stringify(genSel);
        intDisplay = DemoRequestUtility.stringify(intSel);
        prodDisplay = DemoRequestUtility.stringify(prodSel);
        solDisplay = DemoRequestUtility.stringify(prdSolSel);
    }
    
    public void saveChanges() {
		if(track != null) saveTrackChanges();
        else saveDemoChanges();
    }
    
    public void saveContacts() {
        update origContact;
    }
    
    private void saveDemoChanges() {
        system.debug('saving demo changes');
        updateDemoPlats();
        updateDemoGens();
        updateDemoProds();
        updateDemoInts();
        updateDemoSols();
    }
    
    private void saveTrackChanges() {
        system.debug('saving track changes');
        updateTrackGens();
        updateTrackProds();
        updateTrackInts();
    }
    
    private void updateDemoPlats() {
        List<Demo_Request_Platform_Junction__c> removePlats = new List<Demo_Request_Platform_Junction__c>();
        Set<Id> origPlatSet = new Set<Id>();
        Set<Id> newPlatSet = new Set<Id>();
        List<Demo_Request_Platform_Junction__c> addPlats = new List<Demo_Request_Platform_Junction__c>();

        for(Demo_Request_Platform_Junction__c p : origPlat) {
            origPlatSet.add(p.Platform__c);
        }
        
        for(SelectOption s: platSel) {
            if(!origPlatSet.contains(s.getValue())) addPlats.add(createDemoPlatformJunc(s.getValue()));
            newPlatSet.add(s.getValue());
        }
        
        for(Demo_Request_Platform_Junction__c p : origPlat) {
            if(!newPlatSet.contains(p.Platform__c)) removePlats.add(p);
        }

        if(addPlats.size() > 0) insert addPlats;
        if(removePlats.size() > 0) delete removePlats;
    }
    
    private void updateDemoGens() {
        List<Demo_Request_Gen_Concept_Junction__c> removeGens = new List<Demo_Request_Gen_Concept_Junction__c>();
        Set<Id> origGenSet = new Set<Id>();
        Set<Id> newGenSet = new Set<Id>();
        List<Demo_Request_Gen_Concept_Junction__c> addGens = new List<Demo_Request_Gen_Concept_Junction__c>();

        for(Demo_Request_Gen_Concept_Junction__c p : origGen) {
            origGenSet.add(p.General_Concept__c);
        }
        
        for(SelectOption s: genSel) {
            if(!origGenSet.contains(s.getValue())) addGens.add(createDemoGenJunc(s.getValue()));
            newGenSet.add(s.getValue());
        }
        
        for(Demo_Request_Gen_Concept_Junction__c p : origGen) {
            if(!newGenSet.contains(p.General_Concept__c)) removeGens.add(p);
        }
        
        system.debug('origGens size: ' + origGen.size());
        system.debug('addGen size: ' + addGens.size());
        system.debug('removeGen size: ' + removeGens.size());
        
        if(addGens.size() > 0) {
            insert addGens;
            system.debug('inserted ' + addGens.size() + ' gens');
        } 
        if(removeGens.size() > 0){ 
            delete removeGens;
            system.debug('deleted ' + removeGens.size() + ' gens');
        }
    }
    
    private void updateDemoProds() {
        List<Demo_Request_Product_Junction__c> removeProds = new List<Demo_Request_Product_Junction__c>();
        Set<Id> origProdSet = new Set<Id>();
        Set<Id> newProdSet = new Set<Id>();
        List<Demo_Request_Product_Junction__c> addProds = new List<Demo_Request_Product_Junction__c>();

        for(Demo_Request_Product_Junction__c p : origProd) {
            origProdSet.add(p.Product__c);
        }
        
        for(SelectOption s: prodSel) {
            if(!origProdSet.contains(s.getValue())) addProds.add(createDemoProdJunc(s.getValue()));
            newProdSet.add(s.getValue());
        }
        
        for(SelectOption s: prdSolSel) {
            if(!origProdSet.contains(s.getValue())) addProds.add(createDemoProdJunc(s.getValue()));
            newProdSet.add(s.getValue());
        }
        
        for(Demo_Request_Product_Junction__c p : origProd) {
            if(!newProdSet.contains(p.Product__c)) removeProds.add(p);
        }
        
        system.debug('origProd size: ' + origProd.size());
        system.debug('addProds size: ' + addProds.size());
        system.debug('removeProds size: ' + removeProds.size());
        
        if(addProds.size() > 0) {
            insert addProds;
            system.debug('inserted ' + addProds.size() + ' prods');
        }
        if(removeProds.size() > 0) { 
            delete removeProds;
            system.debug('deleted ' + removeProds.size() + ' prods');
        }
    }
    
    private void updateDemoSols() {
        List<Demo_Request_Solution_Taxonomy_Junction__c> removeSols = new List<Demo_Request_Solution_Taxonomy_Junction__c>();
        Set<Id> origSolSet = new Set<Id>();
        Set<Id> newSolSet = new Set<Id>();
        List<Demo_Request_Solution_Taxonomy_Junction__c> addSols = new List<Demo_Request_Solution_Taxonomy_Junction__c>();

        for(Demo_Request_Solution_Taxonomy_Junction__c p : origSol) {
            origSolSet.add(p.Solution_Taxonomy__c);
        }
        
        for(SelectOption s: solSel) {
            if(!origSolSet.contains(s.getValue())) addSols.add(createDemoSolJunc(s.getValue()));
            newSolSet.add(s.getValue());
        }
        
        for(Demo_Request_Solution_Taxonomy_Junction__c p : origSol) {
            if(!newSolSet.contains(p.Solution_Taxonomy__c)) removeSols.add(p);
        }
        
        system.debug('origSol size: ' + origSol.size());
        system.debug('addSols size: ' + addSols.size());
        system.debug('removeSols size: ' + removeSols.size());
        
        if(addSols.size() > 0) {
            insert addSols;
            system.debug('inserted ' + addSols.size() + ' prods');
        }
        if(removeSols.size() > 0) { 
            delete removeSols;
            system.debug('deleted ' + removeSols.size() + ' prods');
        }
    }
    
    private void updateDemoInts() {
        List<Demo_Request_Integration_Junction__c> removeInts = new List<Demo_Request_Integration_Junction__c>();
        Set<Id> origIntSet = new Set<Id>();
        Set<Id> newIntSet = new Set<Id>();
        List<Demo_Request_Integration_Junction__c> addInts = new List<Demo_Request_Integration_Junction__c>();

        for(Demo_Request_Integration_Junction__c p : origInt) {
            origIntSet.add(p.Integration_Solution__c);
        }
        
        for(SelectOption s: intSel) {
            if(!origIntSet.contains(s.getValue())) addInts.add(createDemoIntJunc(s.getValue()));
            newIntSet.add(s.getValue());
        }
        
        for(Demo_Request_Integration_Junction__c p : origInt) {
            if(!newIntSet.contains(p.Integration_Solution__c)) removeInts.add(p);
        }
        
        system.debug('origInt size: ' + origInt.size());
        system.debug('addInts size: ' + addInts.size());
        system.debug('removeInts size: ' + removeInts.size());
        
        if(addInts.size() > 0){ 
            insert addInts;
            system.debug('inserted ' + addInts.size() + ' ints');
        }
        if(removeInts.size() > 0) {
            delete removeInts;
            system.debug('deleted ' + removeInts.size() + ' ints');
        }
    }    
    
    private Demo_Request_Platform_Junction__c createDemoPlatformJunc(Id i){
        Demo_Request_Platform_Junction__c plat = new Demo_Request_Platform_Junction__c();
        plat.Demo_Request__c = demo.Id;
        plat.Platform__c = i;
        return plat;
    }

    private Demo_Request_Gen_Concept_Junction__c createDemoGenJunc(Id i) {
        Demo_Request_Gen_Concept_Junction__c gen = new Demo_Request_Gen_Concept_Junction__c();
        gen.Demo_Request__c = demo.Id;
        gen.General_Concept__c = i;
        return gen;
    }
    
    private Demo_Request_Product_Junction__c createDemoProdJunc(Id i) {
        Demo_Request_Product_Junction__c prod = new Demo_Request_Product_Junction__c();
        prod.Demo_Request__c = demo.Id;
        prod.Product__c = i;
        return prod;
    }
    
    private Demo_Request_Solution_Taxonomy_Junction__c createDemoSolJunc(Id i) {
        Demo_Request_Solution_Taxonomy_Junction__c sol = new Demo_Request_Solution_Taxonomy_Junction__c();
        sol.Demo_Request__c = demo.Id;
        sol.Solution_Taxonomy__c = i;
        return sol;
    }
    
    private Demo_Request_Integration_Junction__c createDemoIntJunc(Id i) {
        Demo_Request_Integration_Junction__c prod = new Demo_Request_Integration_Junction__c();
        prod.Demo_Request__c = demo.Id;
        prod.Integration_Solution__c = i;
        return prod;
    }
    
    private void updateTrackGens() {
        List<Demo_Request_Tracking_Gen_Concept_Jnctn__c> removeGens = new List<Demo_Request_Tracking_Gen_Concept_Jnctn__c>();
        Set<Id> origGenSet = new Set<Id>();
        Set<Id> newGenSet = new Set<Id>();
        List<Demo_Request_Tracking_Gen_Concept_Jnctn__c> addGens = new List<Demo_Request_Tracking_Gen_Concept_Jnctn__c>();
		
        for(Demo_Request_Tracking_Gen_Concept_Jnctn__c p : origGenT) {
            origGenSet.add(p.General_Concept__c);
        }
        
        for(SelectOption s: genSel) {
            if(!origGenSet.contains(s.getValue())) addGens.add(createTrackGenJunc(s.getValue()));
            newGenSet.add(s.getValue());
        }
        system.debug('test');
        for(Demo_Request_Tracking_Gen_Concept_Jnctn__c p : origGenT) {
            if(!newGenSet.contains(p.General_Concept__c)) removeGens.add(p);
        }    
        
        system.debug('origGens size: ' + origGenT.size());
        system.debug('addGen size: ' + addGens.size());
        system.debug('removeGen size: ' + removeGens.size());

        if(addGens.size() > 0) {
            insert addGens;
            system.debug('inserting ' + addGens.size() + ' gencons');
        }
        if(removeGens.size() > 0){
            delete removeGens;
            system.debug('deleting ' + removeGens.size() + ' gencons');
        }
    }
    
    private void updateTrackProds() {
        List<Demo_Request_Tracking_Product_Junction__c> removeProds = new List<Demo_Request_Tracking_Product_Junction__c>();
        Set<Id> origProdSet = new Set<Id>();
        Set<Id> newProdSet = new Set<Id>();
        List<Demo_Request_Tracking_Product_Junction__c> addProds = new List<Demo_Request_Tracking_Product_Junction__c>();

        for(Demo_Request_Tracking_Product_Junction__c p : origProdT) {
            origProdSet.add(p.Product__c);
        }
        
        for(SelectOption s: prodSel) {
            if(!origProdSet.contains(s.getValue())) addProds.add(createTrackProdJunc(s.getValue()));
            newProdSet.add(s.getValue());
        }
        
        for(Demo_Request_Tracking_Product_Junction__c p : origProdT) {
            if(!newProdSet.contains(p.Product__c)) removeProds.add(p);
        }
        
        system.debug('origProd size: ' + origProdT.size());
        system.debug('addProds size: ' + addProds.size());
        system.debug('removeProds size: ' + removeProds.size());
        
        if(addProds.size() > 0) {
            insert addProds;
            system.debug('inserting ' + addProds.size() + ' prods');
        }
        if(removeProds.size() > 0){
            delete removeProds;
            system.debug('deleting ' + removeProds.size() + ' prods');
        }
    }
    
    private void updateTrackInts() {
        List<Demo_Request_Tracking_Integration_Jnctn__c> removeInts = new List<Demo_Request_Tracking_Integration_Jnctn__c>();
        Set<Id> origIntSet = new Set<Id>();
        Set<Id> newIntSet = new Set<Id>();
        List<Demo_Request_Tracking_Integration_Jnctn__c> addInts = new List<Demo_Request_Tracking_Integration_Jnctn__c>();

        for(Demo_Request_Tracking_Integration_Jnctn__c p : origIntT) {
            origIntSet.add(p.Integration_Solution__c);
        }
        
        for(SelectOption s: intSel) {
            if(!origIntSet.contains(s.getValue())) addInts.add(createTrackIntJunc(s.getValue()));
            newIntSet.add(s.getValue());
        }
        
        for(Demo_Request_Tracking_Integration_Jnctn__c p : origIntT) {
            if(!newIntSet.contains(p.Integration_Solution__c)) removeInts.add(p);
        }
        
        system.debug('origInt size: ' + origIntT.size());
        system.debug('addInts size: ' + addInts.size());
        system.debug('removeInts size: ' + removeInts.size());
        
        if(addInts.size() > 0) {
            insert addInts;
            system.debug('inserting ' + addInts.size() + ' ints');
        }
        if(removeInts.size() > 0){
            delete removeInts;
            system.debug('deleting ' + removeInts.size() + ' ints');
        }
    }    
    
    private Demo_Request_Tracking_Gen_Concept_Jnctn__c createTrackGenJunc(Id i) {
        Demo_Request_Tracking_Gen_Concept_Jnctn__c gencon = new Demo_Request_Tracking_Gen_Concept_Jnctn__c();
        gencon.Demo_Request_Activity_Tracking__c = track.Id;
        gencon.General_Concept__c = i;
        return gencon;
    }
    
    private Demo_Request_Tracking_Product_Junction__c createTrackProdJunc(Id i) {
        Demo_Request_Tracking_Product_Junction__c prod = new Demo_Request_Tracking_Product_Junction__c();
        prod.Demo_Request_Activity_Tracking__c = track.Id;
        prod.Product__c = i;
        return prod;
    }
    
    private Demo_Request_Tracking_Integration_Jnctn__c createTrackIntJunc(Id i) {
        Demo_Request_Tracking_Integration_Jnctn__c inte = new Demo_Request_Tracking_Integration_Jnctn__c();
        inte.Demo_Request_Activity_Tracking__c = track.Id;
        inte.Integration_Solution__c = i;
        return inte;
    }
    
    public Boolean checkItems() {
        return genSel.size() == 0 && prodSel.size() == 0 && intSel.size() == 0 && prdSolSel.size() == 0;
    }
    
    public Boolean checkPlatform() {
        return platSel.size() == 0;
    }
    
}