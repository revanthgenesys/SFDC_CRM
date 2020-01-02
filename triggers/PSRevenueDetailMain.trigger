// Trigger actions to be performed against the PS Revenue Details object used for RevPro Events from the PSA Tools, associated to opportunities
// Owner          : PS / RevPro
// IT Contact     : Nik Mills
// Last Updated   : 02-Oct-2018


trigger PSRevenueDetailMain on PS_Revenue_Detail__c (before insert, before update) 
{

if(Util.Bypass_Trigger_Chk)
    return;

  // Check if there is a value for the associated opportunity product ID, and if there is set the associated opportunity product name from it
  for (PS_Revenue_Detail__c obj: trigger.new){
      if(obj.Associated_Opportunity_Product_ID__c == NULL || obj.Associated_Opportunity_Product_ID__c == '')
      {
           // No ID has been specified yet so do nothing at the moment
           //System.Debug('NLM Debug>>>> No Opprty Product ID specified');
      }
      else
      {
          // Need to get the opportunity product (line item) name from the ID
          list<OpportunityLineItem> lstOppLI = new list<OpportunityLineItem>
                      ([SELECT id, product2.name, Line_Number__c FROM OpportunityLineItem WHERE Id =: obj.Associated_Opportunity_Product_ID__c]);
          if (!lstOppLI.IsEmpty())
          {
              //System.Debug('NLM Debug>>>> Oppty Product Name is :' + lstOppLI[0].product2.name);            
              obj.Associated_Opportunity_Product_Name__c = lstOppLI[0].product2.name;
              obj.Associated_Opportunity_Product_Line_Num__c = lstOppLI[0].Line_Number__c;
          }
          else
          {
              //System.Debug('NLM Debug>>>> Oppty Product Name not found from ID');
          }
      }
  }

}