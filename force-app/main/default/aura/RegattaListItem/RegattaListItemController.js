({
    regattaSelected : function(component) {
        var event = $A.get("e.c:RegattaSelected");
        event.setParams({"regatta": component.get("v.regatta")});
        event.fire();
    }
})