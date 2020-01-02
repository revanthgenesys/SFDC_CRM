@isTest
public class ContactFactory {
	public static Contact CreateContact(String name)
    {
        // Create random number to work around dupe catcher.
        Long rnd =  Math.roundToLong(Math.random() * 100);
        Contact c = new Contact(
            LastName = name,
            Email = name + '_' + rnd + '@inin.com',
            Phone = '317-555-1212'
        );
        
        return c;
        
    }
    
    public static void SetAxId(Contact contact, string AxId)
    {
        contact.AX_Contact_Person_ID__c = AxId;
    }
}