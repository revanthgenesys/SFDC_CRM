public  class JSONToApex {
	public List<Entries> Entries;

    public class Entries {
        public String fieldName;
        public String fieldValue;
    }
    
    public static JSONToApex parse(String json) {
        return (JSONToApex) System.JSON.deserialize(json, JSONToApex.class);
    }
    
}