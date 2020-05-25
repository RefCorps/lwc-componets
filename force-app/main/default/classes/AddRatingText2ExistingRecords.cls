public class AddRatingText2ExistingRecords {

    public static void UpdateRecords() {
        
        List<Evaluation_Responses__c> records = [SELECT id, Evaluation_Rating__c, Question_Type__c, Evaluation_Rating_Text__c 
                                                 From Evaluation_Responses__c ];
		
        System.debug('Record count = ' + records.size());
        
        for(Evaluation_Responses__c rec : records) {
 
            if(rec.Evaluation_Rating__c == '1') {
                    if(rec.Question_Type__c.contains('Overall'))
                        rec.Evaluation_Rating_Text__c  = 'Fully Competent';
                    else
                        rec.Evaluation_Rating_Text__c  = 'Meets Standard';
                }
                if(rec.Evaluation_Rating__c == '2') {
                    if(rec.Question_Type__c.contains('Overall'))
                        rec.Evaluation_Rating_Text__c  = 'Needs Work';
                    else
                        rec.Evaluation_Rating_Text__c  = 'Competent';
                }
                
                if(rec.Evaluation_Rating__c == '3') {
                    if(rec.Question_Type__c.contains('Overall'))
                        rec.Evaluation_Rating_Text__c  = 'Not Observed';
                    else
                        rec.Evaluation_Rating_Text__c  = 'Requires Training';
                }
            
            System.debug('Setting task to ' + rec.Evaluation_Rating_Text__c);
            try {
            	update rec;
            } catch (Exception e) {
                e.getMessage();
            }
        }
        
        System.debug('DONE');
    }
    
}