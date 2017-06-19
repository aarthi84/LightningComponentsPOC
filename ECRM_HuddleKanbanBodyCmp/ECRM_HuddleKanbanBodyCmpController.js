({
	navigate2Component : function(component, event, helper) {
        var optNo = component.get("v.caseOptions");
        var selectedItem = event.currentTarget;
        var Name = selectedItem.dataset.record;
        console.log('data Name = '+ Name);
        console.log('optNo=' +optNo);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ECRM_HuddleCaseDetailsComponent",
             componentAttributes:{
                id : Name,
                opt : optNo
            }
        });
        evt.fire();
    }
})