//Naresh Kumar  05/23/2014
public with sharing class ForgotPasswordPartnerController {
    public String userName {get; set;}   
    public Boolean passSent {get;set;}
    
    public ForgotPasswordPartnerController() {
        passSent = false;
        String userNameC = ApexPages.currentPage().getParameters().get('uName');
        system.debug('---------------------------userNameC----------------------------------'+userNameC);
        if(userNameC != null){
            userName = userNameC;
        }
    }
    
    public PageReference forgotPassword() {
        if(username == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Your User Name');
            ApexPages.addMessage(msg);  
            return null;   
        }else{
            
            // List<User> user = [SELECT Id, Name, Email, UserName,FirstName,LastName,Profile.Name,ContactId FROM User WHERE UserName =: username AND isActive = true];
            List<User> user = [SELECT Id, Name, Email, UserName,FirstName,LastName,Profile.Name,ContactId FROM User WHERE Email = :username AND isActive = true];
            if(!user.isEmpty()){
                if(user[0].Profile.Name != PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME && user[0].Profile.Name != PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME && user[0].Profile.Name != PartnerPortalUtil.CUSTOM_GOLDPARTNER_PROFILE_NAME && user[0].Profile.Name != PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER_PP){
                    List<PermissionSetAssignment> psa = [SELECT id, AssigneeId FROM PermissionSetAssignment 
                                                         WHERE AssigneeId =: user[0].id AND PermissionSetId =: PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID];
                    if(psa.isEmpty()){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, Couldn\'t reset your password. You are not registered to partner community.');
                        ApexPages.addMessage(msg);  
                        return null;     
                    }
                }
                //boolean success = Site.forgotPassword(username);
                
                // Send to Azure Queue  
                try{
                    LdapManagement ldap = new LdapManagement();
                    ldap.ResetPassword(user[0].ContactId);  
                } catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error resetting password, Please contact your Channel Manager.'));
                    return null;   
                }
                
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'We have sent you an email containing your new password.');
                ApexPages.addMessage(msg);
                passSent = true;
                return null;
            }else{
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Valid User Name');
                ApexPages.addMessage(msg);  
                return null; 
                
            }
            
        }  
        return null;
    }
    
    public static String getPassword(Integer len) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        
        System.debug(key);
        return key.substring(0,len);
    }
}