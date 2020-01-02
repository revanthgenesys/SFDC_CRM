//Ravi V - G360 -  9/3/2013
public class customer_page
  { 
  private ApexPages.StandardController controller {get; set;}
   public String externalurl='https://gen1bipdb01.genesyslab.com/php/customerdashboard.php?EndUserAccountSAPCode='; 
   public String error{get; set;}
   public Boolean isCheckURLAccess {get;set;}
   public Boolean showIFrame {get;set;}
   public String getExternalurl()
   {
    return externalurl;
   }
  public Account ac {set;get;}
  public String uid {set;get;}
  public String ownerid; 
  public List<VPN_server_ipaddress__c> vpnipaddress {set;get;} 
  public List<custom_dashboard_profile__c> exprofiles {set;get;}
  
  public customer_page(ApexPages.StandardsetController controller)
   {
    String accId = ApexPages.currentPage().getParameters().get('id');
    if(accId != null){
        ac =[select ownerid,SAP_Account_Code__c from account where id=: accId limit 1];
        ownerid=ac.ownerid;
        uid=ac.SAP_Account_Code__c;
        isCheckURLAccess = false;
    }
    else{
        isCheckURLAccess = true;
        showIFrame = false;
        doCheckURLAccess();
    }
   }
    
    private void doCheckURLAccess(){
        String errorMsg;
        try{
            String urlToOpen = Label.VPN_Url;            
            //urlToOpen = 'https://www.salesforce.com';                        
            externalurl = urlToOpen;
            /*
            HttpRequest req = new HttpRequest();
            req.setEndpoint(urlToOpen);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            errorMsg = res.getStatus();
            */
            
            //if(res.getStatus() == 'OK'){
            string UserIP = GetUserIPAddress();
            vpnipaddress=[select id,name,IP_address__c from VPN_server_ipaddress__c where IP_address__c=:UserIP];
            if(vpnipaddress.size() > 0){
                showIFrame = true;                
            }
            else{
                errorMsg = ' You don\'t have access to the VPN.';    
            }
        }
        catch(Exception ex){
            System.debug('NKC debug ex.getMessage() ['+ex.getMessage()+']');
            //errorMsg += ' You don\'t have access to the VPN.';
            //errorMsg += ex.getMessage();
        }
        if(errorMsg != null){           
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }          
        
   }
    
    
  public String GetUserIPAddress() 
   {
    string ReturnValue = '';  
    // True-Client-IP has the value when the request is coming via the caching integration.
    ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
    // X-Salesforce-SIP has the value when no caching integration or via secure URL.
    if (ReturnValue == '' || ReturnValue == null)
     {
      ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
     } // get IP address when no caching (sandbox, dev, secure urls)
    if (ReturnValue == '' || ReturnValue == null)
     {
      ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
     } // get IP address from standard header if proxy in use
    return ReturnValue;
   }
     
  public boolean getChecksrc()
   {
    AllRoleUtils aru = new AllRoleUtils();
    Set<ID> loginuserroleid = new  Set<ID>();
    Set<ID> resultroleid = new  Set<ID>();
    ID rid = userinfo.getUserRoleId();
    ID loginuserprofileid=userinfo.getProfileId();
    loginuserroleid.add(rid);
    resultroleid = aru.getAllunderRoleIds(loginuserroleid);
    User us=[select id,name,userroleid from user where id=:ownerid limit 1];
    ID ownerroleid = us.userroleid;
    boolean flag = true;
    if(uid==null)
     {
      flag = false;
      error='Mapping error between SAP Account name and Salesforce Account name or mapping error between SAP Account and multiple Salesforce Accounts. Please look for Salesforce Account with SAP code and try again';
      
     }
    else
     { externalurl = externalurl + uid;}
        
    if(flag)
     {  
      string UserIP = GetUserIPAddress();
      vpnipaddress=[select id,name,IP_address__c from VPN_server_ipaddress__c where IP_address__c=:UserIP];
      exprofiles = [select name from custom_dashboard_profile__c where name =:[select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name ];
      if (vpnipaddress.size()==0)
       {
        flag = false;
        error = 'Customer dashboard requires VPN access, please enable your VPN connection and try again';
        
        }
      }
    if(flag)
     {             
      if(!(ownerroleid==rid || resultroleid.contains(ownerroleid) || exprofiles.size()>0))
      {
       flag = false;
       error = 'You don’t have access to the customer dashboard for this Account, please check with the Account owner or Administrator';
       
      }
    }         
   if(flag==false)
     {
       Error_log__c elc= new Error_log__c(Error_Level__c = 'medium',Code_Type__c = 'Class', Snippet_Name__c= 'customer_page',User_Name__c= UserInfo.getUserName(),Object_Name__c= 'Account',Error_Description__c  = error );
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error);
       ApexPages.addMessage(myMsg);
     }
   return flag; 
   }
  }