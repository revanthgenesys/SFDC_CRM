public without sharing class ConsultingLeadFormExt {
    
    public string Company {get;set;}
    public string First_Name {get;set;}
    public string Last_Name {get;set;}
    public string Email {get;set;}
    public string Job_Title {get;set;}
    public string Phone {get;set;}
    public string Address {get;set;}
    public string City {get;set;}
    public string State {get;set;}
    public string Postal_Code {get;set;}
    public string Country {get;set;}
    public string Company_Website {get;set;}
    public boolean SMB {get;set;}
    public boolean Mid_Market {get;set;}
    public boolean Large_Enterprise {get;set;}
    public boolean Vertical_Focus {get;set;}
    public boolean Contact_Me {get;set;}

    Public boolean IsSave{get; set;} 

    public ConsultingLeadFormExt() {
        IsSave = false;
    }

    public pageReference save(){
        Lead ll = new Lead();
        ll.FirstName = First_Name;
        ll.LastName =Last_Name;
        ll.Company = Company; 
        ll.Website = Company_Website;
        ll.Title = Job_Title;
        ll.ContactPhone__c = Phone;
        ll.City__c = City;
        ll.Street1__c = Address;
        ll.ZipCode__c = Postal_Code;
        ll.LID__LinkedIn_Company_Id__c='123';
        ll.Email = Email;
        ll.State__c = State;
        ll.LeadSource ='ConsultantPortal';

        List<Country__c> coun = new List<Country__c>([select Id, Name from Country__c where Name=:Country]);
        if(coun.size()>0)
            ll.Country__c   = coun[0].Id;
        else
        ll.Country__c   = Label.DefaultCountry;
        ll.OwnerId      = Label.DefaultOwner;
        
        insert ll;
        IsSave= true;
        return null;
    }
    
}