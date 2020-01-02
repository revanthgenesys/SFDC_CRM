/* Mariya Steason - Aug 2018
   Purpose: DDSToolNodeTreeVar is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public class DDSToolNodeTreeVar {
	
	 public String VarName;
	 public String DataType;

	 public String  StringVal;
	 public Integer IntVal;
	 public Decimal DecimalVal;
    
   	public void setValue(Object obj) {
		if (obj instanceof String && DataType.equals('String')) {
			StringVal = (String) obj;
		} else if (obj instanceof Integer && DataType.equalsIgnoreCase('Integer')) {
			IntVal = (Integer) obj;
		} else if (obj instanceof Decimal && DataType.equalsIgnoreCase('Decimal')) {
			DecimalVal = (Decimal) obj;
		}
	}
    
}