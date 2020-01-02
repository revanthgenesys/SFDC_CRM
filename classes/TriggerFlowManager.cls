/*
04/19/2013  Naresh Kumar
TriggerFlowManager
This class will prevent multiple calling of same part of code within the same thread of execution of triggers.
*/
public without sharing class TriggerFlowManager { 
      public static Boolean ORDER_BEFORE_UPDATE_TRIGGER = true;
      public static Boolean ORDER_BEFORE_INSERT_TRIGGER = true;
      public static Boolean OPPORTUNITY_BEFORE_UPDATE_TRIGGER = true;
      public static Boolean OPPORTUNITY_AFTER_UPDATE_TRIGGER = true;
      public static Boolean OPPORTUNITY_BEFORE_UPDATE_TRIGGER1 = true;
      public static Boolean ORDER_AFTER_UPDATE_TRIGGER = true;
      public static Boolean QUOTE_BEFORE_UPDATE_TRIGGER = true;
      public static Boolean QUOTE_AFTER_UPDATE_TRIGGER = true;
      public static Boolean QUOTEPRODUCT_AFTER_UPDATE_TRIGGER = true; 
      public static Boolean SERVICECONTRACT_AFTER_UPDATE_TRIGGER = true;
      public static Boolean QUOTE_SENT_TO_CUSTOMER_POPULATION = true;
      public static Boolean QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;
      public static Boolean ORDER_AFTER_ACCOUNT_INFO_POPULATION = true;
      public static Boolean ORDER_AFTER_SCLINES_POPULATE = true;
      public static Boolean SC_AFTER_ENTITLEMENT_UPDATION = true;
      public static Boolean ORDER_AFTER_SC_FIELDS_UPDATION = true; 
      public static Boolean CONTACT_AFTER_ENABLE_PARTNER_PORTAL = true;
      public static Order__c CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK = null;
      public static Boolean SERVICECONTRACT_AFTER_IMPORTANT_SCORE_UPDATE = true;
      public static Boolean CASE_IMPORTSCORE_FIELD_UPDATES = true;
      public static Boolean isPublic = false;
      public static Boolean ACCOUNT_AFTER_UPDATE_CONTACT_USERS = true;
      public static Boolean SEND_SOUND_BITE_SURVEY = true;
      public static Boolean PLATEFORM_PRIMARY_FOR_PREMISE = true;
      public static Boolean POPULATE_PARENT_OPP_FIELDS = true;
      public static Boolean POPULATE_PPU_ORDER_TOTAL = true;
      public static Boolean GENERATE_OPPORTUNITY_QUOTE_SC = true;
      public static Boolean ORDER_LINE_ITEM_DECLINE_MAINT = true;
      public static Boolean OPPORTUNITY_SML_UPDATE = true;
      public static Boolean QUOTE_PRODUCT_SML_UPDATE = true;
      public static Boolean ORDER_LINEITEM_SML_UPDATE = true;
      public static Boolean CONTRACT_LINEITEM_SML_UPDATE = true;      
      public static Boolean START_SML_FUTURE_UPDATE = true; 
      public static Boolean INVOICE_INFO_UPDATE = true;
      public static Boolean ORDER_LINE_INFO_UPDATE = true;
      public static Boolean ACCOUNT_ADDRESS_UPDATE = true;
      public static Boolean ACCOUNT_MERGE_CHECK = true;
      public static Boolean ACCOUNT_INITIALIZE_SML = true;
      public static Boolean POPULATE_ORDER_INFO = true;
      public static Boolean POPULATE_NRO_AND_EDUCATION_INFO_ON_ORDER = true;
      public static Boolean PURECLOUDPROJECT_TRIGGER_RUN = true;
      public static Boolean SUBSCRIPTION_PRODUCT_TRIGGER_RUN = true;
      public static Boolean SC_LI_ENTITLEMENTS_CREATED = true;
      public static Boolean OPP_TOTAL_UPDATE_ON_TERM_CHANGE = true;
      public static Boolean CHECK_SC_AND_CLOUD_DEPLOYMENT = true;
}