/*
 * Trigger: QuestionFillDataCategories
 * Purpose: copy DataCategory names into a Question custom field.
 * 			Need by Coveo indexing. 
 * 			Other scenario of using Formula field failed because Question/DataCategorySelections is a master-detail relation.
 */
trigger QuestionFillDataCategories on Question (before update) {
    List<Question> listQuestion = [SELECT Id, DataCategoryNames__c from Question];
    System.Debug(listQuestion.size());
    List<QuestionDataCategorySelection> listSelections = [SELECT ParentId, toLabel(DataCategoryName) from QuestionDataCategorySelection];
    System.Debug(listSelections.size());

    
    //loop through every Question in this trigger batch
    for(Question q: Trigger.new){
        System.Debug('new Question before update; question id= ' + q.Id);

		//find every datacategory for the question        
        List<String> names = new List<String>();
        for(QuestionDataCategorySelection qdcs: listSelections){
            if(qdcs.ParentId == q.Id){
                names.add(qdcs.DataCategoryName);
            }
        }

        //concatenate the names into a single,semicolon-separated string,and assign to custom field
        q.DataCategoryNames__c = String.join(names, ';');
    }
}