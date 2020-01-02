/***************************************************************************************************
* 
*  Class Name      :   DSRDesignOverviewCtlr
*  Description     :   This class is used to control the Design Page Overview (SC_Engagement_Design_Overview)
*  Auther          :   R Systems
* 
****************************************************************************************************/
public with sharing class DSRDesignOverviewCtlr {
    
    public DSR_SCE_Design__c dsrDesign{get;set;}
    public Map<String, Integer> mapBusinessDesign{get;set;}
    public Map<String, Integer> mapTechnicalDesign{get;set;}
    public Map<string,string>map_DesignLinks{get;set;}
    public Integer useCaseCount {get; set;}
    public Integer blueprintCount {get; set;}    // Added by Ashish (10/31/2018), on request of Debbie to add the count of blueprint.
    
    public DSRDesignOverviewCtlr(){
        Id designId = apexpages.currentpage().getparameters().get('id');
        useCaseCount = 0;
        blueprintCount = 0;        // Added by Ashish (10/31/2018), on request of Debbie to add the count of blueprint.
        mapBusinessDesign = new Map<String, Integer>();
        mapTechnicalDesign = new Map<String, Integer>();
         
         /*Notes__c*/
        List<DSR_SCE_Design__c> lstDSRSCEDesign =  [Select  Id, 
                                                            Notes__c, 
                                                            Name,
                                                            Name__c,
                                                            Design_Source__c,
                                                            DSR_SCEngagement__c,
                                                            IsPrimary__c,
                                                            OfferingPlatformType__c,
                                                            PrimaryDesign__c,
                                                            DSR_SCEngagement__r.Name,
                                                            DSR_SCEngagement__r.Account_ID__c,
                                                            DSR_SCEngagement__r.Account_ID__r.Name,
                                                            DSR_SCEngagement__r.Opportunity_ID__c,
                                                            DSR_SCEngagement__r.Opportunity_ID__r.Name,
                                                            DSR_SCEngagement__r.Opportunity_ID__r.Primary_Line_of_Business__c,
                                                            DSR_SCEngagement__r.Opportunity_ID__r.Lines_of_Businesses__c,
                                                            DSR_SCEngagement__r.Opportunity_ID__r.Stagename,
                                                            DSR_SCEngagement__r.Opportunity_ID__r.Lead_Offer__c,
                                                            CreatedDate,
                                                            LastmodifiedDate,
                                                            CreatedById,
                                                            LastModifiedById,
                                                            CreatedBy.Name,
                                                            LastModifiedBy.Name,
                                                            DataCenters__c,
                                                            HAType__c, DSR_SCEngagement__r.Is_Partner_DSR__c,
                                                            (SELECT Id FROM DSR_Use_Case_Blueprints__r WHERE Type__c = 'Use Case') 
                                                            from DSR_SCE_Design__c 
                                                            where Id= : designId];
        
        if(lstDSRSCEDesign.size() > 0){
            dsrDesign = lstDSRSCEDesign[0];
            useCaseCount = dsrDesign.DSR_Use_Case_Blueprints__r.size();
        }
        
        // Added by Ashish (10/31/2018), on request of Debbie to add the count of blueprint.
        List<DSR_Use_Case_Blueprints__c> list_BluePrint = new List<DSR_Use_Case_Blueprints__c>([SELECT Id FROM DSR_Use_Case_Blueprints__c WHERE Type__c = 'Blueprint' AND DSRSCEDesign__c = : designId]);
        blueprintCount = list_BluePrint.size();
        
        if(designId != null){
            //List<DSR_Activity__c> lstBusiness = [Select id,Header__c,SubModule__c from DSR_Activity__c where DSRSCEDesign__c =: designId and Header__c != null];
            List<DSR_Attachments__c> lstBusiness = [Select id,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,Description__c,DSRSCEngagement__c,Notes__c,Source__c,ObjectType__c from DSR_Attachments__c where DSRSCEDesign__c =: designId and AttachmentType__c != null];                       
            
            for(DSR_Attachments__c dsr : lstBusiness){
                if(dsr.ObjectType__c.contains('Technical Design')){
                   if(mapTechnicalDesign.containskey(dsr.AttachmentType__c)){
                        Integer i = mapTechnicalDesign.get(dsr.AttachmentType__c);
                        i++;
                        mapTechnicalDesign.put(dsr.AttachmentType__c, i);
                   }else{
                        Integer i = 0;
                        i++;
                        mapTechnicalDesign.put(dsr.AttachmentType__c, i);
                   }
                }else{
                    if(mapBusinessDesign.containskey(dsr.AttachmentType__c)){
                        Integer i = 0;
                        i = mapBusinessDesign.get(dsr.AttachmentType__c);
                        i++;
                        mapBusinessDesign.put(dsr.AttachmentType__c, i);
                   }else{
                        Integer i = 0;
                        i++;
                        mapBusinessDesign.put(dsr.AttachmentType__c, i);
                   }
                }
            }
        }
        
        /*Design Link*/
        List<DSRDataDefinition__c>list_shortCode = [Select id,Header__c,SubModule__c,FitCategory__c,URL__c from DSRDataDefinition__c where Module__c =: 'Design'];
        map_DesignLinks = new Map<string,string>();
        for(DSRDataDefinition__c obj:list_shortCode)
        {
          if(obj.SubModule__c == 'Design Link')
           {
             map_DesignLinks.put(obj.Header__c,obj.URL__c);
           }
        }
    }
    public PageReference BusinessPage(){
        PageReference pr = new PageReference('/apex/SC_Engagement_Design_Business?id='+dsrDesign.id+'');
        pr.setRedirect(true);
        return pr;
    }
    public PageReference TechnicalPage(){
        PageReference pr = new PageReference('/apex/SC_Engagement_Design_Technical?id='+dsrDesign.id+'');
        pr.setRedirect(true);
        return pr;
    }
}