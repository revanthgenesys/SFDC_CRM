@IsTest
private with sharing class QuestionFillDataCategoriesTest{

    @isTest
    static void testCreateQuestion()
    {
        Community[] c = [SELECT Id from Community];
        // We cannot create a question without a community 
        if (c.size() == 0) { return; }
        String communityId = c[0].Id; 
        
        Question q = new Question();
        q.Body = 'body';
        q.Title = 'title';
        q.CommunityId = communityId; 
        insert q;
        
        QuestionDataCategorySelection qdcs = new QuestionDataCategorySelection();
        qdcs.ParentId = q.Id;
        qdcs.DataCategoryGroupName = 'Product';
        qdcs.DataCategoryName = 'SG_COMPOSER_1_2';
        insert qdcs;
        
        q.Title = 'title2';
        update q;
        
    }
}