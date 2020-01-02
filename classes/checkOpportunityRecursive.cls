// Check for Opportunity Trigger recursion
// NikM: April 2019

public class checkOpportunityRecursive{

    private static boolean runBeforeInsert = true;
    private static boolean runBeforeUpdate = true;
    
    public static boolean runBeforeInsertOnce()
    {
        if(runBeforeInsert)
        {
            runBeforeInsert = false;
            return true;
        }
        else
        {
            return runBeforeInsert;
        }
    }

    public static boolean runBeforeUpdateOnce()
    {
        if(runBeforeUpdate)
        {
            runBeforeUpdate = false;
            return true;
        }
        else
        {
            return runBeforeUpdate;
        }
    }

}