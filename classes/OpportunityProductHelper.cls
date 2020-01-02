// ------------------------------------------------------------------------------
// CLASS: OpportunityProductHelper
// PURPOSE: Aids the Opportunity Product main trigger to determine the POB Type values.
// AUTHOR: A. Haun
// ------------------------------------------------------------------------------
public class OpportunityProductHelper
{
  private List<PS_Opportunity_Product_POB_Type_Mapping__c> MappingList { set; get; }
  private Map<string, string> pobMap { set; get; }

  // -----------------------------------------------------------------------------
  // CONSTRUCTOR
  public OpportunityProductHelper()
  {
    System.debug('*** OpportunityProductHelper: Constructor.');
    // Acquire the POB mapping from the custom setting
    MappingList = [SELECT Product_POB_Type__c, Opportunity_Project_Type__c, Opportunity_Product_POB_Type__c
                            FROM PS_Opportunity_Product_POB_Type_Mapping__c];
    if(MappingList.size() == 0)
      System.debug('*** OpportunityProductHelper: The POB mapping custom setting has not been populated.  Will not be able to map Opportunity Product POB Type.');
    else
    {
      pobMap = new Map<string, string>();

      for(PS_Opportunity_Product_POB_Type_Mapping__c opm : MappingList)
      {
        System.debug('*** OpportunityProductHelper: putting ' + opm.Product_POB_Type__c + ' :: ' + opm.Opportunity_Project_Type__c + ', ' + opm.Opportunity_Product_POB_Type__c);
        pobMap.put(opm.Product_POB_Type__c + ' :: ' + opm.Opportunity_Project_Type__c, opm.Opportunity_Product_POB_Type__c);
      }
      if(pobMap.size() == 0)
        System.debug('*** OpportunityProductHelper: The POB mapping custom setting has not been populated.  Will not be able to map Opportunity Product POB Type.');
    }
  }

  // -----------------------------------------------------------------------------
  // Check the mapping against the specified values to see if the POB Type can be determined.
  public string MapPOBType(string ProdPOBType, string OppProjectType)
  {
    // The map is meant to be for Product POB Type to Opp Product POB Type mapping.  For values 
    // which map Product POB Type directly to the Opp Produt POB Type, the Opp Project Type is 
    // irrelevant and will be null.  Some mappings may require the Product POB Type as well as 
    // the Opp Project Type (such as for PS - Variable Model).  Some mappings may map the 
    // Opp Project Type to POB Type, such as when the Product POB Type has not been
    // specified on the Product (the Oppt Project Type is then required to determine POB Type).
    System.debug('*** OpportunityProductHelper: MapPOBType(' + ProdPOBType + ', ' + OppProjectType + ').');
    // try to get the sub type mapping
    string pob = pobMap.get(ProdPOBType + ' :: ' + null);

    if(pob == null)
    {
      // map not found, check the sub type + project type mapping
      pob = pobMap.get(ProdPOBType + ' :: ' + OppProjectType);
        
      if(pob == null)
      {
        // map not found, check the project type mapping
        pob = pobMap.get(null + ' :: ' + OppProjectType);
        
        if(pob == null)
        {
          // map not found with ProdPOBType, ProdPOBType+OppProjectType, or OppProjectType
          // so set the POB Type to "Error" so we will know to update the mapping
          pob = 'Error';
        }
      }
    }
    System.debug('*** OpportunityProductHelper: pob is ' + pob);
    return pob;
  }
    
  // -----------------------------------------------------------------------------
  // Update the mappings for any Opportunity Products attached to the specified
  // (Professional Services) opportunity.
  // This method will be called by the Opportunityupdate trigger when the Opp 
  // Project Type value has changed on a Professional Services Opp.
  public void UpdateProductPOBTypes(Id OppId, string OppProjectType)
  {
    System.debug('*** OpportunityProductHelper: UpdateProductPOBTypes(' + OppId + ', ' + OppProjectType + ').');
    // Get the list of Opportunity Products attached to the Opp
    List<OpportunityLineItem> oppProds = [SELECT Id, OpportunityId, PricebookEntryId, POB_Type__c
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId =: OppId];
    System.debug('*** OpportunityProductHelper: oppProds.size is ' + oppProds.size());
    if(oppProds.size() == 0)
      return;
      
    for(OpportunityLineItem oli : oppProds)
    {
      PricebookEntry pbe = [SELECT Id, Product2Id 
                            FROM PricebookEntry 
                            WHERE Id =: oli.PricebookEntryId];
      Product2 prod = [SELECT POB_Type__c
                       FROM Product2
                       WHERE Id =: pbe.Product2Id];
      oli.POB_Type__c = MapPOBType(prod.POB_Type__c, OppProjectType);
    }
    update oppProds;
  }
}