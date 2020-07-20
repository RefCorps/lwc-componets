@isTest public with sharing class RefereeAssessmentTest {
    
    static Contact evaluatorcontact;
    static User evaluatoruser;
    static Contact evalueecontact;
    static User evalueeuser;
	static Regatta__c evalregatta;
    static Regatta_Participation__c[] regattaparticipation;
    
    static String rEvaluatorContactId;
    static String rEvalueeId;
    static String rQuestionnaireId;
    static String rEvaluationType;
   
    static User portalAccountOwner;

    public static testMethod void LoadTestUserData(){

        /*
            This method creates an admin user that will create a Referee user and an Assistant Referee user
            Note 1:  A real RefCorp user will have an AccountId set to ID 0016A00000K77C4QAJ NAME USRowing
            Through trial and error I found that when I included AccountId the load would fail due to an
            embedded test condition [if(Test.isRunningTest())...] in a Nonprofit Success Pack (NPSP) related trigger.  
            Omitting AccountId works just fine for testing.
            Note 2:  This method may be call many times depending upon scope of variables across methods. Note that 
            global variables are static.
            Note 3:  Consideration was given to loading static resources; however, this proved to be the cleaner
            option and since the basic user data is limited and consistent there's no need to change it as would 
            be possible with a static resource.  If static resource is needed because values are more dynamic than 
            currently implmented consider the following code:
                List<StaticResource> docs;
                docs = [select id, name, body from StaticResource 
                where name = 'RAEvalTestData'];
            The data will appear in the body.
        */
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None'
            Limit 1
        ];
        // Select Id, name from UserRole where  
        // portalRole is blank for us rowing ref

        // admin user
        String fnamea = 'Admin';
        String lnamea = 'Evaltest';
        String emaila = 'admin.evaltest@test.com';
        String aliasa = 'aeval'; // only be 8 chars 

        // contact1 - user1 
        String fname1 = 'Eva';
        String lname1 = 'Evaltest';
        String email1 = 'evareferee@test.com';
        String rank1 = 'Referee';
        String region1 = 'Southeast';
        String gender1 = 'Female';
        String alias1 = 'reval'; // only be 8 chars 

        // contact2 - user2
        String fname2 = 'Evan';
        String lname2 = 'Evaltest';
        String email2 = 'evanassistant@test.com';
        String rank2 = 'Assistant';
        String region2 = 'Southeast';
        String gender2 = 'Male';
        String alias2 = 'aeval'; // can only be 8 chars

        System.debug('-------------------------------------------------------------------------');
        System.debug('In LoadTestUserData');
        
        System.debug('portalRole is ' + portalRole);
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        System.debug('New System Admin user follows');
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + emaila,
            Alias = aliasa,
            Email= emaila,
            EmailEncodingKey='UTF-8',
            Firstname=fnamea,
            Lastname=lnamea,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/New_York'
        );
        Database.insert(portalAccountOwner1);

        portalAccountOwner = portalAccountOwner1;
        System.debug('runAs portalAccountOwner1');

        System.runAs(portalAccountOwner) {
            /*
            Account portalAccount1 = new Account(
                Name = 'EvalTestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            */

            System.debug('Create Contact 1');
            Contact contact1 = new Contact(
                FirstName = fname1,
                Lastname = lname1,
                // AccountId =  portalAccount1.Id, //'0016A00000K77C4QAJ',
                Email = System.now().millisecond() + email1,
                MEMBERSHIP_LEVEL__C = 'Basic',
                OWNERID = '005e00000060aLjAAI',
                REFEREE_RANK__C = rank1,
                REFEREE_STATUS__C = 'Active',
                REGION__C = region1,
                Contact_Gender__c = gender1
            );
            System.debug('Insert Contact1 ' + fname1 + ' ' + lname1);
            Database.insert(contact1);
            System.debug('Contact1 id = ' + contact1.Id);

            evaluatorcontact = [SELECT Id, AccountId, Name, FirstName,
                Lastname, Email, MEMBERSHIP_LEVEL__C, OWNERID, REFEREE_RANK__C,
                REFEREE_STATUS__C, REGION__C, Contact_Gender__c FROM Contact where ID =: contact1.Id
            ];
            // Load to EvaluationQuestionController for processing tests
            EvaluationQuestionsController.testEvaluatorcontact = evaluatorcontact;

            System.debug('evaluatorcontact id = ' + evaluatorcontact.Id +
                '\nAccountId = ' + evaluatorcontact.AccountId +
                '\nName = ' + evaluatorcontact.Name +
                '\nOwnerId = ' + evaluatorcontact.OwnerId +
                '\nReferee_Status__c = ' + evaluatorcontact.Referee_Status__c
            );
            //
            //Create user
            // SELECT Id, name FROM Profile where name like '%Referee%'
            Profile portalProfile = [SELECT Id FROM Profile where name = 'Referee'
                Limit 1
            ];
            User user1 = new User(
                Username = System.now().millisecond() + email1,
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = alias1,
                Email = email1,
                EmailEncodingKey = 'UTF-8',
                FirstName = evaluatorcontact.FirstName, //'Referee',
                LastName = evaluatorcontact.LastName, //'Evaltest',
                USER_REFEREE_RANK__C = evaluatorcontact.REFEREE_RANK__C, //'Referee',
                CommunityNickname = alias1 + getTimeBasedId(),
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            System.debug('Insert User1 ' + fname1 + ' ' + lname1);
            Database.insert(user1);

            evaluatoruser = [Select Id, Username, Name,
                ContactId,
                ProfileId,
                Alias,
                Email,
                EmailEncodingKey,
                FirstName,
                LastName,
                USER_REFEREE_RANK__C, //'Referee',
                CommunityNickname
                FROM User where Id =: user1.Id
            ];

            System.debug('User1 created');

            System.debug('-------------------------------------------------------------------------');
            System.debug('Create Contact 2');

            Contact contact2 = new Contact(
                FirstName = fname2,
                Lastname = lname2,
                // AccountId =  portalAccount1.Id, //'0016A00000K77C4QAJ',
                Email = System.now().millisecond() + email2,
                MEMBERSHIP_LEVEL__C = 'Basic',
                OWNERID = '005e00000060aLjAAI',
                REFEREE_RANK__C = rank2,
                REFEREE_STATUS__C = 'Active',
                REGION__C = region2,
                Contact_Gender__c = gender2
            );
            System.debug('Insert contact2');
            Database.insert(contact2);
            System.debug('Contact2 id = ' + contact2.Id);

            evalueecontact = [SELECT Id, AccountId, Name, FirstName,
                Lastname, Email, MEMBERSHIP_LEVEL__C, OWNERID, REFEREE_RANK__C,
                REFEREE_STATUS__C, REGION__C, Contact_Gender__c FROM Contact where ID =: contact2.Id
            ];

            // Load to EvaluationQuestionController for processing tests
            EvaluationQuestionsController.testEvalueecontact = evalueecontact;

            System.debug('Selected from Contact' + 
                '\nEvalueeContact Id = ' + evalueecontact.Id +
                '\nAccountId = ' + evalueecontact.AccountId +
                '\nName = ' + evalueecontact.Name +
                '\nOwnerId = ' + evalueecontact.OwnerId +
                '\nReferee_Status__c = ' + evalueecontact.Referee_Status__c
            );


            //
            //Create user
            // SELECT Id, name FROM Profile where name like '%Referee%'
            //Profile portalProfile = [SELECT Id FROM Profile where name = 'Referee' Limit 1];
            User user2 = new User(
                Username = System.now().millisecond() + email2,
                ContactId = contact2.Id,
                ProfileId = portalProfile.Id,
                Alias = alias2,
                Email = email2,
                EmailEncodingKey = 'UTF-8',
                FirstName = evalueecontact.FirstName, //'Referee',
                LastName = evalueecontact.LastName, //'Evaltest',
                USER_REFEREE_RANK__C = evalueecontact.REFEREE_RANK__C, //'Referee',
                CommunityNickname = alias2 + getTimeBasedId(),
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            System.debug('Insert User2');
            Database.insert(user2);

            evalueeuser = [Select Id, Username, Name,
                ContactId,
                ProfileId,
                Alias,
                Email,
                EmailEncodingKey,
                FirstName,
                LastName,
                USER_REFEREE_RANK__C, //'Referee',
                CommunityNickname
                FROM User where Id =: user2.Id
            ];

            System.debug('User2 created');
        }
        System.debug('LoadTestUserData completed');
        System.debug('-------------------------------------------------------------------------');
    }
    
    @IsTest(SeeAllData=true)
    public static void LoadTestRegattaParticipantData() {

        System.debug('In LoadTestRegattaParticipantData');
        if (evaluatoruser == null) {
            System.debug('evaluatoruser is null');
            LoadTestUserData();
        }
        System.debug('Get user Id next');
        User evaluatorusr = [Select id from User where Id =: evaluatoruser.id];

        System.debug('Get regatta Id next');
        System.RunAs(evaluatorusr) {
           Regatta__c testregatta = new Regatta__c(

                Start_Date_Test__c = Date.today().AddDays(-2),
                End_Date_Test__c = Date.today().AddDays(-2),

                START_DATE__C = DateTime.Now().AddDays(-2),
                END_DATE__C = DateTime.Now().AddDays(-2),

                NAME = 'Eval Invite',
                REGATTA_CITY__C = 'Sarasota',
                REGATTA_COUNTRY__C = 'United States',
                REGATTA_COURSE__C = 'a0i6A000003h2XNQAY',
                REGATTA_DESCRIPTION__C = 'Test Regatta',
                REGATTA_REGION__C = 'Southeast',
                REGATTA_STATE__C = 'Florida',
                REGATTA_STATUS__C = 'On Schedule',
                REGATTA_TYPE__C = 'Sprint',

                HOUSING_PROVIDED__C = FALSE,
                INVITE_ONLY__C = TRUE,
                STIPEND_OFFERED__C = FALSE,
                US_ROWING_REGISTERED__C = FALSE,
                NATIONALLY_RECOGNIZED_REGATTA__C = FALSE

            );
            Database.insert(testregatta);

            evalregatta = [select id, name, Start_Date_Test__c, START_DATE__C 
                           from regatta__c where id =: testregatta.id limit 1];
        }
        EvaluationQuestionsController.testEvalregatta = evalregatta.clone();
        System.debug('Loaded regatta ' + evalregatta.Name);

        System.debug('Run using Id ' + evaluatorusr.Id);
        System.RunAs(evaluatorusr) {

            System.debug('Loading contact ' + evaluatorcontact.Name + ' contact id ' + evaluatorcontact.id);
            System.debug('Loading user ' + evaluatoruser.Name + ' user id ' + evaluatoruser.id);
            System.debug('Loaded to ' + evalregatta.Name);
            Regatta_Participation__c rr = new Regatta_Participation__c(

                PARTICIPANT__C = evaluatorcontact.id,
                REGATTA_PARTICIPANT_USER__C = evaluatoruser.id,

                PARTICIPATION_REGATTA__C = evalregatta.id,
                REGATTA_PARTICIPANT_ROLE__C = 'Referee',
                Days_Worked__c = 2,

                ALIGNER__C = TRUE,
                ASSISTANT_STARTER__C = FALSE,
                ATHLETE_WEIGHING__C = FALSE,
                BOAT_WEIGHING__C = FALSE,
                CHEF_DU_LAC__C = FALSE,
                CHIEF_JUDGE_AT_FINISH__C = TRUE,
                CHIEF_REFEREE__C = FALSE,
                COURSE_MARSHAL__C = FALSE,
                DEPUTY_CHIEF__C = FALSE,
                FINISH_LINE__C = FALSE,
                FINISH_MARSHAL__C = FALSE,
                JUDGE_AT_START__C = TRUE,
                JURY__C = FALSE,
                OMBUDSMAN__C = FALSE,
                REFEREE_POSITION__C = FALSE,
                SAFETY_CHECK__C = FALSE,
                START_MARSHAL__C = FALSE,
                STARTER_POSITION__C = FALSE,
                SUPERVISED_OTHER_REFEREES__C = FALSE,
                ZONAL_REFEREE__C = FALSE
            );
            System.debug('Inserting referee participant next');
            Database.insert(rr);
        }

        User evalueeusr = [Select id from User where Id =: evalueeuser.id];
        System.debug('Run using Id ' + evalueeusr.Id);
        System.RunAs(evalueeusr) {

            System.debug('Loading contact ' + evalueecontact.Name + ' contact id ' + evalueecontact.id);
            System.debug('Loading user ' + evalueeuser.Name + ' user id ' + evalueeuser.id);
            System.debug('Loaded to ' + evalregatta.Name);
            Regatta_Participation__c ra = new Regatta_Participation__c(

                PARTICIPANT__C = evalueecontact.id,
                REGATTA_PARTICIPANT_USER__C = evalueeuser.id,

                PARTICIPATION_REGATTA__C = evalregatta.id,
                REGATTA_PARTICIPANT_ROLE__C = 'Assistant Referee',
                DAYS_WORKED__C = 2,

                ALIGNER__C = TRUE,
                ASSISTANT_STARTER__C = FALSE,
                ATHLETE_WEIGHING__C = FALSE,
                BOAT_WEIGHING__C = FALSE,
                CHEF_DU_LAC__C = FALSE,
                CHIEF_JUDGE_AT_FINISH__C = TRUE,
                CHIEF_REFEREE__C = FALSE,
                COURSE_MARSHAL__C = FALSE,
                DEPUTY_CHIEF__C = FALSE,
                FINISH_LINE__C = FALSE,
                FINISH_MARSHAL__C = FALSE,
                JUDGE_AT_START__C = TRUE,
                JURY__C = FALSE,
                OMBUDSMAN__C = FALSE,
                REFEREE_POSITION__C = TRUE,
                SAFETY_CHECK__C = FALSE,
                START_MARSHAL__C = FALSE,
                STARTER_POSITION__C = TRUE,
                SUPERVISED_OTHER_REFEREES__C = FALSE,
                ZONAL_REFEREE__C = FALSE
            );
            System.debug('Inserting assistant participant next');
            Database.insert(ra);

        }

        Integer p =  [select count() from regatta_participation__c where Participation_Regatta__c =: evalregatta.id];
        
        regattaparticipation = [SELECT Participation_Regatta__c, Participation_Regatta__r.name, 
                                Participation_Regatta__r.Start_Date__c, Participation_Regatta__r.End_Date__c 
                                FROM Regatta_Participation__c WHERE Participation_Regatta__c =: evalregatta.id];
        
        System.debug('Participants [' + p + '] loaded to regatta');
        System.debug('Particpants fetch count = '+ regattaparticipation.size());
        // Load to EvaluationQuestionController for processing tests
        EvaluationQuestionsController.testRegattaParticipation = regattaparticipation.clone();
        System.debug('EvaluationQuestionsController testRegattaParticipation count = '+ EvaluationQuestionsController.testRegattaParticipation.size());
        
        System.debug('-------------------------------------------------------------------------');
    }
    

    @IsTest(SeeAllData=true)    
    public static void LoadEvalResponses() {

        System.debug('--------------------------------------------------------------------------------');
        System.debug('Begin LoadEvalResponses');

        if (evaluatoruser == null) {
            System.debug('LoadEvalResponses evaluatoruser is null.  Run LoadTestRegattaParticipantData');
            LoadTestRegattaParticipantData();
        }
        User evaluatorusr = [Select id from User where Id =: evaluatoruser.id];

        String querystmt0 = 'Select Id, Name from Contact where Id = \'' + evalueecontact.Id + '\'';
        System.debug('LoadEvalResponses test0 ' + querystmt0);
        Contact ee0 = Database.query(querystmt0);
        System.debug('LoadEvalResponses test0 evaluee Id'+ ee0.Id + ' / ' + evalueecontact.Id );        

        //System.RunAs(evaluatorusr) {
        System.RunAs(portalAccountOwner) {

            String querystmt01 = 'Select Id, Name from Contact where Id = \'' + evalueecontact.Id + '\'';
            System.debug('LoadEvalResponses test01 ' + querystmt01);
            Contact ee01 = Database.query(querystmt01);
            System.debug('LoadEvalResponses test0 evaluee Id'+ ee01.Id + ' / ' + evalueecontact.Id );        

            System.debug('LoadEvalResponses evaluatorname=' + evaluatorcontact.name);
            System.debug('LoadEvalResponses evaluatoruserid=' + evaluatoruser.Id);

            // The following is TEST DATA captured from a live test each part is delimited by a line return
 
            // CHANGE DATA TO LOCAL DATA FOR TEST IN OTHER APPS  
            String responseString = '';
            responseString = responseString + 'evaluatorname=' + evaluatorcontact.name + '\n';
            responseString = responseString + 'evaluatoruserid=' + evaluatoruser.Id + '\n';
            responseString = responseString + 'evaluatorcontactid=' + evaluatorcontact.Id + '\n';
            responseString = responseString + 'evalueeid=' + evalueecontact.Id + '\n';
            responseString = responseString + 'evaluationtype=CHIEF JUDGE\n';
            responseString = responseString + 'questionnairedatetime=' + evalregatta.START_DATE__C.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\n';
            responseString = responseString + 'evaluationlocation=' + evalregatta.name + '\n';
            responseString = responseString + 'evaluationdate=' + evalregatta.START_DATE__C.format('yyyy-MM-dd') + '\n';
            responseString = responseString + 'evaluatorcomment=test evaluation\n';
            responseString = responseString + 'CJ1_1~CJ1_1^Personal equipment  [Meets Standard]-1\n';
            responseString = responseString + 'CJ1_2~CJ1_2^Position setup  [Meets Standard]-1\n';
            responseString = responseString + 'CJ1_3~CJ1_3^Awareness of regatta; specific procedures, schedules, and crews  [Not Observed]-3\n';
            responseString = responseString + 'CJ5_4~CJ5_4^Overall Evaluation  [Fully Competent]-1';
            System.debug('testInsertResponses Test data appears as:\n' + responseString);

            String EvaluatorUserId;
            String EvaluatorContactId;
            String EvalueeId;
            String EvaluationType;
            String EvaluationLocation;
            String EvaluationDate;
            String EvaluatorComment;
            String QuestionnaireDateTime;
            String QuestionnaireId;

            System.debug('testInsertResponses:\n' + responseString);
            String[] responses = responseString.split('\n');

            Evaluation_Responses__c erlast = new Evaluation_Responses__c();
            
            String querystmt1 = 'Select Id, Name from Contact where Id = \'' + evalueecontact.Id + '\'';
            System.debug(querystmt1);
            Contact ee1 = Database.query(querystmt1);
            System.debug('LoadEvalResponses test1 evaluee Id'+ ee1.Id + ' / ' + evalueecontact.Id );        


            Integer ctr = 0;
            try {

                // begin responses for loop
                for (String resp: responses) {
                    if (resp.contains('evaluatoruserid')) {
                        EvaluatorUserId = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evaluatorcontactid')) {
                        EvaluatorContactId = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evalueeid')) {
                        EvalueeId = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evaluationtype')) {
                        EvaluationType = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evaluationlocation')) {
                        EvaluationLocation = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evaluationdate')) {
                        EvaluationDate = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('questionnairedatetime')) {
                        QuestionnaireDateTime = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('evaluatorcomment')) {
                        EvaluatorComment = resp.substring(resp.indexOf('=') + 1);
                    } else if (resp.contains('~')) {

                        System.debug('testInsertRespones - parse evalueeid = ' + EvalueeId);

                        String[] rsp = resp.split('~');
                        String EvaluationQuestionNum = rsp[0];
                        String[] rrsp = rsp[1].split('-');
                        String EvaluationRating = rrsp[1];

                        System.debug('testInsertResponses - lookup Question_Number__c ' + EvaluationQuestionNum);

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
                            from Evaluation_Questions__c WHERE Question_Number__c =: EvaluationQuestionNum
                        ];

                        System.debug('testInsertResponses - Questions returned = ' + EvaluationQuestionId.size());

                        System.debug('testInsertResponses Common values: ' +
                            '\n\tEvaluatorUserId=' + EvaluatorUserId +
                            '\n\tEvaluatorContactId=' + EvaluatorContactId +
                            '\n\tEvalueeId=' + EvalueeId +
                            '\n\tEvaluationQuestionNum=' + EvaluationQuestionNum +
                            '\n\tEvaluationType=' + EvaluationType +
                            '\n\tEvaluationRating=' + EvaluationRating);

                        Evaluation_Responses__c er = new Evaluation_Responses__c();

                        er.Evaluation_Date__c = date.valueOf(EvaluationDate);

                        //system.debug(logginglevel.debug,'String QuestionnaireDatetime = '+ QuestionnaireDateTime );
                        // THIS WAS A VERY TRICKY ONE - NORMAL PARSE AND VALUEOF DID NOT WORK
                        er.Questionnaire_DateTime__c = (DateTime) JSON.deserialize('"' + QuestionnaireDateTime + '"', DateTime.class);
                        //system.debug(logginglevel.debug,'Parsed QuestionnaireDatetime = ' + er.Questionnaire_DateTime__c);

                        System.debug('testInsertResponses genQuestionnaireID using [' + er.Questionnaire_DateTime__c + '] ' + EvalueeId);
                        if (String.isEmpty(QuestionnaireId)) {
                            QuestionnaireId = EvaluationQuestionsController.genQuestionnaireID(er.Questionnaire_DateTime__c, EvalueeId);
                        }
                        er.Questionnaire_Id__c = QuestionnaireId;
                        System.debug('testInsertResponses genQuestionnaireID = [' + er.Questionnaire_Id__c + '] ');

                        if (EvaluationLocation == null || EvaluationLocation.length() == 0)
                            er.Evaluation_Location__c = 'Location omitted';
                        else
                            er.Evaluation_Location__c = EvaluationLocation;
                        er.Evaluation_Type__c = EvaluationQuestionId[0].Evaluation_Type__c;
                        er.Question_Number__c = EvaluationQuestionId[0].Question_Number__c; // EvaluationQuestionNum;
                        er.Question_Text__c = EvaluationQuestionId[0].Question_Text__c;
                        er.Question_Type__c = EvaluationQuestionId[0].QuestionType__r.Name;
                        er.Question_Id__c = EvaluationQuestionId[0].ID; // EvaluationQuestionNum;
                        er.Evaluation_Rating__c = EvaluationRating;
                        if (EvaluationRating == '1') {
                            er.Evaluation_Rating_Text__c = EvaluationQuestionId[0].QuestionType__r.Response_Text_1__c;
                        }
                        if (EvaluationRating == '2') {
                            er.Evaluation_Rating_Text__c = EvaluationQuestionId[0].QuestionType__r.Response_Text_2__c;
                        }
                        if (EvaluationRating == '3') {
                            er.Evaluation_Rating_Text__c = EvaluationQuestionId[0].QuestionType__r.Response_Text_3__c;
                        }
                        /*
                        if (EvaluationQuestionId[0].QuestionType__r.Name.contains('Overall')) {
                            er.Evaluator_Comment__c = EvaluatorComment;
                        } else {
                            er.Evaluator_Comment__c = '';
                        }
                        */
                        er.Evaluee_Id__c = Id.valueOf(EvalueeId);
                        er.Evaluator_User_Id__c = Id.valueOf(EvaluatorUserId);
                        er.Evaluator_Id__c = Id.valueOf(EvaluatorContactId);
                        
                        Contact evaluatorcnt = [Select id from Contact where Id =: evaluatorcontact.id];
                        System.debug('LoadEvalResponses evaluator Id '+ evaluatorcnt.Id + ' / ' + evaluatorcontact.id );

                        String querystmt = 'Select Id, Name from Contact where Id = \'' + evalueecontact.Id + '\'';
                        System.debug(querystmt);
                        Contact ee = Database.query(querystmt);
                        System.debug('LoadEvalResponses evaluee Id'+ ee.Id + ' / ' + evalueecontact.Id );        

                        Integer cnt = [Select count() from Evaluation_Responses__c WHERE Questionnaire_Id__c =: er.Questionnaire_Id__c];
                        System.debug('LoadEvalResponses - current related responses = ' + cnt);

                        System.debug('testInsertResponses  Inserting Response:' +
                            '\n\tEvaluation_Date__c: ' + er.Evaluation_Date__c + 
                            '\n\tQuestionnaire_DateTime__c: ' +  er.Questionnaire_DateTime__c +
                            '\n\tQuestionnaire_Id__c: ' + er.Questionnaire_Id__c +
                            '\n\tEvaluation_Location__c: ' + er.Evaluation_Location__c +
                            '\n\tEvaluation_Type__c: ' + er.Evaluation_Type__c +
                            '\n\tQuestion_Number__c: ' + er.Question_Number__c +
                            '\n\tQuestion_Text__c: ' + er.Question_Text__c +
                            '\n\tQuestion_Type__c: ' + er.Question_Type__c +  
                            '\n\tQuestion_Id__c: ' + er.Question_Id__c +
                            '\n\tEvaluation_Rating__c: ' + er.Evaluation_Rating__c +
                            '\n\tEvaluation_Rating_Text__c: ' + er.Evaluation_Rating_Text__c +
                            '\n\tEvaluator_Comment__c: ' + er.Evaluator_Comment__c +
                            '\n\tEvaluator_User_Id__c: ' + er.Evaluator_User_Id__c +
                            '\n\tEvaluator_Id__c: ' +er.Evaluator_Id__c +
                            '\n\tEvaluee_Id__c: ' + er.Evaluee_Id__c

                        );
                        erlast = er;
                        ctr++;
                        //if(Test.isRunningTest()) {
                        //      System.debug('insertResponses - In test skipping actual insert');
                        //} else {
                            insert er;

                        //}
                        System.debug('testInsertResponses - insert ' + ctr + ' completed');
                    } // end if resp.contains('~')  
                } // end end responses for loop
                System.debug('testInsertResponses - Insert responses to Evaluation Responses complete - Insert to Evaluation ResponsesAbstract follows');

                Evaluation_Responses__c[] evalresps = [SELECT Question_Id__c, Question_Number__c, Question_Text__c, Question_type__c,
                    Questionnaire_Id__c, Evaluation_Rating__c, Evaluation_Rating_Text__c, Evaluator_Comment__c
                    FROM Evaluation_Responses__c WHERE Questionnaire_Id__c =: QuestionnaireId
                ];

                System.debug('testInsertResponses - ' + evalresps.size() + ' Evaluation_Responses__c rows associated with QuestionnaireId ' + QuestionnaireId);
                
                Evaluation_ResponsesAbstract__c rr = new Evaluation_ResponsesAbstract__c();

                rr.Questionnaire_DateTime__c = (DateTime) JSON.deserialize('"' + QuestionnaireDateTime + '"', DateTime.class);
                rr.Questionnaire_Id__c = QuestionnaireId;
                rr.Evaluee_Id__c = EvalueeId;
                rr.Evaluation_Date__c = date.valueOf(EvaluationDate);
                rr.Evaluation_Location__c = EvaluationLocation;
                rr.Evaluator_User_Id__c = EvaluatorUserId;
                rr.Evaluator_Id__c = EvaluatorContactId;
                rr.Evaluation_Type__c = EvaluationType;

                System.debug('testInsertResponses Evaluation ResponsesAbstract:' +
                    '\n\tQuestionnaire_Id__c: ' + rr.Questionnaire_Id__c +
                    '\n\tEvaluation_Date__c: ' + rr.Evaluation_Date__c +
                    '\n\tEvaluation_Location__c: ' + rr.Evaluation_Location__c +
                    '\n\tEvalation_User_Id__c: ' + rr.Evaluator_User_Id__c +
                    '\n\tEvaluator_Id__c: ' + rr.Evaluator_Id__c +
                    '\n\rEvaluation_Type__c: ' + rr.Evaluation_Type__c
                );

                insert rr;

                Evaluation_ResponsesAbstract__c[] evalabstract = [SELECT Questionnaire_Id__c, Evaluation_Date__c, Evaluation_Location__c,
                    Evaluator_User_Id__c, Evaluator_Id__c, Evaluation_Type__c FROM Evaluation_ResponsesAbstract__c
                    WHERE Questionnaire_Id__c =: QuestionnaireId
                ];

                rQuestionnaireId = rr.Questionnaire_Id__c;

                System.debug('testInsertResponses - ' + evalabstract.size() + ' Evaluation_Responses__c rows associated with QuestionnaireId ' + QuestionnaireId);

                System.debug('testInsertResponses Insert to Evaluation ResponsesAbstract of Questionnaire Id ' + QuestionnaireId + ' completed');

                String rtr = EvaluatorContactId + ';' + EvalueeId + ';' + QuestionnaireId + ';' + EvaluationType;

                //return rtr;    

            } catch (Exception err) {
                String errMsg = err.getMessage();
                String errTrace = err.getStackTraceString();
                System.debug(LoggingLevel.ERROR, 'testInsertResponses Error: ' + errMsg);
                System.debug(LoggingLevel.ERROR, 'testInsertResponses StackTrace:\n' + errTrace);

                System.debug(LoggingLevel.DEBUG, 'testInsertResponses Exception Last Inserted Response Prior to error:' +
                    '\n\tQuestion_Id__c: ' + erlast.Question_Id__c +
                    '\n\tQuestion_Number__c: ' + erlast.Question_Number__c +
                    '\n\tQuestion_Text__c: ' + erlast.Question_Text__c +
                    '\n\tQuestion_Type__c: ' + erlast.Question_Type__c +
                    '\n\tQuestionnaire_Id__c: ' + erlast.Questionnaire_Id__c +
                    '\n\tEvaluation_Rating__c: ' + erlast.Evaluation_Rating__c +
                    '\n\tEvaluation_Rating_Text__c: ' + erlast.Evaluation_Rating_Text__c +
                    '\n\tEvaluator_Comment__c: ' + erlast.Evaluator_Comment__c
                );

                throw new AuraHandledException(err.getMessage());
            }
         } // End RunAs
      
        System.debug('LoadEvalResponses completed');
        System.debug('-------------------------------------------------------------------------');
    }


    public static String getTimeBasedId() {
        Long ts = DateTime.now().getTime();
        String timeBasedVal = ts + '';
        System.debug('timeBaseVal='+timeBasedVal);
        return timeBasedVal;
    }

// =======================================================================================

    @IsTest(SeeAllData = true)
    public static void testSetGlobalValues() {

        /*
            RefereeAssessment.cls RefereeAssesssmentVF() returns data through global values identified below.
            This test will confirm the values are all present and accessible.

         */
        System.debug('=================================================================================================');
        System.debug('RefereeAssessmentTest - Global tests to confirm global values appear within code');

        // globals should be null at start
        System.assertEquals(null, RefereeAssessment.EvaluatorId);
        System.assertEquals(null, RefereeAssessment.EvalueeId);
        System.assertEquals(null, RefereeAssessment.QuestionnaireId);
        System.assertEquals(null, RefereeAssessment.EvaluatorName);
        System.assertEquals(null, RefereeAssessment.EvalueeName);
        System.assertEquals(null, RefereeAssessment.EvaluationLocation);
        System.assertEquals(null, RefereeAssessment.EvaluationDate);
        System.assertEquals(null, RefereeAssessment.fmtEvaluationDate);
        System.assertEquals(null, RefereeAssessment.EvaluatorComment);
        System.assertEquals(null, RefereeAssessment.PositionEvaluated);

        // set globals     
        RefereeAssessment.EvaluatorId = 'test';
        RefereeAssessment.EvalueeId = 'test';
        RefereeAssessment.QuestionnaireId = 'test';
        RefereeAssessment.EvaluatorName = 'test';
        RefereeAssessment.EvalueeName = 'test';
        RefereeAssessment.EvaluationLocation = 'test';
        RefereeAssessment.EvaluationDate = DateTime.Now();
        RefereeAssessment.fmtEvaluationDate = 'test';
        RefereeAssessment.EvaluatorComment = 'test';
        RefereeAssessment.PositionEvaluated = 'test';

        // test globals - basically should be null
        System.assertEquals(null,RefereeAssessment.testEvaluatorcontact );
        System.assertEquals(null,RefereeAssessment.testEvalueecontact );
        System.assertEquals(null,RefereeAssessment.testEvalregatta );
        System.assertEquals(null,RefereeAssessment.testRegattaParticipation);
        System.assertEquals(null,RefereeAssessment.testPropFileNameFormat );

        System.assertEquals(null,RefereeAssessment.tstEvaluatorId );
        System.assertEquals(null,RefereeAssessment.tstEvalueeId );
        System.assertEquals(null,RefereeAssessment.tstQuestionnaireId );
        
        // confirm globals are set
        System.assertEquals('test', RefereeAssessment.EvaluatorId);
        System.assertEquals('test', RefereeAssessment.EvalueeId);
        System.assertEquals('test', RefereeAssessment.QuestionnaireId);
        System.assertEquals('test', RefereeAssessment.EvaluatorName);
        System.assertEquals('test', RefereeAssessment.EvalueeName);
        System.assertEquals('test', RefereeAssessment.EvaluationLocation);
        //RefereeAssessment.EvaluationDate = '';
        System.assertEquals('test', RefereeAssessment.fmtEvaluationDate);
        System.assertEquals('test', RefereeAssessment.EvaluatorComment);
        System.assertEquals('test', RefereeAssessment.PositionEvaluated);

        // re-init globals
        RefereeAssessment.EvaluatorId = '';
        RefereeAssessment.EvalueeId = '';
        RefereeAssessment.QuestionnaireId = '';
        RefereeAssessment.EvaluatorName = '';
        RefereeAssessment.EvalueeName = '';
        RefereeAssessment.EvaluationLocation = '';
        //RefereeAssessment.EvaluationDate = '';
        RefereeAssessment.fmtEvaluationDate = '';
        RefereeAssessment.EvaluatorComment = '';
        RefereeAssessment.PositionEvaluated = '';

        System.debug('RefereeAssessmentTest - Global tests completed');

    }

    @IsTest(SeeAllData = true)
    public static void testgetResponsesVF() {

        /*
            getResponsesVF - this method is AuraEnabled and is primarily used to test and resend existing assessments.
            Method Signature:
                void  getResponsesVF() 

            To preform this test we'll pull an existing record and load it to the globals available for testing (tst...)
            before calling the method

            The results of this test will appear in the global values
                public static String EvaluatorId {get; set;}
                public static String EvalueeId {get; set;}    
                public static String QuestionnaireId {get; set;}  
                
                public static String EvaluatorId {get; set;}
                public static String EvalueeId {get; set;}    
                public static String QuestionnaireId {get; set;}  
                public static String EvaluatorName {get; set;}
                public static String EvalueeName {get; set;}
                public static String EvaluationLocation {get; set;}
                public static DateTime EvaluationDate {get; set;}
                public static String fmtEvaluationDate {get; set;}
                public static String EvaluatorComment {get; set;}
                public static String PositionEvaluated {get; set;}

                public static Evaluation_Questions__c Synopsis {get; set;} 
                public static Evaluation_Questions__c SynopsisHeading {get; set;} 
                public static Evaluation_Questions__c Preface {get; set;} 
                
                public static List<Evaluation_Responses__c> responses {get; set;}

            Under normal operation these globals are gathered through getResponsesVF() for display 
            through RefereeAssessment.page 

        */
        System.debug('=============================================================================');
        System.debug('Begin testgetResponsesVF');

        Exception unexpectedException;
        try {

            if (rQuestionnaireId == null) {
                System.debug('evaluatoruser is null');
                LoadEvalResponses();
            }

            // Select a recently completed assessment from Evaluation_ResponsesAbstract__c - the returned evaluator id, evaluee id, 
            // and questionnaire Id will be used to complete parameters for getResponses 
            Evaluation_ResponsesAbstract__c[] er = [SELECT Evaluator_Id__c, Evaluee_Id__c, Questionnaire_Id__c, Evaluation_type__c
                FROM Evaluation_ResponsesAbstract__c where Questionnaire_Id__c =: rQuestionnaireId];

            System.debug('testgetResponsesVF - there are ' + er.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');
            if (er.size() > 0) {
                String pEvaluatorId = er[0].Evaluator_Id__c;
                String pEvalueeId = er[0].Evaluee_Id__c;
                String pQuestionnaireId = er[0].Questionnaire_Id__c;
                System.debug('testgetResponsesVF: ' +
                    '\npEvaluatorId=' + pEvaluatorId +
                    '\npEvalueeId=' + pEvalueeId +
                    '\npQuestionnaireId=' + pQuestionnaireId);
                // In normal use the app would pass as parameters - for testing they are passed as global values            
                RefereeAssessment.tstEvaluatorId = pEvaluatorId;
                RefereeAssessment.tstEvalueeId = pEvalueeId;
                RefereeAssessment.tstQuestionnaireId = pQuestionnaireId;

                RefereeAssessment.getResponsesVF();

                System.debug('testgetResponsesVF Rows returned = ' + RefereeAssessment.respCount);
                System.debug('testgetResponsesVF Evaluator: ' + RefereeAssessment.EvaluatorName);
                System.debug('testgetResponsesVF Evaluee: ' + RefereeAssessment.EvalueeName);
                System.debug('testgetResponsesVF Position Evaluated: ' + RefereeAssessment.PositionEvaluated);
                System.debug('testgetResponsesVF Evaluation Location: ' + RefereeAssessment.EvaluationLocation);
                System.debug('testgetResponsesVF Evaluation Date: ' + RefereeAssessment.fmtEvaluationDate);

                List < Evaluation_Responses__c > responses = RefereeAssessment.responses;
                System.debug('testgetResponsesVF  total responses to be formatted for report = ' + responses.size());

            } else {
                System.assert(er.size() > 0, 'testgetResponsesVF - no test data available');
            }

        } catch (Exception err) {
            System.debug('testgetResponsesVF err: ' + err.getMessage());
            System.debug('testgetResponsesVF stacktrace: ' + err.getStackTraceString());
            unexpectedException = err;
        }
        System.assertEquals(null, unexpectedException, 'testgetResponsesVF - Unexcepted to failure - review log');
        System.debug('Completed testgetResponsesVF - testing getResponses returned expected results');
        System.debug('=============================================================================');
    }


    @IsTest(SeeAllData = true)
    public static void testObjectAvailablity() {

        /*
            RefereeAssessment was created to support the generation of PDF reports in support of EvaluationQuestionsController.
            There are five object that all begin with 'Evaluation_'
            This will check to see if they are there and in some cases will check for data.

         */

        System.debug('=================================================================================================');
        System.debug('Begin testObjectAvailablity');
        String Evaluation_ResponsesAbstract = 'Evaluation_ResponsesAbstract__c';
        String Evaluation_Responses = 'Evaluation_Responses__c';
        String Evaluation_Questions = 'Evaluation_Questions__c';
        String Evaluation_Properties = 'Evaluation_Properties__c';
        String Evaluation_QuestionTypeResp = 'Evaluation_QuestionTypeResp__c';

        Exception expectedException;
        try {

            // Objects used by the method must be present to complete test
            // the following confirms objects are available 
            boolean existsEvaluation_ResponsesAbstract = false;
            boolean existsEvaluation_Responses = false;
            boolean existsEvaluation_Questions = false;
            boolean existsEvaluation_Properties = false;
            boolean existsEvaluation_QuestionTypeResp = false;

            FieldDefinition[] erafields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                where EntityDefinition.QualifiedApiName =: Evaluation_ResponsesAbstract
            ];

            integer fcnt = erafields.size();
            if (fcnt == 0) {
                existsEvaluation_ResponsesAbstract = false;
            } else {
                existsEvaluation_ResponsesAbstract = true;
            }

            FieldDefinition[] erfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                where EntityDefinition.QualifiedApiName =: Evaluation_Responses
            ];

            fcnt = erfields.size();
            if (fcnt == 0) {
                existsEvaluation_Responses = false;
            } else {
                existsEvaluation_Responses = true;
            }

            FieldDefinition[] eqfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                where EntityDefinition.QualifiedApiName =: Evaluation_Questions
            ];

            fcnt = eqfields.size();
            if (fcnt == 0) {
                existsEvaluation_Questions = false;
            } else {
                existsEvaluation_Questions = true;
            }

            FieldDefinition[] epfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                where EntityDefinition.QualifiedApiName =: Evaluation_Properties
            ];

            fcnt = epfields.size();
            if (fcnt == 0) {
                existsEvaluation_Properties = false;
            } else {
                existsEvaluation_Properties = true;
            }

            FieldDefinition[] eqtfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                where EntityDefinition.QualifiedApiName =: Evaluation_QuestionTypeResp
            ];

            fcnt = eqtfields.size();
            if (fcnt == 0) {
                existsEvaluation_QuestionTypeResp = false;
            } else {
                existsEvaluation_QuestionTypeResp = true;
            }

            // If any object is missing throw a fatal error and end this test
            if (!existsEvaluation_ResponsesAbstract) {
                System.assertNotEquals(true, existsEvaluation_ResponsesAbstract, 'testObjectAvailablity: missing object Evaluation Responses Abstract ');
            }
            if (!existsEvaluation_Responses) {
                System.assertNotEquals(true, existsEvaluation_Responses, 'testObjectAvailablity: missing object Evaluation Responses');
            }

            if (!existsEvaluation_Questions) {
                System.assertNotEquals(true, existsEvaluation_Responses, 'testObjectAvailablity: missing object Evaluation Questions');
            }

            if (!existsEvaluation_Properties) {
                System.assertNotEquals(true, existsEvaluation_Properties, 'testObjectAvailablity: missing object Evaluation Properties');
            }

            if (!existsEvaluation_QuestionTypeResp) {
                System.assertNotEquals(true, existsEvaluation_QuestionTypeResp, 'testObjectAvailablity: missing object Evaluation QuestionTypeResp');
            }

            Evaluation_Properties__c[] ep = [select Id from Evaluation_Properties__c];
            System.assert(0 != ep.size(), 'testObjectAvailablity - Evaluation Properties is empty - add properties');

            Evaluation_Questions__c[] eq = [select Id from Evaluation_Questions__c];
            System.assert(0 != eq.size(), 'testObjectAvailablity - Evaluation Questions is empty - add questions');

            Evaluation_QuestionTypeResp__c[] eqtr = [select Id from Evaluation_QuestionTypeResp__c];
            System.assert(0 != eqtr.size(), 'testObjectAvailablity - Evaluation QuestionTypeResp is empty - add response types');

            System.debug('testGetResponses - all objects found continue test');

        } catch (Exception err) {

        }
        System.debug('testObjectAvailablity complete');
    }

    @IsTest(SeeAllData = true)
    public static void testGetResponses() {

        /*
        getResponses - this method pulls responses of a completed assessment to create a PDF file.  The
        questionnaire allows some questions to be skipped.  If all questions weren't completed (skipped) it 
        adds the missed question with a default static response 'Not Selected' so that all questions are shown.
        Method Signature:
             List<Evaluation_Responses__c>  getResponses(
                String pEvaluatorId,  
                String pEvalueeId, 
                String pQuestionnaireId) 
        Return:
            List containing rows based upon object Evaluation_Responses__c

        Test should:
        1.  Locate a recently completed assessment of evaluation_type__c REFEREE - Evaluation ResponsesAbstract
        2.  Count associated responses - Evaluation Responses
        3.  Count questions based upon the type REFEREE
        4.  The returned list count should match the count of questions
        5.  The responses in the returned list should match defined responses - Evaluation_QuestionTypeResponse

         */

        System.debug('=================================================================================================');
        System.debug('Begin testGetResponses - testing getResponses');

        RefereeAssessment ra = new RefereeAssessment();
        Exception expectedException;
        try {

            if (rQuestionnaireId == null) {
                System.debug('testGetResponses - evaluatoruser is null');
                LoadEvalResponses();
            }
            System.debug('=================================================================================================');

            System.debug('testGetResponses - using Questionnaire_Id__c = ' + rQuestionnaireId);

            // Select a recently completed assessment from Evaluation_ResponsesAbstract__c - the returned evaluator id, evaluee id, 
            // and questionnaire Id will be used to complete parameters for getResponses 
            Evaluation_ResponsesAbstract__c[] er = [SELECT Evaluator_User_Id__c, Evaluee_Id__c, Questionnaire_Id__c, Evaluation_type__c
                FROM Evaluation_ResponsesAbstract__c where Questionnaire_Id__c =: rQuestionnaireId];
 

            System.debug('testGetResponses - there are ' + er.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');
            if (er.size() > 0) {
                String pEvaluatorId = er[0].Evaluator_User_Id__c; // Continue to use User ID
                String pEvalueeId = er[0].Evaluee_Id__c;
                String pQuestionnaireId = er[0].Questionnaire_Id__c;
                String erEvaluationType = er[0].evaluation_type__c;
                System.debug('testGetResponses: ' +
                    '\npEvaluatorId=' + pEvaluatorId +
                    '\npEvalueeId=' + pEvalueeId +
                    '\npQuestionnaireId=' + pQuestionnaireId +
                    '\nerEvaluationType=' + erEvaluationType);

                // Select count of responses associated with Questionnaire_Id__c found in Evaluation ResponsesAbstract
                integer erqidcnt = [SELECT count() FROM evaluation_responses__c WHERE Questionnaire_Id__c =: pQuestionnaireId];
                System.debug('testGetResponses found ' + erqidcnt + ' responses ');
                System.assertNotEquals(0, erqidcnt, 'testGetResponses - no responses matching pQuestionnaireId ' + pQuestionnaireId + ' were found');

                // Select count of questions associated with type  
                integer qcnt = [SELECT count() FROM evaluation_questions__c
                    where Question_Active__c = true
                    and evaluation_type__c =: erEvaluationType
                    and QuestionType__r.Name != 'PREFACE'
                    and QuestionType__r.Name != 'SYNOPSIS'
                ];
                System.debug('testGetResponses found ' + qcnt + ' questions associated with type');
                System.assertNotEquals(0, qcnt, 'testGetResponses - no questions matching ' + erEvaluationType + ' were found');

                // Now execute getResponses
                System.debug('testGetResponses method getResponses follows');
                List < Evaluation_Responses__c > rr = ra.getResponses(pEvaluatorId, pEvalueeId, pQuestionnaireId);
                System.debug('testGetResponses method getResponses returned ' + rr.size() + ' data rows');
                System.assertEquals(qcnt, rr.size(), 'testGetResponses - The number of returned responses does not equal the total number of questions');

                integer rr_cnt = 0; // rr.size();
                if (rr_cnt > 0) {
                    System.debug('testGetResponse contents to be used in PDF report');
                    for (integer i = 0; i < rr_cnt; i++) {
                        System.debug(rr[i].Question_Text__c);
                    }
                }
            } else {
                System.Assert(er.size() > 0, 'testGetResponses no data found in Evaluation ResponsesAbstract to test');
            }

        } catch (Exception err) {
            System.debug('testCreateFile err: ' + err);
            expectedException = err;
            system.assertNotEquals(null, expectedException, 'testGetResponse - Excepted to fail due to data');
        }
        System.debug('Completed testGetResponses - testing getResponses returned expected results');
        System.debug('=============================================================================');
    }

    @IsTest(SeeAllData = true)
    public static void testCreateFile() {

        /*
        createFile - this method creates and files a PDF document generated from VF Page RefereeAssessment output.
        This method is called from within EvaluationQuestionsController method generateRefAssessmentRPT.  The returned 
        ContentDocumentLink contains ContentDocumentId.  ContentDocumentId is used to select the document that will
        be sent to the evaluee via direct messsaging.
        NOTE - YOU CANNOT TEST .getContent FROM WITHIN A TEST METHOD - TESTS SIMULATE DOCUMENTS OR I'VE HAD TO BY-PASS TO COMPLETE TESTS
        Method Signature:
             ContentDocumentLink createFile(
                Id parentId, 
                Id linkedId, 
                String fileName, 
                Blob body, 
                String contentType) 
        Return:
            ContentDocumentLink
        
        This test should create 2 simple text documents.  The document will be stored and subsequently confirmed based 
		upon the returned ContentDocumentLink.

        */

        System.debug('=================================================================================================');
        System.debug('Begin RefereeAssessmentTest - testing createFile');

        Exception unexpectedException;

        RefereeAssessment ra = new RefereeAssessment();

        System.debug('testCreateFile Test 1 - Test will replicate file creation and storage logic in method');

        String AppAcct = EvaluationQuestionsController.getProp('AppName');
        Account acc = [SELECT Id FROM Account WHERE Name =: AppAcct]; // TODO:  WORKS BUT NEED MORE INFO
        String parentId = acc.Id;

        DateTime dtn = DateTime.now();
        String DT = dtn.format('yyyyMMddHHmmsss');
        String filename = 'TestDocument' + DT + '.txt';

        string UserId = UserInfo.getUserId();
        System.debug('testCreateFile UserId = ' + UserId);

        //Create Document
        System.debug('parentId = ' + parentId);
        System.debug('filename = ' + fileName);
        String bodyt1 = 'Test1 Content';
        System.debug('body = ' + bodyt1);

        //
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = 'Test Document';
        cv.PathOnClient = filename;
        cv.VersionData = Blob.valueOf(bodyt1);
        Insert cv;

        //Create ContentDocumentLink 
        System.debug('testCreateFile insert to ContentDocumentLink - LinkedEntityId = ' + parentId);
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id limit 1];
        ContentDocumentLink cdlt1 = New ContentDocumentLink();
        cdlt1.ContentDocumentId = cv.ContentDocumentId;
        cdlt1.LinkedEntityId = parentId; //acc.Id;
        cdlt1.shareType = 'V';
        Insert cdlt1;
        System.debug('testCreateFile  - ContentDocumentId = ' + cdlt1.ContentDocumentId);

        System.debug('testCreateFile Test 1 completed ContentDocumentLink ');

        System.debug('testCreateFile Test 2 - This test will confirm logic in method');

        ContentDocumentLink cdlt2 = New ContentDocumentLink();
        //parentId = UserId;

        Id linkedId = parentId;

        dtn = DateTime.now();
        DT = dtn.format('yyyyMMddHHmmsss');
        filename = 'Test2Document' + DT + '.txt';

        String testbody = 'Test2 Content';
        Blob body = Blob.valueOf(testbody);
        String contentType = 'text/plain';

        try {
            System.debug('parentId = ' + parentId);
            System.debug('linkedId = ' + linkedId);
            System.debug('filename = ' + fileName);
            System.debug('body = ' + body);
            System.debug('contenttype = ' + contentType);
            cdlt2 = ra.createFile(parentId, linkedId, fileName, body, contentType);

            System.debug('Test 2 completed - ContentDocumentId = ' + cdlt2.ContentDocumentId);

        } catch (Exception err) {
            System.debug('testCreateFile err: ' + err);
            unexpectedException = err;
        }
        system.assertEquals(null, unexpectedException, 'testCreateFile - unexcepted fail');

        System.debug('Completed RefereeAssessmentTest - testing createFile');
    }

    @IsTest(SeeAllData = true)
    public static void testSendDirectMessageNoContentDocumentId() {

        /*
            SendDirectMessage - this method creates and sends a chatter based direct message with an attachment
            Method Signature:
                void SendDirectMessage(
                    String EvalueeId,     - must be a contactId - message will be directed to this person's email and message box 
                    String EvalRptFileId) - this is the ContentDocumentLink Id of a document - in this case a PDF Assessment

            This will will use a known user's contact ID and a blank ContentDocumentLink Id

        */
        System.debug('=================================================================================================');
        System.debug('Begin testSendDirectMessageNoContentDocumentId ');

        if (evalueecontact == null) {
            System.debug('evalueecontact is null');
            LoadTestUserData();
        }
        System.debug('Get user Id next');
        //User evaluatorusr = [Select id from User where Id =: evaluatoruser.id];


        // Nomrally suggest randomly selecting a Referee ID - for now use developer's Id - regardless this will fail so no harm
        //Contact c = [SELECT id, name from contact where name like 'Michael Miller'
        //    limit 1
        //];
        RefereeAssessment ra = new RefereeAssessment();
        
        String EvalueeId = evalueecontact.Id;
        String EvalRptFileId = ''; // Alternately you could place any Id that is not a document
        Exception expectedException;
        System.debug('testSendDirectMessageNoContentDocumentId submitting p1=' + EvalueeId + ' p2=' + EvalRptFileId);
        try {
            ra.SendDirectMessage(EvalueeId, EvalRptFileId);
        } catch (Exception err) {
            System.debug('testSendDirectMessageNoData err: ' + err.getMessage());
            expectedException = err;
        }
        System.assertNotEquals(null, expectedException, 'testSendDirectMessageNoData should have thrown an exception related to document lookup');
        System.debug('testSendDirectMessageNoData completed');

    }

    @IsTest(SeeAllData = true)
    public static void testSendDirectMessageBadEvalueeId() {

        /*
            SendDirectMessage - this method creates and sends a chatter based direct message with an attachment
            Method Signature:
                void SendDirectMessage(
                    String EvalueeId,     - must be a contactId - message will be directed to this person's email and message box 
                    String EvalRptFileId) - this is the ContentDocumentLink Id of a document - in this case a PDF Assessment

            This will will use a bad EvalueId (User Id in place of Contact ID) and a blank ContentDocumentLink Id - the method 
            will throw an ApplicationException tied to a bad or missing Id

        */

        System.debug('=================================================================================================');
        System.debug('Begin testSendDirectMessageBadEvalueeId');

        RefereeAssessment ra = new RefereeAssessment();
        String EvalueeId = UserInfo.getUserId();
        String EvalRptFileId = '';
        Exception expectedException;
        System.debug('testSendDirectMessageBadEvalueeId submitting p1=' + EvalueeId + ' p2=' + EvalRptFileId);
        try {
            ra.SendDirectMessage(EvalueeId, EvalRptFileId);
        } catch (Exception err) {
            System.debug('testSendDirectMessageBadEvalueeId err: ' + err.getMessage());
            expectedException = err;
        }
        System.assertNotEquals(null, expectedException, 'testSendDirectMessageBadEvalueeId exception have thrown an exception related to the evaluee Id');
        System.debug('testSendDirectMessageBadEvalueeId completed');
    }

    @IsTest(SeeAllData = true)
    public static void testSendDirectMessage() {

        /*
            SendDirectMessage - this method creates and sends a chatter based direct message with an attachment
            Method Signature:
                void SendDirectMessage(
                    String EvalueeId,     - must be a contactId - message will be directed to this person's email and message box 
                    String EvalRptFileId) - this is the ContentDocumentLink Id of a document - in this case a PDF Assessment

            For this test we'll create a valid attachment document and send with known test user

        */
        System.debug('=================================================================================================');
        System.debug('Begin testSendDirectMessage');
        Exception unexpectedException;
        if (evalueecontact == null) {
            System.debug('evalueecontact is null');
            LoadTestUserData();
        }

        System.runAs(portalAccountOwner) {

            try {

                String EvalueeId = '';
                String EvalRptFileId = '';

                System.debug('testSendDirectMessage - Step 1 obtain a known contact to use as EvlaueeId');



                //Contact c = [SELECT id, name from contact where name like 'Michael Miller'
                //    limit 1
                //]; // TODO: make Name a prop
                EvalueeId = evalueecontact.Id;  // c.Id;
                System.assert(String.isNotEmpty(EvalueeId), 'testSendDirectMessage unable to get a contact Id for our test user');

                System.debug('testSendDirectMessage - Step 2 create a test document to send using method createFile');

                String AppAcct = EvaluationQuestionsController.getProp('AppName');
                Account acc = [SELECT Id FROM Account WHERE Name =: AppAcct]; // TODO:  WORKS BUT NEED MORE INFO
                String parentId = acc.Id;

                ContentDocumentLink cdl = New ContentDocumentLink();

                Id linkedId = parentId;

                DateTime dtn = DateTime.now();
                String DT = dtn.format('yyyyMMddHHmmsss');
                String filename = 'TestSendDirectMsgDocument' + DT + '.txt';

                String testbody = 'Test SendDirectMessage content created ' + DT;
                Blob body = Blob.valueOf(testbody);
                String contentType = 'text/plain';

                RefereeAssessment ra = new RefereeAssessment();

                System.debug('parentId = ' + parentId);
                System.debug('linkedId = ' + linkedId);
                System.debug('filename = ' + fileName);
                System.debug('body = ' + body);
                System.debug('contenttype = ' + contentType);
                cdl = ra.createFile(parentId, linkedId, fileName, body, contentType);

                EvalRptFileId = cdl.ContentDocumentId;
                System.assert(String.isNotEmpty(EvalRptFileId), 'testSendDirectMessage unable to get a ContentDocumentId for our test user');

                System.debug('testSendDirectMessage - Step 3 call ');

                ConnectAPI.FeedElement fi_rtr = ra.SendDirectMessage(EvalueeId, EvalRptFileId);

                String rtrbody = fi_rtr.Body.toString();

                System.debug('testSendDirectMessage - returned body: [' + rtrbody + ']');
                System.assert(!rtrbody.contains(testbody), 'testSendDirectMessage the returned FeedElement does not contain the message body');

                //ConnectApi.ChatterFeeds.

            } catch (Exception err) {
                System.debug('testSendDirectMessage err: ' + err);
                unexpectedException = err;
            }
        }
        system.assertEquals(null, unexpectedException, 'testSendDirectMessage - unexcepted fail');

        System.debug('Completed testSendDirectMessage - testing createFile');
    }

    @IsTest(SeeAllData = true)
    public static void testGenerateRefAssessmentRPT() {

        System.debug('=================================================================================================');
        System.debug('in testGenerateRefAssessmentRPT');

        if (rQuestionnaireId == null) {
            System.debug('evaluatoruser is null');
            LoadEvalResponses();
        }
        Exception unExpectedException;
    System.runAs(portalAccountOwner) {

        System.debug('testGenerateRefAssessmentRPT - Step 1 - pull data from a previous assessment Db for our test');
        Evaluation_ResponsesAbstract__c[] era = [SELECT Evaluator_Id__c, Evaluator_Id__r.Name,
            Evaluee_Id__c, Evaluee_Id__r.Name,
            Evaluation_Location__c,
            Questionnaire_Id__c,
            Evaluation_type__c
            from Evaluation_ResponsesAbstract__c  Evaluation_ResponsesAbstract__c where Questionnaire_Id__c =: rQuestionnaireId];

        System.debug('testGenerateRefAssessmentRPT - records available ' + era.size());
        if (era.size() == 0) {
            System.assertNotEquals(0, era.size(), 'testGenerateRefAssessmentRPT - no data available');
        }
        System.debug('testGetResponses - there are ' + era.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');

        String pEvaluatorId = era[0].Evaluator_Id__c;
        String pEvalueeId = era[0].Evaluee_Id__c;
        String pQuestionnaireId = era[0].Questionnaire_Id__c;
        String erEvaluationType = era[0].evaluation_type__c;
        String pEvaluee = era[0].Evaluee_Id__r.Name;
        String pPosition = era[0].Evaluation_Type__c;
        String pLocation = era[0].Evaluation_Location__c;

        System.debug('testGetResponses - generateRefAssessment EvaluatorId: ' + pEvaluatorId);
        System.debug('testGetResponses - generateRefAssessment EvalueeId: ' + pEvalueeId);
        System.debug('testGetResponses - generateRefAssessment Evaluee: ' + pEvaluee);
        System.debug('testGetResponses - generateRefAssessment Position: ' + pPosition);
        System.debug('testGetResponses - generateRefAssessment Location: ' + pLocation);
        System.debug('testGetResponses - generateRefAssessment QuestionnaireId: ' + pQuestionnaireId);

        System.debug('testGenerateRefAssessmentRPT - Step 2 - pull data we can use to exercise methods RefereeAssessment');

        // TEST SWITCHES
        boolean wrapWithApex = true;
        boolean outputPDF = true;
        boolean outputHTML = false;

        RefereeAssessment ra = new RefereeAssessment();

        DateTime dt = DateTime.now();
        String dateStr = dt.format('MMdd-HHmm-SS');

        Account acc = [SELECT Id FROM Account WHERE Id = '0016A00000K77C4QAJ']; // TODO:  WORKS BUT NEED MORE INFO
        String parentId = acc.Id;
        Contact c = [select Id, email, OwnerId from contact where id =: pEvalueeId];
        String linkedId = c.OwnerId;
        String evaluee_email = c.Email;

        // System.debug('RefereeAssessment ouputPDF');
        //         System.debug('generateRefAssessment QuestionnaireId: ' + pQuestionnaireId);

        System.debug('testGenerateRefAssessmentRPT - Step 3 - create a filename we can use');

        String filename = EvaluationQuestionsController.FormatFileNameFromProps(pEvaluee, pLocation, pPosition, pQuestionnaireId);
        if (filename.length() < 1)
            fileName = 'RA_' + dateStr + '-' + pQuestionnaireId + '.pdf';
        System.debug('testGetResponses - filename from props ' + filename);

        System.debug('testGenerateRefAssessmentRPT - Step 4 - create a PDF document');

        PageReference pageReferenceForPDF = Page.RefereeAssessment;

        Test.setCurrentPage(pageReferenceForPDF);
        pageReferenceForPDF.getParameters().put('testGetResponses pEvaluatorId', pEvaluatorId);
        pageReferenceForPDF.getParameters().put('testGetResponses pEvalueeId', pEvalueeId);
        pageReferenceForPDF.getParameters().put('testGetResponses pQuestionnaireId', pQuestionnaireId);

        // CANNOT TEST getContent - Error System.VisualforceException: Methods defined as TestMethod do not support getContent call
        Blob body = blob.valueOf('Unit.Test');
        String contentType = 'application/pdf';

        //System.debug('RefereeAssessment createFile follows'); 
        ContentDocumentLink rptfile = ra.createFile(parentId, linkedId, fileName, body, contentType);
        System.debug('testGenerateRefAssessmentRPT - ContentDocumentLink returned by createFile = ' + rptfile.ContentDocumentId);

        System.debug('testGenerateRefAssessmentRPT - Step 5 - now create a message with the document');

        try {
            ra.SendDirectMessage(pEvalueeId, rptfile.ContentDocumentId);
        } catch (Exception err) {
            System.debug('testGenerateRefAssessmentRPT - local methods -  error: ' + err.getMessage());
            System.debug(err.getStackTraceString());
            System.debug('----------------------------------------------');
            unExpectedException = err;
        }
        system.assertEquals(null, unExpectedException, 'testGenerateRefAssessmentRPT should not throw exception');

        System.debug('testGenerateRefAssessmentRPT - Step 6 - Now exercise RefereeAssessmethod methods through EvaluationQuestionsController');

        try {
            EvaluationQuestionsController.generateRefAssessmentRPT(pEvaluatorId, pEvalueeId, pQuestionnaireId,
                pEvaluee, pLocation, pPosition);
            System.debug('testGenerateRefAssessmentRPT - Step 6 completed');

        } catch (Exception err) {
            System.debug('testGenerateRefAssessmentRPT EvaluationQuestionsController error: ' + err.getMessage());
            System.debug(err.getStackTraceString());
            System.debug('----------------------------------------------');
            unExpectedException = err;
        }

    }

        system.assertEquals(null, unExpectedException, 'testGenerateRefAssessmentRPT should not throw exception');

        System.debug('testGenerateRefAssessmentRPT Referee Assessment completed');
    }

}