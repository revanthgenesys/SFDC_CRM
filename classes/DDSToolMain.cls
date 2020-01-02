/* Mariya Steason - Aug 2018
   Purpose: DDSToolMain is the main class of the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public class DDSToolMain {

	public String quoteId;	
	public DDSToolQuoteData quoteData;
	public DDSToolAdjuster adjust;
	public DDSToolInterCalc interCalc;
	public DDSToolNode nodeTree;
	public Map<String, DDSToolNodeTreeVar> nvMap;
	public DDSToolPostCalc postCalc;
	public DDSToolFinalScore finalScore;
	public String displayScoreVal;
	public String Log = '';
	public Integer LogLevel;
	public Boolean thirdPrtyOnly;
    public String errorMessage;
	private final Integer DEFAULT_LOG_LEVEL = 0; /// 0 = Info, 1 = Detail, 2 = Fine
	
	public enum AmendScoring { PREVIOUS_SCORE, RESCORE, HW3PARTY_ONLY, WILL_NOT_SCORE }
	
	public static DDSToolMain getDDSToolMain(String quoteId, Integer logLvl) {
		
		DDSToolMain ddsTM = new DDSToolMain();		
		ddsTM.LogLevel = loglvl == 1 || loglvl == 2 ? loglvl : ddsTM.DEFAULT_LOG_LEVEL;
		
		//Process quote input and calculate Node variables
		ddsTM.quoteData = DDSToolQuoteData.getQuoteDataFromQuote(ddsTM, quoteId);
        ddsTM.errorMessage = '';
		if (ddsTM.quoteData == null) {
			ddsTM.displayScoreVal = 'Error';
			ddsTM.Log += 'Data validation error. ';
            ddsTM.errorMessage = System.Label.DDS_Error_Data_Validation;
			return ddsTM;
		} 

		ddsTM.adjust = DDSToolAdjuster.getDDSToolAdjuster(ddsTM);
		if ( ddsTM.quoteData.Amendment && ddsTM.adjust.scoringScenario == AmendScoring.WILL_NOT_SCORE ) {			
			ddsTM.displayScoreVal = 'Error';
			ddsTM.Log += 'Amendment Quantity reduction. No score will be provided.';
	        ddsTM.errorMessage = System.Label.DDS_Amendment_Redaction_Msg;
			return ddsTM;
		}			
		if (!ddsTM.quoteData.isThirdPrtHWonly && (ddsTM.adjust.getTotalProdListPrice() == 0 )) {
			ddsTM.displayScoreVal = 'Error';
			ddsTM.Log += 'List Price error. ';
            ddsTM.errorMessage = System.Label.DDS_Error_Pricing;
			return ddsTM;
		} 

		ddsTM.thirdPrtyOnly = ddsTM.quoteData.isThirdPrtHWonly;
        ddsTM.interCalc = DDSToolInterCalc.getDDSToolInterCalc(ddsTM);		
                
		if ( !ddsTM.thirdPrtyOnly && ddsTM.adjust.scoringScenario != AmendScoring.HW3PARTY_ONLY ) {
		    /// Determine Tree Node						
			ddsTM.nodeTree = DDSToolNode.getDDSNodeTree(ddsTM);				
		    Map<String, Decimal> nodeCutOffs = ddsTM.nodeTree.getNodeCutOffs();	
  
			if ( ddsTM.nodeTree.Node == 0 ) {
				ddsTM.errorMessage = System.Label.DDS_Node_0_Assignment;
			}									    
	    }
        
	    ///Post prcessing
		ddsTM.postCalc = DDSToolPostCalc.getDDSToolPostCalc(ddsTM);
		ddsTM.finalScore = DDSToolFinalScore.getDDSToolFinalScore(ddsTM);
		
		///Display
		if ( ddsTM.finalScore.FinalScore == null && ddsTM.finalScore.MegaDeal == null ) {          
			ddsTM.displayScoreVal = 'Error';
			ddsTM.Log += 'Score assignment error.';  
            ddsTM.errorMessage = System.Label.DDS_Error_Score_Assignment;
		}
		else {       
            ddsTM.displayScoreVal = ddsTM.finalScore.MegaDeal != null ? 'Mega Deal - will Not Score' : String.valueOf(ddsTM.finalScore.FinalScore);
        }
		return ddsTM;
	}

}