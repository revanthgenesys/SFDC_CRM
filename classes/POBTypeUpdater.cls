// ------------------------------------------------------------------------------
// CLASS: POBTypeUpdater
// PURPOSE: Intended to be run manually from the console.  Iterates through the
//          PS Opportunities and PS Orders and attempts to update the POB Type 
//          values for any Opps/Orders that don't have that value set.
//          Used for historical record updates.
// OWNER: PS IT Apps group
// AUTHOR: A. Haun
// ------------------------------------------------------------------------------
public class POBTypeUpdater
{
  private List<PS_Opportunity_Product_POB_Type_Mapping__c> MappingList { set; get; }
  private Map<string, string> pobMap { set; get; }
  
  // -----------------------------------------------------------------------------
  // CONSTRUCTOR
  public POBTypeUpdater()
  {
    System.debug('*** POBTypeUpdater: Constructor.');
    // Acquire the POB mapping from the custom setting
    MappingList = [SELECT Product_POB_Type__c, Opportunity_Project_Type__c, Opportunity_Product_POB_Type__c
                   FROM PS_Opportunity_Product_POB_Type_Mapping__c];
    if(MappingList.size() == 0)
      System.debug('*** POBTypeUpdater: The POB mapping custom setting has not been populated.  Will not be able to map POB Type.');
    else
    {
      pobMap = new Map<string, string>();

      for(PS_Opportunity_Product_POB_Type_Mapping__c opm : MappingList)
      {
        System.debug('*** POBTypeUpdater: putting ' + opm.Product_POB_Type__c + ' :: ' + opm.Opportunity_Project_Type__c + ', ' + opm.Opportunity_Product_POB_Type__c);
        pobMap.put(opm.Product_POB_Type__c + ' :: ' + opm.Opportunity_Project_Type__c, opm.Opportunity_Product_POB_Type__c);
      }
      if(pobMap.size() == 0)
        System.debug('*** POBTypeUpdater: The POB mapping custom setting has not been populated.  Will not be able to map POB Type.');
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
    System.debug('*** POBTypeUpdater: MapPOBType(' + ProdPOBType + ', ' + OppProjectType + ').');
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
    System.debug('*** POBTypeUpdater: pob is ' + pob);
    return pob;
  }
  
  // -----------------------------------------------------------------------------
  // Update the mappings for any Opportunity Products (Opportunity Line Items)
  // attached to the (Professional Services) opportunities that have a missing 
  // POB Type.
  public List<OpportunityLineItem> UpdatePSOpportunityLineItemPOBTypes(Set<OpportunityLineItem> setOLI)
  {
    System.debug('*** POBTypeUpdater: Updating PS Opportunity Line Items.');
    Set<Id> setOpptIds = new Set<Id>();
    Set<Id> setPBEntryIds = new Set<Id>();
    Set<Id> setProdIds = new Set<Id>();
    
    if(setOLI == null)
    {
      // Query for PS Opportunity Line Item records that do NOT have a POB Type
      // value set.  For each of those items, map a POB Type value based on the
      // Product POB Type and Opportunity Project Type.
      setOLI = new Set<OpportunityLineItem>(
        [SELECT Id, OpportunityId, PricebookEntryId, POB_Type__c, Product_POB_Type__c
         FROM OpportunityLineItem
         WHERE Opportunity.RecordType.DeveloperName = 'Professional_Services' AND POB_Type__c = ''
         LIMIT 3000]);
    }
         
    for(OpportunityLineItem oli : setOLI)
    {
      setOpptIds.add(oli.OpportunityId);
      setPBEntryIds.add(oli.PricebookEntryId);
    }
    
    Map<Id,Opportunity> mapOppt = new Map<Id,Opportunity>([SELECT Id, RecordType.DeveloperName, ProjectType__c FROM Opportunity WHERE Id IN :setOpptIds]);
    Map<Id,PricebookEntry> mapPBE = new Map<Id,PricebookEntry>([SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :setPBEntryIds]);
    
    for(PricebookEntry pbe : mapPBE.values())
    {
      setProdIds.add(pbe.Product2Id);
    }
    
    Map<Id,Product2> mapProd = new Map<Id,Product2>([SELECT Id, POB_Type__c FROM Product2 WHERE Id IN :setProdIds]);
    List<OpportunityLineItem> listUpdatedOLI = new List<OpportunityLineItem>();
    
    // Loop through the available Opportunity Line Items.  If they belong to a
    // PS Opportunity, then use the map to update the POB Type.
    for(OpportunityLineItem oli : setOLI)
    {
      System.debug('*** POBTypeUpdater: Trying to get from maps: opp: ' + oli.OpportunityId + ', pbe: ' + oli.PricebookEntryId);
      Opportunity opp = mapOppt.get(oli.OpportunityId);
      PricebookEntry pbe = mapPBE.get(oli.PricebookEntryId);
      Product2 prod = mapProd.get(pbe.Product2Id);
      System.debug('*** POBTypeUpdater: Opp ID: ' + opp.Id + ', PBE ID: ' + pbe.Id + ', Prod ID: ' + prod.Id + '.');
      
      System.debug('*** POBTypeUpdater: Check record type: ' + opp.RecordType.DeveloperName + '.');
      if(opp.RecordType.DeveloperName == 'Professional_Services')
      {
        System.debug('*** POBTypeUpdater: Map POB Type for OLI: ' + oli.Id);
        // PS Oppt and OLI does not have a POB Type, so we will attempt to map it.
        System.debug('*** POBTypeUpdater: Get mapped value for: ' + prod.POB_Type__c + ' :: ' + opp.ProjectType__c);
        oli.POB_Type__c = MapPOBType(prod.POB_Type__c, opp.ProjectType__c);
        listUpdatedOLI.add(oli);
        System.debug('*** POBTypeUpdater: POB Type is: ' + oli.POB_Type__c);
      }
      // else, not a PS Oppt, so we will ignore it
    }
    
    update listUpdatedOLI;
    return listUpdatedOLI;
  }

  // -----------------------------------------------------------------------------
  // Update the mappings for any Order Line Items attached to the
  // (Professional Services) orders that have a missing POB Type.
  public List<Order_Line_Item__c> UpdatePSOrderLineItemPOBTypes(Set<Order_Line_Item__c> setOLI)
  {
    System.debug('*** POBTypeUpdater: Updating PS Order Line Items.');
    Set<Id> setOpptIds = new Set<Id>();

    if(setOLI == null)
    {
      // Query for PS Order Line Item records that do NOT have a POB Type
      // value set.  For each of those items, map a POB Type value based on the
      // Product POB Type and Opportunity Project Type.
      setOLI = new Set<Order_Line_Item__c>(
        [SELECT Id, Order__c, Order__r.Opportunity__c, POB_Type__c, Product_POB_Type_tmp__c
         FROM Order_Line_Item__c
         WHERE Order__r.Opportunity__r.RecordType.DeveloperName = 'Professional_Services' AND POB_Type__c = ''
         LIMIT 3000]);
    }
    
    // Order Line Items
    //   -- get Order IDs, pull Orders
    //       -- get Opportunity IDs, pull Opportunities (for Project Type)
    //   -- get Product IDs, pull Products (for Product POB Type)
    for(Order_Line_Item__c oli : setOLI)
    {
      setOpptIds.add(oli.Order__r.Opportunity__c);
    }
    
    Map<Id, Opportunity> mapOppt = new Map<Id, Opportunity>([SELECT Id, RecordType.DeveloperName, ProjectType__c FROM Opportunity WHERE Id IN :setOpptIds]);
    List<Order_Line_Item__c> listUpdatedOLI = new List<Order_Line_Item__c>();
    
    // Loop through the available Order Line Items.  If they belong to a
    // PS Opportunity, then use the map to update the POB Type.
    for(Order_Line_Item__c oli : setOLI)
    {
      System.debug('*** POBTypeUpdater: Trying to get from map: opp: ' + oli.Order__r.Opportunity__c);
      Opportunity opp = mapOppt.get(oli.Order__r.Opportunity__c);
      System.debug('*** POBTypeUpdater: Opp ID: ' + opp.Id);
      
      System.debug('*** POBTypeUpdater: Check record type: ' + opp.RecordType.DeveloperName + '.');
      if(opp.RecordType.DeveloperName == 'Professional_Services')
      {
        System.debug('*** POBTypeUpdater: Map POB Type for Order LI: ' + oli.Id);
        // PS Oppt and OLI does not have a POB Type, so we will attempt to map it.
        System.debug('*** POBTypeUpdater: Get mapped value for: ' + oli.Product_POB_Type_tmp__c + ' :: ' + opp.ProjectType__c);
        oli.POB_Type__c = MapPOBType(oli.Product_POB_Type_tmp__c, opp.ProjectType__c);
        listUpdatedOLI.add(oli);
        System.debug('*** POBTypeUpdater: POB Type is: ' + oli.POB_Type__c);
      }
      // else, not a PS Oppt, so we will ignore it
    }
    
    update listUpdatedOLI;
    return listUpdatedOLI;
  }
}