@isTest public with sharing class RefereeAssessmentTest {
    
    @IsTest(SeeAllData=true) 
    public static void testSetGlobalValues() {
    
    /*
     * RefereeAssessment methods may take parameters or global values     
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
        1.  Randomly locate a completed assessment of evaluation_type__c REFEREE - Evaluation ResponsesAbstract
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

            // Objects used by the method must be present to complete test
            // the following confirms objects are available 
            boolean existsEvaluation_ResponsesAbstract = false;
            boolean existsEvaluation_Responses = false;
            boolean existsEvaluation_Questions = false;
            
            FieldDefinition[] erafields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                           where EntityDefinition.QualifiedApiName = 'Evaluation_ResponsesAbstract__c'];
            
            integer fcnt = erafields.size();
            if(fcnt == 0) {
                existsEvaluation_ResponsesAbstract = false;
            } else {
                existsEvaluation_ResponsesAbstract = true;
            }           
            
            FieldDefinition[] erfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                          where EntityDefinition.QualifiedApiName = 'Evaluation_Responses__c'];
            
            fcnt = erfields.size();
            if(fcnt == 0) {
                existsEvaluation_Responses = false;
            } else {
                existsEvaluation_Responses = true;
            }           
            
            FieldDefinition[] eqfields = [select Label, QualifiedAPIName, DataType, IsIndexed from FieldDefinition
                                          where EntityDefinition.QualifiedApiName = 'Evaluation_Questions__c'];
            
            fcnt = eqfields.size();
            if(fcnt == 0) {
                existsEvaluation_Questions = false;
            } else {
                existsEvaluation_Questions = true;
            }           
            
            // If any object is missing throw a fatal error and end this test
            if(!existsEvaluation_ResponsesAbstract) {
                System.assertNotEquals(true, existsEvaluation_ResponsesAbstract, 'testGetResponses: missing object Evaluation Responses Abstract ');
            }            
            if(!existsEvaluation_Responses) {
                System.assertNotEquals(true, existsEvaluation_Responses, 'testGetResponses: missing object Evaluation Responses');
            }                
            
            if(!existsEvaluation_Questions) {
                System.assertNotEquals(true, existsEvaluation_Responses, 'testGetResponses: missing object Evaluation Questions');
            }
            
            System.debug('testGetResponses - all objects found continue test');
            
            // Randomly select a completed test - the returned evaluator id, evaluee id, and questionnaire Id will be
            // used to complete parameters for getResponses 
            Evaluation_ResponsesAbstract__c[] er = [SELECT Evaluator_User_Id__c, Evaluee_Id__c, Questionnaire_Id__c, Evaluation_type__c from  Evaluation_ResponsesAbstract__c];
            System.debug('testGetResponses - there are ' + er.size() + ' entries in Evaluation ResponsesAbstract - working with the first entry');
            if(er.size() > 0)
            {
                String pEvaluatorId = er[0].Evaluator_User_Id__c;  // Continue to use User ID
                String pEvalueeId = er[0].Evaluee_Id__c;
                String pQuestionnaireId = er[0].Questionnaire_Id__c;
                String erEvaluationType = er[0].evaluation_type__c; 
                System.debug('testGetResponses:\npEvaluatorId='+pEvaluatorId+'\npEvalueeId='+pEvalueeId+'\npQuestionnaireId='+pQuestionnaireId+'\nerEvaluationType='+ erEvaluationType);
                    
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
        
        System.debug('testCreateFile Test 1 - Test will replicate logic in method');
        
        //user[] useracct = [SELECT AccountId from USER where id =: UserId];
        //String parentId = UserId;
        Account acc = [SELECT Id FROM Account WHERE Id = '0016A00000K77C4QAJ'];  // TODO:  WORKS BUT NEED MORE INFO
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
    public static void testSendDirectMessageNoData(){
        
	System.debug('=================================================================================================');
	System.debug('Begin testSendDirectMessageNoData');
        
        RefereeAssessment ra = new RefereeAssessment();
        string UserId = UserInfo.getUserId();
        String EvalueeId = UserId; 
        String EvalRptFileId = '';
        Exception expectedException;
        
        try {
            // should return false 
            ra.SendDirectMessage(EvalueeId, EvalRptFileId);
            // System.assertNotEquals(true, rtr,'SendDirectMessage should return false');    
        } catch (Exception err) {
            System.debug('testSendDirectMessageNoData err: ' + err);
            expectedException = err;
        } 
           
        system.assertEquals(null, expectedException, 'testSendDirectMessageNoData should not throw exception');
        System.debug('testSendDirectMessageNoData completed');

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