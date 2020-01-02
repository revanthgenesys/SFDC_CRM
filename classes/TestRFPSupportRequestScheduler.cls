@isTest (seeAllData=true)
private class TestRFPSupportRequestScheduler{

   static testmethod void testRFPSuppSchedular(){
        RFPSupportRequestScheduler rfpSupport = new RFPSupportRequestScheduler();
        System.schedule('Test Scheduler Check','0 0 0 1 4 ?',rfpSupport);
        RFPSupportRequestScheduler.sendEmail();
    }
    
    // 10-12-2019 --> Ankaiah Bandi --> below code is added for test coverage of APAC,EMEA,LATAM & NA scheduler classes
    
   static testmethod void testRFPSuppSchedularAPAC(){
        RFPSupportRequestSchedulerAPAC rfpSupport = new RFPSupportRequestSchedulerAPAC();
        System.schedule('Test Scheduler Check','0 0 0 1 4 ?',rfpSupport);
        RFPSupportRequestSchedulerAPAC.sendEmail();
    }
    
    // 11-12-2019 --> Amit Gupta --> below code is added for test coverage of EMEA,LATAM & NA scheduler classes
    
    static testmethod void testRFPSuppSchedularNA(){
        RFPSupportRequestSchedulerNA rfpSupport = new RFPSupportRequestSchedulerNA();
        System.schedule('Test Scheduler Check','0 0 0 1 4 ?',rfpSupport);
        RFPSupportRequestSchedulerNA.sendEmail();
    }
    
     static testmethod void testRFPSuppSchedularLATAM(){
        RFPSupportRequestSchedulerLATAM rfpSupport = new RFPSupportRequestSchedulerLATAM();
        System.schedule('Test Scheduler Check','0 0 0 1 4 ?',rfpSupport);
        RFPSupportRequestSchedulerLATAM.sendEmail();
    }
    
    static testmethod void testRFPSuppSchedularEMEA(){
        RFPSupportRequestSchedulerEMEA rfpSupport = new RFPSupportRequestSchedulerEMEA();
        System.schedule('Test Scheduler Check','0 0 0 1 4 ?',rfpSupport);
        RFPSupportRequestSchedulerEMEA.sendEmail();
    }
    
}