public class CreditMemoTriggerHandler {
    public static void beforeInsert(List<Credit_Memo__c> newCreditList, Map<Id, Credit_Memo__c> oldCreditMap, boolean isUpdate, boolean isAfter){
        Map<Id, List<Credit_Memo__c>> map_OrderIdCreditMemoList = new Map<Id, List<Credit_Memo__c>>();
        for(Credit_Memo__c creditMemo : newCreditList){
            if((!isUpdate && creditMemo.Credit_Full_Invoice__c && creditMemo.SFDC_Sales_Order1__c != null)
                || (isUpdate && creditMemo.SFDC_Sales_Order1__c != null && creditMemo.Credit_Full_Invoice__c && 
                    (!oldCreditMap.get(creditMemo.Id).Credit_Full_Invoice__c || oldCreditMap.get(creditMemo.Id).SFDC_Sales_Order1__c != creditMemo.SFDC_Sales_Order1__c))){
                if(!map_OrderIdCreditMemoList.containsKey(creditMemo.SFDC_Sales_Order1__c)){
                    map_OrderIdCreditMemoList.put(creditMemo.SFDC_Sales_Order1__c, new List<Credit_Memo__c>());
                }
                map_OrderIdCreditMemoList.get(creditMemo.SFDC_Sales_Order1__c).add(creditMemo);
            }
            
            if(!isAfter && creditMemo.Final_Credit_Amount__c != null && creditMemo.Final_Credit_Amount__c < 100 && creditMemo.Ready_for_Approval__c && 
                    creditMemo.Status__c != 'Approved - Pending Debooking' && creditMemo.Status__c != 'Approved - Pending CreditMemo' && 
                    creditMemo.Status__c != 'Completed' && creditMemo.Status__c != 'Approved'){
                //creditMemo.Status__c = 'Approved';
            }
        }
        if(map_OrderIdCreditMemoList.size() > 0){
            if(isAfter){
                List<Credit_Memo_Line_Item__c> list_CreditMemoLineItem = new List<Credit_Memo_Line_Item__c>();
                for(Order__c ordr : [SELECT Id, TotalOrder__c, Product_Description__c, (SELECT Id, Total_Price__c FROM Order_Line_Items__r) FROM Order__c WHERE Id IN :map_OrderIdCreditMemoList.keySet()]){
                    for(Credit_Memo__c credtMemo : map_OrderIdCreditMemoList.get(ordr.Id)){
                        for(Order_Line_Item__c oli : ordr.Order_Line_Items__r){
                            Credit_Memo_Line_Item__c creditLineItem = new Credit_Memo_Line_Item__c();
                            creditLineItem.Credit_Memo__c = credtMemo.Id;
                            creditLineItem.Order__c = ordr.Id;
                            creditLineItem.Order_Line_Item__c = oli.Id;
                            creditLineItem.Original_Amount__c = oli.Total_Price__c;
                            creditLineItem.Credit_Amount__c = oli.Total_Price__c;
                            list_CreditMemoLineItem.add(creditLineItem);
                        }
                    }
                }
                if(list_CreditMemoLineItem.size() > 0){
                    insert list_CreditMemoLineItem;
                }
            }
            else {
                for(Order__c ordr : [SELECT Id, TotalOrder__c FROM Order__c WHERE Id IN :map_OrderIdCreditMemoList.keySet()]){
                    for(Credit_Memo__c credtMemo : map_OrderIdCreditMemoList.get(ordr.Id)){
                        credtMemo.Original_Amount_NU__c = ordr.TotalOrder__c;
                        credtMemo.Credit_Amount_NU__c = ordr.TotalOrder__c;
                        
                        //Commented as requested by Rob on 08/10/2018
                        //credtMemo.Rebill_Amount_NU__c = ordr.TotalOrder__c;
                    }
                }
            }
        }
    }
    
    public static void validation(List<Credit_Memo__c> updateCreditList, Map<Id, Credit_Memo__c> oldCreditMap){
     
        Schema.DescribeSObjectResult a_desc = Credit_Memo__c.sObjectType.getDescribe(); 
        //for the Account object, you can replace that with any object you have, standard or custom
        Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
         
        Set<String> set_creditMemo = new Set<String>();
        for(Credit_Memo__c creditMemo : updateCreditList){  
             
            boolean isOtherfieldUpdate = false;
            boolean isLocked = false;
            boolean isNSfieldUpdate = false;
            boolean isNSLocked = false;
            boolean isStatusUpdated = false;
            boolean isCompleteUpdated = false;
            
            // When status is completed or cancelled, and user try to update any other field except rebill invoice section.
            if((creditMemo.Status__c == 'Completed' || creditMemo.Status__c == 'Cancelled') && creditMemo.Status__c == oldCreditMap.get(creditMemo.Id).Status__c){
                for(Schema.sObjectField field : a_fields.values()){  
                    schema.describefieldresult dfield = field.getDescribe(); 
                    if(dfield.isUpdateable()){
                        //Condition added by priyank in below if as per the requirement shared by JJ.
                        //As discussed with JJ on 5 Nov 2018. Status will be open at every stage belowif commented and added new if condition.
                        /*if((String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Notes__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' || String.valueOf(field) == 'Date_Completed__c') 
                                && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isOtherfieldUpdate = true;
                        }*/
                        if((String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Status__c' || String.valueOf(field) == 'Notes__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' || String.valueOf(field) == 'Date_Completed__c' || String.valueOf(field) == 'Credit_Type__c' || String.valueOf(field) == 'Credit_Memo_Type__c' || String.valueOf(field) == 'Reason_for_Credit__c' || String.valueOf(field) == 'Revenue_Comments_Instructions__c' || String.valueOf(field) == 'More_Info_Reason__c' || String.valueOf(field) == 'NS_Debook_Number__c' || String.valueOf(field) == 'NS_CM_Number__c' || String.valueOf(field) == 'Date_Completed__c' || String.valueOf(field) == 'Owner') 
                                && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                                //Below line commented by Priyank
                                //isOtherfieldUpdate = true;
                        }
                        else{
                            if(creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                                isLocked = true;
                            }
                        }
                    }
                }
            }
            
            // When status is cancelled, and user try to update status to any other status
            // When status is completed, and user try to update status to any other status except cancelled
            // condition Commented below line on 5 Nov 2018.As discueed we can change the status.
            if((creditMemo.Status__c != 'Cancelled' && oldCreditMap.get(creditMemo.Id).Status__c == 'Cancelled')
                            /*|| ( creditMemo.Status__c != 'Cancelled' && creditMemo.Status__c != 'Completed' && oldCreditMap.get(creditMemo.Id).Status__c == 'Completed')*/){
                isLocked = true;
            }
            
            
            // When status is Approved - Pending Debooking and user try to update any other field except rebill invoice section.
            /*
            if(creditMemo.Status__c == 'Approved - Pending Debooking' && creditMemo.Status__c == oldCreditMap.get(creditMemo.Id).Status__c){
                for(Schema.sObjectField field : a_fields.values()){  
                    schema.describefieldresult dfield = field.getDescribe(); 
                    if(dfield.isUpdateable()){
                        if((String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Notes__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' || String.valueOf(field) == 'Date_Completed__c') && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            // do nothing
                        }
                        else
                        if(creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isNSLocked = true;
                        }
                    }
                }
            }
            
            // When status is Approved - Pending CreditMemo and user try to update any other field except rebill invoice section and NS Deebook
            //Number.
            
            if(((creditMemo.Status__c == 'Approved - Pending CreditMemo') && creditMemo.Status__c == oldCreditMap.get(creditMemo.Id).Status__c) || (creditMemo.Status__c == 'Approved - Pending CreditMemo' && creditMemo.Status__c != oldCreditMap.get(creditMemo.Id).Status__c)){
                for(Schema.sObjectField field : a_fields.values()){  
                    schema.describefieldresult dfield = field.getDescribe(); 
                    if(dfield.isUpdateable()){
                        if((String.valueOf(field) == 'NS_Debook_Number__c' || String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' || String.valueOf(field) == 'Notes__c' ||String.valueOf(field) == 'Status__c' || String.valueOf(field) == 'Date_Completed__c') 
                                            && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isNSfieldUpdate = true;
                        }
                        else
                        if(creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isNSLocked = true;
                        }
                    }
                }
            }
            
            //When status is Awaiting Rebill and user try to update any other field except rebill invoice section.
            
            if(creditMemo.Status__c == 'Awaiting Rebill' || creditMemo.Status__c == 'Cancelled'){
                for(Schema.sObjectField field : a_fields.values()){  
                    schema.describefieldresult dfield = field.getDescribe(); 
                    if(dfield.isUpdateable()){
                        if((String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' || String.valueOf(field) == 'Notes__c' ||String.valueOf(field) == 'Status__c' || String.valueOf(field) == 'Date_Completed__c') 
                                            && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            // do nothing
                        }
                        else
                        if(creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isNSLocked = true;
                        }
                    }
                }
            }
            
            // When status is completed user can only update the 
            
            if(creditMemo.Status__c == 'Completed' && oldCreditMap.get(creditMemo.Id).Status__c == 'Awaiting Rebill'){
                for(Schema.sObjectField field : a_fields.values()){  
                    schema.describefieldresult dfield = field.getDescribe(); 
                    if(dfield.isUpdateable()){
                        if((String.valueOf(field) == 'NS_CM_Number__c' || String.valueOf(field) == 'Rebill_Invoice__c' || String.valueOf(field) == 'Rebill_Invoice_Amount__c' 
                                || String.valueOf(field) == 'Notes__c' || String.valueOf(field) == 'Status__c' || String.valueOf(field) == 'Date_Completed__c') 
                                && creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            // isOtherfieldUpdate = true;
                        }
                        else
                        if(creditMemo.get(String.valueOf(field)) != oldCreditMap.get(creditMemo.Id).get(String.valueOf(field))){
                            isCompleteUpdated = true;
                        }
                    }
                }
            }
            
            // When user try to update the status from Approved - Pending CreditMemo to More Info Needed, New, Ready to review, inProgress.
            // It will throw an error of You can not update status to old Status.
            
            if(oldCreditMap.get(creditMemo.Id).Status__c == 'Approved - Pending CreditMemo' && creditMemo.Status__c != 'Awaiting Rebill' && creditMemo.Status__c != oldCreditMap.get(creditMemo.Id).Status__c && (creditMemo.Status__c != 'Cancelled' && creditMemo.Status__c != 'Completed')){
                isStatusUpdated = true;
            }
            
            // When user try to update the status from Approved - Pending Debooking to More Info Needed, New, Ready to review, inProgress,
            //Approved - Pending CreditMemo .It will throw an error of You can not update status to old Status.
            
            if(oldCreditMap.get(creditMemo.Id).Status__c == 'Approved - Pending Debooking' && creditMemo.Status__c != 'Completed' && creditMemo.Status__c != 'Awaiting Rebill' && creditMemo.Status__c != oldCreditMap.get(creditMemo.Id).Status__c && (creditMemo.Status__c != 'Cancelled' && creditMemo.Status__c != 'Approved - Pending CreditMemo')){
                isStatusUpdated = true;
            }
            
            // When user try to update the status from Awaiting Rebill to More Info Needed, New, Ready to review, inProgress,
            //Approved - Pending CreditMemo, Approved - Pending Debooking .It will throw an error of You can not update status to old Status.
            
            if(oldCreditMap.get(creditMemo.Id).Status__c == 'Awaiting Rebill' && creditMemo.Status__c != 'Completed' && creditMemo.Status__c != oldCreditMap.get(creditMemo.Id).Status__c && creditMemo.Status__c != 'Cancelled'){
                isStatusUpdated = true;
            }
            
            // Error Messages Below.
            
            if(isStatusUpdated){
                creditMemo.addError('You can not update status to old Status.');
            }
            
            if(isNSLocked){
                creditMemo.addError('You can update only Rebill Invoice, Rebill Invoice Amount  only.');
            }
            if((isOtherfieldUpdate && isLocked) || isCompleteUpdated){
                creditMemo.addError('Only NS CM Number, Rebill Invoice and Rebill Invoice Amount is editable.');
            } 
            else*/
            if(isLocked){
                creditMemo.addError('Credit Memo record is locked.');
            }
        }
    }
}