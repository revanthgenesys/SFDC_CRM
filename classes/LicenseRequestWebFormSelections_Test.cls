@isTest
public class LicenseRequestWebFormSelections_Test {
	
	static testMethod void tst() {
		
		LicenseRequestWebFormSelections.visiblFlags('Activation File Request', 'Pay Per Use/Hosted Activation File', 'Genesys');
		
		LicenseRequestWebFormSelections.visiblFlags('Activation File Request', 'Pay Per Use/Hosted Activation File', 'Genesys');
		LicenseRequestWebFormSelections.visiblFlags('Activation File Request', 'Genesys Activation File', 'New Deployment');
		LicenseRequestWebFormSelections.visiblFlags('Activation File Request', 'Genesys Activation File', 'Rehost');
		LicenseRequestWebFormSelections.visiblFlags('Activation File Request', 'Third Party Activation File', 'Temporary File Extension Third Party');
		
		LicenseRequestWebFormSelections.implmnts('Pay Per Use/Hosted Activation File', 'Genesys');
		LicenseRequestWebFormSelections.implmnts('Third Party Activation File', 'Third Party - SilverLining');
		LicenseRequestWebFormSelections.implmnts('Activation File Request', 'Voice Genie');
		LicenseRequestWebFormSelections.implmnts('Activation File Request', 'GCIP');
		LicenseRequestWebFormSelections.implmnts('Third Party Activation File', 'TThird Party - VMware');
		LicenseRequestWebFormSelections.implmnts('Third Party Activation File', 'Third Party - Business Objects/Interactive Insights');
		
		LicenseRequestWebFormSelections.deplmnts('Genesys');
		LicenseRequestWebFormSelections.deplmnts('Additional Test Files');
		LicenseRequestWebFormSelections.deplmnts('New Deployment');
		LicenseRequestWebFormSelections.deplmnts('Voice Genie');
		LicenseRequestWebFormSelections.deplmnts('Business Objects/Interactive Insights');
		
	}
    
}