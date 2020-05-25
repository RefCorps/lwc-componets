({
    doInit : function(component, event) {
        var action = component.get("c.findAll");
        action.setCallback(this, function(a) {
            component.set("v.regattas", a.getReturnValue());
            window.setTimeout($A.getCallback(function() {
                var event = $A.get("e.c:RegattasLoaded");
                event.setParams({"regattas": a.getReturnValue()});
                event.fire();
            }), 500);
        });
    $A.enqueueAction(action);
    }
})