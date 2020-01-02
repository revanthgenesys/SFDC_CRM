/* 
   Purpose: DDSToolInterface provides methods to interface with DDS tool
   Test class: DDSToolInterface_Test
*/
public class DDSToolInterface {

    public static string GetMessage(DDSToolMain ddsTM) {
      String message = '';
      
        if (ddsTM.errorMessage != null && !String.isBlank(ddsTM.errorMessage) ) 
            return ddsTM.errorMessage;
        
        if ( ddsTM.finalScore.MegaDeal != null && ddsTM.finalScore.MegaDeal == 'Y' )
            return System.Label.DDS_Mega_Deal;

        if ( ddsTM.finalScore.contractScoreAdjusted != null && ddsTM.finalScore.contractScoreAdjusted == 'Y' ) 
             message = System.Label.DDS_Contractual_Adjustment;

        if ( ddsTM.finalScore.EAPScoreAdjusted != null && ddsTM.finalScore.EAPScoreAdjusted == 'Y' ) {
             message += message != '' ? '<br/>' : '';
             message += System.Label.DDS_EAP_Adjustment;
        }
        
        if ( message == '' ) {
            if (ddsTM.finalScore.FinalScore == 1 ) 
                message = 'Based on a combination of factors this deal only earns a score of 1, which indicates it is not a good deal compared to its peers.  Please review the deal to determine if a score improvement is possible.';   
            
            else if (ddsTM.finalScore.FinalScore == 2 ) 
                message = 'Based on a combination of factors this deal only earns a score of 2.  Please review the deal to determine ways to improve the score.';
            
            else if (ddsTM.finalScore.FinalScore == 3 ) 
                message = 'This deal has earned a score of 3.  This is a good score but continue to evaluate the deal to see if it can be improved.';
            
            else if (ddsTM.finalScore.FinalScore == 4 ) 
                message = 'This deal scores 4, which is an above average score. Take another look at the deal characteristics to determine if it’s possible to achieve a score of 5!';
            
            else if (ddsTM.finalScore.FinalScore == 5 ) 
                message = 'Congratulations! This deal ranks amongst the top in its peer group.';
          }

        return message;   
    }
    
    public static string getCutoffs(DDSToolMain ddsTM) {
        string cutoff='<table><b>';
        //for loop for the map..
        if ( ddsTM.finalScore.finalCutoffsMap.get('Quote Discount Adjusted') != null ) {
            for(string key : ddsTM.finalScore.finalCutoffsMap.get('Quote Discount Adjusted').keySet()){
                cutoff+= '<tr style="height:10px;"><td style="width:40px;"><b>' + key + '</b></td><td style="width:20px;"><b>:</b></td><td><b>' +  ddsTM.finalScore.finalCutoffsMap.get('Quote Discount Adjusted').get(key).setscale(4)*100 + '%</b></td></tr>';                
            }
        }
        cutoff+='</b></table>';
        return cutoff;
    }
    
    public static QuoteDDSWrapper calculateDealScore(BigMachines__Quote__c objQuote){
        
    	DDSToolMain dds = DDSToolMain.getDDSToolMain(objQuote.Id,Integer.valueOf(2));
        QuoteDDSWrapper objWrapper = new QuoteDDSWrapper();
        objWrapper.objQuote = objQuote;
        if(dds != null && dds.finalScore == null ) {         
        	objWrapper.strMessage = DDSToolInterface.GetMessage(dds);
        }
        if(dds != null && dds.finalScore != null) {
            DealScoreHistory__c DDSHistory = new  DealScoreHistory__c();
            DDSHistory.Log__c = dds.Log;            
            DDSHistory.Quote__c =  objQuote.Id;
            objWrapper.strMessage = DDSToolInterface.GetMessage(dds);
            objWrapper.strCutoffs = DDSToolInterface.getCutoffs(dds);

            if ( dds.finalScore.MegaDeal == null && dds.finalScore.FinalScore != null && dds.finalScore.Score != null ) {
                objQuote.Compensation_Multiplier__c = getDDSCompensation(objQuote,Integer.valueOf(dds.finalScore.FinalScore),'PureEngage');
                objQuote.Deal_Score__c = Integer.valueOf(dds.finalScore.FinalScore);
                objQuote.Score__c = Integer.valueOf(dds.finalScore.Score);
            }
            else {
                objQuote.Compensation_Multiplier__c = objQuote.Deal_Score__c = objQuote.Score__c = null;
            }

            DDSHistory.DealScore__c = objQuote.Deal_Score__c;
            insert  DDSHistory;                  
        }  
    	return objWrapper;   
    }
    
    public static Decimal getDDSCompensation(BigMachines__Quote__c quote,Integer finalScore,String OfferingType){
    	If(finalScore == null || OfferingType == null )
        	return null;          
   	  	string compMultiplier;
        string search_Variable_Name = 'Grade ' + finalScore;
        System.debug('+++++search_Variable_Name'+ search_Variable_Name);
     	Decimal compAmount;
        ///Get Constants  
        for ( DDS_Tool_Constants__c cnst : DDSToolSelector.getConstants(OfferingType) ) {
     		If(cnst.Variable_Name__c == search_Variable_Name )
            compMultiplier = cnst.Variable_Value__c;
    	}
        System.debug('+++++compMultiplier'+ compMultiplier); 
        if(compMultiplier == null)
              return null;
        return Decimal.valueOf(compMultiplier);  
	}
    
    public class QuoteDDSWrapper {
        public BigMachines__Quote__c objQuote {get; set;}
        public String strMessage {get; set;}
        public String strCutoffs {get; set;}
    }
    
}