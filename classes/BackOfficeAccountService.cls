public class BackOfficeAccountService {
       
    public static Back_Office_Account__c getBoaContractFieldsBySTEU (Id soldToId, Id endUserId, String contrOffering) {

        Back_Office_Account__c retBoa = new Back_Office_Account__c();
        if ( soldToId == null || endUserId == null || (contrOffering != 'PureConnect On Premise' && contrOffering  != 'PureEngage On Premise') )
            return null;
       
       List<ServiceContract> srvContrs = getServiceContractsByStEuId (soldToId, endUserId, contrOffering, null);

       if ( !srvContrs.isEmpty() ) {
            String contractStatus = 'Closed';
   
            for (ServiceContract srvcnt : srvContrs) {  
                
                if ( srvcnt.Agreement_Status__c != null &&  
                    (srvcnt.Agreement_Status__c == 'Active' || srvcnt.Agreement_Status__c == 'Pending' ||
                     srvcnt.Agreement_Status__c == 'In Negotiation') ) {                        
                         contractStatus = 'Active';
                }                                                       
            }                   
           retBoa.Contract_Status__c = contractStatus;         
           retBoa.End_User_Name__c = srvContrs[0].End_User_Name__r.Name;
           retBoa.Sold_To_Name__c = srvContrs[0].Sold_To_Name__r.Name;         
           retBoa.Platform__c = contrOffering;
                 
           retBoa.Unique_STEU__c = (Id) srvContrs[0].Sold_To_Name__c + '_' + (Id) srvContrs[0].End_User_Name__c + '_' + 
                                    contrOffering.substringBefore(' ');
       }       
       return retBoa;           
    }
 
    public static Id getBoaIdBySTEU (Id soldToId, Id endUserId, String contrOffering)  {
        
        List<Back_Office_Account__c> boa = [SELECT Id FROM Back_Office_Account__c
                                            WHERE End_User_Account__c = :endUserId                                               
                                              AND Sold_To_Account__c = :soldToId
                                              and Platform__c = :contrOffering];
                                           
        if ( boa.isEmpty() )
           return null;
        else
           return boa[0].Id;
    }
    
    private static List<ServiceContract> selectServiceContracts (String soldToSQryStr, String endUserQryStr, String contrOffering, String conrStatus) {
        List<ServiceContract> retcontrs = new List<ServiceContract>();
        if ( String.isBlank(contrOffering) || contrOffering == null || soldToSQryStr == null || endUserQryStr == null )
            return retcontrs;
        
        String qrystatus = '';               
        if ( conrStatus == 'active' )
           qrystatus = 'AND Agreement_Status__c IN (\'Active\', \'Pending\', \'In Negotiation\') ';
        else if ( conrStatus == 'closed' )
           qrystatus = 'AND Agreement_Status__c NOT IN (\'Active\', \'Pending\', \'In Negotiation\') ';
           
        String qry = 'SELECT id, name, End_User_Name__r.Name, Sold_To_Name__r.Name, Agreement_Status__c, Offering_Type__c, ' +
                     'StartDate, EndDate, Service_Contract_Type__c, Support_Owner__r.Name, System_Integrator__r.Name, ' +
                        '(SELECT Product2.OfferingType__c FROM ContractLineItems ' +
                          'WHERE Product2.OfferingType__c INCLUDES (\'' + contrOffering + '\') LIMIT 1) ' +
                   'FROM ServiceContract ' +
                   'WHERE End_User_Name__c ' + endUserQryStr + 
                   'AND Sold_To_Name__c ' + soldToSQryStr  + 
                    qrystatus + 
                   'AND LineItemCount > 0 ' +
                   'AND Service_Contract_Type__c != \'Cloud\' ' +
                     'ORDER BY StartDate DESC';
 
        System.debug('** selectServiceContracts qry ' + qry);
        
        List<ServiceContract> allconts = Database.query(qry);  
        /// return only contracts containing requested product offering
        if ( !allconts.isEmpty() ) { 
            for (ServiceContract sc : allconts) {  
            	Boolean pEng = false;
            	Boolean pCnct = false;
            	Boolean notdefined = true;
            	
            	if ( sc.Offering_Type__c != null && sc.Offering_Type__c.startsWith('PureEngage') ) {
            	     pEng = true;
            	     notdefined = false;
            	}
            	else if ( sc.Offering_Type__c != null && sc.Offering_Type__c.startsWith('PureConnect') ) {
            	     pCnct = true;
            	     notdefined = false;
            	}

                if ( pEng && contrOffering.startsWith('PureEngage') )
                     retcontrs.add(sc);
                else if (pCnct && contrOffering.startsWith('PureConnect') )
                     retcontrs.add(sc);
                else if ( notdefined && !sc.ContractLineItems.isEmpty() )
                     retcontrs.add(sc);
            }
        } 
          
        return retcontrs;
    }
    
    public static List<ServiceContract> getServiceContractsByBoaId (Id boaId, String conrStatus ) {
        String contrOffering;           
        String boaEuQryStr =  'IN (SELECT End_User_Account__c FROM Back_Office_Account__c WHERE Id = \'' + boaId + '\') ';
        String boaStQryStr =  'IN (SELECT Sold_To_Account__c  FROM Back_Office_Account__c WHERE Id = \'' + boaId + '\') ';
        
        List<Back_Office_Account__c> boa = [SELECT Platform__c FROM Back_Office_Account__c WHERE Id = :boaId];
        if ( !boa.isEmpty() )  
            contrOffering = boa[0].Platform__c;
                            
        return selectServiceContracts (boaStQryStr, boaEuQryStr, contrOffering, conrStatus);
    }
    
    public static List<ServiceContract> getServiceContractsByStEuId (Id soldToId, Id endUserId, String contrOffering, String conrStatus ) {
        
        String soldToQryStr =  ' = \'' +  soldToId + '\' ';
        String endUserQryStr = ' = \'' +  endUserId + '\' ';
        
        return selectServiceContracts (soldToQryStr, endUserQryStr, contrOffering, conrStatus);
    }
    
    public static String getServiceContractOffering(ServiceContract sc) {
        String contrOffering;
        
        List<ServiceContract> contr = [SELECT Offering_Type__c,
										(SELECT Product2.OfferingType__c FROM ContractLineItems 
										 WHERE  Product2.OfferingType__c INCLUDES ('PureConnect On Premise','PureEngage On Premise') LIMIT 1)  
									FROM ServiceContract WHERE id = :sc.Id];  
	    if ( !contr.isEmpty() ) {	         
	        if ( contr[0].Offering_Type__c != null && contr[0].Offering_Type__c.startsWith('PureEngage') ) 
	              contrOffering = 'PureEngage On Premise';
	        else if ( contr[0].Offering_Type__c != null && contr[0].Offering_Type__c.startsWith('PureConnect') ) 
	              contrOffering = 'PureConnect On Premise';	        
	        else if ( !contr[0].ContractLineItems.isEmpty() ) {
	        	
	        	 String lineoffer = contr[0].ContractLineItems[0].Product2.OfferingType__c;
	             if ( lineoffer == 'PureConnect On Premise' || lineoffer == 'PureEngage On Premise' ) 	       	        	
	             	contrOffering = contr[0].ContractLineItems[0].Product2.OfferingType__c;
	        }
	    }
	         
        return contrOffering;       
    }
    
    public class BoaInstance {      
        public Back_Office_Account__c boaInst;
        String APPROVED = 'Active';
        String PENDING = 'Pending';

        public BoaInstance (Id soldToId, Id endUserId, Boolean isApproved, String contrOffering) {
            
            boaInst = getBoaContractFieldsBySTEU (soldToId, endUserId, contrOffering);                                    
            Id boaId = getBoaIdBySTEU(soldToId, endUserId, contrOffering);

            if ( boaId != null ) 
                boaInst.Id = boaId;
            else if ( boaInst.Contract_Status__c == null || boaInst.Contract_Status__c == 'Closed' ) ///if no active contracts do not add new BOA
                boaInst = null;
            else {                          
                boaInst.End_User_Account__c = endUserId;
                boaInst.Sold_To_Account__c = soldToId;
                boaInst.Platform__c = contrOffering;
                boaInst.Approval_Status__c = (isApproved == null || isApproved == false? PENDING : APPROVED);  
                                
                if ( contrOffering != null && contrOffering == 'PureEngage On Premise')   
                   boaInst.Support_Package__c = 'Business Care'; 
                else  if ( contrOffering != null && contrOffering == 'PureConnect On Premise') 
                   boaInst.Support_Package__c = 'PureConnect Standard';      
            }               
        }
    }
        
}