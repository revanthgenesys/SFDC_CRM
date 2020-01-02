/**
Raghu R  : 1/31/2014: MDM Projct :  Test class for the class MDMSearch to search accounts in MDM.
 */
@isTest(SeeAllData=true)
private class searchAccounts_Test {
    
    static testMethod void accountSearch() {
        

     Country__c cntry = [select id,Name from Country__c where name =: 'Japan'];
     
     List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'EMGBusinessPartnerRecordType'];
          
     Account testAccount = TestUtil.createAccounts(1, true)[0];    
     testAccount.Subsidary__c = Global_Setting__c.getInstance('Japan').Id__c;
     testAccount.Country__c = cntry.id; 
     testAccount.Name = 'Test Name';
     testAccount.City__c = 'Test City';
     testAccount.recordtypeId = rectp[0].Id;
     testAccount.status__c = 'Active';
     update testAccount;
   
     PageReference pageRef = page.MdmSearch;
     Test.setCurrentPage(pageRef);

     ApexPages.StandardController sc = new ApexPages.standardController(testAccount);                
     searchAccounts controller = new searchAccounts(sc); 
     searchAccounts.Acc objAcc= new searchAccounts.Acc();
     
     searchAccounts objSearchAcc= new searchAccounts(); 
     
     
     ApexPages.currentPage().getParameters().put('MDId','12345');
     ApexPages.currentPage().getParameters().put('SalesforceId', testAccount.id);
     ApexPages.currentPage().getParameters().put('recordtype', rectp[0].id);
      
     //String query = '<MdmQueryRequest limit="200"><Filter><matchrule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="GroupingRule" operator="AND"><nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH"><input xsi:type="StaticRuleInput" value="Test Name"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="ACCOUNT_NAME"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput" value="Japan"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="COUNTRY"/></nestedExpression><nestedExpression xsi:type="GroupingRule " operator="OR"><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8100"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8110"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8325"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8420"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH"><input xsi:type="StaticRuleInput" value="Test City"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="PRIMARY_CITY"/></nestedExpression></matchrule></Filter></MdmQueryRequest>';
     //     String query = '<?xml version="1.0" encoding="utf-8"?><mdm:RecordQueryRequest xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200"><mdm:filter><mdm:expression xsi:type="mdm:GroupingExpression" operator="AND"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH"><mdm:argument>Test Name</mdm:argument></mdm:nestedExpression><mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8100</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8110</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8325</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8420</mdm:argument></mdm:nestedExpression></mdm:Expression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH"><mdm:argument>Test City</mdm:argument></mdm:nestedExpression> </mdm:expression></mdm:filter></mdm:RecordQueryRequest><mdm:RecordQueryResponse xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200"><mdm:filter><mdm:expression xsi:type="mdm:GroupingExpression" operator="AND"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH"><mdm:argument>Test Name</mdm:argument></mdm:nestedExpression><mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8100</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8110</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8325</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8420</mdm:argument></mdm:nestedExpression></mdm:Expression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH"><mdm:argument>Test City</mdm:argument></mdm:nestedExpression> </mdm:expression></mdm:filter></mdm:RecordQueryResponse>';
     String query = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><MdmQueryResponse resultCount="1"><results><customer createddate="02-13-2014T13:53:56.000-0600" grid="37adae10-5b51-48a1-899d-f8a1f4640ada" source="SALESFORCE" updateddate="02-13-2014T15:06:20.000-0600"><id>37adae10-5b51-48a1-899d-f8a1f4640ada</id><genesys_account_reference_number>41286</genesys_account_reference_number><account_name>Wells Fargo Bank</account_name><account_type>Customer</account_type><stage>Confirmed</stage><is_inactive>false</is_inactive><subsidiary>8100</subsidiary><account_owner>LK0079856</account_owner><sales_relationship>Direct</sales_relationship><categories><classification>Unknown</classification><industry>Finance - Banking</industry><key_account_type>Premier Account</key_account_type><region>North America</region><sector>Private</sector><sub_region>#N/A</sub_region><type_of_commerce>Business-to-Consumer</type_of_commerce><vertical>FINANCE AND INSURANCE</vertical></categories><communication><fax>(415) 222-6590</fax><phone>(415) 222-6590</phone></communication><financial><credit_limit>8000000.0</credit_limit><currency>USD</currency><terms>Net 30</terms></financial><primary_address><address_1>455 Market Street 4th Floor</address_1><address_2>MAC A0104-049</address_2><city>SAN FRANCISCO</city><country>United States</country><postal_code>94105</postal_code><state_province>California</state_province></primary_address><references><party>95c87ba0-199a-4b74-aff2-f39f2827808e</party></references></customer></results></MdmQueryResponse>';
         //String query = '<?xml version="1.0" encoding="utf-8"?><mdm:RecordQueryRequest xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200"><mdm:filter><mdm:expression xsi:type="mdm:GroupingExpression" operator="AND"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH"><mdm:argument>Test Name</mdm:argument></mdm:nestedExpression><mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8100</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8110</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8325</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8420</mdm:argument></mdm:nestedExpression></mdm:Expression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH"><mdm:argument>Test City</mdm:argument></mdm:nestedExpression> </mdm:expression></mdm:filter></mdm:RecordQueryRequest><mdm:RecordQueryResponse xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200"><mdm:filter><mdm:expression xsi:type="mdm:GroupingExpression" operator="AND"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH"><mdm:argument>Test Name</mdm:argument></mdm:nestedExpression><mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8100</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8110</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8325</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8420</mdm:argument></mdm:nestedExpression></mdm:Expression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH"><mdm:argument>Test City</mdm:argument></mdm:nestedExpression> </mdm:expression></mdm:filter></mdm:RecordQueryResponse>';
     controller.a1 = testAccount;
     
          test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForAccount());
     
     controller.pageredir();
     controller.dosearch();
     controller.insertAccount();  
     
     searchAccounts.Acc newwrap = new searchAccounts.Acc();
     searchAccounts.acc[] accs = controller.getAccounts(); 
     
     

  
     test.stopTest();
    }
    
    static testMethod void accountSearch2() {        

     Country__c cntry = [select id,Name from Country__c where name =: 'Japan'];
          
     Account testAccount = TestUtil.createAccounts(1, true)[0];    
     testAccount.Subsidary__c = Global_Setting__c.getInstance('Japan').Id__c;
     testAccount.Country__c = cntry.id; 
     testAccount.Name = 'Test Name';
     testAccount.City__c = 'Test City';
     update testAccount;
   
     PageReference pageRef = page.MdmSearch;
     Test.setCurrentPage(pageRef);

     ApexPages.StandardController sc = new ApexPages.standardController(testAccount);                
     searchAccounts controller = new searchAccounts(sc); 
     searchAccounts.Acc objAcc= new searchAccounts.Acc();
     objAcc.name ='testing';
     objAcc.MDId = '12345';
    
     
     
     searchAccounts objSearchAcc= new searchAccounts(); 
     
     List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'EMGBusinessPartnerRecordType'];
     
     ApexPages.currentPage().getParameters().put('MDId','12345');     
     ApexPages.currentPage().getParameters().put('recordtype', rectp[0].id);
   
     //String query = '<MdmQueryRequest limit="200"><Filter><matchrule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="GroupingRule" operator="AND"><nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH"><input xsi:type="StaticRuleInput" value="Test Name"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="ACCOUNT_NAME"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput" value="Japan"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="COUNTRY"/></nestedExpression><nestedExpression xsi:type="GroupingRule " operator="OR"><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8100"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8110"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8325"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="EQUALS"><input xsi:type="StaticRuleInput"  value="8420"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="SALES_CHANNEL"/></nestedExpression></nestedExpression><nestedExpression xsi:type="ExpressionRule" operator="STARTS_WITH"><input xsi:type="StaticRuleInput" value="Test City"/><input xsi:type="UniqueIdRuleInput" type="EXISTING" uniqueId="PRIMARY_CITY"/></nestedExpression></matchrule></Filter></MdmQueryRequest>';
     String query = '<?xml version="1.0" encoding="utf-8"?><mdm:RecordQueryRequest xmlns:mdm="http://mdm.api.platform.boomi.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" limit="200"><mdm:filter><mdm:expression xsi:type="mdm:GroupingExpression" operator="AND"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="account_name"  operator="STARTS_WITH"><mdm:argument>Test Name</mdm:argument></mdm:nestedExpression><mdm:Expression xsi:type="mdm:GroupingExpression" operator="OR"><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8100</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8110</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8325</mdm:argument></mdm:nestedExpression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="subsidiary"  operator="STARTS_WITH"><mdm:argument>8420</mdm:argument></mdm:nestedExpression></mdm:Expression><mdm:nestedExpression xsi:type="mdm:SimpleExpression"  property="primary_address/city"  operator="STARTS_WITH"><mdm:argument>Test City</mdm:argument></mdm:nestedExpression> </mdm:expression></mdm:filter></mdm:RecordQueryRequest>';
     controller.a1 = testAccount;
     
     test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
     controller.addaccountid.add(objAcc);
     controller.pageredir();
     controller.dosearch();
     controller.insertAccount();  
     
     searchAccounts.Acc newwrap = new searchAccounts.Acc();
     //searchAccounts.acc[] accs = controller.getAccounts();
     test.stopTest();
    }
}