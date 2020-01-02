public class GUComplianceRequirementsController {
	
    public List<CS_Partner_Type__c> cspTypesCS {get; set;}
    public List<CS_Partner_Tier__c> cspTiersCS {get; set;}
    public List<CS_Partner_Size__c> cspSizesCS {get; set;}
    public List<CS_Partner_Certification_Group__c> cspCertGroupsCS {get; set;}
    
    // Added By Vijay - Start
    public List<CS_Partner_Offering_Type__c> lst_OfferingTypeCS {get; set;}
    public List<CS_Specialization__c> list_Specializations {get; set;}
    public list<CS_Solution_Group__c> list_SoultionGrp {get; set;}
    // Added By Vijay - End
    
    // All Transactional variable
    public String selectedPartnerType {get; set;}    
    public boolean editMode {get; set;}
    public boolean settingEditMode {get; set;}
    
	public List<selectOption> partnerTypes {get; set;}
    public Map<String, GU_Compliance_Requirement__c> requirementsMap {get; set;}
    public List<GU_Compliance_Requirement__c> requirements {get; set;}
    
    public String selectedTab {get; set;}
    
    public GUComplianceRequirementsController(){
        initializeSetting();
        selectedTab = 'tab1';
        editMode = false;
        settingEditMode = false;
        selectedPartnerType = 'Please Select';
    }
    
    public void initializeSetting(){
        cspTypesCS = [SELECT Id, Name, DisplayOrder__C FROM CS_Partner_Type__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__C];
        cspTiersCS = [SELECT Id, Name, DisplayOrder__C FROM CS_Partner_Tier__c ORDER BY DisplayOrder__C];
        cspSizesCS = [SELECT Id, Name, DisplayOrder__C FROM CS_Partner_Size__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__C];
        list_SoultionGrp = [SELECT Id, Name, DisplayOrder__C FROM CS_Solution_Group__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__C];
        List<CS_Partner_Certification_Group__c> cspCertGroupsCSTemp = [SELECT Id, Name, DisplayOrder__C, Certification_Prefix__c  
                                                                       FROM CS_Partner_Certification_Group__c 
                                                                       WHERE isActive__c = TRUE
                                                                       ORDER BY DisplayOrder__C];
        
        cspCertGroupsCS = new List<CS_Partner_Certification_Group__c>();
        cspCertGroupsCS.add(new CS_Partner_Certification_Group__c(Name='Trained Sales People', DisplayOrder__C=0,Certification_Prefix__c=''));
        cspCertGroupsCS.addAll(cspCertGroupsCSTemp);
        
        lst_OfferingTypeCS = [SELECT Id, Name, DisplayOrder__c, Specialization__c FROM CS_Partner_Offering_Type__c WHERE isActive__c = TRUE ORDER BY DisplayOrder__c];
        list_Specializations = [SELECT Id, Name, Prerequisite__c, Offering_Type__c FROM CS_Specialization__c ORDER BY Offering_Type__c NULLS LAST, Prerequisite__c NULLS FIRST ];
            
        partnerTypes = new List<selectOption>();
        partnerTypes.add(new selectOption('Please Select','Please Select'));
        for(CS_Partner_Type__c ptype : cspTypesCS){
	        partnerTypes.add(new selectOption(ptype.Name,ptype.Name)); 
        }
    }
    
    public PageReference retrieveOrInitializeGUCR(){
        editMode = false;
        requirementsMap = new Map<String, GU_Compliance_Requirement__c>();
        requirements = [SELECT Id, Name, Partner_Type__c, Partner_Tier__c, Partner_Size__c, 
                        Compliance_Requirement__c, Required_Number__c 
                        FROM GU_Compliance_Requirement__c WHERE Partner_Type__c = :selectedPartnerType];
        
        if(requirements.isEmpty()){
             // Initialize GUCR Objects
            for(CS_Partner_Tier__c ptier : cspTiersCS){
                for(CS_Partner_Size__c psize : cspSizesCS){
                    for(CS_Partner_Certification_Group__c pcg : cspCertGroupsCS){
                        requirementsMap.put(selectedPartnerType + ptier.name + psize.name + pcg.name, 
                                            new GU_Compliance_Requirement__c(Partner_Type__c = selectedPartnerType,
                                                                         Partner_Tier__c = ptier.name,
                                                                         Partner_Size__c = psize.name,
                                                                         Compliance_Requirement__c = pcg.name,
                                                                         Required_Number__c = 0 
                                                                         ) );
                    }
                }
            }
        } else {
            // Collect GUCR Objects
            for(GU_Compliance_Requirement__c gucr : requirements){
                requirementsMap.put(gucr.Partner_Type__c + gucr.Partner_Tier__c +  gucr.Partner_Size__c + gucr.Compliance_Requirement__c, gucr);
            }
            
            for(CS_Partner_Tier__c ptier : cspTiersCS){
                for(CS_Partner_Size__c psize : cspSizesCS){
                    for(CS_Partner_Certification_Group__c pcg : cspCertGroupsCS){
                        if(!requirementsMap.containsKey(selectedPartnerType + ptier.name + psize.name + pcg.name)){
                            requirementsMap.put(selectedPartnerType + ptier.name + psize.name + pcg.name, 
                                                new GU_Compliance_Requirement__c(Partner_Type__c = selectedPartnerType,
                                                                             Partner_Tier__c = ptier.name,
                                                                             Partner_Size__c = psize.name,
                                                                             Compliance_Requirement__c = pcg.name,
                                                                             Required_Number__c = 0 
                                                                             ) );
                        }
                    }
                }
            }
        }
         return null; 
    }
    
	public PageReference editGUCR(){
        editMode = true;
        return null; 
    }
    
    public PageReference cancelEditGUCR(){
        editMode = false;
        return null; 
    }
    public PageReference quickSaveGUCR(){
        Database.upsert(requirementsMap.values());
        editMode = true;
        return null; 
    }

    public PageReference saveGUCR(){
        Database.upsert(requirementsMap.values());
        editMode = false;
        return null; 
    }
}