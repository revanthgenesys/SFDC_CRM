@isTest (seeAllData=true)
public class TestConfig {
	
	static testMethod void TestConfig() { 
	
 System.assertNotEquals(null, Config.CORE_OPP_STAGE_CLOSED_WON);
		
 //System.assertNotEquals(null, Config.CORE_OPP_RTYPE = 'CORE - Opportunity Record Type' ; //PRM01
 //System.assertNotEquals(null, Config.CORE_OPP_RTYPE_APP_PROCESS = 'CORE - Opportunity Record Type Approval Process'; //PRM03
 //System.assertNotEquals(null, Config.CORE_OPP_RTYPE_APP_PROCESS = 'CORE - Opportunity Approval Process'; //PRM03
 //System.assertNotEquals(null, Config.USER_PARTNER = 'PowerPartner' ; //PRM01
 
 System.assertNotEquals(null, Config.USER_PARTNER );
 System.assertNotEquals(null, Config.USER_STANDARD);
 System.assertNotEquals(null, Config.CORE_OPP_BP_STATUS_ALLOCATED);
 System.assertNotEquals(null, Config.ALE_TEAM_MEMBER_ROLE);
 System.assertNotEquals(null, Config.CORE_OPP_BP_STATUS_REJECTED);
 System.assertNotEquals(null, Config.CORE_OPP_BP_STATUS_NOT_ALLOCATED);
 System.assertNotEquals(null, Config.CORE_OPP_BP_STATUS_APPROVED);
 System.assertNotEquals(null, Config.BP_TEAM_MEMBER_ROLE );
 //public static final string[] TM_MONITOR_AD_EMAIL = new String[] {'michael.legrand@kerensen.com', 'fabien.jonot@kerensen.com','didier.comte@alcatel-lucent.fr'};
 System.assertNotEquals(null, Config.TM_MONITOR_AD_EMAIL1);
 System.assertNotEquals(null, Config.TM_MONITOR_AD_EMAIL2);
 System.assertNotEquals(null, Config.TM_MONITOR_AD_EMAIL3);
 System.assertNotEquals(null, Config.TM_VALUE_SEPARATOR);
 System.assertNotEquals(null, Config.TM_USER_NAME_TEST1);
 System.assertNotEquals(null, Config.TM_USER_NAME_TEST2 );
 System.assertNotEquals(null, Config.ASSET_DEFAULT_MANUFACTURER);

// Add for EMG Project - 18/11/2010 - OSP (olivier.spehner@kerensen.com)
//Record type label : ESD - Opportunity Approval Process
 System.assertNotEquals(null, Config.CORE_OPP_RTYPE_APP_PROCESS);
//Record type label : ESD - Opportunity Record Type
 System.assertNotEquals(null, Config.CORE_OPP_RTYPE );
 System.debug('#######  Config.CORE_OPP_RTYPE ' + Config.CORE_OPP_RTYPE);
 
 System.assertNotEquals(null, Config.EMG_BUSINESS_PARTNER_RECORDTYPE );
 System.assertNotEquals(null, Config.EMG_BUSINESS_PARTNER_OWNER );
 System.assertNotEquals(null, Config.EMG_STATUS_GET_REJECTED);

  //RFP
  System.assertNotEquals(null, Config.RT_RFP_Refused );
  System.assertNotEquals(null, Config.RT_RFP_Accepted );
  System.assertNotEquals(null, Config.RT_RFP_PROPOSAL_ACCEPTED);
  System.assertNotEquals(null, Config.RT_RFP_PROPOSAL_REFUSED );
  System.assertNotEquals(null, Config.ACCEPTED_RFP_FORM_TEMPLATE);
  System.assertNotEquals(null, Config.REJECTED_RFP_FORM_TEMPLATE );
  System.assertNotEquals(null, Config.SUBMIT_RFP_FORM_TEMPLATE );
  System.assertNotEquals(null, Config.PENDING_RFP_FORM_TEMPLATE);

  // OQM 
  System.assertNotEquals(null, Config.INACTIVE);
  System.assertNotEquals(null, Config.ACTIVE);
  System.assertNotEquals(null, Config.EMEA );
  System.assertNotEquals(null, Config.APAC );
  System.assertNotEquals(null, Config.BP_CONTACT_EMEA);
  System.assertNotEquals(null, Config.BP_CONTACT_NA);
  System.assertNotEquals(null, Config.RFP_QUEUE);
  System.assertNotEquals(null, Config.RFP_MAIL );
  
  System.assertNotEquals(null, Config.RT_OQM_Submission );
  System.assertNotEquals(null, Config.RT_RFP_Submission);
  
  System.assertNotEquals(null, Config.RT_OQM_ACCEPTED );
  System.assertNotEquals(null, Config.RT_OQM_REFUSED );
  System.assertNotEquals(null, Config.OQM_STATUS_PENDING );
  System.assertNotEquals(null, Config.OQM_STATUS_SUBMIT );
  System.assertNotEquals(null, Config.OQM_STATUS_REJECTED);
  System.assertNotEquals(null, Config.OQM_STATUS_ACCEPTED );
 
  //Opportunity Stage
  
 System.assertNotEquals(null, Config.OPP_STAGE4);

 System.assertNotEquals(null, Config.OPP_STAGE5 );
 System.assertNotEquals(null, Config.OPP_STAGE6 );
 System.assertNotEquals(null, Config.OPP_STAGE7);
 
 System.assertNotEquals(null, Config.OPP_STAGE81 );
 System.assertNotEquals(null, Config.OPP_STAGE82 );
 System.assertNotEquals(null, Config.OPP_STAGE9 );
 System.assertNotEquals(null, Config.OPP_STAGE10 );
 System.assertNotEquals(null, Config.BP_ROLE );
 
 System.assertNotEquals(null, Config.PROFIL_ADMIN_ID ); 
	}

}