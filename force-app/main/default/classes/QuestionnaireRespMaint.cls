public class QuestionnaireRespMaint {

    public static void formatDT2ID() {
        
        List<Evaluation_Responses__c> eresps = [select id, Evaluee_Id__r.Name, questionnaire_datetime__c, questionnaire_id__c from Evaluation_Responses__c];
        
        string questionnaire_id = '';
        string last_questionnaire_id = '';
        for (Evaluation_Responses__c er : eresps) {
            questionnaire_id = er.Questionnaire_DateTime__c.formatGMT('yyyymmddhhmmss');
            string evaluee = er.Evaluee_Id__r.Name;
            string n = evaluee.substring(0,1) + evaluee.substringafterlast(' ').substring(0,1);
            
            if(string.isEmpty(er.questionnaire_id__c))
            	er.questionnaire_id__c = n + '_' + questionnaire_id;
            questionnaire_id = er.questionnaire_id__c;
			
            update er;
            
            if(questionnaire_id == last_questionnaire_id) 
            { 
                continue; 
            } else {
                last_questionnaire_id = questionnaire_id;
                System.debug(er.Evaluee_Id__r.name + ' - ' + er.questionnaire_id__c);
                
            }
        }
        
    }
    
    public static void TestEvaluationQuestionsController() {
        
        EvaluationQuestionsController eqc = new EvaluationQuestionsController();
        
        List<Evaluation_Responses__c> qr = [select questionnaire_datetime__c, evaluee_id__c from Evaluation_Responses__c where Evaluator_User_Id__c =  '0056A000002Hx5HQAS' and evaluee_id__c = '0036A00000peZLyQAM' and questionnaire_id__c =	'AL_20203816043837' ];
        System.debug('qDT = ' + qr[0].Questionnaire_DateTime__c.formatGMT('yyyymmddhhmmss'));
        System.debug('eeID = ' + qr[0].Evaluee_Id__c);
        string resp = EvaluationQuestionsController.genQuestionnaireID(qr[0].Questionnaire_DateTime__c, qr[0].Evaluee_Id__c);
        System.debug('resp ' + resp);
    }
    
    public static void LoadEvaluation_RootResponse() {
        
        //group by Questionnaire_Id__c, Evaluee_Id__c, Evaluation_Date__c, Evaluation_Location__c, Evaluator_User_Id__c, Evaluation_Type__c order
        List<Evaluation_Responses__c> er = [SELECT Questionnaire_DateTime__c, Questionnaire_Id__c, Evaluee_Id__c, 
                                            Evaluation_Date__c, Evaluation_Location__c, Evaluator_User_Id__c, Evaluation_Type__c 
                                            FROM Evaluation_Responses__c order by questionnaire_id__c];
        
        String lastQuestionnaire_Id = ''; 
        for(Evaluation_Responses__c r : er) {
            
            Evaluation_RootResponse__c rr = new Evaluation_RootResponse__c();
            rr.Questionnaire_DateTime__c = r.Questionnaire_DateTime__c;
            rr.Questionnaire_Id__c = r.Questionnaire_Id__c;  
            rr.Evaluee_Id__c = r.Evaluee_Id__c;  
            rr.Evaluation_Date__c = r.Evaluation_Date__c; 
            rr.Evaluation_Location__c = r.Evaluation_Location__c; 
            rr.Evaluator_User_Id__c = r.Evaluator_User_Id__c; 
            rr.Evaluation_Type__c = r.Evaluation_Type__c;
            
            if(lastQuestionnaire_Id == rr.Questionnaire_Id__c) {
                continue;
            } else {
                lastQuestionnaire_Id = rr.Questionnaire_Id__c;
                try{
                    insert rr;
                    System.debug('Inserted ' + rr.Questionnaire_Id__c);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
            
            
        } 
        
        
    }
    
    public static void UpdateEvaluationQuesions() {
        
        List<Evaluation_Questions__c> eq = [Select id, question_type__c from evaluation_questions__c where questiontype__c = null];
        
        String Overall = 'a14e0000002Sk91AAC';
        String Task = 'a14e0000002Sk8wAAC';
        
        Evaluation_Questions__c updteq = new Evaluation_Questions__c();
        for(Evaluation_Questions__c q : eq) {
            updteq = q;
            if(q.question_type__c.contains('Overall')) {
            	//System.debug('type=' + q.question_type__c);
                updteq.QuestionType__c = Overall;
            }
            else {
                updteq.QuestionType__c = Task;
            }
            update updteq; 
        }
        
    }
    
}