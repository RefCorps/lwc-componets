({
    
    doInitRpt : function(component, event, helper) {
      
        //alert("in doInitRpt");
        helper.getEvaluationsList(component);
        //helper.getEvaluator(component);
        
    },
    
	confirmSend : function(component, event, helper) {
		
        var assessments = component.get("v.assessments");
        var assessmentId = component.find("selectedevaluee").get("v.value");
        var selectedassessment = '';
        if(assessments.length > 0) {
            var i = 0;
            for (i = 0; i < assessments.length; i++) {
               if(assessmentId === assessments[i].value) {
                 selectedassessment =  assessments[i].label;
                 //component.set('v.regattaName',regattaName);
                 break;
               }
            }
        }
        if(confirm("You selected assessment \n" + selectedassessment +  "\nDo you wish to resend this?" )) {
			alert("Selected assessment will be resent now.");        
            //alert("assessmentId = " + assessmentId); 
            var p = assessmentId.split(";");
            helper.genRefereeAssessmentPDF(component, p[0], p[1], p[2] );
            
        }
	},
    
})