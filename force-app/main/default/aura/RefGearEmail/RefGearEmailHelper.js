({
	fetchRefGearEmailTo : function(component,helper) {
       //alert("in fetchRefGearEmailTo")
        var action = component.get('c.GearExchangeEmailTo');
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {  
                var result=response.getReturnValue();
                //alert("RefGearEmailTo returned: " + result);
                component.set("v.emailToLoaded",true);
                 
                var h = '';
                if(!result.includes("<p>")) {
                
   h = '<p>This page is part of the Referee Gear Exchange project.  The following is a list of lightly used gear that`s available to anyone that needs equipment.  The goal for this project was to help newer members to the corps get good gear.</p><br/>';
   h += '<p>If you are interested in any of the gear listed below or if you find you have gear that you`d like to offer, please send an email to:</p>';
//h = h + '<lightning:formattedEmail value="' + result + '" label="Ref Gear Coordinators" />';
   h += '<div style="font-size: large;">';
   h += '<a href="mailto:' + result + '?subject=Ref Gear Inquiry" >';
   h += '<div style="font-size: large;">Ref Gear Coordinators</div>';
   h += '<i>(click to initiate email)</i></a>';
   h += '<p>One of the coordinators will contact you.</p>';
                
                } else {
                    h = result;
                }    
                    
                // component.set("v.emailTo",result);
                // h = "<p>TEST</p>";                 
                component.set("v.emailTo",h);
                
            }
            else if (state === "ERROR") {
                alert("fetchRefGearEmailTo had an error:\n[" + response.getError()[0].message + "]\nDo not use Gear Email.\nContact support. Hint: Check Apex Class Access and Static Resource GearExchangeEmailTo ");
            }
        }); 
        $A.enqueueAction(action);    
        // return 'mmiller0622@yahoo.com';
	}
})