public without sharing class clsWowRiskAssessment
{
    public WoW_Risk_Assessment__c objWowRiskAssessment{get;set;}
    public string strRequestID{get;set;}
    public string strOpportunityID{get;set;}
    public boolean blnReadOnly{get;set;}
    public boolean blnEditable{get;set;}
    public string sIsReadonly{get;set;}
    public boolean blnShowErrorMsg{get;set;}
    
    public clsWowRiskAssessment()
    {
        blnShowErrorMsg = false;
        objWowRiskAssessment = new WoW_Risk_Assessment__c();
        //Get the Wow Request ID
        strOpportunityID=ApexPages.currentPage().getParameters().get('wowid'); //'aAVZ0000000066JOAQ';
        sIsReadonly = ApexPages.CurrentPage().getParameters().get('view');
        
        if(strOpportunityID.length()>=15)
             strOpportunityID=strOpportunityID.substring(0,15);
        
        system.debug('#OpptyID '+strOpportunityID);
        //strRequestID=[select id from wow_request_form__c where opportunity_id__c =: strOpportunityID and WoW_Status__c <> 'Rejected'].Id;
        system.debug('#WowID '+strRequestID);
        
        
       
        
        //Get the Assigned To on Wow Request to display the Risk Assessment Editable/Read Only
        List<Wow_Request_Form__c> objWowRequest=[select id,AssignTo__c from Wow_Request_Form__c where opportunity_id__c =: strOpportunityID and WoW_Status__c!='Rejected'];
        //Set the flags to controll the display of data
        if(objWowRequest <> null && objWowRequest.size()>0)
        {
            strRequestID=objWowRequest[0].Id;
            system.debug('+++strRequestID+++'+strRequestID);
            system.debug('+++objWowRequest[0].AssignTo__c+++'+objWowRequest[0].AssignTo__c);
            //if(WoWUtility.GlobalUser(UserINfo.getUserId()) || objWowRequest[0].AssignTo__c =='Virtual Team')
            if(objWowRequest[0].AssignTo__c =='Virtual Team'){
                if(WoWUtility.GetProfileName(userinfo.getProfileId())== 'System Administrator' || WoWUtility.GlobalUser(UserINfo.getUserId()) || WoWUtility.IsVirtualTeamExist(string.valueof(strRequestID),UserINfo.getUserId()) || WoWUtility.getSubRegionalUsersForSC(UserINfo.getUserName()))
                    {
                        blnReadOnly=false;
                        blnEditable=true;
                        system.debug('+++if 1+++');
                    }
                else if(WoWUtility.HasReadAccessibility(UserINfo.getProfileId()))
                    {
                        blnReadOnly=true;
                        blnEditable=false;
                        system.debug('+++if 2+++');
                    }
                else        
                    {
                        blnReadOnly=true;
                        blnEditable=false;
                        system.debug('+++yes 1+++');
                    }
            }  
            else
                {
                blnReadOnly=true;
                blnEditable=false;
                system.debug('+++yes 2+++');
                }  
            
            if(sIsReadonly=='yes')
            {
                blnEditable=false;
                blnReadOnly=true;
                system.debug('+++sIsReadonly+++');
            }
        }
           //blnEditable = true;
         //Get Risk Assessment Data
        GetWowRiskAssessmentData();       
    }
    
    //Method to Insert or Update the Ris Assessment Data
    public void SaveData()
    {
       try
       { 
            //if((sIsReadonly!='ýes' || sIsReadonly != null) && blnEditable == true)
            if(blnEditable == true)
            {
                //Get the Wow ID
                objWowRiskAssessment.WoW_Request_Id__c=strRequestID;
                //If it is null then insert risk assessment record else update the record
                if(objWowRiskAssessment.id == null)
                {
                    insert objWowRiskAssessment;
                    WoWUtility.CreateHistory('SC Risk Assessment Sheet Created',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),strRequestID,'Save'),'Virtual Team','Open and Assigned',strRequestID);    
        
                }
                else
                {
                    update objWowRiskAssessment;  
                    WoWUtility.CreateHistory('SC Risk Assessment Sheet Saved',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),strRequestID,'Save'),'Virtual Team','Open and Assigned',strRequestID);    
        
                }    
                GetWowRiskAssessmentData();      
            }
        }
        catch(Exception ex)   
        {
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }    
    }
    
    //Get the Risk Assessment Data based on Wow Request ID
    public void GetWowRiskAssessmentData()
    {
        List<WoW_Risk_Assessment__c> objWowRisk=[select id,name,New_Logo__c,Key_Focus_Account__c,Up_sell_Cross_sell_Opportunity__c,Business_Businss_Expectation__c,Business_Custom_Vision__c,Business_Proposed_Maturity_Leap__c,Technology_Offer_Maturity__c,Technology_Use_Case__c,Technology_Architectural_Composition__c,Deployment_Delivery_Plateform__c,Deployment_Genesys_Competency__c,Deployment_Customer_Competency__c,Support_Genesys_Competency__c,Support_Customer_Competency__c,Support_Delivery__c,Identified_Risk__c,Mitigation_Measures__c,Condition_to_Go_Ahead__c,Business_Score_Value__c,Business_Score_Text__c,Technology_Score_Value__c,Technology_Score_Text__c,Deployment_Score_Value__c,Deployment_Score_Text__c,Support_Score_Value__c,Support_Score_Text__c from WoW_Risk_Assessment__c where WoW_Request_Id__c=:strRequestID];
        
        //If list has data assign to the property
        if(objWowRisk <> null && objWowRisk.size()>0)
            objWowRiskAssessment=objWowRisk[0];
    }
    
}