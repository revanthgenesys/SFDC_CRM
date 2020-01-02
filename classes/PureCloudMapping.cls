public class PureCloudMapping {
 @InvocableMethod
    public static void OnCreationPureCloudEnablement(List<Id> PCEnablementId) 
    {
        system.debug('+++PCEnablementId+++'+PCEnablementId);
        string sObjectAPINAme = findObjectAPIName(PCEnablementId[0]);
        
        system.debug('+++sObjectAPINAme+++'+sObjectAPINAme);
        
        //PureCloud Enablement
        if(sObjectAPINAme  == 'SourceOpportunities__c')
        {
           
            List<SourceOpportunities__c>list_PCEnablement = [Select id,Opportunity__c from SourceOpportunities__c where SourceOpportunities__c.id IN : PCEnablementId ];
            
            List<PureCloud_Trial__c>list_PCProject = new List<PureCloud_Trial__c>();
            list_PCProject = [Select id,Opportunity_PureCloud_Enablement__c,Opportunity__c from PureCloud_Trial__c where Opportunity__c =: list_PCEnablement[0].Opportunity__c];
            if(list_PCProject != null && list_PCProject.size()>0)
            {
              for(PureCloud_Trial__c objPCPrj : list_PCProject)
              {
                 //system.debug('+++list_PCProject +++'+list_PCProject );
                 objPCPrj.Opportunity_PureCloud_Enablement__c = list_PCEnablement[0].id;
              }
              update list_PCProject;
            }
         }
        
         //PureCloud Project
         if(sObjectAPINAme  == 'PureCloud_Trial__c')   
           OnCreationPureCloudProject(PCEnablementId);
    }
    
  
    public static void OnCreationPureCloudProject(List<Id> PCProjectId) 
    {
       system.debug('+++PCProjectId+++'+PCProjectId);
        List<PureCloud_Trial__c>list_PCProject = [Select id,Opportunity__c,Opportunity_PureCloud_Enablement__c from PureCloud_Trial__c where PureCloud_Trial__c.id IN : PCProjectId];
        
        List<SourceOpportunities__c>list_PCEnablement = new List<SourceOpportunities__c>();
        list_PCEnablement = [Select id,Opportunity__c from SourceOpportunities__c where Opportunity__c =: list_PCProject [0].Opportunity__c  order by LastModifieddate desc limit 1];
        if(list_PCEnablement != null && list_PCEnablement.size()>0)
        {
           system.debug('+++list_PCEnablement +++'+list_PCEnablement );
          list_PCProject[0].Opportunity_PureCloud_Enablement__c = list_PCEnablement[0].id;
          update list_PCProject;
        }
        
    }
    
     public static string findObjectAPIName( String recordId ){
        if(recordId == null)
            return null;
        String objectAPIName = '';
        string keyPrefix = recordId.substring(0,3);
         for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
              String prefix = obj.getDescribe().getKeyPrefix();
              if(prefix!=null){
               if(Pattern.matches(keyPrefix, prefix)){
                         objectAPIName = obj.getDescribe().getName();
                          break;
                }
              }  
         }
         return objectAPIName;
}
}