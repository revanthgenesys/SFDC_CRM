@isTest
private class MintigoTests_Genesys {
    static String getXMLResponse() {
        return '<?xml version=\'1.0\' encoding=\'utf-8\'?><data><number_of_employees_category_new></number_of_employees_category_new><is_mysql_user>False</is_mysql_user><company_country_category>United States of America</company_country_category><company_domain>mintigo.com</company_domain><contact_first_name>Tom</contact_first_name><contact_ad_rank>A</contact_ad_rank><sub_industry_category_new>Computer Software</sub_industry_category_new><company_phone>(650) 278-4180</company_phone><customer_company_name>Mintigo</customer_company_name><company_zip>94402</company_zip><is_obiee_user>False</is_obiee_user><company_city>SAN MATEO</company_city><score>99</score><company_name>MINTIGO, INC.</company_name><industry_category_new>Software</industry_category_new><customer_email></customer_email><has_intent_technology__mongodb>False</has_intent_technology__mongodb><is_aws_user>True</is_aws_user><annual_revenue_category_new></annual_revenue_category_new><is_sqlserver_user>False</is_sqlserver_user><contact_last_name>Thomas</contact_last_name><url>www.mintigo.com</url><is_sharepoint_user>False</is_sharepoint_user><mcid>7537138</mcid><created_on>2016-11-25 21:53:58.081616</created_on><company_address>155 BOVET ROAD</company_address><company_state_category>CA</company_state_category><is_oracle_db_user>False</is_oracle_db_user></data>';
    }

    @isTest static void testNullToEmpty() {
        MintigoScore_Genesys myInstance = new MintigoScore_Genesys();
        //System.assertEquals('', myInstance.nullToEmpty(null));
        //System.assertEquals('asdf', myInstance.nullToEmpty('asdf'));
    }
    
    @isTest static void testGetEnrichedValue() {
        MintigoScore_Genesys myInstance = new MintigoScore_Genesys();
        Dom.Document doc = new Dom.Document();
        doc.load('<root>' +
                 '<TrueTag>True</TrueTag>' +
                 '<FalseTag>False</FalseTag>' +
                 '<IntegerTag>6</IntegerTag>' +
                 '<DoubleTag>3.1416</DoubleTag>' +
                 '<StringTag>Hello, world!</StringTag>' +
                 '</root>');
        Dom.XmlNode root = doc.getRootElement();
        /*
        System.assertEquals(true,            myInstance.getEnrichedValue(root, 'TrueTag',    Boolean.class));
        System.assertEquals(false,           myInstance.getEnrichedValue(root, 'FalseTag',   Boolean.class));
        System.assertEquals(6,               myInstance.getEnrichedValue(root, 'IntegerTag', Integer.class));
        System.assertEquals(3.1416,          myInstance.getEnrichedValue(root, 'DoubleTag',  Double.class));
        System.assertEquals('Hello, world!', myInstance.getEnrichedValue(root, 'StringTag',  String.class));
        
        System.assertEquals(null, myInstance.getEnrichedValue(root, 'NonExistantTag', Boolean.class));
        System.assertEquals(null, myInstance.getEnrichedValue(root, 'NonExistantTag', Integer.class));
        System.assertEquals(null, myInstance.getEnrichedValue(root, 'NonExistantTag', Double.class));
        System.assertEquals(null, myInstance.getEnrichedValue(root, 'NonExistantTag', String.class));
        
        System.assertEquals(false, myInstance.getEnrichedValue(root, 'NonExistantTag', Boolean.class, true));
        System.assertEquals(0,     myInstance.getEnrichedValue(root, 'NonExistantTag', Integer.class, true));
        System.assertEquals(0.0,   myInstance.getEnrichedValue(root, 'NonExistantTag', Double.class, true));
        System.assertEquals('',    myInstance.getEnrichedValue(root, 'NonExistantTag', String.class, true));
        */
    }
    
    @isTest static void testEnrichAccounts() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', getXMLResponse());
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        Account o = new Account(Name='Mintigo',Website='www.mintigo.com');
        insert o;
        Account o1 = new Account(Name='Mintigo 2',Website='www.mintigo.com');
        o1.Mintigo_Do_Not_Enrich__c=true;
        insert o1;
        Test.stopTest();
        o = [Select MI_Industry__c from Account where Id = :o.id];
        //System.assertEquals('Software', o.MI_Industry__c);
        o1 = [Select MI_Industry__c from Account where Id = :o1.id];
        //System.assertNotEquals('Software', o1.MI_Industry__c);
    }     

}