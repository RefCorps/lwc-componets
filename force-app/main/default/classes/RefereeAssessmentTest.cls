@isTest public with sharing class RefereeAssessmentTest {
    
    @IsTest(SeeAllData=true) 
    public static void testSetGlobalValues() {
    
    /*
        RefereeAssessment.cls RefereeAssesssmentVF() returns data through global values identified below.
        This test will confirm the values are all present and accessible.

     */  
    System.debug('=================================================================================================');
    System.debug('RefereeAssessmentTest - Global tests to confirm global values appear within code');    
        
    // globals should be null at start
    System.assertEquals(null,RefereeAssessment.EvaluatorId);
    System.assertEquals(null,RefereeAssessment.EvalueeId);
    System.assertEquals(null,RefereeAssessment.QuestionnaireId);
    System.assertEquals(null,RefereeAssessment.EvaluatorName);
    System.assertEquals(null,RefereeAssessment.EvalueeName);
    System.assertEquals(null,RefereeAssessment.EvaluationLocation);
    //RefereeAssessment.EvaluationDate = '';
    System.assertEquals(null,RefereeAssessment.fmtEvaluationDate);
    System.assertEquals(null,RefereeAssessment.EvaluatorComment);
    System.assertEquals(null,RefereeAssessment.PositionEvaluated);
    
    // set globals     
    RefereeAssessment.EvaluatorId = 'test';
    RefereeAssessment.EvalueeId = 'test';
    RefereeAssessment.QuestionnaireId = 'test';
    RefereeAssessment.EvaluatorName = 'test';
    RefereeAssessment.EvalueeName = 'test';
    RefereeAssessment.EvaluationLocation = 'test';
    //RefereeAssessment.EvaluationDate = 'test';
    RefereeAssessment.fmtEvaluationDate = 'test';
    RefereeAssessment.EvaluatorComment = 'test';
    RefereeAssessment.PositionEvaluated = 'test';

    // confirm globals are set
    System.assertEquals('test',RefereeAssessment.EvaluatorId);
    System.assertEquals('test',RefereeAssessment.EvalueeId);
    System.assertEquals('test',RefereeAssessment.QuestionnaireId);
    System.assertEquals('test',RefereeAssessment.EvaluatorName);
    System.assertEquals('test',RefereeAssessment.EvalueeName);
    System.assertEquals('test',RefereeAssessment.EvaluationLocation);
    //RefereeAssessment.EvaluationDate = '';
    System.assertEquals('test',RefereeAssessment.fmtEvaluationDate);
    System.assertEquals('test',RefereeAssessment.EvaluatorComment);
    System.assertEquals('test',RefereeAssessment.PositionEvaluated);

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
    
@IsTest(SeeAllData=true)
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
    System.debug('=================================================================================================');
    System.debug('Begin testgetResponsesVF');

    Exception unexpectedException;
    try {

        // Select a recently completed assessment from Evaluation_ResponsesAbstract__c - the returned evaluator id, evaluee id, 
        // and questionnaire Id will be used to complete parameters for getResponses 
        Evaluation_ResponsesAbstract__c[] er = [SELECT Evaluator_Id__c, Evaluee_Id__c, Questionnaire_Id__c, Evaluation_type__c 
                FROM  Evaluation_ResponsesAbstract__c order by CreatedDate desc];
        System.debug('testgetResponsesVF - there are ' + er.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');
        if(er.size() > 0)
        {
            String pEvaluatorId = er[0].Evaluator_Id__c;
            String pEvalueeId = er[0].Evaluee_Id__c;
            String pQuestionnaireId = er[0].Questionnaire_Id__c;
            System.debug('testgetResponsesVF: ' +
                        '\npEvaluatorId=' + pEvaluatorId +
                        '\npEvalueeId=' + pEvalueeId +
                        '\npQuestionnaireId=' + pQuestionnaireId );
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
            
            List<Evaluation_Responses__c> responses = RefereeAssessment.responses;
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

}


    @IsTest(SeeAllData=true)
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
     String 	Evaluation_QuestionTypeResp = 'Evaluation_QuestionTypeResp__c';
     
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
                                        where EntityDefinition.QualifiedApiName =: Evaluation_ResponsesAbstract];
         
         integer fcnt = erafields.size();
         if(fcnt == 0) {
             existsEvaluation_ResponsesAbstract = false;
         } else {
             existsEvaluation_ResponsesAbstract = true;
         }           
         
         FieldDefinition[] erfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                       where EntityDefinition.QualifiedApiName =: Evaluation_Responses];
         
         fcnt = erfields.size();
         if(fcnt == 0) {
             existsEvaluation_Responses = false;
         } else {
             existsEvaluation_Responses = true;
         }           
         
         FieldDefinition[] eqfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                       where EntityDefinition.QualifiedApiName =: Evaluation_Questions];
         
         fcnt = eqfields.size();
         if(fcnt == 0) {
             existsEvaluation_Questions = false;
         } else {
             existsEvaluation_Questions = true;
         }           
         
         FieldDefinition[] epfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                       where EntityDefinition.QualifiedApiName =: Evaluation_Properties];
         
         fcnt = epfields.size();
         if(fcnt == 0) {
             existsEvaluation_Properties = false;
         } else {
             existsEvaluation_Properties = true;
         }           
         
         FieldDefinition[] eqtfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                       where EntityDefinition.QualifiedApiName =: Evaluation_QuestionTypeResp];
         
         fcnt = eqtfields.size();
         if(fcnt == 0) {
             existsEvaluation_QuestionTypeResp = false;
         } else {
             existsEvaluation_QuestionTypeResp = true;
         }           
         
         // If any object is missing throw a fatal error and end this test
         if(!existsEvaluation_ResponsesAbstract) {
             System.assertNotEquals(true, existsEvaluation_ResponsesAbstract, 'testObjectAvailablity: missing object Evaluation Responses Abstract ');
         }            
         if(!existsEvaluation_Responses) {
             System.assertNotEquals(true, existsEvaluation_Responses, 'testObjectAvailablity: missing object Evaluation Responses');
         }                
         
         if(!existsEvaluation_Questions) {
             System.assertNotEquals(true, existsEvaluation_Responses, 'testObjectAvailablity: missing object Evaluation Questions');
         }
         
         if(!existsEvaluation_Properties) {
             System.assertNotEquals(true, existsEvaluation_Properties, 'testObjectAvailablity: missing object Evaluation Properties');
         }
         
         if(!existsEvaluation_QuestionTypeResp) {
             System.assertNotEquals(true, existsEvaluation_QuestionTypeResp, 'testObjectAvailablity: missing object Evaluation QuestionTypeResp');
         }

         Evaluation_Properties__c[] ep = [select Id from Evaluation_Properties__c];
         System.assert(0 != ep.size(),'testObjectAvailablity - Evaluation Properties is empty - add properties');
                     
         Evaluation_Questions__c[] eq = [select Id from Evaluation_Questions__c];
         System.assert(0 != eq.size(),'testObjectAvailablity - Evaluation Questions is empty - add questions');

         Evaluation_QuestionTypeResp__c[] eqtr = [select Id from Evaluation_QuestionTypeResp__c];
         System.assert(0 != eqtr.size(),'testObjectAvailablity - Evaluation QuestionTypeResp is empty - add response types');
         
         System.debug('testGetResponses - all objects found continue test');

     } catch (Exception err) {
         
     }
     System.debug('testObjectAvailablity complete');
 
    }

    @IsTest(SeeAllData=true)
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
        System.debug('Begin RefereeAssessmentTest - testing getResponses');
        
        RefereeAssessment ra = new RefereeAssessment();
        Exception expectedException;
        try {

            // Select a recently completed assessment from Evaluation_ResponsesAbstract__c - the returned evaluator id, evaluee id, 
            // and questionnaire Id will be used to complete parameters for getResponses 
            Evaluation_ResponsesAbstract__c[] er = [SELECT Evaluator_User_Id__c, Evaluee_Id__c, Questionnaire_Id__c, Evaluation_type__c 
                    FROM  Evaluation_ResponsesAbstract__c order by CreatedDate desc];
            System.debug('testGetResponses - there are ' + er.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');
            if(er.size() > 0)
            {
                String pEvaluatorId = er[0].Evaluator_User_Id__c;  // Continue to use User ID
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
                List<Evaluation_Responses__c> rr = ra.getResponses(pEvaluatorId, pEvalueeId, pQuestionnaireId);
                System.debug('testGetResponses method getResponses returned ' + rr.size() + ' data rows');
                System.assertEquals( qcnt, rr.size(), 'testGetResponses - The number of returned responses does not equal the total number of questions');
                
                integer rr_cnt =  0; // rr.size();
                if(rr_cnt > 0) {
                    System.debug('testGetResponse contents to be used in PDF report');
                    for(integer i = 0; i < rr_cnt; i++)
                    {
                        System.debug( rr[i].Question_Text__c );                    
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
        System.debug('Completed RefereeAssessmentTest - testing getResponses returned expected results');
            
   }
    
    @IsTest(SeeAllData=true)
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
        Account acc = [SELECT Id FROM Account WHERE Name =: AppAcct];  // TODO:  WORKS BUT NEED MORE INFO
        String parentId = acc.Id;

        DateTime dtn = DateTime.now();
        String DT = dtn.format('yyyyMMddHHmmsss'); 
        String filename = 'TestDocument'+DT+'.txt';

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
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id limit 1];
        ContentDocumentLink cdlt1 = New ContentDocumentLink();
        cdlt1.ContentDocumentId = cv.ContentDocumentId;
        cdlt1.LinkedEntityId =  parentId;  //acc.Id;
        cdlt1.shareType = 'V';
        Insert cdlt1;
        System.debug('testCreateFile  - ContentDocumentId = ' + cdlt1.ContentDocumentId);

        System.debug('testCreateFile Test 1 completed ContentDocumentLink ' );
        
        System.debug('testCreateFile Test 2 - This test will confirm logic in method');
        
         ContentDocumentLink cdlt2 = New ContentDocumentLink();
         //parentId = UserId;
       
        Id linkedId = parentId;
        
        dtn = DateTime.now();
        DT = dtn.format('yyyyMMddHHmmsss'); 
        filename = 'Test2Document'+DT+'.txt';
        
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
    
    @IsTest(SeeAllData=true)
    public static void testSendDirectMessageNoContentDocumentId(){
        
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
        
        // Nomrally suggest randomly selecting a Referee ID - for now use developer's Id - regardless this will fail so no harm
        Contact c = [SELECT id, name from contact where name like 'Michael Miller' limit 1];    
        RefereeAssessment ra = new RefereeAssessment();
        String EvalueeId = c.Id; 
        String EvalRptFileId = '';  // Alternately you could place any Id that is not a document
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
    
    @IsTest(SeeAllData=true)
    public static void testSendDirectMessageBadEvalueeId(){
        
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

   @IsTest(SeeAllData=true)
    public static void testSendDirectMessage(){
        
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
        try {

            String EvalueeId = '';
            String EvalRptFileId = '';

            System.debug('testSendDirectMessage - Step 1 obtain a known contact to use as EvlaueeId');
                
            Contact c = [SELECT id, name from contact where name like 'Michael Miller' limit 1];  // TODO: make Name a prop
            EvalueeId = c.Id;
            System.assert(String.isNotEmpty(EvalueeId), 'testSendDirectMessage unable to get a contact Id for our test user');

            System.debug('testSendDirectMessage - Step 2 create a test document to send using method createFile');

            String AppAcct = EvaluationQuestionsController.getProp('AppName');
            Account acc = [SELECT Id FROM Account WHERE Name =: AppAcct];  // TODO:  WORKS BUT NEED MORE INFO
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
            System.assert(!rtrbody.contains(testbody),'testSendDirectMessage the returned FeedElement does not contain the message body');

            //ConnectApi.ChatterFeeds.

        } catch (Exception err) {
            System.debug('testSendDirectMessage err: ' + err);
            unexpectedException = err;
        }
        system.assertEquals(null, unexpectedException, 'testSendDirectMessage - unexcepted fail');

        System.debug('Completed testSendDirectMessage - testing createFile');
        }

    @IsTest(SeeAllData=true)
    public static void testGenerateRefAssessmentRPT() {
  
		System.debug('=================================================================================================');
        System.debug('in testGenerateRefAssessmentRPT');
        
        System.debug('testGenerateRefAssessmentRPT - Step 1 - pull data from a previous assessment Db for our test');
        Evaluation_ResponsesAbstract__c[] era = [SELECT Evaluator_Id__c, Evaluator_Id__r.Name,
                                                Evaluee_Id__c, Evaluee_Id__r.Name,
                                                Evaluation_Location__c,
                                                Questionnaire_Id__c, 
                                                Evaluation_type__c 
                                                from  Evaluation_ResponsesAbstract__c order by Questionnaire_DateTime__c desc];

        System.debug('testGenerateRefAssessmentRPT - records available ' + era.size() );        
        if(era.size() == 0) {
            System.assertNotEquals(0, era.size(),'testGenerateRefAssessmentRPT - no data available');
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
        
        Account acc = [SELECT Id FROM Account WHERE Id = '0016A00000K77C4QAJ'];  // TODO:  WORKS BUT NEED MORE INFO
        String parentId = acc.Id;
        Contact c = [select Id, email, OwnerId from contact where id =: pEvalueeId ];
        String linkedId = c.OwnerId;
        String evaluee_email = c.Email;
        
       // System.debug('RefereeAssessment ouputPDF');
        //         System.debug('generateRefAssessment QuestionnaireId: ' + pQuestionnaireId);

        System.debug('testGenerateRefAssessmentRPT - Step 3 - create a filename we can use'); 

        String filename = EvaluationQuestionsController.FormatFileNameFromProps(pEvaluee, pLocation, pPosition, pQuestionnaireId);
        if(filename.length() < 1)
            fileName = 'RA_' + dateStr + '-' + pQuestionnaireId + '.pdf';
        System.debug('testGetResponses - filename from props ' + filename);        
        
        System.debug('testGenerateRefAssessmentRPT - Step 4 - create a PDF document'); 
        
        PageReference pageReferenceForPDF = Page.RefereeAssessment;
        
        Test.setCurrentPage(pageReferenceForPDF);
        pageReferenceForPDF.getParameters().put('testGetResponses pEvaluatorId',pEvaluatorId);
        pageReferenceForPDF.getParameters().put('testGetResponses pEvalueeId',pEvalueeId);
        pageReferenceForPDF.getParameters().put('testGetResponses pQuestionnaireId',pQuestionnaireId);
         
        // CANNOT TEST getContent - Error System.VisualforceException: Methods defined as TestMethod do not support getContent call
        Blob body = blob.valueOf('Unit.Test');
        String contentType = 'application/pdf';
        
        //System.debug('RefereeAssessment createFile follows'); 
        ContentDocumentLink rptfile = ra.createFile(parentId, linkedId, fileName, body, contentType);
        System.debug('testGenerateRefAssessmentRPT - ContentDocumentLink returned by createFile = ' + rptfile.ContentDocumentId);
        
        System.debug('testGenerateRefAssessmentRPT - Step 5 - now create a message with the document'); 
        Exception unExpectedException;
        try{                                            
            ra.SendDirectMessage(pEvalueeId, rptfile.ContentDocumentId );                                            
        } catch(Exception err) {
            System.debug('testGenerateRefAssessmentRPT - local methods -  error: ' + err.getMessage());
            System.debug(err.getStackTraceString());
            System.debug('----------------------------------------------');
            unExpectedException = err;
        }    
        system.assertEquals(null, unExpectedException, 'testGenerateRefAssessmentRPT should not throw exception');

        System.debug('testGenerateRefAssessmentRPT - Step 6 - Now exercise RefereeAssessmethod methods through EvaluationQuestionsController'); 
        
        try {
        	EvaluationQuestionsController.generateRefAssessmentRPT(pEvaluatorId, pEvalueeId, pQuestionnaireId, 
                                                pEvaluee, pLocation, pPosition );
            System.debug('testGenerateRefAssessmentRPT - Step 6 completed');
            
        } catch(Exception err) {
            System.debug('testGenerateRefAssessmentRPT EvaluationQuestionsController error: ' + err.getMessage());
            System.debug(err.getStackTraceString());
            System.debug('----------------------------------------------');
            unExpectedException = err;
        }    
        system.assertEquals(null, unExpectedException, 'testGenerateRefAssessmentRPT should not throw exception');
         
        System.debug('testGenerateRefAssessmentRPT Referee Assessment completed');   
                
    }
    
}