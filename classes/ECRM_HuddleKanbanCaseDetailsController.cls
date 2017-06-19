/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_HuddleKanbanCaseDetailsController
// Description: This Controller class will be used by ECRM_HuddleKanbanCaseDetailsComponent.Account ID and options will be passed down to this controller to get the case details to be displayed at front 
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author                                   Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Aarthi R C - Acumen solutions        12/8/2016           User Story No : FEG05-40
//                             
*/
public with sharing class ECRM_HuddleKanbanCaseDetailsController {
	
    //private static final String CASE_KANBAN_REC_TYPE = 'Kanban Case';
    private static String CASE_KANBAN_REC_TYPE_ID = '';
    private static String TeamName = ''; // ECRM_Team__c =:TeamName
    private static List<String> otherAccIds = new List<String>();
    
    /*public static Id getKanbanCaseRecTypeId()
    {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_KANBAN_REC_TYPE).getRecordTypeId();
        return caseRecordTypeId;
    }*/
    
    @AuraEnabled
    public static List<Case> getCaseDetails(String accId, String optNum)
    {
        getCaseDetailsFromWrapper();
        List<String> accIds = new List<String>();
        if(accId.equals('Others'))
        {
            accIds = otherAccIds;
        }
        else
        	accIds.add(accId);
        return filterMethods(accIds,optNum);           
    }
    
    public static void getCaseDetailsFromWrapper()
    {
        ECRM_HuddleKanbanMetricsController.caseDetailsWrapper caseDetailsCls = ECRM_HuddleKanbanMetricsController.getCaseDetailsWrapCls();
        TeamName = caseDetailsCls.tName;
        otherAccIds = caseDetailsCls.otherAccIds;
        CASE_KANBAN_REC_TYPE_ID = caseDetailsCls.caseRT;
    }
    
    public static List<Case> filterMethods(List<String> accId, String optNum)
    {
        List<Case> caseDetails;
        if(optNum=='1')
        {
            caseDetails = new List<Case>();
            caseDetails = displayNewCases24Hr(accId);
        }
        else if(optNum=='2')
        {
            caseDetails = new List<Case>();
            caseDetails = displayDueTodayCases(accId);
        }
        else if(optNum=='3')
        {
            caseDetails = new List<Case>();
            caseDetails = displayDueThisWeekCases(accId);
        }
        else if(optNum=='4')
        {
            caseDetails = new List<Case>();
            caseDetails = displayEscalatedCases(accId);
        }
        else if(optNum=='5')
        {
            caseDetails = new List<Case>();
            caseDetails = displayLongTermCases(accId);
        }
        else if(optNum=='6')
        {
            caseDetails = new List<Case>();
            caseDetails = displayReqCompCases(accId);
        }
        else if(optNum=='7')
        {
            caseDetails = new List<Case>();
            caseDetails = displayPastDueCases(accId);
        }
        system.debug('caseDetails' +caseDetails);
        return caseDetails;
    }
    
    public static List<Case> displayNewCases24Hr(List<String> acctID) // Last 24 hours
        {
            DateTime currTime = System.now();
                DateTime before24Hr = currTime.addHours(-24);
                return [Select ID, caseNumber, Account.Name, Subject, ECRM_Target_Date__c,Status, Owner.Name, CreatedDate from Case 
                                where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Team__c =:TeamName   
                        		AND	CreatedDate < :currTime 
                                and CreatedDate > :before24Hr
                                and accountID IN :acctID];
        }
    
    public static List<Case> displayDueTodayCases(List<String> acctID) // Due TODAY
        {
            Date dateToday = System.today();
        	return [Select ID, caseNumber,Account.Name, Subject, ECRM_Target_Date__c, Status, Owner.Name,CreatedDate from Case 
                            where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Team__c =:TeamName AND Status ='Open'
                    		AND ECRM_Target_Date__c = :dateToday
                            and accountID IN :acctID];
        }
    
    public static List<Case> displayDueThisWeekCases(List<String> acctID)  // Due this week
        {
           return [Select ID, caseNumber, Account.Name,Subject, ECRM_Target_Date__c, Status, Owner.Name,CreatedDate from Case
                          where recordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Team__c =:TeamName AND Status ='Open'
                   			AND ECRM_Target_Date__c = THIS_WEEK
                            and accountID IN :acctID];
        }
    
    public static List<Case> displayLongTermCases(List<String> acctID)  // Display Long Term
        {
            Date dateToday = System.today();
            Date past30Days = dateToday.addDays(-30);
            return [Select ID, caseNumber, Account.Name,Subject, ECRM_Target_Date__c, Status, Owner.Name,CreatedDate from Case
                          where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Team__c =:TeamName AND (status = 'Open' OR status = 'On Hold') AND (ECRM_Target_Date__c != NEXT_WEEK AND ECRM_Target_Date__c != THIS_WEEK AND ECRM_Target_Date__c = NEXT_N_MONTHS:12) 
                    		AND accountID IN :acctID];
        }
    public static List<Case> displayReqCompCases(List<String> acctID)  // Completed Cases in last 7 Days
    	{
        	return [Select ID, caseNumber, Account.Name,Subject, ECRM_Target_Date__c, Status, Owner.Name,CreatedDate from Case
                          where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Date_of_Completion__c = LAST_N_DAYS:7 AND ECRM_Team__c =:TeamName
                            and accountID IN :acctID];
    	}
    public static List<Case> displayPastDueCases(List<String> acctID)
    {
         Date dateToday = System.today();
               return [Select ID, caseNumber, Account.Name,Subject, ECRM_Target_Date__c, Status, Owner.Name,CreatedDate from Case
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND Status ='Open' AND ECRM_Date_of_Completion__c = null AND ECRM_Team__c =:TeamName AND ECRM_Target_Date__c < :dateToday AND accountID IN :acctID];
    }
    
    public static List<Case> displayEscalatedCases(List<String> acctID)
    {
		return [Select ID, caseNumber, Account.Name,Subject, ECRM_Target_Date__c,Status, Owner.Name, CreatedDate from Case
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND Status ='Open' AND ECRM_Escalation_Needed__c = True AND ECRM_Team__c =:TeamName AND accountID IN :acctID];
    }
}