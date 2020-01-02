@isTest (SeeAllData = True)
/* Mariya Steason - Aug 2018
   Test class: DDSTool_Test covers all classes with names starting with DDSTool
*/
public class DDSTool_Test {
    
    public static List<Id> qtSelected = new List<Id>();
       
    static testmethod void pureEngTst () {
    	Util.Bypass_Trigger_Chk = true;
    	
    	List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                        WHERE (BigMachines__Quote__r.Offering_Type__c = 'PureEngage On Premise' OR BigMachines__Quote__r.Offering_Type__c = null)
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Customer'
                           AND 	BigMachines__Quote__r.BigMachines__Is_Primary__c = true
                           AND BigMachines__Product__r.Type__c = 'Genesys Care'                             
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
        
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
        	
        try {     
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';             
             tpg.getScore();
             
             Product2 newProduct = new Product2();
	        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
	        newProduct.Name = 'Test';
	        newProduct.recordTypeId = rtypes[0].Id;
	        newProduct.zqu__SKU__c = 'Test1';
	        newProduct.Type__c = 'Product - Hardware';
	        insert newProduct;
	         qt[0].BigMachines__Product__c = newProduct.id;
	         qt[0].Ext_List_Price_1__c =1;
	         qt[0].Ext_List_Price_2__c =1;
	        update qt[0];
    
         Test.startTest();
            tpg.getScore(); 
            
           DDSToolMain dds = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds); 
	       thirdPartyOnly.calcScore(); 
	      	 
	       DDSToolPostCalc.DDSToolPostCalcPureEngage pstc = (DDSToolPostCalc.DDSToolPostCalcPureEngage) dds.postCalc; 
	       Decimal vol = pstc.getGUVolumeDisc(4000.0);	
           Decimal lp = dds.adjust.getTotalQuoteNonCntrctListPrice();
         Test.stopTest();
       
        }
        catch(Exception ex) {
          System.debug('pureEngTst - ERROR ' + ex.getMessage());
        } 
       }         
    }
     
    static testmethod void pureEngSubsptTst () {
    	Util.Bypass_Trigger_Chk = true;
    	
    	Product2 newProduct = new Product2();
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        newProduct.Name = 'Base Package';
        newProduct.recordTypeId = rtypes[0].Id;
        newProduct.zqu__SKU__c = 'Test3';
        newProduct.Type__c = 'Bundle';
        newProduct.Product_Specific_Discount__c = 5; 
        insert newProduct;
        List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureEngage Subscription'
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND Weightage__c != null AND Weightage__c > 0
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
         
        qt[0].BigMachines__Product__c = newProduct.id;
        qt[0].Ext_List_Price_1__c =1;
        qt[0].Ext_List_Price_2__c =1;
        qt[0].Dropped_Products__c = true;
        update qt;                     
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
        	
            try {  
             
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';
             
      Test.startTest();       
             tpg.getScore();
             
            DDSToolMain dds = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 2);
	        Decimal lp = dds.adjust.getBasePackage_ListPrice() ;
	        Decimal np = dds.adjust.getBasePackage_NetPrice() ; 
	        Decimal bp = dds.adjust.getSubscrBasePackagePriceLicPct() ;	  
            Decimal lst = dds.adjust.getTotalQuoteNonCntrctListPrice();
            Decimal lcp = dds.adjust.getTotalNonCntrctProdNetPriceLocal();
      /*      
            Product2 newProduct1 = new Product2(); 
            newProduct1.Name = 'Prod';
	        newProduct1.recordTypeId = rtypes[0].Id;
	        newProduct1.zqu__SKU__c = 'Test1';
	        newProduct1.Type__c = 'Product';
	        insert newProduct1;
	        qt[0].BigMachines__Product__c = newProduct1.id;
	        qt[0].Ext_List_Price_1__c =1;
	        qt[0].Ext_List_Price_2__c =1;
	        qt[0].Dropped_Products__c = true;
	        update qt;
	        
	         tpg.getScore(); 
     */	         
	    Test.stopTest();
	           
          }
         catch(Exception ex) {
          System.debug('pureEngSubsptTst - ERROR ' + ex.getMessage());
        } 
      }         
    }
    
    static testmethod void pureEngSubsptTst1 () {
    	Util.Bypass_Trigger_Chk = true;
    	
    	String cntr = DDSToolSelector.getSoldToCountryMapped('China');
    	
        Product2 newProduct = new Product2();
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        newProduct.Name = 'Test Prod';
        newProduct.recordTypeId = rtypes[0].Id;
        newProduct.zqu__SKU__c = 'Test1';
        newProduct.Type__c = 'Product';
        newProduct.Third_Party__c = 'True';
        insert newProduct;
        List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Product__r.Type__c,BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureEngage Subscription'
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND Weightage__c != null AND Weightage__c > 0
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c != 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
          
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
        	
        	qt[0].BigMachines__Product__c = newProduct.id;
	        qt[0].Ext_List_Price_1__c =1;
	        qt[0].Ext_List_Price_2__c =1;
	        qt[0].Dropped_Products__c = true;
	        update qt;              
        	
            try {
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';
             
             tpg.getScore();
              
             newProduct.Type__c = 'GU';
             newProduct.Product_Specific_Discount__c = 0;
	         update newProduct;
	         
	         DDSToolTestPage tpg2 = new DDSToolTestPage();
             tpg2.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg2.logLevel = '2';
             
             tpg2.getScore();
           }
        catch(Exception ex) {
          System.debug('pureEngSubsptTst1 - ERROR ' + ex.getMessage());
        } 
       
        }         
    }
    
    static testmethod void pureCnctIndirectTst () {
    	Util.Bypass_Trigger_Chk = true;
    	
    	List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c, BigMachines__Quote__r.Sold_To_Name__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect Subscription'
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Partner'
                           AND BigMachines__Quote__r.End_User_ID__r.Type = 'Customer'
                           AND BigMachines__Product__r.Type__c = 'Product'
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
        	
            try {   
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';
     
     Test.startTest();        
             tpg.getScore();
             
             Product2 newProduct = new Product2();
	        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
	        newProduct.Name = 'Test Prod';
	        newProduct.recordTypeId = rtypes[0].Id;
	        newProduct.zqu__SKU__c = 'Test1';
	        newProduct.Type__c = 'Product - Hardware';
	        insert newProduct;   
	        
	        qt[0].BigMachines__Product__c = newProduct.id;
	        qt[0].Ext_List_Price_1__c =1;
	        qt[0].Ext_List_Price_2__c =1;
	        qt[0].Dropped_Products__c = true;
	        update qt; 
	        
	        tpg.getScore();  
	 /*   
	        DDSToolMain dds = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 2);	 
	        DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds);
	        thirdPartyOnly.calcScore(); 
      	        
	        Decimal cd = DDSToolSelector.getPartnerContractualDiscount(qt[0].BigMachines__Quote__r.Sold_To_Name__c, 'PureConnect', false); 
      */
	   Test.stopTest();
	   
           }
         catch(Exception ex) {
          System.debug('pureCnctIndirectTst - ERROR ' + ex.getMessage());
        } 
       }         
    }
    
  static testmethod void pureCnctHWTst () {
    	Util.Bypass_Trigger_Chk = true;
        try {	
	    	List<BigMachines__Quote_Product__c> qtprod = [SELECT BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Quote__r.Sold_To_Name__c FROM BigMachines__Quote_Product__c 
	                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise'
	                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                          
	                           AND BigMachines__Product__r.Type__c = 'Product'
	                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Partner'
	                           AND  BigMachines__Product__r.Product_Specific_Discount__c = null
	                           AND BigMachines__Quote__c NOT IN :qtSelected
	                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
	                           
	        if ( !qtprod.isEmpty() )  { 
	           qtSelected.add(qtprod[0].BigMachines__Quote__c);
	            
		       DDSToolMain dds = DDSToolMain.getDDSToolMain(qtprod[0].BigMachines__Quote__c, 2);	       
		       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds); 
		       thirdPartyOnly.calcScore();    
		       
		       Decimal cd = DDSToolSelector.getPartnerContractualDiscount(qtprod[0].BigMachines__Quote__r.Sold_To_Name__c, 'PureConnect', false);        
	        } 
        }
	     catch(Exception ex) {
          System.debug('pureCnctHWTst - ERROR ' + ex.getMessage());
        }  
    }
    
  static testmethod void pureCnctHWTst3 () {  
    	Util.Bypass_Trigger_Chk = true;
   try {	    
        List<BigMachines__Quote_Product__c> qtprod2 = [SELECT BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Quote__r.Sold_To_Name__c
                         FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise'
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                          
                           AND BigMachines__Product__r.Type__c = 'Product'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Partner'
                           AND  BigMachines__Product__r.Product_Specific_Discount__c != null
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
         if ( !qtprod2.isEmpty() )  {  
           qtSelected.add(qtprod2[0].BigMachines__Quote__c);
              
	       DDSToolMain dds2 = DDSToolMain.getDDSToolMain(qtprod2[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly2 = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds2); 
	       thirdPartyOnly2.calcScore();  
	       
	       Decimal cd = DDSToolSelector.getPartnerContractualDiscount(qtprod2[0].BigMachines__Quote__r.Sold_To_Name__c, 'PureConnect', false);
         }
       }
      
       catch(Exception ex) {
          System.debug('pureCnctHWTst3 - ERROR ' + ex.getMessage());
        }         
    }
    
    static testmethod void pureCnctHWIndirectTst () {
    	Util.Bypass_Trigger_Chk = true;
        try {	
    	List<BigMachines__Quote_Product__c> qtprod = [SELECT BigMachines__Quote__c, BigMachines__Product__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise'
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                          
                           AND BigMachines__Product__r.Type__c = 'Product - Hardware'                           
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Customer'
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qtprod.isEmpty() )  {   
           qtSelected.add(qtprod[0].BigMachines__Quote__c);
             
	       DDSToolMain dds = DDSToolMain.getDDSToolMain(qtprod[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds); 
	       thirdPartyOnly.calcScore(); 
	       
	       dds.postCalc.getThirdPartyListPrice();
	       dds.postCalc.getThirdPartyNetPrice();
	       dds.postCalc.getThirdPartyDiscount();
	       dds.postCalc.getHardwareListPrice();
	       dds.postCalc.getHardwareNetPrice();
	       dds.postCalc.getHardwareDiscount();    
           Decimal lst = dds.adjust.getTotalQuoteNonCntrctListPrice();
            Decimal lcp = dds.adjust.getTotalNonCntrctProdNetPriceLocal();
        } 
        
        List<BigMachines__Quote_Product__c> qtprod2 = [SELECT BigMachines__Quote__c, BigMachines__Product__c FROM BigMachines__Quote_Product__c                       
                           WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise'
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                          
                           AND BigMachines__Product__r.Type__c = 'Product - Hardware'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Customer'
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' 
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qtprod2.isEmpty() )  {  
           qtSelected.add(qtprod2[0].BigMachines__Quote__c);
           
           qtprod2[0].Dropped_Products__c = true;
           update qtprod2[0];  
	       DDSToolMain dds2 = DDSToolMain.getDDSToolMain(qtprod2[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly2 = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds2); 
	       thirdPartyOnly2.calcScore();  
        } 
       }
        catch(Exception ex) {
          System.debug('pureCnctHWIndirectTst - ERROR ' + ex.getMessage());
        } 
    }
    
    static testmethod void pureThirdPtrtTst () {
    	Util.Bypass_Trigger_Chk = true;
    	List<BigMachines__Quote_Product__c> qtprod = [SELECT BigMachines__Quote__c, BigMachines__Product__c FROM BigMachines__Quote_Product__c 
                          WHERE (BigMachines__Quote__r.Offering_Type__c = 'PureEngage On Premise' OR BigMachines__Quote__r.Offering_Type__c = null)
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                        
                           AND BigMachines__Product__r.Type__c = 'Product' AND BigMachines__Product__r.Third_Party__c = 'true'
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qtprod.isEmpty() )  {
          qtSelected.add(qtprod[0].BigMachines__Quote__c);
         try {
           qtprod[0].Dropped_Products__c = true;
           qtprod[0].Ext_Net_Price__c = 0;  
           update qtprod[0];  
	       DDSToolMain dds = DDSToolMain.getDDSToolMain(qtprod[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds); 
	       thirdPartyOnly.calcScore(); 
	       
	       DDSToolPostCalc.DDSToolPostCalcPureEngage pstc = (DDSToolPostCalc.DDSToolPostCalcPureEngage) dds.postCalc; 
	       Decimal rate = pstc.getPredictedCareRate();
	       Decimal cc = pstc.getCareCustmrContrRate();	
	       Decimal camnt = pstc.getCareRateAmount();
	       Decimal vol = pstc.getGUVolumeDisc(4000.0);
           Decimal lst = dds.adjust.getTotalQuoteNonCntrctListPrice();
            Decimal lcp = dds.adjust.getTotalNonCntrctProdNetPriceLocal();
        }
        catch(Exception ex) {
          System.debug('pureThirdPtrtTst - ERROR ' + ex.getMessage());
        } 
       }
    }
    
    static testmethod void pureThirdPtrtTst2 () {
    	Util.Bypass_Trigger_Chk = true;
    	List<BigMachines__Quote_Product__c> qtprod = [SELECT BigMachines__Quote__c, BigMachines__Product__c FROM BigMachines__Quote_Product__c 
                          WHERE (BigMachines__Quote__r.Offering_Type__c = 'PureEngage On Premise' OR BigMachines__Quote__r.Offering_Type__c = null)
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'                        
                           AND BigMachines__Product__r.Type__c = 'Product' AND BigMachines__Product__r.Third_Party__c = 'true'                       
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qtprod.isEmpty() )  {
          qtSelected.add(qtprod[0].BigMachines__Quote__c);
         try {
           qtprod[0].Dropped_Products__c = false;
           qtprod[0].Ext_Net_Price__c = 0;           
           update qtprod[0];  

	       DDSToolMain dds = DDSToolMain.getDDSToolMain(qtprod[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds); 
	       thirdPartyOnly.calcScore();
	       
	         Product2 newProduct = new Product2();
	        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
	        newProduct.Name = 'Test Prod';
	        newProduct.recordTypeId = rtypes[0].Id;
	        newProduct.zqu__SKU__c = 'Test1';
	        newProduct.Type__c = 'Product';
	        newProduct.Third_Party__c = 'True';
	        newProduct.Product_Specific_Discount__c = 5;
	        insert newProduct;
	        
	        qtprod[0].BigMachines__Product__c = newProduct.id;
	        update qtprod[0];
	        
	       DDSToolMain dds2 = DDSToolMain.getDDSToolMain(qtprod[0].BigMachines__Quote__c, 2);	       
	       DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly2 = new DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly(dds2); 
	       thirdPartyOnly2.calcScore();	       	     
	       
        }
         catch(Exception ex) {
          System.debug('pureThirdPtrtTst2 - ERROR ' + ex.getMessage());
        } 
       }
    }
   
    static testmethod void pureCnctDirectSubscripTst () {
    	Util.Bypass_Trigger_Chk = true;
    	List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect Subscription'
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Customer'
                           AND BigMachines__Quote__r.End_User_ID__r.Type = 'Customer'
                           AND BigMachines__Product__r.Type__c = 'Product'
                           AND Weightage__c != null AND Weightage__c > 0
                           AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
          try {
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';
             
             tpg.getScore();
             
            DDSToolMain dds = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 2);
	        Decimal lp = dds.adjust.getBasePackage_ListPrice() ;
	        Decimal np = dds.adjust.getBasePackage_NetPrice() ; 
	        Decimal bp = dds.adjust.getSubscrBasePackagePriceLicPct() ;
            Decimal lst = dds.adjust.getTotalQuoteNonCntrctListPrice();
            Decimal lcp = dds.adjust.getTotalNonCntrctProdNetPriceLocal();
	       }
          catch(Exception ex) {
          System.debug('pureCnctDirectSubscripTst - ERROR ' + ex.getMessage());
        }         
      }         
    }
    
   static testmethod void pureCnctSubscripTst () {
   	    Util.Bypass_Trigger_Chk = true;
        List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Offering_Type__c = 'PureConnect Subscription'
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
                           AND BigMachines__Quote__r.Sold_To_Name__r.Type = 'Partner'
                           AND BigMachines__Quote__r.End_User_ID__r.Type = 'Customer'
                           AND BigMachines__Product__r.Type__c = 'Product'
                           AND Weightage__c != null AND Weightage__c > 0
                          AND BigMachines__Quote__c NOT IN :qtSelected
                           AND BigMachines__Quote__r.New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
                           
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
            try {   
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';             
             tpg.getScore();
             tpg.clear();
             
             BigMachines__Quote__c q = new BigMachines__Quote__c(id = qt[0].BigMachines__Quote__c, Order_Type__c ='Amend');
             update q;
             
             DDSToolTestPage t = new DDSToolTestPage();
             t.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             t.logLevel = '2';             
             t.getScore();

           /*  ///Mega- deal
             q.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c = Math.pow(10, 8);
             DDSToolTestPage t2 = new DDSToolTestPage();
             t2.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             t2.logLevel = '2';             
             t2.getScore(); */
           }
        catch(Exception ex) {
             System.debug('pureCnctSubscripTst - ERROR ' + ex.getMessage());
        }      
                                
        }         
    }
    static testmethod void Amenndm() {
   	    Util.Bypass_Trigger_Chk = true;
        List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                         WHERE BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise'
						   AND BigMachines__Quote__r.Order_Type__c LIKE 'Amend%'
                           AND BigMachines__Product__r.Type__c = 'Product' 
                           AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' 
                           AND BigMachines__Quantity__c > 1
 							 AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                                                    
        if ( !qt.isEmpty() )  {
        	qtSelected.add(qt[0].BigMachines__Quote__c);
            try {   
             
             BigMachines__Quote_Product__c pr = new BigMachines__Quote_Product__c (id=qt[0].id, 
                                                                                   BigMachines__Quantity__c = qt[0].BigMachines__Quantity__c + 1);
             update pr;
                 
             DDSToolTestPage tpg = new DDSToolTestPage();
             tpg.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg.logLevel = '2';             
             tpg.getScore();

              BigMachines__Quote_Product__c pr1 = new BigMachines__Quote_Product__c (id=qt[0].id, 
                                                                                   BigMachines__Quantity__c = 0);
             update pr1;
             DDSToolTestPage tpg2 = new DDSToolTestPage();
             tpg2.qte.Parent_Quote__c = qt[0].BigMachines__Quote__c;
             tpg2.getScore(); 
         
         }
        catch(Exception ex) {
          System.debug('pureCnctSubscripTst - ERROR ' + ex.getMessage());
        }      
                                
        }         
    }
    
     static testmethod void errorTst2() {
          List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                                        WHERE BigMachines__Product__r.Type__c = 'Product'
                                        AND Ext_Net_Price__c = null AND Ext_List__c = null AND List_Price_1__c = null LIMIT 1];
         
         if ( !qt.isEmpty() ) 
             try {
         	DDSToolMain dds2 = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 0);  
          }
        catch(Exception ex) {}
    }
    static testmethod void errorTst3() {
          List<BigMachines__Quote_Product__c> qt = [SELECT BigMachines__Quote__c FROM BigMachines__Quote_Product__c 
                                        WHERE BigMachines__Quote__r.Quote_Business_Type__c = 'Cloud'
                                        AND BigMachines__Quote__r.Offering_Type__c = 'PureCloud' LIMIT 1];
         
         if ( !qt.isEmpty() ) 
             try {
         	DDSToolMain dds2 = DDSToolMain.getDDSToolMain(qt[0].BigMachines__Quote__c, 0);  
          }
        catch(Exception ex) {}
    }
    
}