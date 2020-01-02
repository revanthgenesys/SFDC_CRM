public with sharing class Ctrl03_VF01_Create_OQM_Form {

private Opportunity Oppty {get; set;}
private String mydate;
private String BP_Contact;
private string RecordTypeId;

public string typeOfCreation{get;set;}

public String getmydate () {
    return mydate;
}
public String getRecordTypeID() {
    return RecordTypeID;
}

public void setmydate(String s) {
    mydate = s;
}

public String getBP_Contact () {
    return BP_Contact;
}

public void setBP_Contact(String country) {
	if(typeOfCreation =='RFP' ){
		BP_Contact = Config.RFP_QUEUE;
	}
    else if(country == Config.EMEA
    || country == null 
    || country == Config.APAC) {
            BP_Contact = Config.BP_CONTACT_EMEA;
    }
    else
    {
            BP_Contact = Config.BP_CONTACT_NA;
    }   
}

public void setRT(){
	if( (Userinfo.getProfileId()==Util.getProfileId('EMG - Direct Touch OQM Simple (NA)') && Oppty.EPGGroup__c=='Genesys')
	 	|| Userinfo.getProfileId()==Util.getProfileId('GEN - Direct Touch AMERICAS') 
	 	|| Userinfo.getProfileId()==Util.getProfileId('GEN - Inside Sales AMERICAS')  )
	 {
		typeOfCreation ='RFP'; 
		RecordTypeId = Config.RT_RFP_Submission;
	 }
	 else{
	 	typeOfCreation ='OQM';
	 	RecordTypeId = Config.RT_OQM_Submission;
	 	 
	 }
}

public Ctrl03_VF01_Create_OQM_Form (ApexPages.StandardController stdController) {
		
        Util.MyLog('###Ctrl03_VF01_Create_OQM_RFP_Form');
        
        this.Oppty = (Opportunity)stdController.getRecord();
        this.Oppty = [SELECT Country__r.Region__c, CloseDate , EPGGroup__c 
                      FROM Opportunity
                      WHERE id =: this.Oppty.id];
                      
		setRT();
        setmydate(This.Oppty.CloseDate.format());
        Util.MyLog('### This.Oppty.Country__r.Region__c =' + This.Oppty.Country__r.Region__c);
        setBP_Contact(This.Oppty.Country__r.Region__c);
        
        
		
        
    }

}