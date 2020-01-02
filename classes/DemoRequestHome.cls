public class DemoRequestHome {
    
    public Boolean isTSC { get; private set; }
    public Boolean isTSM { get; private set; }
    public Boolean isTSD { get; private set; }
    public List<String> teamNames { get; private set; }
    public String UserName { get { return UserInfo.getName(); } }
    public String selectedPerson { get; set; }
    public String selectedQueue { get; set; }
    private Id Jason = '005n0000001nATu';
    public SelectOption[] managers { get; private set; }
    
    public DemoRequestHome() {
        selectedQueue = DemoRequestUtility.getPresentersQueue(UserInfo.getUserId());
        isTSD = UserInfo.getName() == 'Carl Fluke' || UserInfo.getName() == 'Justin Hawkins' || UserInfo.getName() == 'Jaclyn Spillane';
        isTSC = (DemoRequestUtility.GetTSCsIds(selectedQueue).contains(UserInfo.getUserId()) || isTSD);
        isTSM = (DemoRequestUtility.GetTSMsIds(selectedQueue).contains(UserInfo.getUserId()) || isTSD);
        
        if(isTSM)  selectedPerson = UserInfo.getUserId();
        if(isTSD)  selectedPerson = Jason;
        
        if(!String.isBlank(selectedPerson))updateManager();
    }
    
    public void updateManager(){
        teamNames = new List<String>();
        //Adding empty for filter to work correctly
        teamNames.add('');
        for(User u : [Select Name from User where ManagerId=:selectedPerson]) {
            teamNames.add(u.Name);
        }
        //Adding empty for filter to work correctly
        teamNames.add('');
    }
}