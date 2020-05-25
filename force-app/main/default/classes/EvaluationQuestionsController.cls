public with sharing class EvaluationQuestionsController {

    /*
     * EvaluationQuestionsController
     * This is an APEX controller created to support the Evaluation Questionnaire
     * NOTE:  @AuraEnabled allows the method to be accessed through a Lightning/Aura application
     * 
     */ 
    
    // GET THE LOGGED IN USER ID - THIS WILL BE THE EVALUATOR
    // NOTE THAT THE RETURN IS A LIST BUT IN REALITY THERE WILL BE ONE USER
    @AuraEnabled 
    public static List<User> fetchEvaluator(){
       string UserId = UserInfo.getUserId();
       List<User> evaluator = [select name, contactid from user where id =: UserId ];
       //System.debug(evaluator); 
       return evaluator;
    }

    // GET THE SERVER TIMESTAMP THAT WILL BE USED WITH ALL RESPONSES
    @AuraEnabled 
    public static DateTime getQuestionnaireTS() {
        DateTime dt = DateTime.now();
        //System.debug(dt);
        return dt;
    }

    @AuraEnabled 
    public static Evaluation_Properties__c[] getProps() {
        Evaluation_Properties__c[] props = [select Name, Value__c from Evaluation_Properties__c where isActive__c = true];
        return props;
    }
    
    public static String getProp(String prop) {
        String value = '';
        String searchquery = 'select Name, Value__c from Evaluation_Properties__c where isActive__c = true and name = \'' + prop + '\'';
        System.debug('getProp query: ' + searchquery);
        List<Evaluation_Properties__c> props = Database.query(searchquery);
        if(props.size() > 0) {
            value = (String) props[0].get('Value__c');
        }
        System.debug('getProp returning ' + value);
        return value;
    }
    
   @AuraEnabled
    public static String[] getEvaluationTypes() {
        List<Evaluation_Questions__c> selectedquestions = new List<Evaluation_Questions__c>();
        AggregateResult[] types = [select Evaluation_type__c from Evaluation_Questions__c where IsQuestionGroupHeader__c = false and QuestionType__r.Type_Response_Count__c > 0
            group by Evaluation_type__c order by Evaluation_type__c];
        String[] rts =  new List<String>();
        for (AggregateResult type : types)  {
            rts.add((String) type.get('Evaluation_type__c') );            
        }
        return rts;
    }
    
    // REFER TO REGATTA PICK LIST
    public static Set<String> getRegattaTypes() {
        Set<String> rts = new Set<String>();
        rts.add('Sprint');
        rts.add('Head');
        rts.add('Head - Sprint Combination');
        rts.add('Coastal');
        rts.add('Indoor');
        return rts;
    }
    
    // GET A LIST OF RECENT REGATTA    
    @AuraEnabled
    public static List<RecordsData> myRecentRegattas(String myId, Integer lastNDays) {
        
        List<RecordsData> myRegattasList = new List<RecordsData>();
        
        // AT THIS POINT IF THE USER DOES NOT HAVE ACCESS TO EVALUATION PROPERTIES 
        // THIS METHOD WILL IGNORE PROPS
        // TODO: FIX SECURITY
        String strLastNDays = EvaluationQuestionsController.getProp('LastNDays');
        if(!String.isEmpty(strLastNDays)) {
            //strLastNDays = strLastNDays.replaceAll('[^\\0123456789]','');
            System.debug('strLastNDays=' + strLastNDays.trim());
            integer n = integer.valueOf(strLastNDays);
            if(n > 0)
                lastNDays = n;
        }
        System.debug('lastNDays='+lastNDays);
        
        String regattatype = EvaluationQuestionsController.getProp('RegattaType');
        // REFEREE DOES NOT EXECUTE SELECT AGAINST EVALUATION PROPERTIES - NO ERRORS EITHER
        if (String.isEmpty(regattatype))
            return myRegattasList; // empty list
        
        String searchquery = 'SELECT Participation_Regatta__c, Participation_Regatta__r.name, Participation_Regatta__r.Start_Date__c, Participation_Regatta__r.End_Date__c ';
        searchquery = searchquery + 'FROM Regatta_Participation__c '; 
        searchquery = searchquery + 'WHERE Regatta_Participant_User__c = \'' + myId + '\' ';
        searchquery = searchquery + 'AND Participation_Regatta__r.Start_Date__c = LAST_N_DAYS:'+lastNDays+' '; 
        if(!String.isEmpty(regattatype)) {
            if(regattatype.contains('Head') && regattatype.contains('Sprint'))
                regattatype = 'Head - Sprint Combination';  // this should solve possible issues with this type
            Set<String> rts = getRegattaTypes();
            if(!regattatype.equals('All') && rts.contains(regattatype))
                searchquery = searchquery + 'and Participation_Regatta__r.Regatta_Type__c = \'' + regattatype+'\' ';
        }
        searchquery = searchquery + 'ORDER BY Participation_Regatta__r.Start_Date__c DESC';
        System.debug(searchquery);
        //
        List <sObject> regattalist = new List <sObject>();
        regattalist = Database.query(searchquery);
        integer sz = regattalist.size();
        System.debug('regattalist size = ' + sz);
        for(integer i = 0 ; i < sz; i++)
        {
            String dateFormatString = 'yyyy-MM-dd';
            String rname = (String) regattalist[i].getSObject('Participation_Regatta__r').get('name');
            String rdatetime = ((Datetime) regattalist[i].getSObject('Participation_Regatta__r').get('Start_Date__c')).format(dateFormatString);
            String renddatetime = ((Datetime) regattalist[i].getSObject('Participation_Regatta__r').get('End_Date__c')).format(dateFormatString);
            String rid = (String)(String) regattalist[i].get('Participation_Regatta__c');
            System.debug(rname + ' - ' + rdatetime + ' / ' + renddatetime + ', ' + rid);
            myRegattasList.add(new RecordsData(rname + ' - ' + rdatetime + ' / ' + renddatetime , rid));
        }
        return myRegattasList;
    }
    
    // GET A LIST OF REFEREE PARTICIPANT CONTACT IDS ASSOCIATED WITH A SPECIFIC REGATTA - EXCLUDE THE EVALUATOR
    // WE WILL STORE EVALUEE BY CONTACT ID 
    @AuraEnabled
    public static List<RecordsData> regattaContacts(String regattaId, String myId) {
         List<RecordsData> regattaParticipants = new List<RecordsData>();
        String searchquery = 'SELECT contactid FROM user WHERE id in ';
        searchquery = searchquery + '(SELECT Regatta_Participant_User__c FROM Regatta_Participation__c ';
        searchquery = searchquery + 'where Participation_Regatta__c = \'' + regattaId + '\' ';
        searchquery = searchquery + 'and Regatta_Participant_User__c != \'' + myId + '\') ';
        System.debug(searchquery);
        //
        List <String> contactIds = new List <String>();
        List<user> userlist = Database.query(searchquery);
        System.debug(userlist.size());
        for (User u : userlist) {
            contactIds.add(u.contactid);
        }
        List<contact> participants = [SELECT id, name, email, Referee_Rank__c FROM contact WHERE id in : contactIds ORDER BY Referee_Rank__c, name];
        integer sz = participants.size();
        for(integer i = 0; i < sz; i++) {
            String pname = ((String) participants[i].get('name'))  + ' - ' + ((String) participants[i].get('email'))  + ' - ' + ((String) participants[i].get('Referee_Rank__c'))  ;
            String pid = (String) participants[i].get('Id');
            System.debug(pname + ', ' + pid);
            regattaParticipants.add(new RecordsData(pname, pid));
        }
        return regattaParticipants;
    }
    
    // GET A LIST OF REFEREE PARTICIPANT USERS ASSOCIATED WITH A SPECIFIC REGATTA - EXCLUDE THE EVALUATOR
    // THIS IS FOR DISPLAY PURPOSES
    @AuraEnabled
    public static List<RecordsData> regattaParticipants(String regattaId, String myId) {
        List<RecordsData> regattaParticipants = new List<RecordsData>();
        String searchquery = 'SELECT Regatta_Participant_User__c, Regatta_Participant_User__r.name, Regatta_Participant_User__r.User_Referee_Rank__c ';
        searchquery = searchquery + 'FROM Regatta_Participation__c ';
        searchquery = searchquery + 'where Participation_Regatta__c = \'' + regattaId + '\' ';
        searchquery = searchquery + 'and Regatta_Participant_User__c != \'' + myId + '\' ';
        searchquery = searchquery + 'order by Regatta_Participant_User__r.User_Referee_Rank__c, Regatta_Participant_User__r.name';
        System.debug(searchquery);
        //
        List <sObject> plist = new List <sObject>();
        plist = Database.query(searchquery);
        integer sz = plist.size();
        for(integer i = 0; i < sz; i++) {
            String pname = ((String) plist[i].getSObject('Regatta_Participant_User__r').get('name')) + ' - ' + ((String) plist[i].getSObject('Regatta_Participant_User__r').get('User_Referee_Rank__c'))  ;
            String pid = (String) plist[i].get('Regatta_Participant_User__c');
            System.debug(pname + ', ' + pid);
            regattaParticipants.add(new RecordsData(pname, pid));
            
        }
        return regattaParticipants;
    }
   
    // SELECT QUESTIONS FROM Evaluation_Questions__c
    @AuraEnabled
    public static List<Evaluation_Questions__c> getQuestions(string EvaluationTypeIn) {
        
        List<Evaluation_Questions__c> selectedquestions = new List<Evaluation_Questions__c>();
        
        selectedquestions = [select Name, Id, Evaluation_Type__c, Question_Number__c, Question_Text__c, Question_Active__c, Question_Type__c,
                                    QuestionType__r.Name, QuestionType__r.Response_Text_1__c,  QuestionType__r.Response_Text_2__c,  QuestionType__r.Response_Text_3__c,
                                    QuestionType__r.Type_Response_Count__c, IsRequired__c, IsQuestionGroupHeader__c from Evaluation_Questions__c
                                    where Evaluation_Type__c =: EvaluationTypeIn and Question_Active__c = true
                                    order by question_number__c];          
        
        return selectedquestions;
    }


    
    
    
    // TWO VERSIONS OF fetchRecords WERE CREATED - THEY ARE OVERLOADED SO THERE'S NO CONFLICT 
    // THE SECOND VERSION IS CURRENTLY USED
    @AuraEnabled 
    public static List<Contact> fetchRecords(string name, string rank){
       List<List<SObject>> searchlist = [FIND :name IN NAME FIELDS RETURNING Contact(name, email, Referee_Rank__c, Region__c, id WHERE Referee_Rank__c =: rank)];
       List<Contact> evaluee = ((List<Contact>)searchList[0]);
       return evaluee;
    }
   
    // THIS IS THE OLD REFEREE LOOK UP - I LEFT IT IN THIS CLASS FOR REFERENCE PURPOSES
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        
        System.debug('in fetchRecords');
        try {
            
            List<RecordsData> recordsDataList = new List<RecordsData>();
            
            /*
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                query += ' WHERE '+filterField+
                        ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
            }
            */
            String searchquery = 'FIND \'' + searchString + '\' IN NAME FIELDS RETURNING Contact('+ filterField + ' WHERE Referee_Rank__c = \'Referee\' OR Referee_Rank__c = \'Assistant\' )';
            System.debug(searchquery);
            
            //For(SObject s : Database.query(query)) {
            List<List <sObject>> slist = search.query(searchquery);
            integer sz = slist.size();
            for(integer i = 0 ; i < sz; i++)
            {
                List<Contact> contact = ((List<Contact>)slist[i]);
                for(Contact c : contact) {
                System.debug(c);
                System.debug(c.name);
                    
                // Record data tests - RecordsData is an object defined at the end of this class                        
                // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );  
                // name, email, Referee_Rank__c, Region__c  
                 //recordsDataList.add( new RecordsData(c.email, c.id) );    
                 //recordsDataList.add( new RecordsData(c.Referee_Rank__c, c.id) );    
                 //recordsDataList.add( new RecordsData(c.Region__c, c.id) );
                 
                 // Records data label = c.name + ' ' + c.email + ' ' + c.Referee_Rank__c + ' ' + c.Region__c
                 // Records data value = c.id
                 recordsDataList.add( new RecordsData(c.name + ' ' + c.email + ' ' + c.Referee_Rank__c + ' ' + c.Region__c, c.id) ); 
                }
                
            }
            return recordsDataList;
            
            
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                System.debug('1 ' + err.getMessage());
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                System.debug('2 ' + err.getMessage());
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    
    // THIS INSERTS RESPONSES INTO Evaluation_Responses__c
    @AuraEnabled
    public static String insertResponses(String responseString) {
        
        String EvaluatorId;
        String EvaluatorContactId;
        String EvalueeId;
        String evaluationtype;
        String EvaluationLocation;
        String EvaluationDate;
        String EvaluatorComment;
        String QuestionnaireDateTime;
        String QuestionnaireId;
        
        System.debug('insertResponses: ' + responseString);
        String[] responses = responseString.split('\n'); 
        
        /* USED TO TEST DELAYED RESPONSES
        if(1==1) {
            sleep(5000);
            return;
        }
        */
        
        try {
        
        // begin responses for loop
        for(String resp : responses) {
            if(resp.contains('evaluatorid')) {
                EvaluatorId = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('evaluatorcontactid')) {
                EvaluatorContactId = resp.substring(resp.indexOf('=')+1); }
           else if(resp.contains('evalueeid')) {
                EvalueeId = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('evaluationtype')) {
                evaluationtype = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('evaluationlocation')) {
                EvaluationLocation = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('evaluationdate')) {
                EvaluationDate = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('questionnairedatetime')) {
                QuestionnaireDateTime = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('evaluatorcomment')) {
                EvaluatorComment = resp.substring(resp.indexOf('=')+1); }
            else if(resp.contains('~')) {
                
                String[] r = resp.split('~');
                String EvaluationQuestionNum = r[0];
                String[] rr = r[1].split('-');
                String EvaluationRating = rr[1];
                  
                // THIS WAS CREATED TO REDUCE TRAFFIC BETWEEN CLIENT AND SERVER 
                // TODO:  REVIEW EFFECTIVENESS
                Evaluation_Questions__c[] EvaluationQuestionId = [SELECT id,
                       Evaluation_Type__c,                                           
                       Question_Number__c, 
                       Question_Text__c,
                       isRequired__c,                                          
                       QuestionType__r.Name,
                       QuestionType__r.Response_Text_1__c, 
                       QuestionType__r.Response_Text_2__c, 
                       QuestionType__r.Response_Text_3__c
                       from Evaluation_Questions__c WHERE Question_Number__c =: EvaluationQuestionNum ];
                
                System.debug('Common values: ' + EvaluatorId + ' ' + EvaluatorContactId + ' ' + EvalueeId + ' ' + EvaluationQuestionNum + ' ' + EvaluationRating);

                Evaluation_Responses__c er = new Evaluation_Responses__c();
                                
                er.Evaluation_Date__c = date.valueOf(EvaluationDate);
                
                //system.debug('String QuestionnaireDatetime = '+ QuestionnaireDateTime );
                // THIS WAS A VERY TRICKY ONE - NORMAL PARSE AND VALUEOF DID NOT WORK
                er.Questionnaire_DateTime__c = (DateTime) JSON.deserialize('"' + QuestionnaireDateTime + '"', DateTime.class);
                //system.debug('Parsed QuestionnaireDatetime = ' + er.Questionnaire_DateTime__c);
                
                System.debug('genQuestionnaireID ' + er.Questionnaire_DateTime__c + ' ' + EvalueeId);
                if(String.isEmpty(QuestionnaireId)) {
                    QuestionnaireId = genQuestionnaireID(er.Questionnaire_DateTime__c, EvalueeId);
                } 
                er.Questionnaire_Id__c = QuestionnaireId;
                
                if(EvaluationLocation == null || EvaluationLocation.length() == 0)
                    er.Evaluation_Location__c = 'Location omitted';
                else
                    er.Evaluation_Location__c = EvaluationLocation;
                er.Evaluation_Type__c = EvaluationQuestionId[0].Evaluation_Type__c;
                er.Question_Number__c =  EvaluationQuestionId[0].Question_Number__c; // EvaluationQuestionNum;
                er.Question_Text__c = EvaluationQuestionId[0].Question_Text__c;
                er.Question_Type__c = EvaluationQuestionId[0].QuestionType__r.Name;
                er.Question_Id__c =  EvaluationQuestionId[0].ID; // EvaluationQuestionNum;
                er.Evaluation_Rating__c = EvaluationRating; 
                if(EvaluationRating == '1') {
                    er.Evaluation_Rating_Text__c  = EvaluationQuestionId[0].QuestionType__r.Response_Text_1__c;
                }
                if(EvaluationRating == '2') {
                    er.Evaluation_Rating_Text__c  = EvaluationQuestionId[0].QuestionType__r.Response_Text_2__c;
                }
                
                if(EvaluationRating == '3') {
                    er.Evaluation_Rating_Text__c  = EvaluationQuestionId[0].QuestionType__r.Response_Text_3__c;
                }
                if(EvaluationQuestionId[0].QuestionType__r.Name.contains('Overall')) {
                   er.Evaluator_Comment__c = EvaluatorComment;    
                } else {
                   er.Evaluator_Comment__c = ''; 
                }
                er.Evaluator_User_Id__c = Id.valueOf(EvaluatorId);
                er.Evaluator_Id__c = Id.valueOf(EvaluatorContactId);
                er.Evaluee_Id__c = Id.valueOf(EvalueeId);

                insert er;
                
            }  // end if resp.contains('~')  
        }  // end end responses for loop
        
        Evaluation_ResponsesAbstract__c rr = new Evaluation_ResponsesAbstract__c();
        rr.Questionnaire_DateTime__c = (DateTime) JSON.deserialize('"' + QuestionnaireDateTime + '"', DateTime.class);
        rr.Questionnaire_Id__c = QuestionnaireId;
        rr.Evaluee_Id__c = EvalueeId;  
        rr.Evaluation_Date__c = date.valueOf(EvaluationDate);
        rr.Evaluation_Location__c = EvaluationLocation; 
        rr.Evaluator_User_Id__c = EvaluatorId;
        rr.Evaluator_Id__c = EvaluatorContactId; 
        rr.Evaluation_Type__c = EvaluationType;
        insert rr;
        
        System.debug('Inserted ' + QuestionnaireId);
            
        String rtr = EvaluatorId + ';' + EvalueeId + ';' + QuestionnaireId + ';' + EvaluationType;   
         
        return rtr;    
            
        } catch(Exception err) {
            String errMsg = err.getMessage();
            String errTrace = err.getStackTraceString();
            System.debug(errMsg);
            System.debug(errTrace);
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    // =================================================================================
    // THE FOLLOWING IS RELATED TO EMAIL AND PDF FILE GENERATION
    
    public static String EvaluatorName {get; set;}
    public static String EvalueeName {get; set;}
    public static String EvaluationLocation {get; set;}
    public static Date EvaluationDate {get; set;}
    public static String EvaluatorComment {get; set;}
    public static String PositionEvaluated {get; set;}
    
    // =====================================================================
    // PULLS A LIST OF COMPLETED EVALUATIONS FOR RESEND AND TESTING 
    @AuraEnabled
    public static List<RecordsData> getEvaluationsList() {
        
        List<RecordsData> evaluations = new List<RecordsData>();
        
        // TODO: SELECT BASED UPON WHO THE REQUESTOR IS
        String searchquery = 'Select Questionnaire_DateTime__c, Questionnaire_Id__c, Evaluator_User_Id__r.name,  Evaluee_Id__r.name,  Evaluation_Type__c, Evaluation_Location__c, Evaluator_User_Id__c, Evaluator_Id__c from Evaluation_ResponsesAbstract__c';
        System.debug(searchquery);
        
        List <sObject> evaluationlist = new List <sObject>();
        evaluationlist = Database.query(searchquery);
        integer sz = evaluationlist.size();
        for(integer i = 0 ; i < sz; i++)
        {
            String evaluee = (String) evaluationlist[i].getSObject('Evaluee_Id__r').get('name');
            String evalueeId = (String) evaluationlist[i].get('Evaluee_Id__c');
            String evaluator = (String) evaluationlist[i].getSObject('Evaluator_User_Id__r').get('name');
            String evaluatorId = (String) evaluationlist[i].get('Evaluator_User_Id__c');
            String evaluatorContactId = (String) evaluationlist[i].get('Evaluator_Id__c');
            String evaluationType = (String) evaluationlist[i].get('Evaluation_Type__c');
            String questionnaireId = (String) evaluationlist[i].get('Questionnaire_Id__c');
            String evaluationlocation = (String) evaluationlist[i].get('Evaluation_Location__c');
            
            String rid = evaluatorId + ';' + evalueeId + ';' + questionnaireId;
            String eval = evaluee + ' ' + evaluationType  + ' \n@ ' + evaluationlocation + ' \nby '  +  evaluator;
            
            System.debug(eval + ' ' + rid);
            evaluations.add(new RecordsData(eval, rid));
        }
        return evaluations;
        
    }
    
    
    // =====================================================================
    // THIS WILL CREATE THE REPORT THAT WILL BE CONVERTED TO PDF AND PLACED IN THE USER'S FILE FOLDER
    @AuraEnabled
    @future(callout=true) 
    public static void generateRefAssessmentRPT(String pEvaluatorId, String pEvalueeId, String pQuestionnaireId, 
                                                String pEvaluee, String pLocation, String pPosition ) {

        System.debug('in EvaluationQuestionsController generateRefAssessmentRPT');
        if( String.isEmpty(pEvaluee) || String.isEmpty(pLocation) || String.isEmpty(pPosition) ) {
           System.debug('generateRefAssessmentRPT pulling missing data from Evaluation_ResponsesAbstract__c');
           Evaluation_ResponsesAbstract__c rr = [select evaluee_id__c, evaluee_id__r.name, evaluation_type__c, evaluation_location__c from Evaluation_ResponsesAbstract__c 
                                            where questionnaire_id__c =: pQuestionnaireId limit 1];    
           pEvaluee = rr.evaluee_id__r.name;
           pLocation = rr.evaluation_location__c;
           pPosition = rr.evaluation_type__c;
        }                                                    
                                                    
        // TEST SWITCHES
        boolean wrapWithApex = true;
        boolean outputPDF = true;
        boolean outputHTML = false;
        
        RefereeAssessment ra = new RefereeAssessment();

        System.debug('generateRefAssessment EvaluatorId: ' + pEvaluatorId);
        System.debug('generateRefAssessment EvalueeId: ' + pEvalueeId);
        
        System.debug('generateRefAssessment Evaluee: ' + pEvaluee);
        System.debug('generateRefAssessment Position: ' + pPosition);
        System.debug('generateRefAssessment Location: ' + pLocation);
        System.debug('generateRefAssessment QuestionnaireId: ' + pQuestionnaireId);
       
        DateTime dt = DateTime.now();
        String dateStr = dt.format('MMdd-HHmm-SS');
        
        Account acc = [SELECT Id FROM Account WHERE Id = '0016A00000K77C4QAJ'];  // TODO:  WORKS BUT NEED MORE INFO
        String parentId = acc.Id;
        Contact c = [select Id, email, OwnerId from contact where id =: pEvalueeId ];
        String linkedId = c.OwnerId;
        String evaluee_email = c.Email;
        
        System.debug('RefereeAssessment ouputPDF');
        //         System.debug('generateRefAssessment QuestionnaireId: ' + pQuestionnaireId);

        // FormatFileNameFromProps(String Evaluee, String Location, String Position, String Id) 
        String filename = FormatFileNameFromProps(pEvaluee, pLocation, pPosition, pQuestionnaireId);
        if(filename.length() < 1)
            fileName = 'RA_' + dateStr + '-' + pQuestionnaireId + '.pdf';
                                                    
        // begin test 
        // test 1 - same result no data
        
        PageReference pageReferenceForPDF = Page.RefereeAssessment;
        pageReferenceForPDF.getParameters().put('pEvaluatorId',pEvaluatorId);
        pageReferenceForPDF.getParameters().put('pEvalueeId',pEvalueeId);
        pageReferenceForPDF.getParameters().put('pQuestionnaireId',pQuestionnaireId);
        
        System.debug('RefereeAssessment getContentAsPDF follows');    
        // Blob body = pageReferenceForPDF.getContentAsPDF(); 
        Blob body = pageReferenceForPDF.getContent();   
        
        String contentType = 'application/pdf';
        
        System.debug('RefereeAssessment createFile follows'); 
        ContentDocumentLink rptfile = ra.createFile(parentId, linkedId, fileName, body, contentType);
        
        System.debug('RefereeAssessment file saved now create email'); 

        try{                                            
            ra.SendDirectMessage(pEvalueeId, rptfile.ContentDocumentId );                                            
        } catch(Exception err) {
            System.debug('SendDirectMessage error: ' + err.getMessage());
            System.debug(err.getStackTraceString());
            System.debug('----------------------------------------------');
        }
        System.debug('Referee Assessment completed');   
        
    } 
    
    // =================================================================
    // THIS INITIATES THE REFEREE ASSESSMENT REPORT REQUEST FROM A LIGHTNING PAGE PARAMETERS ARE PASSED FROM THE PAGE
    @AuraEnabled
    public static void  getResponsesVF() {
        
        System.debug('in EvaluationQuestionsConroller.apxc getResponseVF');
        
        RefereeAssessment ra = new RefereeAssessment();
        
        PageReference pg = ApexPages.currentPage();
        String pEvaluatorId =  pg.getParameters().get('pEvaluatorId');
        String pEvalueeId = pg.getParameters().get('pEvalueeId');
        String pQuestionnaireId = pg.getParameters().get('pQuestionnaireId');
        
        System.debug('pEvaluatorId: ' + pEvaluatorId);
        System.debug('pEvalueeId: ' + pEvalueeId);
        System.debug('pQuestionnaireId: ' + pQuestionnaireId);
        ra.getResponses(pEvaluatorId, pEvalueeId, pQuestionnaireId);
        
        System.debug('out getResponseVF');
    }    
    
    // =================================================================
    // GET RESPONSES FOR ASSESSMENT REPORT
    public List<Evaluation_Responses__c>  getResponses(
        String pEvaluatorId, 
        String pEvalueeId, 
        String pQuestionnaireId) {
        
        System.debug('in getResponses');    
            
        RefereeAssessment ra = new RefereeAssessment();
        
        if(String.isEmpty(pQuestionnaireId)) {
            pQuestionnaireId = RefereeAssessment.QuestionnaireId;
        }
        if(String.isEmpty(pEvalueeId)) {
            pEvalueeId = RefereeAssessment.EvalueeId;
        }
        if(String.isEmpty(pEvaluatorId)) {
            pEvaluatorId = RefereeAssessment.EvaluatorId;
        }
            
        List<Evaluation_Questions__c> selectedquestions = new List<Evaluation_Questions__c>();
        List<Evaluation_Responses__c> selectedresp = new List<Evaluation_Responses__c>();
        List<Evaluation_Responses__c> editedresp = new List<Evaluation_Responses__c>();

        System.debug('Select from Evaluation_Responses__c follows');
        selectedresp = [SELECT 
              Evaluator_User_Id__r.name,
              Evaluee_Id__r.Name,
              Questionnaire_DateTime__c,            
              Questionnaire_Id__c,          
              Evaluation_Date__c,
              Evaluation_Location__c,
              Evaluation_Type__c,Question_Type__c,
              Question_Number__c,Question_Text__c,Evaluation_Rating_Text__c,
              Evaluator_Comment__c
              FROM Evaluation_Responses__c
              where evaluator_user_id__c =: pEvaluatorId and evaluee_id__c =: pEvalueeId and Questionnaire_Id__c =: pQuestionnaireId    
              order by question_number__c   ];       
        
        String EvaluationTypeIn = selectedresp[0].Evaluation_Type__c;
        
        System.debug('Select from Evaluation_Questions__c follows');
        selectedquestions = [SELECT Name, 
               Evaluation_Type__c, 
               Question_Number__c, 
               Question_Text__c, 
               Question_Active__c, 
               QuestionType__c,
               QuestionType__r.Name,
               QuestionType__r.Response_Text_1__c, 
               QuestionType__r.Response_Text_2__c, 
               QuestionType__r.Response_Text_3__c,
               QuestionType__r.Type_Response_Count__c,
               IsQuestionGroupHeader__c                
               FROM Evaluation_Questions__c
               where Evaluation_Type__c =: EvaluationTypeIn and Question_Active__c = true
               order by question_number__c];        
        
        //RefereeAssessment.respCount = selectedresp.size();
        //System.debug('Rows returned = ' + RefereeAssessment.respCount);
        boolean match = false;
        for (Evaluation_Questions__c q : selectedquestions ) {
            match = false;
            //System.debug('check ' + q.Question_Number__c + '  ' + q.Question_Text__c);
            for (Evaluation_Responses__c er : selectedresp ) {
                if(q.Question_Number__c.contains('_0'))
                    break;
                if(q.Question_Number__c == er.Question_Number__c) {
                    //System.debug(er.Evaluator_User_Id__r.name);
                    EvaluatorName = er.Evaluator_User_Id__r.name;
                    EvalueeName = er.Evaluee_Id__r.name;
                    System.debug(EvalueeName);
                    EvaluationLocation = er.Evaluation_Location__c;
                    EvaluationDate = er.Evaluation_Date__c;
                    if(String.isNotBlank(er.Evaluation_Type__c))
                        PositionEvaluated = er.Evaluation_Type__c;
                    if(String.isNotBlank(er.Evaluator_Comment__c))
                        EvaluatorComment = er.Evaluator_Comment__c;
                    editedresp.add(er);
                    match = true;
                } 
            }
            if(match)
                continue;
            else {
                Evaluation_Responses__c r = new Evaluation_Responses__c();
                //System.debug('no match ' + q.Question_Number__c + '  ' + q.Question_Text__c);
                r.Question_Text__c = q.Question_Text__c;
                r.Question_Number__c = q.Question_Number__c;
                r.Question_Type__c = q.QuestionType__r.Name;
                if(!r.Question_Number__c.contains('_0') )
                   r.Evaluation_Rating_Text__c = 'Not Selected';
                editedresp.add(r);
            }
            
        }
        RefereeAssessment.responses = editedresp;
        
        System.debug('out getResponses return size=' + RefereeAssessment.responses.size());
        
        //sleep(5000);
        //ra.GeneratePDF();
        
        return editedresp;
    }

    
    // =================================================================
    // METHODS USED TO HANDLE OUTPUT
       
    // THIS WILL PLACE THE PDF REPORT IN THE USER'S FILE FOLDER
    public ContentDocumentLink createFile(Id parentId, Id linkedId, String fileName, Blob body, String contentType) {

        System.debug('createFile ' + filename + ' ' + contentType);
        // insert a version of the file - if no ContentDocumentId, then it creates a new ContentDocument
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; // S = within Salesforce, E = External
        cv.VersionData = body;
        cv.Title = fileName;
        cv.PathOnClient = filename;
        //cv.OwnerId = linkedId; // owner exception
        //cv.firstPublishLocationId= linkedId;
        insert cv;
        System.debug('createFile ContentVersion completed');

        // insert a ContentDocumentLink with the file version
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        //cdl.LinkedEntityId = parentId;
        cdl.LinkedEntityId = linkedId;
        cdl.ShareType = 'V';
        //cdl.Visibility = 'SharedUsers'; // share exception
        insert cdl;
        
        System.debug('createFile ContentDocumentLink completed');
        
        return cdl;
    }
 
    // ==================================================================
    // UTILITIES 
     
    private static void sleep(integer milliseconds) 
    {
            Long timeDiff = 0;
            DateTime firstTime = System.now();
            do
            {
                timeDiff = System.now().getTime() - firstTime.getTime();
            }
            while(timeDiff <= milliseconds);      
    }
    
    public static String GUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        //system.debug(guid);
        return guid;
    }
    
    public static String genQuestionnaireID(DateTime Questionnaire_DateTime, String EvalueeId)
    {
            System.debug('Questionnaire_DateTime = ' + Questionnaire_DateTime.formatGMT('yyyymmddhhmmss'));
            System.debug('EvalueeId = ' + EvalueeId);
        
            List<Contact> c = [SELECT Name FROM Contact where id =: EvalueeId];
            String Evaluee = c[0].Name;
            String strQuestionnaireDT = Questionnaire_DateTime.formatGMT('yyyymmddhhmmss');
            string QuestionnaireID = Evaluee.substring(0,1) + Evaluee.substringafterlast(' ').substring(0,1) + strQuestionnaireDT;
            System.debug(QuestionnaireID);
            return QuestionnaireID;
    }
  
    public static String StringTS() {
        Long ts = DateTime.now().getTime();
        String sts = ts + '';
        System.debug(sts);
        return sts;
    }
 
    public static String FormatFileNameFromProps(String Evaluee, String Location, String Position, String ID) {
        
        System.debug('FormatFileNameFromProps evaluee=' + evaluee + ' loc=' + Location + ' Pos=' + Position  + ' Id=' + Id );
        
        /*
        $D = Date - YYYYMMDD
        $DT = DateTime - YYYYMMDDHHMMSS
        $EN = Full Evaluee Name - spaces will be removed
        $EL = Evaluee Initial with LastName
        $EI = Evaluee Inititals
        $L = Location - spaces will be replaced with underscore
        $PN = Position
        $PA = Positioni abbreviated: S, JS, R, JS, CC, M, CR
        $ID = evaluation ID
        */
       String filename = '';
       String fmt = getProp('FileNameFormat');
        if(String.isEmpty(fmt)) {
            System.debug('No FileNameFormat found');
           return filename;
        }
       //String[] fmtelems = fmt.split(';'); 
        
       DateTime dtn = DateTime.now();
       if(fmt.contains('$DT')) {
            String DT = dtn.format('yyyyMMddHHmmsss'); 
            fmt = fmt.replace('$DT', DT);
       }
       if(fmt.contains('$D')) {
           String D = dtn.format('yyyyMMdd');
           fmt = fmt.replace('$D', D);
       }
        if(fmt.contains('$EN')){
            String EN = Evaluee.replace(' ','_');
            fmt = fmt.replace('$EN',EN);
        }
        if(fmt.contains('$EL')) {          
            String EL = Evaluee.substring(0,1) + Evaluee.substringafterlast(' '); 
            fmt = fmt.replace('$EL',EL);
        }
        if(fmt.contains('$EI')) {
            String EI = Evaluee.substring(0,1) + Evaluee.substringafterlast(' ').substring(0,1);
            fmt = fmt.replace('$EI',EI);
        }
        if(fmt.contains('$ID')) {
            fmt = fmt.replace('$ID',ID);
        }
        if(fmt.contains('$L')) {
            String L = Location.replace(' ','_');
            fmt = fmt.replace('$L',L);
        }
        if(fmt.contains('$PN')) {
            String PN = Position;
            fmt = fmt.replace('$PN',PN);
        }
        if(fmt.contains('$PA')) {
            String PA = '';
            Switch on Position {
            when 'CHIEF JUDGE' { PA = 'CJ'; } 
            when 'CONTROL COMMISSION' { PA = 'CC'; } 
            when 'JUDGE AT START' { PA = 'JS'; } 
            when 'STARTER' { PA = 'S'; } 
            when else { PA = 'R'; }
            }
            fmt = fmt.replace('$PA',PA);
        }
        filename = fmt;
        
        if(!filename.contains('.pdf'))
            filename = filename + '.pdf';
            
       System.debug(filename); 
       return filename;
    }
 
    // =================================================================
    // OBJECTS USED
    
    public class MyRegatta {
        public String Id;
        public String RegattaName;
        public Datetime StartDate;
        public MyRegatta(String id, String name, Datetime sdate) {
            this.Id = id;
            this.RegattaName = name;
            this.StartDate = sdate;
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
}