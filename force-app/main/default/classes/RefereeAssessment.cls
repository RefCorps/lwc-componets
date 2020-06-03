public class RefereeAssessment {
    
    public static String EvaluatorId {get; set;}
    public static String EvalueeId {get; set;}    
    public static String QuestionnaireId {get; set;}
    
    public string ResponseIn {get; set;}
    
    public static Evaluation_Questions__c Synopsis {get; set;} 
    public static Evaluation_Questions__c SynopsisHeading {get; set;} 
    public static Evaluation_Questions__c Preface {get; set;} 
    public static String EvaluatorName {get; set;}
    public static String EvalueeName {get; set;}
    public static String EvaluationLocation {get; set;}
    public static DateTime EvaluationDate {get; set;}
    public static String fmtEvaluationDate {get; set;}
    public static String EvaluatorComment {get; set;}
    public static String PositionEvaluated {get; set;}
    
    public String recipientEmail { get; set; }  // Send to this email
    
    public static String htmlrpt {get; set;}
    
    public static integer respCount {get; set;}
    
    public static List<Evaluation_Responses__c> responses {get; set;}

    // =================================================================
    
    /*
        THIS IS THE ENTRY POINT FROM RefereeAssessment.vfp
        THE FLOW IS A FOLLOWS        
        EvaluationQuestionsController.apxc INVOKES THE FOLLOWING 
            PageReference pageReferenceForPDF = Page.RefereeAssessment;   <<< THIS IS RefereeAssessment.vfp
            pageReferenceForPDF.getParameters().put('pEvaluatorId',pEvaluatorId);
            pageReferenceForPDF.getParameters().put('pEvalueeId',pEvalueeId);
            pageReferenceForPDF.getParameters().put('pQuestionnaireId',pQuestionnaireId);
            Blob body = pageReferenceForPDF.getContent();   

        EvaluationQuestionController WILL CALL RefereeAssessment.ContentDocumentLink MOVE CONTENT TO FILES
    */
    @AuraEnabled
    public static void  getResponsesVF() {
        
        System.debug('in RefereeAssessment.apxc getResponseVF');
        
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
        
        System.debug('in RefereeAssessment.getResponses'  +
            '\n\tpEvaluatorId=' + pEvaluatorId +
            '\n\rpEvalueeId=' + pEvalueeId +
            '\n\tpQuestionnaireId=' + pQuestionnaireId
        );    
            
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
            
        List<Evaluation_Questions__c> prefacetxt = new List<Evaluation_Questions__c>();    
        List<Evaluation_Questions__c> synopsistxt = new List<Evaluation_Questions__c>();
        List<Evaluation_Questions__c> synopsisheadingtxt = new List<Evaluation_Questions__c>();
        List<Evaluation_Questions__c> selectedquestions = new List<Evaluation_Questions__c>();
        List<Evaluation_Responses__c> selectedresp = new List<Evaluation_Responses__c>();
        List<Evaluation_Responses__c> editedresp = new List<Evaluation_Responses__c>();

        System.debug('Select from Evaluation_Responses__c follows');
        selectedresp = [SELECT 
              Evaluator_Id__r.name,
              Evaluee_Id__r.Name,
              Questionnaire_DateTime__c,            
              Questionnaire_Id__c,          
              Evaluation_Date__c,
              Evaluation_Location__c,
              ResponseGroupHeader__c,
              Question_Id__r.IsQuestionGroupHeader__c,
              Question_Id__r.QuestionType__r.Type_Response_Count__c,
              Evaluation_Type__c,Question_Type__c,
              Question_Number__c,Question_Text__c,
              Evaluation_Rating_Text__c,
              Evaluator_Comment__c
              FROM Evaluation_Responses__c
              where evaluator_id__c =: pEvaluatorId and evaluee_id__c =: pEvalueeId and Questionnaire_Id__c =: pQuestionnaireId    
              order by question_number__c   ];       
        
        String EvaluationTypeIn = selectedresp[0].Evaluation_Type__c;
        
        System.debug('Select from Evaluation_Questions__c follows');
            
        prefacetxt = [SELECT Name, 
               Evaluation_Type__c, 
               Question_Number__c, 
               Question_Text__c, 
               Question_Active__c, 
               QuestionType__r.Name,
               QuestionType__r.Type_Response_Count__c,
               IsQuestionGroupHeader__c 
               FROM Evaluation_Questions__c
               where QuestionType__r.Name = 'PREFACE' and IsQuestionGroupHeader__c = false
               order by question_number__c];    
            
        synopsisheadingtxt = [SELECT Name, 
               Evaluation_Type__c, 
               Question_Number__c, 
               Question_Text__c, 
               Question_Active__c, 
               QuestionType__r.Name,
               QuestionType__r.Type_Response_Count__c,
               IsQuestionGroupHeader__c 
               FROM Evaluation_Questions__c
               where Evaluation_Type__c =: EvaluationTypeIn and Question_Active__c = true and QuestionType__r.Type_Response_Count__c = 0
                    and IsQuestionGroupHeader__c = true
               order by question_number__c];    
            
       synopsistxt = [SELECT Name, 
               Evaluation_Type__c, 
               Question_Number__c, 
               Question_Text__c, 
               Question_Active__c, 
               QuestionType__r.Name,
               QuestionType__r.Type_Response_Count__c,
               IsQuestionGroupHeader__c 
               FROM Evaluation_Questions__c
               where Evaluation_Type__c =: EvaluationTypeIn and Question_Active__c = true and QuestionType__r.Type_Response_Count__c = 0
                    and IsQuestionGroupHeader__c = false
               order by question_number__c];      
            
            
        selectedquestions = [SELECT Name, 
               Evaluation_Type__c, 
               Question_Number__c, 
               Question_Text__c, 
               Question_Active__c, 
               QuestionType__r.Name,
               QuestionType__r.Type_Response_Count__c,
               IsQuestionGroupHeader__c 
               FROM Evaluation_Questions__c
               where Evaluation_Type__c =: EvaluationTypeIn 
                             and Question_Active__c = true 
                             and QuestionType__r.Name != 'PREFACE'
                             and QuestionType__r.Name != 'SYNOPSIS'
               order by question_number__c];        
          //         
            
        //RefereeAssessment.respCount = selectedresp.size();
        //System.debug('Rows returned = ' + RefereeAssessment.respCount);
        boolean match = false;
        for (Evaluation_Questions__c q : selectedquestions ) {
            match = false;
            //System.debug('check ' + q.Question_Number__c + '  ' + q.Question_Text__c);
            for (Evaluation_Responses__c er : selectedresp ) {
                //if(q.Question_Number__c.contains('_0'))
                // there shouldn't be any group headers in responses
                //if(q.IsQuestionGroupHeader__c)    
                //    break;
                if(q.Question_Number__c == er.Question_Number__c) {
                    //System.debug(er.Evaluator_User_Id__r.name);
                    Synopsis = synopsistxt[0];
                    SynopsisHeading = synopsisheadingtxt[0];
                    Preface = prefacetxt[0];
                    EvaluatorName = er.Evaluator_Id__r.name;
                    EvalueeName = er.Evaluee_Id__r.name;
                    System.debug(EvalueeName);
                    EvaluationLocation = er.Evaluation_Location__c;
                    EvaluationDate = (DateTime) er.Evaluation_Date__c;
                    fmtEvaluationDate = EvaluationDate.format('MMMMM dd, yyyy');
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
                if(q.IsQuestionGroupHeader__c)
                    r.ResponseGroupHeader__c = true;
                if(q.QuestionType__r.Type_Response_Count__c == 0)
                    r.Evaluation_Rating_Text__c = '';
                else if(!r.Question_Number__c.contains('_0') )
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
        System.debug('createFile ContentVersion id = ' + cv.Id);

        // insert a ContentDocumentLink with the file version
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        //cdl.LinkedEntityId = linkedId;
        cdl.ShareType = 'V';
        //cdl.Visibility = 'SharedUsers'; // share exception
        insert cdl;
        
        System.debug('createFile ContentDocumentLink id = ' + cdl.Id + '  ContentDocument id = ' + cdl.ContentDocumentId);
        
        return cdl;
    }

    
    // =====================================================================

    public void SendDirectMessage(String EvalueeId, String EvalRptFileId) {
        
     System.debug('SendDirectMessage: EvalueeId=' + EvalueeId + '  EvalRptFileId=' + EvalRptFileId);   
        
     String TestDMAddress = EvaluationQuestionsController.getProp('TestDMAddress');   
        if(String.isNotEmpty(TestDMAddress)) {
            EvalueeId = TestDMAddress;
            System.debug('Using test user Id ' + TestDMAddress);
        }
        
     user[] u = [select name, id from user where contactid =: EvalueeId];
     if(u.size() < 1) {
        System.debug('NO USER INFO FOUND');
         return;
     }   
     String rUserId = u[0].Id;
     System.debug('rUserId = ' + rUserId);   
        
// DIRECT FEED

// Define the FeedItemInput object to pass to postFeedElement
ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
 
ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
textSegmentInput.text = 'Testing direct messages from RefereeAssessment using networkid lookup.';
textSegmentInput.text = EvaluationQuestionsController.getProp('DMText'); 
        
// The MessageBodyInput object holds the text in the post
ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
messageBodyInput.messageSegments.add(textSegmentInput);
feedItemInput.body = messageBodyInput;
 
// The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
// For this feed item, we define a direct message capability to hold the member(s) and the subject.
// select NetworkId, NetworkUserId, UserType FROM NetworkUserHistoryRecent where networkuserid = '0056A000002Hx5HQAS'
// group by NetworkId, NetworkUserId,  UserType 

String UserNetworkID = null;
String MemberId = null;
NetworkMember[] nm =  [SELECT id, memberid, networkid FROM NetworkMember WHERE memberid =: rUserId]; 
        if(nm.size() > 0) {
    UserNetworkID = nm[0].networkid;            
    MemberId = nm[0].memberid;
        }
        
System.debug('UserNetworkID = ' + UserNetworkID);
System.debug('MemberID = ' + MemberId);            
List<String> memberIds = new List<String>();
System.debug('Adding memberId ' + rUserId);        
memberIds.add(MemberId);
// memberIds.add(UserNetworkID);
// memberIds.add('0056A000002Hx5HQAS');
// memberIds.add('005B0000001rIN6');
 
ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
dmInput.subject = 'Referee Assessment';
dmInput.membersToAdd = memberIds;

//============
List<String> fileIds = new List<String>();
// fileIds.add('069e0000001VDzmAAG');
fileIds.add(EvalRptFileId);  //  RA_0507-1335-231-PJ20204106074109.pdf
//fileIds.add('069xx00000000QT');
//fileIds.add('069xx00000000Qn');
//fileIds.add('069xx00000000Qi');
//fileIds.add('069xx00000000Qd');

ConnectApi.FilesCapabilityInput filesInput = new ConnectApi.FilesCapabilityInput();
filesInput.items = new List<ConnectApi.FileIdInput>();

for (String fileId : fileIds) {
    ConnectApi.FileIdInput idInput = new ConnectApi.FileIdInput();
    idInput.id = fileId;
    filesInput.items.add(idInput);
}

ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
feedElementCapabilitiesInput.files = filesInput;

feedItemInput.capabilities = feedElementCapabilitiesInput;            
// ===============

            
//ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
feedElementCapabilitiesInput.directMessage = dmInput;
 
feedItemInput.capabilities = feedElementCapabilitiesInput;
 
// Post the feed item. 
// 0DB6A00000010V7WAI

ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(UserNetworkID, feedItemInput);
              //
            
        system.debug('out GenerateChatterMessage');
        
    }

    
    
}