/*
Purpose: Created for Searching Partner Directory record. Controller behind Finderloc VF page
Created By: Navaneetha Krishnan
Created On: 04-FEB-2018
*/


public class PartnerDirectoryController {   
    
    public Boolean smartQualifieds {get;set;}
    //Region variable 
    public List<SelectOption> regionList {get;set;}
    public String[] selectedRegion{get;set;} 
    //Country Variable
    public List<SelectOption> countryList {get;set;}
    public String[] selectedCountryIds {get;set;}  
    public String selectedCountryId {get;set;}
    //PartnerType variables
    public List<SelectOption> partnerTypes {get;set;}
    public String[] selectedPartnerType1 {get;set;} 
    public String selectedPartnerType {get;set;} 
    //Partner Tier Variables
    public List<SelectOption> partnerTiers {get;set;}
    public String[] selectedPartnerTiers {get;set;}      
    //Offering type variables
    public List<SelectOption> offeringType{get;set;}
    public String[] selectedOfferingType {get;set;} 
    public String[] selectedOfferingTypecloud {get;set;}     
    Set<String>  selectedOfferingTypeoncloud ;
    //Specialization Variables
    public List<SelectOption> Specialization{get;set;}
    public String[] selectedSpecialization {get;set;}     
    public String[] selectedSpecializationPConnect {get;set;}  
    public String[] selectedSpecializationPcSA {get;set;}  
    Set<String>  selectedSpecializationPEPCPSA ;
    public List<String> listOfAddresses {get; set;}    
    public String approvalstatus; // Approval status variable
    public String bubblestring{get;set;}
    //Clear search button variables.
    public string removeregionfiltertxt{get;set;}
    public string removeptypefiltertxt{get;set;}
    public string removeptierfiltertxt{get;set;}
    public string removepoffertypefiltertxt{get;set;}
    public string removepoffertypecloudfiltertxt{get;set;}
    public string removepSpecfiltertxt{get;set;}
    public string removepSpecfiltertxtPConnect{get;set;}
    public string removepSpecfiltertxtPcSA{get;set;}
    public boolean removepsmartfiltertxt{get;set;}
    //Added filter variables
    public filtercriteria partnerFilter {get;set;}
    List<Partner_Directory_Approved__c> lstglobalresult = new List<Partner_Directory_Approved__c>();
    
    // Get the PDid / partner id / Partner name
    public string singleidtxt{get;set;}
    private String partnerId;
    public String partnerName {get;set;}
    public String addressList {get;set;}   
    //Result wrapper list
    public List<resultWrapper> result = new list<resultWrapper>();    
    public List<resultWrapper>getresult(){return result;}
    
    
    public Boolean isResult {get;set;}
    public String errorMsg {get;set;}
    public Boolean noResultFound {get;set;}   
    public String sortBy {get;set;}
    public Integer resultSize {get;set;}    
    public String urlPart {get;set;}   
    
        //Constructor Starts
        public PartnerDirectoryController(ApexPages.StandardController controller){
            resultSize = 0;
            partnerId = ApexPages.currentPage().getParameters().get('pid');
            partnerName = '';
            smartQualifieds = false;
            removepsmartfiltertxt = false;
            
            approvalstatus = 'Published';
            init();
            searchPartner();
            //Initializing the variables
            selectedRegion   = new String[]{};
            selectedCountryIds = new String[]{};
            selectedPartnerType1 = new String[]{};
            selectedPartnerTiers = new String[]{};
            selectedOfferingType = new String[]{};
            selectedOfferingTypecloud = new String[]{};
            selectedOfferingTypeoncloud = new Set<String>();            
            selectedSpecialization = new String[]{};            
            selectedSpecializationPConnect = new String[]{};
            selectedSpecializationPcSA = new String[]{};            
            selectedSpecializationPEPCPSA = new Set<String>();
            
        }//Constructor Ends

        //Clear all search button method
        public pagereference clearall(){
            pagereference pg = new pagereference('/apex/Finderloc');
            pg.setRedirect(true);
            return pg;
        }
        //Individual partner link method
        public pagereference specficpartnerlink(){
            system.debug('pid='+ singleidtxt );
            pagereference pg1 = new pagereference('/apex/Finderloc?pid='+ singleidtxt );
            pg1.setRedirect(true);
            return pg1;
        }

        //Initial method to load for the left search boxes from pick list to check box.
        public void init(){
            if(UserInfo.getUserType() == 'Guest')
            urlPart = 'partner';
            else
            urlPart = 'apex';
            isResult = false;
            noResultFound = false;
            
            regionList = new List<SelectOption>();
            List<SelectOption> pickListValuesregion = getPicklistValues(new Country__C(), 'Region__C',TRUE);
            regionList.addAll(pickListValuesregion);        

            partnerTypes = new List<SelectOption>();
            //List<SelectOption> pickListValues = getPicklistValues(new Partner_Directory_Approved__c(), 'Partner_Type__c', True);
            List<SelectOption> pickListValues = getPicklistValues(new Partner_Directory_Approved__c(), 'PartnerTypeSupport__c', True);
            partnerTypes.addAll(picklistValues);

            partnerTiers = new List<SelectOption>();
            //List<SelectOption> pickListValuesTiers = getPicklistValues(new Partner_Directory_Approved__c(), 'Tier__c',True);
           // List<SelectOption> pickListValuesTiers = getPicklistValues(new Account(), 'Partner_Tier__c',True);
            List<SelectOption> pickListValuesTiers = getPicklistValues(new Partner_Directory_Approved__c(), 'TierSupport__c',True);
            partnerTiers.addAll(pickListValuesTiers); 
            
            
            offeringType = new List<SelectOption>();
            List<SelectOption> pickListValuesOffertype = getPicklistValues(new Partner_Directory_Approved__c(), 'Offering_Type__c', True);
            offeringType.addAll(pickListValuesOffertype);
            
            Specialization= new List<SelectOption>();
            List<SelectOption> pickListValuesSpec = getPicklistValues(new Account(), 'Specialization__c',True);
            Specialization.addAll(pickListValuesSpec );  

        } 
        
        // New check box values from custom label for offering type and specialization.        
        public List<SelectOption> getOnPremiseoff () {
            List<SelectOption> options = new List<SelectOption>();
            list <String> OnPremiseoffer = system.label.Offering_Type_On_Premise.split(';'); 
            for(String op : OnPremiseoffer ){
            options.add(new SelectOption(op,  op ));        
        }
            return options;
        }
            
        public List<SelectOption> getCloudoff () {
            List<SelectOption> options = new List<SelectOption>();
            list <String> Cloudoffer = system.label.Offering_Type_Cloud.split(';'); 
            for(String co : Cloudoffer ){
            options.add(new SelectOption(co,  co ));        
        }
            return options;
        }
            
            
        public List<SelectOption> getPEngage () {
            List<SelectOption> options = new List<SelectOption>();
            list <String> PEngagespec = system.label.Specialization_PureEngage.split(';'); 
            for(String PE : PEngagespec ){
            options.add(new SelectOption(PE,  PE.substring(13)));        
        }
            return options;
        }
        
        public List<SelectOption> getPCloud () {
            List<SelectOption> options = new List<SelectOption>();
            list <String> PCloudspec = system.label.Specialization_PureConnect.split(';'); 
            for(String PC : PCloudspec ){
            options.add(new SelectOption(PC,  PC.substring(14)));        
        }
            return options;
        }       
        
        public List<SelectOption> getPCSA () {
            List<SelectOption> options = new List<SelectOption>();
            list <String> PCSAspec = system.label.PureCloud_Speech_Analytics.split(';'); 
            for(String PCSA : PCSAspec ){
            options.add(new SelectOption(PCSA,  PCSA));        
        }
            return options;
        }
        // New check box values from custom label for offering type and specialization. Ends
    

        public void searchPartner(){    system.debug('inside searchPartner');
        filtercriteria p = new filtercriteria();        
        String query = 'SELECT  Partner_Country__c ,Account__c,Approval_Status__c,Company_Description__c,Country_Territory__c,HQ_Address__c,Id,Latitude__c,Longitude__c,Offering_Type_Admin__c,Specialization_Admin__c,Name,   Partner_Directory_Staging__c,Partner_Name__c,Partner_Type_Admin__c,Phone__c,Region__c,SMART_Qualified__c,Tier_Admin__c,Tier_Order__c,Website__c,Offering_Type__c, Specialization__c FROM Partner_Directory_Approved__c where Approval_Status__c =\'Published\' AND Partner_Directory_Staging__c != null ' ;
       // String query = 'SELECT  Account__c,Approval_Status__c,Company_Description__c,Country_Territory__c,Country_Search__c ,HQ_Address__c,Id,Latitude__c,Longitude__c,Offering_Type_Admin__c,Specialization_Admin__c,Name,Partner_Directory_Admin__c,Partner_Name__c,Partner_Type_Admin__c,Phone__c,Region__c,SMART_Qualified__c,Tier_Admin__c,Tier_Order__c,Website__c,Offering_Type__c, Specialization__c FROM Partner_Directory_Approved__c where Approval_Status__c =\'Published\'' ;
        
            if(!string.isblank(partnerId))
            {
            query += ' and id = \'' +partnerId+ '\' ';
            } 
            else
            {

            //Partner Name search keyword
            if(!string.isblank(partnerName))
            {           
                set<id> matchcountry = new set<id>();
                for(Partner_Directory_Approved__c i: database.query(query)){
                    if(i.Partner_Country__c   != null && i.Partner_Country__c != ''){
                    if(i.Partner_Country__c.contains(partnerName)){
                            matchcountry.add(i.id); 
                    }
                    }
                }
               // query += ' and  (Partner_Name__c LIKE \'%'+ partnerName +'%\' or  Partner_Type_Admin__c LIKE \'%'+ partnerName +'%\' or  Region__c LIKE \'%'+ partnerName +'%\' or  HQ_Address__c LIKE \'%'+ partnerName +'%\'or  Tier_Admin__c LIKE \'%'+ partnerName +'%\' or  Specialization_Admin__c LIKE \'%'+ partnerName +'%\' or  Country_Territory__c includes (\''+ partnerName +'\'))';
                 query += ' and  (Partner_Name__c LIKE \'%'+ partnerName +'%\' or  Partner_Type_Admin__c LIKE \'%'+ partnerName +'%\' or  Region__c LIKE \'%'+ partnerName +'%\' or  HQ_Address__c LIKE \'%'+ partnerName +'%\'or  Tier_Admin__c LIKE \'%'+ partnerName +'%\' or  Specialization_Admin__c LIKE \'%'+ partnerName +'%\' or Country_Territory__c includes (\''+ partnerName +'\') or  id IN : matchcountry)';               
                
            } 
            
            //if smartqualified checked in the filter
            if(smartQualifieds)       
            {                
                query += ' AND SMART_Qualified__c = true';
            }
           
            //if Region checked in the filter
            if(selectedRegion !=null && selectedRegion.size()>0)        
            {               
                query += ' AND Region__c LIKE : selectedRegion';
            }

            //if Partner Type checked in the filter
            if( selectedPartnerType1!= null && selectedPartnerType1.size()>0  )
            {
                String values='';
                string filtercondition = '(';
                integer i = 1;          
            for(String s: selectedPartnerType1){        
             
                filtercondition+= ' Partner_Type_Admin__c LIKE \'%'+ s +'%\'';
                if(i<selectedPartnerType1.size()){
                filtercondition += ' OR '; 
                }  
                i++;      
            } 
                filtercondition += ')';                   

                query += ' AND '+  filtercondition;
           }
           
            //if Partner Type checked in the filter ENDS
            //if Partner Tier checked in the filter
            if(selectedPartnerTiers!=null && selectedPartnerTiers.size()>0)
            {
                query += ' AND Tier_Admin__c LIKE : selectedPartnerTiers';
            }            
            
            if( (selectedOfferingType != null && selectedOfferingType.size()>0) || (selectedOfferingTypecloud != null && selectedOfferingTypecloud.size()>0) )
            {
                String values3='';
                string filtercondition1 = '(';
                integer i = 1;    
               
               if(selectedOfferingType.size()>0)
               {
               selectedOfferingTypeoncloud.clear();
               selectedOfferingTypeoncloud.addAll(selectedOfferingType);              
               }               
               if(selectedOfferingTypecloud.size()>0)
               {
               selectedOfferingTypeoncloud.clear();
               selectedOfferingTypeoncloud.addAll(selectedOfferingTypecloud );             
               }
               
            for(String s1: selectedOfferingTypeoncloud){        
             
                filtercondition1+= ' Offering_Type_Admin__c LIKE \'%'+ s1 +'%\'';
                if(i<selectedOfferingTypeoncloud.size()){
                filtercondition1 += ' OR '; 
                }  
                i++;      
            } 
                filtercondition1 += ')';                   

                query += ' AND '+  filtercondition1;
           }
           
           
           
           
           if( selectedSpecialization  != null && selectedSpecialization .size()>0  || selectedSpecializationPConnect != null && selectedSpecializationPConnect.size()>0 || selectedSpecializationPcSA != null && selectedSpecializationPcSA.size()>0 )
            {
                String values4='';
                string filtercondition2 = '(';
                integer i = 1;   
            if(selectedSpecialization.size()>0)
               {
               selectedSpecializationPEPCPSA.addAll(selectedSpecialization);              
               }               
               if(selectedSpecializationPConnect.size()>0)
               {
               selectedSpecializationPEPCPSA.addAll(selectedSpecializationPConnect);             
               }
               if(selectedSpecializationPcSA.size()>0)
               {
               selectedSpecializationPEPCPSA.addAll(selectedSpecializationPcSA);             
               }

                
            for(String s2: selectedSpecializationPEPCPSA ){        
             
                filtercondition2+= ' Specialization_Admin__c LIKE \'%'+ s2 +'%\'';
                if(i<selectedSpecializationPEPCPSA.size()){
                filtercondition2+= ' OR '; 
                }  
                i++;      
            } 
                filtercondition2 += ')';                   

                query += ' AND '+  filtercondition2;
           }
            query += ' ORDER BY Tier_Order__c, Partner_Name__c ASC';
            }
            //Search result list 
            system.debug('query-->'+query);
        List<Partner_Directory_Approved__c> accountsFound = (List<Partner_Directory_Approved__c>)Database.query(query); 
        System.debug('NKC debug query ['+accountsFound+']');       
        //Removing the selected checkbox values while clicking the clear buttons.
        if(smartQualifieds){
            removepsmartfiltertxt = true;
            system.debug('removepsmartfiltertxt' + removepsmartfiltertxt);
            p.partnerSmartQualified = smartQualifieds ;
            partnerFilter = p; 
        }

        if( (selectedRegion !=null) ){          
            p.regionfilters = selectedRegion;
            partnerFilter = p;       
        }
        
        if(  (selectedPartnerType1!= null)){     
            p.partnertypefilters = selectedPartnerType1;
            partnerFilter = p;
        }

        if((selectedPartnerTiers!=null)){      
            p.partnertierfilters = selectedPartnerTiers;
            partnerFilter = p; 
        }
        
        if((selectedOfferingType!=null)){      
            p.partnerofferingtypefilters = selectedOfferingType ;
            partnerFilter = p; 
        }
        
        if((selectedOfferingTypecloud!=null)){      
            p.selectedOfferingTypecloudfilters = selectedOfferingTypecloud  ;
            partnerFilter = p; 
        }
        
        if((selectedSpecialization!=null)){      
            p.partnerSpecializationtypefilters = selectedSpecialization ;
            partnerFilter = p; 
        }
        
        if((selectedSpecializationPConnect!=null)){      
            p.partnerSpecializationPConnectfilters  = selectedSpecializationPConnect ;
            partnerFilter = p; 
        }
        
        if((selectedSpecializationPcSA !=null)){      
            p.partnerSpecializationPCSAfilters  = selectedSpecializationPcSA  ;
            partnerFilter = p; 
        }
        
        
        // Adding the search result list to wrapper to display in the vf page
        result = new List<resultWrapper>();
        for(Partner_Directory_Approved__c eachPD : accountsFound){           
            //string ptypeadmin = eachPD.Partner_Type_Admin__c.removeEnd(';');
            string ptypeadmin = eachPD.Partner_Type_Admin__c;
          //  str.left(str.length()-2)
            string abc = ptypeadmin.left(ptypeadmin.length()-3);
            System.debug('accPartnerType231'+ abc );  
            
            resultWrapper newRecord = new resultWrapper();
            newRecord.accId = eachPD.Account__c;
            newRecord.accRegion = eachPD.Region__c;
            newRecord.accRegion1 = eachPD.Region__c;
            newRecord.accName = eachPD.Partner_Name__c;
            newRecord.accCountryId = eachPD.Country_Territory__c;
            
            Set<string> countrysetdup = new Set<string>();
            list<String> countyteritory = new list<String>();
             countyteritory = String.isBlank(eachPD.Country_Territory__c)?new list<String>():eachPD.Country_Territory__c.split(';');
            for(string county : countyteritory ){
                countrysetdup.add(county);
            }
            countyteritory.clear();
            countyteritory = String.isBlank(eachPD.Partner_Country__c)?new list<String>():eachPD.Partner_Country__c.split(';');
            for(string pcounty :  countyteritory){
                countrysetdup.add(pcounty);
            }
            
            list<String> countylist = new list<String>();
           countylist.addAll(countrysetdup)  ;
           newRecord.accCountryName = String.join(countylist, ';'); 
            
           system.debug('newRecord.accCountryName' + newRecord.accCountryName);
            // newRecord.accCountryName = eachPD.Country_Territory__c + eachPD.Partner_Country__c;
         /*   if(!string.isblank(eachPD.Country_Territory__c))
            {
            
            newRecord.accCountryName = eachPD.Country_Territory__c + eachPD.Partner_Country__c;
            
            }
            else{
            
            newRecord.accCountryName = eachPD.Partner_Country__c;
            
            } */
            
            newRecord.accTier = eachPD.Tier_Admin__c;
            newRecord.accPartnerType = eachPD.Partner_Type_Admin__c; 
           // newRecord.accPartnerType1 = (eachPD.Partner_Type_Admin__c).removeEnd(';');  
            newRecord.accPartnerType1 = eachPD.Partner_Type_Admin__c.left(eachPD.Partner_Type_Admin__c.length()-3);
          
       
            newRecord.accSmartQualified = eachPD.SMART_Qualified__c;   
            newRecord.Longitude = eachPD.Longitude__C;
            newRecord.Latitude = eachPD.Latitude__C;
            newRecord.ids = eachPD.id;
            newRecord.pdWebsite = eachPD.Website__c;
            newRecord.pdPhone = eachPD.Phone__c;
            newRecord.pdCompanyDesc = eachPD.Company_Description__c;
            newRecord.pdhqAddress = eachPD.HQ_Address__c;
            newRecord.accSpecialization = eachPD.Specialization_Admin__c;
            newRecord.accofferingType = eachPD.Offering_Type_Admin__c;
            result.add(newRecord);  
            
        }                 
      
        if(!result.isEmpty())
            isResult = true;
            if(result.isEmpty())
            noResultFound = true;
            resultSize = result.size();
            return;
        }
        
//Filter action method to clean wrapper in button button action
    public void filteraction(){

        if(!removepsmartfiltertxt)
        {
            partnerfilter.partnerSmartQualified = false;
            smartQualifieds = false;
            
        }
        for(integer i=0; i<partnerfilter.regionfilters.size();i++){

            if(partnerfilter.regionfilters[i] == removeregionfiltertxt){
                partnerfilter.regionfilters.remove(i);
            }

            if(removeregionfiltertxt == selectedRegion[i]){
                selectedRegion.remove(i);
            }           
        }

        for(integer i=0; i<partnerfilter.partnertypefilters.size();i++){                

            if(partnerfilter.partnertypefilters[i] == removeptypefiltertxt){
                partnerfilter.partnertypefilters.remove(i);
            }
            
            if(removeptypefiltertxt == selectedPartnerType1[i])
            {
                selectedPartnerType1.remove(i);
            }                       
        }

        for(integer i=0; i<partnerfilter.partnertierfilters.size();i++){

            if(partnerfilter.partnertierfilters[i] == removeptierfiltertxt){
                partnerfilter.partnertierfilters.remove(i);
            }
            if(removeptierfiltertxt == selectedPartnerTiers[i])
            {
                selectedPartnerTiers.remove(i);
            }
 
        }
        
        for(integer i=0; i<partnerfilter.partnerofferingtypefilters.size();i++){                

            if(partnerfilter.partnerofferingtypefilters[i] == removepoffertypefiltertxt){
                partnerfilter.partnerofferingtypefilters.remove(i);
            }
            
            if(removepoffertypefiltertxt == selectedOfferingType[i])
            {
                selectedOfferingType.remove(i);
            }                       
        }
        
        //Added for additional offer type
        for(integer i=0; i<partnerfilter.selectedOfferingTypecloudfilters.size();i++){                

            if(partnerfilter.selectedOfferingTypecloudfilters[i] == removepoffertypecloudfiltertxt){
                partnerfilter.selectedOfferingTypecloudfilters.remove(i);
            }
            
            if(removepoffertypecloudfiltertxt == selectedOfferingTypecloud[i])
            {
                selectedOfferingTypecloud.remove(i);
            }                       
        }
                     
        
        for(integer i=0; i<partnerfilter.partnerSpecializationtypefilters.size();i++){                

            if(partnerfilter.partnerSpecializationtypefilters[i] == removepSpecfiltertxt){
                partnerfilter.partnerSpecializationtypefilters.remove(i);
            }
            
            if(removepSpecfiltertxt == selectedSpecialization[i])
            {
                selectedSpecialization.remove(i);
            }                       
        }  
        
        for(integer i=0; i<partnerfilter.partnerSpecializationPConnectfilters.size();i++){                

            if(partnerfilter.partnerSpecializationPConnectfilters[i] == removepSpecfiltertxtPConnect){
                partnerfilter.partnerSpecializationPConnectfilters.remove(i);
            }
            
            if(removepSpecfiltertxtPConnect == selectedSpecializationPConnect[i])
            {
                selectedSpecializationPConnect.remove(i);
            }                       
        } 
        
        for(integer i=0; i<partnerfilter.partnerSpecializationPCSAfilters.size();i++){                

            if(partnerfilter.partnerSpecializationPCSAfilters[i] == removepSpecfiltertxtPcSA){
                partnerfilter.partnerSpecializationPCSAfilters.remove(i);
            }
            
            if(removepSpecfiltertxtPcSA == selectedSpecializationPcSA[i])
            {
                selectedSpecializationPcSA.remove(i);
            }                       
        }   
       
        searchPartner();
    }
    
    //Convert picklist to checkbox
    private static list<SelectOption> getPicklistValues(SObject obj, String fld, Boolean isPer){
        list<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
        fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
        if(isPer){
        //  options.add(new SelectOption('%'+a.getLabel()+'%', a.getValue())); 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }else{
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        }
        return options;
    }

    
        //Wrapper class for result to display.
        public class resultWrapper{
            public String accId {get;set;}
            public String accName {get;set;}
            public String accCountryId {get;set;}
            public String accCountryName {get;set;}
            public String accPartCountryName {get;set;}
            public String accTier {get;set;}
            public String accPartnerType {get;set;}
            public String accRegion {get;set;}
            public String accRegion1 {get;set;}          
            public boolean accSmartQualified {get;set;}
            public String accPartnerType1{get;set;}
            public String Latitude{get;set;}
            public String Longitude{get;set;}
            public String ids{get;set;}
            public String pdWebsite{get;set;}
            public String pdPhone{get;set;}
            public String pdCompanyDesc{get;set;}
            public String pdhqAddress{get;set;}
            public String accofferingType{get;set;}
            public String accSpecialization{get;set;}
        }
        //Wrapper class for filter criteria 
        public class filtercriteria{

            public list<String> regionfilters{get; set;}
            public list<String> partnertypefilters{get; set;}
            public list<String> partnertierfilters{get; set;}
            public list<String> partnerofferingtypefilters{get; set;}
            public list<String> selectedOfferingTypecloudfilters{get; set;}            
            public list<String> partnerSpecializationtypefilters{get; set;}         
            public list<String> partnerSpecializationPConnectfilters{get; set;}
            public list<String> partnerSpecializationPCSAfilters{get; set;}            
            public boolean partnerSmartQualified {get;set;}           

        public filtercriteria(){ 
            regionfilters = new list<String>();
            partnertypefilters = new list<String>();
            partnertierfilters = new list<string>();
            partnerofferingtypefilters = new list<string>();   
            selectedOfferingTypecloudfilters = new list<string>();
            partnerSpecializationtypefilters= new list<string>();           
            partnerSpecializationPConnectfilters = new list<string>();
            partnerSpecializationPCSAfilters = new list<string>();
        }  
        }   

}