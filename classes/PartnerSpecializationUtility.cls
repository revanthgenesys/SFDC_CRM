public class PartnerSpecializationUtility {

    public Map<String,Set<String>> map_CurrentSpec {get; set;}
    public String accountId {get; set;}
    public string specialization {get;set;}
    public Map<String, boolean> map_BlnSelectedSpec {get; set;}
    public Map<String, Set<String>> map_OfferingGroupSpec {get; set;}
    public List<CS_Specialization__c> list_SepcByOff {get; set;}
    public String strCurrSpecial {get; set;}
               
    public PartnerSpecializationUtility(){
        
    }

    public List<Partner_Certifications__c> getAllCertifications(){
        return [SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, 
                Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c 
                FROM Partner_Certifications__c WHERE Account__c = :accountId AND (Expiry_Date__c = NULL OR Expiry_Date__c  >= TODAY) ORDER BY Expiry_Date__c];
    } 
    
    /*public List<Litmos__UserProgramResult__c> getAllLitmosTrainings(){
    return [SELECT Id,Litmos__Active__c,Litmos__Completed__c,Litmos__ProgramID__r.Litmos__LitmosID__c,Litmos__FinishDate__c,Litmos__LitmosID__c,
                Litmos__PercentageComplete__c,Litmos__ProgramID__c,Litmos__Program_Code__c,Litmos__StartDate__c,Litmos__ProgramID__r.Litmos__Code__c,
                Litmos__status__c,Litmos__UserID__c,Litmos__User_Name__c,Name,OwnerId,Litmos__ContactID__r.Email
                FROM Litmos__UserProgramResult__c  WHERE Litmos__Completed__c = true 
                AND Litmos__UserID__r.Contact.AccountId = :accountId ORDER BY Litmos__FinishDate__c ASC NULLS LAST];                
    }*/
    
    /*public List<Litmos__UserLearningPathResult__c> getAllLitmosLearningPathUsers(){
        return [SELECT Id, Name, Litmos__LearningPathID__r.Litmos__Description__c,
                Litmos__LearningPathID__r.Litmos__LitmosID__c , Litmos__UserID__r.Contact.Name, Litmos__Completed__c, 
                Litmos__FinishDate__c, Litmos__StartDate__c, Litmos__LearningPathID__c, Litmos__UserID__c, Litmos__UserID__r.Email
                FROM Litmos__UserLearningPathResult__c  
                WHERE Litmos__Completed__c = TRUE AND Litmos__UserID__r.Contact.AccountId = :accountId
                ORDER BY Litmos__FinishDate__c ];
    }*/
    
    public list<docebo_v3__CourseEnrollment__c> getAllDoceboCourses(){
        return [select docebo_v3__CompletedLearningObjects__c, docebo_v3__Completion__c, docebo_v3__EnrollmentCompletionDate__c, docebo_v3__Course__c, 
                        docebo_v3__Credits__c, docebo_v3__DoceboUser__c, docebo_v3__EnrollmentStartDate__c, docebo_v3__EnrolmentId__c, docebo_v3__Score__c, 
                        docebo_v3__Status__c, docebo_v3__TimeInCourse__c, docebo_v3__Who__c,docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Email,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__r.Contact_Full_Name__c,
                        docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.Contact_Full_Name__c,docebo_v3__DoceboUser__r.docebo_v3__User__c,
                        docebo_v3__DoceboUser__r.docebo_v3__Contact__c,docebo_v3__Course__r.docebo_v3__Name__c,docebo_v3__Course__r.docebo_v3__CourseId__c
                        from docebo_v3__CourseEnrollment__c  
                        where (docebo_v3__DoceboUser__r.docebo_v3__Contact__r.AccountId = :accountId 
                        OR docebo_v3__DoceboUser__r.docebo_v3__User__r.Contact.AccountId = :accountId) AND docebo_v3__Status__c='Completed'];
    }
    
     public void getSpecializationByOffering(){
         
        // Step 1 - Start
        // Collect all Certifications from Litmos and Map it by Course Id code.
        /*List<Litmos__UserProgramResult__c> list_LitmosCertUsers = getAllLitmosTrainings();
        
        Map<String, List<Litmos__UserProgramResult__c>> map_LCertUserbyCode = new Map<String, List<Litmos__UserProgramResult__c>>();
        System.Debug('LitmosList--->'+list_LitmosCertUsers);
        for(Litmos__UserProgramResult__c objUser :  list_LitmosCertUsers){
            if(!map_LCertUserbyCode.containsKey(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c)){
                map_LCertUserbyCode.put(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c, new  List<Litmos__UserProgramResult__c>{objUser});
            }else{
                map_LCertUserbyCode.get(objUser.Litmos__ProgramID__r.Litmos__LitmosID__c).add(objUser);
            }
        }
        System.Debug('LcertMap--->'+map_LCertUserbyCode);*/
        
        List<docebo_v3__CourseEnrollment__c> list_DoceboCourses = getAllDoceboCourses();
        Map<string, List<docebo_v3__CourseEnrollment__c>> map_DCoursesEnrollment = new Map<string, List<docebo_v3__CourseEnrollment__c>>();

        for(docebo_v3__CourseEnrollment__c objUser :  list_DoceboCourses){
            if(!map_DCoursesEnrollment.containsKey(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c))){
                map_DCoursesEnrollment.put(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c), new  List<docebo_v3__CourseEnrollment__c>{objUser});
            }else{
                map_DCoursesEnrollment.get(string.valueof(objUser.docebo_v3__Course__r.docebo_v3__CourseId__c)).add(objUser);
            }
        }


        System.Debug('DcertMap--->'+map_DCoursesEnrollment);
        
        // Collect all Certifications from Partner and Map it by Test code.
        List<Partner_Certifications__c> list_PartCertUser = getAllCertifications();
        Map<String, List<Partner_Certifications__c>> map_PCertUserbyCode = new Map<String, List<Partner_Certifications__c>>();
        
        for(Partner_Certifications__c objUser :  list_PartCertUser){
            if(!map_PCertUserbyCode.containsKey(objUser.Genesys_Test_Code__c)){
                map_PCertUserbyCode.put(objUser.Genesys_Test_Code__c, new  List<Partner_Certifications__c>{objUser});
            }else{
                map_PCertUserbyCode.get(objUser.Genesys_Test_Code__c).add(objUser);
            }
        }
        System.Debug('PCertMap--->'+map_PCertUserbyCode);
        
        // Collect all Learning Path Users From Litmos Learning Path and map then by Learning Path Id
        /*List<Litmos__UserLearningPathResult__c> list_LitmosLearnPathUsers = getAllLitmosLearningPathUsers();
        
        Map<String, List<Litmos__UserLearningPathResult__c>> map_LLPathUsersByCode = new Map<String, List<Litmos__UserLearningPathResult__c>>();
        
        for(Litmos__UserLearningPathResult__c objUser :  list_LitmosLearnPathUsers){
            if(!map_LLPathUsersByCode.containsKey(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c)){
                map_LLPathUsersByCode.put(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c, new  List<Litmos__UserLearningPathResult__c>{objUser});
            }else{
                map_LLPathUsersByCode.get(objUser.Litmos__LearningPathID__r.Litmos__LitmosID__c).add(objUser);
            }
        }
        System.Debug('map_LLPathUsersByCode--->'+map_LLPathUsersByCode);*/
        
        // Step 1 - End
        // Step 2 - Start
        // Get Specialization with test code and Map Test codes by Specialization. 
        List<CS_Certification_Group_By_Specialization__c> list_CSCGS = [SELECT Id, Name,Certification_Codes__c,Solution_Group__c, Specialization__c FROM CS_Certification_Group_By_Specialization__c];
        System.Debug('list_CSCGS--->'+list_CSCGS);
        Map<String, Set<String>> map_CGSBySG = new Map<String, Set<String>>();
        
        for(CS_Certification_Group_By_Specialization__c objCG : list_CSCGS){
            List<String> list_Temp = new List<String>();
            if(String.isNotBlank(objCG.Certification_Codes__c)){
                if(objCG.Certification_Codes__c.contains(',')){
                    list_Temp.addAll(objCG.Certification_Codes__c.split(','));
                }else{
                    list_Temp.add(objCG.Certification_Codes__c);
                }
            }
            
            if(!map_CGSBySG.containsKey(objCG.Specialization__c)){
                map_CGSBySG.put(objCG.Specialization__c, new Set<String>(list_Temp));
            }else{
                map_CGSBySG.get(objCG.Specialization__c).addAll(list_Temp);
            }
        }
        System.debug('Map : '+map_CGSBySG);
        // Step 2 - End
        // Step 3 - Start
        // Check Qualification of each Specialization.
        Map<String , Map<String, boolean>> map_QualificationBySpecAndCode = new Map<String , Map<String, boolean>>();
        // Step a: Setup
        for(String strSpec : map_CGSBySG.keySet()){
            if(!map_QualificationBySpecAndCode.containsKey(strSpec)){
                map_QualificationBySpecAndCode.put(strSpec, new Map<String, boolean>());
            }
            if(map_CGSBySG.get(strSpec).size() > 0){
                for(String strCertCode : map_CGSBySG.get(strSpec)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode , false);
                }
            }else{
                map_QualificationBySpecAndCode.get(strSpec).put('NONE' , true);
            }
            
        }
        System.Debug('map_QualificationBySpecAndCode--->'+map_QualificationBySpecAndCode);
        // Step b: Check 
        for(String strSpec : map_QualificationBySpecAndCode.keySet()){
            for(String strCertCode : map_QualificationBySpecAndCode.get(strSpec).keySet()){
                if(map_PCertUserbyCode.containsKey(strCertCode)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }else if(map_DCoursesEnrollment.containsKey(strCertCode)){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }/*else if(map_LLPathUsersByCode.containsKey(strCertCode) ){
                    map_QualificationBySpecAndCode.get(strSpec).put(strCertCode, true);
                }*/
            }
        }
        System.Debug('map_QualificationBySpecAndCode after--->'+map_QualificationBySpecAndCode);
        // Step 3 - End
        // Step 4 - Start
        // Collect all Offering Types by Specializations
        List<CS_Specialization__c> list_ComplSpec = [SELECT Id, Name, Offering_Type__c, Prerequisite__c FROM CS_Specialization__c ORDER BY Offering_Type__c NULLS First, Prerequisite__c NULLS FIRST];
        System.Debug('list_ComplSpec--->'+list_ComplSpec);

        map_CurrentSpec = new Map<String, Set<String>>();
        
        // Collect Offering Types for above Specializations which are eligible.
        Map<String , boolean> map_SpecEligible = new Map<String, boolean>();
        
        for(String strSpec : map_QualificationBySpecAndCode.keySet()){
            boolean flag = true ;
            for(String strCode : map_QualificationBySpecAndCode.get(strSpec).keySet()){
                flag = flag && map_QualificationBySpecAndCode.get(strSpec).get(strCode);
            }
            map_SpecEligible.put(strSpec, flag);
        }
        System.Debug('map_SpecEligible--->'+map_SpecEligible);
        for(CS_Specialization__c objCS : list_ComplSpec){
            if(map_SpecEligible.containsKey(objCS.Name) && map_SpecEligible.get(objCS.Name)){
                if(map_CurrentSpec.containsKey(objCS.Offering_Type__c)){
                    map_CurrentSpec.get(objCS.Offering_Type__c).add(objCS.Name);
                }else{
                    map_CurrentSpec.put(objCS.Offering_Type__c, new Set<String>{objCS.Name});
                }
                if(String.isBlank(objCS.Offering_Type__c)){
                    map_CurrentSpec.put('Other', new Set<String>{objCS.Name});
                }
            }
            
        }
        System.Debug('map_CurrentSpec--->'+map_CurrentSpec);
        // Check if Core is eligible on PureConnect and PureEngage 
        // Step 4 - End
        // Step 5 - Start
        // Setup data to Present in UI
        map_OfferingGroupSpec = new Map<String, Set<String>>();
        list_SepcByOff = [SELECT Id, Name, Offering_Type__c, Prerequisite__c FROM CS_Specialization__c ORDER BY Offering_Type__c NULLS First, Prerequisite__c NULLS FIRST];
        System.Debug('list_SepcByOff--->'+list_SepcByOff);
        for(CS_Specialization__c objSpec :  list_SepcByOff){
            boolean blnAddSpec = false; 
            if( (String.isNotBlank(objSpec.Prerequisite__c) && map_CurrentSpec.containsKey(objSpec.Offering_Type__c) && 
                               map_CurrentSpec.get(objSpec.Offering_Type__c).contains(objSpec.Prerequisite__c)) ||
                 String.isBlank(objSpec.Prerequisite__c)
              )
            {
                blnAddSpec = true;
            }
            
            if(blnAddSpec){
                if(String.isNotBlank(objSpec.Offering_Type__c)){
                    if(!map_OfferingGroupSpec.containsKey(objSpec.Offering_Type__c))
                        map_OfferingGroupSpec.put(objSpec.Offering_Type__c, new Set<String>{objSpec.Name});
                    else
                        map_OfferingGroupSpec.get(objSpec.Offering_Type__c).add(objSpec.Name);
                }
            }
        }
        System.Debug('map_OfferingGroupSpec--->'+map_OfferingGroupSpec);
        // Step 5 - End
        getSelectedSpecializationDetails();
    }
    
    public void getSelectedSpecializationDetails(){
        strCurrSpecial = '';
        
        // Collected User selected Specialization and default specializations. 
        for(String strKeyOff : map_OfferingGroupSpec.keySet()){
            for(String strKeySep : map_OfferingGroupSpec.get(strKeyOff)){
                if(map_CurrentSpec.containsKey(strKeyOff) && map_CurrentSpec.get(strKeyOff).contains(strKeySep)){
                    strCurrSpecial += (strKeySep.equalsIgnoreCase('PureEngage - Core') || strKeySep.equalsIgnoreCase('PureCloud') ? strKeySep : strKeyOff +' - '+strKeySep ) + ' + ';
                }
                System.debug('Key : '+strKeySep);
            }
        }
        if(map_CurrentSpec.containsKey('Other')){
            strCurrSpecial += 'Speech Analytics'+' + ';
        }
        strCurrSpecial = strCurrSpecial.removeEndIgnoreCase(' + ');
        specialization = strCurrSpecial.replace(' + ',';');
        
        System.debug('strCurrSpecial : '+strCurrSpecial);
    }
    
}