/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_ChatterFeedController
// Description: This Apex class will be used by several Lightning Components to fetch the feeds on specific topic under logged in user's primary CDT Chatter group.
// // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author                                   Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Aarthi R C - Acumen solutions        12/01/2016           User Story Nos : FEG05-12,FEG05-48,FEG05-18,FEG05-51,FEG05-31,FEG05-32,FEG05-41
//                             
*/

public with Sharing class ECRM_ChatterFeedController {
    //Topic names
    private static final String SHOUT_OUT ='Shoutout';
    private static final String FOCUS_OF_THE_WEEK='focusoftheweek';
    private static final String NEWS='news';
    private static final String PARKING_LOT='parkinglot';
    private static final String ESCALATIONS='escalation';
    private static final String SURVEY='Survey';
    private static final String WILO='WILO';
    //Display no of items at the front end
    private static final Integer LIST_ITEMS_TO_DISPLAY = 5;
    //Error message boolean Indicator
    public static Boolean ERROR_PRIMARY_GRP_NOT_SPECIFIED = false;
    //public static Boolean ERROR_NO_MEMBERSHIP_TO_GRP = false;
    public static Boolean USER_PART_OF_PRIMARY_GRP = false;
    public static Boolean IS_MORE_PRIMARY_GRP_SPECIFIED = false;
    //Static variable
    public static String ECRM_PRIMARY_TEAM_NAME = null;
    public static String ECRM_PRIMARY_CHATTER_GP_ID = null;
    public static String ECRM_PRIMARY_CHATTER_GP_NAME = null;
    public static set<Id> memberIdListOfPrimaryGrp = new set<Id>();
    public static set<Id> memberIdListForTeam = new set<Id>();
    public static String CDT_TEAM_NAME = '';
    
    //public static Map<Id,CollaborationGroupMember> chatterGrpMemMap = new Map<Id,CollaborationGroupMember>();
    
    @AuraEnabled
    public static FeedWrapperClass getShoutOutFeedsBySOQL(String topicName)
    {
       return getFeedsByTopicAndGroupId(topicName);
       //return getFeedsByTopicAndGroupId4Team(SHOUT_OUT);
    }

    @AuraEnabled
    public static FeedWrapperClass getShoutOutFeeds4Team(String teamNmae, String topic)
    {
       system.debug('initial Team Name' + teamNmae + ' topic' + topic);
       return getFeedsByTopicAndGroupId4Team(teamNmae,topic);
    }

    @AuraEnabled
    public static FeedWrapperClass getFocusOfTheWeekBySOQL()
    {
       return getFeedsByTopicAndGroupId(FOCUS_OF_THE_WEEK);
    }
   
    @AuraEnabled
    public static FeedWrapperClass getNewsBySOQL()
    {
     return getFeedsByTopicAndGroupId(NEWS);
    }
    @AuraEnabled
    public static FeedWrapperClass getParkingLotBySOQL()
    {
       return getFeedsByTopicAndGroupId(PARKING_LOT);
    }
    @AuraEnabled
    public static FeedWrapperClass getEscalationsBySOQL()
    {
       return getFeedsByTopicAndGroupId(ESCALATIONS);
    }
    @AuraEnabled
    public static FeedWrapperClass getSurveysBySOQL()
    {
       return getFeedsByTopicAndGroupId(SURVEY);
    }
    @AuraEnabled
    public static FeedWrapperClass getWiloFeedsBySOQL()
    {
       return getFeedsByTopicAndGroupId(WILO);
    }
   
    
    public class FeedWrapperClass
    {
        //variables
         @AuraEnabled public Boolean isSuccess;
         @AuraEnabled public String errorMsg;//error Msg
         @AuraEnabled public List<FeedItem> feedLists;
         @AuraEnabled public String msgStr;//Default Text  
         @AuraEnabled public String teamName;//Default Text       
        //initializing the variables
        public FeedWrapperClass()
        {
            isSuccess=true;
            errorMsg = '';
            feedLists = new List<FeedItem>();
            msgStr ='';
            teamName = '';
            
        }        
    }
    //Main method which pulls the FeedItems
    public static FeedWrapperClass getFeedsByTopicAndGroupId(String topicName)
    {
         //Initializing the wrapper message 
        FeedWrapperClass returnMessage = new FeedWrapperClass();
        List<FeedItem> feedItemList = new List<FeedItem>();
        String feedBody ='';
        Integer count = 0;       
        //calling base methods
        callAllCoreMethods();
        
        if(ERROR_PRIMARY_GRP_NOT_SPECIFIED)//When logged in user does not have primary group specified
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForNoPrimaryGroup();
            return returnMessage;
        }
        if(IS_MORE_PRIMARY_GRP_SPECIFIED)//when logged in user have more than one primary group
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForMorePrimaryGroup();
            return returnMessage;
        }
        if(!USER_PART_OF_PRIMARY_GRP)//when logged in user not part of the primary CDT group
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForGpMembership();
            return returnMessage;
        }        
        try
        {
            for(FeedItem feed : [SELECT  Id, Body, CommentCount, CreatedDate, ParentId, RelatedRecordId, Title, Type,CreatedBy.Name, CreatedById, InsertedById, Status
            FROM FeedItem WHERE Id IN (SELECT EntityId FROM TopicAssignment WHERE EntityType = 'FeedItem' AND TopicId =: fetchTopicId(topicName)
            ) AND (ParentId =:ECRM_PRIMARY_CHATTER_GP_ID OR ParentId IN :memberIdListOfPrimaryGrp) ORDER BY CreatedDate Desc])
                {
                    if(count==LIST_ITEMS_TO_DISPLAY)
                        break;
                    feedBody = feed.Body;
                    if((feed.ParentId==ECRM_PRIMARY_CHATTER_GP_ID) ||(feedBody.contains(filterByGroupName())))
                    {
                        feed.Body = getPostText(feed,topicName,ECRM_PRIMARY_CHATTER_GP_NAME);
                        count++;
                        feedItemList.add(feed);
                    }
                    
                }
            if(feedItemList.isEmpty())//When there is no feeds available under that topic   
                {
                    system.debug('I ma in empty feedList');
                    returnMessage.isSuccess=false;
                    returnMessage.msgStr=defaultText();
                    return returnMessage;
                }
            else
                {
                    returnMessage.isSuccess=true;
                    returnMessage.feedLists=feedItemList;
                    returnMessage.teamName=ECRM_PRIMARY_TEAM_NAME;
                    return returnMessage;
                }
        }
        catch(Exception e)
        {
            returnMessage.isSuccess = false;
            returnMessage.errorMsg =e.getMessage();
            return returnMessage;
        }         
        
    }

    public static Id getTeamIdFromName (String teamNm)
    {
        Id hudId;
        List<ECRM_Team__c> teams = new List<ECRM_Team__c>();
        teams = [SELECT ECRM_Team_code__c,Id,Name FROM ECRM_Team__c where Name =:teamNm Limit 1];
        for(ECRM_Team__c tms : teams)
        {
            hudId = tms.Id;
        }
        return hudId;
    }

    public static FeedWrapperClass getFeedsByTopicAndGroupId4Team(String teamName, String topicName)
    {
         //Initializing the wrapper message 
        FeedWrapperClass returnMessage = new FeedWrapperClass();
        List<FeedItem> feedItemList = new List<FeedItem>();
        String feedBody ='';
        Integer count = 0;
        Id teamId = getUsersCDTGrpID(teamName);
        system.debug('teamId'+teamId);
        findMembersOfTheCDTTeam(teamId);
        system.debug('Topic Id'+fetchTopicId(topicName));
        system.debug('memlist'+memberIdListForTeam);
        //calling base methods
            //callAllCoreMethods();
        
        /*if(ERROR_PRIMARY_GRP_NOT_SPECIFIED)//When logged in user does not have primary group specified
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForNoPrimaryGroup();
            return returnMessage;
        }
        if(IS_MORE_PRIMARY_GRP_SPECIFIED)//when logged in user have more than one primary group
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForMorePrimaryGroup();
            return returnMessage;
        }
        if(!USER_PART_OF_PRIMARY_GRP)//when logged in user not part of the primary CDT group
        {
            returnMessage.isSuccess=false;
            returnMessage.errorMsg=errorMsgForGpMembership();
            return returnMessage;
        } */       
        try
        {
            for(FeedItem feed : [SELECT  Id, Body, CommentCount, CreatedDate, ParentId, RelatedRecordId, Title, Type,CreatedBy.Name, CreatedById, InsertedById, Status
            FROM FeedItem WHERE Id IN (SELECT EntityId FROM TopicAssignment WHERE EntityType = 'FeedItem' AND TopicId =: fetchTopicId(topicName)
            ) AND (ParentId =:teamId OR ParentId IN :memberIdListForTeam) ORDER BY CreatedDate Desc])
                {
                    system.debug('Inside for loop');
                    if(count==LIST_ITEMS_TO_DISPLAY)
                        break;
                    feedBody = feed.Body;
                    system.debug('feedBody'+feedBody);
                    if((feed.ParentId==teamId) ||(feedBody.contains(filterGroupByTeamName(teamName))))
                    {
                        feed.Body = getPostText(feed,topicName,teamName);
                        count++;
                        feedItemList.add(feed);
                    }
                    
                }
            if(feedItemList.isEmpty())//When there is no feeds available under that topic   
                {
                    system.debug('I ma in empty feedList');
                    returnMessage.isSuccess=false;
                    returnMessage.msgStr=defaultText();
                    return returnMessage;
                }
            else
                {
                    returnMessage.isSuccess=true;
                    returnMessage.feedLists=feedItemList;
                    system.debug('returnMessage'+returnMessage.feedLists);
                    return returnMessage;
                }
        }
        catch(Exception e)
        {
            returnMessage.isSuccess = false;
            returnMessage.errorMsg =e.getMessage();
            return returnMessage;
        }         
        
    }
    //Filter feed based on group
    public static String filterByGroupName()
    {
        return '@'+ECRM_PRIMARY_CHATTER_GP_NAME;
    }
    
    //Filter feed based on group
    public static String filterGroupByTeamName(String teamName)
    {
        return '@'+teamName;
    }
    
    public static void toRemoveDebugLogs()
    {
        system.debug('ECRM_PRIMARY_CHATTER_GP_ID='+ECRM_PRIMARY_CHATTER_GP_ID);
        system.debug('ECRM_PRIMARY_CHATTER_GP_NAME='+ECRM_PRIMARY_CHATTER_GP_NAME);
        system.debug('memberId='+UserInfo.getUserId());
        system.debug('IS_MORE_PRIMARY_GRP_SPECIFIED='+IS_MORE_PRIMARY_GRP_SPECIFIED);
        system.debug('ERROR_PRIMARY_GRP_NOT_SPECIFIED='+ERROR_PRIMARY_GRP_NOT_SPECIFIED);
        system.debug('USER_PART_OF_PRIMARY_GRP='+USER_PART_OF_PRIMARY_GRP);
        system.debug('memberIdListOfPrimaryGrp'+memberIdListOfPrimaryGrp);
    }
    //Feed Body Text
    public static String getPostText(FeedItem fItem,String topic, String team)
    {
        String feedBody = '';
        /* // this creates the feed - "hello " by Sushil, 12/10/2016
        feedBody  = '"';
        feedBody += removeHTMLTagsFromFeedItems(fItem.Body);
        feedBody += '"';
        feedBody += +' ' + 'by' + ' ';
        feedBody += fItem.CreatedBy.Name;
        feedBody += +' ' + ',' + ' ';
        feedBody += fItem.CreatedDate.format('MM/dd/yyyy');
        */
        // this creates simple feed as requested by Biz
        feedBody += removeHTMLTagsFromFeedItems(fItem.Body,topic,team);
        system.debug('feed'+feedBody);
        return feedBody;
    }
    
    
    public static void callAllCoreMethods()
    {
        getLoggedInUsersPrimaryCDTGroup();
        if(!ERROR_PRIMARY_GRP_NOT_SPECIFIED || !IS_MORE_PRIMARY_GRP_SPECIFIED)
        {
            //system.debug('before calling primary');
            getUsersPrimaryCDTGrpID();
            verifyLoggedInUserGrpMembership();
            if(USER_PART_OF_PRIMARY_GRP)
                findMembersOfTheCDTGroup();
                
        }
        //toRemoveDebugLogs();//To be removed after code freeze
    }
    
    public static void getLoggedInUsersPrimaryCDTGroup()
    {
        List<ECRM_Team_Membership__c> userCDTGroup = new List<ECRM_Team_Membership__c>();
        
        userCDTGroup = [SELECT Id, Name, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name, 
            ECRM_Member_Name__r.Name, ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId()
                AND ECRM_Primary__c = true];
        
        if(userCDTGroup.isEmpty())
        {
            ERROR_PRIMARY_GRP_NOT_SPECIFIED = true;
        }
        else if(userCDTGroup.size()>1)
        {
            IS_MORE_PRIMARY_GRP_SPECIFIED = true;
        }
        else if(userCDTGroup.size()==1)
        {
            for(ECRM_Team_Membership__c myCDT : userCDTGroup)
            {
                ECRM_PRIMARY_CHATTER_GP_NAME = myCDT.ECRM_Member_Team__r.ECRM_Chatter_GroupName__c;
                ECRM_PRIMARY_TEAM_NAME = myCDT.ECRM_Member_Team__r.Name;
                system.debug('team...nmae ' + ECRM_PRIMARY_TEAM_NAME);
            }
           
        }
        
    }
    //Get User's Primary CDTGroup Id 
    public static void getUsersPrimaryCDTGrpID()
    {
        for(CollaborationGroup groupInfo : [SELECT Id FROM CollaborationGroup where name=:ECRM_PRIMARY_CHATTER_GP_NAME Limit 1])
            {
                ECRM_PRIMARY_CHATTER_GP_ID = groupInfo.Id;
            }
                 
    }
    //Get Chatter group id by team Name
    public static Id getUsersCDTGrpID(String teamName)
    {
        Id chatterGrpId;
        for(CollaborationGroup groupInfo : [SELECT Id FROM CollaborationGroup where name=:teamName Limit 1])
            {
                chatterGrpId = groupInfo.Id;
            }
        return chatterGrpId;         
    }
    //verify the loggedin user is part of the CDT group
    public static void verifyLoggedInUserGrpMembership()
    {
        for(CollaborationGroupMember cgrpMember : [SELECT CollaborationGroupId,Id,MemberId FROM CollaborationGroupMember where MemberId=:UserInfo.getUserId() AND CollaborationGroupId =:ECRM_PRIMARY_CHATTER_GP_ID])
            {
               USER_PART_OF_PRIMARY_GRP = true;
            } 
    }
    
     public static void findMembersOfTheCDTGroup()
    {
        for(CollaborationGroupMember grpMembers : [SELECT CollaborationGroupId,Id,MemberId FROM CollaborationGroupMember where CollaborationGroupId=:ECRM_PRIMARY_CHATTER_GP_ID])
        {
            memberIdListOfPrimaryGrp.add(grpMembers.MemberId);
        }
        //system.debug('memberIdListOfPrimaryGrp'+memberIdListOfPrimaryGrp);
    }

    public static void findMembersOfTheCDTTeam(String teamId)
    {
        for(CollaborationGroupMember grpMembers : [SELECT CollaborationGroupId,Id,MemberId FROM CollaborationGroupMember where CollaborationGroupId=:teamId])
        {
            memberIdListForTeam.add(grpMembers.MemberId);
        }
        //system.debug('memberIdListOfPrimaryGrp'+memberIdListOfPrimaryGrp);
    }
    
    public static String fetchTopicId (String topicName)
    {
        String topicID = '';
        //system.debug('topicName'+topicName);
        //system.debug('topic id='+ [select Id from Topic where name=:topicName]);
        for(Topic topic : [SELECT Id from Topic where name=:topicName Limit 1])
            {
                topicID = topic.Id;
            }
        //system.debug('topicID--Aarthi='+topicID);
        return topicID;
    }
    
    //If the feeds are empty set the default text
    public static String defaultText()
        {
            return 'There are no feeds available at this time';
        }
    
    //Error Message for more than one primary group specified
    public static String errorMsgForMorePrimaryGroup()
    {
        return 'Please correct your primary assignment. You have more than one Primary Group';
    }
    //Error Message for Primary group not specified for the logged in user
    public static String errorMsgForNoPrimaryGroup()
    {
        return 'The logged in user does not have any primary chatter group specified. Please select atleast one CDT group as Primary';
    }
    //Error message for when the user is not part of CDT chatter group
    public static String errorMsgForGpMembership()
    {
        return 'The user is not a member of any CDT Chatter group';
    }
    //Remove HTML tags from the Feed Items
    public static String removeHTMLTagsFromFeedItems(String bodyText, String topicName, String teamName)
    {   String returnStr='';
    	String teamNme = '@'+teamName;
    	String topicNme = '#'+topicName;
     	String topicNme1 = '#['+topicName+']';
     system.debug('topicNme'+topicNme);
    	returnStr = bodyText.stripHtmlTags();
    	returnStr = returnStr.remove(teamNme);
    	returnStr = returnStr.remove(topicNme);
     	returnStr = returnStr.remove(topicNme1);
		system.debug('returnStr'+returnStr);
        return returnstr;
    }
    
}