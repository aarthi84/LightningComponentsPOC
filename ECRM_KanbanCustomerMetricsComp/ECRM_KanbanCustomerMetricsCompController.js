({
	myAction : function(component, event, helper) {
        helper.getPrimaryTeam(component);
        helper.getHeaders(component);
        helper.getMetrics(component);
  	},
    handleApplicationEvent : function(component, event,helper) {
        component.set("v.kanbanDatas", []);
        component.set("v.selectedTeamName", "");
        var teamName = event.getParam("teamName");
        component.set("v.selectedTeamName", teamName);
        helper.getMetricsForNewTeam(component);
        
    }
})