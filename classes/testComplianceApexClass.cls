//Ravi V - Sales Compliance -  10/17/2013
@isTest(SEEALLDATA=TRUE)

public class testComplianceApexClass{  
     static String firstcheck;
     String RecordTypeId;
     String st;
     List<SelectOption> temp = new List<SelectOption>();
     static Account a ;
     static Compliance_Response__c sar;
     static Export_Screening_Checklist__c sa3 = new Export_Screening_Checklist__c();
     static user u;
     static List<compliance_question__c> cpmqu = new List<compliance_question__c>();
     static Export_Screening_Checklist__c sa;
     
     static{        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        u = new User(FirstName = 'Test007',LastName = 'User007',Email = 'vikram.sharma@genesys.com',CompanyName = 'testcom007',
                     Title = 'Test User0007',Username = 'ravikiranreddyv007@genesys.com',Alias = 'testu007',CommunityNickname = 'Test User',
                     TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,
                     LanguageLocaleKey = 'en_US',EmployeeNumber = 'EMP-'+ Math.random().format());
        insert u;
     }
    
    public static void insertTestData(){ 
     RecordType rt = [select id,Name from RecordType where name='EMG - Customer Record Type'];
     List<String> listTempCntry = new List<String>();
         listTempCntry.add('United States');
         listTempCntry.add('Canada');
         listTempCntry.add('Japan');  
         listTempCntry.add('China'); 
     List<Country__c> cc = [select id,Name from Country__c where NAME IN : listTempCntry];
     for(integer i=0;i<5;i++){
        compliance_question__c saq = new compliance_question__c(Compliance_Question__c='this is for testing'+i,Question_number__c=i,name='question'+i);
        cpmqu.add(saq);
		complianceWrapper saqWrappernew = new complianceWrapper(saq);
     	saqWrappernew.getOptionsall();         
     }
     insert cpmqu;
     
     
     List<Account> listAccnts = new List<Account>();   
     a = new Account( Name='Test Account007', Status__c = 'Active',Type='Prospect',Country__c=cc[0].id,recordtypeid=rt.id,
                     ownerid=u.id,screening_checklist_completed__c=true); 
     listAccnts.add(a);
     /*
     Account a1 = new Account( Name='Test Account007', Status__c = 'Active',Type='Partner',Country__c=cc[1].id,recordtypeid=rt.id,
                              ownerid=u.id,screening_checklist_completed__c=true); 
     listAccnts.add(a1);
     Account a2 = new Account( Name='Test Account007',StateProvince__c = 'test Province', Type='Customer',IsDirect__c = true,
                              Status__c = 'Active',Country__c=cc[2].id,recordtypeid=rt.id,ownerid=u.id,screening_checklist_completed__c=true); 
     listAccnts.add(a2);
     Account a3 = new Account( Name='Test Account007',StateProvince__c = 'test Province', Status__c = 'Active',Country__c=cc[3].id,
                              recordtypeid=rt.id,ownerid=u.id,screening_checklist_completed__c=true); 
     listAccnts.add(a3);
     */ 
     insert listAccnts;   
     //delete a3;    
          
     sa = new Export_Screening_Checklist__c(name='test007',account__c=a.id,
                                            Checklist_expiration_date__c=Date.newInstance(System.today().year(), System.today().month()+1, System.today().day()),
                                            ownerid=u.id,CompletionDate__c=date.today());
     insert sa;
     Export_Screening_Checklist__c sa1 = new Export_Screening_Checklist__c(name='test008',account__c=a.id,
                                            Checklist_expiration_date__c=Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
                                            ownerid=u.id,CompletionDate__c=date.today());
     insert sa1;
    }
    
 public static testmethod void updateRec() {   
 // Test.startTest();
  
   System.runAs(u){
   	Test.startTest();    
    insertTestData(); 
    Test.stopTest();
   }   
    /*  
    PageReference pageRef = Page.compliance_new;
    pageRef.getParameters().put('retURL','/'+a.id);
    Test.setCurrentPageReference(pageRef); 
    ApexPages.StandardController sc = new ApexPages.StandardController(sa);
    compliance_extension sad = new compliance_extension(sc);
    Export_Screening_Checklist__c abc= sad.getescdisplay();
    Date dd=sad.getexpirationdate();
    firstcheck=sad.getNeworedit();
    sad.count = 15;   
    sad.subcount=9;
    sad.status='Yes';
       
    pageReference pfsave =sad.savequestions();
    ComplianexpireBatch cb = new  ComplianexpireBatch();
    Schedulesendemail ss = new Schedulesendemail();
    ChecklistIterable checkir = new ChecklistIterable();
    ChecklistIterator ci = new ChecklistIterator();
    checkir.Iterator();
    Export_Screening_Checklist__c esc = ci.next();
    boolean next = ci.hasNext();
    SchedulableContext sc1;
    Database.BatchableContext bc;
    cb.start(bc);
    List<Export_Screening_Checklist__c> lsttrig=new List<Export_Screening_Checklist__c>();
    lsttrig=[SELECT id,name,Account__c,Checklist_expiration_date__c,owner.email,Account__r.name,
             Account__r.owner.email FROM Export_Screening_Checklist__c where Checklist_expiration_date__c!=null LIMIT 5];
    //lsttrig.add(sa);
    cb.execute(bc,lsttrig);
    cb.finish(bc);
    Test.StopTest();
    
        //Test code for order_checklist
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        List<Order__c> orders = new List<Order__c>();
            
        for(Integer i=0; i<1; i++ ){
            Order__c o = new Order__c();
            o.Quote__c = testQuote.id;
            o.Maintenance_Start__c = Date.today();
            o.Maintenance_End__c = Date.today().addYears(1);
            o.Opportunity__c = testOpp.id;
            o.Numb_of_Maint_Months__c = 12;
            o.End_User_Name__c=a.id;
            orders.add( o );
        }
        //insert orders;
        PageReference pageRef1 = Page.Order_checklist;
        Test.setCurrentPageReference(pageRef1); 
       //List<order__c> records = [SELECT Id,End_User_Name__c FROM Order__c WHERE End_User_Name__r.screening_checklist_completed__c = true and id=:orders[0] ];
        pageRef1.getParameters().put('id',+orders[0].id);
        ApexPages.StandardController sco = new ApexPages.StandardController(orders[0]);
    
    
     Order_checklist sado1 = new Order_checklist(sco);       
     List<compliance_response__c> saqWrapperresponse = new List<compliance_response__c>();
     List<Export_Screening_Checklist__c> sa1 = new List<Export_Screening_Checklist__c>();
     sa1=[select id,name,Checklist_expiration_date__c from Export_Screening_Checklist__c limit 1];
     
     PageReference pageRef3 = Page.compliance_edit;
     Test.setCurrentPageReference(pageRef3); 
     pageRef3.getParameters().put('tempid',+sa.id);
     pageRef3.getParameters().put('mode','edit');
     ApexPages.StandardController sc3 = new ApexPages.StandardController(sa);
     compliance_extension sad1 = new compliance_extension(sc3);
     Export_Screening_Checklist__c abc3= sad1.getescdisplay();
     Date dd3=sad1.getexpirationdate();
     sad1.subcount=9;
     sad1.status='Yes';
     pageReference pfupdate =sad1.updatequestions();     
     }
     */
  }
     
}