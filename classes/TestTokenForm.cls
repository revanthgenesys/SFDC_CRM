@isTest
public class TestTokenForm {
    
    @isTest
    static void isValid_ValidForm_ReturnsTrue(){
        
        TokenForm tf = getValidTokenForm();
        
        System.assertEquals(true, tf.isValid());        
    }
    
    @isTest
    static void isValid_MissingOrderDate_ReturnsFalse(){
        
        TokenForm tf = getValidTokenForm();
        tf.orderDate = null;
               
        System.assertEquals(false, tf.isValid());    
    }
    
    @isTest
    static void isValid_MissingPurchaserName_ReturnsFalse(){
        
        TokenForm tf = getValidTokenForm();
        tf.purchaserName = '';
        
        System.assertEquals(false, tf.isValid());    
    }
    
    @isTest
    static void isValid_MissingPurchaserCompany_ReturnsFalse(){
        
    TokenForm tf = getValidTokenForm();
        tf.purchaserCompany = null;
        
        System.assertEquals(false, tf.isValid());    
    }
    
    @isTest
    static void isValid_MissingPurchaserEmail_ReturnsFalse(){
        
        TokenForm tf = getValidTokenForm();
        tf.purchaserEmail = '';
        
        System.assertEquals(false, tf.isValid());        
    }
    
    @isTest
    static void isValid_MissingPurchaserPhone_ReturnsFalse(){
        
        TokenForm tf = getValidTokenForm();
        tf.purchaserPhone = null;
        
        System.assertEquals(false, tf.isValid());
    }
    
    @isTest
    static void getEmailBody_ValidForm_ReturnsString(){
        
        TokenForm tf = getValidTokenForm();
        tf.ppl001Quantity = 1;
        
        String body = tf.getEmailBody();
        
        System.assertNotEquals(null, body);
        System.assertNotEquals('', body);        
    }
    
    @isTest
    static void getEmailSubject_ValidForm_ReturnsString(){
        
        TokenForm tf = getValidTokenForm();
        
        String subject = tf.getEmailSubject();
        
        System.assertEquals('PSS Service Order - [Genesys] - [2018-02-16]', subject);
    }
    
    @isTest
    static void getFromString_validValues_ReturnsObject(){
        
        String tokenFormString = '{"orderDate": "2018-02-16", "purchaserName":"Nik", "purchaserCompany":"Genesys", "purchaserEmail": "Nik.Mills@genesys.com", "purchaserPhone":"555-5555"}';
        
        TokenForm tf = TokenForm.getFromString(tokenFormString);
        
        System.assertNotEquals(null, tf);
        System.assertEquals('2018-02-16', tf.orderDate);
        System.assertEquals('Nik', tf.purchaserName);
        System.assertEquals('Genesys', tf.purchaserCompany);
        System.assertEquals('Nik.Mills@genesys.com', tf.purchaserEmail);
        System.assertEquals('555-5555', tf.purchaserPhone);        
    }
    
    
    private static TokenForm getValidTokenForm(){
        
        TokenForm tf = new TokenForm();
        tf.setDefaultValues();
        
        tf.orderDate = '2018-02-16';
        tf.purchaserName = 'Nik';
        tf.purchaserCompany = 'Genesys';
        tf.purchaserEmail = 'Nik.Mills@genesys.com';
        tf.purchaserPhone = '555-5555';
        
        return tf;        
    }
    
}