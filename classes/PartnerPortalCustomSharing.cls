/*
 * Class            : PartnerPortalCustomSharing
 * Description      : A Utility class to for all Partner Portal Custom Sharing requirements.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 public class PartnerPortalCustomSharing {
	
	public static void manageOpportunityTeamAndShareRelatedObjects(List<String> contactIds, List<Opportunity> opportunities){
		// Build the set of Opportunity Ids
		Set<String> opportunityIds = new Set<String>();
		for(Opportunity o: opportunities){
			opportunityIds.add(o.Id);
		}
    	
    	// Build Contact Id and User Id Map
		Map<String, String> partnerContactIdUserIdMap = new Map<String, String>();
		Map<String, String> partnerContactIdAccountIdMap = new Map<String, String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			partnerContactIdUserIdMap.put(u.ContactId, u.Id);
			partnerContactIdAccountIdMap.put(u.ContactId,u.Contact.AccountId);
		} 
		
		// Find all Opportunities where its business partner is one of the accounts of Contact's Account
		Map<Id, List<Opportunity>> accountOpportunitiesMap = new Map<Id, List<Opportunity>>();
		for(Opportunity o: opportunities){
			if(accountOpportunitiesMap.get(o.BusinessPartner__c) != NULL){
				accountOpportunitiesMap.get(o.BusinessPartner__c).add(o);
			} else {
				accountOpportunitiesMap.put(o.BusinessPartner__c, new List<Opportunity>{o});
			}
		}
		
		Map<String, List<BigMachines__Quote__c>> opportunityQuotesMap = new Map<String, List<BigMachines__Quote__c>>();
		for(BigMachines__Quote__c quote : [SELECT Id, BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN :opportunityIds]){
			if(opportunityQuotesMap.get(quote.BigMachines__Opportunity__c) != NULL){
				opportunityQuotesMap.get(quote.BigMachines__Opportunity__c).add(quote);
			} else {
				opportunityQuotesMap.put(quote.BigMachines__Opportunity__c, new List<BigMachines__Quote__c>{quote});
			}
		}
		
		Map<String, List<Order__c>> opportunityOrdersMap = new Map<String, List<Order__c>>();
		for(Order__c order : [SELECT Id, Opportunity__c FROM Order__c WHERE Opportunity__c IN :opportunityIds]){
			if(opportunityOrdersMap.get(order.Opportunity__c) != NULL){
				opportunityOrdersMap.get(order.Opportunity__c).add(order);
			} else {
				opportunityOrdersMap.put(order.Opportunity__c, new List<Order__c>{order});
			}
		}
		
		Map<String, List<Deal_Support__c>> opportunityDealSupportRequestsMap = new Map<String, List<Deal_Support__c>>();
		for(Deal_Support__c dealSupport : [SELECT Id, Opportunity__c FROM Deal_Support__c WHERE Opportunity__c IN :opportunityIds]){
			if(opportunityDealSupportRequestsMap.get(dealSupport.Opportunity__c) != NULL){
				opportunityDealSupportRequestsMap.get(dealSupport.Opportunity__c).add(dealSupport);
			} else {
				opportunityDealSupportRequestsMap.put(dealSupport.Opportunity__c, new List<Deal_Support__c>{dealSupport});
			}
		}
		
		List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();  
		List<BigMachines__Quote__Share> quoteShareRecords = new List<BigMachines__Quote__Share>();
		List<Order__Share> orderShareRecords = new List<Order__Share>();
		List<Deal_Support__Share> dealSupportShareRecords = new List<Deal_Support__Share>();

		Set<String> uniqueQuoteShareObjectIds = new Set<String>();
		Set<String> uniqueOrderShareObjectIds = new Set<String>();
		Set<String> uniqueDealSupportShareObjectIds = new Set<String>();
		
		for(String contactId : partnerContactIdUserIdMap.KeySet()){
			if(accountOpportunitiesMap.get(partnerContactIdAccountIdMap.get(contactId)) != NULL){
				for(Opportunity o : accountOpportunitiesMap.get(partnerContactIdAccountIdMap.get(contactId))){
			
					// Add OpportunityTeamMember's for those opportunities  
					otmList.add(new OpportunityTeamMember(OpportunityId = o.Id, UserId = partnerContactIdUserIdMap.get(contactId), TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit'));
					
					// Share - Current Opportunity's Quotes				
					if(opportunityQuotesMap.get(o.Id) != NULL){
						for(BigMachines__Quote__c quote : opportunityQuotesMap.get(o.Id)){
			      			
			      			if(!uniqueQuoteShareObjectIds.contains(quote.Id + '#' + partnerContactIdUserIdMap.get(contactId))){
				      			quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId = partnerContactIdUserIdMap.get(contactId), AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
				      			uniqueQuoteShareObjectIds.add(quote.Id + '#' + partnerContactIdUserIdMap.get(contactId));
			      			}
							if(!uniqueQuoteShareObjectIds.contains(quote.Id + '#' + o.OwnerId)){
								quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId =  o.OwnerId, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
				      			uniqueQuoteShareObjectIds.add(quote.Id + '#' + o.OwnerId);
							}
						}
					}				

					// Share - Current Opportunity's Orders				
					if(opportunityOrdersMap.get(o.Id) != NULL){
						for(Order__c order : opportunityOrdersMap.get(o.Id)){
			      			if(!uniqueOrderShareObjectIds.contains(order.Id + '#' + partnerContactIdUserIdMap.get(contactId))){
				      			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId = partnerContactIdUserIdMap.get(contactId), AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
				      			uniqueOrderShareObjectIds.add(order.Id + '#' + partnerContactIdUserIdMap.get(contactId));
			      			}
							if(!uniqueOrderShareObjectIds.contains(order.Id + '#' + o.OwnerId)){
				      			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId =  o.OwnerId, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
				      			uniqueOrderShareObjectIds.add(order.Id + '#' + o.OwnerId);
							}
			      			
						}
					}				

					// Share - Current Opportunity's Deal Support Requests				
					if(opportunityDealSupportRequestsMap.get(o.Id) != NULL){
						for(Deal_Support__c dealSupport : opportunityDealSupportRequestsMap.get(o.Id)){
							if(!uniqueDealSupportShareObjectIds.contains(dealSupport.Id + '#' + partnerContactIdUserIdMap.get(contactId))){
				      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = partnerContactIdUserIdMap.get(contactId), AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
				      			uniqueDealSupportShareObjectIds.add(dealSupport.Id + '#' + partnerContactIdUserIdMap.get(contactId));
			      			}
							if(!uniqueDealSupportShareObjectIds.contains(dealSupport.Id + '#' + o.OwnerId)){
				      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = o.OwnerId, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
				      			uniqueDealSupportShareObjectIds.add(dealSupport.Id + '#' + o.OwnerId);
							}
						}
					}				
				}
			}
		}
		
		// Ignore errors while inserting OpportunityTeamMember's mostly they will be inactive users or already existing sharing ..
		Database.insert(otmList, false);
		Database.insert(quoteShareRecords, false);
		Database.insert(orderShareRecords, false);
		Database.insert(dealSupportShareRecords, false);
	}
	
	
	// Share for all Quote, Order, Deal Support Requests objects with Opportunity's team member 
	public static void shareRelatedObjectsWithOpportunityTeam(List<OpportunityTeamMember> newList){
		
		// Build the set of Opportunity Ids
		Set<String> opportunityIds = new Set<String>();
		for(OpportunityTeamMember otm : newList){
			opportunityIds.add(otm.OpportunityId);
		}
		
        //Naresh Kumar	11/22/2018	[101 SOQL Issue]Skipping unnecessary SOQLs and DMLs if there is no opportunity Id 
        if(opportunityIds.isEmpty())
            return;
        
		// Share all Quotes created from the Opportunity
		List<BigMachines__Quote__Share> quoteShareRecords = new List<BigMachines__Quote__Share>();
		for(BigMachines__Quote__c quote : [SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN :opportunityIds]){
			for(OpportunityTeamMember otm : newList){
      			quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
			}
		}

		// Share all Orders created from the Opportunity
		List<Order__Share> orderShareRecords = new List<Order__Share>();
		for(Order__c order : [SELECT Id FROM Order__c WHERE Opportunity__c IN :opportunityIds]){
			for(OpportunityTeamMember otm : newList){
      			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
			}
		}
		
		// Share all Deal Support Requests created from the Opportunity
		List<Deal_Support__Share> dealSupportShareRecords = new List<Deal_Support__Share>();
		for(Deal_Support__c dealSupport : [SELECT Id FROM Deal_Support__c WHERE Opportunity__c IN :opportunityIds]){
			for(OpportunityTeamMember otm : newList){
      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
			}	
		}
		
		Database.insert(quoteShareRecords, false);
		Database.insert(orderShareRecords, false);
		Database.insert(dealSupportShareRecords, false);
	}
	
	// Share for all Quote objects with associacted Opportunity's team member
	public static void shareQuoteWithOpportunityTeam(List<BigMachines__Quote__c> newList){
		Set<String> opportunityIds = new Set<String>();
		for(BigMachines__Quote__c quote : newList){
			opportunityIds.add(quote.BigMachines__Opportunity__c);
		}
		
		// Share Quotes with all OpportunityTeamMember's of the Opportunity being used on Quote
		// Share Quotes with all Opportunity Onwer's of the Opportunity being used on Quote
		Set<String> uniqueObjectIds = new Set<String>();
		Map<Id, Opportunity> opportunityOwnerMap= new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.isActive FROM Opportunity WHERE Id IN :opportunityIds]);		
		List<OpportunityTeamMember> otmList = [SELECT UserId FROM OpportunityTeamMember WHERE User.isActive = true AND OpportunityId IN :opportunityIds];
	
		List<BigMachines__Quote__Share> quoteShareRecords = new List<BigMachines__Quote__Share>();
		for(BigMachines__Quote__c quote : newList){
			for(OpportunityTeamMember otm : otmList){
				if(!uniqueObjectIds.contains(quote.Id + '#' + otm.UserId)){
      				quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
      				uniqueObjectIds.add(quote.Id + '#' + otm.UserId);
				}
			}
			
			if(quote.BigMachines__Opportunity__c != NULL && opportunityOwnerMap.get(quote.BigMachines__Opportunity__c).Owner.isActive == true && !uniqueObjectIds.contains(quote.Id + '#' + opportunityOwnerMap.get(quote.BigMachines__Opportunity__c).OwnerId)){
      			quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId = opportunityOwnerMap.get(quote.BigMachines__Opportunity__c).OwnerId, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
      			uniqueObjectIds.add(quote.Id + '#' + opportunityOwnerMap.get(quote.BigMachines__Opportunity__c).OwnerId);
			}
		}
		Database.insert(quoteShareRecords, false);
	}
	
	// Share for all Order objects with associacted Opportunity's team member
	public static void shareOrderWithOpportunityTeam(List<Order__c> newList){
		Set<String> opportunityIds = new Set<String>();
		for(Order__c order : newList){
			if(order.Opportunity__c != NULL)
				opportunityIds.add(order.Opportunity__c);
		}
		
		// Share Orders with all OpportunityTeamMember's of the Opportunity being used on Order 
		// Share Orders with all Opportunity Onwer's of the Opportunity being used on Order 
		Set<String> uniqueObjectIds = new Set<String>();
		Map<Id, Opportunity> opportunityOwnerMap= new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.isActive FROM Opportunity WHERE Id IN :opportunityIds]);
		List<OpportunityTeamMember> otmList = [SELECT UserId FROM OpportunityTeamMember WHERE User.isActive = true AND OpportunityId IN :opportunityIds];
	
		List<Order__Share> orderShareRecords = new List<Order__Share>();
		for(Order__c order : newList){
			for(OpportunityTeamMember otm : otmList){
      			if(!uniqueObjectIds.contains(order.Id + '#' + otm.UserId)){
	      			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
	      			uniqueObjectIds.add(order.Id + '#' + otm.UserId);
      			}
			}
			
			if(order.Opportunity__c != NULL && opportunityOwnerMap.get(order.Opportunity__c).Owner.isActive == true && !uniqueObjectIds.contains(order.Id + '#' + opportunityOwnerMap.get(order.Opportunity__c).OwnerId)){
     			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId = opportunityOwnerMap.get(order.Opportunity__c).OwnerId, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
      			uniqueObjectIds.add(order.Id + '#' + opportunityOwnerMap.get(order.Opportunity__c).OwnerId);
			}
		}
		Database.insert(orderShareRecords, false);
	}
	
	// Share for all Deal Support objects with associacted Opportunity's team member
	public static void shareDealSupportRequestWithOpportunityTeam(List<Deal_Support__c> newList){
		Set<String> opportunityIds = new Set<String>();
		for(Deal_Support__c dealSupport : newList){
			opportunityIds.add(dealSupport.Opportunity__c);
		}
		
		// Share Deal Support Requests with all OpportunityTeamMember's of the Opportunity being used on Deal Support Request
		// Share Deal Support Requests with all Opportunity Owner's of the Opportunity being used on Deal Support Request
		Set<String> uniqueObjectIds = new Set<String>();
		Map<Id, Opportunity> opportunityOwnerMap= new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.isActive FROM Opportunity WHERE Id IN :opportunityIds]);
		List<OpportunityTeamMember> otmList = [SELECT UserId FROM OpportunityTeamMember WHERE User.isActive = true AND OpportunityId IN :opportunityIds];

		List<Deal_Support__Share> dealSupportShareRecords = new List<Deal_Support__Share>();
		for(Deal_Support__c dealSupport : newList){
			for(OpportunityTeamMember otm : otmList){
      			if(!uniqueObjectIds.contains(dealSupport.Id + '#' + otm.UserId)){
	      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
	      			uniqueObjectIds.add(dealSupport.Id + '#' + otm.UserId);
      			}
			}
			
			if(dealSupport.Opportunity__c != NULL && opportunityOwnerMap.get(dealSupport.Opportunity__c).Owner.isActive == true && !uniqueObjectIds.contains(dealSupport.Id + '#' + opportunityOwnerMap.get(dealSupport.Opportunity__c).OwnerId)){
      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = opportunityOwnerMap.get(dealSupport.Opportunity__c).OwnerId, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
      			uniqueObjectIds.add(dealSupport.Id + '#' + opportunityOwnerMap.get(dealSupport.Opportunity__c).OwnerId);
			}
		}
		Database.insert(dealSupportShareRecords, false);	
	}
    
    // clean up all related sharing records 
	public static void cleanupRelatedObjectsSharing(Map<String, Set<String>> opportunityIdUserIdsMap){
    	Set<String> opportunityIds = new Set<String>();
    	Set<String> userIds = new Set<String>();
    	for(String opportunityId : opportunityIdUserIdsMap.KeySet()){
    		opportunityIds.add(opportunityId);
    		userIds.addAll(opportunityIdUserIdsMap.get(opportunityId));
    	}
    	
    	// Prepare Data for sharing deletion purpose ...
    	Map<String, List<BigMachines__Quote__c>> opportunityQuotesMap = new Map<String, List<BigMachines__Quote__c>>();
    	Set<String> quoteIds = new Set<String>();
		for(BigMachines__Quote__c quote : [SELECT Id, BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN :opportunityIds]){
			quoteIds.add(quote.Id);
			if(opportunityQuotesMap.get(quote.BigMachines__Opportunity__c) != NULL){
				opportunityQuotesMap.get(quote.BigMachines__Opportunity__c).add(quote);
			} else {
				opportunityQuotesMap.put(quote.BigMachines__Opportunity__c, new List<BigMachines__Quote__c>{quote});
			}
		}
		
		Map<String, List<Order__c>> opportunityOrdersMap = new Map<String, List<Order__c>>();
    	Set<String> orderIds = new Set<String>();
    	for(Order__c order : [SELECT Id, Opportunity__c FROM Order__c WHERE Opportunity__c IN :opportunityIds]){
			orderIds.add(order.Id);
			if(opportunityOrdersMap.get(order.Opportunity__c) != NULL){
				opportunityOrdersMap.get(order.Opportunity__c).add(order);
			} else {
				opportunityOrdersMap.put(order.Opportunity__c, new List<Order__c>{order});
			}
		}
		
		Map<String, List<Deal_Support__c>> opportunityDealSupportRequestsMap = new Map<String, List<Deal_Support__c>>();
    	Set<String> dealSupportIds = new Set<String>();
		for(Deal_Support__c dealSupport : [SELECT Id, Opportunity__c FROM Deal_Support__c WHERE Opportunity__c IN :opportunityIds]){
			dealSupportIds.add(dealSupport.Id);
			if(opportunityDealSupportRequestsMap.get(dealSupport.Opportunity__c) != NULL){
				opportunityDealSupportRequestsMap.get(dealSupport.Opportunity__c).add(dealSupport);
			} else {
				opportunityDealSupportRequestsMap.put(dealSupport.Opportunity__c, new List<Deal_Support__c>{dealSupport});
			}
		}
    	
    	List<BigMachines__Quote__Share> quoteShares = [SELECT id, ParentId, UserOrGroupId FROM BigMachines__Quote__Share WHERE RowCause = :Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c AND ParentId IN :quoteIds AND UserOrGroupId IN :userIds];
    	List<Order__Share> orderShares = [SELECT id, ParentId, UserOrGroupId FROM Order__Share WHERE RowCause = :Schema.Order__Share.RowCause.Sales_Team_Access__c AND ParentId IN :orderIds AND UserOrGroupId IN :userIds];
    	List<Deal_Support__Share> dealSupportShares = [SELECT id, ParentId, UserOrGroupId FROM Deal_Support__Share WHERE RowCause = :Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c AND ParentId IN :dealSupportIds AND UserOrGroupId IN :userIds];
    	
		// Start with actual deletion process ...
		List<BigMachines__Quote__Share> quoteSharesToDelete = new List<BigMachines__Quote__Share>();
		List<Order__Share> orderSharesToDelete = new List<Order__Share>();
		List<Deal_Support__Share> dealSupportSharesToDelete = new List<Deal_Support__Share>();
		
		for(String opportunityId : opportunityIdUserIdsMap.KeySet()){
			Set<String> opportunityUsers = opportunityIdUserIdsMap.get(opportunityId);
			for(String userId : opportunityUsers){
				List<BigMachines__Quote__c> opportunityQuotes = opportunityQuotesMap.get(opportunityId);
				if(opportunityQuotes != NULL ){
					for(BigMachines__Quote__c quote : opportunityQuotes){
						for(BigMachines__Quote__Share quoteShare : quoteShares){
							if(quote.Id == quoteShare.ParentId && userId == quoteShare.UserOrGroupId){
								quoteSharesToDelete.add(quoteShare);
							}
						}
					}
				}
				
				List<Order__c> opportunityOrders = opportunityOrdersMap.get(opportunityId);
				if(opportunityOrders != NULL){
					for(Order__c order : opportunityOrders){
						for(Order__Share orderShare : orderShares){
							if(order.Id == orderShare.ParentId && userId == orderShare.UserOrGroupId){
								orderSharesToDelete.add(orderShare);
							}
						}
					}
				}
				
				List<Deal_Support__c> opportunityDealSupports = opportunityDealSupportRequestsMap.get(opportunityId);
				if(opportunityDealSupports != NULL){
					for(Deal_Support__c dealSupport : opportunityDealSupports){
						for(Deal_Support__Share dealSupportShare : dealSupportShares){
							if(dealSupport.Id == dealSupportShare.ParentId && userId == dealSupportShare.UserOrGroupId){
								dealSupportSharesToDelete.add(dealSupportShare);
							}
						}
					}
				}
			}
		}
		
		Database.delete(quoteSharesToDelete, false);
		Database.delete(orderSharesToDelete, false);
		Database.delete(dealSupportSharesToDelete, false);
		
	}
    
    // ********** FOLLOWING 2 METHODS ARE USED FOR ONE TIME UDPATES
    
	// Share for all Quote, Order, Deal Support Requests objects with Opportunity's team member of given opportunities
	public static void shareRelatedObjectsWithOpportunityTeam(Set<String> opportunityIds){
		
		Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT id, Name, (SELECT id, OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMembers WHERE User.isActive = true) FROM Opportunity WHERE id IN :opportunityIds]);
		
				
		// Share all Quotes created from the Opportunity
		List<BigMachines__Quote__Share> quoteShareRecords = new List<BigMachines__Quote__Share>();
		for(BigMachines__Quote__c quote : [SELECT Id, BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN :opportunityIds AND Offering_Type__c = 'PureConnect On Premise']){
			for(OpportunityTeamMember otm : opportunities.get(quote.BigMachines__Opportunity__c).OpportunityTeamMembers ){
      			quoteShareRecords.add(new BigMachines__Quote__Share(ParentId = quote.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
			}
		}
		
		// Share all Orders created from the Opportunity
		List<Order__Share> orderShareRecords = new List<Order__Share>();
		for(Order__c order : [SELECT Id, Opportunity__c FROM Order__c WHERE Opportunity__c IN :opportunityIds AND Quote__c != NULL AND Quote__r.Offering_Type__c = 'PureConnect On Premise']){
			for(OpportunityTeamMember otm : opportunities.get(order.Opportunity__c).OpportunityTeamMembers){
      			orderShareRecords.add(new Order__Share(ParentId = order.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
			}
		}
		
		// Share all Deal Support Requests created from the Opportunity
		List<Deal_Support__Share> dealSupportShareRecords = new List<Deal_Support__Share>();
		for(Deal_Support__c dealSupport : [SELECT Id, Opportunity__c FROM Deal_Support__c WHERE Opportunity__c IN :opportunityIds]){
			for(OpportunityTeamMember otm : opportunities.get(dealSupport.Opportunity__c).OpportunityTeamMembers){
      			dealSupportShareRecords.add(new Deal_Support__Share(ParentId = dealSupport.Id, UserOrGroupId = otm.UserId, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
			}	
		}
		
		Database.insert(quoteShareRecords, false);
		Database.insert(orderShareRecords, false);
		Database.insert(dealSupportShareRecords, false);
	}
   
	// Add the Partner Contacts to the Opportunity Teams
	public static void manageOpportunityTeamForPartnerContacts(List<Contact> newList){
		
		// Collect all Contact Ids for the Contacts
		Set<String> contactIds = new Set<String>();
		for(Contact c : newList){
			contactIds.add(c.Id);
		}
		
		// Build Contact Id and User Id Map
		Map<String, String> partnerContactIdUserIdMap = new Map<String, String>();
		Map<String, String> partnerContactIdAccountIdMap = new Map<String, String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			partnerContactIdUserIdMap.put(u.ContactId, u.Id);
			partnerContactIdAccountIdMap.put(u.ContactId,u.Contact.AccountId);
		} 
		
		// Find all Opportunities where its business partner is one of the accounts of Contact's Account
		Map<Id, List<Opportunity>> accountOpportunitiesMap = new Map<Id, List<Opportunity>>();
		for(Opportunity o : [SELECT Id, Name, AccountId, BusinessPartner__c, CreatedBy.Contact.AccountId FROM Opportunity WHERE Lines_of_Businesses__c IN ('PureCloud', 'PureConnect') AND BusinessPartner__c != NULL AND BusinessPartner__c IN :partnerContactIdAccountIdMap.Values()]){
			if(accountOpportunitiesMap.get(o.BusinessPartner__c) != NULL){
				accountOpportunitiesMap.get(o.BusinessPartner__c).add(o);
			} else {
				accountOpportunitiesMap.put(o.BusinessPartner__c, new List<Opportunity>{o});
			}
		}
		
		// Add OpportunityTeamMember's for those opportunities  
		List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();  
		for(String contactId : partnerContactIdUserIdMap.KeySet()){
			if(accountOpportunitiesMap.get(partnerContactIdAccountIdMap.get(contactId)) != NULL){
				for(Opportunity o : accountOpportunitiesMap.get(partnerContactIdAccountIdMap.get(contactId))){
					otmList.add(new OpportunityTeamMember(OpportunityId = o.Id, UserId = partnerContactIdUserIdMap.get(contactId), TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit'));
				}		
			}
		}
		// Ignore errors while inserting OpportunityTeamMember's mostly they will be inactive users or already existing sharing ..
		Database.insert(otmList, false);
	}
	
	
	// -------- Deal Registration Sharing (partner_portal_prospect__c)....
	public static void shareDealRegistrationWithDesignatedContacts(List<partner_portal_prospect__c> newList){
		// Build the set of Account Ids
		Set<String> accountIds = new Set<String>();
		for(Partner_Portal_Prospect__c dealRegistration: newList){
			accountIds.add(dealRegistration.Account__c);
		}
    	
    	// Build Contact Id and User Id's Map
		Map<String, Set<String>> partnerAccountIdUsersMap = new Map<String, Set<String>>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND Contact.AccountId IN :accountIds AND Contact.Designated_Partner_Contact__c = true]){
			if(partnerAccountIdUsersMap.get(u.Contact.AccountId) != NULL){
				partnerAccountIdUsersMap.get(u.Contact.AccountId).add(u.Id);
			} else {
				partnerAccountIdUsersMap.put(u.Contact.AccountId, new Set<String>{u.Id});
			}
		}
		
		List<Partner_Portal_Prospect__Share> dealRegistrationShareRecords = new List<Partner_Portal_Prospect__Share>();
		for(Partner_Portal_Prospect__c dealRegistration: newList){
			if(partnerAccountIdUsersMap.get(dealRegistration.Account__c) != NULL){
				for(String userId : partnerAccountIdUsersMap.get(dealRegistration.Account__c)){
		      		dealRegistrationShareRecords.add(new Partner_Portal_Prospect__Share(ParentId = dealRegistration.Id, UserOrGroupId = userId, AccessLevel = 'Edit', RowCause = Schema.Partner_Portal_Prospect__Share.RowCause.Designated_Partner_Contact__c));
				}
			}
		}
		// Ignore errors while inserting OpportunityTeamMember's mostly they will be inactive users or already existing sharing ..
		Database.insert(dealRegistrationShareRecords, false); 
	}
	
	
	public static void shareDealRegistrationWithDesignatedContacts(List<String> contactIds, List<Partner_Portal_Prospect__c> dealRegistrations){
		
		// Build Contact Id and User Id Map
		Map<String, String> partnerContactIdUserIdMap = new Map<String, String>();
		Map<String, String> partnerContactIdAccountIdMap = new Map<String, String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			partnerContactIdUserIdMap.put(u.ContactId, u.Id);
			partnerContactIdAccountIdMap.put(u.ContactId,u.Contact.AccountId);
		} 

		Map<Id, List<Partner_Portal_Prospect__c>> accountDealRegistrationsMap = new Map<Id, List<Partner_Portal_Prospect__c>>();
		for(Partner_Portal_Prospect__c dealRegistration: dealRegistrations){
			if(accountDealRegistrationsMap.get(dealRegistration.Account__c) != NULL){
				accountDealRegistrationsMap.get(dealRegistration.Account__c).add(dealRegistration);
			} else {
				accountDealRegistrationsMap.put(dealRegistration.Account__c, new List<Partner_Portal_Prospect__c>{dealRegistration});
			}
		}
		
		List<Partner_Portal_Prospect__Share> dealRegistrationShareRecords = new List<Partner_Portal_Prospect__Share>();
		for(String contactId : partnerContactIdUserIdMap.KeySet()){
			if(accountDealRegistrationsMap.get(partnerContactIdAccountIdMap.get(contactId)) != NULL){
				for(Partner_Portal_Prospect__c dealRegistration : accountDealRegistrationsMap.get(partnerContactIdAccountIdMap.get(contactId))){
					dealRegistrationShareRecords.add(new Partner_Portal_Prospect__Share(ParentId = dealRegistration.Id, UserOrGroupId = partnerContactIdUserIdMap.get(contactId), AccessLevel = 'Edit', RowCause = Schema.Partner_Portal_Prospect__Share.RowCause.Designated_Partner_Contact__c));
				}
			}
		}
		
		// Ignore errors while inserting OpportunityTeamMember's mostly they will be inactive users or already existing sharing ..
		Database.insert(dealRegistrationShareRecords, false); 
	}

	// clean up all related DealRegistration sharing records 
	public static void cleanupDealRegistrationSharing(List<String> contactIds, List<Partner_Portal_Prospect__c> dealRegistrations){
		// Build Contact Id and User Id Map
		Map<String, String> partnerContactIdUserIdMap = new Map<String, String>();
		Map<String, String> partnerContactIdAccountIdMap = new Map<String, String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			partnerContactIdUserIdMap.put(u.ContactId, u.Id);
			partnerContactIdAccountIdMap.put(u.ContactId, u.Contact.AccountId);
		} 

		Map<Id, List<Partner_Portal_Prospect__c>> accountDealRegistrationsMap = new Map<Id, List<Partner_Portal_Prospect__c>>();
		Set<String> dealRegistrationIds = new Set<String>();
		for(Partner_Portal_Prospect__c dealRegistration: [SELECT Id, Account__c FROM Partner_Portal_Prospect__c WHERE Account__c IN :partnerContactIdAccountIdMap.values()]){
			dealRegistrationIds.add(dealRegistration.Id);
			if(accountDealRegistrationsMap.get(dealRegistration.Account__c) != NULL){
				accountDealRegistrationsMap.get(dealRegistration.Account__c).add(dealRegistration);
			} else {
				accountDealRegistrationsMap.put(dealRegistration.Account__c, new List<Partner_Portal_Prospect__c>{dealRegistration});
			}
		}
		
		List<Partner_Portal_Prospect__Share> dealRegistrationSharesToDelete = new List<Partner_Portal_Prospect__Share>();
		List<Partner_Portal_Prospect__Share> dealRegistrationShareRecords = [SELECT id, ParentId, UserOrGroupId FROM Partner_Portal_Prospect__Share WHERE RowCause = :Schema.Partner_Portal_Prospect__Share.RowCause.Designated_Partner_Contact__c AND ParentId IN :dealRegistrationIds AND UserOrGroupId IN :partnerContactIdUserIdMap.values()];
		for(String contactId : contactIds){
			List<Partner_Portal_Prospect__c> accountDealRegistrations = accountDealRegistrationsMap.get(partnerContactIdAccountIdMap.get(contactId));
			if(accountDealRegistrations != NULL ){
				for(Partner_Portal_Prospect__c dealRegistration : accountDealRegistrations){
					for(Partner_Portal_Prospect__Share dealRegistrationShare : dealRegistrationShareRecords){
						if(dealRegistration.Id == dealRegistrationShare.ParentId && partnerContactIdUserIdMap.get(contactId) == dealRegistrationShare.UserOrGroupId){
							dealRegistrationSharesToDelete.add(dealRegistrationShare);
						}
					}
				}
			}
		}
		Database.delete(dealRegistrationSharesToDelete, false); 
	}
	
}