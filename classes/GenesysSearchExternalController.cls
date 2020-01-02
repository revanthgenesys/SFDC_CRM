public class GenesysSearchExternalController {
    public string coveoUserAccountName {get;private set;}

    public GenesysSearchExternalController(){
       Init();
    }
    
    private void Init(){
        String userId = UserInfo.getUserId();
        User currentUser = [Select Id, Contact.Account.Name From User WHERE Id = :userId];
        coveoUserAccountName = currentUser.Contact.Account.Name;
    }
}