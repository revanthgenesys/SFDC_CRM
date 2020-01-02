//This Class is meant for Sandbox use only.  It should not be deployed in production
@isTest
public with sharing class DemoRequestFactory {
    
    private static final Map<String, Boolean> nameActiveMap = new Map<String, Boolean>{'CIC' => true, 'CaaS' => true, 'PureCloud' => true, 
        'CaaS Small Center' => true, 'Decisions' => true, 'Collector' => true, 'Purecloud Webinar' => false, 'CIC Webinar' => true};
    private static final Map<String, Boolean> nameProductDemonstrableMap = new Map<String, Boolean>{'.NET Client' => true, 'Administrator' => true, 
        'Agent' => true, 'Analyzer' => true, 'Architect' => true, 'Attendant' => true, 'Business User' => true, 'Collaborate' => true, 
        'Communicate' => true, 'Designer' => true, 'Dialer' => true, 'Engage' => true, 'Feedback' => true, 'ICBM (Overview)' => true, 
        'Iconference' => true, 'IPA' => true, 'iPad Supervisor' => true, 'IWP' => true, 'Marquee' => true, 'Mobile Collaborate' => true, 
        'Mobile Documents' => true, 'Mobile Office' => true, 'Mobile Web Client' => true, 'Mobilizer' => false, 'MyCloud' => true, 'Optimizer' => true, 
        'Recorder' => true, 'Report Assistant' => true, 'Scheduled Reports' => true, 'Scripter' => true, 'Social Customer Service' => true, 
        'Supervisor' => true, 'Tracker' => true, 'Web Client' => true, 'Interaction Desktop' => true, 'Interaction Connect' => true};
    private static final Map<String, Boolean> nameIntegrationDemonstrableMap = new Map<String, Boolean>{'Salesforce' => true, 
        'InteractionSync' => false, 'Lync' => true, 'Oracle Service Cloud' => true, 'SAP' => true, 'Siebel' => true, 'CallScripter' => true};
    private static final List<String> genConNames = new List<String>{'ACD', 'CIC Overview', 'Collaboration', 'Contact Center', 
        'Content Management', 'Enterprise Telephony', 'IVR', 'MMQ', 'Outbound Dialing', 'Process Automation', 'Quality Assurance', 
        'Reporting', 'Response Management', 'Social Media', 'Speech Analytics', 'Speech Reco/TTS', 'Unified Communications', 
        'Video', 'Workforce Management', 'Workforce Optimization'};
    private static final List<String> competitorNames = new List<String>{'Cisco', 'Avaya', 'Genesys','InContact'};
    public static final List<String> requestTimeZone = new List<String>{'Australia/Sydney','Asia/Kuala_Lumpur','Europe/London','GMT','America/Puerto_Rico','America/New_York','America/Chicago','America/Phoenix','America/Los_Angeles','America/Tijuana','America/Anchorage','Pacific/Honolulu','Pacific/Kiritimati','Pacific/Chatham','Pacific/Auckland','Pacific/Enderbury','Pacific/Fiji','Pacific/Tongatapu','Asia/Kamchatka','Pacific/Norfolk','Australia/Lord_Howe','Pacific/Guadalcanal','Australia/Adelaide','Australia/Darwin','Asia/Seoul','Asia/Tokyo','Asia/Hong_Kong','Asia/Manila','Asia/Shanghai','Asia/Singapore','Asia/Taipei','Australia/Perth','Asia/Bangkok','Asia/Ho_Chi_Minh','Asia/Jakarta','Asia/Rangoon','Asia/Dhaka','Asia/Yekaterinburg','Asia/Kathmandu','Asia/Colombo','Asia/Kolkata','Asia/Karachi','Asia/Tashkent','Asia/Kabul','Asia/Dubai','Asia/Tbilisi','Europe/Moscow','Asia/Tehran','Africa/Nairobi','Asia/Baghdad','Asia/Kuwait','Asia/Riyadh','Europe/Minsk','Africa/Cairo','Africa/Johannesburg','Asia/Jerusalem','Europe/Athens','Europe/Bucharest','Europe/Helsinki','Europe/Istanbul','Africa/Algiers','Europe/Amsterdam','Europe/Berlin','Europe/Brussels','Europe/Paris','Europe/Prague','Europe/Rome','Europe/Dublin','Europe/Lisbon'};    

    private static void InitData() {
        List<Platform__c> platforms = CreatePlatformData();        
        List<Product__c> products = CreateProductData();        
        List<General_Concept__c> genCons = CreateGenConData();        
        List<Integration_Solution__c> integrations = CreateIntegrationData();
        CreateJunctions(platforms, products, genCons, integrations);
        CreateCompetitorData();
        CreateChatterGroup();   
    }
        
    public static void InitializeData(){
        InitData();
        CreateCustomSettings();
    }
    
    public static void InitializeDataWithSeeAllData() {
        InitData();
    }
    
    static private void CreateCustomSettings() {
        List<DemoProcessConfig__c> settings = new List<DemoProcessConfig__c>{
            new DemoProcessConfig__c(Name='DeclineBuffer',Number__c=14.0),
            new DemoProcessConfig__c(Name='TechnicalSalesDistro',String__c='technicalsales@inin.com'),
            new DemoProcessConfig__c(Name='VelocitySalesDistro',String__c='velocitysales@inin.com')
                };
        insert settings;
    }
    
    static private List<Platform__c> CreatePlatformData(){
        List<Platform__c> platforms = new List<Platform__c>();
        for(String name : nameActiveMap.keySet()){
            Platform__c platform = new Platform__c();
            platform.Name = name;
            platform.Active__c = nameActiveMap.get(name);
            platforms.add(platform);
        }
        insert platforms;
        return platforms;
    }
    
    static private List<Product__c> CreateProductData(){
        List<Product__c> products = new List<Product__c>();
        for(String name : nameProductDemonstrableMap.keySet()){
            Product__c product = new Product__c();
            product.Name = name;
            product.Demonstrable__c = nameProductDemonstrableMap.get(name);
            product.Sellable__c = true;
            products.add(product);
        }
        insert products;
        return products;
    }
    
    static private List<General_Concept__c> CreateGenConData(){
        List<General_Concept__c> generalConcepts = new List<General_Concept__c>();
        for(String name : genConNames){
            General_Concept__c genCon = new General_Concept__c();
            genCon.Name = name;
            generalConcepts.add(genCon);
        }
        insert generalConcepts;
        return generalConcepts;
    }
    
    static private List<Integration_Solution__c> CreateIntegrationData(){
        List<Integration_Solution__c> integrations = new List<Integration_Solution__c>();
        for(String name : nameIntegrationDemonstrableMap.keySet()){
            Integration_Solution__c integration = new Integration_Solution__c();
            integration.Name = name;
            integration.Demonstrable__c = nameIntegrationDemonstrableMap.get(name);
            integrations.add(integration);
        }
        insert integrations;
        return integrations;
    }
    
    static private void CreateCompetitorData(){
        List<Competition__c> competitors = new List<Competition__c>();
        for(String name : competitorNames){
            Competition__c comp = new Competition__c();
            comp.Name = name;
            competitors.add(comp);
        }
        insert competitors;
    }

    static public void CreateDemonstrationPresenters(List<User> allTscon, List<User> allMgm) {
        List<Demonstration_Presenter__c> presenters = new List<Demonstration_Presenter__c>();
        for(User i : allTscon) {
            Demonstration_Presenter__c d = new Demonstration_Presenter__c();
            d.User_Name__c = i.Id;
            d.Presenter_Signature__c = 'We are the best team';
            d.isTS__c = true;
            d.isTSC__c = true;
            d.QueueName__c = 'Technical Sales';
            presenters.add(d);
            System.debug('##### Added Demostration Presenter TSC: ' + d.User_Name__c);
        }
        
        for(User i : allMgm) {
            Demonstration_Presenter__c d = new Demonstration_Presenter__c();
            d.User_Name__c = i.Id;
            d.Presenter_Signature__c = 'We are the best team';
            d.isTS__c = true;
            d.isTSC__c = true;
            d.isTSM__c = true;
            d.QueueName__c = 'Technical Sales';
            presenters.add(d);
            System.debug('##### Added Demostration Presenter TSM: ' + d.User_Name__c);
        }
        
        insert presenters;
    }
    
    static public void CreateDemonstrationPresenters(List<User> allTscon, List<User> allMgm, String queue) {
        List<Demonstration_Presenter__c> presenters = new List<Demonstration_Presenter__c>();
        for(User i : allTscon) {
            Demonstration_Presenter__c d = new Demonstration_Presenter__c();
            d.User_Name__c = i.Id;
            d.Presenter_Signature__c = 'We are the best team';
            d.isTS__c = true;
            d.isTSC__c = true;
            d.QueueName__c = queue;
            presenters.add(d);
            System.debug('##### Added Demostration Presenter TSC: ' + d.User_Name__c);
        }
        
        for(User i : allMgm) {
            Demonstration_Presenter__c d = new Demonstration_Presenter__c();
            d.User_Name__c = i.Id;
            d.Presenter_Signature__c = 'We are the best team';
            d.isTS__c = true;
            d.isTSC__c = true;
            d.isTSM__c = true;
            d.QueueName__c = queue;
            presenters.add(d);
            System.debug('##### Added Demostration Presenter TSM: ' + d.User_Name__c);
        }
        
        insert presenters;
    }
    
    static public List<User> CreateTscTestUsers(Integer numUsers){
        List<User> users = new List<User>();
        UserRole tscRole = [SELECT Id FROM UserRole WHERE Name = 'Tech Sales Consultants'];
        for(Integer i = 0; i < numUsers; i++){
            User testUser = UserFactory.CreateInternalUser('TestTscUser' + String.valueOf(i)); 
            testUser.FirstName = 'TSC' + String.valueOf(i);
            testUser.UserRoleId = tscRole.Id;
            users.add(testUser);
            System.debug('##### Added TSC Test user: ' + testUser.Email);
        }
        
        insert users;
        AssignTscPermissionSet(users);
        return users;
    }
    
    static public List<User> CreateTsmTestUsers(Integer numUsers){
        List<User> users = new List<User>();
        UserRole tsmRole = [SELECT Id FROM UserRole WHERE Name = 'Tech Sales Team Lead'];
        for(Integer i = 0; i < numUsers; i++){
            User testUser = UserFactory.CreateInternalUser('TestTsmUser' + String.valueOf(i));
            testUser.FirstName = 'TSM' + String.valueOf(i);
            testUser.UserRoleId = tsmRole.Id;
            users.add(testUser);
            System.debug('##### Added TSM Test user: ' + testUser.Email);
        }
        
        insert users;
        AssignTscPermissionSet(users);
        AssignTsmPermissionSet(users);
        return users;
    }
    
    static private void AssignTscPermissionSet(List<User> users){
        PermissionSet psTs = [SELECT Id FROM PermissionSet WHERE Name = 'DemoRequestAccessTS'];
        List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();
        for(User u : users){
            PermissionSetAssignment psa = new PermissionSetAssignment(
                PermissionSetId = psTs.Id,
                AssigneeId = u.Id);
            permissions.add(psa);
            System.debug('##### Added DemoRequestAccessTS permission set to user: ' + u.FirstName);
        }
        
        insert permissions;
    }
    
    static private void AssignTsmPermissionSet(List<User> users){
        PermissionSet psTs = [SELECT Id FROM PermissionSet WHERE Name = 'DemoRequestAccessAdmin'];
        List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();
        for(User u : users){
            PermissionSetAssignment psa = new PermissionSetAssignment(
                PermissionSetId = psTs.Id,
                AssigneeId = u.Id);
            permissions.add(psa);
            System.debug('##### Added DemoRequestAccessAdmin permission set to user: ' + u.FirstName);
        }
        
        insert permissions;
    }
    
    //may not be needed
    static private void CreateChatterGroup() {
        List<CollaborationGroup> groups = [Select Name from CollaborationGroup where Name ='TS Test Group'];
        if(groups.size() > 0) return;
        try{
            insert new CollaborationGroup(Name='TS Test Group',CollaborationType='Public');
        } catch(Exception e){ system.debug(e.getMessage()); }
    }
    
    static private void CreateJunctions(List<Platform__c> platforms, List<Product__c> products, List<General_Concept__c> genCons, List<Integration_Solution__c> integrations){

        List<Product_Platform_Junction__c> productPlatformJunction = new List<Product_Platform_Junction__c>();
        List<General_Concept_Platform_Junction__c> genConPlatformJunction = new List<General_Concept_Platform_Junction__c>();
        List<Platform_Integration_Junction__c> intPlatformJunction = new List<Platform_Integration_Junction__c>();
        
        //Create Name and Id Maps
        Map<String, Id> productIdMap = new Map<String, Id>();
        Map<String, Id> genConIdMap = new Map<String, Id>();
        Map<String, Id> integrationIdMap = new Map<String, Id>();
        
        for(Product__c product : products){
            productIdMap.put(product.Name, product.Id);
        }
        
        for(General_Concept__c genCon : genCons){
            genConIdMap.put(genCon.Name, genCon.Id);
        }
        
        for(Integration_Solution__c integration : integrations){
            integrationIdMap.put(integration.Name, integration.Id);
        }
        
        //Populate all Products, Integrations, and General Concepts Ids by Platform Id in Maps
        for(Platform__c platform : platforms){
            if(platform.Name == 'CIC'){
                List<Id> productPlatform = new List<Id>{productIdMap.get('.NET Client'), productIdMap.get('Administrator'), productIdMap.get('Analyzer'), productIdMap.get('Designer'), productIdMap.get('ICBM (Overview)'), productIdMap.get('Tracker'), productIdMap.get('Mobilizer'), productIdMap.get('Web Client'), productIdMap.get('Feedback'), productIdMap.get('IPA'), productIdMap.get('Scheduled Reports'), productIdMap.get('Iconference'), productIdMap.get('Marquee'), productIdMap.get('Scripter'), productIdMap.get('Optimizer'), productIdMap.get('Recorder'), productIdMap.get('Supervisor'), productIdMap.get('Mobile Office'), productIdMap.get('Report Assistant'), productIdMap.get('Mobile Web Client'), productIdMap.get('Dialer'), productIdMap.get('Attendant'), productIdMap.get('IWP'), productIdMap.get('iPad Supervisor'), productIdMap.get('Interaction Desktop'), productIdMap.get('Interaction Connect')};
                    for(Id i : productPlatform){
                        Product_Platform_Junction__c pPj = new Product_Platform_Junction__c();
                        pPj.Platform__c = platform.Id;
                        pPj.Product__c = i;
                        productPlatformJunction.add(pPj);
                    }                    
                List<Id> integrationPlatform = new List<Id>{integrationIdMap.get('CallScripter'), integrationIdMap.get('InteractionSync'), integrationIdMap.get('Lync'), integrationIdMap.get('Oracle Service Cloud'), integrationIdMap.get('Salesforce'), integrationIdMap.get('SAP'), integrationIdMap.get('Siebel')};
                    for(Id i : integrationPlatform){
                        Platform_Integration_Junction__c iPj = new Platform_Integration_Junction__c();
                        iPj.Platform__c = platform.Id;
                        iPj.Integration_Solution__c = i;
                        intPlatformJunction.add(iPj);
                    }                
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('ACD'), genConIdMap.get('CIC Overview'), genConIdMap.get('Contact Center'), genConIdMap.get('Enterprise Telephony'), genConIdMap.get('IVR'), genConIdMap.get('MMQ'), genConIdMap.get('Outbound Dialing'), genConIdMap.get('Process Automation'), genConIdMap.get('Quality Assurance'), genConIdMap.get('Reporting'), genConIdMap.get('Response Management'), genConIdMap.get('Social Media'), genConIdMap.get('Speech Analytics'), genConIdMap.get('Speech Reco/TTS'), genConIdMap.get('Unified Communications'), genConIdMap.get('Video'), genConIdMap.get('Workforce Management'), genConIdMap.get('Workforce Optimization')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            } else if(platform.Name == 'CaaS'){
                List<Id> productPlatform = new List<Id>{productIdMap.get('.NET Client'), productIdMap.get('Administrator'), productIdMap.get('Analyzer'), productIdMap.get('Attendant'), productIdMap.get('Designer'), productIdMap.get('Dialer'), productIdMap.get('Feedback'), productIdMap.get('ICBM (Overview)'), productIdMap.get('Iconference'), productIdMap.get('IPA'), productIdMap.get('IWP'), productIdMap.get('Marquee'), productIdMap.get('Mobile Office'), productIdMap.get('Mobile Web Client'), productIdMap.get('MyCloud'), productIdMap.get('Optimizer'), productIdMap.get('Recorder'), productIdMap.get('Report Assistant'), productIdMap.get('Scheduled Reports'), productIdMap.get('Scripter'), productIdMap.get('Supervisor'), productIdMap.get('Tracker'), productIdMap.get('Web Client'), productIdMap.get('Interaction Desktop'), productIdMap.get('Interaction Connect')};
                    for(Id i : productPlatform){
                        Product_Platform_Junction__c pPj = new Product_Platform_Junction__c();
                        pPj.Platform__c = platform.Id;
                        pPj.Product__c = i;
                        productPlatformJunction.add(pPj);
                    }
                List<Id> integrationPlatform = new List<Id>{integrationIdMap.get('CallScripter'), integrationIdMap.get('Lync'), integrationIdMap.get('Oracle Service Cloud'), integrationIdMap.get('Salesforce'), integrationIdMap.get('SAP'), integrationIdMap.get('Siebel')};
                    for(Id i : integrationPlatform){
                        Platform_Integration_Junction__c iPj = new Platform_Integration_Junction__c();
                        iPj.Platform__c = platform.Id;
                        iPj.Integration_Solution__c = i;
                        intPlatformJunction.add(iPj);
                    }
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('ACD'), genConIdMap.get('CIC Overview'), genConIdMap.get('Contact Center'), genConIdMap.get('Enterprise Telephony'), genConIdMap.get('IVR'), genConIdMap.get('MMQ'), genConIdMap.get('Outbound Dialing'), genConIdMap.get('Process Automation'), genConIdMap.get('Quality Assurance'), genConIdMap.get('Reporting'), genConIdMap.get('Response Management'), genConIdMap.get('Social Media'), genConIdMap.get('Speech Analytics'), genConIdMap.get('Speech Reco/TTS'), genConIdMap.get('Unified Communications'), genConIdMap.get('Workforce Management'), genConIdMap.get('Workforce Optimization')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            } else if(platform.Name == 'Collector'){
                List<Id> productPlatform = new List<Id>{productIdMap.get('.NET Client'), productIdMap.get('Dialer')};
                    for(Id i : productPlatform){
                        Product_Platform_Junction__c pPj = new Product_Platform_Junction__c();
                        pPj.Platform__c = platform.Id;
                        pPj.Product__c = i;
                        productPlatformJunction.add(pPj);
                    }
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('Reporting')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            } else if(platform.Name == 'Decisions'){
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('Reporting'), genConIdMap.get('Workforce Management'), genConIdMap.get('Workforce Optimization')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            } else if(platform.Name == 'Caas Small Center'){
                List<Id> productPlatform = new List<Id>{productIdMap.get('Analyzer'), productIdMap.get('Feedback'), productIdMap.get('ICBM (Overview)'), productIdMap.get('MyCloud'), productIdMap.get('Recorder'), productIdMap.get('Report Assistant'), productIdMap.get('Scheduled Reports'), productIdMap.get('Supervisor'), productIdMap.get('Web Client'), productIdMap.get('Interaction Connect')};
                    for(Id i : productPlatform){
                        Product_Platform_Junction__c pPj = new Product_Platform_Junction__c();
                        pPj.Platform__c = platform.Id;
                        pPj.Product__c = i;
                        productPlatformJunction.add(pPj);
                    }
                List<Id> integrationPlatform = new List<Id>{integrationIdMap.get('Salesforce')};
                    for(Id i : integrationPlatform){
                        Platform_Integration_Junction__c iPj = new Platform_Integration_Junction__c();
                        iPj.Platform__c = platform.Id;
                        iPj.Integration_Solution__c = i;
                        intPlatformJunction.add(iPj);
                    }
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('ACD'), genConIdMap.get('CIC Overview'), genConIdMap.get('Contact Center'), genConIdMap.get('Enterprise Telephony'), genConIdMap.get('IVR'), genConIdMap.get('MMQ'), genConIdMap.get('Quality Assurance'), genConIdMap.get('Reporting'), genConIdMap.get('Speech Analytics'), genConIdMap.get('Speech Reco/TTS'), genConIdMap.get('Unified Communications')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            } else if(platform.Name == 'PureCloud'){
                List<Id> productPlatform = new List<Id>{productIdMap.get('Administrator'), productIdMap.get('Agent'), productIdMap.get('Architect'), productIdMap.get('Business User'), productIdMap.get('Collaborate'), productIdMap.get('Communicate'), productIdMap.get('Engage'), productIdMap.get('iPad Supervisor'), productIdMap.get('Mobile Collaborate'), productIdMap.get('Mobile Documents'), productIdMap.get('Social Customer Service'), productIdMap.get('Supervisor')};
                    for(Id i : productPlatform){
                        Product_Platform_Junction__c pPj = new Product_Platform_Junction__c();
                        pPj.Platform__c = platform.Id;
                        pPj.Product__c = i;
                        productPlatformJunction.add(pPj);
                    }
                List<Id> genConPlatform = new List<Id>{genConIdMap.get('ACD'), genConIdMap.get('Collaboration'), genConIdMap.get('Contact Center'), genConIdMap.get('Content Management'), genConIdMap.get('Enterprise Telephony'), genConIdMap.get('IVR'), genConIdMap.get('MMQ'), genConIdMap.get('Outbound Dialing'), genConIdMap.get('Process Automation'), genConIdMap.get('Quality Assurance'), genConIdMap.get('Reporting'), genConIdMap.get('Speech Reco/TTS'), genConIdMap.get('Unified Communications'), genConIdMap.get('Video')};
                    for(Id i : genConPlatform){
                        General_Concept_Platform_Junction__c gPj = new General_Concept_Platform_Junction__c();
                        gPj.Platform__c = platform.Id;
                        gPj.General_Concept__c = i;
                        genConPlatformJunction.add(gPj);
                    }
            }            
        }
        
        insert productPlatformJunction;
        insert intPlatformJunction;
        insert genConPlatformJunction;       
        
    }

    static public Map<Id, List<Id>> BuildProductList(){
        
        List<Product_Platform_Junction__c> availableProducts = [SELECT Product__c, Platform__c, Demonstrable__c FROM Product_Platform_Junction__c];
        
        Map<Id, List<Id>> platformToProductMap = new Map<Id, List<Id>>();        
        for(Product_Platform_Junction__c prod : availableProducts){
            if(prod.Demonstrable__c == true){
                if(!platformToProductMap.containsKey(prod.Platform__c)){
                    platformToProductMap.put(prod.Platform__c, new List<Id>());
                }
                platformToProductMap.get(prod.Platform__c).add(prod.Product__c);
            }
        }        
        return platformToProductMap;
    }
    
    static public Map<Id, List<Id>> BuildGenConList(){
        
        List<General_Concept_Platform_Junction__c> availableGenConcepts = [SELECT General_Concept__c, Platform__c FROM General_Concept_Platform_Junction__c];
        
        Map<Id, List<Id>> platformToGenConMap = new Map<Id, List<Id>>();        
        for(General_Concept_Platform_Junction__c genCon : availableGenConcepts){
            if(!platformToGenConMap.containsKey(genCon.Platform__c)){
                platformToGenConMap.put(genCon.Platform__c, new List<Id>());
            }
            platformToGenConMap.get(genCon.Platform__c).add(genCon.General_Concept__c);
        }
        
        return platformToGenConMap;
    }
    
    static public Map<Id, List<Id>> BuildIntegrationList(){
        
        List<Platform_Integration_Junction__c> availableIntegrations = [SELECT Integration_Solution__c, Platform__c, Demonstrable__c FROM Platform_Integration_Junction__c];
        
        Map<Id, List<Id>> platformToIntMap = new Map<Id, List<Id>>();        
        for(Platform_Integration_Junction__c integration : availableIntegrations){
            if(integration.Demonstrable__c == true){
                if(!platformToIntMap.containsKey(integration.Platform__c)){
                    platformToIntMap.put(integration.Platform__c, new List<Id>());
                }
                platformToIntMap.get(integration.Platform__c).add(integration.Integration_Solution__c);
            }
                                        
        }
        
        return platformToIntMap;
    }
    
    static public List<Id> BuildCompetitorsList() {
        List<Competition__c> competitors = [SELECT Id FROM Competition__c];
        List<Id> competitorIds = new List<Id>();
        for(Competition__c i : competitors){
            competitorIds.add(i.Id);
        }
        return competitorIds;
    }
    
    static public List<Id> BuildPlatformList() {
        List<Platform__c> platforms = [SELECT Id, Name FROM Platform__c];
        List<Id> platformIds = new List<Id>();
        for(Platform__c p : platforms){
            platformIds.add(p.Id);
        }
        return platformIds;
    }
    
    static public Id CreateOpportunity(){
        
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
            
        AX_Legal_Entity__c defaultEntity = AxLegalEntityFactory.CreateDefaultEntity();
        insert defaultEntity;

        //Create Account
        Account acct = AccountFactory.CreateProspectAccount('Test Account');
        insert acct;        
        
        //Create Opportunity       
        Opportunity opp = OpportunityFactory.CreatePremiseQualifiedOpportunity('Demo Request Test');
        opp.Account = acct;
        insert opp;
        
        //Create Opportunity Competitors
        List<Competition__c> competitors = [SELECT Id FROM Competition__c];
        List<Opportunity_Competitor__c> oppComps = new List<Opportunity_Competitor__c>();
        for(Competition__c c : competitors){
            Opportunity_Competitor__c oc = new Opportunity_Competitor__c();
            oc.Opportunity__c = opp.Id;
            oc.Competitor__c = c.Id;
            oppComps.add(oc);
        }
        insert oppComps;
        return opp.Id;
    }
    
    static public Opportunity CreateOpportunityfromAccount() {
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
            
        AX_Legal_Entity__c defaultEntity = AxLegalEntityFactory.CreateDefaultEntity();
        insert defaultEntity;

        //Create Account
        Account acct = AccountFactory.CreateProspectAccount('Test Account');
        insert acct;        
        
        //Create Opportunity       
        Opportunity opp = OpportunityFactory.CreatePremiseQualifiedOpportunity('Demo Request Test');
        opp.Account = acct;
        opp.AccountId = acct.Id;
        opp.CloseDate = DateTime.now().addDays(40).date();
        insert opp;
        
        //Create Opportunity Competitors
        List<Competition__c> competitors = [SELECT Id FROM Competition__c];
        List<Opportunity_Competitor__c> oppComps = new List<Opportunity_Competitor__c>();
        for(Competition__c c : competitors){
            Opportunity_Competitor__c oc = new Opportunity_Competitor__c();
            oc.Opportunity__c = opp.Id;
            oc.Competitor__c = c.Id;
            oppComps.add(oc);
        }
        insert oppComps;
        return opp;
    }
    
    static public Id CreateAccount(string name){
        
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
            
        AX_Legal_Entity__c defaultEntity = AxLegalEntityFactory.CreateDefaultEntity();
        insert defaultEntity;

        //Create Account
        if(name == null || name == '') name='Test Account';
        Account acct = AccountFactory.CreateProspectAccount(name);
        
        insert acct;
		system.debug('created account: ' + acct.Id);       

        return acct.Id;
    }
    
    static public Id CreateLead(){
        
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
            
        AX_Legal_Entity__c defaultEntity = AxLegalEntityFactory.CreateDefaultEntity();
        insert defaultEntity;       

        Lead l = new Lead();
        l.Status = 'Open';
        l.LastName = 'Flinestone';
        l.FirstName = 'Fred';
        l.Company = 'Slate Rock and Gravel Company';
        Country__c country = new Country__c(Name='United States',Country__c='US',ISO_Code__c='123');
        insert country;
        l.Country__c = country.Id;
        insert l;
        
        return l.Id;
    }
    
    static public List<Id> BuildTSCList() {
        List<Id> groupUserIds = new List<Id>();        
        
        for(Demonstration_Presenter__c d : [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTSC__c = true AND isTSM__c = false]){
            groupUserIds.add(d.User_Name__c);
        }
        System.debug('Technical Sales Consultants Ids: ' + groupUserIds.size() + groupUserIds);
        return groupUserIds;
    }
    
    static public List<Id> BuildTSMList() {
        List<Id> groupUserIds = new List<Id>();        
        
        for(Demonstration_Presenter__c d : [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTSM__c = true]){
            groupUserIds.add(d.User_Name__c);
        }
        System.debug('Technical Sales Management Ids: ' + groupUserIds.size() + groupUserIds);
        return groupUserIds;
    }
    
    static public List<Id> BuildAllTSList() {
        List<Id> groupUserIds = new List<Id>();        
        
        for(Demonstration_Presenter__c d : [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTS__c = true]){
            groupUserIds.add(d.User_Name__c);
        }
        System.debug('All TS Ids: '+ groupUserIds.size() + groupUserIds);
        return groupUserIds;
    }
    
    static public List<DateTime> BuildRequestTimes(Integer listSize){
        DateTime initialDt = DateTime.now().addDays(4);
        List<DateTime> listDt = new List<DateTime>{initialDt};
        DateTime newDate = initialDt;
        for(Integer i = 0; i < listSize - 1; i++){
            newDate = newDate.addDays(1);
            listDt.add(newDate);
        }
        return listDt;
    }
    
    static public List<DateTime> BuildRequestTimesInPast(Integer listSize){
        DateTime initialDt = DateTime.now().addDays(-1);
        List<DateTime> listDt = new List<DateTime>{initialDt};
        DateTime newDate = initialDt;
        for(Integer i = 0; i < listSize - 1; i++){
            newDate = newDate.addDays(-1);
            listDt.add(newDate);
        }
        return listDt;
    }
    
}