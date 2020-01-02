/*
 * Sivarajan Dhandapani 4/15/2014 
 * Queueable class to update contact portal access flag for partner users 
 */
public class ContactFlagUpdateQueueableJob implements Queueable{
    public List<Contact> cntToBeUpdated;
    public List<User> userToBeUpdated;
    
    public ContactFlagUpdateQueueableJob() {
        cntToBeUpdated = new List<Contact>();
        userToBeUpdated = new List<User>();
    }
    public ContactFlagUpdateQueueableJob(List<Contact> cntToBeUpdated,List<User> userToBeUpdated) {
        this.cntToBeUpdated = cntToBeUpdated;
        this.userToBeUpdated = userToBeUpdated;  
    }
    
    public void execute(QueueableContext context) {
        if(!cntToBeUpdated.isEmpty()) {
            try {
                update cntToBeUpdated; 
            }
            catch(DMLException ex) {
                String subject = 'Error while updating the contact field Partner portal access in Queueable class';
                String htmlBody = 'Hi <br/><br/>';
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    htmlBody += 'System was trying to update the field portal partner access in contact:' + ex.getDmlId(i) +'<br/>' +'. But it failed due to following error. <br/>' + 'Error Details :' + ex.getDmlMessage(i);
                }
                SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody); 
            }
        }
        
        if(!userToBeUpdated.isEmpty()) {
            try {
                update userToBeUpdated; 
            }
            catch(DMLException ex) {
                String subject = 'Error while updating the user field Genie access in Queueable class';
                String htmlBody = 'Hi <br/><br/>';
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    htmlBody += 'System was trying to update the field Genie access in user:' + ex.getDmlId(i) +'<br/>' +'. But it failed due to following error. <br/>' + 'Error Details :' + ex.getDmlMessage(i);
                }
                SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody); 
            }
        }
    }
}