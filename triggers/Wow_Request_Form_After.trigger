trigger Wow_Request_Form_After on Wow_Request_Form__c(after insert,before update)
{ 
   // if(Util.Bypass_Trigger_Chk)
    //    return;
    for(Wow_Request_Form__c wow: Trigger.New) {      
        List<Wow_Request_User__c> lst_WowUser=New List<Wow_Request_User__c>();
        Wow_Request_User__c objWowUser=new Wow_Request_User__c();    //To store the Wow request user
        user objMgr=new user();  //to store the manager
        
          
        //Find the user and user type is not exist in Wow_Request_User__c then insert in Wow_Request_User__c
        if (Trigger.isInsert) //for insert of Wow then insert the AE information
            {
            //Find the manager of user 
            objMgr=[SELECT ManagerId FROM USER WHERE Id=:wow.AE__c];
            
            //Find the AE Id in Wow_Request_User__c
            lst_WowUser=[SELECT Id FROM Wow_Request_User__c Where UserId__c=:wow.AE__c AND User_Type__c='AE'];
            If(lst_WowUser.Size()==0)
                {
                    objWowUser.UserId__c=wow.AE__c;
                    objWowUser.User_Type__c='AE';
                    if(objMgr!=null)
                        objWowUser.ManagerId__c=objMgr.ManagerId; 
                    insert objWowUser;    
                }
            }
        //Update
        if (Trigger.isUpdate)
           {
            //For Wow SC user
            //Find the manager of SC user 
            if(wow.SE__c!=null) 
                {
                objMgr=null; //initialize the manager object
                objMgr=[SELECT ManagerId FROM USER WHERE Id=:wow.SE__c];
                //Find the AE Id in Wow_Request_User__c
                lst_WowUser=[SELECT Id FROM Wow_Request_User__c Where UserId__c=:wow.SE__c AND User_Type__c='VT'];
                if(lst_WowUser.size()==0)
                    {
                    objWowUser.UserId__c=wow.SE__c ;
                    objWowUser.User_Type__c='VT';
                    if(objMgr!=null)
                        objWowUser.ManagerId__c=objMgr.ManagerId; 
                    insert objWowUser;  
                    }
                }
               
             //Find the manager of BC user 
            if(wow.BC__c!=null) 
                {
                objMgr=null; //initialize the manager object
                objMgr=[SELECT ManagerId FROM USER WHERE Id=:wow.BC__c];
                //Find the SC Id in Wow_Request_User__c
                lst_WowUser=null;
                lst_WowUser=[SELECT Id FROM Wow_Request_User__c Where UserId__c=:wow.BC__c AND User_Type__c='VT'];
                objWowUser=new Wow_Request_User__c(); 
                if(lst_WowUser.size()==0)
                    {
                    objWowUser.UserId__c=wow.BC__c;
                    objWowUser.User_Type__c='VT';
                    if(objMgr!=null)
                        objWowUser.ManagerId__c=objMgr.ManagerId; 
                    insert objWowUser;  
                    }
                }  
                
            //Find the manager of SEM user 
            /*if(wow.SEM__c!=null) 
                {
                objMgr=null; //initialize the manager object
                objMgr=[SELECT ManagerId FROM USER WHERE Id=:wow.SEM__c];
                //Find the SC Id in Wow_Request_User__c
                lst_WowUser=null;
                lst_WowUser=[SELECT Id FROM Wow_Request_User__c Where UserId__c=:wow.SEM__c AND User_Type__c='VT'];
                objWowUser=new Wow_Request_User__c(); 
                if(lst_WowUser.size()==0)
                    {
                    objWowUser.UserId__c=wow.SEM__c;
                    objWowUser.User_Type__c='VT';
                    if(objMgr!=null)
                        objWowUser.ManagerId__c=objMgr.ManagerId; 
                    insert objWowUser;  
                    }
                }*/    
            }
     }       
}