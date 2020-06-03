({
 
    // CALL fetchEvaluator in EvaluationQuestionsController.apxc - this does a FIND based upon name characters entered
    getEvaluator: function(component) {
        //alert("in getEvaluator - component.get follows");
        var action = component.get("c.fetchEvaluator");
        var self = this;
        //alert("getEvaluator callback follows");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getEvaluator rtr: " + response.getReturnValue());
                var uObj = response.getReturnValue();
                
				// push the evaluator to the form
				component.set("v.evaluator", uObj[0]);
                // now go fetch my regattas
                // var evaluatorId = uObj[0].Id;
                var evaluatorcontactId = uObj[0].ContactId;
                
                var evaluatorContactId = uObj[0].ContactId;                
                //alert('evaluator Ids = ' + evaluatorContactId + '|' + evaluatorId);
                
                this.getMyRegattas(component,evaluatorcontactId);
                                
                // POSSIBLE AURA BUG - TRIED TO CALL THIS FROM doInit BUT IF FAILED DUE TO UNDEFINED COMPONENT
                // THIS IS EXACTLY THE SAME CALL  
                this.getQuestionnaireTS(component);
              
             }else if (state === "ERROR") {
                console.log('Error');
                 alert("evaluationquestionnireHelper getEvaluator error");
            }
       
        });
        $A.enqueueAction(action);
	},
    
    // THIS WILL PULL A SERVER TIMESTAMP USING EvaluationQuestionsController.apxc - getQuestionnaireTS
    // PROVIDES A CONSTANT VALUE ACROSS ALL RESPONSES - IT WILL BE GMT
    getQuestionnaireTS: function(component) {
        //alert("in getQuestionnaireTS - component.get follows");
        var action = component.get("c.getQuestionnaireTS");
        var self = this;
        //alert("getEvaluator callback follows");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getEvaluator rtr: " + response.getReturnValue());
                var result = response.getReturnValue();
				component.set("v.questionnaireTS", result);
             }else if (state === "ERROR") {
                console.log('Error');
            }
       
        });
        $A.enqueueAction(action);
	},
    
    getProps: function(component) {
        
    	//alert("in getProps - component.get follows");
        var action = component.get("c.getProps");
        var self = this;
        //alert("getEvaluator callback follows");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getEvaluator rtr: " + response.getReturnValue());
                var result = response.getReturnValue();
 
				component.set("v.props", result);
                //alert("setProps follows");
                
                var props = component.get('v.props');
                //alert("attribute props length="+props.length);
                for(var i = 0; i < props.length; i++) {
                    //alert("prop " + i + " name = " + props[i].Name);  
                    // SET PROPERTY RestrictRegattaDaySelection
                    var k = props[i].Name;
                    if( k.includes("RestrictRegattaDaySelection") ) {
                        var v = props[i].Value__c;
                         if(v.includes("true")) {
                             //alert("Found restrict days");
                             component.set("v.RestrictRegattaDaySelection", true);	   
                        }
                    }
               } 
           }else if (state === "ERROR") {
                console.log('Error');
          }
       
        });
        $A.enqueueAction(action);     
    },
    
    
    // CALL getMyRegattas in EvaluationQuestionsController.apxc
    getMyRegattas : function(component, evaluatorcontactId) {
        
        var lastNDays = component.get("v.lastNDays");
    	var action = component.get("c.myRecentRegattas");
        //alert("getMyRegattas evaluatorId " + evaluatorId + " lastNDays " + lastNDays);
        action.setParams({
             'myId': evaluatorcontactId,
             'lastNDays': lastNDays             
        });
        
        var self = this;
        //alert("getMyRegattas callback follows");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getMyRegattas rtr: " + response.getReturnValue());
                var result = response.getReturnValue();
                //alert("getMyRegattas count " + result.length );
                if(result.length > 0) {
                    //alert( JSON.stringify(result[0]));
    				//alert("set v.regattas with result");
                    component.set('v.regattas',result);        
    			} else {
                    alert("No recent regatta records where found");
    				component.set('v.regattas', "No Records Found");
    			}
             }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
	}, 
    
    // CALL regattaParticipants in EvaluationQuestionsController.apxc
    getRegattaParticipants : function(component, regattaId) {

        //alert("in helper getRegattaParticipants");
        var regattaId = component.find("selectedregatta").get("v.value");
        var myId = component.find("evaluatorcontactid").get("v.value");
        //alert("getRegattaParticipants regattaId=" + regattaId + "  myId=" + myId );
        
        //var action = component.get("c.regattaParticipants");
        var action = component.get("c.regattaContacts");
        action.setParams({
            "regattaId": regattaId,
            "myId": myId
        });
        var self = this;
        action.setCallback(self,function(response){
            
            var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getMyRegattas rtr: " + response.getReturnValue());
                var result = response.getReturnValue();
                //alert("getRegattaParticipants count " + result.length );
                if(result.length > 0) {
                    //alert( JSON.stringify(result[0]));
                    component.set('v.participants',result);        
    			} else {
                    alert("No records found");
    				component.set('v.participants', "No Records Found");
    			}
             }else if (state === "ERROR") {
                console.log('Error');
            }
            
        });
        $A.enqueueAction(action);

    },
    
    getEvaluationTypes : function(component) {
        var action = component.get("c.getEvaluationTypes");
        //alert("getEvalQuestionsByType param = " + param);
        var self = this;
        action.setCallback(this, function(response){
	        var state = response.getState();
	        if (state === "SUCCESS") {
                //alert("rtr: " + response.getReturnValue());
                // HINT: You need to unpack the return into a local value 
                // in this case it will be a list object
                var evaltypes = response.getReturnValue();
               	component.set("v.evaluationtypes",evaltypes);
	           
            } else {
               // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    alert('evaluationquestionnaireHelper getEvaluationTypes error: ' +  errors[0].message);
                    component.set('v.message', errors[0].message);
                }
            }
	    });
	    $A.enqueueAction(action);
    },
    
    getEvalQuestions : function(component, evaluationtype, loadpreface) {
        
        var param = evaluationtype;
        //alert("in getEvalQuestions - type=" + evaluationtype);
		var action = component.get("c.getQuestions");
        //alert("getEvalQuestionsByType param = " + param);
        var self = this;
        action.setParams({
            'EvaluationTypeIn' : param
        });
        action.setCallback(this, function(response){
	        var state = response.getState();
            //alert("response = " + state)
	        if (state === "SUCCESS") {
                //alert("rtr: " + response.getReturnValue());
                // HINT: You need to unpack the return into a local value 
                // in this case it will be a list object
                var qObj = response.getReturnValue();
                //alert( Object.keys(qObj).length + " questions returned ")
             
                if(loadpreface) {
                    component.set("v.preface", qObj);
                    if(qObj.length > 0)
                	   component.set("v.prefaceloaded",true);
                } else {
	            	component.set("v.questions", qObj);
                	component.set("v.questionsloaded",true);
                }
	           
            } else {
               // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    alert('evaluationquestionnaireHelper getEvalQuestionsByType error: ' +  errors[0].message);
                    component.set('v.message', errors[0].message);
                }
            }
	    });
	    $A.enqueueAction(action);
	},
    
    
    // CALL insertResponses in EvaluationQuestionsController.apxc
    // NOTE THAT ON SUCCESS A TOAST IS OPENED ON THE PAGE - THIS CAN BE EITHER SUCCESS OR ERROR
    // TODO: TEST POSSIBLE ERROR SCENARIOS (MESS UP THE INSERT TO FORCE DB ERRORS AND DELAY RESPONSES)
    insertRespHelper : function(component, responseString) {
        
		//alert(responseString);
        var action = component.get("c.insertResponses");
        action.setParams({
            'responseString' : responseString
        });
       var self = this;
       action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                
                var result = response.getReturnValue();
                //alert("success return = " + result);
                if(result.includes(";")) {                   
                	var p = result.split(";");
                    // generateRefAssessmentRPT(String pEvaluatorId, String pEvalueeId, String pQuestionnaireId, 
                    //alert("evaluationquestionnaireHelper insertRespHelper call insertResponses " + p);
                    var pEvaluatorcontactId = p[0];
                    var pEvalueeId = p[1];
                    var pQuestionnaireId = p[2];
                    var pPosition = p[3];
                    var pEvaluee = component.get('v.evalueeName');
                    var pLocation = component.get('v.regattaName');
                    var pPosition = component.find("selectedEvaluationType").get("v.value");
                    // genRefereeAssessmentPDF: function(component, evaluatorId, evalueeId, evaluee, position, questionnaireId)
                    /*
                    alert("genRefereeAssessmentPDF\n" +
                          "pEvaluatorId: " + pEvaluatorId + "\n" + 
                          "pEvalueeId: " + pEvalueeId + "\n" +  
                          "pEvaluee: " + pEvaluee + "\n" + 
                          "pPosition: " + pPosition + "\n" + 
                          "pLocation: " + pLocation + "\n" +
                          "pQuestionnaireId: " + pQuestionnaireId ); 
                    */
                	this.genRefereeAssessmentPDF(component,pEvaluatorcontactId,pEvalueeId,pEvaluee,pLocation,pPosition,pQuestionnaireId);
                }
                
                //alert("insertRespHelper success");
                component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_success");
            	component.set("v.toastClass","slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top");                 
                component.set("v.isSubmitCompleted",true); 
      		    component.set("v.isModalOpen", false);               
           		component.set("v.wasSubmitSuccessful",true);
                component.set('v.toastMessage'," successfully submitted");
                component.set("v.questionsloaded",false); // THIS WILL REMOVE THE SUBMIT BUTTON BUT THE FORM DATA WILL REMAIN UNTIL TOAST IS CLOSED

                //alert('calling genRefereeAssessmentPDF');
                //this.genRefereeAssessmentPDF(component);
                
             }else if (state === "ERROR") {
                 //alert("insertRespHelper error");
                 component.set("v.toastTheme","slds-notify slds-notify_toast slds-theme_error");
            	 component.set("v.toastClass","slds-icon_container slds-icon-utility-error slds-m-right_small slds-no-flex slds-align-top");                 
                var errors = response.getError();
                 var errormessage = " submission failed: ";
                if (errors && errors[0] && errors[0].message) {
                    errormessage = errormessage + errors[0].message + " -- Please notify support for assistance";
                } else {
                  errormessage = errormessage + " Unknown procesing error.  Please notify support for assistance";
                }
                 //alert("evlauationquestionnaireHelper insertRespHelper errormessage = " + errormessage);
                 component.set('v.toastMessage',errormessage);
                 component.set("v.isSubmitCompleted",true); 
      		     component.set("v.isModalOpen", false);               
                 component.set("v.wasSubmitSuccessful", true);
            }
        });
        $A.enqueueAction(action); 
    },

               
    genRefereeAssessmentPDF: function(component, evaluatorcontactId, evalueeId, evaluee, location, position, questionnaireId) {

        
        //alert("in genRefereeAssessmentPDF test");
        /*
        alert("genRefereeAssessmentPDF\n" +
              "pEvaluatorId: " + evaluatorId + "\n" + 
              "pEvalueeId: " + evalueeId + "\n" +  
              "pEvaluee: " + evaluee + "\n" + 
              "location: " + location + "\n" +
              "pPosition: " + position + "\n" + 
              "pQuestionnaireId: " + questionnaireId );
         */
        //generateRefAssessmentRPT(String pEvaluatorId, String pEvalueeId, String pEvaluee, String pPosition, String pQuestionnaireId) 
        var action = component.get("c.generateRefAssessmentRPT");  // creates an assessment output to PDF
        action.setParams({
           'pEvaluatorId':evaluatorcontactId, 
           'pEvalueeId':evalueeId, 
            'pEvaluee':evaluee,
            'pPosition':position,
           'pQuestionnaireId':questionnaireId
        });
        
        var self = this;
        //alert("genRefereeAssessmentPDF callback follows standby");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("Request successfully completed");
                var result = response.getReturnValue();
             }else if (state === "ERROR") {
                 alert("evaluationquestionnaireHelper genRefereeAssessmentPDF Error processing request");
                console.log('Error');
            }
       
        });
        $A.enqueueAction(action);
	},

    
    
    // CALLS fetchRecords in EvaluationQuestionsController.apxc
    // The return is a list of potential evaluee names
    searchRecordsHelper : function(component, event, helper, value) {
        
        //alert("in searchRecordsHelper");
        
		$A.util.removeClass(component.find("Spinner"), "slds-hide"); // test to display spinner

        var searchString = component.get('v.searchString');
        //alert("searchRecordsHelper searchString=" + searchString);
              
        component.set('v.message', '');
        component.set('v.recordsList', []);
        
		// Calling Apex Method
    	var action = component.get('c.fetchRecords');
        var objname = component.get('v.objectName');
        var fname = component.get('v.fieldName');
        //alert("searchRecordsHelper objname=" + objname);
        //alert("searchRecordsHelper filterField=" + fname);
        //alert("searchRecordsHelper searchString=" + searchString);
        //alert("searchRecordsHelper value=" + value);
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : searchString,
            'value' : value
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
					} else {
                        component.set('v.selectedRecord', result[0]);
					}
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + "'");
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	}
    
    
})