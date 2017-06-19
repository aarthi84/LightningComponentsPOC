/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_HuddleMetricsControllerTest
// Description: This test class is for ECRM_HuddleKanbanMetricsController
// // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author               Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Fang Z -Acumen Solutions          12/14/2016      Created
// Aarthi                            12/15/2016      Modified based on the recent changes in the controller class 
*/

@isTest
private class ECRM_HuddleMetricsControllerTest {
    /*private static User rmoUser;
    private static ECRM_Team__c testTeam;
    private static ECRM_Team_Membership__c teamMember;
    private static FeedItem newFeed;   
    private static Set<Id> acctIds;
    // Data Setup
    static void setup() {
        // create RMO user
        rmoUser = new User();
        rmoUser = ECMS_UtilTestData.createRMO();
        // create Team 
        testTeam = new ECRM_Team__c();
         testTeam.OwnerId = rmoUser.Id;
         testTeam.Team_Type__c = 'CDT';
         Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
         testTeam.Name = 'TestTeam'+ randomInt;
         testTeam.ECRM_Chatter_GroupName__c = 'TestChatterGroup';
         testTeam.ECRM_Region__c = 'Atlanta';
         insert testTeam;
        // create Team Membership
        teamMember = new ECRM_Team_Membership__c();
         teamMember.ECRM_Member_Team__c = testTeam.Id;
         teamMember.ECRM_Member_Name__c = rmoUser.Id;
         teamMember.OwnerId = UserInfo.getUserId();
         teamMember.ECRM_Team_Member_Role__c = 'IT';         
         //teamMember.Name = 'TestTeamMember';
         teamMember.ECRM_Primary__c = true;
         insert teamMember;
        // create Collaboration Group
        system.runAs(new User(Id = UserInfo.getUserId())){
            CollaborationGroup newGroup = new CollaborationGroup(
             Name='TestChatterGroup', CollaborationType='Public');
             insert newGroup;
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember(
             CollaborationGroupId = newGroup.Id, CollaborationRole = 'Admin', MemberId = rmoUser.Id);
             insert newGroupMember;
            Topic newTopic = new Topic(
             Description = 'testTopic', Name = 'SurveyTest');
             insert newTopic;
            newFeed = new FeedItem(
             Type = 'TextPost', Title = 'TestFeedTitle', Status = 'Published', ParentId = newGroup.Id,
             Body = '<div>TestFeed</div>');
             insert newFeed;
            TopicAssignment newAssignment = new TopicAssignment(
             TopicId = newTopic.Id, EntityId = newFeed.Id);
             insert newAssignment;
        }
        acctIds = new Set<Id>();
        List<Account> acctsToUpdate = new List<Account>();
        Set<Id> acctIdsToUpdate = new Set<Id>();
        // Create Account
        String newAccountId = '';
        String newAccountId2 = '';
        String newAccountId3 = '';
        String newAccountId4 = '';
        newAccountId = ECMS_UtilTestData.createAccount('Test Account','024680135'); 
        newAccountId2 = ECMS_UtilTestData.createAccount('Test Account2','024680136');
        newAccountId3 = ECMS_UtilTestData.createAccount('Test Account3','024680137');
        newAccountId4 = ECMS_UtilTestData.createAccount('Test Account4','024680138');
        Datetime yesterday = Datetime.now().addDays(-1);
        Datetime lastHour = Datetime.now().addHours(-1);
        Test.setCreatedDate(newAccountId3, yesterday);
        Test.setCreatedDate(newAccountId4, lastHour);
        acctIds.add(newAccountId);
        acctIds.add(newAccountId2);
        acctIds.add(newAccountId3);
        acctIds.add(newAccountId4);
        acctIdsToUpdate.add(newAccountId3);
        acctIdsToUpdate.add(newAccountId4);
        Boolean isSet = false;
        for (Account acct: [Select Id, Name, ECRM_Dummy_Type__c From Account Where Id IN: acctIdsToUpdate]) {
            if(!isSet && acct.ECRM_Dummy_Type__c == null) {
                acct.ECRM_Dummy_Type__c = 'Total';
                isSet = true;
            } else if (isSet && acct.ECRM_Dummy_Type__c == null) {
                acct.ECRM_Dummy_Type__c = 'Other';
            }
            acctsToUpdate.add(acct);
        }
        update acctsToUpdate;
        // Create Cases
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Kanban Case').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case newCase1 = new Case();
        newCase1 = ECMS_UtilTestData.createCase(newAccountId);
        newCase1.Status = 'Open';
        newCase1.RecordTypeId = caseRecordTypeId;
        caseList.add(newCase1);
        Case newCase2 = new Case();
        newCase2 = ECMS_UtilTestData.createCase(newAccountId2);
        newCase2.Status = 'Open';
        newCase2.RecordTypeId = caseRecordTypeId;
        caseList.add(newCase2);
        Case newCase3 = new Case();
        newCase3 = ECMS_UtilTestData.createCase(newAccountId3);
        newCase3.Status = 'Open';
        newCase3.RecordTypeId = caseRecordTypeId;
        caseList.add(newCase3);
        Case newCase4 = new Case();
        newCase4 = ECMS_UtilTestData.createCase(newAccountId4);
        newCase4.Status = 'Open';
        newCase4.RecordTypeId = caseRecordTypeId;
        caseList.add(newCase4);
        update caseList;
        // Create Team Seller Servicer Accounts
        List<ECRM_Team_SS_Account__c> teamAccList = new List<ECRM_Team_SS_Account__c>();
        ECRM_Team_SS_Account__c teamAcct1 = new ECRM_Team_SS_Account__c(
         ECRM_SS_Account__c = newAccountId, ECRM_Team_Name__c = testTeam.Id, OwnerId = UserInfo.getUserId());
        teamAccList.add(teamAcct1);
        ECRM_Team_SS_Account__c teamAcct2 = new ECRM_Team_SS_Account__c(
         ECRM_SS_Account__c = newAccountId2, ECRM_Team_Name__c = testTeam.Id, OwnerId = UserInfo.getUserId(), ECRM_High_Priority__c = true);
        teamAccList.add(teamAcct2);
        ECRM_Team_SS_Account__c teamAcct3 = new ECRM_Team_SS_Account__c(
         ECRM_SS_Account__c = newAccountId3, ECRM_Team_Name__c = testTeam.Id, OwnerId = rmoUser.Id, ECRM_High_Priority__c = true);
        teamAccList.add(teamAcct3);
        ECRM_Team_SS_Account__c teamAcct4 = new ECRM_Team_SS_Account__c(
         ECRM_SS_Account__c = newAccountId4, ECRM_Team_Name__c = testTeam.Id, OwnerId = rmoUser.Id, ECRM_High_Priority__c = true);
        teamAccList.add(teamAcct4);
        insert teamAccList;
    }
    static testMethod void testBasic() {
        Test.startTest();
            ECRM_HuddleKanbanMetricsController controller = new ECRM_HuddleKanbanMetricsController();
            ECRM_HuddleKanbanMetricsController.getAccountsForLoggedInUserTeam();
            ECRM_HuddleKanbanMetricsController.getDueThisWeekCaseCounts();
            ECRM_HuddleKanbanMetricsController.get24HRCaseCounts();
            ECRM_HuddleKanbanMetricsController.getDueTodayCaseCounts();
            ECRM_HuddleKanbanMetricsController.getHeaderForKanbanAccs();
            ECRM_HuddleKanbanMetricsController.getHeaderForNonKanbanAccs();
            //ECRM_HuddleKanbanMetricsController.getKanbanCaseRecTypeId();
            ECRM_HuddleKanbanMetricsController.getKanbanMetricsForAccs();
            ECRM_HuddleKanbanMetricsController.getLoggedInUsersPrimaryCDTGroup();
            ECRM_HuddleKanbanMetricsController.getLongTermCaseCounts();
            ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetrics();
            ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetricsForOtherAccs();
            ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetricsForPriorityAccs();
            ECRM_HuddleKanbanMetricsController.getNonKanbanMetricsForAccs();
            ECRM_HuddleKanbanMetricsController.getOtherAccIdsForCases();
            ECRM_HuddleKanbanMetricsController.getPastDueCaseCounts();
            //ECRM_HuddleKanbanMetricsController.getRecordTypeId();
            ECRM_HuddleKanbanMetricsController.getReqCompletedCaseCounts();
            ECRM_HuddleKanbanMetricsController.queryforNonKanbanPriorityAcc();
            ECRM_HuddleKanbanMetricsController.setOtherAccForNonKanban();
            ECRM_HuddleKanbanMetricsController.setTotalAcc();
        Test.stopTest();
        system.assertEquals(true, ECRM_HuddleKanbanMetricsController.MEMBER_NOT_PART_OF_A_TEAM);
    }
    
     static testMethod void testNormal() {
         setup();
         String groupName = '';
         List<Account> accountList = [Select Id, Name, ECRM_CSAT__c, ECRM_Acquisition_Volume__c,
                                      ECRM_LEOPARD__c, ECRM_Affordable__c, ECRM_Swindex__c,
                                      ECRM_STAR__c, ECRM_Leaders_Choice_STP__c, ECRM_Market_Share__c,
                                      ECRM_DU_Index__c, ECRM_X60_in_6__c
                                      From Account];
         system.runAs(rmoUser) {
             Test.startTest();
                ECRM_HuddleKanbanMetricsController controller = new ECRM_HuddleKanbanMetricsController();
                ECRM_HuddleKanbanMetricsController.getAccountsForLoggedInUserTeam();
                ECRM_HuddleKanbanMetricsController.getDueThisWeekCaseCounts();
                ECRM_HuddleKanbanMetricsController.get24HRCaseCounts();
                ECRM_HuddleKanbanMetricsController.getDueTodayCaseCounts();
                ECRM_HuddleKanbanMetricsController.getHeaderForKanbanAccs();
                ECRM_HuddleKanbanMetricsController.getHeaderForNonKanbanAccs();
                //ECRM_HuddleKanbanMetricsController.getKanbanCaseRecTypeId();
                ECRM_HuddleKanbanMetricsController.getKanbanMetricsForAccs();
                ECRM_HuddleKanbanMetricsController.getLoggedInUsersPrimaryCDTGroup();
                ECRM_HuddleKanbanMetricsController.getLongTermCaseCounts();
                ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetrics();
                ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetricsForOtherAccs();
                ECRM_HuddleKanbanMetricsController.getNonKanbanAccMetricsForPriorityAccs();
                ECRM_HuddleKanbanMetricsController.getNonKanbanMetricsForAccs();
                ECRM_HuddleKanbanMetricsController.getOtherAccIdsForCases();
                ECRM_HuddleKanbanMetricsController.getPastDueCaseCounts();
                //ECRM_HuddleKanbanMetricsController.getRecordTypeId();
                ECRM_HuddleKanbanMetricsController.getReqCompletedCaseCounts();
                ECRM_HuddleKanbanMetricsController.queryforNonKanbanPriorityAcc();
                ECRM_HuddleKanbanMetricsController.setOtherAccForNonKanban();
                ECRM_HuddleKanbanMetricsController.setTotalAcc();
                ECRM_HuddleKanbanMetricsController.sortRespByOrder(true);
                ECRM_HuddleKanbanMetricsController.sortRespByOrder(false);
                ECRM_HuddleKanbanMetricsController.filterNonKanbanMetricsAssignment(accountList, 'Other');
                ECRM_HuddleKanbanMetricsController.filterNonKanbanMetricsAssignment(accountList, 'Total');
                ECRM_HuddleKanbanMetricsController.filterNonKanbanMetricsAssignment(accountList, 'Priority');
                ECRM_HuddleKanbanMetricsController.getEscalatedReqCaseCounts();
                ECRM_HuddleKanbanMetricsController.queryDBForDueThisWeek(acctIds);
                ECRM_HuddleKanbanMetricsController.MEMBER_NOT_PART_OF_A_TEAM = false;
                ECRM_HuddleKanbanMetricsController.callRelatedMethods(true);
                ECRM_HuddleKanbanMetricsController.callRelatedMethods(false);
                ECRM_HuddleKanbanMetricsController.getAccDummyType('Other', acctIds);
                ECRM_HuddleKanbanMetricsController.getAccDummyType('Total', acctIds);
             Test.stopTest();
             system.assertEquals(false, ECRM_HuddleKanbanMetricsController.MEMBER_NOT_PART_OF_A_TEAM);
         }
     }*/
}