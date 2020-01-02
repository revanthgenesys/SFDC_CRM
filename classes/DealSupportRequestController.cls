//Naresh Kumar  01/02/2015
public with sharing class DealSupportRequestController {
    public String oppId {get;set;}
    public String accId {get;set;}
    public Account accnt {get;set;}   
    Public String accname {get;set;}
    public Opportunity oppt{get;set;} 
    Public String opptname {get;set;}
    public List<GCR__c> gcrs {get;set;}
    public Boolean showGrid {get;set;}
    public String gcrPageParams {get;set;}
    public string strUserID{get;set;}
    public Boolean blnIsPartner {get; private set;}
    public Wow_Request_Form__c SCEForm {get;set;}
    public Deal_Support__c DealSupport {get;set;}
    public Opportunity objOpp{get;set;}
    public  DSR_SCEngagement__c dsr{get;set;}
    //Not Used                                             
    public  DSR_SCEngagement__c dsrpart{get;set;}
    public String PartnerDSRID{get;set;}                                     
    
    public DealSupportRequestController(){
                                              
        //oppId = Apexpages.currentPage().getParameters().get('oppId');
        //accId = Apexpages.currentPage().getParameters().get('accId');
        
         if(Apexpages.currentPage().getParameters().get('oppId') != null && Apexpages.currentPage().getParameters().get('oppId') != '')
         {
           oppId = Apexpages.currentPage().getParameters().get('oppId');
           
           oppt = [select id, Name,Accountid, account.name from Opportunity where id=: oppId ];           
           opptname = EncodingUtil.URLENCODE(oppt.name,'UTF-8');          
           accnt = [SELECT id,Name from account where id =: oppt.Accountid];           
           accname = EncodingUtil.URLENCODE(accnt.name,'UTF-8');
         }
           
        if(Apexpages.currentPage().getParameters().get('accId') != null)
        {   
           accId = Apexpages.currentPage().getParameters().get('accId');
           accnt = [SELECT id,Name from account where id =: accId ];
           accname = accnt.name.replace('\'', '');
           }
        
        
        showGrid = false;
        gcrPageParams = '';
        strUserID=UserInfo.getUserID();
        populateGCRs();
        blnIsPartner = UserInfo.getUserType() == 'PowerPartner';
        
        //Check if SCE1.0 DSR is already exists for this Opportunity
        if(oppId != null){
        List<Wow_Request_Form__c> listSCEForm = [SELECT Id, Name, Opportunity_Id__c FROM Wow_Request_Form__c where Opportunity_Id__c=:oppId ORDER BY CreatedDate DESC LIMIT 1];
        if(listSCEForm.size() > 0) {
            SCEForm = listSCEForm[0];
        }
        }

        //This is not required but it is in UAT so it is commented - Jitendra 02/08/2018
        //List<Deal_Support__c> listDealSupport = new List<Deal_Support__c>([select Id, Name, PS_POR_Reference__c from Deal_Support__c where Opportunity__c =:oppId and Support_Area__c ='POR Review' ORDER BY CreatedDate DESC LIMIT 1]);
        //if(listDealSupport.size()>0) DealSupport = listDealSupport[0];
        
        //Check if SCE2.0 DSR is already exists for this Opportunity
        if(oppId != null){
            List<DSR_SCEngagement__c> lstDsr = [Select Id,SC_Engagement_Status__c from DSR_SCEngagement__c where Opportunity_ID__c =:oppId and SC_Engagement_Status__c != 'Rejected' and Is_partner_DSR__c = false ORDER BY createddate DESC];
            if(lstDsr.size() >0)
                dsr = lstDsr[0];
        }
    }
    
    private void populateGCRs(){
        if(oppId != null){
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE Opportunity__c =: oppId order by createddate desc];
            gcrPageParams = '&oppId='+ oppId;
        }
        else if(accId != null){
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE Account__c =: accId order by createddate desc];
            gcrPageParams = '&accId='+ accId;
        }
        else
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE CreatedById =: UserInfo.getUserId()  order by createddate desc];
        if(!gcrs.isEmpty()){
            showGrid = true;
        }       
    }
}