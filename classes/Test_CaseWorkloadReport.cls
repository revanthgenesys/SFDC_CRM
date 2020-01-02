@isTest
private class Test_CaseWorkloadReport
{
    static testmethod void testReport()
    {
        Util.Bypass_Trigger_Chk = true;
        User usr = TestCommon.createUser('testtet', null, 'MyTestLastName','MyTestFirstName',Config__c.getValues('PROFIL_ADMIN_ID').Value__c);
        usr.Product_Support_group__c = 'Business Applications';
        usr.Work_Day_Start__c = '8:00';
        usr.Work_Day_End__c = '17:00';
        update usr;
        Account acc = TestCommon.createAccount(true);
        Contact cnt = TestCommon.createContact(acc.id);
        Support_Product__c sp = new Support_Product__c();
        sp.Product_Support_Group__c = 'Business Applications';
        Case cas = new Case(status='open',subject='test',contactid=cnt.id,Support_Product__c=sp.id);
        cas.ownerid=usr.id;
        cas.expert_help__c=usr.id;        
        cas.recordtypeid=Config__c.getValues('RT_CASE_SUPPORT').Value__c;
        cas.Product_Support_Group__c ='Business Applications';
        cas.Last_Owner_Change__c=System.now();
        cas.priority = '3-Medium';
        insert cas;
        cas.Last_Owner_Change__c=System.now();
        update cas;        
        ApexPages.StandardController cont = new ApexPages.StandardController(new Case(id=cas.id));
        PageReference caselogic= new PageReference('/apex/caseLogic2');
        caselogic.getparameters().put('id',cas.id);
     Test.startTest();
        Test.setCurrentPage(caselogic);
        Apexpages.currentPage().getparameters().containsKey('id');
        CaseWorkLoadReport cwr = new CaseWorkLoadReport(cont);
        cwr.selectedPSG= 'Business Applications';
        cwr.generateReport();
      
        cwr.sortField='currentstatus';
        cwr.sortOrder='asc';
        cwr.sort();
        cwr.sortOrder='dsc'; 
        cwr.sort();  
           
        cwr.sortField='currenttime';
        cwr.sortOrder='asc';
        cwr.sort();
        cwr.sortOrder='dsc'; 
        cwr.sort();
        
               
        cwr.sortField='total24';
        cwr.sortOrder='asc';
        cwr.sort();
        cwr.sortOrder='dsc'; 
        cwr.sort();
              
        cwr.sortField='totalowned';
        cwr.sortOrder='asc';
        cwr.sort();
        cwr.sortOrder='dsc'; 
        cwr.sort(); 
        
             
        cwr.sortField='total48';
        cwr.sortOrder='dsc';  
        cwr.sort();  
        cwr.sortOrder='asc'; 
        cwr.sort(); 
                      
        cwr.sortField='total168';
        cwr.sortOrder='dsc';  
        cwr.sort();  
        cwr.sortOrder='asc'; 
        cwr.sort(); 
         
        cwr.sortField='name';
        cwr.sortOrder='dsc'; 
        cwr.sort(); 
        cwr.sortOrder='asc'; 
        cwr.sort(); 
        
        cwr.sortField='chkbox';
        cwr.sortOrder='dsc'; 
        cwr.sort(); 
        cwr.sortOrder='asc'; 
        cwr.sort(); 
                      
        cwr.selectedPSG= 'All';
        cwr.generateReport();
        cwr.filterEnabled = true;
        cwr.filterReport();
        
        usr.Work_Day_Start__c = '18:00';
        usr.Work_Day_End__c = '5:00';
        update usr;
        //cwr.generateReport();
     Test.stopTest();   
    }

}