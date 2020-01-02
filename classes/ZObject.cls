/*
 * Class to assist with the Zuora zObject and testing code that uses it. 
 * Code should not directly use Zuora zObject, instead instantiate an instince of this class for each Zuora object.
 * For test classes, mock up the data by directly instantiating this class.
 */
public class ZObject {
    public String Id {get;set;}
    public String Name {get;set;}
    public String Status {get;set;}
    public Integer Version {get;set;}
    public DateTime TermStartDate {get;set;}
    public String Type {get;set;}
    
    public ZObject(String id, String name, String status, Integer version, DateTime termStartDate, String type)
    {
        this.Id = id;
        this.Name = name;
        this.Status = status;
        this.Version = version;
        this.TermStartDate = termStartDate;
        this.Type = type;
    }
    
    public static List<ZObject> getZObjects(List<Zuora.zObject> zuoraObjects)
    {
        List<ZObject> zObjects = new List<ZObject>();
        
        for (Zuora.zObject zObject : zuoraObjects)
        {
			zObjects.add(new ZObject(
                (String)zObject.getValue('Id'),
            	(String)zObject.getValue('Name'),
            	(String)zObject.getValue('Status'),
            	(Integer)zObject.getValue('Version'),
            	(DateTime)zObject.getValue('TermStartDate'),
            	(String)zObject.getValue('Type')));          
        }
        
        return zObjects;
    }
}