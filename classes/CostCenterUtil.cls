/************************************************************************************
Purpose :  Utility class for Cost center project
Written By :  Naresh Kumar	08/27/2018
Test Classes :  
*************************************************************************************/
public class CostCenterUtil {
	
    public static Boolean getBlackoutFlag(){
        List<Cost_Center_Blackout_Peroid__c> listOfBlackoutPeriods = [SELECT Start_Date__c, End_Date__c FROM Cost_Center_Blackout_Peroid__c
                                                                     WHERE Start_Date__c <=: System.today() AND End_Date__c >=: System.today()];
		return !listOfBlackoutPeriods.isEmpty();   
    }    
}