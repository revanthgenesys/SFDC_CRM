/************************************************************************************
Purpose : Controller class redirect user to the correct page by case Recor Type
Written By : Mariya Steason
Test Classes : CaseSelectRecordType_Test
Business Areas affected: Customer Support internal app
*************************************************************************************/
public without sharing class CaseSelectRecordType {
      
    private Map<String, Id> casetypesMap;

    public CaseSelectRecordType(ApexPages.StandardController stdCon)  {
          
          casetypesMap = new Map<String, Id>();
          List<RecordType> caseTypeLst = CaseUtil.getAllTScaseTypes();
          if ( !caseTypeLst.isEmpty() ) {
              for ( RecordType rt : caseTypeLst ) 
                  casetypesMap.put( rt.DeveloperName, rt.Id );
          }
    }   
        
    public pageReference premSupportType()  {
          return new PageReference('/apex/CasePremiseContactProductSelection?RecordType=' + casetypesMap.get('Genesys_Product_Case'));
    }
    
    public pageReference premFRType() {
          return new PageReference('/apex/CasePremiseContactProductSelection?RecordType=' + casetypesMap.get('Genesys_Feature_Request_Case'));
    }
    
    public pageReference premMacType() {
        return new PageReference('/apex/CasePremiseContactProductSelection?RecordType=' + casetypesMap.get('Premises_Service_Request'));        
    }
       
    public pageReference cloudSupportType() {
          return new PageReference('/apex/CaseCloudDeplProductSelection?RecordType=' + casetypesMap.get('Genesys_Cloud_Support_Request'));
    }
    
    public pageReference cloudServiceType() {
         return new PageReference('/apex/CaseCloudDeplProductSelection?RecordType=' + casetypesMap.get('Genesys_Cloud_Service_Request'));
    }
    
    public pageReference cloudIncidentType() {
         return new PageReference('/apex/CaseCloudDeplProductSelection?RecordType=' + casetypesMap.get('Genesys_Cloud_Incident'));
    }
        
   public pageReference cloudFRType() {
         return new PageReference('/apex/CaseCloudDeplProductSelection?RecordType=' + casetypesMap.get('Genesys_Cloud_Feature_Request'));
    }
    
    public pageReference adminType() {
        return new PageReference('/500/e?RecordType=' + casetypesMap.get('Genesys_Admin_Case') + '&nooverride=1');       
    }
       
}