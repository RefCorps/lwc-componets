({
    // CALL getEvaluationsList in EvaluationQuestionsController.apxc
	getEvaluationsList : function(component) {
		
        //alert("in getEvaluationsList");
         var action = component.get("c.getEvaluationsList");
         var self = this;
        //alert("getEvaluationsList callback follows");
        action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                //alert("getEvaluationsList rtr: " + response.getReturnValue());
                var result = response.getReturnValue();
                component.set("v.assessments", result);
             }else if (state === "ERROR") {
                alert("getEvaluationsList error");
                console.log('Error');
            }
       
        });
        $A.enqueueAction(action);
        //
	},
    
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
                var evaluatorId = uObj[0].Id;
                
                //this.getMyRegattas(component,evaluatorId);
                
                // POSSIBLE AURA BUG - TRIED TO CALL THIS FROM doInit BUT IF FAILED DUE TO UNDEFINED COMPONENT
                // THIS IS EXACTLY THE SAME CALL  
                //this.getQuestionnaireTS(component);
              
             }else if (state === "ERROR") {
                console.log('Error');
            }
       
        });
        $A.enqueueAction(action);
	},

     genRefereeAssessmentPDF: function(component, evaluatorId, evalueeId, questionnaireId) {
        
        //alert("in genRefereeAssessmentPDF");
        var action = component.get("c.generateRefAssessmentRPT");
        
        // test
        action.setParams({
           'pEvaluatorId':evaluatorId, 
           'pEvalueeId':evalueeId, 
           'pQuestionnaireId':questionnaireId
        });
                
        var self = this;
        //alert("genRefereeAssessmentPDF callback follows");
		action.setCallback(self,function(response){
        	var state = response.getState();
        	if(state === 'SUCCESS'){
                alert("Request successfully completed");
                var result = response.getReturnValue();
             }else if (state === "ERROR") {
                 alert("Error processing request");
                console.log('Error');
            }
       
        });
        $A.enqueueAction(action);
	},
    
    
})