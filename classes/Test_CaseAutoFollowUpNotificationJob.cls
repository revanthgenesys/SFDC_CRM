@isTest
private class Test_CaseAutoFollowUpNotificationJob {
       
    static testmethod void testAutoFollowupJob () {  
       Util.Bypass_Trigger_Chk = true; 
    
        RecordType rt = [Select Id FROM RecordType WHERE SobjectType='Case' AND DeveloperName='Genesys_Admin_Case'];
        
        Case cs1 = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', 
                            recordtypeid=rt.Id, 
                             Do_Not_Auto_Follow_Up__c=false,
                            Auto_Follow_up_Start_Date__c = returnDate(-2));
        insert cs1;
     
        Case cs2 = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', 
                            recordtypeid= rt.Id, Do_Not_Auto_Follow_Up__c=false,     
                            Auto_Follow_up_Start_Date__c = returnDate(-5));
        insert cs2;
    
        Case cs3 = new Case(status='Awaiting Info',
                            subject='test',
                            recordtypeid=rt.Id, Do_Not_Auto_Follow_Up__c=false,
                            Auto_Follow_up_Start_Date__c = returnDate(-10));
        insert cs3;
        
        System.Test.startTest();
        Database.executeBatch( new CaseAutoFollowUpNotificationJob() );  
        System.Test.stopTest();  
    }
      
    static testmethod void testAutoFollowupSolPrpJob () {
    	Util.Bypass_Trigger_Chk = true; 
        RecordType rt = [Select Id FROM RecordType WHERE SobjectType='Case' AND DeveloperName='Genesys_Admin_Case'];
               
        Case cs1 = new Case(status='Solution Proposed',Closure_Category__c='Closed', Closure_Reason_Code__c='Closed', 
                           recordtypeid=rt.Id, Do_Not_Auto_Follow_Up__c=false,
                            Auto_Follow_up_Start_Date__c = returnDate(-2));
        insert cs1;
     
        Case cs2 = new Case(status='Solution Proposed',Closure_Category__c='Closed', Closure_Reason_Code__c='Closed',  
                            subject='test', priority = '3-Medium',
                            recordtypeid=rt.Id, Do_Not_Auto_Follow_Up__c=false,
                            Auto_Follow_up_Start_Date__c = returnDate(-5));
        insert cs2;
        
        Case cs3 = new Case(status='Solution Proposed',Closure_Category__c='Closed', Closure_Reason_Code__c='Closed', 
                            subject='test', priority = '3-Medium', 
                            recordtypeid=rt.Id, Do_Not_Auto_Follow_Up__c=false,
                            Auto_Follow_up_Start_Date__c = returnDate(-10));
        insert cs3;
        System.Test.startTest();
        Database.executeBatch( new CaseAutoFollowUpNotificationJob() ); 
        System.Test.stopTest();
    }
      
    static void testAutoFollowupJobNoData () {
        System.Test.startTest();
        Database.executeBatch( new CaseAutoFollowUpNotificationJob() );    
        System.Test.stopTest();
    }
    
    static Datetime returnDate (Integer daysBack) {     
        Datetime startDate = datetime.now();   
        Datetime retDate = startDate.addDays(-1);  ///skip day 1
        Integer i = 0;
        
        while ( i > daysBack ) {
            
            if (retDate.format('EEE') != 'Sat' && retDate.format('EEE') != 'Sun') {
                 i--;
            }           
            retDate = retDate.addDays(-1);
        }
        return retDate;
    }
    
    static testmethod void testCaseAutoFollowUpNotificationSchedule() {    
        Util.Bypass_Trigger_Chk = true; 
       
        Test.startTest();
        CaseAutoFollowUpNotificationSchedulable schedObj = new CaseAutoFollowUpNotificationSchedulable(); 
                       
        String jobId = system.schedule('test', '0 0 0 3 9 ? 2020', schedObj);              
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE id = :jobId]; 
               
        System.assertEquals('0 0 0 3 9 ? 2020', ct.CronExpression);                                             
        Database.executeBatch(new CaseAutoFollowUpNotificationJob());        
            
        Test.stopTest();
    }
}