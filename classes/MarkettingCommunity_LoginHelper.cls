public with sharing class MarkettingCommunity_LoginHelper {
	  public static Boolean checkForExistingUser(String email, String pageType){
        List<User> existingUser;
        existingUser = [SELECT id FROM User WHERE Email =: email AND Profile.Name =: MarketingCommunity_Util.Marketing_Community_Full_Profile];
        if(existingUser.isEmpty())
            return false;
        else{
            return true;
        }
     }

    public static void processRequest(String firstName, String lastName, String companyName, String country, String email, String pageType){
        Marketting_Community_User_Request__c newRequest = new Marketting_Community_User_Request__c();
        newRequest.Company_Name__c = companyName;       
        newRequest.Email__c = email;
        newRequest.First_Name__c = firstName;
        newRequest.Last_Name__c = lastName;

        Country__c countryRecord = searchCountry(country);
        if(countryRecord != null)
          newRequest.Country__c = countryRecord.id;
        try{
            insert newRequest;
        /*    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Request submitted for approval automatically.');
            req1.setObjectId(newRequest.id);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);       */   
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Warning, 
            'There is some error in submitting you request. Error : ' + ex.getMessage()));
        }       
    }   

    public static List<SelectOption> getAllCountries(){
        List<Country__c> countriesList = [SELECT Name FROM Country__c where Name != 'US/Canada'];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));
        for(Country__c eachCountry : countriesList){
            SelectOption newOption = new SelectOption(eachCountry.Name, eachCountry.Name);
            options.add(newOption);         
        }
        return options;
    }
    
    private static Country__c searchCountry(String countryName){
        List<Country__c> country = [SELECT id FROM Country__c WHERE Name =: countryName LIMIT 1];
        if(country.size() > 0)
            return country[0];
        else 
            return null;         
    }

}