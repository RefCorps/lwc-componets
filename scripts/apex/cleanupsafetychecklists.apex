
/*
    THE FOLLOWING ANONYMOUS APEX SCRIPT CAN BE USED TO REMOVE ROWS FROM EVLAUTION_RESPONSES__C
    TO RUN THIS IN UAT - OPEN DEVELOPER CONSOLE
    SELECT 'Debug' FROM THE MENU AND 'Open Execute Anonymous Window'
    PASTE SCRIPT IN WINDOW AND PRESS 'Execute'

    OUTPUT WILL APPEAR UNDER THE LOGS TAB

    CHANGE THE FOLLOWING TO MATCH YOUR TEST DATA
    and Evaluation_Location__c = 'Safety Checklist test 2022' 
    and Evaluee_Id__c = '0036A00000baN6HQAU' 

*/

Evaluation_Responses__c[] rows = [
    Select Evaluation_Date__c, Evaluation_Location__c, Evaluator_Id__c, Evaluation_Type__c, Evaluee_Id__c, 
    Questionnaire_Id__c, RegattaId__c, Evaluator_Comment__c 
    FROM Evaluation_Responses__c 
    where EVALUATION_TYPE__C = 'SAFETY CHECKLIST' 
    and Evaluation_Location__c = 'Safety Checklist test 2022' 
    and Evaluee_Id__c = '0036A00000baN6HQAU' 
    ];

System.debug( ' >>> rows fetched size = ' + rows.size());

if(rows.size() > 0) {

    string  QUESTIONNAIRE_ID = rows[0].Questionnaire_Id__c;

    Evaluation_Responses__c[] responses = [select id from Evaluation_Responses__c where QUESTIONNAIRE_ID__C =: QUESTIONNAIRE_ID ];
    System.debug( ' >>> response size = ' + responses.size());
    for(Evaluation_Responses__c resp : responses) {
        System.debug(' >>> resp id = ' + resp.Id);
    }
    if(responses.size() > 0)
    {   delete responses;   }


    Evaluation_ResponsesAbstract__c[] respabstract = [ select id FROM Evaluation_ResponsesAbstract__c where Questionnaire_Id__c  =: QUESTIONNAIRE_ID ];
    System.debug( ' >>> abstract size = ' + respabstract.size());
    for(Evaluation_ResponsesAbstract__c abs : respabstract) {
        System.debug(' >>> abstract id = ' + abs.Id);
    }
    if(respabstract.size() > 0)
    {   delete respabstract;    }

    System.debug(' >>> DONE DONE DONE ');

}