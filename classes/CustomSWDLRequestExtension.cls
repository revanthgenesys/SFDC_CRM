public with sharing class CustomSWDLRequestExtension {
    private final Custom_SWDL_Request__c objCustomSWDL;
    public Boolean isEditPage {get; set;}

    public CustomSWDLRequestExtension(ApexPages.StandardController controller) 
    {
        this.objCustomSWDL=(Custom_SWDL_Request__c)controller.getrecord();
        String idd = ApexPages.currentPage().getParameters().get('id');
        if(idd != null) {
            isEditPage = true;
        } else {
            isEditPage = false;
        }
    }
    
    public pageReference saveAndNew(){
        try{
            upsert objCustomSWDL;
            string url = '/' + ('' + objCustomSWDL.get('Id')).subString(0, 3) + '/e?retURL=' + objCustomSWDL.get('Id');
            return new Pagereference(url);
            
        } catch (System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
    }
}