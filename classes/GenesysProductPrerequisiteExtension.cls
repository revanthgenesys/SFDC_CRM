/* GenesysProductPrerequisiteExtension
   A. Haun Dec 2016
   Loads the Prerequisites for the owning Genesys Product.
   Use with the GenesysProductPrerequisites VF page, which is to be displayed on the Genesys Product.
   
   This class corresponds to SellableItemPrerequisiteExtension.  This class should be kept up-to-date
   with that one due to integration.
 */
public class GenesysProductPrerequisiteExtension {
  public final Product2 gp {get; set;}
  public transient List<Genesys_Product_Prerequisite__c> mprereqs {get; set;} // List of mandatory prereqs
  public transient List<Genesys_Product_Prerequisite__c> cprereqs {get; set;} // List of conditional prereqs
  public transient Product2 mgp {get; set;}                                   // Info for master product
 
  public GenesysProductPrerequisiteExtension(ApexPages.StandardController stdController) {
    this.gp = (Product2)stdController.getRecord();
    // build the prerequisites lists
    getMandatoryPrerequisites();
    getConditionalPrerequisites();
  }
  
  public List<Genesys_Product_Prerequisite__c> getMandatoryPrerequisites() {
    mprereqs = [select id, Genesys_Product_Master__c, Part_Number__c, Prerequisite_Product__c, Prerequisite_Product_Name__c, Supported_Versions__c, Ratios__c, Prerequisite_has_prerequisites__c, Notes__c
                from Genesys_Product_Prerequisite__c
                where (Genesys_Product_Master__c=:gp.id AND Prerequisite_Product__c!=null AND Mandatory__c=:true)];
    if(mprereqs.isEmpty())
      return null;
    else
      return mprereqs;
  }
  
  public List<Genesys_Product_Prerequisite__c> getConditionalPrerequisites() {
    cprereqs = [select id, Genesys_Product_Master__c, Part_Number__c, Prerequisite_Product__c, Prerequisite_Product_Name__c, Supported_Versions__c, Ratios__c, Prerequisite_has_prerequisites__c, Notes__c
                from Genesys_Product_Prerequisite__c
                where (Genesys_Product_Master__c=:gp.id AND Prerequisite_Product__c!=null AND Mandatory__c=:false)];
    if(cprereqs.isEmpty())
      return null;
    else
      return cprereqs;
  }
}