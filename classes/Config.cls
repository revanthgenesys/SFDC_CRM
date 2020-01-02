public class Config {
 
 public static final string CORE_OPP_STAGE_CLOSED_WON = Config__c.getValues('CORE_OPP_STAGE_CLOSED_WON').Value__c; //AP01
 //public static final string CORE_OPP_RTYPE = 'CORE - Opportunity Record Type' ; //PRM01
 //public static final string CORE_OPP_RTYPE_APP_PROCESS = 'CORE - Opportunity Record Type Approval Process'; //PRM03
 //public static final string CORE_OPP_RTYPE_APP_PROCESS = 'CORE - Opportunity Approval Process'; //PRM03
 //public static final string USER_PARTNER = 'PowerPartner' ; //PRM01
 
 public static final string USER_PARTNER = Config__c.getValues('USER_PARTNER').Value__c; //PRM01
 public static final string USER_STANDARD = Config__c.getValues('USER_STANDARD').Value__c; //PRM01 test method
 public static final string CORE_OPP_BP_STATUS_ALLOCATED = Config__c.getValues('CORE_OPP_BP_STATUS_ALLOCATED').Value__c; //PRM01
 public static final string ALE_TEAM_MEMBER_ROLE =  Config__c.getValues('ALE_TEAM_MEMBER_ROLE').Value__c;//PRM01
 public static final string CORE_OPP_BP_STATUS_REJECTED = Config__c.getValues('CORE_OPP_BP_STATUS_REJECTED').Value__c; //PRM03
 public static final string CORE_OPP_BP_STATUS_NOT_ALLOCATED = Config__c.getValues('CORE_OPP_BP_STATUS_NOT_ALLOCATED').Value__c; //PRM03
 public static final string CORE_OPP_BP_STATUS_APPROVED = Config__c.getValues('CORE_OPP_BP_STATUS_APPROVED').Value__c; //PRM04
 public static final string BP_TEAM_MEMBER_ROLE =  Config__c.getValues('BP_TEAM_MEMBER_ROLE').Value__c;//PRM04
 //public static final string[] TM_MONITOR_AD_EMAIL = new String[] {'michael.legrand@kerensen.com', 'fabien.jonot@kerensen.com','didier.comte@alcatel-lucent.fr'};
 public static final string TM_MONITOR_AD_EMAIL1 = Config__c.getValues('TM_MONITOR_AD_EMAIL1').Value__c; // TM02
 public static final string TM_MONITOR_AD_EMAIL2 = Config__c.getValues('TM_MONITOR_AD_EMAIL2').Value__c; // TM02
 public static final string TM_MONITOR_AD_EMAIL3 = Config__c.getValues('TM_MONITOR_AD_EMAIL3').Value__c; // TM02
 public static final string TM_VALUE_SEPARATOR = Config__c.getValues('TM_VALUE_SEPARATOR').Value__c;
 public static final string TM_USER_NAME_TEST1 = Config__c.getValues('TM_USER_NAME_TEST1').Value__c;
 public static final string TM_USER_NAME_TEST2 = Config__c.getValues('TM_USER_NAME_TEST2').Value__c;
 public static final string ASSET_DEFAULT_MANUFACTURER = Config__c.getValues('ASSET_DEFAULT_MANUFACTURER').Value__c;

// Add for EMG Project - 18/11/2010 - OSP (olivier.spehner@kerensen.com)
//Record type label : ESD - Opportunity Approval Process
 public static final string CORE_OPP_RTYPE_APP_PROCESS = Config__c.getValues('CORE_OpportunityApprovalProcess').Value__c;
//Record type label : ESD - Opportunity Record Type
 public static final string CORE_OPP_RTYPE = Config__c.getValues('COREOpportunityRecordType').Value__c;
 public static final string EMG_BUSINESS_PARTNER_RECORDTYPE = Config__c.getValues('EMGBusinessPartnerRecordType').Value__c;
 public static final string EMG_BUSINESS_PARTNER_OWNER = Config__c.getValues('EMGBusinessPartnerOwner').Value__c;
 public static final string EMG_STATUS_GET_REJECTED = Config__c.getValues('EMGStatusGetRejected').Value__c;

  //RFP
  public static final string RT_RFP_Refused = Config__c.getValues('RT_RFP_Refused').value__c;
  public static final string RT_RFP_Accepted = Config__c.getValues('RT_RFP_Accepted').value__c;
  public static final string RT_RFP_PROPOSAL_ACCEPTED = Config__c.getValues('RT_RFP_PROPOSAL_ACCEPTED').Value__c;
  public static final string RT_RFP_PROPOSAL_REFUSED  = Config__c.getValues('RT_RFP_PROPOSAL_REFUSED').Value__c;
  public static final string ACCEPTED_RFP_FORM_TEMPLATE = Config__c.getValues('ACCEPTED_RFP_FORM_TEMPLATE').value__c;
  public static final string REJECTED_RFP_FORM_TEMPLATE = Config__c.getValues('REJECTED_RFP_FORM_TEMPLATE').value__c;
  public static final string SUBMIT_RFP_FORM_TEMPLATE = Config__c.getValues('SUBMIT_RFP_FORM_TEMPLATE').value__c;
  public static final string PENDING_RFP_FORM_TEMPLATE = Config__c.getValues('PENDING_RFP_FORM_TEMPLATE').value__c; 

  // OQM 
  public static final string INACTIVE = Config__c.getValues('INACTIVE_OFFER').Value__c;
  public static final string ACTIVE   = Config__c.getValues('ACTIVE_OFFER').Value__c;
  public static final string EMEA = Config__c.getValues('REGION_EMEA').Value__c;
  public static final string APAC = Config__c.getValues('REGION_EMEA').Value__c;
  public static final string BP_CONTACT_EMEA = Config__c.getValues('BID_PROPOSAL_CONTACT_EMEA').Value__c;
  public static final string BP_CONTACT_NA   = Config__c.getValues('BID_PROPOSAL_CONTACT_NA').Value__c;
  public static final string RFP_QUEUE   = Config__c.getValues('RFP_QUEUE').Value__c;
  public static final string RFP_MAIL   = Config__c.getValues('RFP_MAIL').Value__c;
  
  public static final string RT_OQM_Submission = Config__c.getValues('RT_OQM_Submission').Value__c;
  public static final string RT_RFP_Submission = Config__c.getValues('RT_RFP_Submission').Value__c;
  
  public static final string RT_OQM_ACCEPTED = Config__c.getValues('RT_OQM_PROPOSAL_ACCEPTED').Value__c;
  public static final string RT_OQM_REFUSED  = Config__c.getValues('RT_OQM_PROPOSAL_REFUSED').Value__c;
  public static final string OQM_STATUS_PENDING  = Config__c.getValues('OQM_STATUS_PENDING').Value__c;
  public static final string OQM_STATUS_SUBMIT = Config__c.getValues('OQM_STATUS_SUBMIT').Value__c;
  public static final string OQM_STATUS_REJECTED = Config__c.getValues('OQM_STATUS_REJECTED').Value__c;
  public static final string OQM_STATUS_ACCEPTED = Config__c.getValues('OQM_STATUS_ACCEPTED').Value__c;
 
  //Opportunity Stage
  
 public static final string OPP_STAGE4 = Config__c.getValues('OPP_STAGE4').Value__c;

 public static final string OPP_STAGE5 = Config__c.getValues('OPP_STAGE5').Value__c;
 public static final string OPP_STAGE6 = Config__c.getValues('OPP_STAGE6').Value__c;
 public static final string OPP_STAGE7 = Config__c.getValues('OPP_STAGE7').Value__c;
 
 public static final string OPP_STAGE81 = Config__c.getValues('OPP_STAGE81').Value__c;
 public static final string OPP_STAGE82 = Config__c.getValues('OPP_STAGE82').Value__c;
 public static final string OPP_STAGE9 = Config__c.getValues('OPP_STAGE9').Value__c;
 public static final string OPP_STAGE10 = Config__c.getValues('OPP_STAGE10').Value__c;
 public static final string BP_ROLE = Config__c.getValues('BP_ROLE').Value__c;
 
 public static final string PROFIL_ADMIN_ID = Config__c.getValues('PROFIL_ADMIN_ID').Value__c; 
 
}