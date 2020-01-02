public class DSR_SC_Engage_Utility {
    
    /**
    *   Class Name  :   CheckSubregionalUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public static Boolean CheckSubregionalUser(String userId, String dsrId){
        Boolean isRegional = false;
        Integer count = [Select count() from DSR_Virtual_Team__c where SCE_ID__c=:dsrID and Virtual_Team_Member_Name__c=:userId and Virtual_User_Role__c=:'Sub Regional Leader'];        
        if(count > 0){
            isRegional = true;
        }
        return isRegional;
    }
    
    
    
    /**
    *   Class Name  :   CheckSalesCOE()
    *   Description :   This method is used to check the current user as SalesCOE
    *   Parameters  : 
    *   Requested By : Debora Lane 16/April/2018
    **/
    public static Boolean CheckSalesCOE(String userEmail){
        Boolean isCOE = false;
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        for(Wow_Sub_Regional_Users__c obj : list_SubRegion)
        {
           if(obj.Subregional_Leader__c == userEmail && obj.Sales_COE__c)
            isCOE = true;
        }
        return isCOE;
    }
    
    
    
    /**
    *   Class Name  :   CheckVTUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public static Boolean CheckVTUser(String userId, String dsrId){
        Boolean isVT = false;        
        Integer count = [Select count() from DSR_Virtual_Team__c where SCE_ID__c=:dsrID and Virtual_Team_Member_Name__c=:userId and Virtual_User_Role__c=:'Virtual Team'];        
        if(count > 0){
            isVT = true;
        }
        return isVT;
    }
    
    
    
    /**
    *   Class Name  :   CheckAEUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public static Boolean CheckAEUser(String userId, String dsrId){
        Boolean isAE = false;
        Integer count = [Select count() from DSR_SCEngagement__c where ID=:dsrID and AE_Name__c=:userId];        
        if(count > 0){
            isAE = true;
        }
        return isAE;
    }
    
    
    
    /**
    *   Class Name  :   CheckAdminUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public static Boolean CheckAdminUser(String userId, String dsrId){
        Boolean isAdmin = false;        
        Integer count = [Select count() from User where Id=:UserId and Profile.Name =: 'System Administrator'];
        if(count > 0){
            isAdmin = true;
        }
        return isAdmin;
    }
    
    
    /**
    *   Class Name  :   checkReadOnly()
    *   Description :   This method is used to check the current user access on DSR
    *   Parameters  :  
    **/
    public static boolean checkReadOnly(String userId, String dsrId, String userEmail){
        boolean isReadOnly = false;        
        if(!CheckAEUser(userId, dsrId) && !CheckSalesCOE(userEmail) && !CheckSubregionalUser(userId, dsrId) && !CheckVTUser(userId, dsrId) && !CheckAdminUser(userId, dsrId)){
            isReadOnly = true;
        }
        return isReadOnly;
    }
}