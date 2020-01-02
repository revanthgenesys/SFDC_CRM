public class DependentPartsMappingProvider {
    
    public Map<String, List<String>> GetMap()
    {
        //System.debug(LoggingLevel.ERROR, 'DependentPartsMappingProvider.GetMap');
        
        Map<String, List<String>> result = new Map<String, List<String>>();
        
        for (DependentPartRelationship__c relationship : [SELECT Id, Name, Dependent_Parts__c, Independent_Part__c FROM DependentPartRelationship__c])
        {
            String independentPart = relationship.Independent_Part__c;
            List<String> dependentParts = GetPartsList(relationship.Dependent_Parts__c);
            
            if (dependentParts.size() == 0)
            {
                //System.debug('No Dependent Parts found for Independent with Part No: ' + independentPart);
            }
            
            
            result.put(independentPart, dependentParts);
        }
        
        if (result.size() == 0)
        {
            //System.debug('No DependentPartRelationship__c records found for the Map');
        }
        
        return result;
    }
    
    
    private List<String> GetPartsList(string commaConcatenatedString)
    {
        //System.debug(LoggingLevel.ERROR, 'DependentPartsMappingProvider.GetPartsList');
        
        List<Id> result = new List<String>();
        for (String partNo : commaConcatenatedString.split(','))
        {
            result.add(partNo.trim());
        }
        
        
        return result;
    }
}