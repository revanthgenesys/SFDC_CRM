/*
Class Name = GenesysUtility
Purpose = Class represent the common function/logic instead of writing code on multiple components. User Story# S-647816, Task# T-848005
Developed By = Sushen Adhikary
Developed Date = 26-Nov-2019
Modified By = Sushen Adhikary
Modified Date = 28-Nov-2019
*/
public class GenesysUtility 
{
    /*
    Method Name = isPartnerPortalUser
    Purpose = Method is written for checking Parner User. If logged-in user is Partner Portal User then it return true else false. User Story# S-647816, Task# T-848005     
    Developed By = Sushen Adhikary
    Developed Date = 26-Nov-2019
    Modified By = Sushen Adhikary
    Modified Date = 28-Nov-2019
    */
    public static Boolean isPartnerPortalUser()
    {       
        String profileName = [SELECT Name FROM Profile WHERE Id=: Userinfo.getProfileId() LIMIT 1].Name;
        for(String pn : System.Label.PartnerProfileNames.trim().split(',')){
            if(profileName == pn){
                return true;
            }
        }       
        return false;
    }
}