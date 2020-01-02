public class updateofferplatformtypehandler {
    public static void updateOfferingPlatformType(List<SObject> listOfrecords, Map<Id, SObject> oldMap){
        for(SObject eachrecord : listOfrecords){
            if(oldMap == null ){
                if(eachrecord.get('Lead_Offer__c') == 'PureCloud'){
                    eachrecord.put('Offerings_Type__c', 'PureCloud');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise'){
                    eachrecord.put('Offerings_Type__c', 'PureConnect');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Cloud'){
                    eachrecord.put('Offerings_Type__c', 'PureConnect');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Cloud Partner PPU'){
                    eachrecord.put('Offerings_Type__c', 'PureConnect');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise Subscription'){
                    eachrecord.put('Offerings_Type__c', 'PureConnect');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise Rental'){
                    eachrecord.put('Offerings_Type__c', 'PureConnect');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                } 
                else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Cloud'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Cloud Partner PPU'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise Subscription'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise Rental'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'On Premise');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'Premier Edition Cloud'){
                    eachrecord.put('Offerings_Type__c', 'Premier Edition');
                    eachrecord.put('Platform_Type__c' , 'Cloud');
                }
                else if(eachrecord.get('Lead_Offer__c') == 'Outbound Engagement Cloud'){
                    eachrecord.put('Offerings_Type__c', 'PureEngage');
                    eachrecord.put('Platform_Type__c' , 'PureEngage');
                }
                
            }
            if(oldMap != null)
            {
                sobject oldrecord = oldMap.get(''+eachrecord.get('id'));
                System.Debug('eachrecord.Lead_Offer__c--->'+eachrecord.get('Lead_Offer__c'));
                System.Debug('oldrecord.Lead_Offer__c--->'+oldrecord.get('Lead_Offer__c'));
                //if(eachrecord.get('Lead_Offer__c')!= oldrecord.get('Lead_Offer__c')){
                    if(eachrecord.get('Lead_Offer__c') == 'PureCloud'){
                        eachrecord.put('Offerings_Type__c', 'PureCloud');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise'){
                        eachrecord.put('Offerings_Type__c', 'PureConnect');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Cloud'){
                        eachrecord.put('Offerings_Type__c', 'PureConnect');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Cloud Partner PPU'){
                        eachrecord.put('Offerings_Type__c', 'PureConnect');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise Subscription'){
                        eachrecord.put('Offerings_Type__c', 'PureConnect');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureConnect Premise Rental'){
                        eachrecord.put('Offerings_Type__c', 'PureConnect');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    } 
                    else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Cloud'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Cloud Partner PPU'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise Subscription'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'PureEngage Premise Rental'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'On Premise');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'Premier Edition Cloud'){
                        eachrecord.put('Offerings_Type__c', 'Premier Edition');
                        eachrecord.put('Platform_Type__c' , 'Cloud');
                    }
                    else if(eachrecord.get('Lead_Offer__c') == 'Outbound Engagement Cloud'){
                        eachrecord.put('Offerings_Type__c', 'PureEngage');
                        eachrecord.put('Platform_Type__c' , 'PureEngage');
                    }
                //}
            }      
        }
    }
    
}