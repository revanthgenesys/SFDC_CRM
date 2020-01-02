/*
    Naresh Kumar    06/02/2013
*/
public without sharing class UpdateCaseProductControllerHelper {
    static Set<Id> supportProductIds = new Set<Id>(); //product 
    static Set<Id> supportProIds = new Set<Id>();
    private static String unspecifiedStringLiteral = 'Unknown';
    public static List<SelectOption> fetchProdLines(Case currentCase, Boolean isProductNotFound){
        List<SelectOption> prodLines = new List<SelectOption>();    
        SelectOption item = new SelectOption('', 'None');
        prodLines.add(item);
        Set<id> prodIds = new Set<Id>();
        if(isProductNotFound){
            for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product Line' 
                AND Customer_Available__c = true ORDER BY Name ASC]){
                item = new SelectOption(eachSP.id, eachSP.Name);
                prodLines.add(item);
            }
        }
        else{
        	Boolean isContactEmployee = false;
    		List<Contact> conts = [SELECT Account.Name FROM Contact WHERE id =: currentCase.contactId];
        	if(conts.size() > 0 && conts[0].Account.Name == 'Genesys - Employees')
           		isContactEmployee = true;
           	List<ContractLineItem> scLineItemList;
           	
        /* MS - 3/5/2015
           	if(isContactEmployee)
            	scLineItemList = [SELECT id, PriceBookEntry.Product2Id FROM ContractLineItem WHERE Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
            		AND ServiceContractId in (SELECT Service_Contract__c FROM Support_Access__c WHERE End_User_Account__c =: currentCase.End_User_Account__c AND 
            		Sold_To_Account__c =: currentCase.Sold_To_Account__c)];
            else
            	scLineItemList = [SELECT id, PriceBookEntry.Product2Id FROM ContractLineItem WHERE Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
            		AND ServiceContractId in (SELECT Service_Contract__c FROM Support_Access__c WHERE End_User_Account__c =: currentCase.End_User_Account__c AND 
            		Sold_To_Account__c =: currentCase.Sold_To_Account__c )];
         */
            scLineItemList = [SELECT id, PriceBookEntry.Product2Id 
							  FROM ContractLineItem 
                              WHERE Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
                                AND ServiceContract.End_User_Name__c =: currentCase.End_User_Account__c 
                                AND ServiceContract.Sold_To_Name__c =: currentCase.Sold_To_Account__c
                                AND ServiceContract.End_User_Name__c != null
                                AND ServiceContract.Sold_To_Name__c != null];	
            
            for(ContractLineItem eachLI : scLineItemList){
                prodIds.add(eachLI.PriceBookEntry.Product2Id);
            }
            Set<Id> productIds = new Set<Id>();
             supportProIds.clear();
            for(Product_Mapping__c eachPM : [SELECT Product__r.Parent_Product__c FROM Product_Mapping__c WHERE Sellable_Item__c IN : prodIds]){
                productIds.add(eachPM.Product__r.Parent_Product__c);
                supportProIds.add(eachPM.Product__c);
            }           
            supportProductIds.clear();
            
            for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product Line' 
                    AND Customer_Available__c = true AND  Id IN : productIds ORDER BY Name ASC]){
                item = new SelectOption(eachSP.id, eachSP.Name);
                prodLines.add(item);
                supportProductIds.add(eachSP.id);
            
            }
        }
        return prodLines;
    }
    public static String getProductLineId(Case currentCase){
        List<Support_Product__c> suppProducts =  [SELECT Parent_Product__c FROM Support_Product__c WHERE id =: currentCase.Support_Product__c 
                                                            AND Customer_Available__c = true ORDER BY Name ASC];
        if(!suppProducts.isEmpty())
                return suppProducts[0].Parent_Product__c;
        
        return null;    
    }
    public static List<SelectOption> fetchProds(Case currentCase,boolean isProductNotFound){    
        List<SelectOption> prods = new List<SelectOption>();
        SelectOption item = new SelectOption('', 'None');
        prods.add(item);
        System.debug('NKC debug currentCase.Product_Line__c ['+currentCase.Product_Line__c+']');
        System.debug('NKC debug supportProductIds ['+supportProductIds+']');
        System.debug('NKC debug ProductIds ['+supportProIds+']');
        
        List<Support_Product__c> suppProducts;
        List<SelectOption> tempProducts;
        if(isProductNotFound) {
            suppProducts =  [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product' AND Parent_Product__c =: currentCase.Product_Line__c AND Customer_Available__c = true ORDER BY Name ASC];          
            
        } else {
        if(currentCase.Product_Line__c == null)
            suppProducts =  [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product' AND Parent_Product__c in: supportProductIds AND Customer_Available__c = true  ORDER BY Name ASC];
        else {
             
             tempProducts = fetchProdLines(currentCase,false);
             suppProducts =  [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product' AND Parent_Product__c =: currentCase.Product_Line__c 
             		AND Customer_Available__c = true ORDER BY Name ASC];             
            }
        } 
         for(Support_Product__c eachSP: suppProducts){
            item = new SelectOption(eachSP.id, eachSP.Name);
            prods.add(item);
        }
        return prods;       
    }
    public static List<SelectOption> fetchMajorVersions(Case currentCase){
        List<SelectOption> majorVersions = new List<SelectOption>();
        SelectOption item;
        Set<Id> componentIds = new Set<Id>();   
        System.debug('NKC debug currentCase.Support_Product__c ['+currentCase.Support_Product__c+']');
        for(Support_Product__c eachSP : [SELECT id FROM Support_Product__c WHERE Product_Type__c = 'Component'
                AND Parent_Product__c =: currentCase.Support_Product__c AND Customer_Available__c = true ORDER BY Name ASC]){
            componentIds.add(eachSP.id);
        }
        System.debug('NKC debug componentIds ['+ componentIds +']');
        Set<String> setUniqueMajorVersions = new Set<String>();
        for(Product_Version__c eachSP : [SELECT Major_Release__c, Version__c FROM Product_Version__c WHERE Parent_Product__c IN : componentIds 
            AND Customer_Available__c = true ORDER BY Name DESC]){
           	if(eachSP.Version__c != null && eachSP.Version__c.length() >= 3){
           		String majorVersion = eachSP.Version__c.left(3);
	            if(!setUniqueMajorVersions.contains(majorVersion)){
	                if(majorVersion == 'Uns')
	                    item = new SelectOption(majorVersion, unspecifiedStringLiteral);
	                else
	                    item = new SelectOption(majorVersion, majorVersion);
	                majorVersions.add(item);
	                setUniqueMajorVersions.add(majorVersion);
	            }
           	}
        }
        majorVersions = addDefaultValues(majorVersions, null);
        return majorVersions;
    }
    
    public static List<SelectOption> fetchComponents(Case currentCase){
        List<SelectOption> components = new List<SelectOption>();
        SelectOption item;
        System.debug('NKC debug currentCase.Major_Release1__c ['+currentCase.Major_Release1__c+'] ');         
        for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c IN ('Component','Third Party')
                AND Parent_Product__c =: currentCase.Support_Product__c AND id IN ( SELECT Parent_Product__c FROM Product_Version__c WHERE Version__c LIKE :  currentCase.Major_Release1__c + '%' ) 
                AND Customer_Available__c = true ORDER BY Name ASC]){
            item = new SelectOption(eachSP.id, eachSP.Name);
            components.add(item);
        }
        components = addDefaultValues(components, 'Component');
        return components;
    }
    public static List<SelectOption> fetchProductVersion(Case currentCase){
        List<SelectOption> productVersions = new List<SelectOption>();
        SelectOption item;
        System.debug('NKC debug currentCase.Major_Release1__c ['+currentCase.Major_Release1__c+'] ');
        for(Product_Version__c eachSP : [SELECT id, Name FROM Product_Version__c WHERE Parent_Product__c =: currentCase.Component__c AND Version__c LIKE :  currentCase.Major_Release1__c + '%'
            AND Customer_Available__c = true ORDER BY Name DESC]){
            if(eachSP.Name == 'Unspecified')
                item = new SelectOption(eachSP.id, unspecifiedStringLiteral);
            else
                item = new SelectOption(eachSP.id, eachSP.Name);            
            productVersions.add(item);
        } 
        productVersions = addDefaultValues(productVersions, 'Product Version');
        return productVersions;
    }
    private static List<SelectOption> addDefaultValues(List<SelectOption> listOfItems, String objType){
    	List<SelectOption> sortedList = new List<SelectOption>();
    	SelectOption item = new SelectOption('', 'None');
    	sortedList.add(item);
    	    	
    	Boolean isUnknown = false;
        for(SelectOption eachItem : listOfItems){
        	if(eachItem.getLabel().contains(unspecifiedStringLiteral)){
        		isUnknown = true;
        		break;
        	}
        }     
        if(!isUnknown){        	
        	if(objType == 'Product Version'){
        		List<Product_Version__c> eachSP = [SELECT id, Name FROM Product_Version__c WHERE Name = 'Unspecified'];
        		if(!eachSP.isEmpty())
        		 	item = new SelectOption(eachSP[0].id, unspecifiedStringLiteral);
        	}
        	else if (objType == 'Component'){
        		List<Support_Product__c> eachSP = [SELECT id, Name FROM Support_Product__c WHERE Name = 'Unspecified'];
        		if(!eachSP.isEmpty())
        		 	item = new SelectOption(eachSP[0].id, unspecifiedStringLiteral);
        	}
        	else
        		item = new SelectOption(unspecifiedStringLiteral, unspecifiedStringLiteral);       	
        	sortedList.add(item);       	
        }
        sortedList.addAll(listOfItems);
        return sortedList;        
    }
}