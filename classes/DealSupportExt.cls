/*
Modified By: Swastika on Apr/19/2017 to check whether the user is Partner
*/
public with sharing class DealSupportExt 
{
    public List<Deal_Support__c> list_POR {get; private set;}  
    public List<Deal_Support__c> list_ToolsSystems {get; private set;}
    public List<Deal_Support__c> list_Finance {get; private set;}
    public List<Deal_Support__c> list_Pricing {get; private set;}
    public List<Deal_Support__c> list_DealFactory {get; private set;}
    public List<Deal_Support__c> list_PS {get; private set;}
    public List<Deal_Support__c> list_CustomerCare {get; private set;}
    public List<Deal_Support__c> list_BusinessConsulting {get; private set;}
    public List<Deal_Support__c> list_ProductManagement {get; private set;}
    public List<Deal_Support__c> list_SalesOps {get; private set;}
    public List<Deal_Support__c> list_QuoteRequest {get; private set;} 
    public List<Deal_Support__c> list_Transactionalhelp {get; private set;} 
   
    public String strRecordId {get; private set;}
    public String strRecordName {get; private set;}
    public String strOppName {get; private set;}
    public String strAccName {get; private set;}
    public String strAccId {get; private set;}
    public Boolean blnIsAccount {get; private set;}
    public Boolean blnIsPartnerUser {get; private set;}
    public Boolean blnIsPartnerUserNoOpp {get; private set;}
    public Boolean hidePsServices {get; private set;}  
    
    public  DSR_SCEngagement__c dsr{get;set;}
    public  DSR_SCEngagement__c dsrpart{get;set;}
    public String PartnerDSRID{get;set;}
    public string strUserID{get;set;}
    public string OppId{get;set;}
      
      public DealSupportExt(ApexPages.StandardController controller) {
        blnIsPartnerUserNoOpp = true;
        strRecordId = ApexPages.currentPage().getParameters().get('objid');        
        blnIsPartnerUser = UserInfo.getUserType() == 'PowerPartner'; //'PowerCustomerSuccess'//added by swastika on Apr/19/2017 to check the current user profile is partner user          
        
        
        if(strRecordId != null){
          if(strRecordId.startsWith('001'))
          {
              blnIsAccount = true;
              strRecordName = [SELECT Name FROM Account WHERE Id = :strRecordId].Name;
              hidePsServices = true;
          }       
          if(strRecordId.startsWith('006'))
          {
              blnIsAccount = false;
               OppId = strRecordId;
              opportunity opp  = [SELECT Name,account.name,accountid FROM Opportunity WHERE Id = :strRecordId];
              strOppName = opp.Name;
              strRecordName = opp.Name;
              strAccName = opp.account.name;
              strAccId = opp.accountid;
              hidePsServices = false;
              
              List<DSR_SCEngagement__c> lstDsr = [Select Id,SC_Engagement_Status__c from DSR_SCEngagement__c where Opportunity_ID__c =:strRecordId and SC_Engagement_Status__c != 'Rejected' and Is_Partner_DSR__c=: false ORDER BY createddate DESC];
                    if(lstDsr.size() >0)
                        dsr = lstDsr[0];

                //Check if SCE2.0 Partner DSR is already exists for this Opportunity

                    List<DSR_SCEngagement__c> lstDsr1 = [Select Id,SC_Engagement_Status__c from DSR_SCEngagement__c where Opportunity_ID__c =:strRecordId and SC_Engagement_Status__c != 'Rejected' and Is_Partner_DSR__c=: true ORDER BY createddate DESC];
                    if(lstDsr1.size() >0)
                    {
                        system.debug('enter');
                        dsrpart = lstDsr1[0];
                        PartnerDSRID = lstDsr1[0].Id;
                    }    
          } 
        }  
        
        if((strRecordId == null || strRecordId == '') && blnIsPartnerUser){
            blnIsPartnerUserNoOpp = false;  
        }
        
          
          fetchDealSupportRecords();
      }
    
  
    
  
    
    public DealSupportExt() 
    {
        strRecordId = ApexPages.currentPage().getParameters().get('objid');
        
        if(strRecordId != null){
        
        if(strRecordId.startsWith('001'))
        {
            blnIsAccount = true;
            strAccName = [SELECT Name FROM Account WHERE Id = :strRecordId].Name;
        }
            
        if(strRecordId.startsWith('006'))
        {
            blnIsAccount = false;
            opportunity opp = [SELECT Name,account.name,accountid FROM Opportunity WHERE Id = :strRecordId];
            strOppName = opp.Name;
            strAccName = opp.account.name;
            strAccId = opp.accountid;
        }
        
        }
        fetchDealSupportRecords();
    }
    
    
    public void fetchDealSupportRecords()
    {
        list_ToolsSystems = new List<Deal_Support__c>();
        list_Finance = new List<Deal_Support__c>();
        list_Pricing = new List<Deal_Support__c>();
        list_DealFactory = new List<Deal_Support__c>();
        list_PS = new List<Deal_Support__c>();
        list_CustomerCare = new List<Deal_Support__c>();
        list_BusinessConsulting = new List<Deal_Support__c>();
        list_ProductManagement = new List<Deal_Support__c>();
        list_SalesOps = new List<Deal_Support__c>();
        list_POR = new List<Deal_Support__c>();
        list_QuoteRequest = new List<Deal_Support__c>();
        list_Transactionalhelp = new List<Deal_Support__c>();
        
        List<Deal_Support__c> list_DSRecords;
        //2 lines commented by Ankit and added 1 line 
        /*if(blnIsAccount)
            list_DSRecords = [SELECT Id,Subject__c,Name,Priority__c,Status__c,LastModifiedDate,Support_Area__c FROM Deal_Support__c
                                   WHERE Opportunity__c = null AND Account__c = :strRecordId ORDER BY CreatedDate DESC];
        else
            list_DSRecords = [SELECT Id,Subject__c,Name,Priority__c,Status__c,LastModifiedDate,Support_Area__c FROM Deal_Support__c
                                   WHERE Opportunity__c = :strRecordId ORDER BY CreatedDate DESC];
        */
         list_DSRecords = [SELECT Id,Subject__c,Name,Priority__c,Status__c,LastModifiedDate,Support_Area__c FROM Deal_Support__c
                                   WHERE Requester__c = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
        
        for(Deal_Support__c objDS : list_DSRecords)
        {
            if(objDS.Support_Area__c == 'Finance')
                list_Finance.add(objDS);
            else if(objDS.Support_Area__c == 'Tools/Systems Support')
                list_ToolsSystems.add(objDS);     
            else if(objDS.Support_Area__c == 'Pricing')
                list_Pricing.add(objDS);
            else if(objDS.Support_Area__c == 'Deal Factory')
                list_DealFactory.add(objDS);
            else if(objDS.Support_Area__c == 'Professional Services')
                list_PS.add(objDS);
            else if(objDS.Support_Area__c == 'Customer Care')
                list_CustomerCare.add(objDS);
            else if(objDS.Support_Area__c == 'Business Consulting')
                list_BusinessConsulting.add(objDS);
            else if(objDS.Support_Area__c == 'Sales Ops')
                list_SalesOps.add(objDS);
            else if(objDS.Support_Area__c == 'Product Management')
                list_ProductManagement.add(objDS);
            else if(objDS.Support_Area__c == 'Quote Request')
                list_QuoteRequest.add(objDS); 
            else if(objDS.Support_Area__c == 'Transactional Help')
                list_Transactionalhelp.add(objDS); 
            /*else if(objDS.Support_Area__c == 'POR Review')
                list_POR.add(objDS);*/
        }
        // Show All PORs related to an Opportunity
        if(String.isNotBlank(strRecordId) && !blnIsAccount)
            list_POR = [SELECT Id,Name,LastModifiedDate,Support_Area__c,POR_Type__c,POR_Disposition__c FROM Deal_Support__c
                             WHERE Support_Area__c = 'POR Review' AND Opportunity__c = :strRecordId ORDER BY CreatedDate DESC];             
    }
}