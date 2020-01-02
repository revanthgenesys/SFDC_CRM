/* CONSTANTS
 * Class to hold hardcoded values like picklists and record types.
 *
 * Developer: Harish
 * Business Owner: 
 *
 * Scenario:
 * 
 * 
 *
 * History:
 * 03/08/2017, Harish - created CONSTANTS.
 * 03/16/2017, Harish - Added Genesys Care Forecasting.
 * 03/22/2017, Harish - Added Order related.
 */
public with sharing class CONSTANTS {
		
	// order related.
	public static final String ORDER_STATUS_COMPLETED				= 'Completed';
	public static final String ORDER_STATUS_CREDIT 					= 'Credit';

	// Opportunity related.
	public static final String OPP_RT_GENESYSRENEWAL 					= 'Genesys Renewal';
	public static final String OPP_NAME_PPU 							= 'PPU';
	public static final String OPP_NAME_CAS 							= 'CAS';
	
	public static final String OPP_NAME_SPLIT 							= 'Split';

	public static final String OPP_OPPSTATUS_SPLIT						= 'Split';

	// Quote related.

	// Genesys Care Forecasting related.
	public static final String GCF_SUBCATEGORY_FYM 						= 'FYM';
	public static final String GCF_SUBCATEGORY_RENEWAL 					= 'RENEWAL';
	public static final String GCF_SUBCATEGORY_EXPECTED					= 'Expected';
	public static final String GCF_SUBCATEGORY_UPSIDE 					= 'Upside';

	public static final String GCF_REGION_APAC 							= 'APAC';
	public static final String GCF_REGION_EMEA 							= 'EMEA';
	public static final String GCF_REGION_LA							= 'Latin America';
	public static final String GCF_REGION_NA		 					= 'North America';

	public static final String GCF_REVENUETYPE_IR	 					= 'Incremental Revenue';
	public static final String GCF_REVENUETYPE_FYM	 					= 'First Year Maintenance';
	public static final String GCF_REVENUETYPE_BS	 					= 'Billing Schedule';
	public static final String GCF_REVENUETYPE_DR	 					= 'Deferred Revenue';
	public static final String GCF_REVENUETYPE_RR1	 					= 'Revenue Recognition';
	public static final String GCF_REVENUETYPE_RR2	 					= 'Recognized Revenue';

}