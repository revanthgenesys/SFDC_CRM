/*
	Naresh Kumar	07/02/2013
*/
global with sharing class RecalculateWorkloadSchedular implements Schedulable{
	global void execute(SchedulableContext SC){
		String query = 'SELECT id FROM User WHERE ID NOT IN ('+ Label.Skip_WorkLoad_Calculation_For_Users +')';
        RecalcWorkloadScoresBatch b = new RecalcWorkloadScoresBatch(query);
        Database.executeBatch(b,1);
	}
}