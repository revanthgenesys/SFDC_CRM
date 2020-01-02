public class PartnerNROrderController {
    
    public List<Order__c> orderLst {get; set;}
    public Boolean canAccess {get; set;}
    public String orderId {get; set;}
    
    public PartnerNROrderController() {
        
        String NROrderPartnerType = '';
        List<Partner_Portal_Deal_Registration_Config__c> partnerConfig = Partner_Portal_Deal_Registration_Config__c.getall().values();
        for(Partner_Portal_Deal_Registration_Config__c ppdr: partnerConfig){
            if(ppdr.Lab_Order__c == true){
                if(NROrderPartnerType == '')
                    NROrderPartnerType = '\''+ppdr.Name+'\'';
                else 
            		NROrderPartnerType = NROrderPartnerType + ', \''+ppdr.Name+'\'' ;
            }
        }
        
        String query = 'SELECT Id, Contact.Account.Id FROM User WHERE id = \''+UserInfo.getUserId()+'\' AND Contact.Account.PartnerType__c INCLUDES (' +NROrderPartnerType+ ')';
        List<User> usr = Database.query(query);
        /*
        List<User> usr = [SELECT Id, Contact.Account.Id 
                          FROM User 
                          WHERE id =: UserInfo.getUserId()
                          AND Contact.Account.PartnerType__c 
                          INCLUDES ('VAR','Specialized Reseller','Cloud Partner','Managed Services Provider')];
        */
        canAccess = usr.isEmpty() ? false : true;
        
        if ( canAccess )  {
            orderLst = [SELECT Id, Name, Status__c, Product_Description__c, CreatedDate,
                        Product_Bundles__c, CreatedBy.Name, CreatedBy.Id,
                        Maintenance_End__c, Maintenance_Start__c, Order_Completed_by_AE__c
                        FROM Order__c
                        WHERE Sold_To_Name__c = :usr[0].Contact.Account.Id
                        AND Source__c = 'Web'
                        AND CreatedDate = LAST_N_DAYS:365
                        ORDER BY CreatedDate DESC];
        }
        
    }
    
    public PageReference openRequestForm()  {        
        return new PageReference('/partner/apex/PartnerNROrderForm');  
    }
    
    public PageReference showDetails() {
        
        return new PageReference('/partner/apex/PartnerNROrderDetails?Id=' + orderId);        
    }
    
    public PageReference editRequestForm()  {        
        return new PageReference('/partner/apex/PartnerNROrderForm?Id=' + orderId);  
    }
    
    
}