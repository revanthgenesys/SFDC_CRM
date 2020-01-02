/*Mukunth created class for INC0416843 - DQ Special Offers Sub-aprpovers
    To display DQs pending for Finance function sub-approval for special offer terms
*/
public with sharing class dqSubApprovalStatus {
    
    //public List<Quote_Approval__c> quoteApprovals {get;set;}
    public list<DQSubAppWrapperClass> dqSubApprwrppr{get;set;}
    public Boolean showGrid {get;set;}
    
    public dqSubApprovalStatus(){
		
		try{
			profile usrPrfl = [Select Id,Name from profile where Id=:UserInfo.getProfileId()];
			list<string> adminProf = Label.DQAdminProfiles.split(';');
			boolean isAdminDQ = adminProf.contains(usrPrfl.name)?true:false;
			string usrEmail = UserInfo.getUserEmail();
			Id userId = UserInfo.getUserId();
			set<string> region = new set<string>();
			set<string> financeFn = new set<string>();
			list<string> finFn = new list<string>();
			map<string,list<string>> finToAddresses = new map<string,list<string>>();
			map<string,DQ_Special_Offers__c> dqSpecOffersCS = DQ_Special_Offers__c.getAll();
			map<string,string> financeToFld =new map<string,string>();
			
			
			financeToFld.put('Revenue','Deal_Qualification__r.Revenue_approval__c');
			financeToFld.put('Order Management/Billing','Deal_Qualification__r.Order_Mgmt_Billing_approval__c');
			financeToFld.put('Credit and Collections','Deal_Qualification__r.Credit_and_Collections_approval__c');
			financeToFld.put('Legal','Deal_Qualification__r.Legal_approval__c');
			
			for(string finReg: dqSpecOffersCS.keySet()){
				DQ_Special_Offers__c dqCS = dqSpecOffersCS.get(finReg);
				if((dqCS.Primary_Contact_Email__c != null && (dqCS.Primary_Contact_Email__c).containsIgnoreCase(usrEmail)) 
					|| (dqCS.Back_Up_Contact_Email__c != null && (dqCS.Back_Up_Contact_Email__c).containsIgnoreCase(usrEmail))){
					region.add(dqCS.Region__c);
					financeFn.add(dqCS.Finance_Function__c);
				}
				if(dqCS.Additional_Email_Addresses__c != null){
					for(string adtnEmail:(dqCS.Additional_Email_Addresses__c).split(';')){
						if(adtnEmail.containsIgnoreCase(usrEmail)){
							region.add(dqCS.Region__c);
							financeFn.add(dqCS.Finance_Function__c);
						}
					}
				}
				
			}
			finFn.addAll(financeFn);
			System.Debug('region--->'+region);
			System.Debug('financeFn--->'+finFn);
			
			dqSubApprwrppr = new list<DQSubAppWrapperClass>();
			List<Quote_Approval__c> quoteApprovals = new List<Quote_Approval__c>();
			
			string query1 = 'SELECT id,Reason_Name__c,Deal_Qualification__c,Deal_Qualification__r.Name,Deal_Qualification__r.Req_Revenue_Approval__c,Deal_Qualification__r.Req_Order_Mgmt_Billing_approval__c,';
			query1 += 'Deal_Qualification__r.Req_Credit_Collections_approval__c,Deal_Qualification__r.Req_Legal_approval__c,Deal_Qualification__r.Credit_and_Collections_approval__c,Deal_Qualification__r.Legal_approval__c,';
			query1 += 'Deal_Qualification__r.Opportunity__r.Country_Region__c,Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__c,';
			query1 += 'Deal_Qualification__r.Order_Mgmt_Billing_approval__c,Deal_Qualification__r.Revenue_approval__c FROM Quote_Approval__c WHERE ';
			query1 += 'Status__c = \'' + QuoteApprovalUtil.STATUS_PENDING;
			query1 += '\' AND (BigMachines_Quote__r.BigMachines__Status__c = \'' + QuoteApprovalUtil.QUOTE_STATUS_PENDING + '\' OR Deal_Qualification__r.Status__c = \'' + DealQualificationApprovalUtil.QUOTE_STATUS_PENDING + '\') ';
			query1 += 'AND (Deal_Qualification__r.Revenue_approval__c = \'Pending\' OR Deal_Qualification__r.Order_Mgmt_Billing_approval__c = \'Pending\' ';
			query1 += 'OR Deal_Qualification__r.Credit_and_Collections_approval__c = \'Pending\' OR Deal_Qualification__r.Legal_approval__c = \'Pending\') ';

			if(!isAdminDQ){
				if(region.size()>0){
					query1 += 'AND Deal_Qualification__r.Opportunity__r.Country_Region__c IN :region ';
				}
				/*if(finFn.size()>0){
					if(finFn.size() == 1)
						query1 += 'AND '+financeToFld.get(finFn[0])+' = \'Pending\' ';
					else{
						query1 += 'AND (';
						for(integer i=0;i<=finFn.size()-1;i++){
							query1 += financeToFld.get(finFn[i]) + ' = \'Pending\'';
							if(i != finFn.size()-1)
								query1 += ' OR ';
						}
						query1 += ')';
					}
				}*/
			}
			query1 += ' ORDER BY CreatedDate DESC';
			
			System.Debug('query1--->'+query1);
			
			quoteApprovals = database.query(query1);
			
			
								
			for(Quote_Approval__c quoapp:quoteApprovals){
				Id assignedAppr = quoapp.Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__c;
				if(quoapp.Reason_Name__c != null && (quoapp.Reason_Name__c).containsIgnoreCase('Special') && (quoapp.Reason_Name__c).containsIgnoreCase('Offer')){
					if(quoapp.Deal_Qualification__r.Req_Revenue_Approval__c && quoapp.Deal_Qualification__r.Revenue_approval__c=='Pending' 
						&& (finFn.contains('Revenue') || isAdminDQ || assignedAppr==userId) ){
						DQSubAppWrapperClass dqRec = createDQWrapperRec(quoapp,'Revenue');
						dqSubApprwrppr.add(dqRec);
					}
					if(quoapp.Deal_Qualification__r.Req_Order_Mgmt_Billing_approval__c && quoapp.Deal_Qualification__r.Order_Mgmt_Billing_approval__c=='Pending' 
						&& (finFn.contains('Order Management/Billing') || isAdminDQ || assignedAppr==userId)){
						DQSubAppWrapperClass dqRec1 = createDQWrapperRec(quoapp,'Order Management/Billing');
						dqSubApprwrppr.add(dqRec1);
					}
					if(quoapp.Deal_Qualification__r.Req_Credit_Collections_approval__c && quoapp.Deal_Qualification__r.Credit_and_Collections_approval__c=='Pending' 
						&& (finFn.contains('Credit and Collections') || isAdminDQ || assignedAppr==userId)){
						DQSubAppWrapperClass dqRec2 = createDQWrapperRec(quoapp,'Credit and Collections');
						dqSubApprwrppr.add(dqRec2);
					}
					if(quoapp.Deal_Qualification__r.Req_Legal_approval__c && quoapp.Deal_Qualification__r.Legal_approval__c=='Pending' 
						&& (finFn.contains('Legal') || isAdminDQ || assignedAppr==userId)){
						DQSubAppWrapperClass dqRec3 = createDQWrapperRec(quoapp,'Legal');
						dqSubApprwrppr.add(dqRec3);
					}
				}
			}
			System.Debug('dqSubApprwrppr--->'+dqSubApprwrppr);
			if(dqSubApprwrppr.isEmpty())
				showGrid = false;
			else
				showGrid = true;
		}
		catch(exception e){
			showGrid = false;
			System.Debug('Error--->'+e.getMessage());
			System.Debug('ErrorInLine--->'+e.getLineNumber());
		}
    }
    

    public DQSubAppWrapperClass createDQWrapperRec(Quote_Approval__c quoapp, string finFunc){
        DQSubAppWrapperClass prepDQ = new DQSubAppWrapperClass();
        prepDQ.dqName = quoapp.Deal_Qualification__r.Name;
        prepDQ.status = quoapp.Deal_Qualification__r.Revenue_approval__c;
        prepDQ.assignedApprvr = finFunc;
        prepDQ.region = quoapp.Deal_Qualification__r.Opportunity__r.Country_Region__c;
        prepDQ.dqId = quoapp.Deal_Qualification__c;
        return prepDQ;
    }

    public class DQSubAppWrapperClass{
        public string dqName{get;set;}
        public string status{get;set;}
        public string assignedApprvr{get;set;}
        public Id dqId{get;set;}
        public string region{get;set;}
        public DQSubAppWrapperClass(){
            
        }
    }
    
}