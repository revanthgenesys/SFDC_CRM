//Created by Saurabh Gupta

public class MoveContacts{

    
    public Account account{get;set;}
    public Contact contact{get;set;}
    public List<ContactWrapper> lstConWrap{get;set;}
    
        public MoveContacts(ApexPages.StandardController stdController) {
        this.account = (account)stdController.getRecord();
        contact = new Contact();
        lstConWrap = new List<ContactWrapper>();
        for(Contact con: [SELECT Id,Contact.FirstName,Contact.lastName FROM Contact WHERE AccountId =: account.Id]){
            lstConWrap.add(new ContactWrapper(con)); 
        } 
    }

        public PageReference moveContacts(){
            try{
                List<Contact> conList = new List<Contact>();
    
                for(ContactWrapper conWrap: lstConWrap){
                    if(conWrap.selected == true){
                        conWrap.contact.AccountId = contact.AccountId;
                        conList.add(conWrap.contact);  
                    }
                }
                update conList;
            }
           catch(Exception e){}  
        
            PageReference pg = new PageReference('/' + contact.AccountId);
            pg.setRedirect(true);
            return pg;
       }
      List<Contact> conList = new List<Contact>();
        public PageReference moveAllContacts(){
            try{
                

                for(ContactWrapper conWrap: lstConWrap){
                    conWrap.contact.AccountId = contact.AccountId;
                    conList.add(conWrap.contact);  
                }
                //update conList;
                 Database.SaveResult[] result = Database.update(conList, false);
            }
            catch(Exception e){
               
            } 
        
            PageReference pg = new PageReference('/' + contact.AccountId);
            pg.setRedirect(true);
            return pg;
        }
    
     public class ContactWrapper{
        
        public Contact contact{get;set;}
        public Boolean selected{get;set;}
        
        public ContactWrapper(Contact contact){
            this.Contact = contact;
            this.selected = false;
        }
    }
    
}