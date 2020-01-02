global class AddressMatchUpdate implements Schedulable {
    
    
    global void execute(SchedulableContext sc)
    {
        AccountAddressmerge b = new AccountAddressmerge ();     
        
        database.executebatch(b,50);
    }

}