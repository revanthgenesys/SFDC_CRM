public class CreateMultipleSupAcsForContactController {
        
        public String contactName {get; private set;}
        public String accountSearch {get; set;}
        public String accountDeplSearch {get; set;}
        public String platformSearch {get; set;}
        public String platformCldSearch {get; set;}
        public List<Util.Wrappers> addBoaList {get; set;}
        public List<Util.Wrappers> addClDeplList {get; set;}
        public List<Back_Office_Account__c> boaList;
        public List<Cloud_Deployment__c> cldeplList;
        public String saStatus {get; set;}
        public String saAccessLevel {get; set;}
        public String saStatusComment {get; set;}
        public String saCaseNum {get; set;}
        public Id contactId {get; set;}
        public Boolean showClosed {get; set;}
        public Boolean showClosedCloud {get; set;}
        public String selectedCloudPrem {get; set;}
        public Boolean isCloud {get; set;}
        public Boolean isPremise {get; set;}
        //// to display date and account fields properly from the page
        public Support_Access__c dummySa {get; set;}
        
        public CreateMultipleSupAcsForContactController (ApexPages.StandardController stdController) {
                 contactId = stdController.getId();
                 showClosed = false;
                 showClosedCloud = false;
   
                 addBoaList = new List<Util.Wrappers>();
                 addClDeplList = new List<Util.Wrappers>();
                 
                 if (contactId != null ) {
                    List<Contact> cont = [SELECT Name FROM Contact WHERE Id = :contactId];
                    contactName = cont[0].Name;
                 }
                 
                 dummySa = new Support_Access__c();
             //    selectedCloudPrem = 'Premise';
       }
        
       public List<SelectOption> cloudPlatforms {
        	get {
        		List<SelectOption> options = new List<SelectOption>();
        		options.add(new SelectOption('', ''));
        		
        		Schema.DescribeFieldResult fieldResult = Cloud_Deployment__c.Cloud_Platform__c.getDescribe();
        	    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
  			    for( Schema.PicklistEntry f : ple)  
 					options.add(new SelectOption(f.getLabel(), f.getValue()));
 					
   				return options;
        	}
        	set;
        }

       public List<SelectOption> boaPlatforms {
        	get {
        		List<SelectOption> options = new List<SelectOption>();
        		options.add(new SelectOption('', ''));
        		
        		Schema.DescribeFieldResult fieldResult = Back_Office_Account__c.Platform__c.getDescribe();
        	    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();         	           
  			    for( Schema.PicklistEntry f : ple)  
 					options.add(new SelectOption(f.getLabel(), f.getValue()));
 					
   				return options;
        	}
        	set;
        }
        
        public PageReference changeType() {
            isCloud = selectedCloudPrem == 'Cloud' ? true : false;
            isPremise = selectedCloudPrem == 'Premise' ? true : false;
            
            saStatus = '';
            saAccessLevel = '';
            saStatusComment = '';
            saCaseNum = '';
            showClosed = false;
            accountSearch = '';
            accountDeplSearch = '';
            platformSearch = '';
            dummySa = new Support_Access__c();
                        
            return null;
        }
        
        public void getBackOfficeAcconts () {
                addBoaList.clear(); 
                String contractStatus = '';
                
                if ( String.isBlank(accountSearch) ) {                          
                        return;
                }
                else {                        
                        String searchStr = '%' + accountSearch + '%'; 
                        String pltfrmStr = '%' + (String.isBlank(platformSearch) ? '' : platformSearch) + '%';
                        if ( !showClosed )
                           contractStatus = ' AND Contract_Status__c = \'Active\' ';
                  
                       String query = 'SELECT Id, Name, End_User_Name__c, Sold_To_Name__c, Contract_Status__c, ' +
                                      ' Access_Approval__c, End_User_Account__c, Sold_To_Account__c, Platform__c ' + 
                                      'FROM Back_Office_Account__c ' +
                                      'WHERE Service_Type__c != \'Cloud\' ' + contractStatus +                                             
                                      'AND (End_User_Name__c LIKE \'' + searchStr + '\' OR Sold_To_Name__c LIKE \'' + searchStr + '\') ' +  
                                      'AND Platform__c LIKE \'' + pltfrmStr + '\' ' +                              
                                      'ORDER BY End_User_Name__c, Sold_To_Name__c LIMIT 500';

                        for(Back_Office_Account__c boa :  Database.query( query ) )  {
                            addBoaList.add(new Util.Wrappers (boa));                            
                        }
                }               
        }
        
        public void getCloudDeployments () {
                addClDeplList.clear(); 
                String deplStatus = '';
                
                if ( String.isBlank(accountDeplSearch) ) {                          
                        return;
                }
                else {                        
                        String searchStr = '%' + accountDeplSearch + '%'; 
                        String pltfrmStr = '%' + (String.isBlank(platformCldSearch) ? '' : platformCldSearch) + '%';
                        if ( !showClosedCloud )
                              deplStatus =  ' AND (Support_Status__c = \'Active\' OR Support_Status__c= null) ';
                              
                       String query = 'SELECT Id, Name, Account__r.Name, Account__c, Cloud_Platform__c, Support_Status__c, ' + 
                                      ' Sold_To_Account__c, Sold_To_Account__r.Name, Access_Approval__c ' +
                                      'FROM Cloud_Deployment__c ' +
                                      'WHERE Account__c != null ' +
                                      ' AND Support_Status__c != \'Billing Only\' ' +
                                      ' AND (Name LIKE \'' + searchStr + '\' OR Account__r.Name LIKE \'' + searchStr + '\'  OR Sold_To_Account__r.Name LIKE \'' + searchStr + '\') ' +
                                      ' AND Cloud_Platform__c LIKE \'' + pltfrmStr + '\' ' + 
                                        deplStatus +                                   
                                      ' ORDER BY Name LIMIT 500';

                        for(Cloud_Deployment__c cld :  Database.query( query ) )  {
                            addClDeplList.add(new Util.Wrappers (cld));                            
                        }
                }               
        }
        
        public void addSupportAccessRecords() {
                if ( contactId == null ) {
                   ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Contact is required.'));
                  return;
                } 
                else if ( addBoaList.isEmpty() ) {
                  ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at least one Back Office Account record.'));
                  return;
                }
                else if (saStatus == null || saAccessLevel == null ) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please provide Status and Access Level for the new Support Access records.'));
                        return;
                }
      
                List<Support_Access__c> existingSAList = [SELECT Back_Office_Account__c 
                                                          FROM Support_Access__c 
                                                          WHERE Contact__c = :contactId AND Back_Office_Account__c != null];
                Set<Id> existingBoaIdSet = new Set<Id>();
                if ( !existingSAList.isEmpty() )  {
                    for (Support_Access__c sa : existingSAList ) 
                       existingBoaIdSet.add(sa.Back_Office_Account__c);
                }
                
                //// process selected Back Office Account records
                Integer skippedExisting=0, insNum=0, errNum=0, totalSelected=0;
                String messg ='', errMsg='';
                
                List<Support_Access__c> insSupAccessList = new List<Support_Access__c>();   
                
                ////Workaround for too many SOQL queries error. All required fields set here
                Util.Bypass_Trigger_Chk = true; 
                                                
                for (Util.Wrappers boa : addBoaList) {                   
                    
                    if(boa.isSelected) {
                        Id boaId = (Id) boa.obj.get('Id');
                        totalSelected++;
                        
                        if ( !existingBoaIdSet.isEmpty() && existingBoaIdSet.contains(boaId) ) {
                             skippedExisting++;
                             continue;
                        }     
                        Support_Access__c sa = new Support_Access__c (Contact__c = contactId,
                                                                      Back_Office_Account__c = boaId,
                                                                      Status__c = saStatus,
                                                                      SR_Access_Level__c = saAccessLevel,
                                                                      Support_Owner__c = dummySa.Support_Owner__c,
                                                                      Expiration_Date__c = dummySa.Expiration_Date__c,
                                                                      Status_Comment__c = saStatusComment,
                                                                      Case_Number__c = saCaseNum,                                                                      
                                                                      End_User_Account__c = (Id) boa.obj.get('End_User_Account__c'),
                 													  Sold_To_Account__c = (Id) boa.obj.get('Sold_To_Account__c'),
                 							                          Unique_Boa_Contact_Combination__c = boaId + '_' + contactId);
                        insSupAccessList.add(sa);
                    }
                }
                
                if ( !insSupAccessList.isEmpty() ) {
                        List<Database.SaveResult> insResults = Database.insert(insSupAccessList, false);                                                                          
                         for (Database.SaveResult result : insResults) {
                                   if (result.isSuccess()) 
                                          insNum++;
                                   else {
                                         errNum++;
                                         errMsg += result.getErrors()[0].getMessage() + '\n';
                                   }
                      }
                }
                messg = 'Out of total ' + totalSelected + ' Back Office Account selected records:  ';
                messg += insNum + ' Support Access records added successfully; ';              
                if ( skippedExisting > 0 )
                     messg += skippedExisting + ' found existing;  ';
                                             
               if ( errNum > 0 )
                   messg += errNum + ' Failed due to error';
                         
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, messg));                
                                         
        }
        
        public void addSupportAccessCloudRecords() {
                if ( contactId == null ) {
                   ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Contact is required.'));
                  return;
                } 
                else if ( addClDeplList.isEmpty() ) {
                  ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please select at least one Cloud Deployment record.'));
                  return;
                }
                else if (saStatus == null || saAccessLevel == null ) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Please provide Status and Access Level for the new Support Access records.'));
                        return;
                }
      
                List<Support_Access_Cloud__c> existingSAList = [SELECT Cloud_Deployment__c 
                                                                  FROM Support_Access_Cloud__c 
                                                                 WHERE Contact__c = :contactId];
                Set<Id> existingCldIdSet = new Set<Id>();
                if ( !existingSAList.isEmpty() )  {
                    for (Support_Access_Cloud__c sa : existingSAList ) 
                       existingCldIdSet.add(sa.Cloud_Deployment__c);
                }
                
                //// process selected records
                Integer skippedExisting=0, insNum=0, errNum=0, totalSelected=0;
                String messg ='', errMsg='';
                
                List<Support_Access_Cloud__c> insSupAccessList = new List<Support_Access_Cloud__c>();                                   
                for (Util.Wrappers cld : addClDeplList) {                   
                    
                    if(cld.isSelected) {
                        Id deplId = (Id) cld.obj.get('Id');
                        totalSelected++;
                        
                        if ( !existingCldIdSet.isEmpty() && existingCldIdSet.contains(deplId) ) {
                             skippedExisting++;
                             continue;
                        }     
                        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = contactId,
                                                                      Cloud_Deployment__c = deplId,
                                                                      Access_Status__c = saStatus,
                                                                      Access_Level__c = saAccessLevel,
                                                                      Expiration_Date__c = dummySa.Expiration_Date__c,
                                                                      Status_Comment__c = saStatusComment,
                                                                      Case_Number__c = saCaseNum );
                        insSupAccessList.add(sa);
                    }
                }
                
                if ( !insSupAccessList.isEmpty() ) {
                        List<Database.SaveResult> insResults = Database.insert(insSupAccessList, false);                                                                          
                         for (Database.SaveResult result : insResults) {
                                   if (result.isSuccess()) 
                                          insNum++;
                                   else {
                                         errNum++;
                                         errMsg += result.getErrors()[0].getMessage() + '\n';
                                   }
                      }
                }
                messg = 'Out of total ' + totalSelected + ' Cloud Deployment selected records:  ';
                messg += insNum + ' Support Access records added successfully; ';              
                if ( skippedExisting > 0 )
                     messg += skippedExisting + ' found existing;  ';
                                             
               if ( errNum > 0 )
                   messg += errNum + ' Failed due to error';
                         
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, messg));                
                                         
        }       
}