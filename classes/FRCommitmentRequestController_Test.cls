@isTest
public class FRCommitmentRequestController_Test {
    
    static testMethod void frcommtst() {
    	
    	FR_Commitment__c frc = new FR_Commitment__c();
    	insert frc;
    	
    	ApexPages.StandardController stdController = new ApexPages.StandardController(frc);
        FRCommitmentRequestController contr = new FRCommitmentRequestController(stdController);
        contr.withdraw();
    }
}