@isTest(seeAllData=true)
public class LicenseSnapshotTest {
    @isTest
    static void testLMSCaptureSoldToEndUserCombinationBatch(){
		Test.startTest();
        LMSCaptureSoldToEndUserCombinationBatch batchClass =  new LMSCaptureSoldToEndUserCombinationBatch();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();        
    }
    
    @isTest
    static void testLMSCaptureSnapshotBatch(){
        List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL];
        
        List<License_Snapshot_Sold_To_End_User__c> combinationRecords = new List<License_Snapshot_Sold_To_End_User__c>();
        for(ServiceContract sc : sContracts){
			combinationRecords.add(new License_Snapshot_Sold_To_End_User__c(Sold_To__c = sc.Sold_To_Name__c, 
                                                                            End_User__c = sc.End_User_Name__c,
                                                                            Sold_To_End_User__c = sc.Sold_To_Name__c + '' + sc.End_User_Name__c,
                                                                            Regenerate_Snapshot__c = true,
                                                                            Snapshot_Reason__c = 'Testing Snapshot'
                                                                           )
                                  );
        }
        Database.upsert(combinationRecords, Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
        
        Test.startTest();
        LMSCaptureSnapshotBatch batchClass =  new LMSCaptureSnapshotBatch();       
        ID batchprocessid = Database.executeBatch(batchClass);
        Test.stopTest();  
    }
	
    @isTest
	static void testLMSCaptureSTEUCombinationScheduler(){
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler1', cronExp, new LMSCaptureSTEUCombinationScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    } 
    
    @isTest
    static void testLicenseSnapshotUtil1(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		for(ServiceContract sc : sContracts){   
			LicenseSnapshotUtil.generateSnapshot(sc.Sold_To_Name__c, sc.End_User_Name__c, 'Testing Snapshot');
			LicenseSnapshotUtil.refreshSnapshot(sc.End_User_Name__c);                                        
		}
    }
    
    @isTest
    static void testLicenseSnapshotUtil2(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		for(ServiceContract sc : sContracts){   
			String[] soldToAccountIds = new List<String> {sc.Sold_To_Name__c};
        	LicenseSnapshotUtil.generateSnapshot(sc.End_User_Name__c, 'Testing Snapshot');
			LicenseSnapshotUtil.generateSnapshot(soldToAccountIds, sc.End_User_Name__c, 'Testing Snapshot');
			LicenseSnapshotUtil.refreshSnapshot(sc.End_User_Name__c, soldToAccountIds);                                      
		}
    }
   
    @isTest
    static void testLicenseSnapshotUtil3(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		LicenseSnapshotUtil.trackServiceContractForSnapshot(sContracts);
    }
    
    @isTest
    static void testLicenseSnapshotUtil3_1(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        sContracts[0].Agreement_Status__c = 'Drop';
		LicenseSnapshotUtil.trackServiceContractForSnapshot(sContracts);
    }
    
    @isTest
    static void testLicenseSnapshotUtil3_2(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		sContracts[0].Agreement_Status__c = 'Closed';
		LicenseSnapshotUtil.trackServiceContractForSnapshot(sContracts);
    }
    
    @isTest
    static void testLicenseSnapshotUtil3_3(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		sContracts[0].Agreement_Status__c = 'Transferred';
		LicenseSnapshotUtil.trackServiceContractForSnapshot(sContracts);
    }
    
    @isTest
    static void testLicenseSnapshotUtil3_4(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		sContracts[0].Agreement_Status__c = 'In Negotiation';
		LicenseSnapshotUtil.trackServiceContractForSnapshot(sContracts);
    }
    
    @isTest
    static void testLicenseSnapshotUtil4(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = sc.Agreement_Status__c ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_1(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = 'Drop' ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }

	@isTest
    static void testLicenseSnapshotUtil4_2(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = 'Closed' ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_3(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = 'Transferred' ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_4(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = 'In Negotiation' ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_5(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
                                            
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate, Agreement_Status__c = 'Credit' ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_6(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate.addDays(-1), endDate = sc.endDate, Agreement_Status__c = sc.Agreement_Status__c ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil4_7(){
    	List<ServiceContract> oldServiceContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c, startDate, endDate  
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();                                     
		for(ServiceContract sc : oldServiceContracts){   
			newServiceContracts.add(new ServiceContract(Id = sc.id, Sold_To_Name__c = sc.Sold_To_Name__c , End_User_Name__c = sc.End_User_Name__c, startDate = sc.startDate, endDate = sc.endDate.addDays(1), Agreement_Status__c = sc.Agreement_Status__c ));
		}
		LicenseSnapshotUtil.trackServiceContractForSnapshot(newServiceContracts, oldServiceContracts);		
    }
    
    @isTest
    static void testLicenseSnapshotUtil5(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		List<ContractLineItem> clis = [SELECT id, ServiceContractId, Current_Quantity__c, PricebookEntryId, PricebookEntry.Product2Id, Maintenance_Start_Date__c, Maintenance_End_Date__c, Upgraded_Product__c FROM ContractLineItem WHERE ServiceContractId = :sContracts[0].Id];
		LicenseSnapshotUtil.trackServiceContractLineItemForSnapshot(clis);
    }
    
    @isTest
    static void testLicenseSnapshotUtil6(){
    	List<ServiceContract> sContracts = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, End_User_Name__c, End_User_Name__r.Name, Agreement_Status__c
                                            FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation') AND End_User_Name__r.ININ_ID__c != NULL LIMIT 1];
		List<ContractLineItem> clis = [SELECT id, ServiceContractId, Current_Quantity__c, PricebookEntryId, PricebookEntry.Product2Id, Maintenance_Start_Date__c, Maintenance_End_Date__c, Upgraded_Product__c FROM ContractLineItem WHERE ServiceContractId = :sContracts[0].Id];
		LicenseSnapshotUtil.trackServiceContractLineItemForSnapshot(clis, clis);
		
    }
    
    @isTest
    static void testLicenseSnapshotUtil7(){
		Account testAccount = [Select Id, Name FROM Account WHERE ININ_ID__c != NULL LIMIT 1];
		List<UL_Upsize_Parts__c> ulParts = [SELECT Name, Part_To_Be_Decremented__c, Part_To_Be_Incremented__c FROM UL_Upsize_Parts__c WHERE Name in ('SW-001-4.0-ULA4','SW-001-4.0-ULA9') LIMIT 2];
		
		Set<String> productAPNNumbers = new Set<String>();
		productAPNNumbers.add(ulParts[0].Name);
		productAPNNumbers.add(ulParts[0].Part_To_Be_Decremented__c);
		productAPNNumbers.add(ulParts[0].Part_To_Be_Incremented__c);
		productAPNNumbers.add(ulParts[1].Name);
		productAPNNumbers.add(ulParts[1].Part_To_Be_Decremented__c);
		productAPNNumbers.add(ulParts[1].Part_To_Be_Incremented__c);
		
		Map<String, Product2> productsMap = new Map<String, Product2>();
		for(Product2 p: [SELECT Id, APN_Number__c, Description FROM Product2 WHERE APN_Number__c IN :productAPNNumbers]){
			productsMap.put(p.APN_Number__c, p);
		}	
		List<License_Snapshot__c> snapshotRecords = new List<License_Snapshot__c>();
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulParts[0].Part_To_Be_Decremented__c,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 5, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).Id, Part_Number__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).APN_Number__c, Description__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).Description
		));	
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulParts[0].Part_To_Be_Decremented__c,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 5, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).Id, Part_Number__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).APN_Number__c, Description__c = productsMap.get(ulParts[0].Part_To_Be_Decremented__c).Description
		));	
		
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulParts[1].Part_To_Be_Decremented__c,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 10, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulParts[1].Part_To_Be_Decremented__c).Id, Part_Number__c = productsMap.get(ulParts[1].Part_To_Be_Decremented__c).APN_Number__c, Description__c = productsMap.get(ulParts[1].Part_To_Be_Decremented__c).Description
		));		
		
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulParts[0].Name,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 10, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulParts[0].Name).Id, Part_Number__c = productsMap.get(ulParts[0].Name).APN_Number__c, Description__c = productsMap.get(ulParts[0].Name).Description
		));	
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulParts[1].Name,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 10, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulParts[1].Name).Id, Part_Number__c = productsMap.get(ulParts[1].Name).APN_Number__c, Description__c = productsMap.get(ulParts[1].Name).Description
		));	
		Insert 	snapshotRecords;
		
		Test.StartTest();
		LicenseSnapshotUtil.performPurchaseUpgrades((String)testAccount.Id);
		Test.stopTest();
				
    }
    //performPurchaseUpgrades
}