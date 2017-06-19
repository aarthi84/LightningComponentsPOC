({
	changeFilter:function(component,event)
    {
        var dropDownType= component.get("v.type");
        var selectCmp = component.find("selection");
        var selectVal = selectCmp.get("v.value");
        var cmpEvent = $A.get("e.c:ECRM_Team_Update_Event");
        if(dropDownType=="TeamList")
        {
            cmpEvent.setParams({
            "teamNameUpdate" : selectVal });
        }
        else if(dropDownType=="HuddleList")
        {
            cmpEvent.setParams({
            "huddleTypeUpdate" : selectVal });
        }        
        cmpEvent.fire();
        console.log('Selected Value '+selectVal);        
    }
})