@isTest
public class LicenseReqActivityHistory_Test {
	
	public static testmethod void acthstTst() {
		
		TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true; 
     
        License_Request__c srceLR = new License_Request__c();
        srceLR.Request_Type__c = 'Question';
        srceLR.Status__c = 'Open';
        srceLR.Sub_Status__c = 'New';
        insert srceLR;
        
        EmailMessage inbMsg = new EmailMessage();
        inbMsg.RelatedToId = srceLR.Id;
        inbMsg.Subject = 'Test';
        insert inbMsg;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(srceLR);
        LicenseReqActivityHistory cntr = new LicenseReqActivityHistory(stdController);
        cntr.msgId = inbMsg.Id;
        cntr.delRec();
	}
    
}