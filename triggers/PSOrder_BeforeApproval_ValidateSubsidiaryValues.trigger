/**********************************************************************************
** Purpose: Validation trigger which checks the Order Sold To Subsidiary value 
** against the Opportunity PS Subsidiary Override value (if specified) or the 
** Opportunity Sold To Subsidiary value before allowing the Order to be approved.
**
** Project: PS RevPro
** Author: Alex H
** Date: 28-Oct-2019
** Unit Test: Order_ValidateSubsidiaryValsTriggerTest
**
** This trigger applies to PS ORDERS ONLY and is valid for the following scenarios:
**
** 1) PS Opp Sold To Subsidiary = xxxx 
**    PS Opp Subsidiary Override = null
**    PS Order Sold To Subsidiary = xxxx
**    --> Opp Sold To Subsidiary = Order Sold To Subsidiary, so approval
**        is allowed to occur
**
** 2) PS Opp Sold To Subsidiary = xxxx
**    PS Opp Subsidiary Override = yyyy
**    PS Order Sold To Subsidiary = yyyy
**    --> Opp Subsidiary Override = Order Sold To Subsidiary, so approval
**        is allowed to occur
**
** 3) PS Opp Sold To Subsidiary = xxxx
**    PS Opp Subsidiary Override = null
**    PS Order Sold To Subsidiary = yyyy
**    --> Opp Sold To Subsidiary != Order Sold To Subsidiary, so error is
**        added and approval is disallowed
**
** 4) PS Opp Sold To Subsidiary = xxxx
**    PS Opp Subsidiary Override = yyyy
**    PS Order Sold To Subsidiary = xxxx
**    --> Opp Subsidiary Override != Order Sold To Subsidiary, so error is
**        added and approval is disallowed
**
***********************************************************************************/

trigger PSOrder_BeforeApproval_ValidateSubsidiaryValues on Order__c (before update) {
  if(Util.Bypass_Trigger_Chk)return;
  
  Id PSOrderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PS Orders').getRecordTypeId();
  Id PSMasterOrderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PS Orders Master').getRecordTypeId();
  
  Map<Id, Order__c> objMap = new Map<Id, Order__c>([
    Select Id, Opportunity__r.BusinessPartner__r.Subsidary__r.Name, Opportunity__r.PS_Subsidiary_Override__c
    From Order__c
    Where Id in : Trigger.new
  ]);
  
  for(Order__c o: Trigger.new)
  {
    System.Debug('******** Checking Order ID: ' + o.recordtypeid + ', License FYM Detail: ' + o.License_FYM_detail__c + ', Status: ' + o.status__c);
    if((o.recordtypeid == PSOrderRecordTypeId || o.recordtypeid == PSMasterOrderRecordTypeID || o.License_FYM_detail__c == 'PS Orders')
        && o.status__c == 'Approved')
    {
      // Check that the PS Order subsidiary value matches the PS Opp subsidiary override value if
      // if was specified.  If the override value was not specified, check that the order subsidiary
      // value matches the opp subsidiary value.  If the order subsidiary matches neither opportunity
      // subsidiary value, then we must add the error to prevent the order from being approved.
      System.Debug('******** Order Sold To Subsidiary: ' + o.Sold_To_Subsidiary__c + ', Opportunity Sold To Subsidiary: ' + objMap.get(o.Id).Opportunity__r.BusinessPartner__r.Subsidary__r.Name + ', Opportunity PS Subsidiary Override: ' + objMap.get(o.Id).Opportunity__r.PS_Subsidiary_Override__c);
      if(objMap.get(o.Id).Opportunity__r.PS_Subsidiary_Override__c != null)
      {
        // subsidiary override is specified, so we need to match to it
        if(o.Sold_To_Subsidiary__c != objMap.get(o.Id).Opportunity__r.PS_Subsidiary_Override__c)
        {
          // order subsidiary doesn't match the opportunity subsidiary override, so
          // we need to add an error to the order and prevent the order from being approved
          o.AddError('Order cannot be approved because the Sold To Subsidiary [' + o.Sold_To_Subsidiary__c + '] does not match the Opportunity PS Subsidiary Override [' + objMap.get(o.Id).Opportunity__r.PS_Subsidiary_Override__c + ']');
        }
      }
      else
      {
        // subsidiary override is not specified, so we need to match to the sold to subsidiary
        if(o.Sold_To_Subsidiary__c != objMap.get(o.Id).Opportunity__r.BusinessPartner__r.Subsidary__r.Name)
        {
          // order subsidiary doesn't match the opportunity sold to subsidiary, so
          // we need to add an error to the order and prevent the order from being approved
          o.AddError('Order cannot be approved because the Sold To Subsidiary [' + o.Sold_To_Subsidiary__c + '] does not match the Opportunity Sold To Subsidiary [' + objMap.get(o.Id).Opportunity__r.BusinessPartner__r.Subsidary__r.Name + ']');
        }
      }
    }
  }
}