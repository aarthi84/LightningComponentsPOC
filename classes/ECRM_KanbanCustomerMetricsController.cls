public with sharing class ECRM_KanbanCustomerMetricsController {
    private static String ECRM_PRIMARY_TEAM_ID = null; 
    private static final String CASE_KANBAN_REC_TYPE = 'Kanban_Case';
    public static Boolean ERROR_PRIMARY_GRP_NOT_SPECIFIED = false;
    public static Map<Id,String> priorityAccMap = new Map<Id,String>();
    public static Set<Id> otherAccounts = new Set<Id>();
    public static Map<String,ECRM_Huddle_Board__c> accHuddleMap = new Map<String,ECRM_Huddle_Board__c>();
    public static Map<String,ECRM_Huddle_Board__c> accHuddleOtherMap = new Map<String,ECRM_Huddle_Board__c>();
    public static Map<String,AccountWrapperClass> finalRespMap = new Map<String,AccountWrapperClass>();
    public static String HUDDLE_OBJECT = 'ECRM_Huddle_Board__c';
    public static String RECORD_TYPE_CUSTOMER_METRICS = 'Customer_Metrics';
    public static String HUDDLE_TYPE = 'Customer Metrics';
    public static String TEBLEAU_HUDDLE_TYPE = 'Tebleau Reports';
    public static String TEBLEAU_REC_TYPE = 'TebleauReports';  
    public static String TEAM_REPORT_HUDDLE_TYPE = 'TeamReports';
    public static String TEAM_REPORT_REC_TYPE = 'TeamReports';
    public static String OTHER_REPORTS_HUDDLE_TYPE = 'OtherReports';
    public static String OTHER_REPORTS_REC_TYPE = 'OtherReports';
    public static List<AccountWrapperClass> returnResponse = new List<AccountWrapperClass>();
    public static Boolean isNew24HR = false;
    public static Boolean isDueToday = false;
    public static Boolean isDueThisWeek = false;
    public static Boolean isEscalatedReq = false;
    public static Boolean isLongTerm = false;
    public static Boolean isReqCompleted = false;
    public static Boolean isPastDue = false;
    private static String CASE_KANBAN_REC_TYPE_ID = '';

    //WrapperClass
    public class AccountWrapperClass
    {
        //variables
         @AuraEnabled public Boolean isSuccess = true;
         @AuraEnabled public String errorMsg='';//error Msg             
         @AuraEnabled public Integer new24Hr;
         @AuraEnabled public Integer dueToday;
         @AuraEnabled public Integer dueThisWeek;
         @AuraEnabled public Integer escalatedReq;
         @AuraEnabled public Integer longTerm;
         @AuraEnabled public Integer requestsComplete;
         @AuraEnabled public Integer pastDue;
         @AuraEnabled public String acctId;
         @AuraEnabled public String acctName;
         //Non-Kanban Metrics
         @AuraEnabled public String HuddleId = '';
         @AuraEnabled public String CSAT = '';
         @AuraEnabled public String Acqu_Vol = '';
         @AuraEnabled public String leopard = '';
         @AuraEnabled public String affordable = '';
         @AuraEnabled public String swindex = '';
         @AuraEnabled public String star = '';
         @AuraEnabled public String leaders_choice = '';
         @AuraEnabled public String market_share = '';
         @AuraEnabled public String DU_index = '';
         @AuraEnabled public String x60_in_6 = '';
        //initializing the variables
        public AccountWrapperClass()
        {
            acctId='';
            acctName='';
            new24Hr=0;
            dueToday=0;
            dueThisWeek=0;
            escalatedReq=0;
            longTerm=0;
            requestsComplete=0;
            pastDue=0;
                       
        }        
    }
    
    
    public static String getRecordTypeId(String sObjectName, String DeveloperName)
    {
        String devRecordTypeId = '';
        for(RecordType rType : [select Id from RecordType where sObjectType =:sObjectName and DeveloperName =:DeveloperName Limit 1])
        {
             devRecordTypeId = rType.Id;
        }
        //Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(NON_KANBAN_REC_TYPE).getRecordTypeId();
        system.debug('Record Type Id=' + devRecordTypeId);
        return devRecordTypeId;
    }
    @AuraEnabled
    public static String getTeamIdFromName (String teamNm)
	{
		String hudId = '';
		List<ECRM_Team__c> teams = new List<ECRM_Team__c>();
		teams = [SELECT ECRM_Team_code__c,Id,Name FROM ECRM_Team__c where Name =:teamNm Limit 1];
		for(ECRM_Team__c tms : teams)
		{
			hudId = tms.Id;
		}
		return hudId;
	}
    //Get Logged in User's primary CDT Team
       @AuraEnabled
       public static String getLoggedInUsersPrimaryCDTGroup()
    	{
            List<ECRM_Team_Membership__c> userCDTGroup = new List<ECRM_Team_Membership__c>();
            //system.debug('ECRM_Member_Name__c' + UserInfo.getUserId());
            userCDTGroup = [SELECT Id, Name, ECRM_Member_Team__c, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name, 
                            ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId()
                            AND ECRM_Primary__c = true];
            
            if(userCDTGroup.isEmpty())
            {
                //system.debug('User CDT primary group is empty');
                ERROR_PRIMARY_GRP_NOT_SPECIFIED = true;
            }        
            else if(userCDTGroup.size()==1)
            {
                for(ECRM_Team_Membership__c myCDT : userCDTGroup)
                {
                    //ECRM_PRIMARY_CHATTER_GP_NAME = myCDT.ECRM_Member_Team__r.ECRM_Chatter_GroupName__c;
                    ECRM_PRIMARY_TEAM_ID = myCDT.ECRM_Member_Team__c;
                }
                
            }
            return ECRM_PRIMARY_TEAM_ID;
    	}
    //From the Team Id, pull all the priority accounts from team s/s assignments + 
    //non-priority accounts -consolidate them as Other -- Kanban Metrics
    public static void getAccountsForLoggedInUserTeam(String teamID)
    {
        AccountWrapperClass accWrap;
        for(ECRM_Team_SS_Account__c accounts : [SELECT Apply_to_Main_Branch__c,ECRM_High_Priority__c,ECRM_SS_Account__c,ECRM_SS_Account__r.ECRM_Dummy_Type__c, 
                                                ECRM_SS_Account__r.RecordTypeId,ECRM_SS_Account__r.Name,ECRM_Team_Name__c,Name 
                                                FROM ECRM_Team_SS_Account__c where ECRM_Team_Name__c =:teamID ORDER BY ECRM_SS_Account__r.Name])
        {
            if(accounts.ECRM_High_Priority__c)
            { 
                priorityAccMap.put(accounts.ECRM_SS_Account__c,accounts.ECRM_SS_Account__r.Name);
                accWrap = new AccountWrapperClass();
                accWrap.acctId = accounts.ECRM_SS_Account__c;
                accWrap.acctName = accounts.ECRM_SS_Account__r.Name;
                finalRespMap.put(accWrap.acctId,accWrap);
            }
            else
                {
                    otherAccounts.add(accounts.ECRM_SS_Account__c);//All remaining accounts for kanban metrics
                }
        }
        if(!otherAccounts.isEmpty() && otherAccounts.size()>0)
        {
            List<Id> otherAccIds = new List<Id>(otherAccounts);
            accWrap = new AccountWrapperClass();
            accWrap.acctId = 'Others';
            accWrap.acctName = 'Other Accounts';
            finalRespMap.put(accWrap.acctId,accWrap);
        }
        else//We need others for Customer metrics
        {
            accWrap = new AccountWrapperClass();
            accWrap.acctId = 'Others';
            accWrap.acctName = 'Other Accounts';
            finalRespMap.put(accWrap.acctId,accWrap);
        }
	}
    public static void setTotalAcc()
    {
        AccountWrapperClass accWrap = new AccountWrapperClass();
        accWrap.acctId = 'Total';
        accWrap.acctName = 'Total';
        finalRespMap.put(accWrap.acctId,accWrap);
    }
    //In Huddle Object, check if there is any huddle record for the priority accounts with the type as Priority for the team and huddle type 
    //as cusotmer metrics
    public static void fetchPriorityAccRecordsFromHuddleObj(Set<Id> priorityAccId, String teamID)
    {
        String acctType = 'Priority';
        accHuddleMap.clear();
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        for(Id priorityAcc : priorityAccId)
        {
          huddleRec = [SELECT ID, ECRM_Account__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Acquisition_Volume__c,
                                            ECRM_Affordable__c,ECRM_Account_Type__c,ECRM_CSAT__c,ECRM_DU_Index__c,ECRM_Leaders_Choice_STP__c,
                                            ECRM_LEOPARD__c,ECRM_Market_Share__c,ECRM_STAR__c,ECRM_Swindex__c,ECRM_X60_in_6__c FROM ECRM_Huddle_Board__c 
       	where ECRM_Account__c=:priorityAcc AND ECRM_Huddle_Team__c=:teamID AND ECRM_Huddle_Type__c=:HUDDLE_TYPE LIMIT 1];
            //With that Huddle Id, get all the data needed for Customer metrics and if not find, type 'N/A'
            if(!huddleRec.isEmpty() && huddleRec.size()>0 )
            {
                accHuddleMap.put(huddleRec.get(0).ECRM_Account__c, huddleRec.get(0));
            }
            else
            {
               	ECRM_Huddle_Board__c newHuddleRec = createHuddleRecForPriorityAcc(priorityAcc,teamID, acctType, true);
                accHuddleMap.put(newHuddleRec.ECRM_Account__c, newHuddleRec);
            }
        }
    }
    //If not, create a record for the record Type Customer metrics for all priority accounts
	public static ECRM_Huddle_Board__c createHuddleRecForPriorityAcc(String acctId, String teamID, String acctType, Boolean isPriority) 
    {
        String recType = getRecordTypeId(HUDDLE_OBJECT, RECORD_TYPE_CUSTOMER_METRICS);
        ECRM_Huddle_Board__c newHuddle = new ECRM_Huddle_Board__c();
        if(isPriority)
        	newHuddle.ECRM_Account__c = acctId;
        
        newHuddle.ECRM_Account_Type__c = acctType;
        newHuddle.ECRM_Huddle_Team__c = teamID;
        newHuddle.ECRM_Acquisition_Volume__c = 'N/A';
        newHuddle.ECRM_Affordable__c = 'N/A';
        newHuddle.ECRM_CSAT__c = 'N/A';
        newHuddle.ECRM_DU_Index__c = 'N/A';
        newHuddle.ECRM_Huddle_Type__c = HUDDLE_TYPE;
        newhuddle.ECRM_Leaders_Choice_STP__c = 'N/A';
        newHuddle.ECRM_LEOPARD__c = 'N/A';
        newHuddle.ECRM_Market_Share__c = 'N/A';
        newHuddle.ECRM_STAR__c = 'N/A';
        newHuddle.ECRM_Swindex__c = 'N/A';
        newHuddle.ECRM_X60_in_6__c = 'N/A';
        newHuddle.RecordTypeId = recType;
        insert newHuddle;
        return newHuddle;        
    }
    //check for Account type as Other and Total as the account type and for the team and huddle type and add it to the Accounts list
    public static void fetchHuddleRecForOtherAndTotal (String accType, string teamID)
    {
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        String priorityAcc = '';
        huddleRec = [SELECT ID, ECRM_Account__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Acquisition_Volume__c,
                                            ECRM_Affordable__c,ECRM_Account_Type__c,ECRM_CSAT__c,ECRM_DU_Index__c,ECRM_Leaders_Choice_STP__c,
                                            ECRM_LEOPARD__c,ECRM_Market_Share__c,ECRM_STAR__c,ECRM_Swindex__c,ECRM_X60_in_6__c FROM ECRM_Huddle_Board__c 
       	where ECRM_Huddle_Team__c=:teamID AND ECRM_Huddle_Type__c=:HUDDLE_TYPE AND ECRM_Account_Type__c =:accType LIMIT 1];
        if(!huddleRec.isEmpty() && huddleRec.size()>0 )
        {
            accHuddleOtherMap.put(huddleRec.get(0).ECRM_Account_Type__c, huddleRec.get(0));
        }
        else//If not, create a record
        {
            ECRM_Huddle_Board__c newHuddleRec = createHuddleRecForPriorityAcc(priorityAcc,teamID, accType, false);
            system.debug('newHuddleRec' +newHuddleRec + 'newHuddleRec.ECRM_Account_Type__c' +newHuddleRec.ECRM_Account_Type__c);
            accHuddleOtherMap.put(newHuddleRec.ECRM_Account_Type__c, newHuddleRec);
            system.debug('accHuddleOtherMap'+accHuddleOtherMap);
        }
    }
    @AuraEnabled 
    public static List<AccountWrapperClass> getKanbanAndCustomerMetricsForTeamEvent(String teamName)
    {
        String teamId = getTeamIdFromName(teamName);
        system.debug('team Id from event' + teamId);
        return getKanbanAndCustomerMetrics(teamId);
    }
    
    //Team Reporting
     @AuraEnabled 
    public static TebleauReportsWrapper getTeamReportsForTeamEvent(String teamName)
    {
        system.debug('teamName from event'+teamName);
        String teamId = getTeamIdFromName(teamName);
        system.debug('team Id from event' + teamId);
        return getTeamReports(teamId);
    }
	//GetUserPrimaryTeamId - onload
    //From TeamId and huddle type as Tebleau report check the hud obj
    //If record found, assign it to wrapper
    //If not, create record with record type as TebleauReports assign it to wrapper
    @AuraEnabled
    public static TebleauReportsWrapper getTeamReports(String teamID)
    {
        system.debug('team Id mostly on load' + teamId);
        String cdtTeamID = '';
        if(String.isBlank(teamId))
            cdtTeamID = getLoggedInUsersPrimaryCDTGroup();
        else
            cdtTeamID = teamId;
        return createPullTeamReports(teamID);
    }
   
    public static TebleauReportsWrapper createPullTeamReports(String teamID)
    {
        TebleauReportsWrapper reportsWrapper = new TebleauReportsWrapper();
        String returnStr = '';
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        huddleRec = [SELECT ID, Team_Survey__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c FROM ECRM_Huddle_Board__c 
       	where ECRM_Huddle_Team__c=:teamID AND ECRM_Huddle_Type__c=:TEAM_REPORT_HUDDLE_TYPE LIMIT 1];
        
        if(!huddleRec.isEmpty() && huddleRec.size()>0 )
        {
            reportsWrapper.reports = huddleRec.get(0).Team_Survey__c;
            reportsWrapper.hudId = huddleRec.get(0).Id;
        }
        else//If not, create a record
        {
            ECRM_Huddle_Board__c newHuddleRec = createHuddleRecForTeam(teamID);
            reportsWrapper.reports = newHuddleRec.Team_Survey__c;
            reportsWrapper.hudId = newHuddleRec.Id;
        }
        return reportsWrapper;
    }
    public static ECRM_Huddle_Board__c createHuddleRecForTeam(String teamID)
    {
        system.debug('teamId for Tebleau'+teamID);
        String recType = getRecordTypeId(HUDDLE_OBJECT, TEAM_REPORT_REC_TYPE);
        ECRM_Huddle_Board__c newHuddle = new ECRM_Huddle_Board__c();            
        newHuddle.ECRM_Huddle_Type__c = TEAM_REPORT_HUDDLE_TYPE;
        newHuddle.ECRM_Huddle_Team__c = teamID;
        newHuddle.RecordTypeId = recType; 
        newHuddle.Team_Survey__c = 'Click here to add';
        insert newHuddle;
        system.debug('newhuddle record to display'+newHuddle);
        return newHuddle;
    }   
    
    //Other Reporting
    
     @AuraEnabled 
    public static TebleauReportsWrapper getOtherReportsForTeamEvent(String teamName)
    {
        system.debug('teamName from event'+teamName);
        String teamId = getTeamIdFromName(teamName);
        system.debug('team Id from event' + teamId);
        return getOtherReports(teamId);
    }
	//GetUserPrimaryTeamId - onload
    //From TeamId and huddle type as Tebleau report check the hud obj
    //If record found, assign it to wrapper
    //If not, create record with record type as TebleauReports assign it to wrapper
    @AuraEnabled
    public static TebleauReportsWrapper getOtherReports(String teamID)
    {
        system.debug('team Id mostly on load' + teamId);
        String cdtTeamID = '';
        if(String.isBlank(teamId))
            cdtTeamID = getLoggedInUsersPrimaryCDTGroup();
        else
            cdtTeamID = teamId;
        return createPullOtherReports(teamID);
    }
   
    public static TebleauReportsWrapper createPullOtherReports(String teamID)
    {
        TebleauReportsWrapper reportsWrapper = new TebleauReportsWrapper();
        String returnStr = '';
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        huddleRec = [SELECT ID, Other_Reports__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c FROM ECRM_Huddle_Board__c 
       	where ECRM_Huddle_Team__c=:teamID AND ECRM_Huddle_Type__c=:OTHER_REPORTS_HUDDLE_TYPE LIMIT 1];
        
        if(!huddleRec.isEmpty() && huddleRec.size()>0 )
        {
            reportsWrapper.reports = huddleRec.get(0).Other_Reports__c;
            reportsWrapper.hudId = huddleRec.get(0).Id;
        }
        else//If not, create a record
        {
            ECRM_Huddle_Board__c newHuddleRec = createHuddleRecForOtherReports(teamID);
            reportsWrapper.reports = newHuddleRec.Other_Reports__c;
            reportsWrapper.hudId = newHuddleRec.Id;
        }
        return reportsWrapper;
    }
    public static ECRM_Huddle_Board__c createHuddleRecForOtherReports(String teamID)
    {
        system.debug('teamId for Tebleau'+teamID);
        String recType = getRecordTypeId(HUDDLE_OBJECT, OTHER_REPORTS_REC_TYPE);
        ECRM_Huddle_Board__c newHuddle = new ECRM_Huddle_Board__c();            
        newHuddle.ECRM_Huddle_Type__c = OTHER_REPORTS_HUDDLE_TYPE;
        newHuddle.ECRM_Huddle_Team__c = teamID;
        newHuddle.RecordTypeId = recType; 
        newHuddle.Other_Reports__c = 'Click here to add';
        insert newHuddle;
        system.debug('newhuddle record to display'+newHuddle);
        return newHuddle;
    }
    
    
    
    @AuraEnabled 
    public static TebleauReportsWrapper getTebleauReportsForTeamEvent(String teamName)
    {
        system.debug('teamName from event'+teamName);
        String teamId = getTeamIdFromName(teamName);
        system.debug('team Id from event' + teamId);
        return getTebleauReports(teamId);
    }
	//GetUserPrimaryTeamId - onload
    //From TeamId and huddle type as Tebleau report check the hud obj
    //If record found, assign it to wrapper
    //If not, create record with record type as TebleauReports assign it to wrapper
    @AuraEnabled
    public static TebleauReportsWrapper getTebleauReports(String teamID)
    {
        system.debug('team Id mostly on load' + teamId);
        String cdtTeamID = '';
        if(String.isBlank(teamId))
            cdtTeamID = getLoggedInUsersPrimaryCDTGroup();
        else
            cdtTeamID = teamId;
        return createPullTebleauReports(teamID);
    }
    Public Class TebleauReportsWrapper
    {
        @AuraEnabled public String hudId;
        @AuraEnabled public String reports;
        public TebleauReportsWrapper()
        {
            hudId='';
            reports='';
        }
    }
    public static TebleauReportsWrapper createPullTebleauReports(String teamID)
    {
        TebleauReportsWrapper reportsWrapper = new TebleauReportsWrapper();
        String returnStr = '';
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        huddleRec = [SELECT ID, Tebleau_Reports__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c FROM ECRM_Huddle_Board__c 
       	where ECRM_Huddle_Team__c=:teamID AND ECRM_Huddle_Type__c=:TEBLEAU_HUDDLE_TYPE LIMIT 1];
        
        if(!huddleRec.isEmpty() && huddleRec.size()>0 )
        {
            reportsWrapper.reports = huddleRec.get(0).Tebleau_Reports__c;
            reportsWrapper.hudId = huddleRec.get(0).Id;
        }
        else//If not, create a record
        {
            ECRM_Huddle_Board__c newHuddleRec = createHuddleRecForTebleau(teamID);
            reportsWrapper.reports = newHuddleRec.Tebleau_Reports__c;
            reportsWrapper.hudId = newHuddleRec.Id;
        }
        return reportsWrapper;
    }
    public static ECRM_Huddle_Board__c createHuddleRecForTebleau(String teamID)
    {
        system.debug('teamId for Tebleau'+teamID);
        String recType = getRecordTypeId(HUDDLE_OBJECT, TEBLEAU_REC_TYPE);
        ECRM_Huddle_Board__c newHuddle = new ECRM_Huddle_Board__c();            
        newHuddle.ECRM_Huddle_Type__c = TEBLEAU_HUDDLE_TYPE;
        newHuddle.ECRM_Huddle_Team__c = teamID;
        newHuddle.RecordTypeId = recType; 
        newHuddle.Tebleau_Reports__c = 'Click here to add';
        insert newHuddle;
        system.debug('newhuddle record to display'+newHuddle);
        return newHuddle;
    }
	@AuraEnabled 
	public static List<AccountWrapperClass> getKanbanAndCustomerMetrics(String teamId)
    {
        system.debug('team Id mostly on load' + teamId);
        String cdtTeamID = '';
        if(String.isBlank(teamId))
            cdtTeamID = getLoggedInUsersPrimaryCDTGroup();
        else
            cdtTeamID = teamId;
        if(String.isBlank(CASE_KANBAN_REC_TYPE_ID))
            CASE_KANBAN_REC_TYPE_ID = getRecordTypeId('Case',CASE_KANBAN_REC_TYPE);
        //getLoggedInUsersPrimaryCDTGroup();//To Get the Team ID
        finalRespMap.clear();
        returnResponse.clear();                    
		getAccountsForLoggedInUserTeam(cdtTeamID);//To Get the Accounts for the Team
        setTotalAcc();//to add Total Account to the Accounts list
        if(!ERROR_PRIMARY_GRP_NOT_SPECIFIED)
        {
            //Fetch Kanban details
            //Get New last 24hr
            get24HRCaseCounts();
            //Get Due Today
            getDueTodayCaseCounts();
            //Get Due this week
            getDueThisWeekCaseCounts();
            //Get Escalated Requests
            getEscalatedReqCaseCounts();
            //Get Long Term
            getLongTermCaseCounts();
            //Get Requests Complete
            getReqCompletedCaseCounts();
            //Get PastDue
            getPastDueCaseCounts();
            //fetch accHuddleMap
            fetchPriorityAccRecordsFromHuddleObj(priorityAccMap.keySet(), cdtTeamID);
            fetchHuddleRecForOtherAndTotal('Others',cdtTeamID);
            fetchHuddleRecForOtherAndTotal('Total',cdtTeamID);
            assignCustomerMetrics();//Assign it to finalRespWrap for  customer metrics
            sortRespByOrder();
            return returnResponse;
        }
        else
        {
            	AccountWrapperClass accWrapCls = new AccountWrapperClass();
                accWrapCls.isSuccess = false;
                accWrapCls.errorMsg='Logged in user is not part of the team specified';
                //return error message
                returnResponse.add(accWrapCls);
            return returnResponse;
        }
    }
    public static void sortRespByOrder()
    {
        for(Id priorityAcc : priorityAccMap.keySet())
        {	
            returnResponse.add(finalRespMap.get(priorityAcc));
        }
            returnResponse.add(finalRespMap.get('Others'));//Add Total Records
            returnResponse.add(finalRespMap.get('Total'));//Add Total Records
    }
    public static void assignCustomerMetrics()
    {
        ECRM_Huddle_Board__c huddleObj = new ECRM_Huddle_Board__c();
        //assign priority first
        for(Id actId : priorityAccMap.keySet())
        {
            for(Id actHudId : accHuddleMap.keySet())
            {
                if(actId==actHudId)
                {
                    huddleObj = accHuddleMap.get(actHudId);
                    assignNonKanbanMetrics(finalRespMap.get(actId),huddleObj);
                }
            }
        }
        assignOtherAndTotalMetrics();
        
    }
    
    public static void assignOtherAndTotalMetrics()
    {
        system.debug('accHuddleOtherMap.get(Others)'+accHuddleOtherMap.get('Others'));
        system.debug('finalRespMap.get(Others)'+finalRespMap.get('Others'));
        assignNonKanbanMetrics(finalRespMap.get('Others'),accHuddleOtherMap.get('Others'));
        assignNonKanbanMetrics(finalRespMap.get('Total'),accHuddleOtherMap.get('Total'));
        
    }
     public static void assignNonKanbanMetrics(AccountWrapperClass accWrapCls, ECRM_Huddle_Board__c a)
    {
            AccountWrapperClass w = accWrapCls;
        	w.HuddleId = a.Id;
            w.CSAT = a.ECRM_CSAT__c;
            w.Acqu_Vol = a.ECRM_Acquisition_Volume__c;
            w.leopard = a.ECRM_LEOPARD__c;
            w.affordable = a.ECRM_Affordable__c;
            w.swindex = a.ECRM_Swindex__c;
            w.star = a.ECRM_STAR__c;
            w.leaders_choice = a.ECRM_Leaders_Choice_STP__c;
            w.market_share = a.ECRM_Market_Share__c;
            w.DU_index = a.ECRM_DU_Index__c;
            w.x60_in_6 = a.ECRM_X60_in_6__c;
    }
    
    //Kanban Case Details
     public static void get24HRCaseCounts()
    {
        //system.debug('inside get24 hr');
        isNew24HR=true;
        fetchCaseCountForPriorityAccounts(queryDBForLast24hrNewCaseCt(priorityAccMap.keySet()));
        //system.debug('successfully out priority acc get24 hr');
        if(!otherAccounts.isEmpty())
        	fetchCaseCountForOtherAccounts(queryDBForLast24hrNewCaseCt(otherAccounts));
        isNew24HR=false;
        //system.debug('successfully out get24 hr');
                
    }
    public static void getDueTodayCaseCounts()
    {
        isDueToday=true;
        fetchCaseCountForPriorityAccounts(queryDBForDueToday(priorityAccMap.keySet()));
		if(!otherAccounts.isEmpty())        
        	fetchCaseCountForOtherAccounts(queryDBForDueToday(otherAccounts));
        isDueToday=false;
                
    }
    public static void getDueThisWeekCaseCounts()
    {
        isDueThisWeek=true;
        fetchCaseCountForPriorityAccounts(queryDBForDueThisWeek(priorityAccMap.keySet()));
		if(!otherAccounts.isEmpty())        
        	fetchCaseCountForOtherAccounts(queryDBForDueThisWeek(otherAccounts));
        isDueThisWeek=false;
                
    }
    public static void getEscalatedReqCaseCounts()
    {
        isEscalatedReq=true;
        fetchCaseCountForPriorityAccounts(queryDBForEscalation(priorityAccMap.keySet()));
		if(!otherAccounts.isEmpty())        
        	fetchCaseCountForOtherAccounts(queryDBForEscalation(otherAccounts));
        isEscalatedReq=false;
                
    }
    public static void getLongTermCaseCounts()
    {
        isLongTerm=true;
        fetchCaseCountForPriorityAccounts(queryDBForLongTerm(priorityAccMap.keySet()));
        if(!otherAccounts.isEmpty())
        	fetchCaseCountForOtherAccounts(queryDBForLongTerm(otherAccounts));
        isLongTerm=false;
                
    }
    public static void getReqCompletedCaseCounts()
    {
        isReqCompleted=true;
        fetchCaseCountForPriorityAccounts(queryDBForRequestComplete(priorityAccMap.keySet()));
        if(!otherAccounts.isEmpty())
        	fetchCaseCountForOtherAccounts(queryDBForRequestComplete(otherAccounts));
        isReqCompleted=false;
                
    }
    public static void getPastDueCaseCounts()
    {
        isPastDue=true;
        fetchCaseCountForPriorityAccounts(queryDBForPastDueCases(priorityAccMap.keySet()));
        if(!otherAccounts.isEmpty())
        	fetchCaseCountForOtherAccounts(queryDBForPastDueCases(otherAccounts));
        isPastDue=false;
                
    }
    public static void fetchCaseCountForPriorityAccounts(AggregateResult[] groupResults)
    {
        //system.debug('inside  fetchcasecount');
        for(AggregateResult ar : groupResults)
            {
                ID acctID = (ID)ar.get('accountID');
                Integer count = (Integer) ar.get('expr0');
                if(acctID!=null)
                        {
                            AccountWrapperClass w = finalRespMap.get(acctID);
                            if(isNew24HR)
                                w.new24Hr = count;
                            else if(isDueToday)
                              w.dueToday = count;
                            else if(isDueThisWeek)
                              w.dueThisWeek = count;
                            else if(isEscalatedReq)
                              w.escalatedReq = count;
                            else if(isLongTerm)
                              w.longTerm = count;
                            else if(isReqCompleted)
                               w.requestsComplete = count;
                            else if(isPastDue)
                               w.pastDue = count;   
                        }            	
    		    }
        
    }
    
     public static void fetchCaseCountForOtherAccounts(AggregateResult[] groupResults)
    {
        Integer sumOfOtherAccCaseCount = 0;
        for(AggregateResult ar : groupResults)
            {
                Integer count = (Integer) ar.get('expr0');
                sumOfOtherAccCaseCount = sumOfOtherAccCaseCount + count;
            }
             AccountWrapperClass w = finalRespMap.get('Others');
                if(isNew24HR)
                    w.new24Hr = sumOfOtherAccCaseCount;
                else if(isDueToday)
                 w.dueToday = sumOfOtherAccCaseCount;
                else if(isDueThisWeek)
                 w.dueThisWeek = sumOfOtherAccCaseCount;
        		else if(isEscalatedReq)
                 w.escalatedReq = sumOfOtherAccCaseCount;
                else if(isLongTerm)
                     w.longTerm = sumOfOtherAccCaseCount;
                else if(isReqCompleted)
                    w.requestsComplete = sumOfOtherAccCaseCount;
                else if(isPastDue)
                    w.pastDue = sumOfOtherAccCaseCount;                 
                       
    }
    
    
    public static AggregateResult[] queryDBForDueThisWeek(Set<Id> accID) // Due This Week 
        {
            return [Select count(ID), accountID from Case 
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND Status ='Open' AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND ECRM_Target_Date__c = THIS_WEEK AND accountID IN :accID
                                    group by accountID];
        } 
   
	public static AggregateResult[] queryDBForPastDueCases(Set<Id> accID) // Past Due Cases
        {
             Date dateToday = System.today();
               return [Select count(ID), accountID from Case 
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND Status ='Open' AND ECRM_Date_of_Completion__c = null AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND ECRM_Target_Date__c < :dateToday AND accountID IN :accID
                                    group by accountID];
        }     
	
	public static AggregateResult[] queryDBForLast24hrNewCaseCt(Set<Id> accID) // Last 24 Hours
        {
            DateTime currentTime = System.now();
            DateTime before24Hr = currentTime.addHours(-24);
            //system.debug('accID inside query'+accID);
            List<AggregateResult> argList = new List<AggregateResult>();
            //system.debug('argList' + argList);
            //system.debug('getKanbanCaseRecTypeId()' +getKanbanCaseRecTypeId());
            argList = [Select count(ID), accountID from Case 
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND ( CreatedDate < :currentTime 
                                    and CreatedDate > :before24Hr) AND accountID IN :accID
                                           group by accountID];
            //system.debug('result='+ argList);
           return argList;
        } 
    
    public static AggregateResult[] queryDBForDueToday(Set<Id> accID)   // Due Today
        {
            Date dateToday = System.today();
              return [Select count(ID), accountID from Case 
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND Status ='Open' AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND ECRM_Target_Date__c = :dateToday AND accountID IN :accID
                                    group by accountID];
        } 
    
    public static AggregateResult[] queryDBForLongTerm(Set<Id> accID) // Long Term - Forward Looking
        {
            Date dateToday = System.today();
            Date past30Days = dateToday.addDays(-30);
              return [Select count(ID), accountID from Case 
                                    where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND status IN('Open','On Hold') AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND (ECRM_Target_Date__c != NEXT_WEEK AND ECRM_Target_Date__c != THIS_WEEK AND ECRM_Target_Date__c = NEXT_N_MONTHS:12) AND accountID IN :accID
                                    group by accountID];
        }
    
	public static AggregateResult[] queryDBForRequestComplete(Set<Id> accID) // Completed last Week - Last_n_days:7
        {
            Date dateToday = System.today();
              return [Select count(ID), accountID from Case 
                            where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Date_of_Completion__c = LAST_N_DAYS:7 AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND accountID IN :accID
                            group by accountID];
        } 
    
     public static AggregateResult[] queryDBForEscalation(Set<Id> accID) // Escalation
        {
              return [Select count(ID), accountID from Case 
                            where RecordTypeId =:CASE_KANBAN_REC_TYPE_ID AND ECRM_Escalation_Needed__c = True AND Status ='Open' AND ECRM_Team__c =:ECRM_PRIMARY_TEAM_ID AND accountID IN :accID
                            group by accountID];
        }  
    
    //Get List of Accounts 
    //Get List of Headers
    @AuraEnabled
    public static List<String> getHeaders()
    {
        List<String> accHeader = new List<String> {'Lenders','New Last 24hr','Due Today','Due This Week','Escalated Requests','Long Term','Requests Complete','Past Due','CSAT','Acquisition Volume','LEOPARD','Affordable','Swindex','STAR','Leaders Choice STP','Market Share','DU Index','60-in-6'};
		return accHeader; 
    }
}