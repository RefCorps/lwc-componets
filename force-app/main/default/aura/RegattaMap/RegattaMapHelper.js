({
    navigateToDetailsView : function(regattaId) {
        var event = $A.get("e.force:navigateToSObject");
        console.log(regattaId);
        event.setParams({
            "recordId": regattaId
        });
        event.fire();
    }
})