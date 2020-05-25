public class mmEvaluationQuestions {

    public string EvaluationTypeIn {get; set;}
    
    public string EvaluationIn {get; set;}
    
    public string SelectedEvaluationType {get; set;}
    
    public string EvaluatorId {get; set;}
    public string EvaluatorName {get; set;}

    public static List<Evaluation_Questions__c> questions {get; set;}

    public void getQuestions() {
        
        if(String.isEmpty(EvaluationTypeIn))
        {
            EvaluationTypeIn = 'Referee';
        }
        
        string Name; 
        string Evaluation_Type;
        string Question_Number; 
        string Question_Text; 
        string Question_Active; 
        string Question_Type;
        
        List<Evaluation_Questions__c> selectedquestions = new List<Evaluation_Questions__c>();
        List<Evaluation_Questions__c> editedquestions = new List<Evaluation_Questions__c>();
		selectedquestions = [select Name, Evaluation_Type__c, Question_Number__c, Question_Text__c, 
                                           Question_Active__c, Question_Type__c from Evaluation_Questions__c
											where Evaluation_Type__c =: EvaluationTypeIn and Question_Active__c = true
											order by question_number__c];	       
        for (Evaluation_Questions__c q : selectedquestions ) {
            //
            if(!q.Question_Number__c.contains('_0')) {
                q.Question_Type__c = '';
            } 

           	editedquestions.add(q);
        }
        mmEvaluationQuestions.questions = editedquestions;
         
    }
 
    public void getEvaluatorFromUser() {
        
        //username = UserInfo.getName();
        string UserId = UserInfo.getUserId();
        List<User> evaluator = [select name, contactid from user where id =: UserId ];
		EvaluatorId = evaluator[0].contactid;
        EvaluatorName = evaluator[0].name;
        
    }
    
    
    
}