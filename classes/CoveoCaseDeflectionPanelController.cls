public class CoveoCaseDeflectionPanelController {
    public string coveoProductName {get;set;}
    public string coveoProductLineName {get;set;}
    public string coveoMajorRelease {get;set;}
    public string coveoComponentName {get;set;}
    public string coveoSoldToName {get;private set;}
    public string coveoUserAccountName {get;private set;}
    

    public CoveoCaseDeflectionPanelController(){
       Init();
    }
    
    private void Init(){
        string prmCM = Apexpages.currentPage().getParameters().get('cm');
        if(isValidParamValue(prmCM)){
            coveoComponentName = [select name from Support_Product__c where id=:prmCM].name;
		}
        
        coveoMajorRelease = Apexpages.currentPage().getParameters().get('mr');
        
        string prmSP = Apexpages.currentPage().getParameters().get('sp');
        if(isValidParamValue(prmSP)){
            coveoProductName = [select name from Support_Product__c where id=:prmSP].name;
        }

        string sto = Apexpages.currentPage().getParameters().get('sto');
        if(isValidParamValue(sto)){
            coveoSoldToName = [SELECT Id, Name FROM Account WHERE Id=:sto LIMIT 1].Name;
        }

        string pl = Apexpages.currentPage().getParameters().get('pl');
        if(isValidParamValue(pl)){
            coveoProductLineName = [select name from Support_Product__c where id=:pl].name;
        }
        
        String userId = UserInfo.getUserId();
        User currentUser = [Select Id, Contact.Account.Name From User WHERE Id = :userId];
        coveoUserAccountName = currentUser.Contact.Account.Name;
    }
   
    private Boolean isValidParamValue(string paramValue){
        return (String.isNotEmpty(paramValue) && paramValue != 'null');
    }
}