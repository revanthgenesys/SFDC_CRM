@isTest
public class LiveChatEnableController_Test {
	
	static testMethod void chatTest() {

        Customer_Care_Live_Chat__c lch = new Customer_Care_Live_Chat__c(Key__c = '12345678901234567890123456789012',
                                                                        Enabled__c = true,
                                                                        URL__c = '');
        insert lch;
        
        LiveChatEnableController lchcon = new LiveChatEnableController();
        
        lchcon.key = '123456789012345678';
        lchcon.enableFlg = false;
        lchcon.url = '';
        
        lchcon.applyUpdate();  
        
        Customer_Care_Live_Chat__c csf = Customer_Care_Live_Chat__c.getOrgDefaults();
	    String key = csf.Key__c;
	    Boolean enabled = csf.Enabled__c;      
        
        System.assertEquals('123456789012345678', key);
        System.assertEquals(false, enabled);    
                                                                           
    }

}