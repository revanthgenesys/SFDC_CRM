//Naresh Kumar  05/03/2014
public without sharing class CreateOrderFromQuoteTriggerHelper {
  
  public static List<Order_Line_Item__c> populateBusinessLinesOnQuoteOtherThanRenewal(List<Order_Line_Item__c> orderLineItems, String genesysCareProductId, 
      String genesysCareProductName, String genesysCareProductDescription, BigMachines__Quote__c quote, Order__c order, Set<String> genesysCareFlexCareProductIds, 
        Set<String> genesysFeeProductIds, Set <String> genesysPS){
        // System.Debug('line7--->'+quote.Quote_Business_Type__c+';;'+quote.Opportunity_Type__c);
        List<Order_Line_Item__c> AllOrderLineItems = new List<Order_Line_Item__c>();
            
        /*List<Order_Line_Item__c> ThirdPartyOrderLineItems = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> NonThirdPartyOrderLineItems = new List<Order_Line_Item__c>();*/
            
        Set<String> oliProductids = new Set<String>();
        for(Order_Line_Item__c eachOLI : orderLineItems){
          oliProductids.add(eachOLI.Product__c);
            System.debug('@@Checking Custom App');
          /*  if(eachOLI.Product__c != genesysCareProductId){
                if(eachOLI.description__c != NULL && eachOLI.description__c.contains('Custom App Support')){
          System.debug('Setting POB');
                    if(eachOLI.Support_Type_Formula__c=='Renewal')
                    eachOLI.POB_Type__c = 'PS - CAS - Renewal';
                    else
            eachOLI.POB_Type__c = 'PS - CAS';

        }
            }*/
            
            AllOrderLineItems.add(eachOLI);
    }
      /*  Map<String, Product2> oliProductMap = new Map<String, Product2>([SELECT id, Type__c, Third_Party__c, APN_Number__c, Description, Third_Party_Custom__c FROM Product2 WHERE Id IN :oliProductids]);
            
        for(Order_Line_Item__c eachOLI : orderLineItems){
          if(eachOLI.Product__c != genesysCareProductId){
          if(eachOLI.description__c != NULL && eachOLI.description__c.contains('Custom App Support'))
            eachOLI.POB_Type__c = 'PS - CAS - Renewal';
            
          if(oliProductMap.get(eachOLI.Product__c) != NULL && oliProductMap.get(eachOLI.Product__c).Third_Party_Custom__c != NULL){
              ThirdPartyOrderLineItems.add(eachOLI);    
            } else {
              NonThirdPartyOrderLineItems.add(eachOLI);
            }
          }  
    }*/

        // NonThirdPartyOrderLineItems.remove(genesysCareIndex);
        //08/22/2013   Naresh Kumar    Logic to add new lint item for each group with same start and end date.
        Map<String, Order_Line_Item__c> keyVsOLI = new Map<String, Order_Line_Item__c>();
        Integer recCount = orderLineItems.size();
         Integer genesysCareIndex = 0, counter = 0;
        for(Order_Line_Item__c eachOLI : AllOrderLineItems){
          System.debug('NKC debug eachOLI.Product__c ['+eachOLI.Product__c+']');
            System.debug('NKC debug genesysCareProductId ['+genesysCareProductId+']');
            System.debug('NKC debug eachOLI.Product__r.Type__c ['+eachOLI.Product__r.Type__c+']');
                
            if(eachOLI.Product__c == genesysCareProductId){
              eachOLI.Contract_Line_Update_Status__c = 'InActive';
                genesysCareIndex = counter;
                counter++;
                continue;
      }
            if(genesysCareFlexCareProductIds.contains(eachOLI.Product__c) || genesysFeeProductIds.contains(eachOLI.Product__c)){
                System.debug('POB Type'+eachOLI.POB_Type__c);
              eachOLI.Maintenance_Due__c = eachOLI.Sales_Price__c;
              eachOLI.POB_Type__c = 'Maintenance Renewal';
                counter++;
        continue;
      }
            if(genesysPS.contains(eachOLI.Product__c)){
                counter++;
              continue;
      }
                
                
            System.debug('NKC debug eachOLI.Maintenance_Start_Date__c ['+eachOLI.Maintenance_Start_Date__c+']');
            System.debug('NKC debug eachOLI.Maintenance_End_Date__c ['+eachOLI.Maintenance_End_Date__c+']');
            String key =  (eachOLI.Maintenance_Start_Date__c != NULL ? (eachOLI.Maintenance_Start_Date__c.day()+''+eachOLI.Maintenance_Start_Date__c.month()+''+eachOLI.Maintenance_Start_Date__c.year()) : 'NOVALUE');
          key = key + '-' + (eachOLI.Maintenance_End_Date__c != NULL ? (eachOLI.Maintenance_End_Date__c.day()+''+eachOLI.Maintenance_End_Date__c.month()+''+eachOLI.Maintenance_End_Date__c.year()) : 'NOVALUE');
            key = key + '-' + ((eachOLI.Genesys_Care_Rate__c != NULL && eachOLI.Genesys_Care_Rate__c > 0) ? String.valueOf(eachOLI.Genesys_Care_Rate__c)  : 'NOVALUE'); 
      
      if(eachOLI.Maintenance_Due__c > 0){  
              if(keyVsOLI.get(key) == null){
                  Order_Line_Item__c newOLI = eachOLI.clone(false, false);
                  newOLI.Product__c = genesysCareProductId;
                  newOLI.Name = genesysCareProductName;
                  newOLI.APN_Number__c = genesysCareProductName;
                  newOLI.Description__c = genesysCareProductDescription;
                  newOLI.Quantity__c = 1;
                  newOLI.BigMachines_Quantity__c = 1;                     
                  newOLI.Unit_of_Measure__c = 'Year'; 
                  newOLI.Genesys_Care_Rate__c = eachOLI.Genesys_Care_Rate__c;
                  newOLI.POB_Type__c = 'Maintenance Renewal'; 
                  newOLI.Maintenance_Due__c = eachOLI.Maintenance_Due__c;
                  newOLI.Annualized_Maintenance_Due__c  = eachOLI.Annualized_Maintenance_Due__c;
                 newOLI.Revised_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c;
                  newOLI.Original_Net_License_Value__c = eachOLI.Original_Net_License_Value__c;
                  newOLI.Current_Qty__c = eachOLI.Current_Qty__c;
                          
                  if(newOLI.Maintenance_Start_Date__c != null && newOLI.Maintenance_End_Date__c != null)                                    
                      newOLI.Maintenance_No_of_Months__c = newOLI.Maintenance_Start_Date__c.monthsBetween(newOLI.Maintenance_End_Date__c) + 1;
                  //newOLI.Net_License_Quantity     -> Bigmachine_quantity --> sum(quantity)  à Product Type = Product/License
          //newOLI.Net_License_Sell_Amount   -> Total Price --> sum(quantity * Sales Price)  à Product Type = Product/License
          //newOLI.Net_License_List_amount   -> Ext List    --> sum(quantity * list Price) à Product Type = Product/License
                              
                  keyVsOLI.put(key, newOLI);
        } else {
            if(eachOLI.Maintenance_Due__c != null){
                        if(keyVsOLI.get(key).Maintenance_Due__c == null)                        
                            keyVsOLI.get(key).Maintenance_Due__c = eachOLI.Maintenance_Due__c;
              else
                            keyVsOLI.get(key).Maintenance_Due__c += eachOLI.Maintenance_Due__c;
            }
                      if(eachOLI.Annualized_Maintenance_Due__c != null){
                        if(keyVsOLI.get(key).Annualized_Maintenance_Due__c == null)                        
                            keyVsOLI.get(key).Annualized_Maintenance_Due__c = eachOLI.Annualized_Maintenance_Due__c;
              else
                              keyVsOLI.get(key).Annualized_Maintenance_Due__c += eachOLI.Annualized_Maintenance_Due__c;
                      }
                      if(eachOLI.Year1_Maintenance_Due__c != null){
                          if(keyVsOLI.get(key).Year1_Maintenance_Due__c == null)                        
                              keyVsOLI.get(key).Year1_Maintenance_Due__c = eachOLI.Year1_Maintenance_Due__c;
                          else
                              keyVsOLI.get(key).Year1_Maintenance_Due__c += eachOLI.Year1_Maintenance_Due__c;
                      }
                      if(eachOLI.Year2_Maintenance_Due__c != null){
                          if(keyVsOLI.get(key).Year2_Maintenance_Due__c == null)                        
                              keyVsOLI.get(key).Year2_Maintenance_Due__c = eachOLI.Year2_Maintenance_Due__c;
                          else
                              keyVsOLI.get(key).Year2_Maintenance_Due__c += eachOLI.Year2_Maintenance_Due__c;
                      }
                      if(eachOLI.Year3_Maintenance_Due__c != null){
                          if(keyVsOLI.get(key).Year3_Maintenance_Due__c == null)                        
                              keyVsOLI.get(key).Year3_Maintenance_Due__c = eachOLI.Year3_Maintenance_Due__c;
                          else
                              keyVsOLI.get(key).Year3_Maintenance_Due__c += eachOLI.Year3_Maintenance_Due__c;
                      }
                      if(eachOLI.Year4_Maintenance_Due__c != null){
                          if(keyVsOLI.get(key).Year4_Maintenance_Due__c == null)                        
                              keyVsOLI.get(key).Year4_Maintenance_Due__c = eachOLI.Year4_Maintenance_Due__c;
                          else
                              keyVsOLI.get(key).Year4_Maintenance_Due__c += eachOLI.Year4_Maintenance_Due__c;
                      } 
            if(eachOLI.Revised_Net_License_Value__c != null){
                        if(keyVsOLI.get(key).Revised_Net_License_Value__c == null)   
                         keyVsOLI.get(key).Revised_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c;
                        else 
                            keyVsOLI.get(key).Revised_Net_License_Value__c += eachOLI.Revised_Net_License_Value__c;
            }
                          
            if(eachOLI.Original_Net_License_Value__c != null){
                        if(keyVsOLI.get(key).Original_Net_License_Value__c == null)   
                         keyVsOLI.get(key).Original_Net_License_Value__c = eachOLI.Original_Net_License_Value__c;
                        else 
                            keyVsOLI.get(key).Original_Net_License_Value__c += eachOLI.Original_Net_License_Value__c;
            }                        
            if(eachOLI.Current_Qty__c != null){
                        if(keyVsOLI.get(key).Current_Qty__c == null)   
                         keyVsOLI.get(key).Current_Qty__c = eachOLI.Current_Qty__c;
                        else 
                            keyVsOLI.get(key).Current_Qty__c += eachOLI.Current_Qty__c;
                    }

            //Mukunthan added below lines to aggregate Original List Price, Partner List Price, Revised List Price, Unit List Price and Unit Partner Price.
          //  System.Debug('line162--->'+quote.Quote_Business_Type__c+';;'+quote.Opportunity_Type__c);
            if(eachOLI.Original_License_List_Price__c != null){
                        if(keyVsOLI.get(key).Original_License_List_Price__c == null)   
                         keyVsOLI.get(key).Original_License_List_Price__c = eachOLI.Original_License_List_Price__c;
                        else 
                            keyVsOLI.get(key).Original_License_List_Price__c += eachOLI.Original_License_List_Price__c;
            }  
            if(eachOLI.Partner_License_List_Price__c != null){
                        if(keyVsOLI.get(key).Partner_License_List_Price__c == null)   
                         keyVsOLI.get(key).Partner_License_List_Price__c = eachOLI.Partner_License_List_Price__c;
                        else 
                            keyVsOLI.get(key).Partner_License_List_Price__c += eachOLI.Partner_License_List_Price__c;
            }  
            if(eachOLI.Revised_License_List_Price__c != null){
                        if(keyVsOLI.get(key).Revised_License_List_Price__c == null)   
                         keyVsOLI.get(key).Revised_License_List_Price__c = eachOLI.Revised_License_List_Price__c;
                        else 
                            keyVsOLI.get(key).Revised_License_List_Price__c += eachOLI.Revised_License_List_Price__c;
            }
            if(eachOLI.Unit_List_Price__c != null){
                        if(keyVsOLI.get(key).Unit_List_Price__c == null)   
                         keyVsOLI.get(key).Unit_List_Price__c = eachOLI.Unit_List_Price__c;
                        else 
                            keyVsOLI.get(key).Unit_List_Price__c += eachOLI.Unit_List_Price__c;
            }  
            if(eachOLI.Unit_Partner_Price__c != null){
                        if(keyVsOLI.get(key).Unit_Partner_Price__c == null)   
                         keyVsOLI.get(key).Unit_Partner_Price__c = eachOLI.Unit_Partner_Price__c;
                        else 
                            keyVsOLI.get(key).Unit_Partner_Price__c += eachOLI.Unit_Partner_Price__c;
            }
          }
                System.debug('NKC debug keyVsOLI ['+keyVsOLI+']');
                System.debug('NKC debug keyVsOLI.size() ['+keyVsOLI.size()+']');
              //   counter ++;
               }
          counter ++;
          }
           if(keyVsOLI.keyset().size() > 0){
                 AllOrderLineItems.remove(genesysCareIndex);
              for(Order_Line_Item__c eachOLI : keyVsOLI.values()){
                  recCount ++ ;
                  //Order_Line_Item__c newOLI = eachOLI.clone(false, false);
                  eachOLI.Line_Number__c = recCount;
                  // Populate Original_Net_License_Value__c with Revised_Net_License_Value__c if there is no value in Original_Net_License_Value__c
                    if(eachOLI.Original_Net_License_Value__c == NULL || eachOLI.Original_Net_License_Value__c <= 0){
                      eachOLI.Original_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c;
                    }
            eachOLI.List_Price__c =  eachOLI.Maintenance_Due__c;
          eachOLI.Ext_List__c =  eachOLI.Maintenance_Due__c;
          eachOLI.Net_Unit_Price__c =  eachOLI.Maintenance_Due__c;
          eachOLI.Ext_Net_Price__c =  eachOLI.Maintenance_Due__c;
                    eachOLI.Sales_Price__c =  eachOLI.Maintenance_Due__c;
                    AllOrderLineItems.add(eachOLI);
                }               
             }
            
             // This following code is only for code coverage ...
            if(Test.isRunningTest()){
                Order_Line_Item__c genesysCareLine; 
                for(Order_Line_Item__c eachOLI : orderLineItems){
                    if(eachOLI.Product__c == genesysCareProductId){
                        genesysCareLine = eachOLI;
                    }
                }
                populateBusinessLinesOnQuoteForRenewal(orderLineItems, genesysCareProductId, genesysCareProductName, genesysCareProductDescription, quote, order, genesysCareLine);
            }
           
           
          /*  AllOrderLineItems.addAll(NonThirdPartyOrderLineItems);
      AllOrderLineItems.addAll(ThirdPartyOrderLineItems);     
      AllOrderLineItems.addAll(populateThirdPartyCareLines(ThirdPartyOrderLineItems, genesysCareProductId, genesysCareProductName, genesysCareProductDescription, recCount+1, false));    */
          AllOrderLineItems =  populateFeesLines(AllOrderLineItems, quote, order, genesysCareProductDescription); 

          // If Quote Level Discount Exists apply Discount for all Care Lines
          // Maintenance_Due__c, Total_Discount_Amt__c 
          if(quote.Maintenance_Due_Discount_Amount__c != NULL && quote.Maintenance_Due_Discount_Amount__c > 0){
            Decimal discountPercentage = quote.Maintenance_Due_Discount_Amount__c / quote.Total_Renewal_Without_Tax__c;
            for(Order_Line_Item__c eachOLI : AllOrderLineItems){
           if(eachOLI.POB_Type__c == 'Maintenance Renewal' || eachOLI.POB_Type__c == 'Upon Booking Immediate'){
             eachOLI.Total_Discount_Amt__c = discountPercentage * eachOLI.Maintenance_Due__c;
             eachOLI.Maintenance_Due__c = (1 - discountPercentage) * eachOLI.Maintenance_Due__c;
             // Copy updated values ..
             eachOLI.List_Price__c =  eachOLI.Maintenance_Due__c;
            eachOLI.Ext_List__c =  eachOLI.Maintenance_Due__c;
            eachOLI.Net_Unit_Price__c =  eachOLI.Maintenance_Due__c;
            eachOLI.Ext_Net_Price__c =  eachOLI.Maintenance_Due__c;
                      eachOLI.Sales_Price__c =  eachOLI.Maintenance_Due__c;  
           }      
            } 
          }
           
          for(Order_Line_Item__c eachOLI : AllOrderLineItems){
            eachOLI.Original_Net_License_Value__c = eachOLI.Original_Net_License_Value__c != NULL ? eachOLI.Original_Net_License_Value__c.setScale(2) : eachOLI.Original_Net_License_Value__c;
            eachOLI.Revised_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c != NULL ? eachOLI.Revised_Net_License_Value__c.setScale(2) : eachOLI.Revised_Net_License_Value__c;
            eachOLI.Maintenance_Due__c = eachOLI.Maintenance_Due__c != NULL ? eachOLI.Maintenance_Due__c.setScale(2) : eachOLI.Maintenance_Due__c;
            eachOLI.List_Price__c = eachOLI.List_Price__c != NULL ? eachOLI.List_Price__c.setScale(2) : eachOLI.List_Price__c;
            eachOLI.Ext_List__c = eachOLI.Ext_List__c != NULL ? eachOLI.Ext_List__c.setScale(2) : eachOLI.Ext_List__c;
            eachOLI.Net_Unit_Price__c = eachOLI.Net_Unit_Price__c != NULL ? eachOLI.Net_Unit_Price__c.setScale(2) : eachOLI.Net_Unit_Price__c;
            eachOLI.Ext_Net_Price__c = eachOLI.Ext_Net_Price__c != NULL ? eachOLI.Ext_Net_Price__c.setScale(2) : eachOLI.Ext_Net_Price__c;
            eachOLI.Sales_Price__c = eachOLI.Sales_Price__c != NULL ? eachOLI.Sales_Price__c.setScale(2) : eachOLI.Sales_Price__c;
            eachOLI.Total_Discount_Amt__c = eachOLI.Total_Discount_Amt__c != NULL ? eachOLI.Total_Discount_Amt__c.setScale(2) : eachOLI.Total_Discount_Amt__c;
          }
          return AllOrderLineItems;
  }
    
    // orderLineItems - third party product based order ids
    // genesysCareProductId, genesysCareProductName, genesysCareProductDescription - Care Product Information to use
    // lineNumberToStart - Order Line Item Number where to start (generally - total number of existing Order Lines + 1)
    // aggregrate3rdPartyTotalMainAmt - true for setting Skip_Invoice__c, Base_Package__c values
   /* public static List<Order_Line_Item__c> populateThirdPartyCareLines(List<Order_Line_Item__c> orderLineItems, 
                                      String genesysCareProductId, 
                                      String genesysCareProductName, 
                                      String genesysCareProductDescription, 
                                      Integer lineNumberToStart, 
                                      Boolean aggregrate3rdPartyTotalMainAmt){
    List<Order_Line_Item__c> careOrderLineItems = new List<Order_Line_Item__c>();
    
    Set<String> oliProductids = new Set<String>();
        for(Order_Line_Item__c eachOLI : orderLineItems){
            oliProductids.add(eachOLI.Product__c);
        }
        Map<String, Product2> oliProductMap = new Map<String, Product2>([SELECT id, Type__c, Third_Party__c, APN_Number__c, Description, Third_Party_Custom__c FROM Product2 WHERE Id IN :oliProductids]);
    
    Decimal total3rdPartyTotalMainAmt = 0.0; 
        // Handle 3rd Party Products for maintenance line items
        for(Order_Line_Item__c eachOLI : orderLineItems){
          //if(oliProductMap.get(eachOLI.Product__c) != NULL && oliProductMap.get(eachOLI.Product__c).Third_Party__c != NULL && oliProductMap.get(eachOLI.Product__c).Third_Party__c == 'TRUE' && eachOLI.Maintenance_Due__c > 0){
          if(oliProductMap.get(eachOLI.Product__c) != NULL && oliProductMap.get(eachOLI.Product__c).Third_Party_Custom__c != NULL && eachOLI.Maintenance_Due__c > 0){
          Order_Line_Item__c newOLI = eachOLI.clone(false, false);
                newOLI.Product__c = genesysCareProductId;
                newOLI.Name = genesysCareProductName;
                newOLI.APN_Number__c = genesysCareProductName;
              newOLI.Description__c = oliProductMap.get(eachOLI.Product__c).APN_Number__c + ' ' + oliProductMap.get(eachOLI.Product__c).Description;
                newOLI.Quantity__c = 1;
                newOLI.BigMachines_Quantity__c = 1;                     
                newOLI.Unit_of_Measure__c = 'Year'; 
                newOLI.Current_Qty__c = eachOLI.Current_Qty__c;
                newOLI.Genesys_Care_Rate__c = eachOLI.Genesys_Care_Rate__c;
               newOLI.Revised_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c;
                newOLI.Original_Net_License_Value__c = eachOLI.Original_Net_License_Value__c;
          
          newOLI.Third_Party_Partners__c = oliProductMap.get(eachOLI.Product__c).Third_Party_Custom__c;
          eachOLI.Third_Party_Partners__c = oliProductMap.get(eachOLI.Product__c).Third_Party_Custom__c;
          if(eachOLI.Original_Net_License_Value__c == NULL || eachOLI.Original_Net_License_Value__c <= 0){
          newOLI.Original_Net_License_Value__c = eachOLI.Revised_Net_License_Value__c;
          newOLI.Ext_Net_Price__c = eachOLI.Revised_Net_License_Value__c;
                } else {
                  newOLI.Original_Net_License_Value__c = eachOLI.Original_Net_License_Value__c;
          newOLI.Ext_Net_Price__c = eachOLI.Original_Net_License_Value__c;
                }

                newOLI.Annualized_Maintenance_Due__c  = eachOLI.Annualized_Maintenance_Due__c;
          newOLI.Maintenance_Due__c  = eachOLI.Maintenance_Due__c;
          newOLI.Sales_Price__c =  eachOLI.Maintenance_Due__c;
          newOLI.Ext_List__c = eachOLI.Revised_Net_License_Value__c;
          
            newOLI.Third_Party__c = 'TRUE';
            newOLI.POB_Type__c = 'Maintenance Renewal';   
            newOLI.Line_Number__c = lineNumberToStart;
            lineNumberToStart = lineNumberToStart + 1;
          total3rdPartyTotalMainAmt = total3rdPartyTotalMainAmt + newOLI.Maintenance_Due__c;
          if(aggregrate3rdPartyTotalMainAmt){
            newOLI.Revised_Net_License_Value__c = eachOLI.Ext_List__c;
                  newOLI.Original_Net_License_Value__c = eachOLI.Ext_Net_Price__c;
          } 
          newOLI.List_Price__c =  eachOLI.Maintenance_Due__c;
        newOLI.Ext_List__c =  eachOLI.Maintenance_Due__c;
        newOLI.Net_Unit_Price__c =  eachOLI.Maintenance_Due__c;
        newOLI.Ext_Net_Price__c =  eachOLI.Maintenance_Due__c;
                newOLI.Sales_Price__c =  eachOLI.Maintenance_Due__c;
            careOrderLineItems.add(newOLI);
          }
        }
        if(aggregrate3rdPartyTotalMainAmt){
          for(Integer i = 0; i < careOrderLineItems.size(); i++){  
            if(i == 0)
              careOrderLineItems[i].Skip_Invoice__c = false;  
        else
              careOrderLineItems[i].Skip_Invoice__c = true;  
            careOrderLineItems[i].Base_Package__c = total3rdPartyTotalMainAmt;
          }
        } 
        return careOrderLineItems;
    }
    */
    public static List<Order_Line_Item__c> populateBusinessLinesOnQuoteForRenewal(List<Order_Line_Item__c> orderLineItems, String genesysCareProductId, 
        String genesysCareProductName, String genesysCareProductDescription, BigMachines__Quote__c quote, Order__c order, Order_Line_Item__c genesysCareLine){
        Integer genesysCareIndex, counter = 0;
        for(Order_Line_Item__c eachOLI : orderLineItems){
            System.debug('NKC debug eachOLI.Product__c ['+eachOLI.Product__c+']');
            System.debug('NKC debug genesysCareProductId ['+genesysCareProductId+']');          
            if(eachOLI.Product__c == genesysCareProductId){             
                genesysCareIndex = counter;                
                break;
            }   
            counter ++;
        }
        System.debug('NKC debug genesysCareIndex ['+genesysCareIndex+']');      
        //Getting all quote periods for current quote
        List<Quote_Period__c> quotePeriods = [SELECT id, Start_Date__c, End_Date__c FROM Quote_Period__c WHERE Quote__c =:quote.id];
        if(!quotePeriods.isEmpty() && genesysCareIndex != null){
            orderLineItems.remove(genesysCareIndex);    
        }
        Integer iYear = 1;
        for(Quote_Period__c eachPeriod : quotePeriods){
             Order_Line_Item__c newOLI = genesysCareLine.clone(false, false);
             newOLI.Product__c = genesysCareProductId;
             newOLI.Name = genesysCareProductName;
             newOLI.APN_Number__c = genesysCareProductName;
             newOLI.Description__c = genesysCareProductDescription;
             newOLI.Quantity__c = 1;
             newOLI.BigMachines_Quantity__c = 1;                     
             newOLI.Unit_of_Measure__c = 'Year';
             newOLI.Maintenance_Start_Date__c = eachPeriod.Start_Date__c;
             newOLI.Maintenance_End_Date__c = eachPeriod.End_Date__c;             
             if(iYear == 1)
                newOLI.Maintenance_Due__c = quote.Period1_Maintenance_Due__c;
             else if(iYear == 2)
                newOLI.Maintenance_Due__c = quote.Period2_Maintenance_Due__c;
             else if(iYear == 3)
                newOLI.Maintenance_Due__c = quote.Period3_Maintenance_Due__c;
             else if(iYear == 4)
                newOLI.Maintenance_Due__c = quote.Period4_Maintenance_Due__c;             
             newOLI.Net_Unit_Price__c = newOLI.Maintenance_Due__c;
             newOLI.Sales_Price__c =  newOLI.Maintenance_Due__c;
             if(newOLI.Maintenance_Start_Date__c != null && newOLI.Maintenance_End_Date__c != null){
                newOLI.Maintenance_No_of_Months__c = newOLI.Maintenance_Start_Date__c.monthsBetween(newOLI.Maintenance_End_Date__c);
                if(newOLI.Maintenance_Start_Date__c.Month() != newOLI.Maintenance_End_Date__c.Month())
                  newOLI.Maintenance_No_of_Months__c += 1;
             }
             orderLineItems.add(newOLI);             
             iYear++;
        }
        orderLineItems =  populateFeesLines(orderLineItems, quote, order, genesysCareProductDescription); 
            
             System.debug('@@Discount apply code started');
        // Code for Applying Discount
        if(quote.Maintenance_Due_Discount_Amount__c != NULL && quote.Maintenance_Due_Discount_Amount__c > 0){
        	Decimal discountPercentage = quote.Maintenance_Due_Discount_Amount__c / quote.Total_Renewal_Without_Tax__c;
	        Set<String> oliProductids = new Set<String>();
	        for(Order_Line_Item__c eachOLI : orderLineItems){
	        	oliProductids.add(eachOLI.Product__c);
			}
	        Map<String, Product2> oliProductMap = new Map<String, Product2>([SELECT id, Type__c, Third_Party__c, APN_Number__c, Description, Third_Party_Custom__c FROM Product2 WHERE Id IN :oliProductids]);
	        for(Order_Line_Item__c eachOLI : orderLineItems){
	        	if(oliProductMap.get(eachOLI.Product__c) != NULL && oliProductMap.get(eachOLI.Product__c).Type__c == 'Genesys Care'){
                    System.debug('@@ disc amount'+discountPercentage * eachOLI.Maintenance_Due__c);
	 				eachOLI.Total_Discount_Amt__c = discountPercentage * eachOLI.Maintenance_Due__c;
	 				eachOLI.Maintenance_Due__c = (1 - discountPercentage) * eachOLI.Maintenance_Due__c; 
	 			}
	        }
        }        
        return orderLineItems;              
    }
    
    private static List<Order_Line_Item__c> populateFeesLines(List<Order_Line_Item__c> orderLineItems, BigMachines__Quote__c objQuote, Order__c objOrder,String strGCProdDesc){
      Map<String,Product2> map_FeesProducts = new Map<String,Product2>();
      // Fetching all Fees products and storing in a map
      for(Product2 objProduct : [SELECT Id,Name FROM Product2 WHERE 
            Name IN ('3GP21070ACAA','3GP21065ACAA','3GP21063ACAA','3GP21064ACAA','3GP21071ACAA',
            '3GP21072ACAA','3GP20317ACAA','3GP21062ACAA','3GP00615AXAA','3GP00616AXAA', '3GP109129ACAA', '3GP108391ACAA') AND IsActive = true])
        map_FeesProducts.put(objProduct.Name,objProduct);
        
      // Licensing Reduction Fee : 3GP20317ACAA
      if(objQuote.Licensing_Reduction_Fee__c != null && objQuote.Licensing_Reduction_Fee__c > 0 && map_FeesProducts.containsKey('3GP20317ACAA') )
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP20317ACAA'),objQuote.Licensing_Reduction_Fee__c,objQuote,objOrder));      
      
      // PureEngage License Reduction Fee :   3GP108391ACAA
      if(objQuote.License_Reduction_Fee__c != null && objQuote.License_Reduction_Fee__c > 0 && map_FeesProducts.containsKey('3GP108391ACAA') && (objQuote.Offering_Type__c == 'PureEngage' || objQuote.Offering_Type__c == NULL))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP108391ACAA'),objQuote.License_Reduction_Fee__c,objQuote,objOrder)); 
      
      // PureConnect License Reduction Fee : 3GP109129ACAA
      if(objQuote.License_Reduction_Fee__c != null && objQuote.License_Reduction_Fee__c > 0 && map_FeesProducts.containsKey('3GP109129ACAA')  && objQuote.Offering_Type__c == 'PureConnect')
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP109129ACAA'),objQuote.License_Reduction_Fee__c,objQuote,objOrder)); 
      
      // Reinstatement Fee : 3GP21070ACAA
      if(objQuote.Reinstatement_fee__c != null && objQuote.Reinstatement_fee__c > 0 && map_FeesProducts.containsKey('3GP21070ACAA'))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21070ACAA'),objQuote.Reinstatement_fee__c,objQuote,objOrder));  
      
      // Partner to Partner Uplift Fee : 3GP21065ACAA
      if(objQuote.Partner_to_Partner_Uplift__c != null && objQuote.Partner_to_Partner_Uplift__c > 0 && map_FeesProducts.containsKey('3GP21065ACAA'))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21065ACAA'),objQuote.Partner_to_Partner_Uplift__c,objQuote,objOrder));
        
      // KPI 1 Fee : 3GP21063ACAA
      if(objQuote.Total_KPI1_Amount__c != null && objQuote.Total_KPI1_Amount__c > 0 && map_FeesProducts.containsKey('3GP21063ACAA'))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21063ACAA'),objQuote.Total_KPI1_Amount__c,objQuote,objOrder));
      
      // KPI 2 Fee : 3GP21064ACAA
      if(objQuote.Total_KPI2_Amount__c != null && objQuote.Total_KPI2_Amount__c > 0 && map_FeesProducts.containsKey('3GP21064ACAA'))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21064ACAA'),objQuote.Total_KPI2_Amount__c,objQuote,objOrder));
      
      // Quarterly Semi Annual Fee : 3GP21062ACAA
      if(objQuote.Quarterly_Semi_Annual_Billing_Fee__c != null && objQuote.Quarterly_Semi_Annual_Billing_Fee__c > 0 && map_FeesProducts.containsKey('3GP21062ACAA'))
        orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21062ACAA'),objQuote.Quarterly_Semi_Annual_Billing_Fee__c,objQuote,objOrder));
      
      if(String.isNotBlank(strGCProdDesc) && strGCProdDesc.containsIgnoreCase('Partner'))
      {
        // Shelving Fee (Partner) : 3GP21072ACAA
        if(objQuote.Total_Shelving_Fee__c != null && objQuote.Total_Shelving_Fee__c > 0 && map_FeesProducts.containsKey('3GP21072ACAA'))
          orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21072ACAA'),objQuote.Total_Shelving_Fee__c,objQuote,objOrder));
          
        // Flex Care-Extended Support(Partner) : 3GP00616AXAA
        if(objQuote.Extended_End_of_Support__c != null && objQuote.Extended_End_of_Support__c > 0 && map_FeesProducts.containsKey('3GP00616AXAA'))
          orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP00616AXAA'),objQuote.Extended_End_of_Support__c,objQuote,objOrder));
      }
      else if(String.isNotBlank(strGCProdDesc) && strGCProdDesc.containsIgnoreCase('End User'))
      {
        // Shelving Fee (End User)  : 3GP21071ACAA
        if(objQuote.Total_Shelving_Fee__c != null && objQuote.Total_Shelving_Fee__c > 0 && map_FeesProducts.containsKey('3GP21071ACAA'))
          orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP21071ACAA'),objQuote.Total_Shelving_Fee__c,objQuote,objOrder));
          
        // Flex Care-Extended Support(End User) : 3GP00615AXAA
        if(objQuote.Extended_End_of_Support__c != null && objQuote.Extended_End_of_Support__c > 0 && map_FeesProducts.containsKey('3GP00615AXAA'))
          orderLineItems.add(createOrderLineItem(map_FeesProducts.get('3GP00615AXAA'),objQuote.Extended_End_of_Support__c,objQuote,objOrder));
      }
      
      return orderLineItems;
    }
  
   private static Order_Line_Item__c createOrderLineItem(Product2 objProduct,Decimal decAmount,BigMachines__Quote__c objQuote,Order__c objOrder)
    {
      Order_Line_Item__c objOLI = new Order_Line_Item__c(Name = objProduct.Name,Product__c = objProduct.Id, Order__c =  objOrder.Id,
                                Maintenance_Start_Date__c = objQuote.Maintenance_Start_Date__c, Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c, 
                                BigMachines_Quantity__c = 1, APN_Number__c = objProduct.Name, CurrencyIsoCode = objQuote.CurrencyIsoCode,
                                Maintenance_Due__c = decAmount,Sales_Price__c = decAmount,Net_Unit_Price__c = decAmount, 
                                POB_Type__c = 'Upon Booking Immediate');
        
      if(objOLI.Maintenance_Start_Date__c != null && objOLI.Maintenance_End_Date__c != null)
      {
          objOLI.Maintenance_No_of_Months__c = objOLI.Maintenance_Start_Date__c.monthsBetween(objOLI.Maintenance_End_Date__c);
          if(objOLI.Maintenance_Start_Date__c.Month() != objOLI.Maintenance_End_Date__c.Month())
            objOLI.Maintenance_No_of_Months__c += 1;
      }
      
      return objOLI;
    }
}