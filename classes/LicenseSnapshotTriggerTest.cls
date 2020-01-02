@isTest(seeAllData=true)
public class LicenseSnapshotTriggerTest {
	@isTest
    static void testLicenseSnapshotTrigger(){
		Account testAccount = [Select Id, Name FROM Account WHERE ININ_ID__c != NULL LIMIT 1];
		UL_Upsize_Parts__c ulPart = [SELECT Name, Part_To_Be_Decremented__c, Part_To_Be_Incremented__c FROM UL_Upsize_Parts__c WHERE Name Like 'SW-001-4.0%' LIMIT 1];
		Set<String> productAPNNumbers = new Set<String>();
		productAPNNumbers.add(ulPart.Name);
		productAPNNumbers.add(ulPart.Part_To_Be_Decremented__c);
		productAPNNumbers.add(ulPart.Part_To_Be_Incremented__c);
		
		Map<String, Product2> productsMap = new Map<String, Product2>();
		for(Product2 p: [SELECT Id, APN_Number__c, Description FROM Product2 WHERE APN_Number__c IN :productAPNNumbers]){
			productsMap.put(p.APN_Number__c, p);
		}	
		List<License_Snapshot__c> snapshotRecords = new List<License_Snapshot__c>();
		
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulPart.Part_To_Be_Decremented__c,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 10, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulPart.Part_To_Be_Decremented__c).Id, Part_Number__c = productsMap.get(ulPart.Part_To_Be_Decremented__c).APN_Number__c, Description__c = productsMap.get(ulPart.Part_To_Be_Decremented__c).Description
		));		
		snapshotRecords.add(new License_Snapshot__c(Sold_To__c = testAccount.Id, End_User__c = testAccount.Id, Sold_To_End_User_Part_Number__c = ''+testAccount.Id+''+testAccount.Id+''+ulPart.Name,
			Change_Date__c = Date.today(), 	ProductCategory__c = 'CIC', ProductVersion__c = '4.0', Perpetual__c = 10, Non_Perpetual__c = 0, IsActive__c = true, isMirrored__c = false,
			Product__c = productsMap.get(ulPart.Name).Id, Part_Number__c = productsMap.get(ulPart.Name).APN_Number__c, Description__c = productsMap.get(ulPart.Name).Description
		));	
		
		Test.StartTest();
		Insert snapshotRecords;
		snapshotRecords[0].Perpetual__c = 100;
		snapshotRecords[1].Perpetual__c = 100;
		Update snapshotRecords;
		Test.stopTest();
				
    }
}