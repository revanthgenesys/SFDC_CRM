public without sharing class PartnerNewUserRegistrationHelper {

     public static Boolean checkForExistingUser(String email, String pageType){
        List<User> existingUser;
        existingUser = [SELECT id FROM User WHERE Email =: email AND IsActive = true and UserType != 'Standard'];        
        if(existingUser.isEmpty())
            return false;
        else{
            Set<Id> userIds = new Set<Id>();
            for(User eachUser : existingUser){
                userIds.add(eachUser.id);
            }
            List<PermissionSetAssignment> psa = [SELECT id, AssigneeId FROM PermissionSetAssignment 
                WHERE AssigneeId IN : userIds AND PermissionSetId =: PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID];
            List<User> existingUserWithProf = [Select Id from User where id IN : userIds and ( Profile.Name =: PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME OR Profile.Name =: PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME OR Profile.Name = :PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER_PP)];
            if(psa.isEmpty() && existingUserWithProf.isEmpty()){
                return false;
            }
            return true;
        }
        return false;
     }
     
     
     public static Boolean checkForExistingPUR(String email)
     {
       List<Partner_User_Request__c> existingPur = new List<Partner_User_Request__c>();
       existingPur = [Select Id,Name from Partner_User_Request__c where email__c =:email and (Status__c = 'Awaiting Approval' or Status__c = 'Awaiting Sales Ops')];
       if(existingPur.size() > 0)
       {
          return true;
        }else{
          return false;
        }
     }
     
    public static Boolean checkInternalUser(String email)
    {
       List<User> existingUser = new List<User>();
       Boolean standUser = false;
       existingUser = [SELECT id,UserType FROM User WHERE Email =: email AND IsActive = true];      
       if(existingUser.size() > 0)
       {
       	for(User eachuser : existingUser)
       	 {
       	   	if(eachuser.UserType == 'Standard')
       	   	{
       	     standUser = true;	
       	   	}
       	 }
      }  
      if(standUser){ return true; } else { return false; }
    }

    // Modified for Adding Job Title.
    public static String processRequest(String firstName, String lastName, String companyName, String country, String email, String jobTitle, String partnerType, String pageType){
        Partner_User_Request__c newRequest = new Partner_User_Request__c();
        newRequest.Company_Name__c = companyName;       
        newRequest.Email__c = email;
        newRequest.First_Name__c = firstName;
        newRequest.Last_Name__c = lastName;
		newRequest.Job_Title__c =  jobTitle;      
		newRequest.Partner_Type__c =  partnerType;      
        
        if(pageType == 'as')
            newRequest.Request_Type__c = 'Application Submission';
        else
            newRequest.Request_Type__c = 'Partner Creation';
        Country__c countryRecord = searchCountry(country);
        if(countryRecord != null)
            newRequest.Country__c = countryRecord.id;
        try{
            insert newRequest;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Request submitted for approval automatically.');
            req1.setObjectId(newRequest.id);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1); 
            return 'OK';        
        }
        catch(Exception ex){
            return  'There is some error in submitting you request. Error : ' + ex.getMessage();
        }       
    }   

    public static List<SelectOption> getAllCountries(){
        List<Country__c> countriesList = [SELECT Name FROM Country__c where Name != 'US/Canada' ORDER BY Name];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));
        for(Country__c eachCountry : countriesList){
            SelectOption newOption = new SelectOption(eachCountry.Name, eachCountry.Name);
            options.add(newOption);         
        }
        return options;
    }
    
    private static Country__c searchCountry(String countryName){
        List<Country__c> country = [SELECT id FROM Country__c WHERE Name =:countryName LIMIT 1];
        if(country.size() > 0)
            return country[0];
        else 
            return null;         
    }
}