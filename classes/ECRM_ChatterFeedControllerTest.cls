/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_HuddleMetricsControllerTest
// Description: This test class is for ECRM_HuddleKanbanMetricsController
// // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author               Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Fang Z -Acumen Solutions          12/14/2016      Created
// 
*/

@isTest
private class ECRM_ChatterFeedControllerTest {
    /*private static User rmoUser;
    private static ECRM_Team__c testTeam;
    private static ECRM_Team_Membership__c teamMember;
    private static FeedItem newFeed; 
    // Data Setup
    static void setup() {
        // create RMO user
        rmoUser = new User();
        rmoUser = ECMS_UtilTestData.createRMO();
        // create Team 
        testTeam = ECRM_UtilTestData.createTeam('Test', 'CDT','Atlanta','AA');
         
        /*testTeam = new ECRM_Team__c();
         testTeam.OwnerId = rmoUser.Id;
         testTeam.Team_Type__c = 'CDT';
         testTeam.Name = 'TestTeam';*/
        
         /*testTeam.ECRM_Chatter_GroupName__c = 'TestChatterGroup';
         update testTeam;
        
        //creating user
        User user = ECRM_UtilTestData.createTestUser('ECMS General User','tstfn','tstln');
        system.debug('chatterFeed..'+ 'user'+ user);
        // create Team Membership
        teamMember = ECRM_UtilTestData.createTeamMember(testTeam.id, user.id, 'CDT Lead');
        /*teamMember = new ECRM_Team_Membership__c();
         teamMember.ECRM_Member_Team__c = testTeam.Id;
         teamMember.ECRM_Member_Name__c = rmoUser.Id;
         teamMember.OwnerId = UserInfo.getUserId();
         teamMember.ECRM_Team_Member_Role__c = 'IT';*/
         //teamMember.Name = 'TestTeamMember';
        /*teamMember.ECRM_Primary__c = true;
        update teamMember;
        
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
    }
     static testMethod void testNormal() {
         setup();
         String groupName = '';
         system.runAs(rmoUser) {
            Test.startTest();
                ECRM_ChatterFeedController controller = new ECRM_ChatterFeedController();
                groupName = ECRM_ChatterFeedController.filterByGroupName();
                ECRM_ChatterFeedController.callAllCoreMethods();
                ECRM_ChatterFeedController.defaultText();
                ECRM_ChatterFeedController.errorMsgForGpMembership();
                ECRM_ChatterFeedController.errorMsgForMorePrimaryGroup();
                ECRM_ChatterFeedController.errorMsgForNoPrimaryGroup();
                ECRM_ChatterFeedController.findMembersOfTheCDTGroup();
                ECRM_ChatterFeedController.getEscalationsBySOQL();
                ECRM_ChatterFeedController.getFocusOfTheWeekBySOQL();
                ECRM_ChatterFeedController.getLoggedInUsersPrimaryCDTGroup();
                ECRM_ChatterFeedController.getNewsBySOQL();
                ECRM_ChatterFeedController.getParkingLotBySOQL();
                ECRM_ChatterFeedController.getShoutOutFeedsBySOQL();
                ECRM_ChatterFeedController.getSurveysBySOQL();
                ECRM_ChatterFeedController.getUsersPrimaryCDTGrpID();
                ECRM_ChatterFeedController.getWiloFeedsBySOQL();
                ECRM_ChatterFeedController.toRemoveDebugLogs();
                ECRM_ChatterFeedController.verifyLoggedInUserGrpMembership();
                ECRM_ChatterFeedController.fetchTopicId('SurveyTest');
                ECRM_ChatterFeedController.removeHTMLTagsFromFeedItems('<div>Test</div>');
                ECRM_ChatterFeedController.getPostText(newFeed);
            Test.stopTest();
            system.assertEquals('@null', groupName);
          }
     }
    static testMethod void testBasic() {
         String groupName = '';
            Test.startTest();
                ECRM_ChatterFeedController controller = new ECRM_ChatterFeedController();
                groupName = ECRM_ChatterFeedController.filterByGroupName();
                ECRM_ChatterFeedController.callAllCoreMethods();
                ECRM_ChatterFeedController.defaultText();
                ECRM_ChatterFeedController.errorMsgForGpMembership();
                ECRM_ChatterFeedController.errorMsgForMorePrimaryGroup();
                ECRM_ChatterFeedController.errorMsgForNoPrimaryGroup();
                ECRM_ChatterFeedController.findMembersOfTheCDTGroup();
                ECRM_ChatterFeedController.getEscalationsBySOQL();
                ECRM_ChatterFeedController.getFocusOfTheWeekBySOQL();
                ECRM_ChatterFeedController.getLoggedInUsersPrimaryCDTGroup();
                ECRM_ChatterFeedController.getNewsBySOQL();
                ECRM_ChatterFeedController.getParkingLotBySOQL();
                ECRM_ChatterFeedController.getShoutOutFeedsBySOQL();
                ECRM_ChatterFeedController.getSurveysBySOQL();
                ECRM_ChatterFeedController.getUsersPrimaryCDTGrpID();
                ECRM_ChatterFeedController.getWiloFeedsBySOQL();
                ECRM_ChatterFeedController.toRemoveDebugLogs();
                ECRM_ChatterFeedController.verifyLoggedInUserGrpMembership();
            Test.stopTest();
            system.assertEquals('@null', groupName);
     }
    static testMethod void testUserWithMultiGroups() {
        setup();
        // create Team Membership
        ECRM_Team_Membership__c teamMember2 = new ECRM_Team_Membership__c();
         teamMember2.ECRM_Member_Team__c = testTeam.Id;
         teamMember2.ECRM_Member_Name__c = rmoUser.Id;
         teamMember2.OwnerId = UserInfo.getUserId();
         teamMember2.ECRM_Team_Member_Role__c = 'IT';
         //teamMember2.Name = 'TestTeamMember2';
         teamMember2.ECRM_Primary__c = true;
         insert teamMember2;
        system.runAs(rmoUser) {
            Test.startTest();
                ECRM_ChatterFeedController controller = new ECRM_ChatterFeedController();
                ECRM_ChatterFeedController.getLoggedInUsersPrimaryCDTGroup();
                ECRM_ChatterFeedController.getFeedsByTopicAndGroupId('SurveyTest');
            Test.stopTest();
            //system.assertEquals('@null', ECRM_ChatterFeedController.filterByGroupName());
            system.assertEquals('@TestChatterGroup', ECRM_ChatterFeedController.filterByGroupName());
         }
    } 
    static testMethod void testUserNotPartOfCDTGroup() {
        setup();
        system.runAs(rmoUser) {
            Test.startTest();
                ECRM_ChatterFeedController controller = new ECRM_ChatterFeedController();
                ECRM_ChatterFeedController.getLoggedInUsersPrimaryCDTGroup();
                ECRM_ChatterFeedController.getFeedsByTopicAndGroupId('SurveyTest');
            Test.stopTest();
            system.assertEquals('@null', ECRM_ChatterFeedController.filterByGroupName());
            
         }
    } */      
}