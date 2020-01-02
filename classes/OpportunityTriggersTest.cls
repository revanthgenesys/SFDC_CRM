@isTest(SeeAllData=true)
// ------------------------------------------------------------------------------
// TEST: OpportunityTriggersTest
// PURPOSE: Tests the Opportunity class triggers.
// AUTHOR: A. Haun
// ------------------------------------------------------------------------------
public class OpportunityTriggersTest {

  // -----------------------------------------------------------------------------
  // SETUP
  static void setup() 
  {
    System.debug('############################################################################################ Creating test opportunity');
    List<Opportunity> oppts = TestUtil.createOpportunities(1, true);
    System.AssertEquals(1, oppts.size());
  }

  // -----------------------------------------------------------------------------
  // TEST METHOD: validateOppPOBTypeTrigger
  // PURPOSE: Create Opportunity record(s) and validate that records were 
  //          properly created.  Then, update the record and validate that the 
  //          update triggers properly executed.
  static testMethod void validateOppPOBTypeTrigger() 
  {
    setup();
    
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
    
    List<Opportunity> oppts = [SELECT Name, Id, RecordTypeId, CurrencyIsoCode
                                               FROM Opportunity
                                               WHERE Name =: 'Test Opp' AND OwnerId =: thisUser.Id];

    List<RecordType> recType = [SELECT DeveloperName, Id 
                                                    FROM RecordType
                                                    WHERE DeveloperName =: 'Professional_Services'];

    List<Pricebook2> pBook = [SELECT Id, Name
                                                FROM Pricebook2
                                                WHERE Name =: 'Professional Services'];
  
    List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                                         FROM PriceBookEntry
                                                         WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];

    System.AssertEquals(1, oppts.size(), 'The expected number of test opportunities was not created in the setup method.');
    System.AssertEquals(1, recType.size(), 'The Professional Services record type was not found.');

    // Start test
    System.debug('############################################################################################ Testing creation of Opp records');
    Test.startTest();

    oppts[0].CurrencyIsoCode = 'USD';
    oppts[0].RecordTypeId = recType[0].Id;  // set PS record type
    oppts[0].PriceBook2Id = pBook[0].Id;     // set PS price book
    oppts[0].ProjectType__c = 'Time Billing';
    oppts[0].Direct_Sales__c = true;
    oppts[0]. PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
    update oppts;

    OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=oppts[0].Id, PriceBookEntryId=pbEntry[0].Id, Quantity=2, UnitPrice=1000);
    insert oli;

     oli = [SELECT OpportunityId, POB_Type__c
            FROM OpportunityLineItem
            WHERE OpportunityId =: oppts[0].Id];

    System.AssertNotEquals(null, oli.POB_Type__c, 'The POB Type was not calculated when the Opportunity Product was created.');

    oppts[0].ProjectType__c = 'Fixed Price';
    update oppts;

    oli = [SELECT OpportunityId, POB_Type__c
            FROM OpportunityLineItem
            WHERE OpportunityId =: oppts[0].Id];

    System.AssertNotEquals(null, oli.POB_Type__c, 'The POB Type was not calculated when the Opportunity Project Type changed.');

    Test.stopTest();
  }
}