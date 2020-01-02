// Sourav Mitra : Feb 2014
public class PartnerSetupController 
{
    String strContractId;
    public Partner_Contract__c objContract {get; private set;}
    public Map<String,Partner_Business_Terms_Category__c> map_CategoryToCategoryRecord {get; private set;}
    public List<SelectOption> list_CategoryOptions {get; private set;}
    public List<SelectOption> Status_List {get; private set;}
    public String strSelectedCategory {get; set;}
    public String strStatus {get; set;}
    public Boolean blnIsReadMode {get; private set;}
    public Partner_Category_and_Tier__c objCategoryAndTier {get; private set;}
    public List<Country_Requirements__c> list_CountryRequirements {get; set;}
    Map<String,Partner_Category_and_Tier__c> map_CategoryToSetupCategoryRecord = new Map<String,Partner_Category_and_Tier__c>();
    public Map<String,String> map_CountryIdToColumnHeader {get; private set;}
    
    public PartnerSetupController()
    {
        strContractId = ApexPages.currentPage().getParameters().get('contId');
        init();
    }
    
    //*** Method to initialize data when the page loads ***
    private void init()
    {
        blnIsReadMode = true;
        strStatus = 'In Progress';
        
        strSelectedCategory = '';
        list_CategoryOptions = new List<SelectOption>();
        Status_List = new List<SelectOption>();
        Status_List.add(new SelectOption('In Progress','In Progress'));         
        Status_List.add(new SelectOption('Completed','Completed'));
        map_CategoryToCategoryRecord = new Map<String,Partner_Business_Terms_Category__c>();
        map_CountryIdToColumnHeader = new Map<String,String>();
        
        List<Partner_Contract__c> list_Temp = [SELECT Id, Application__c, Application__r.Account__c,Tier__c,
                                    Application__r.Account__r.Name,Application__r.For_User__c,
                                    Partner_Business_Terms_and_Conditions__c
                                    FROM Partner_Contract__c WHERE Id = :strContractId];
        
        if(list_Temp.size() > 0)
        {
            objContract = list_Temp[0];
            for(Partner_Business_Terms_Category__c objTermsCategory : [SELECT Id,Category__c,
                (SELECT Country__c,Country__r.Name,Country__r.Market_Type__c,Id 
                FROM Partner_Business_Terms_Countries__r ORDER BY Country__r.Name)
                FROM Partner_Business_Terms_Category__c
                WHERE Partner_Business_Terms_and_Conditions__c = :objContract.Partner_Business_Terms_and_Conditions__c
                ORDER BY Category__c])
            {
                map_CategoryToCategoryRecord.put(objTermsCategory.Category__c,objTermsCategory);
                list_CategoryOptions.add(new SelectOption(objTermsCategory.Category__c,objTermsCategory.Category__c));
                
                if(strSelectedCategory == '')
                    strSelectedCategory = objTermsCategory.Category__c;
                    
                for(Partner_Business_Terms_Country__c objTermsCountry : objTermsCategory.Partner_Business_Terms_Countries__r)
                {
                    String strColumnHeader = objTermsCountry.Country__r.Name;
                    if(objTermsCountry.Country__r.Market_Type__c != null && objTermsCountry.Country__r.Market_Type__c != '')
                        strColumnHeader += '<br/>[ ' + objTermsCountry.Country__r.Market_Type__c + ' ]';
                    map_CountryIdToColumnHeader.put(objTermsCountry.Country__c,strColumnHeader);
                    
                    system.debug('----------------------------objTermsCountry.Country__c-------------------------------'+objTermsCountry.Country__c);
                    

                   
                }
                   system.debug('---------------------------- list_CountryRequirements-------------------------------'+list_CountryRequirements);
            }
            checkExistingData();
        }
        else
            objContract = new Partner_Contract__c();
            
             strStatus = 'In Progress';
             Profile currProf = [SELECT Id FROM Profile WHERE Name='Partner Community Login New'];
             User currUser = [SELECT id,ProfileId  from User where id=:objContract.Application__r.For_User__c];
             if(currProf.id == currUser.ProfileId)
             {
              strStatus = 'Completed';
             }
        refresh();
    }
    
    //*** Method to Handle refresh of bottom section based on Category selected ***
    public void refresh()
    {
        // if there are existing partner setup records
        if(map_CategoryToSetupCategoryRecord.containsKey(strSelectedCategory))
        {
            objCategoryAndTier = map_CategoryToSetupCategoryRecord.get(strSelectedCategory);
            list_CountryRequirements = objCategoryAndTier.Country_Requirements__r;
        }
        else
        {
            objCategoryAndTier = new Partner_Category_and_Tier__c(Partner_Contract__c = objContract.Id,
                                Account__c = objContract.Application__r.Account__c,
                                Tier__c = objContract.Tier__c,
                                Category__c = strSelectedCategory);
                
            list_CountryRequirements = new List<Country_Requirements__c>();
            
            if(map_CategoryToCategoryRecord.containsKey(strSelectedCategory))
            {
                for(Partner_Business_Terms_Country__c objTermsCountry : 
                                    map_CategoryToCategoryRecord.get(strSelectedCategory).Partner_Business_Terms_Countries__r)
                {
                    Country_Requirements__c obj = new Country_Requirements__c();
                    obj.Country__c = objTermsCountry.Country__c;
                    list_CountryRequirements.add(obj);
                }
            }
        }       
    }
    
    //*** Method to check whether category exists or not and to pre-populate as required ***
    void checkExistingData()
    {
        if(objContract.Id == null)
            return;
            
        String strQuery = 'SELECT Tier__c,Category__c, ';
        strQuery += '(SELECT ';
        // Adding all custom fields to the query string
        for(String strFieldName : Schema.SObjectType.Country_Requirements__c.fields.getMap().keySet())
        {
            if(strFieldName.endsWith('__c'))
                strQuery += strFieldName + ', ';
        }
        strQuery += 'Id FROM Country_Requirements__r ORDER BY Country__r.Name),';
        strQuery += 'Id FROM Partner_Category_and_Tier__c ';
        strQuery += 'WHERE Partner_Contract__c = ';
        strQuery += '\'' + objContract.Id + '\'';
        
        for(Partner_Category_and_Tier__c objPCT : Database.query(strQuery))
        {
            map_CategoryToSetupCategoryRecord.put(objPCT.Category__c,objPCT);
        }
    }
    
    //*** Quick Save Button Handler/function ***
    public void quickSaveBtnHandler()
    {
        saveBtnHandler();
        blnIsReadMode = false;
    }
    
    //*** Save Button Handler/function ***
    public PageReference saveBtnHandler()
    {   
        upsert objCategoryAndTier;
        
        system.debug('-------------------------inside------------------------------------');
         
        system.debug('-------------------------list_CountryRequirements------------------------------------'+list_CountryRequirements);


        if(list_CountryRequirements != null && list_CountryRequirements.size() > 0)
        {
            for(Country_Requirements__c objRecord : list_CountryRequirements)
            {
                if(objRecord.Id == null)
                    objRecord.Partner_Category_and_Tier__c = objCategoryAndTier.Id;
                    objRecord.Status__c = strStatus;
                    system.debug('-------------------------strStatus------------------------------------'+strStatus);
            }
            upsert list_CountryRequirements;
        }
        
        if(strStatus == 'Completed')
        {
         updateUserProfile(objContract.Id);
        }  
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Partner Setup data for category : <b>' + strSelectedCategory + '</b> has been saved.');
         ApexPages.addMessage(myMsg);
         blnIsReadMode = true;
         return null;
       }
    
    //*** Edit button handler ***
    public void changeToEditMode()
    {
        blnIsReadMode = false;
    }
    
    //*** Edit button handler ***
    public void cancelBtnHandler()
    {
        blnIsReadMode = true;
    }
     @future 
     private static void updateUserProfile(Id objContract){
     Partner_Contract__c  partnerContr = [Select Id,Application__r.For_User__c from Partner_Contract__c where id=:objContract];
     Profile currProf = [SELECT Id FROM Profile WHERE Name='Partner Community Login New'];
     User currUser = [SELECT id from User where id=:partnerContr.Application__r.For_User__c];
     currUser.ProfileId = currProf.id;
     update currUser;
     }
}