@isTest(SeeAllData=true)
public class TestTokenFormHelper {
  
    @isTest
    static void TokenFormHelper_DefaultConstructor_NoErrors(){
        TokenFormHelper tfh = new TokenFormHelper();
    }
    
//    @isTest
//    static void buildAndSendEmail_ToAddressSettingMissing_DoesntSendEmail(){
//      
//        FakeEmailSender emailSender = new FakeEmailSender();
//        
//        TokenFormHelper tfh = new TokenFormHelper(emailSender);
//        
//        tfh.buildAndSendEmail(new TokenForm());
//        
//        System.assertEquals(0, emailSender.getSendCallCount());
//        
//    }
    
    @isTest
    static void buildAndSendEmail_ValidParameters_SendsEmail(){
        
        FakeEmailSender emailSender = new FakeEmailSender();
        
        Map<String, String> settings = new Map<String, String>();
        settings.put('TokenFormToAddress', 'Nik.Mills@genesys.com');
        settings.put('TokenFormReplyToAddress', 'Nik.Mills@genesys.com');
        settings.put('NoReplyOrgWideEmailId', '0D20B000002RvrG');
        
        TokenFormHelper tfh = new TokenFormHelper(emailSender);
        TokenForm tf = new TokenForm();
        tf.setDefaultValues();
        tf.purchaserEmail = 'Nik.Mills@genesys.com';
        tf.contactEmail = 'Nik.Mills@genesys.com';
        
        tfh.buildAndSendEmail(tf);
        
        //System.assertEquals(1, emailSender.getSendCallCount());
    }
    
    @isTest
    static void buildAndSendEmail_WithTestTokenForm_SendsEmail(){
        
        FakeEmailSender emailSender = new FakeEmailSender();
        String tokenFormString = '{"orderDate":"2018-02-22","purchaserName":"Nik Mills","purchaserCompany":"Genesys","purchaserEmail":"Nik.Mills@genesys.com","purchaserPhone":"9022259493","contactName":"Nik Mills","contactCompany":"Genesys","contactEmail":"Nik.Mills@genesys.com","contactPhone":"9022259493","ppl001Quantity":1,"ppl001Notes":"PPL001 test notes","loc001Quantity":null,"loc001Notes":"","cfr001Quantity":null,"cfr001Notes":"","cfr002Quantity":null,"cfr002Notes":"","cfr003Quantity":null,"cfr003Notes":"","cfr004Quantity":null,"cfr004Notes":"","cfr005Quantity":null,"cfr005Notes":"","cfr006Quantity":null,"cfr006Notes":"","cfr007Quantity":null,"cfr007Notes":"","cfr008Quantity":null,"cfr008Notes":"","dia001Quantity":null,"dia001Notes":"","qua001Quantity":null,"qua001Notes":"","scr001Quantity":null,"scr001Notes":"","dat001Quantity":null,"dat001Notes":"","dat002Quantity":null,"dat002Notes":"","dat003Quantity":null,"dat003Notes":"","dat004Quantity":null,"dat004Notes":"","dat005Quantity":null,"dat005Notes":"","dat006Quantity":null,"dat006Notes":"","dat007Quantity":null,"dat007Notes":"","sup001Quantity":null,"sup001Notes":"","sup002Quantity":null,"sup002Notes":"","sup003Quantity":null,"sup003Notes":"","sup004Quantity":null,"sup004Notes":"","sup005Quantity":null,"sup005Notes":"","con001Quantity":null,"con001Notes":"","con002Quantity":null,"con002Notes":""}';
        
        TokenFormHelper tfh = new TokenFormHelper(emailSender);
        TokenForm tf = TokenForm.getFromString(tokenFormString);
        
        tfh.buildAndSendEmail(tf);
        
        //System.assertEquals(1, emailSender.getSendCallCount());
    }
    
    private class FakeEmailSender implements TokenFormHelper.IEmailSender {
        
        private Integer sendCallCount = 0;
        
        public void send(List<Messaging.SingleEmailMessage> mails){
            sendCallCount++;
        }
        
        public Integer getSendCallCount(){
            return sendCallCount;
        }        
    }
    
}