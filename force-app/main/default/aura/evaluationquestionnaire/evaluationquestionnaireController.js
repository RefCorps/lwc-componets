({

    /*
     * FYI - You will see commands that begin with $A...  This is a reference to AURA classes from Javascript
     * Some of the more common are
     *  $A.enqueueAction(action) sends the request the server.
     *  $A.get('e.force:refreshView').fire() resets and reloads a form
     *  $A.util.addClass(selectedevaluee, 'slds-has-error') fires and edit related to selectedevaluee
     *  $A.util.removeClass(component.find("Spinner"), "slds-hide") spinner may be used with long task this removes it
     */ 
    
    
	// THIS WILL BE CALLED ON LOAD - GETS EVALUATOR FROM SYSTEM AND SETS EVALUATION DATE TO TODAY    
    doInit : function(component, event, helper) 
    { 
        //alert("in doInit");
        var device = $A.get("$Browser.formFactor");
        if(device.includes('PHONE')) {
            //alert("You are using a phone");
            component.set("v.isPhone",true);
        }
        
        helper.getEvaluator(component);
        // NOTE: helper.getMyRegattas and helper.getQuestionnaireTS ARE CALLED FROM helper.getEvaluator
        // This is because we're making async calls - we have to wait  
        // for user Id before we can request regattas 
        // Calling from getEvaluator after success effectively chains the calls
        // but there can be issues when there are errors
        // TODO: Switch to chained promises to better handle errors
        // see developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/js_promises.htm
        
        // Calendar date for display - this will be replaced once a regatta is selected
        var today = new Date();
		//component.set("v.evaldate", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
		//component.set("v.evaldate", (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear() ) ;
        component.set("v.evaldate",$A.localizationService.formatDate(today,"MM/dd/yyyy"));
        component.set("v.maxdate",$A.localizationService.formatDate(today,"MM/dd/yyyy"));
        var oneyearago  = new Date();
        oneyearago.setFullYear(oneyearago.getFullYear()-1);
        component.set("v.mindate",$A.localizationService.formatDate(today,"MM/dd/yyyy"));
        
        //alert("doInint getEvalQuestions follows");        
        var evaluationtype = "PREFACE";
        var loadpreface = true;
        helper.getEvalQuestions(component, evaluationtype, loadpreface);
        //alert("doInit getEvaluationTypes follows");
        helper.getEvaluationTypes(component, evaluationtype, loadpreface);
 
        helper.getProps(component);
        
    },
     
    regattaDateCheck: function(component) {
		
		var regattadate = component.get("v.regattadate");
        var evaluationlocation =  component.get("v.regattaName");
        var mindate = new Date(component.get("v.mindate"));
        var maxdate = new Date(component.get("v.maxdate"));
        var evaldate = new Date(component.get("v.evaldate"));
        evaldate.setDate(evaldate.getDate() + 1);
        evaldate.setHours(0,0,0,0);
        if(evaldate < mindate  || evaldate > maxdate) {
            var min_mm = mindate.getMonth()+1;
            var min_dd = mindate.getDate();
            var min_yyyy = mindate.getFullYear();
            var sdt = min_mm + "/" + min_dd +"/"+ min_yyyy;
            var max_mm = mindate.getMonth()+1;
            var max_dd = mindate.getDate();
            var max_yyyy = mindate.getFullYear();
            var edt = max_mm + "/" + max_dd +"/"+ max_yyyy;
            if(mindate == maxdate) {
            	var msg = "The date, " + sdt  +  ", is the date of "+   evaluationlocation + ".\nYou should not change the date to a date outside of the actual regatta days.\nDo you still wish to change this date?";
            } else {
                var msg = "Warning: " + sdt  +  " through " + edt + ", are the dates of\n"+   evaluationlocation + ".\nYou should not change the date to a date outside of the actual regatta days. This implies your observation was not on a regatta date.\nDo you still wish to change this date?";
            }
            //alert(evaldate + "\n" + mindate  + "\n" + maxdate);
            //
            var r = confirm(msg);
            if (r == true) {
                txt = "You pressed OK!";
            } else {
                component.set("v.evaldate", regattadate);
            } 
            //
        }
    },
    
    checkBrowser: function(component) {
       
    },
    
    // PROCESS ANSWERS FOLLOWING A RESPONSE CLICK
    handleAnswer : function(component, event, helper) {
        
       // alert("handleAnswer");
       var idx = event.target.value;
       var key = idx.substr(0,idx.indexOf("^"));
       var responses = component.get("v.responses");
       // remove duplicate response by key        
       for(var i = 0; i < responses.length; i++) {
            var k = responses[i].substring(0,responses[i].indexOf("~"));
            //alert("list " + k + " new entry " + key);
            var response = responses[i];
            if(k == key)
            	responses.splice(i,1);
        }
        // add the new response
        responses.push(key + "~" + idx);
        responses.sort();
        //alert(responses);
        component.set("v.responses",responses);
        
    },
        
    getEvalPreamble : function(component, event, helper) {
        //alert("in getEvalPreamble");
        var evaluationtype = "PREAMBLE";
        var loadpreamble = true;
        //helper.getEvalQuestions(component, evaluationtype, loadpreamble);
    },
    
    getEvalQuestionsByType : function(component, event, helper) {

        //alert("in getEvalQuestions");
        var evaluationtype = component.find("selectedEvaluationType").get("v.value");
 
        var loadpreamble = false;
        helper.getEvalQuestions(component, evaluationtype, loadpreamble);

	},
    
    // SET REGATTA DATA AND MAKE THE CALL TO GET PARTIICPANTS
	setRegattaSelection : function(component, event, helper) {
        
        var regattas = component.get('v.regattas');
        var regattaId = component.find("selectedregatta").get("v.value");
        var regattaName = "";
        if(regattas.length > 0) {
            var i = 0;
            for (i = 0; i < regattas.length; i++) {
               if(regattaId === regattas[i].value) {
                 regattaName = regattas[i].label;
                 component.set('v.regattaName',regattaName);
                 break;
               }
            }
        }
        // The following will take a regatta start date and make it the evaluation date - if there is a date
        regattaStartDate = Date.now();
        if(regattaName.includes(" - ")) {
        	var regattaStartDate = regattaName.substring(regattaName.indexOf(" - ")+2, regattaName.indexOf(" / ") ).trim();
            var regattaEndDate = regattaName.substr(regattaName.indexOf(" / ")+2).trim();
            var startdate = new Date(regattaStartDate);
            component.set("v.evaldate", startdate.getUTCFullYear() + "-" + (startdate.getUTCMonth() + 1) + "-" + (startdate.getUTCDate()) );
            component.set("v.mindate", startdate.getUTCFullYear() + "-" + (startdate.getUTCMonth() + 1) + "-" + (startdate.getUTCDate()) );
            component.set("v.regattadate", startdate.getUTCFullYear() + "-" + (startdate.getUTCMonth() + 1) + "-" + (startdate.getUTCDate()) );

            var enddate = new Date(regattaEndDate);
            component.set("v.maxdate", enddate.getUTCFullYear() + "-" + (enddate.getUTCMonth() + 1) + "-" + (enddate.getUTCDate()) );
            
        } 
        // Use the helper to fetch participants of the regatta
        var participants =  component.get('v.participants')
        if (participants.length > 1) {
            participants = participants.splice(1, 1);
        	component.set("v.participants", participants);
        }
        helper.getRegattaParticipants(component);
        
    },

    // THIS IS A WORK AROUND TO GET PARTICIPANT NAME - CANNOT GET IT FROM SELECT TEXT IN LIGHTNING
    setEvalueeId : function(component, event, helper) {
        var evalueeId = component.find("selectedevaluee").get('v.value');
        var evalueeName = ""; //component.find("selectedevaluee").get('v.name');
        component.set('v.evalueeId',evalueeId);
        //alert("get participants");
        var participants = component.get('v.participants');
        if(participants.length > 0) {
            var i = 0;
            for (i = 0; i < participants.length; i++) {
               if(evalueeId === participants[i].value) {
                  evalueeName = participants[i].label;
                 component.set('v.evalueeName',evalueeName);
                 break;
               }
            }
        }
        component.set('v.evalueeloaded',true);
        //alert('in setEvalueeId -- ' + evalueeName + ' - ' + evalueeId);        
    },
    
    // TODO: REMOVE - CREATED TO TEST GEN OF PDF TO FILE
    testGenPDFAssessment: function(component, event, helper) {
        //helper.genRefereeAssessmentPDF(component);
    },
    
    // INTRO MODAL CODE
     
    openIntroModal: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isIntroModalOpen", true);
    },
 
   closeIntroModal: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isIntroModalOpen", false);
   }, 
    
    
    // ------------------------------------------
    // MODAL CODE - 
    // CALLED WHEN THE SUBMIT BUTTON IS PRESSED - IT WILL COLLECT 
    // RESPONSE FOR INSERT TO EvaluationResponse
    openModel: function(component, event, helper) {
        //alert("openMoal");
        var evaluationreview = ""; 
        var evaluatorname = component.find("evaluatorname").get("v.value");
        var evaluatorid = component.find("evaluatorid").get("v.value");
        var evaluatorcontactid = component.find("evaluatorcontactid").get("v.value");
        
        var evalueename = component.get('v.evalueeName'); //component.find("evalueename").get("v.value");
        var evalueeid =  component.get('v.evalueeId'); //component.find("evalueeid").get("v.value");
        
        var questionnairedatetime = component.get('v.questionnaireTS');
        
        // NOTE: SOME OF THE EDITS BELOW SHOULD NOT NEEDED WITH THE REORG OF THE FORM - BUT I'VE LEFT THEM JUST IN CASE
        // EDIT FOR EVALUEE NAME IF NOT PRESENT FLAG FIELD AND RETURN FOR DATA
        if(evalueename == null || evalueename.length == 0)
        {
            var selectedevaluee = component.find("selectedevaluee");
            selectedevaluee.showHelpMessageIfInvalid();
            selectedevaluee.focus();
            $A.util.addClass(selectedevaluee, 'slds-has-error');
            component.set("v.message","Evaluee is missing");
            alert("Evaluee is missing");
            return;
            
        } else {
            component.set("v.message","");
            component.set("v.selectedevaluee",evalueename);
            // MOVE THIS TO THE END
            //$A.util.removeClass(evalueecombo, 'slds-has-error');
        }
        
        var evaluationtypeCmp = component.find("selectedEvaluationType");
        var evaluationtype = evaluationtypeCmp.get("v.value");
        // EVALUATION TYPE EDIT - THERE SHOULD BE A TYPE OTHERWISE THERE WON'T BE 
        // QUESTIONS -- BUT YOU CAN OMIT SELECTION - HIDE SUBMIT BUTTON IF THERE ARE NO QUESTIONS 
        // TODO: BUTTON HIDDEN UNTIL QUESTIONS LOADED AND UNTIL SUCCESSFUL SUBMISSION
        if(evaluationtype == null || evaluationtype.length == 0) {
            evaluationtypeCmp.focus();
            alert("Select an evaluation type and respond to questions");
            return;
        } 
        
        var evaluationlocation =  component.get("v.regattaName");  //component.find("evaluationlocation").get("v.value");
        var evaluationdate = component.find("evaluationdate").get("v.value");
        var evaluatorcomment = component.find("evaluatorcomment").get("v.value");
        
        var responseList = [];
        var review = '<table style="width:100%;">';
        review = review + '<tr style="border-bottom:1pt solid black;"><td style="width:50%;vertical-align:top">Evaluator</td><td style="width:50%;vertical-align:top">' + evaluatorname + '</td></tr>';   //+ " (" + evaluatorid + ")</td></tr>"
        review = review + '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">Evaluee</td><td style="vertical-align:top">' + evalueename + '</td></tr>';

        var displayDateTime = new Date(questionnairedatetime);
         review = review + '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">Questionnaire DateTime</td><td style="vertical-align:top">' + displayDateTime + '</td></tr>';
        
         review = review + '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">Evaluation Date</td><td  style="vertical-align:top">' + evaluationdate + '</td></tr>'; 
         review = review + '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">Location</td><td  style="vertical-align:top">' + evaluationlocation + '</td></tr>';
        
        var cntOverall = 0;
        var responses = component.get("v.responses");
        //alert("responses  " + responses)
        //var resptext = cmp.get("v.questiontext");
        var resps = "";
        var respList = [];
       
        //
        var required = [];
        var questions = component.get("v.questions")
        for(var q = 0; q < questions.length; q++ ) {
            if(questions[q].isRequired__c) {           
            	required.push(questions[q].Question_Text__c);
            }
        }
        //
        cntOverall = required.length;
        //alert("There are " + cntOverall + " required questions");
        //
        for(var i = 0; i < responses.length; i++) {
            resps = resps + responses[i] + "\n";
            //alert("Check answers for required " + responses[i]);
            for(var r = 0; r < required.length; r++) {
                if(responses[i].includes(required[r])) {
                	//alert("Found required question " + required[r]);
                	required.splice(r,1);
                    break;
                }
            }
            //
            var resp = responses[i].substring(responses[i].indexOf("^")+1);
            resp = resp.substring(0,resp.indexOf("-"));
            resp = '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">' + resp.replace('[','</td><td style="vertical-align:top">');
            resp = resp.replace(']','</td></tr>');
            //responseList.push(resp);
            review = review + resp;
        }
        //alert("Check for missed required elements");
        if(required.length > 0)
        {
            for(var r = 0; r < required.length; r++) {
            component.set("v.message", required[r] + " response");
            alert("Please provide a rating for\n" + required[r]);
            return;
            }
        }
        //alert("No missing questions");
        var responseString = "evaluatorname=" + evaluatorname + "\nevaluatorid=" + evaluatorid + "\n"; 
        responseString = responseString + "evaluatorcontactid=" + evaluatorcontactid + "\n";
        responseString = responseString + "evalueeid=" + evalueeid + "\n";
        responseString = responseString + "evaluationtype=" + evaluationtype + "\n";
        responseString = responseString + "questionnairedatetime=" + questionnairedatetime + "\n";
        responseString = responseString + "evaluationlocation=" + evaluationlocation + "\n"; 
        responseString = responseString + "evaluationdate=" + evaluationdate + "\n"; 
        responseString = responseString + "evaluatorcomment=" + evaluatorcomment + "\n";
        responseString = responseString + resps;
        evaluationreview = responseString;
        
         review = review + '<tr style="border-bottom:1pt solid black;"><td style="vertical-align:top">Evalautor Comment</td><td>' + evaluatorcomment + '</td></tr>';
        review = review + '</table>';
        //alert(responseString + "\n" + responseList);
        alert(responseString);
        
        component.set("v.evaluationReviewList", review); 
        component.set("v.evaluationReview",responseString);
        
        component.set("v.isModalOpen", true);
        
        component.set("v.passedEdits", true);
        window.scrollTo(0, 0);
        
    },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      //alert("closeModal");
      component.set("v.isModalOpen", false);
   },
    
   // MODAL SUBMIT
   submitDetails: function(component, event, helper) {
       // Set isModalOpen attribute to false
       // Add your code to call apex method or do some processing
       //alert("submitDetails -> c.submitButton");
       var responseString = component.get("v.evaluationReview");
       
       //alert("submit responsestring = " + responseString); 
       helper.insertRespHelper(component, responseString);     

       //component.set("v.isSubmitCompleted",true); 
      
      component.set("v.isModalOpen", false);
       
   },
    
    // CLEAR FORM AFTER TOAST CLOSED - TODO: REVIEW REFRESH WHEN THERE IS AN ERROR 
   myrefresh : function(component, event, helper) {
    component.set("v.isSubmitCompleted",false);    
    $A.get('e.force:refreshView').fire();
	},
    
})