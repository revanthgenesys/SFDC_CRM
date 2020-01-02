//Naresh Kumar      04/23/2014
public without sharing class PartnerSearchController {
    public List<SelectOption> countryList {get;set;}
    public List<SelectOption> partnerTypes {get;set;}
    public String selectedCountryId {get;set;}
    public String selectedPartnerType {get;set;}
    public String partnerName {get;set;}
    public List<resultWrapper> result {get;set;}
    public Boolean isResult {get;set;}
    public String errorMsg {get;set;}
    public Boolean noResultFound {get;set;}
    private String partnerId;
    public String companyOverview {get;set;}
    public String companySpecialization {get;set;}
    public String partnerAwards {get;set;}
    public String partnerAddress {get;set;} 
    public String partnerPhone {get;set;}
    public String partnerWebsite {get;set;}
    public String partnerCountries {get;set;}
    public String partnerTier {get;set;}
    public String partnerType {get;set;}
    public String sortBy {get;set;}
    public Integer resultSize {get;set;}
    public String partnerCertificates {get;set;}
    public String partnerRelationship {get;set;}
    public String partnerLogoURL {get;set;} 
    public String gForceSponsorship {get;set;}   
    public String urlPart {get;set;}
    public String logoId {get;set;}
    public Boolean isLogoInAttachment {get;set;}
    
    public List<CertificationWrapper> partnerCertifications {get;set;}
    
    public PartnerSearchController(){
        resultSize = 0;
        partnerId = ApexPages.currentPage().getParameters().get('id');
        if(partnerId == null)
            init();
        else
            initDetailPage();
    }
    
    public void initDetailPage(){
        isLogoInAttachment = false;
        partnerCertifications = new List<CertificationWrapper>();
        List<Partner_Directory__c> partner = [SELECT id, Name, Tier__c, Partner_Type__c, 
                                              Company_Overview__c, Company_Specialization__c, Partner_Relationship__c, Gforce_Sponsorship__c, 
                                              Partner_Awards__c, Partner_Certificates__c, Address__c, Phone__c, Logo_File__c, 
                                              Partner_Name__c , Website__c, Country__c,Account__c
                                              FROM Partner_Directory__c WHERE id = :partnerId];
        if(!partner.isEmpty()){
            
            partnerName = partner[0].Partner_Name__c;
            selectedPartnerType = partner[0].Partner_Type__c;
            companyOverview = partner[0].Company_Overview__c;
            companySpecialization = partner[0].Company_Specialization__c;
            partnerAwards = partner[0].Partner_Awards__c;   
            partnerAddress = partner[0].Address__c;
            /*(partner[0].Street1__c == null ? '' : partner[0].Street1__c) + 
'<br/>' + (partner[0].City__c == null ? '' : partner[0].City__c) + 
' ' + (partner[0].StateProvince__c == null ? '' : partner[0].StateProvince__c) + 
' ' + (partner[0].ZipCode__c == null ? '' : '- ' + partner[0].ZipCode__c) +
' ' + (partner[0].Country__r.Name == null ? '' : partner[0].Country__r.Name);
*/                
            partnerPhone = partner[0].Phone__c;
            partnerWebsite = partner[0].Website__c;
            partnerCountries = partner[0].Country__c;     
            partnerTier = partner[0].Tier__c;
            partnerCertificates = partner[0].Partner_Certificates__c;
            partnerRelationship = partner[0].Partner_Relationship__c;
            partnerLogoURL = partner[0].Logo_File__c;
            partnerType = partner[0].Partner_Type__c;
            gForceSponsorship = partner[0].Gforce_Sponsorship__c;
            
            partnerCertifications = queryCertifications(partner[0].Account__c);
            
            
            List<Attachment> atts = [select Id, Name from Attachment where ParentId =: partner[0].id];
            if(!atts.isEmpty()){
                for(Attachment eachAtt : atts){
                    System.debug('NKC debug eachAtt.Name ['+eachAtt.Name+']');
                    if(eachAtt.Name.toLowerCase().contains('logo'))	{
                        logoId = eachAtt.id;
                        isLogoInAttachment = true;
                        break;	
                    }
                }
            }
        }
    }
    
    public void init(){
        if(UserInfo.getUserType() == 'Guest')
            urlPart = 'partner';
        else
            urlPart = 'apex';
        isResult = false;
        noResultFound = false;
        countryList = new List<SelectOption>();
        SelectOption newOption = new SelectOption('', '- Any -');
        countryList.add(newOption);            
        for(Country__c eachCountry : [SELECT id, Name FROM Country__c ORDER BY Name]){
            newOption = new SelectOption(eachCountry.Name, eachCountry.Name);            	            	
            countryList.add(newOption);
        }
        partnerTypes = new List<SelectOption>();
        newOption = new SelectOption('', '- Any -');
        partnerTypes.add(newOption);
        List<SelectOption> pickListValues = getPicklistValues(new Partner_Directory__c(), 'Partner_Type__c');
        partnerTypes.addAll(picklistValues);
    }
    
    public void searchPartner(){                
        if((partnerName == null || partnerName.trim() == '') && (selectedCountryId == null || selectedCountryId == '')
           && (selectedPartnerType == null || selectedPartnerType == '')){
               errorMsg = 'Please enter/select something to begin search.';
               return;
           }
        errorMsg = '';
        String query = 'SELECT id, Partner_Name__c, Tier__c, Partner_Type__c, Country__c FROM Partner_Directory__c WHERE Partner_Name__c LIKE \'' + partnerName + '%\' ';
        //if(selectedCountryId != '' && selectedCountryId != null)
        //        query += ' AND Country__c = \'' + selectedCountryId + '\'';
        //if(selectedPartnerType != '' && selectedPartnerType != null)
        //        query += ' AND Partner_Type__c LIKE \'%' + selectedPartnerType + '%\'';
        if(sortBy == null)
            query += ' ORDER BY Tier_Order__c, Partner_Name__c ASC';
        else
            query += ' ORDER BY ' + sortBy + ' ASC';
        System.debug('NKC debug query ['+query+']');
        List<Partner_Directory__c> accountsFound = (List<Partner_Directory__c>)Database.query(query);
        result = new List<resultWrapper>();
        for(Partner_Directory__c eachPD : accountsFound){
            if(selectedCountryId == '' || selectedCountryId == null || (eachPD.Country__c != null && eachPD.Country__c.contains(selectedCountryId))){
                if(selectedPartnerType == '' || selectedPartnerType == null || (eachPD.Partner_Type__c != null && eachPD.Partner_Type__c.contains(selectedPartnerType))){
                    resultWrapper newRecord = new resultWrapper();
                    newRecord.accId = eachPD.id;
                    newRecord.accName = eachPD.Partner_Name__c;
                    newRecord.accCountryId = eachPD.Country__c;
                    newRecord.accCountryName = eachPD.Country__c;
                    newRecord.accTier = eachPD.Tier__c;
                    newRecord.accPartnerType = eachPD.Partner_Type__c;          
                    result.add(newRecord);         
                }         
            }
        }               
        if(!result.isEmpty())
            isResult = true;
        if(result.isEmpty())
            noResultFound = true;
        resultSize = result.size();
        return;
    }
    
    private static list<SelectOption> getPicklistValues(SObject obj, String fld){
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
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
    }
    
    public List<CertificationWrapper> queryCertifications(String accountId){
        List<Partner_Certifications__c> pCerts = [SELECT Genesys_Test_Code__c, Test_Name__c 
                								  FROM Partner_Certifications__c 
                                                  WHERE Account__c = :accountId AND Pass_Fail__c = 'P' 
                                                  AND Expiry_Date__c  >= TODAY
                                                  ORDER BY Genesys_Test_Code__c];
        
        Map<String, CertificationWrapper> pCertsMap = new Map<String, CertificationWrapper>();
        
        for(Partner_Certifications__c pc : pCerts){
            if(pCertsMap.containsKey(pc.Genesys_Test_Code__c)){
                CertificationWrapper cw = pCertsMap.get(pc.Genesys_Test_Code__c);
                cw.count = cw.count + 1;
                pCertsMap.put(pc.Genesys_Test_Code__c, cw);
            } else {
                pCertsMap.put(pc.Genesys_Test_Code__c, new CertificationWrapper(pc.Genesys_Test_Code__c, pc.Test_Name__c, 1));
            }
        }
        
        return pCertsMap.values();
    }
    
    public class resultWrapper{
        public String accId {get;set;}
        public String accName {get;set;}
        public String accCountryId {get;set;}
        public String accCountryName {get;set;}
        public String accTier {get;set;}
        public String accPartnerType {get;set;}
    }
    
    public class CertificationWrapper{
        public String code {get; set;}
        public String name {get; set;}
        public Integer count {get; set;}
        public CertificationWrapper(String code, String name, Integer count){
            this.code = code;
            this.name = name;
            this.count = count;    
        }   
    }
}