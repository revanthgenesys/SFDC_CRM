global class DemoWebinar implements Schedulable {
	       
    global void execute(SchedulableContext SC) {
        createWeeklyWebinars();
    }
    
    public static void createWeeklyWebinars() {
        DateTime now = DateTime.now();
        Integer days = 0;
        //make them a week earlier by default
        now.addDays(7);
        while(now.addDays(days).format('EEE') != 'Mon') days++;
        
        DateTime mon = now.addDays(days);
        DateTime tues = now.addDays(days+1);
        DateTime wed = now.addDays(days+2);
        DateTime thurs = now.addDays(days+3);
        DateTime fri = now.addDays(days+4);
        
        List<Demo_Request__c> webs = [Select Id from Demo_Request__c where Requester_Name__c = 'Team Process' and Demo_Date_Time__c >= :mon and Demo_Date_Time__c <= :fri];
        if(webs.size() >= 2 ) return;
        
        DateTime finalTues = DateTime.newInstance(tues.year(), tues.month(), tues.day(), 11, 0, 0);
        DateTime finalThurs = DateTime.newInstance(thurs.year(), thurs.month(), thurs.day(), 10, 0, 0);
        
        
        String pcWebName = 'Purecloud Webinar';
        createWebinar(pcWebname, finalTues);
        createWebinar(pcWebname, finalThurs);
    }
    
    private static void createWebinar(String platformName, DateTime start){
        DemoRequestBuilder drb = new DemoRequestBuilder();
        DemoRequestRelatedItems drl = new DemoRequestRelatedItems();
        Platform__c pcWebinar = [Select Id, Name from Platform__c where Name=:platformName];
        drl.platSel.add(new SelectOption(pcWebinar.Id, pcWebinar.Name));
        
        //quick way to go to list to set of ids
        List<General_Concept_Platform_Junction__c > gens = [Select General_Concept__c, General_Concept__r.Name from General_Concept_Platform_Junction__c where Platform__r.Name=:platformName];
        List<Product_Platform_Junction__c> prods = [Select Product__c,  Product__r.Name from Product_Platform_Junction__c where Platform__r.Name=:platformName];
        List<Platform_Integration_Junction__c> ints = [Select Integration_Solution__c,  Integration_Solution__r.Name from Platform_Integration_Junction__c where Platform__r.Name=:platformName];
        

        for(Product_Platform_Junction__c p : prods) drl.prodSel.add(new SelectOption(p.Product__c, p.Product__r.Name));
        for(General_Concept_Platform_Junction__c p : gens) drl.genSel.add(new SelectOption(p.General_Concept__c, p.General_Concept__r.Name));
        for(Platform_Integration_Junction__c p : ints) drl.intSel.add(new SelectOption(p.Integration_Solution__c, p.Integration_Solution__r.Name));
        
        drb.RequesterEmail = 'TechSalesDev@inin.com';
        drb.RequesterName = 'Weekly Webinar';
        drb.audienceType = 'Webinar';
        drb.requestType = 'Webinar';
        drb.companyName = 'Weekly Webinar';
        drb.demoLocation = 'Web Based';
        drb.demoDuration = 1;
        drb.demoDateTime = start;
        drb.demoTimezone = 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)';
        drb.Attendees = 'Webinar Signin: https://global.gotowebinar.com/webinars.tmpl';
        drb.suppressNotifications = true;
        drb.queue = 'Technical Sales';
        
        Demo_Request__c d = drb.build();
        drl.setDemo(d);
        drl.saveChanges();
    }
}