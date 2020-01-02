@isTest
public class TestTokenFormController {
  
    @isTest
    static void submitForm_InvalidForm_DoesntSendEmail(){
        
        String tokenFormString = '{}';
        
        TokenFormController.submitForm(tokenFormString);        
    }
    
    @isTest
    static void submitForm_NullForm_DoesntSendEmail(){
        
        TokenFormController.submitForm(null);
    }
    
    @isTest
    static void submitForm_ValidForm_DoesntSendEmail(){
        String tokenFormString = '{"orderDate":"2018-02-22","purchaserName":"Nik Mills","purchaserCompany":"Genesys","purchaserEmail":"Nik.Mills@genesys.com","purchaserPhone":"9022259493","contactName":"Nik Mills","contactCompany":"Genesys","contactEmail":"Nik.Mills@genesys.com","contactPhone":"9022259493","ppl001Quantity":1,"ppl001Notes":"PPL001 test notes","loc001Quantity":null,"loc001Notes":"","cfr001Quantity":null,"cfr001Notes":"","cfr002Quantity":null,"cfr002Notes":"","cfr003Quantity":null,"cfr003Notes":"","cfr004Quantity":null,"cfr004Notes":"","cfr005Quantity":null,"cfr005Notes":"","cfr006Quantity":null,"cfr006Notes":"","cfr007Quantity":null,"cfr007Notes":"","cfr008Quantity":null,"cfr008Notes":"","cfr009Quantity":null,"cfr009Notes":"","dia001Quantity":null,"dia001Notes":"","qua001Quantity":null,"qua001Notes":"","scr001Quantity":null,"scr001Notes":"","dat001Quantity":null,"dat001Notes":"","dat002Quantity":null,"dat002Notes":"","dat003Quantity":null,"dat003Notes":"","dat004Quantity":null,"dat004Notes":"","dat005Quantity":null,"dat005Notes":"","dat006Quantity":null,"dat006Notes":"","dat007Quantity":null,"dat007Notes":"","dat008Quantity":null,"dat008Notes":"","sup001Quantity":null,"sup001Notes":"","sup002Quantity":null,"sup002Notes":"","sup003Quantity":null,"sup003Notes":"","sup004Quantity":null,"sup004Notes":"","con001Quantity":null,"con001Notes":"","con002Quantity":null,"con002Notes":"","con003Quantity":null,"con003Notes":"","con004Quantity":null,"con004Notes":"","con005Quantity":null,"con005Notes":""}';

        TokenFormController.submitForm(tokenFormString);
        
    }
}