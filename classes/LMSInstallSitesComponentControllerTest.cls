@isTest(seeAllData=true)
public class LMSInstallSitesComponentControllerTest {
    @isTest
    static void testLMSInstallSitesComponentController(){
        LMS_Install_Site__c iSite = [SELECT Id, Name, Account__c FROM LMS_Install_Site__c WHERE Active__c = true AND Account__c != NULL LIMIT 1]; 
        
        Test.startTest();
        LMSInstallSitesComponentController controller =  new LMSInstallSitesComponentController();       
        controller.endUserAccountId = iSite.Account__c;
        controller.soldToAccountIds = new List<String>{iSite.Account__c};
        controller.userType = 'Internal';
        List<SelectOption> activeInactiveOptions = controller.getActiveInactive();
        List<LMSInstallSitesComponentController.InstallSiteWrapper> installSites;
        installSites = controller.getInstallSites();
        controller.selectedActiveInactive = 'Yes';
        installSites = controller.getInstallSites();
        controller.selectedActiveInactive = 'No';
        installSites = controller.getInstallSites();
        controller.addInstallSite();
        controller.installSite.Name = 'Test'; 
        controller.saveInstallSite();
        controller.selectedInstallSite = iSite.Id;
        controller.editInstallSite();
        controller.cancelInstallSite();
        Test.stopTest();        
    }   
}