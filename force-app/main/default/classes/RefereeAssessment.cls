public class RefereeAssessment {
/*
    RefereeAssesssment was created to support RefereeAssessment.vfp, a 
    Visual Force Page that outputs a PDF Document in a format similar to 
    the originial Referee Assessment (Asst. Evaluation) document.  
    
    The RefereeAssessment.vfp entry point is getResponseVF [action="{!getResponsesVF}"].
    
    EvaluationQuestionsController.apxc INVOKES THE FOLLOWING 
        PageReference pageReferenceForPDF = Page.RefereeAssessment;   <<< THIS IS RefereeAssessment.vfp
        pageReferenceForPDF.getParameters().put('pEvaluatorId',pEvaluatorId);
        pageReferenceForPDF.getParameters().put('pEvalueeId',pEvalueeId);
        pageReferenceForPDF.getParameters().put('pQuestionnaireId',pQuestionnaireId);
        Blob body = pageReferenceForPDF.getContent();   

    EvaluationQuestionController will call RefereeAssessment method createFile (creates and stores file)
        ContentDocumentLink rptfile = ra.createFile(parentId, linkedId, fileName, body, contentType);
    EvaluationQuestionController WILL CALL RefereeAssessment method SendDirectMessage (sends file to Evaluee)
        ra.SendDirectMessage(pEvalueeId, rptfile.ContentDocumentId ); 

*/

// THE FOLLOWING GLOBAL VALUES ARE USED WITHIN RefereeAssessment.vfp
public static String EvaluatorId {
    get;
    set;
}
public static String EvalueeId {
    get;
    set;
}
public static String QuestionnaireId {
    get;
    set;
}
public static String EvaluatorName {
    get;
    set;
}
public static String EvalueeName {
    get;
    set;
}
public static String EvaluationLocation {
    get;
    set;
}
public static DateTime EvaluationDate {
    get;
    set;
}
public static String fmtEvaluationDate {
    get;
    set;
}
public static String EvaluatorComment {
    get;
    set;
}
public static String PositionEvaluated {
    get;
    set;
}

public static Evaluation_Questions__c Synopsis {
    get;
    set;
}
public static Evaluation_Questions__c SynopsisHeading {
    get;
    set;
}
public static Evaluation_Questions__c Preface {
    get;
    set;
}

public static List < Evaluation_Responses__c > responses {
    get;
    set;
}

public static integer respCount {
    get;
    set;
}

public static Contact testEvaluatorcontact {get; set;}
public static Contact testEvalueecontact {get; set;}
public static Regatta__c testEvalregatta {get; set;}
public static Regatta_Participation__c[] testRegattaParticipation {get; set;}
public static String testPropFileNameFormat {get; set;}

// THE FOLLOWING WERE CREATED TO SUPPORT APEX TESTING AS AN ALTERNATIVE TO PARAMS
public static String tstEvaluatorId {get; set;}
public static String tstEvalueeId {get; set;}
public static String tstQuestionnaireId {get; set;}

public static String getProp(String prop) {
    String value = '';
    String searchquery = 'select Name, Value__c from Evaluation_Properties__c where isActive__c = true and name = \'' + prop + '\'';
    //System.debug(LoggingLevel.DEBUG,'getProp query: ' + searchquery);
    List<Evaluation_Properties__c> props = Database.query(searchquery);
    if(props.size() > 0) {
        value = (String) props[0].get('Value__c');
    }
    //System.debug(LoggingLevel.DEBUG,'getProp returning ' + value);
    return value;
}


// =================================================================

@AuraEnabled
public static void getResponsesVF() {

    System.debug(LoggingLevel.INFO, 'in RefereeAssessment.apxc getResponseVF');

    RefereeAssessment ra = new RefereeAssessment();

    String pEvaluatorId = '';
    String pEvalueeId = '';
    String pQuestionnaireId = ''; 

    PageReference pg = ApexPages.currentPage();
    pEvaluatorId = pg.getParameters().get('pEvaluatorId');
    pEvalueeId = pg.getParameters().get('pEvalueeId');
    pQuestionnaireId = pg.getParameters().get('pQuestionnaireId');


    // THERE ARE TWO WAYS TO SET VALUES 1) Parameters 2) 'tst' Globals (used for apex testing)
    // If there are no values this will fail
    if(Test.isRunningTest()) {
        pEvaluatorId = tstEvaluatorId;
        pEvalueeId = tstEvalueeId;
        pQuestionnaireId = tstQuestionnaireId;
    }
    System.debug(LoggingLevel.DEBUG, 'pEvaluatorId: ' + pEvaluatorId);
    System.debug(LoggingLevel.DEBUG, 'pEvalueeId: ' + pEvalueeId);
    System.debug(LoggingLevel.DEBUG, 'pQuestionnaireId: ' + pQuestionnaireId);

    if (String.isEmpty(pEvaluatorId))
        throw new applicationException('RefereeAssessment error - missing pEvaluatorId value');
    if (String.isEmpty(pEvalueeId))
        throw new applicationException('RefereeAssessment error - missing pEvalueeId value');
    if (String.isEmpty(pQuestionnaireId))
        throw new applicationException('RefereeAssessment error - missing pQuestionnaireId value');

    ra.getResponses(pEvaluatorId, pEvalueeId, pQuestionnaireId);

    System.debug(LoggingLevel.INFO, 'out getResponseVF');
}

// =================================================================
// GET RESPONSES FOR ASSESSMENT REPORT
public List < Evaluation_Responses__c > getResponses(
    String pEvaluatorId,
    String pEvalueeId,
    String pQuestionnaireId) {

    System.debug(LoggingLevel.INFO, 'in RefereeAssessment.getResponses' +
        '\n\tpEvaluatorId=' + pEvaluatorId +
        '\n\tpEvalueeId=' + pEvalueeId +
        '\n\tpQuestionnaireId=' + pQuestionnaireId
    );

    RefereeAssessment ra = new RefereeAssessment();

    if (String.isEmpty(pQuestionnaireId)) {
        pQuestionnaireId = RefereeAssessment.QuestionnaireId;
    }
    if (String.isEmpty(pEvalueeId)) {
        pEvalueeId = RefereeAssessment.EvalueeId;
    }
    if (String.isEmpty(pEvaluatorId)) {
        pEvaluatorId = RefereeAssessment.EvaluatorId;
    }

    List < Evaluation_Questions__c > prefacetxt = new List < Evaluation_Questions__c > ();
    List < Evaluation_Questions__c > synopsistxt = new List < Evaluation_Questions__c > ();
    List < Evaluation_Questions__c > synopsisheadingtxt = new List < Evaluation_Questions__c > ();
    List < Evaluation_Questions__c > selectedquestions = new List < Evaluation_Questions__c > ();
    List < Evaluation_Responses__c > selectedresp = new List < Evaluation_Responses__c > ();
    List < Evaluation_Responses__c > editedresp = new List < Evaluation_Responses__c > ();

    System.debug(LoggingLevel.DEBUG, 'Select from Evaluation_Responses__c follows');
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
        Evaluation_Type__c, Question_Type__c,
        Question_Number__c, Question_Text__c,
        Evaluation_Rating_Text__c,
        Evaluator_Comment__c
        FROM Evaluation_Responses__c
        where evaluator_id__c =: pEvaluatorId and evaluee_id__c =: pEvalueeId and Questionnaire_Id__c =: pQuestionnaireId
        order by question_number__c
    ];

    String EvaluationTypeIn = selectedresp[0].Evaluation_Type__c;

    System.debug(LoggingLevel.DEBUG, 'Select from Evaluation_Questions__c follows');

    prefacetxt = [SELECT Name,
        Evaluation_Type__c,
        Question_Number__c,
        Question_Text__c,
        Question_Active__c,
        QuestionType__r.Name,
        QuestionType__r.Type_Response_Count__c,
        IsQuestionGroupHeader__c
        FROM Evaluation_Questions__c
        where QuestionType__r.Name = 'PREFACE'
        and IsQuestionGroupHeader__c = false
        order by question_number__c
    ];

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
        order by question_number__c
    ];

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
        order by question_number__c
    ];


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
        order by question_number__c
    ];
    //         

    RefereeAssessment.respCount = selectedresp.size();

    System.debug(LoggingLevel.DEBUG, 'prefacetxt rows returned = ' + prefacetxt.size());
    System.debug(LoggingLevel.DEBUG, 'synopsisheadingtxt rows returned = ' + synopsisheadingtxt.size());
    System.debug(LoggingLevel.DEBUG, 'synopsistxt rows returned = ' + synopsistxt.size());

    System.debug(LoggingLevel.DEBUG, 'selectedquestions rows returned = ' + selectedquestions.size());
 
    boolean match = false;
    for (Evaluation_Questions__c q: selectedquestions) {
        match = false;
        System.debug(LoggingLevel.DEBUG, 'check ' + q.Question_Number__c + '  ' + q.Question_Text__c);
        for (Evaluation_Responses__c er: selectedresp) {
            //if(q.Question_Number__c.contains('_0'))
            // there shouldn't be any group headers in responses
            //if(q.IsQuestionGroupHeader__c)    
            //    break;

            // THE FOLLOWING POPULATES STATIC GLOBAL VALUES AND RETURNED VALUES IN editedresp
            if (q.Question_Number__c == er.Question_Number__c) {

                if (synopsistxt.size() > 0) {
                    Synopsis = synopsistxt[0];
                  
                }
                if (synopsisheadingtxt.size() > 0) {
                    SynopsisHeading = synopsisheadingtxt[0];
                    
                }
                if (prefacetxt.size() > 0 && !EvaluationTypeIn.contains('SAFETY CHECKLIST')) {
                    Preface = prefacetxt[0];
                  
                }
                EvaluatorName = er.Evaluator_Id__r.name;
                EvalueeName = er.Evaluee_Id__r.name;
                System.debug(EvalueeName);
                EvaluationLocation = er.Evaluation_Location__c;
                EvaluationDate = (DateTime) er.Evaluation_Date__c;
                fmtEvaluationDate = EvaluationDate.format('MMMMM dd, yyyy');
                if (String.isNotBlank(er.Evaluation_Type__c)) {
                    PositionEvaluated = er.Evaluation_Type__c; 
                }
                if (String.isNotBlank(er.Evaluator_Comment__c)) {
                    EvaluatorComment = er.Evaluator_Comment__c; 
                }
                editedresp.add(er);
                System.debug(LoggingLevel.DEBUG, '\n\n ### Added matched response: ' + er);
                match = true;
            }
        }
        if (match) {
            System.debug(' !!! IF MATCH CONTINUE LOOP');
            continue; 
        }
        else {

            System.debug(' xxx NO MATCH LOOP');

            // THESE WILL BE VALUES ADDED TO editedresp
            Evaluation_Responses__c r = new Evaluation_Responses__c();
            System.debug(LoggingLevel.DEBUG, 'no match ' + q.Question_Number__c + '  ' + q.Question_Text__c);
            r.Question_Text__c = q.Question_Text__c;
            r.Question_Number__c = q.Question_Number__c;
            r.Question_Type__c = q.QuestionType__r.Name;
            if (q.IsQuestionGroupHeader__c)
                r.ResponseGroupHeader__c = true;
            if (q.QuestionType__r.Type_Response_Count__c == 0)
                r.Evaluation_Rating_Text__c = '';
            else if (!r.Question_Number__c.contains('_0'))
                r.Evaluation_Rating_Text__c = 'Not Selected';
            editedresp.add(r);
        }

    } // END OUTER LOOP

    // THIS SETS THE GLOBAL VARIABLE THAT'S USED IN THE PDF
    RefereeAssessment.responses = editedresp;

    System.debug(LoggingLevel.INFO, 'out getResponses return size=' + RefereeAssessment.responses.size());

    //sleep(5000);
    //ra.GeneratePDF();

    return editedresp;
}

// =================================================================
// METHODS USED TO HANDLE OUTPUT

public ContentDocumentLink createFile(Id parentId, Id linkedId, String fileName, Blob body, String contentType) {

    System.debug(LoggingLevel.INFO, 'createFile ' + filename + ' ' + contentType);
    // insert a version of the file - if no ContentDocumentId, then it creates a new ContentDocument
    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S'; // S = within Salesforce, E = External
    cv.VersionData = body;
    cv.Title = fileName;
    cv.PathOnClient = filename;
    //cv.OwnerId = linkedId; // owner exception
    //cv.firstPublishLocationId= linkedId;
    insert cv;
    System.debug(LoggingLevel.DEBUG, 'createFile ContentVersion id = ' + cv.Id);

    // insert a ContentDocumentLink with the file version
    cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = cv.ContentDocumentId;
    cdl.LinkedEntityId = parentId;
    //cdl.LinkedEntityId = linkedId;
    cdl.ShareType = 'V';
    //cdl.Visibility = 'SharedUsers'; // share exception
    insert cdl;

    System.debug(LoggingLevel.INFO, 'createFile ContentDocumentLink id = ' + cdl.Id + '  ContentDocument id = ' + cdl.ContentDocumentId);

    return cdl;
}


// =====================================================================

public ConnectApi.FeedElement SendDirectMessage(String EvalueeId, String EvalRptFileId) {

    System.debug(LoggingLevel.INFO, 'SendDirectMessage: EvalueeId=' + EvalueeId + '  EvalRptFileId=' + EvalRptFileId);

    // THE FOLLOWING IS TEMP OUT OF ORDER - PROP 'TestDMAddress' SHOULD BE DISABLED FOR NOW
    //String TestDMAddress = EvaluationQuestionsController.getProp('TestDMAddress');
    //if (String.isNotEmpty(TestDMAddress)) {
    //    EvalueeId = TestDMAddress;
    //    System.debug(LoggingLevel.DEBUG,'Using test user Id ' + TestDMAddress);
    //}
    // ==================================

    user[] u = [select name, id from user where contactid =: EvalueeId];
    if (u.size() == 0) {
        System.debug(LoggingLevel.ERROR, 'SendDirectMessage - 0 user data found - throwing error');
        throw new applicationException('SendDirectMessage - EvaluedId lookup failed probable cause is EvalueeId contact Id: [' + EvalueeId + ']');
    }
    String rUserId = u[0].Id;
    System.debug(LoggingLevel.DEBUG, 'rUserId = ' + rUserId);

    String AppAcct = RefereeAssessment.getProp('AppName');
    System.debug(LoggingLevel.DEBUG, 'SendDirectMessage - Lookup Account Id for ' + AppAcct);
    Account acc = [SELECT Id FROM Account WHERE Name =: AppAcct]; // TODO:  WORKS BUT NEED MORE INFO
    String parentId = acc.Id;
    System.debug(LoggingLevel.DEBUG, 'SendDirectMessage - using Account Id = ' + parentId + ' to location contentdocument ' + EvalRptFileId);

    String querystmt = 'SELECT ContentDocument.title, Id,LinkedEntityId,ContentDocumentId,IsDeleted,SystemModstamp ';
    querystmt = querystmt + 'FROM ContentDocumentLink WHERE LinkedEntityId = \'' + parentId + '\' AND ContentDocumentId = \'' + EvalRptFileId + '\'';
    System.debug(LoggingLevel.DEBUG, 'SendDirectMessage - query\n' + querystmt);
    ContentDocumentLink[] cdl = Database.query(querystmt);
    System.debug(LoggingLevel.DEBUG, 'SendDirectMessage - Lookup document, rows = ' + cdl.size());
    if (cdl.size() == 0) {
        System.debug(LoggingLevel.ERROR, 'SendDirectMessage - document lookup failed probable cause is EvalRptFileId: [' + EvalRptFileId + ']');
        throw new applicationException('SendDirectMessage - document lookup failed probable cause is EvalRptFileId: [' + EvalRptFileId + ']');
    }
    //System.assert(cdl.size() > 0, 'SendDirectMessage - could not locate document for ' + u[0].Name);

    // DIRECT FEED

    // Define the FeedItemInput object to pass to postFeedElement
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
    textSegmentInput.text = 'Testing direct messages from RefereeAssessment using networkid lookup.';
    textSegmentInput.text = RefereeAssessment.getProp('DMText');

    // The MessageBodyInput object holds the text in the post
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
    messageBodyInput.messageSegments.add(textSegmentInput);
    feedItemInput.body = messageBodyInput;

    // The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
    // For this feed item, we define a direct message capability to hold the member(s) and the subject.
    // select NetworkId, NetworkUserId, UserType FROM NetworkUserHistoryRecent where networkuserid = '0056A000002Hx5HQAS'
    // group by NetworkId, NetworkUserId,  UserType 

    String UserNetworkID = null;
    String MemberId = null;
    NetworkMember[] nm = [SELECT id, memberid, networkid FROM NetworkMember WHERE memberid =: rUserId];
    if (nm.size() > 0) {
        UserNetworkID = nm[0].networkid;
        MemberId = nm[0].memberid;
    }

    System.debug(LoggingLevel.DEBUG, 'UserNetworkID = ' + UserNetworkID);
    System.debug(LoggingLevel.DEBUG, 'MemberID = ' + MemberId);
    List < String > memberIds = new List < String > ();
    System.debug(LoggingLevel.DEBUG, 'Adding memberId ' + rUserId);
    memberIds.add(MemberId);
    // memberIds.add(UserNetworkID);
    // memberIds.add('0056A000002Hx5HQAS');
    // memberIds.add('005B0000001rIN6');

    ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
    dmInput.subject = 'Referee Assessment';
    dmInput.membersToAdd = memberIds;

    //============
    List < String > fileIds = new List < String > ();
    // fileIds.add('069e0000001VDzmAAG');
    fileIds.add(EvalRptFileId); //  RA_0507-1335-231-PJ20204106074109.pdf
    //fileIds.add('069xx00000000QT');
    //fileIds.add('069xx00000000Qn');
    //fileIds.add('069xx00000000Qi');
    //fileIds.add('069xx00000000Qd');

    ConnectApi.FilesCapabilityInput filesInput = new ConnectApi.FilesCapabilityInput();
    filesInput.items = new List < ConnectApi.FileIdInput > ();

    for (String fileId: fileIds) {
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
    System.debug(LoggingLevel.INFO, 'out SendDirectMessage');

    return feedElement;

}

public class applicationException extends Exception {}
}