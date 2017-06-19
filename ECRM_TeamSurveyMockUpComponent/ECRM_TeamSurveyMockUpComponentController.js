({
	 myAction : function(component, event, helper) {
        helper.getPrimaryTeam(component);
        helper.getReports(component);
       
    },
    handleApplicationEvent : function(component, event,helper) {
        component.find("getValue").set("v.myVal","");
        component.set("v.myVal","");
        component.set("v.selectedTeamName", "");
        var teamName = event.getParam("teamName");
        console.log('teamNamefromTableau' + teamName);
        component.set("v.selectedTeamName", teamName);
        helper.getReportsForNewTeam(component);		
    }
})