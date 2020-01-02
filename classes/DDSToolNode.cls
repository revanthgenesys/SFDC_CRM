/* Mariya Steason - Aug 2018
   Purpose: DDSToolNode is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public virtual class DDSToolNode {

	private DDSToolMain ddsTM;
	private DDSToolQuoteData QuoteData;
	private DDSToolInterCalc InterCalc;	 
	private Map<String, Decimal> nodeCutoffs;
	private String treeType;
	
	public Integer Node;
	public Map<String, DDSToolNodeTreeVar> mapNodeTreeVars;
		
    public static DDSToolNode getDDSNodeTree(DDSToolMain ddsTM) {
		DDSToolNode ddsTlNode;
		
		DDSToolQuoteData qd = ddsTM.quoteData;
		if (qd.offering == 'PureEngage') {			
   		    ddsTlNode = new DDSToolNodePureEngage();
       	} 
       	else if (qd.offering == 'PureConnect' && qd.DirectSales) {       
   		    ddsTlNode = new DDSToolNodePureCnctDirect();
       	}
       	else if (qd.offering == 'PureConnect' && !qd.DirectSales) {
   		    ddsTlNode = new DDSToolNodePureCnctIndirect();
       	}
  
		ddsTlNode.ddsTM = ddsTM;
		ddsTlNode.QuoteData = ddsTM.quoteData;
		ddsTlNode.InterCalc = ddsTM.interCalc;

		ddsTlNode.mapNodeTreeVars = new Map<String, DDSToolNodeTreeVar>();
        ddsTlNode.populateNodes();
        
		return ddsTlNode;
	}
	
    public virtual void populateNodes() {}
    
     ///PureEngage subclass - PureEngage specific variables
    public class DDSToolNodePureEngage extends DDSToolNode {
    	public DDSToolNodePureEngage() {
    		treeType = 'PureEngage';
    	}     
        public override void populateNodes() {       	
        	addToMap('Sold_To_Country__Sub_Sub_Region', 'String', InterCalc.getSold_To_Country_Sub_Sub_Region());
			addToMap('Self_Service_5Percent_2019', 'Integer', InterCalc.getSelf_Service_5Percent_2019());
			addToMap('Account_Name__Vertical_Fixed', 'String', InterCalc.getAccount_Name_Vertical_Fixed());
			addToMap('Sold_To_Country', 'String', InterCalc.getSold_To_Country());
			addToMap('Number_Product_Category_Over5percent_2019', 'Integer', InterCalc.getNumber_Product_Category_Over5percent_2019());
			addToMap('Sold_To_Country__Region', 'String', InterCalc.getSold_To_Country_Region());
			addToMap('Dominant_Unit_of_Measure_50Pct', 'String', InterCalc.getDominant_Unit_of_Measure_50Pct());
			addToMap('Type', 'String', InterCalc.getType());
			addToMap('Customer_age', 'Integer', InterCalc.getCustomer_age());			
			addToMap('Inbound_5Percent_2019', 'Integer', InterCalc.getInbound_5Percent_2019());
			addToMap('LastYear_NetRevenue', 'Decimal', InterCalc.getLastYear_NetRevenue());
			addToMap('LastSixMonths_NetRevenue', 'Decimal', InterCalc.getLastSixMonths_NetRevenue());
			addToMap('Number_of_Lost', 'Integer', InterCalc.getNumber_of_Lost());
			addToMap('WEM_5Percent_2019', 'Integer', InterCalc.getWEM_5Percent_2019());
			addToMap('Open_Platform_5Percent_2019', 'Integer', InterCalc.getOpen_Platform_5Percent_2019());
        } 
    }
    
    //PureConnect subclass - PureConnect specific variables 
    public virtual class DDSToolNodePureConnect extends DDSToolNode {
        public virtual override void populateNodes() {
        	        	
        	addToMap('Sold_To_Country__Sub_Sub_Region', 'String', InterCalc.getSold_To_Country_Sub_Sub_Region());
			addToMap('Account_Name__Vertical_Fixed', 'String', InterCalc.getAccount_Name_Vertical_Fixed());
			addToMap('DDS_List_Price__USD_', 'Decimal', InterCalc.getDDS_List_Price_USD());
			addToMap('Last2Years_NetRevenue', 'Decimal', InterCalc.getLast2Years_NetRevenue());
			addToMap('Number_of_Lost', 'Integer', InterCalc.getNumber_of_Lost());
			addToMap('Public_sector_vs_enterprise_customer', 'String', InterCalc.getPublic_sector_vs_enterprise_customer());
			addToMap('WEM_5Percent_2019', 'Integer', InterCalc.getWEM_5Percent_2019());
    	}
    }
    //PureConnect Direct subclass - PureConnect Direct specific variables  
    public class DDSToolNodePureCnctDirect extends DDSToolNodePureConnect {
    	public DDSToolNodePureCnctDirect() {
    		treeType = 'PureConnect Direct';
    	}    	
        public override void populateNodes() {        	
            super.populateNodes();  
            
            addToMap('LastYear_NumberOfDeals', 'Integer', InterCalc.getLastYear_NumberOfDeals());
			addToMap('Number_of_products_in_deal_5pc', 'Integer', InterCalc.getNumber_of_products_in_deal_5pc()); 
    	}
    } 
    //PureConnect Indirect subclass - PureConnect Indirect specific variables  
    public class DDSToolNodePureCnctIndirect extends DDSToolNodePureConnect {
    	public DDSToolNodePureCnctIndirect() {
    		treeType = 'PureConnect Indirect';
    	}
        public override void populateNodes() {
            super.populateNodes();
            addToMap('Customer_age', 'Integer', InterCalc.getCustomer_age());
			addToMap('Digital_5Percent_2019', 'Integer', InterCalc.getDigital_5Percent_2019());
			addToMap('Dominant_Product_Category_50PCT_2019_', 'String', InterCalc.getDominant_Product_Category_50PCT_2019());
			addToMap('LastYear_NetRevenue', 'Decimal', InterCalc.getLastYear_NetRevenue());
			addToMap('number_of_products_5pc', 'String', InterCalc.getNumber_of_products_5pc());
			addToMap('Number_Product_Category_Over5percent_2019', 'Integer', InterCalc.getNumber_Product_Category_Over5percent_2019());
			addToMap('Open_Platform_5Percent_2019', 'Integer', InterCalc.getOpen_Platform_5Percent_2019());
			addToMap('Sold_To_Country', 'String', InterCalc.getSold_To_Country());
			addToMap('Sold_To_Country__Region', 'String', InterCalc.getSold_To_Country_Region());
    	}
    } 
    
    // Core methods for getting, setting and traversing the node map
	private void addToMap(String vrName, String dtType, Object vrValue) {
		DDSToolNodeTreeVar ndVar = getNewNodeTreeVar(vrName, dtType, vrValue);
		if (ndVar != null) 
			mapNodeTreeVars.put(vrName, ndVar);
	}

	private DDSToolNodeTreeVar getNewNodeTreeVar(String vrName, String dtType, Object vrValue) {
		DDSToolNodeTreeVar newNode = new DDSToolNodeTreeVar();

		newNode.VarName = vrName;
		newNode.DataType = dtType;		
		newNode.setValue(vrValue);

      	return newNode;
	}
	
   private void getNode() {
	 if ( Node == null ) {
		Integer VERSION = 1;

		if ( mapNodeTreeVars == null || mapNodeTreeVars.isEmpty() ) 
			return;
		
		List<DDS_Tool_Tree_Logic__c> logictree = [SELECT Node__c, Execution_Order__c, Level__c, Variable_Name__c, Operator__c, 
		                                                 Criteria_Value__c, isEndNode__c
		                                          FROM DDS_Tool_Tree_Logic__c WHERE Offering__c = :treeType AND Version__c =:VERSION
		                                          Order By Execution_Order__c, Level__c];
		 
	   Map<Integer, DDS_Tool_Tree_Logic__c> logicmap = new Map<Integer, DDS_Tool_Tree_Logic__c>(); 
	   for (DDS_Tool_Tree_Logic__c testline : logictree )
	      logicmap.put((Integer)testline.Execution_Order__c, testline);
		
	   String truthlist='';
	   for (Integer execorder=1; execorder <= logicmap.size(); execorder++) {			
			DDS_Tool_Tree_Logic__c testline = logicmap.get(execorder);
						
			String testvarname = testline.Variable_Name__c;
			DDSToolNodeTreeVar testvar = mapNodeTreeVars.get(testvarname);
			
			if ( testline.Level__c <= truthlist.length() )
			   truthlist = truthlist.substring(0, (Integer)testline.Level__c-1);
			
			truthlist += evaluateCondition(testline, testvar) ? 'T' :'F';
             
			if ( testline.isEndNode__c && !truthlist.contains('F') ) {
					Node = (Integer)testline.Node__c;
					break; 
			}

		} /// end of logic loop; by this point should have node found
		
		///If not found, assign Node 0
		if ( Node == null )
		    Node = 0;		
	  }	  
	  return;
   }
	
	private Boolean evaluateCondition(DDS_Tool_Tree_Logic__c testline, DDSToolNodeTreeVar nodeVar) {		
		Boolean res = false;

		/// test on IN operator
		if ( testline.Operator__c.equalsIgnoreCase('In') ) {
			List<String> strtvals = new List<String>( testline.Criteria_Value__c.split('\\|') );
			
			for (String str : strtvals)  {
				if ( (nodeVar.DataType == 'String' && nodeVar.StringVal != null && nodeVar.StringVal.trim().equalsIgnoreCase(str.trim())) ||
				     (nodeVar.DataType == 'Integer' && nodeVar.IntVal != null && nodeVar.IntVal == Integer.valueOf(str))    ||
				     (nodeVar.DataType == 'Decimal' && nodeVar.DecimalVal != null && nodeVar.DecimalVal == Decimal.valueOf(str)) ) {
					   res = true;
					   break;
				}  				
			}			
		} 
		/// test on = operator including <=, >= for numbers, but just test for =
		if ( testline.Operator__c.equals('=') || testline.Operator__c.equals('<=') || testline.Operator__c.equals('>=') ) {
			if ( (nodeVar.DataType == 'String' && nodeVar.StringVal != null && nodeVar.StringVal.trim().equalsIgnoreCase(testline.Criteria_Value__c.trim())) ||
			     (nodeVar.DataType == 'Integer' && nodeVar.IntVal != null && nodeVar.IntVal == Integer.valueOf(testline.Criteria_Value__c))    ||
				 (nodeVar.DataType == 'Decimal' && nodeVar.DecimalVal != null && nodeVar.DecimalVal == Decimal.valueOf(testline.Criteria_Value__c)) ) {
					   res = true;			
				 }
		}
		/// < operator, numbers only, but just test for <
		if ( testline.Operator__c.equals('<') || testline.Operator__c.equals('<=') ) {
			if ( (nodeVar.DataType == 'Integer' && nodeVar.IntVal != null && nodeVar.IntVal < Integer.valueOf(testline.Criteria_Value__c))    ||
				 (nodeVar.DataType == 'Decimal' && nodeVar.DecimalVal != null && nodeVar.DecimalVal < Decimal.valueOf(testline.Criteria_Value__c)) ) {
					   res = true;			
				 }
		}
		/// > operator, numbers only, but just test for >
		if ( testline.Operator__c.equals('>') || testline.Operator__c.equals('>=') ) {
			if ( (nodeVar.DataType == 'Integer' && nodeVar.IntVal != null && nodeVar.IntVal > Integer.valueOf(testline.Criteria_Value__c))    ||
				 (nodeVar.DataType == 'Decimal' && nodeVar.DecimalVal != null && nodeVar.DecimalVal > Decimal.valueOf(testline.Criteria_Value__c)) ) 
					   res = true;			
		}
	
		return res;		
	}
	
	public Map<String, Decimal> getNodeCutoffs() {
		if ( nodeCutoffs == null ) {  
		    getNode();
			
			nodeCutoffs = new Map<String, Decimal>();
			if ( Node != null ) {
				
				List<DDS_Tool_Cutoffs__c> cutoffs = [SELECT Cutoff_A__c, Cutoff_B__c, Cutoff_C__c, Cutoff_D__c 
				                                      FROM DDS_Tool_Cutoffs__c
				                                      WHERE Node__c =:Node AND Offering__c = :treeType];
				if ( !cutoffs.isEmpty() )  {				
					nodeCutoffs.put('5', cutoffs[0].Cutoff_A__c);
					nodeCutoffs.put('4', cutoffs[0].Cutoff_B__c);
					nodeCutoffs.put('3', cutoffs[0].Cutoff_C__c);
					nodeCutoffs.put('2', cutoffs[0].Cutoff_D__c);
				}			
			} 
		}
		return nodeCutoffs;
	}

}