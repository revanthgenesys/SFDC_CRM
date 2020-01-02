public class BackOfficeAccountUtil {
    
   static Map<String, Back_Office_Account__c> upsertBoaMap;
    
   @InvocableMethod
   public static void addBOAbyServiceContract (List<ServiceContract> srvConList) {
   	 // process flow when a new Service Contract Created
   	  try {
   	 	 upsertBoaByServiceContracts(srvConList);
   	  }
   	  catch(Exception ex) {
   	  	 ErrorLogUtil.insertLog('BackOfficeAccountUtil', 'Error from method addBOAbyServiceContract: ' +  ex.getMessage(), 'BackOfficeAccountUtil.upsertBoaByServiceContracts(srvConList)');     
    	 return;	
   	  }
   }
      
   public static void upsertBoaByServiceContracts (List<ServiceContract> srvConList) {
        if ( srvConList == null || upsertBoaMap != null)
              return;

        upsertBoaMap = new Map<String, Back_Office_Account__c>();
       
        for ( ServiceContract srvCon : srvConList )  {

            if ( srvCon.Sold_To_Name__c == null || srvCon.End_User_Name__c == null  || srvCon.Service_Contract_Type__c == 'Cloud' ||
                (upsertBoaMap.get((Id) srvCon.Sold_To_Name__c + '_' + (Id) srvCon.End_User_Name__c) != null) )  {
                     continue;
            }

            String contrOffering = BackOfficeAccountService.getServiceContractOffering(srvCon);
            if ( contrOffering != 'PureConnect On Premise' && contrOffering  != 'PureEngage On Premise' )
                  continue;

            BackOfficeAccountService.BoaInstance boa = new BackOfficeAccountService.BoaInstance(srvCon.Sold_To_Name__c, srvCon.End_User_Name__c, false, contrOffering);
            
            if (boa.boaInst != null )
               upsertBoaMap.put(boa.boaInst.Unique_STEU__c, boa.boaInst);   
        }

        if ( !upsertBoaMap.isEmpty() )  {

              List<Database.upsertResult> upsertResults = Database.upsert(upsertBoaMap.values(), false);
              
              for (Database.UpsertResult result : upsertResults) {
                   if (!result.isSuccess())
                        System.debug('UPSERT FAILED : ' + result.getErrors()[0].getMessage());
             }
  
        }
    }
    
  public static void setBoaFields (List<Back_Office_Account__c> boaList) {

         if ( boaList == null || upsertBoaMap != null )
              return;
         
         upsertBoaMap = new Map<String, Back_Office_Account__c>();
         
         for (Back_Office_Account__c boa : boaList)  {
            
            if ( boa.Sold_To_Account__c == null || boa.End_User_Account__c == null  ||
                (upsertBoaMap.get((Id) boa.Sold_To_Account__c + '_' + (Id) boa.End_User_Account__c) != null) )  {
                     continue;
            }
            
            Back_Office_Account__c verifiedBoa = BackOfficeAccountService.getBoaContractFieldsBySTEU (boa.Sold_To_Account__c, boa.End_User_Account__c, boa.Platform__c);
            
            if ( verifiedBoa != null ) {                                
                boa.Contract_Status__c = verifiedBoa.Contract_Status__c;
                boa.Platform__c     = verifiedBoa.Platform__c;
                boa.Unique_STEU__c  = verifiedBoa.Unique_STEU__c;
                boa.End_User_Name__c = verifiedBoa.End_User_Name__c;
                boa.Sold_To_Name__c = verifiedBoa.Sold_To_Name__c;       
            }                       
         }                        
    }
    
}