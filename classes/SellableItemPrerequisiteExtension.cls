/* SellableItemPrerequisiteExtension
   A. Haun  Dec 2016
   Loads the Prerequisites for the owning Sellable Item - Product.
   Use with the SellableItemPrerequisites VF page, which is to be displayed on the Sellable Item - Product.
   
   This class corresponds to GenesysProductPrerequisiteExtension, which should be kept up-to-date
   with this one due to integrations.
 */
 public class SellableItemPrerequisiteExtension {
   public final Sellable_Item_Product__c si {get;set;}
   public transient List<Sellable_Item_Product_Prerequisite__c> mprereqs {get;set;} // List of mandatory prereqs
   public transient List<Sellable_Item_Product_Prerequisite__c> cprereqs {get;set;} // List of conditional prereqs
   public transient Sellable_Item_Product__c msitem {get;set;}                      // Info for master sellable item
   
   public SellableItemPrerequisiteExtension(ApexPages.StandardController stdController) {
     this.si = (Sellable_Item_Product__c)stdController.getRecord();
     // need to grab the name of the item for the VF page
     msitem = [select id, name
               from Sellable_Item_Product__c
               where (id=:si.id)];
     // build the prerequisites lists
     getMandatoryPrerequisites();
     getConditionalPrerequisites();
   }
   
   public List<Sellable_Item_Product_Prerequisite__c> getMandatoryPrerequisites() {
     mprereqs = [select id, Sellable_Item_Product_Master__c, Part_Number__c, Prerequisite_Product__c, Prerequisite_Product_Name__c, Base_Item__c, Supported_Versions__c, Ratios__c, Prerequisite_has_prerequisites__c, Notes__c
                 from Sellable_Item_Product_Prerequisite__c
                 where (Sellable_Item_Product_Master__c=:si.id  AND Prerequisite_Product__c!=null AND Mandatory__c=:true)];
                
     if(mprereqs.isEmpty())
       return null;
     else
       return mprereqs;
   }
   
   public List<Sellable_Item_Product_Prerequisite__c> getConditionalPrerequisites() {
     cprereqs = [select id, Sellable_Item_Product_Master__c, Part_Number__c, Prerequisite_Product__c, Prerequisite_Product_Name__c, Base_Item__c, Supported_Versions__c, Ratios__c, Prerequisite_has_prerequisites__c, Notes__c
                 from Sellable_Item_Product_Prerequisite__c
                 where (Sellable_Item_Product_Master__c=:si.id  AND Prerequisite_Product__c!=null AND Mandatory__c=:false)];
                 
     if(cprereqs.isEmpty())
       return null;
     else
       return cprereqs;
   }
 }