/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_HuddleKanbanMetricsController
// Description: This Controller class will be used by ECRM_HuddleKanbanParentComponent and ECRM_HuddleNonKanbanParentComponent and it's nested components of ECRM_HuddleKanbanBodyComponent,ECRM_HuddleNonKanbanBodyComponent,ECRM_HuddleKanbanMetricsHeaderComponent.
// // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author                                   Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Aarthi R C - Acumen solutions        12/7/2016           User Story No : Kanban- FEG05-40 , Non-Kanban - FEG05-10
//                             
*/
public with sharing class ECRM_HuddleKanbanMetricsController {
	//Static variables
    private static final String NON_KANBAN_REC_TYPE = 'CDT_Dummy_Account';
    private static final String CASE_KANBAN_REC_TYPE = 'Kanban_Case';
    private static final String CDT_DUMMY_TYPE_OTHER = 'Other';
    private static final String CDT_DUMMY_TYPE_TOTAL = 'Total';
    private static String NON_KANBAN_REC_TYPE_ID = '';
    private static String CASE_KANBAN_REC_TYPE_ID = '';
    private static String ECRM_PRIMARY_CHATTER_GP_ID = null;
    private static String ECRM_PRIMARY_CHATTER_GP_NAME = null;
    private static String ECRM_PRIMARY_TEAM_ID = null; 
    public static Boolean ERROR_PRIMARY_GRP_NOT_SPECIFIED = false;
    public static Boolean USER_PART_OF_PRIMARY_GRP = false;
    public static Boolean IS_MORE_PRIMARY_GRP_SPECIFIED = false;
    public static Boolean MEMBER_NOT_PART_OF_A_TEAM = false;       
    public static Boolean isNew24HR = false;
    public static Boolean isDueToday = false;
    public static Boolean isDueThisWeek = false;
    public static Boolean isEscalatedReq = false;
    public static Boolean isLongTerm = false;
    public static Boolean isReqCompleted = false;
    public static Boolean isPastDue = false;
    public static set<Id> otherTypeAccs = new Set<Id>();
    public static set<Id> totalTypeAccs = new Set<Id>();
    public static Map<Id,String> priorityAccMap = new Map<Id,String>();
    public static Set<Id> otherAccounts = new Set<Id>();
    public static Map<String,AccountWrapperClass> finalRespMap = new Map<String,AccountWrapperClass>();
    public static List<AccountWrapperClass> returnResponse = new List<AccountWrapperClass>();
    
    @AuraEnabled
    public static List<AccountWrapperClass> getKanbanMetricsForAccs()
    {
        //should not have Total
        return callRelatedMethods(false);
    }
    @AuraEnabled
    public static List<AccountWrapperClass> getNonKanbanMetricsForAccs()
    {
        //should have total
        return callRelatedMethods(true);
    }
    
    //find logged in user's Team ID
    public static void getLoggedInUsersPrimaryCDTGroup()
    {
        List<ECRM_Team_Membership__c> userCDTGroup = new List<ECRM_Team_Membership__c>();
        system.debug('ECRM_Member_Name__c' + UserInfo.getUserId());
        userCDTGroup = [SELECT Id, Name, ECRM_Member_Team__c, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name, 
            ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId()
                AND ECRM_Primary__c = true];
        
        if(userCDTGroup.isEmpty())
        {
            //system.debug('User CDT primary group is empty');
            ERROR_PRIMARY_GRP_NOT_SPECIFIED = true;
        }
        else if(userCDTGroup.size()>1)
        {
            //system.debug('CDT primary group has been specified more than once');
            IS_MORE_PRIMARY_GRP_SPECIFIED = true;
        }
        else if(userCDTGroup.size()==1)
        {
            for(ECRM_Team_Membership__c myCDT : userCDTGroup)
            {
                //ECRM_PRIMARY_CHATTER_GP_NAME = myCDT.ECRM_Member_Team__r.ECRM_Chatter_GroupName__c;
                ECRM_PRIMARY_TEAM_ID = myCDT.ECRM_Member_Team__c;
            }
           
        }
    }
    
    //from the team, have to get high priority and other accounts
    public static void getAccountsForLoggedInUserTeam()
    {
        if(String.isBlank(ECRM_PRIMARY_TEAM_ID))
        {
            MEMBER_NOT_PART_OF_A_TEAM = true;
        }
        else
        {  
            AccountWrapperClass accWrap;
            for(ECRM_Team_SS_Account__c accounts : [SELECT Apply_to_Main_Branch__c,ECRM_High_Priority__c,ECRM_SS_Account__c,ECRM_SS_Account__r.ECRM_Dummy_Type__c, 
                                                    ECRM_SS_Account__r.RecordTypeId,ECRM_SS_Account__r.Name,ECRM_Team_Name__c,Name 
                                                    FROM ECRM_Team_SS_Account__c where ECRM_Team_Name__c =:ECRM_PRIMARY_TEAM_ID ORDER BY ECRM_SS_Account__r.Name])
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
                    String dummyType = accounts.ECRM_SS_Account__r.ECRM_Dummy_Type__c;
                    String accRecType = accounts.ECRM_SS_Account__r.RecordTypeId;
                    if('Other'.equalsIgnoreCase(dummyType) && NON_KANBAN_REC_TYPE_ID.equals(accRecType))
                    {
                        otherTypeAccs.add(accounts.ECRM_SS_Account__c);//accounts for other 
                    }
                    else if('Total'.equalsIgnoreCase(dummyType) && NON_KANBAN_REC_TYPE_ID.equals(accRecType))
                    {
                        totalTypeAccs.add(accounts.ECRM_SS_Account__c);//accounts for Total
                    }                    
                    else
                    {
                        otherAccounts.add(accounts.ECRM_SS_Account__c);//All remaining accounts for kanban metrics
                    }
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
            
        }            
    }
    //For Non-Kanban Metrics
    public static void setOtherAccForNonKanban()
    {
        AccountWrapperClass accWrap = new AccountWrapperClass();
        accWrap.acctId = 'Other';
        accWrap.acctName = 'Other';
        finalRespMap.put(accWrap.acctId,accWrap);
    }
    public static void setTotalAcc()
    {
        AccountWrapperClass accWrap = new AccountWrapperClass();
        accWrap.acctId = 'Total';
        accWrap.acctName = 'Total';
        finalRespMap.put(accWrap.acctId,accWrap);
    }
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
       
    public static List<AccountWrapperClass> callRelatedMethods(Boolean isNonKanban)
    {
        if(String.isBlank(NON_KANBAN_REC_TYPE_ID))
        	NON_KANBAN_REC_TYPE_ID = getRecordTypeId('Account',NON_KANBAN_REC_TYPE);
        if(String.isBlank(CASE_KANBAN_REC_TYPE_ID))
            CASE_KANBAN_REC_TYPE_ID = getRecordTypeId('Case',CASE_KANBAN_REC_TYPE);
        system.debug('NON_KANBAN_REC_TYPE_ID'+NON_KANBAN_REC_TYPE_ID);
        system.debug('CASE_KANBAN_REC_TYPE_ID'+CASE_KANBAN_REC_TYPE_ID);
        getLoggedInUsersPrimaryCDTGroup();//To Get the Team ID
        finalRespMap.clear();
        returnResponse.clear();                    
		getAccountsForLoggedInUserTeam();//To Get the Accounts for the Team
        //check for Errors
        if(!ERROR_PRIMARY_GRP_NOT_SPECIFIED && !IS_MORE_PRIMARY_GRP_SPECIFIED)
        {
            if(MEMBER_NOT_PART_OF_A_TEAM)
            {
                AccountWrapperClass accWrapCls = new AccountWrapperClass();
                accWrapCls.isSuccess = false;
                accWrapCls.errorMsg='Logged in user is not part of the team specified';
                //return error message
                returnResponse.add(accWrapCls);
                return returnResponse;
            }
            else 
            {
                //system.debug('inside else condition');
                if(isNonKanban)
                {
                    setOtherAccForNonKanban();
                    setTotalAcc();
        			getNonKanbanAccMetrics();
                    sortRespByOrder(isNonKanban);
                    //system.debug('successfully finished non-kanbnareturnresp=' +returnResponse);
                    return returnResponse;
                }
                else{
                    //system.debug('inside kanban else');
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
                    sortRespByOrder(isNonKanban);
                    //system.debug('successfully finished kanbnareturnresp=' +returnResponse);
                    return returnResponse;
                }
            }
        }
        return returnResponse;
    }
        
    public static void sortRespByOrder(Boolean isNonKanban)
    {
        for(Id priorityAcc : priorityAccMap.keySet())
        {	
            returnResponse.add(finalRespMap.get(priorityAcc));
        }
        //Add others account for Kanban Metrics
        if(!isNonKanban)
        	returnResponse.add(finalRespMap.get('Others'));
        if(isNonKanban)
        {
            returnResponse.add(finalRespMap.get('Other'));//Add Total Records
            returnResponse.add(finalRespMap.get('Total'));//Add Total Records
        }
        	
    }
    
    public static void getNonKanbanAccMetrics()
    {
        getNonKanbanAccMetricsForPriorityAccs();
        getNonKanbanAccMetricsForOtherAccs();
    }
    
    public static void getNonKanbanAccMetricsForOtherAccs()
    {
        //get Account with the ECRM_Dummy_Type__c as Other and account recordType as CDT_Dummy_Account
        List<Account> dummyOtherAccs = new List<Account>();
        List<Account> dummyTotalAccs = new List<Account>();
		        dummyOtherAccs = getAccDummyType(CDT_DUMMY_TYPE_OTHER,otherTypeAccs);
        		dummyTotalAccs = getAccDummyType(CDT_DUMMY_TYPE_TOTAL,totalTypeAccs);
        if(!dummyOtherAccs.isEmpty())
        	filterNonKanbanMetricsAssignment(dummyOtherAccs,'Other');
        ////get Account with the ECRM_Dummy_Type__c as Total and account recordType as CDT_Dummy_Account
        if(!dummyTotalAccs.isEmpty())
        	filterNonKanbanMetricsAssignment(dummyTotalAccs,'Total'); 
        //system.debug('getAccDummyType(CDT_DUMMY_TYPE_OTHER)'+dummyOtherAccs);
        //system.debug('getAccDummyType(CDT_DUMMY_TYPE_TOTAL)'+dummyTotalAccs);
    }
    
    public static List<Account> getAccDummyType(String type, Set<Id> accIds)
    {
        if(accIds.isEmpty())
        {
            return new List<Account>();
        }
        else
        	return [SELECT Id,ECRM_Dummy_Type__c,RecordTypeId,ECRM_CSAT__c,ECRM_Acquisition_Volume__c,ECRM_LEOPARD__c,ECRM_Affordable__c,
			ECRM_Swindex__c,ECRM_STAR__c,ECRM_Leaders_Choice_STP__c,ECRM_Market_Share__c,ECRM_DU_Index__c,ECRM_X60_in_6__c
         	from Account Where Id IN : accIds AND RecordTypeId =:NON_KANBAN_REC_TYPE_ID AND ECRM_Dummy_Type__c =: type];
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
    
    /*public static Id getKanbanCaseRecTypeId()
    {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_KANBAN_REC_TYPE).getRecordTypeId();
        return caseRecordTypeId;
    }*/
    
    public static void assignNonKanbanMetrics(AccountWrapperClass accWrapCls, Account a)
    {
        //system.debug('accWrapCls='+accWrapCls);
        if(accWrapCls!=Null)
        {        
        AccountWrapperClass w = accWrapCls;
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
        else
        {
            system.debug('accWrapCla is null');
        }
    }
    
    public static void filterNonKanbanMetricsAssignment(List<Account> acc, String accType)
    {
        //system.debug('acc=' + acc);
        if(acc!=Null || !acc.isEmpty())
        {
            AccountWrapperClass w;
                if(accType.equals('Other'))
                {
                    w = new AccountWrapperClass();
                    w = finalRespMap.get(accType);
                    //system.debug('**************** other accWrapClass' +finalRespMap.get(accType) );
                    assignNonKanbanMetrics(w,acc.get(0));
                }
                else if(accType.equals('Total'))
                {
                    w = new AccountWrapperClass();
                    w = finalRespMap.get(accType);                    
                    assignNonKanbanMetrics(w,acc.get(0));
                }
                else if(accType.equals('Priority'))
                {
                    for(Account a : acc)
                    {
                        w = new AccountWrapperClass();
                        w = finalRespMap.get(a.Id);
                        assignNonKanbanMetrics(w, a);
                    }
                }
        }
        
        
    }
    
    public static void getNonKanbanAccMetricsForPriorityAccs()
    {
        system.debug('queryforNonKanbanPriorityAcc()'+queryforNonKanbanPriorityAcc());
       		filterNonKanbanMetricsAssignment(queryforNonKanbanPriorityAcc(),'Priority');
    }
    
    public static List<Account> queryforNonKanbanPriorityAcc()
    {
        return [SELECT Id,ECRM_Dummy_Type__c,ECRM_CSAT__c,ECRM_Acquisition_Volume__c,ECRM_LEOPARD__c,ECRM_Affordable__c,
		ECRM_Swindex__c,ECRM_STAR__c,ECRM_Leaders_Choice_STP__c,ECRM_Market_Share__c,ECRM_DU_Index__c,ECRM_X60_in_6__c
         from Account where Id IN :priorityAccMap.keySet()];
    }
    
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
    
   
    @AuraEnabled
    public static List<String> getHeaderForKanbanAccs()
    {
        List<String> accHeader = new List<String> {'Lenders','New Last 24hr','Due Today','Due This Week','Escalated Requests','Long Term','Requests Complete','Past Due'};
		return accHeader;        
    }
    @AuraEnabled
    public static List<String> getHeaderForNonKanbanAccs()
    {
        List<String> nonKanbanHeader = new List<String>{'Lenders','CSAT','Acquisition Volume','LEOPARD','Affordable','Swindex','STAR','Leaders Choice STP','Market Share','DU Index','60-in-6'};
		return nonKanbanHeader;
    }
    
    public class caseDetailsWrapper
    {
        public String tName ='';
        public String caseRT = '';
        public List<String> otherAccIds = new List<String>();
        
        caseDetailsWrapper()
        {
            otherAccIds = getOtherAccIdsForCases();
            tName = ECRM_PRIMARY_TEAM_ID;
            caseRT = CASE_KANBAN_REC_TYPE_ID;
        }
    }
    
    public static caseDetailsWrapper getCaseDetailsWrapCls()
    {
        return new caseDetailsWrapper();
    }
     //for the case detail page
      public static List<String> getOtherAccIdsForCases()
        {
            finalRespMap.clear();
            returnResponse.clear();
            getLoggedInUsersPrimaryCDTGroup();
            if(String.isBlank(NON_KANBAN_REC_TYPE_ID))
        		NON_KANBAN_REC_TYPE_ID = getRecordTypeId('Account',NON_KANBAN_REC_TYPE);
            if(String.isBlank(CASE_KANBAN_REC_TYPE_ID))
            	CASE_KANBAN_REC_TYPE_ID = getRecordTypeId('Case',CASE_KANBAN_REC_TYPE);
            getAccountsForLoggedInUserTeam();
            List<Id> otherAccIds = new List<Id>(otherAccounts);
            return otherAccIds;
        }
}