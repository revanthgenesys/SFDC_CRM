@isTest
public class CreateMultipleSupAcsControllers_Test {
    
    static testMethod void testAddPremisSAforContact () {
    ///test for class CreateMultipleSAForContactControllr
    
       Util.Bypass_Trigger_Chk = true; 
      	  
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact cont = TestUtil.createContacts(1, accnt, true)[0];
                
        Back_Office_Account__c boa = new Back_Office_Account__c();
        boa.Contract_Status__c = 'Active';
        boa.Service_Type__c = 'Premise';
        boa.Approval_Status__c = 'Active';
        boa.Sold_To_Account__c = accnt.id;
        boa.End_User_Account__c = accnt.id;
        boa.Unique_STEU__c = accnt.id + '_' + accnt.id ;
        boa.End_User_Name__c = accnt.Name;
        boa.Sold_To_Name__c = accnt.Name;
        insert boa;
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(cont);
        CreateMultipleSupAcsForContactController addContrl = new CreateMultipleSupAcsForContactController(stdController);
        
        List<SelectOption> op = addContrl.boaPlatforms;
        addContrl.accountSearch = accnt.name;
        addContrl.showClosed = false;
        addContrl.saStatus = 'Active';
        addContrl.saAccessLevel = 'Read Only';
        addContrl.getBackOfficeAcconts();
        
        Util.Wrappers wrboa = new Util.Wrappers (boa);
        wrboa.isSelected = true;
        addContrl.addBoaList.add(wrboa);  
        
        addContrl.addSupportAccessRecords();
        
        //cover errors
        ///try to add second time
        addContrl.addSupportAccessRecords();
        
        addContrl.saStatus = null;
        addContrl.addSupportAccessRecords();
        
        addContrl.contactId = null;
        addContrl.addSupportAccessRecords();
 
    }
    
   static testMethod void testAddCloudSAforContact () {
    ///test for class CreateMultipleSupAcsForContactController
    
    Util.Bypass_Trigger_Chk = true; 
      	  
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact cont = TestUtil.createContacts(1, accnt, true)[0];
        
        Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test', Account__c = accnt.id, Status__c = 'Production',
                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
        insert cldDep;
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(cont);
        CreateMultipleSupAcsForContactController addContrl = new CreateMultipleSupAcsForContactController(stdController);
        
        List<SelectOption> op = addContrl.cloudPlatforms;
        addContrl.accountDeplSearch = 'Test';
        addContrl.showClosedCloud = false;
        addContrl.saStatus = 'Active';
        addContrl.saAccessLevel = 'Read Only';
        addContrl.selectedCloudPrem = 'Cloud';
        addContrl.changeType();
        addContrl.getCloudDeployments();
        
        Util.Wrappers wrboa = new Util.Wrappers (cldDep);
        wrboa.isSelected = true;
        addContrl.addClDeplList.add(wrboa);  
        
        addContrl.addSupportAccessCloudRecords();
        
        //cover errors
        ///try to add second time
        addContrl.addSupportAccessCloudRecords();
        
        addContrl.saStatus = null;
        addContrl.addSupportAccessCloudRecords();
        
        addContrl.contactId = null;
        addContrl.addSupportAccessCloudRecords();

    }
       
    static testMethod void testAddSAPremiseforBOA () {
    // test for class CreateMultipleSupAcsForBoaController - Premises
        Util.Bypass_Trigger_Chk = true; 
        
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact cont = TestUtil.createContacts(1, accnt, true)[0];
                
        Back_Office_Account__c boa = new Back_Office_Account__c();
        boa.Contract_Status__c = 'Active';
        boa.Service_Type__c = 'Premise';
        boa.Approval_Status__c = 'Active';
        boa.Sold_To_Account__c = accnt.id;
        boa.End_User_Account__c = accnt.id;
        boa.Unique_STEU__c = accnt.id + '_' + accnt.id ;
        boa.End_User_Name__c = accnt.Name;
        boa.Sold_To_Name__c = accnt.Name;
        insert boa;
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(boa);
        CreateMultipleSupAcsForBoaController addContrl = new CreateMultipleSupAcsForBoaController(stdController);
        
        addContrl.contactSearch = 'test';
        addContrl.saStatus = 'Active';
        addContrl.saAccessLevel = 'Read Only';
        addContrl.getContacts();
        
        CreateMultipleSupAcsForBoaController.wrapContact wr = new CreateMultipleSupAcsForBoaController.wrapContact (cont);
        wr.isSelected = true;
        addContrl.addContList.add(wr);  
        
        addContrl.addSupportAccessRecords();
        
        //cover errors
        ///try to add second time
        addContrl.addSupportAccessRecords();
        
        addContrl.saStatus = null;
        addContrl.addSupportAccessRecords();
        
        addContrl.boaId = null;
        addContrl.addSupportAccessRecords();

  } 
  
  static testMethod void testAddSACforCloudDepl () {
    // test for class CreateMultipleSupAcsForCloudController - Cloud
             
      Util.Bypass_Trigger_Chk = true; 

        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact cont = TestUtil.createContacts(1, accnt, true)[0];
                
        Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
        insert cldDep;
            
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(cldDep);
        CreateMultipleSupAcsForCloudController addContrl = new CreateMultipleSupAcsForCloudController(stdController);
        
        addContrl.contactSearch = 'test';
        addContrl.saStatus = 'Active';
        addContrl.saAccessLevel = 'Read Only';
        addContrl.getContacts();
        
        CreateMultipleSupAcsForCloudController.wrapContact wr = new CreateMultipleSupAcsForCloudController.wrapContact (cont);
        wr.isSelected = true;
        addContrl.addContList.add(wr);  
        
        addContrl.addSupportAccessRecords();
        
        //cover errors
        ///try to add second time
        addContrl.addSupportAccessRecords();
        
        addContrl.saStatus = null;
        addContrl.addSupportAccessRecords();
        
        addContrl.deplId = null;
        addContrl.addSupportAccessRecords();
    }

}