@isTest
public class TestDemoUpdateItems {
    
    @testSetup
    static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeData();
    }
    
    static testMethod void validateModifyRequest(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Get List of IDs to create a request for each
        List<Integration_Solution__c> integrations = [SELECT Id, Name FROM Integration_Solution__c];
        List<General_Concept__c> genCons = [SELECT Id, Name FROM General_Concept__c];
        List<Product__c> products = [SELECT Id, Name FROM Product__c];
        
		//Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(6, null);
        
        Test.startTest();
        //Attempt to add Products, Integrations, and General Concepts to each request.  System.Assert statements are in the method called
        TestDemoRequestClass.ModifyRequest(request, integrations, genCons, products);
        Test.stopTest();
    }

    static testMethod void updateDemoItemsAddNewItems() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
            
            Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);
            
            System.debug('Existing Items');
            System.debug(ext.drl.prodSel);
            System.debug(ext.drl.intSel);
            System.debug(ext.drl.genSel);
            
            Set<Id> products = new Set<Id>();
            Set<Id> integrations = new Set<Id>();
            Set<Id> gencons = new Set<Id>();
            
            for(SelectOption s: ext.drl.prodSel) products.add(s.getValue());
            for(SelectOption s: ext.drl.intSel) integrations.add(s.getValue());
            for(SelectOption s: ext.drl.genSel) gencons.add(s.getValue());
            
            //Pick new random items to add to demo
            SelectOption[] newProds = TestDemoRequestClass.randomSelections(ext.drl.prodOptSel);
            SelectOption[] newInts = TestDemoRequestClass.randomSelections(ext.drl.intOptSel);
            SelectOption[] newGens = TestDemoRequestClass.randomSelections(ext.drl.genOptSel);
            
            ext.drl.prodSel.addAll(newProds);
            ext.drl.intSel.addAll(newInts);
            ext.drl.genSel.addAll(newGens);
            ext.otherProducts = 'Other product here?';
            
            //click update items
            ext.submitItems();
            
            System.debug('New Items');
            System.debug(newProds);
            System.debug(newInts);
            System.debug(newGens);
            
            //collect Ids from all items

            for(SelectOption s: newProds) products.add(s.getValue());
            for(SelectOption s: newInts) integrations.add(s.getValue());
            for(SelectOption s: newGens) gencons.add(s.getValue());
            
            List<Demo_Request_Product_Junction__c> finalProducts = [Select Id, Product__r.Name, Product__c from Demo_Request_Product_Junction__c where Demo_Request__c = :demo.Id];
            List<Demo_Request_Gen_Concept_Junction__c> finalGenCons = [Select Id, General_Concept__r.Name, General_Concept__c from Demo_Request_Gen_Concept_Junction__c where Demo_Request__c = :demo.Id];
            List<Demo_Request_Integration_Junction__c> finalIntegrations = [Select Id, Integration_Solution__r.Name, Integration_Solution__c from Demo_Request_Integration_Junction__c where Demo_Request__c = :demo.Id];
            
            for(Demo_Request_Product_Junction__c p : finalProducts) {
                System.assert(products.contains(p.Product__c), 'Demo did not contain an added product: ' + p.Product__c + ' ' + p.Product__r.Name);
            }
            for(Demo_Request_Gen_Concept_Junction__c p : finalGenCons) {
                System.assert(gencons.contains(p.General_Concept__c), 'Demo did not contain an added gencon: ' + p.General_Concept__c + ' ' + p.General_Concept__r.Name);
            }
            for(Demo_Request_Integration_Junction__c p : finalIntegrations) {
                System.assert(integrations.contains(p.Integration_Solution__c), 'Demo did not contain an added integration: ' + p.Integration_Solution__c + ' ' + p.Integration_Solution__r.Name);
            }
        }
    }
    
    static testMethod void updateDemoItemsRemoveItems() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){

            Test.startTest();

            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                   	
			Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);
            
            system.debug('Product start Size: ' + ext.drl.origProd.size());
            system.debug('Gen Con start Size: ' + ext.drl.origGen.size());
            system.debug('Integration start Size: ' + ext.drl.origInt.size());

            //Pick new random items to remove from demo
            SelectOption[] newProds = TestDemoRequestClass.randomSelections(ext.drl.prodSel);
            SelectOption[] newInts = TestDemoRequestClass.randomSelections(ext.drl.intSel);
            SelectOption[] newGens = TestDemoRequestClass.randomSelections(ext.drl.genSel);

            system.debug('new Product size: ' + newProds.size() + ' old Product Size: ' + ext.drl.prodSel.size());
            system.debug('new Gen Con size: ' + newGens.size() + ' old Gen Con Size: ' + ext.drl.genSel.size());
            system.debug('new Integration size: ' + newInts.size() + ' old Integration Size: ' + ext.drl.intSel.size());
            
            //Set those to the lists
            ext.drl.prodSel.clear();
            ext.drl.prodSel.addAll(newProds);
            ext.drl.intSel.clear();
            ext.drl.intSel.addAll(newInts);
            ext.drl.genSel.clear();
            ext.drl.genSel.addAll(newGens);
            //click update items
            system.assert(!ext.drl.checkItems(), 'No items were selected');
            system.debug('Product save Size: ' + ext.drl.prodSel.size());
            system.debug('Gen Con save Size: ' + ext.drl.genSel.size());
            system.debug('Integration save Size: ' + ext.drl.intSel.size());
            
            ext.submitItems();
            
            //collect Ids from all items
            Set<Id> products = new Set<Id>();
            for(SelectOption s: ext.drl.prodSel) products.add(s.getValue());
            Set<Id> integrations = new Set<Id>();
            for(SelectOption s: ext.drl.intSel) integrations.add(s.getValue());
            Set<Id> gencons = new Set<Id>();
            for(SelectOption s: ext.drl.genSel) gencons.add(s.getValue());
            
            List<Demo_Request_Product_Junction__c> finalProducts = [Select Id, Product__c, Product__r.Name from Demo_Request_Product_Junction__c where Demo_Request__c = :demo.Id];
            List<Demo_Request_Gen_Concept_Junction__c> finalGenCons = [Select Id, General_Concept__c, General_Concept__r.Name from Demo_Request_Gen_Concept_Junction__c where Demo_Request__c = :demo.Id];
            List<Demo_Request_Integration_Junction__c> finalIntegrations = [Select Id, Integration_Solution__c, Integration_Solution__r.Name from Demo_Request_Integration_Junction__c where Demo_Request__c = :demo.Id];
           
            system.debug('Product ID Set size: ' + products.size() + ' Product Junction List Size: ' + finalProducts.size());
            system.debug('Gen Con ID Set size: ' + gencons.size() + ' Gen Con Junction List Size: ' + finalGenCons.size());
            system.debug('Integration ID Set size: ' + integrations.size() + ' Integration Junction List Size: ' + finalIntegrations.size());
            
            for(Demo_Request_Product_Junction__c p : finalProducts) {
                System.assert(products.contains(p.Product__c), 'Demo did not contain an item: ' + p.Product__c + ' ' + p.Product__r.Name);
            }
            for(Demo_Request_Gen_Concept_Junction__c p : finalGenCons) {
                System.assert(gencons.contains(p.General_Concept__c), 'Demo did not contain an item: ' + p.General_Concept__c + ' ' + p.General_Concept__r.Name);
            }
            for(Demo_Request_Integration_Junction__c p : finalIntegrations) {
                System.assert(integrations.contains(p.Integration_Solution__c), 'Demo did not contain an item: ' + p.Integration_Solution__c + ' ' + p.Integration_Solution__r.Name);
            }
            
            System.assertEquals(products.size(), finalProducts.size(), 'Inserted products is not equal');
            System.assertEquals(integrations.size(), finalIntegrations.size(), 'Inserted integrations is not equal');
            System.assertEquals(gencons.size(), finalGenCons.size(), 'Inserted gencons is not equal');
            

        }
    }
    
    static testMethod void updateDemoItemsAddPlatform() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){

            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                   	
			Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            
        	//Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);

            ext.resetPlatform();
            
            SelectOption[] newPlats = TestDemoRequestClass.randomSelections(ext.drl.platOptSel);
            newPlats.add(new SelectOption(ext.drl.platSel[0].getValue(),ext.drl.platSel[0].getLabel()));
            ext.drl.platSel = newPlats;
            ext.submitPlatform();
            ext.submitItems();
            
            List<Demo_Request_Platform_Junction__c> plats = [Select Platform__r.Name from Demo_Request_Platform_Junction__c where Demo_Request__c= :demo.Id];
            
            System.assertEquals(ext.drl.platSel.size(), plats.size(), 'Platform did not change');
        }
    }
    
    static testMethod void checkOnePlatformSelected() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){

            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                   	
			Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            
        	//Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);

            ext.resetPlatform();
            
            ext.drl.platSel.clear();
            ext.submitPlatform();

            System.assertNotEquals(0, ApexPages.getMessages().size(), 'Could submit with no selected platforms');
        }
    }
    
    static testMethod void checkOneItemSelected() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){

            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                   	
			Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            
        	//Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);

            ext.drl.prodSel.clear();
            ext.drl.intSel.clear();
            ext.drl.genSel.clear();
            
            ext.submitItems();

            System.assertNotEquals(0, ApexPages.getMessages().size(), 'Could submit with no selected items');
        }
    }
 
    static testMethod void checkCannotUpdateTradeshow() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
            DemoRequestSubmissionController extsub = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            extsub.drb.requestType = 'Tradeshow';
            Demo_Request__c demo = extsub.drb.build();
            
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestUpdateController ext = new DemoRequestUpdateController(stdRequest);

            System.assert(ext.showNA, 'Update Items was shown for a tradeshow =[');
        }
    }
    
}