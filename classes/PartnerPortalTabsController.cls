public class PartnerPortalTabsController {

    public boolean isPotentialPartner{get;set;}

    public PartnerPortalTabsController (){
        isPotentialPartner = false;
        User currentUser = [SELECT Id, profile.Name, profileId FROM User where id =:Userinfo.getUserId()];
        isPotentialPartner = (currentUser.profile.Name==Label.Potential_Partner_User_Profile_Name || currentUser.profile.Name==Label.Customer_Portal_EndUser_PP)?true:false;
    }
}