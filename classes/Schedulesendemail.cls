//Ravi V - Sales Compliance -  10/16/2013
global class Schedulesendemail implements Schedulable
{
 global void execute(SchedulableContext SC)
  {
   ComplianexpireBatch ceb = new ComplianexpireBatch();
   Database.executeBatch(ceb);
  }
}