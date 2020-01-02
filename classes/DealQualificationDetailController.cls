//Naresh Kumar	04/07/2017	Controller for the VF page used on opportunity layout
public class DealQualificationDetailController {
    // will contain all the DQs for a particular opportunities
    public List<Deal_Qualification__c> list_OfDQs {get; private set;}
	// contains base url
    public String strBaseURL {get; private set;}
    // contains opportunity id
    public String strOppId {get; private set;}
    // whether opportunity is locked for partner user or not
    public Boolean blnIsOppApproved {get; private set;}
    // whether it's a portal user or not
    public Boolean blnPortalUser {get; private set;}
    // whether to show DQ button or not
    public Boolean blnShowDQButton {get; private set;}
    //Constructor
    public DealQualificationDetailController(ApexPages.StandardController stdCtrl){
        // getting the base url depending upon user logged in
    	strBaseURL = UserInfo.getUserType() == 'PowerPartner' ? '/partner' : '/apex';   
        // getting opportunity id
        strOppId = stdCtrl.getId();
        // populating whether it's portal user or not
    	blnPortalUser = UserInfo.getUserType() == 'PowerPartner';
        blnIsOppApproved = true;
        blnShowDQButton = true;
        if(blnPortalUser){
            // getting opportunity record
            Opportunity objOpp = [SELECT Partner_Opportunity_Status__c, Lines_of_Businesses__c, Primary_Line_of_Business__c
                                  FROM Opportunity WHERE id =: strOppId];
            // populating whether the opportunity is approved or not
            blnIsOppApproved = objOpp.Partner_Opportunity_Status__c == 'Approved' ? true : false;
            
            // if pure connect don't show the new DQ button
            if(objOpp.Lines_of_Businesses__c != 'PureConnect' || objOpp.Primary_Line_of_Business__c != 'On Premise')
                blnShowDQButton = false;
    	}
        if(blnPortalUser)
            list_OfDQs = [SELECT id, Name, Pricing_Type__c, Pricing_Model__c, Offering_Type__c, Platform_Type__c, Status__c, DQ_Page_Name__c 
                FROM Deal_Qualification__c WHERE Opportunity__c =: strOppId AND Type__c =: DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL
                AND Offering_Type__c =: QuoteUtil.OFFERING_TYPE_CIC];        
        else
            list_OfDQs = [SELECT id, Name, Pricing_Type__c, Pricing_Model__c, Offering_Type__c, Platform_Type__c, Status__c, DQ_Page_Name__c 
                FROM Deal_Qualification__c WHERE Opportunity__c =: strOppId AND Type__c =: DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL];        
    }
}