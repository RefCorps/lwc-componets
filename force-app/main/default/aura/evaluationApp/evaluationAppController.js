({
	getQuestions: function(cmp) {
	var action = cmp.get("c.getQuestions")
    action.setCallback(this, function(response){
    	var state = response.getState();
        if (state === "SUCCESS") {
            cmp.set("v.questions", response.getReturnValue());
        }
    });
    $A.enqueueAction(action);
}
})