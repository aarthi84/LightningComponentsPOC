({
	myAction : function(component, event, helper) {
        var action = component.get("c.getCaseDetails");
        console.log('accId'+ component.get("v.id"));
        console.log('optNum'+ component.get("v.opt"));
        action.setParams({
            accId :component.get("v.id"),//"Others",
            optNum :component.get("v.opt")//"3"
        });
        action.setCallback(this,function(res){
            var state = res.getState();            
            if(state=="SUCCESS"){
              var result = res.getReturnValue();
                console.log('result=',result);
              component.set("v.cases",res.getReturnValue());
            }
            else if (state === "ERROR") {
                alert('Error in calling server side from case details component: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    alert('error', errors[0].pageErrors[0].message);
            }
        });        
        $A.enqueueAction(action);
	}
})