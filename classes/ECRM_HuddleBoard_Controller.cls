public class ECRM_HuddleBoard_Controller {
    //Needs to rewrite this class after the POC
    public static Boolean REC_VISIBILITY = true;
    public static String ECRM_PRIMARY_TEAM_ID = null;
    public static String ECRM_PRIMARY_TEAM_NAME = null;
    public static Integer NO_OF_RECORDS_ALLOWED = 5;
    public static String FOCUS_OF_THE_WEEK = 'Focus of the Week';
    public static String NEWS = 'News';
	public static String PROBLEM_SOLVE = 'Problem Solve';
	public static String BAROMETER = 'Priority'; 
    public static String HUDDLE_METRICS_REC_TYPE = 'HuddleMetrics';
    public static String HUDDLE_OBJECT = 'ECRM_Huddle_Board__c';
        
    @AuraEnabled
    public static List<String> getCustomerMetricsFields(String selectionStr)
    {
        	List<String> fieldLabels = new List<String>();
            fieldLabels.add(selectionStr);
            String type='ECRM_Huddle_Board__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType cusObjSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = cusObjSchema.getDescribe().fields.getMap();
            
            for (String fieldName: fieldMap.keySet()) {
                System.debug('##Field API Name='+fieldName);// list of all field API name
             if((fieldName.equalsIgnoreCase('ECRM_Account__c')) || (fieldName.equalsIgnoreCase('ECRM_Huddle_Content__c')) || (fieldName.equalsIgnoreCase('ECRM_Huddle_Team__c'))
                || (fieldName.equalsIgnoreCase('ECRM_Huddle_Type__c'))||(fieldName.equalsIgnoreCase('ECRM_Huddle_Visible__c'))||(fieldName.equalsIgnoreCase('ECRM_Rich_Tx__c'))
               || (fieldName.equalsIgnoreCase('ECRM_Account_Type')))
                {
                    continue;
                }
             else
                 fieldLabels.add(fieldName);             
                //fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
            }
                
        return fieldLabels;
    }
    
    
    public class AccountTeamWrapper{
       @AuraEnabled public String acctId;
       @AuraEnabled public String acctName;
        public AccountTeamWrapper()
        {
            acctId = '';
            acctName = '';
        }
    }
    
    @AuraEnabled
    public static List<AccountTeamWrapper> getAccountsForTheTeam(String selectionStr, String teamName)
    {
        List<AccountTeamWrapper> mainWrapper = new List<AccountTeamWrapper>();
        AccountTeamWrapper actListWrapper = new AccountTeamWrapper();
        String teamID = '';
        
        if(String.isBlank(teamName))//If teamName is blank, then default primary team should be assigned
            if(String.isBlank(ECRM_PRIMARY_TEAM_ID))
            {
                getLoggedInUserCDTTeams();
                teamID = ECRM_PRIMARY_TEAM_ID;
            }
            else
                teamID = ECRM_PRIMARY_TEAM_ID;
        else
                teamID = getTeamIdFromName(teamName);
        //Add Please select text
        	actListWrapper.acctId=selectionStr;
        	actListWrapper.acctName=selectionStr;
        	mainWrapper.add(actListWrapper);            
        	return setOtherAndTotalAccounts(getPriorityAccountsForTeam(teamID,mainWrapper)); 
    }
    
    public static List<AccountTeamWrapper> setOtherAndTotalAccounts(List<AccountTeamWrapper> otherTotalWrapper)
    {
        AccountTeamWrapper otherWrapper = new AccountTeamWrapper();
        
        otherWrapper.acctId='Other';
        otherWrapper.acctName='Other';
        otherTotalWrapper.add(otherWrapper);  
        
        otherWrapper.acctId='Total';
        otherWrapper.acctName='Total';
        otherTotalWrapper.add(otherWrapper);  
        
        return otherTotalWrapper;
    }
    
    @AuraEnabled
    public static void fetchHuddleRec(String acctID, String teamName, String huddleType, String fieldLabel,String fieldValue)
    {
        Id huddleBoard;
        List<ECRM_Huddle_Board__c> huddleRec = new List<ECRM_Huddle_Board__c>();
        //check whether we have the huddle rec already
       huddleRec = [SELECT ID, ECRM_Account__c,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c FROM ECRM_Huddle_Board__c 
       where ECRM_Account__c=:acctID AND ECRM_Huddle_Team__r.Name=:teamName AND ECRM_Huddle_Type__c=:huddleType LIMIT 1];
       
        if(huddleRec.isEmpty() && huddleRec.size()==0)
           huddleBoard = createHuddleRec4Accounts(acctID, teamName, huddleType);
       	else
           huddleBoard = huddleRec.get(0).Id; 
        //If so, based on field label call the specific method
        callRespectiveMethod(huddleBoard,fieldLabel,fieldValue);        
    }
    
    public static void callRespectiveMethod(Id hudId,String fieldLabel, String fieldValue)
    {
        if(fieldLabel.equalsIgnoreCase('60-in-6'))
            upsert60_in_6(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('Acquisition Volume'))
            upsertAcquistionVol(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('Affordable'))
            upsertAffordable(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('CSAT'))
            upsertCSAT(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('DU Index'))
            upsertDUIndex(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('Leaders Choice STP'))
            upsertLeadersChoice(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('LEOPARD'))
            upsertLEOPARD(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('Market Share'))
            upsertMarketShare(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('STAR'))
            upsertSTAR(hudId,fieldValue);
        if(fieldLabel.equalsIgnoreCase('Swindex'))
            upsertSwindex(hudId,fieldValue);
        
    }
    public static void upsertAcquistionVol(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_Acquisition_Volume__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_Acquisition_Volume__c = value;
        upsert upsertHud;
    }
    
    public static void upsertAffordable(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_Affordable__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_Affordable__c = value;
        upsert upsertHud;
    }
    public static void upsertCSAT(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_CSAT__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_CSAT__c = value;
        upsert upsertHud;
    }
    
    public static void upsertDUIndex(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_DU_Index__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_DU_Index__c = value;
        upsert upsertHud;
    }
    public static void upsertLeadersChoice(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_Leaders_Choice_STP__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_Leaders_Choice_STP__c = value;
        upsert upsertHud;
    }
    
    public static void upsertLEOPARD(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_LEOPARD__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_LEOPARD__c = value;
        upsert upsertHud;
    }
    public static void upsertMarketShare(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_Market_Share__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_Market_Share__c = value;
        upsert upsertHud;
    }
    
    public static void upsertSTAR(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_STAR__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_STAR__c = value;
        upsert upsertHud;
    }
    public static void upsertSwindex(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_Swindex__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_Swindex__c = value;
        upsert upsertHud;
    }
    
    public static void upsert60_in_6(Id huddleId, String value)
    {
        ECRM_Huddle_Board__c upsertHud = new ECRM_Huddle_Board__c();
        upsertHud = [SELECT Id, ECRM_X60_in_6__c FROM ECRM_Huddle_Board__c where Id =:huddleId Limit 1];
        upsertHud.ECRM_X60_in_6__c = value;
        upsert upsertHud;
    }
    
    public static Id createHuddleRec4Accounts(String acctID, String teamName, String huddleType)
    {
        ECRM_Huddle_Board__c hudBoard = new ECRM_Huddle_Board__c();
        hudBoard.ECRM_Account__c =acctID;
        hudBoard.ECRM_Huddle_Team__r.Name=teamName;
        hudBoard.ECRM_Huddle_Type__c=huddleType;
        insert hudBoard;
        return hudBoard.Id;
    }
    //We need Id and Account Name - So using Wrapper class
    public static List<AccountTeamWrapper> getPriorityAccountsForTeam(String teamID, List<AccountTeamWrapper> actTeamWrapper)
    {
        List<AccountTeamWrapper> mainWrapper = actTeamWrapper;
        AccountTeamWrapper teamWrapper = new AccountTeamWrapper();
        List<ECRM_Team_SS_Account__c> teamSSAccounts = new List<ECRM_Team_SS_Account__c>();
          
        //Get Accounts for the team
        
        teamSSAccounts =  [SELECT Apply_to_Main_Branch__c,ECRM_High_Priority__c,ECRM_SS_Account__c,ECRM_SS_Account__r.ECRM_Dummy_Type__c, 
                                                    ECRM_SS_Account__r.RecordTypeId,ECRM_SS_Account__r.Name,ECRM_Team_Name__c,Name 
                                                    FROM ECRM_Team_SS_Account__c where ECRM_Team_Name__c =:teamID ORDER BY ECRM_SS_Account__r.Name];
        for(ECRM_Team_SS_Account__c accs : teamSSAccounts)
        {
            if(accs.ECRM_High_Priority__c)//Get High Priority accts
            {
                teamWrapper.acctId =accs.ECRM_SS_Account__c;
                teamWrapper.acctName =accs.ECRM_SS_Account__r.Name;
                mainWrapper.add(teamWrapper);
            }
        }
        return mainWrapper;              
    }
    
    public static Id createDummyAccount (String teamName , String dummytype)
    {
        Account acc = new Account();
        acc.Name = teamName + '' + '-' + '' + dummytype + '' + 'Account';
        //acc.RecordTypeId = NON_KANBAN_REC_TYPE_ID;
        acc.ECRM_Dummy_Type__c = dummytype;
        insert acc;
        return acc.Id;
    }
    
    public static Id createSSAccount (String teamId, Id acctId)
    {
        ECRM_Team_SS_Account__c acct = new ECRM_Team_SS_Account__c();
        acct.ECRM_Team_Name__c = teamId;
        acct.ECRM_SS_Account__c = acctId;
        insert acct;
        return acct.Id;
    }
    
    /* A logged in user will always have only one primary team selected as per the validation rule on the team membership object. 
     * Though the logged in user may not have any primary team specified. If no primary team selected the component should throw the message saying 
		'Please select your primary CDT Team'
	TODO- Any active members check to do it?*/
    public static String checkCustomSettingsValue()
    {
        String huddleTeam = '';
        ECRM_Huddle_Team__c team = ECRM_Huddle_Team__c.getValues('Last_Huddle_Team');
        if(!String.isBlank(team.Huddle_Team_Name__c))
        {
            huddleTeam = team.Huddle_Team_Name__c;
        }
        system.debug('huddleTeam'+huddleTeam);
        return huddleTeam;
    }
    
    @AuraEnabled
    public static void setHuddleTeamName(String teamName)
    {
        ECRM_Huddle_Team__c team = ECRM_Huddle_Team__c.getValues('Last_Huddle_Team');
                            team.Huddle_Team_Name__c = teamName;
                            upsert team;
    }
    
    @AuraEnabled
    public static CDTTeamWrapperClass getLoggedInUserCDTTeamsTest()
	{
        CDTTeamWrapperClass teamWrapper = new CDTTeamWrapperClass();
        Boolean NO_PRIMARY_SELCTED =false;
		List<String> userCDTGroup = new List<String>();
		List<String> userPrimaryCDTGroup = new List<String>();
		List<ECRM_Team_Membership__c> teamMembers = new List<ECRM_Team_Membership__c>();
		
        //From Team members pull all the teams that the logged user is active
		teamMembers =[SELECT Id, Name, ECRM_Member_Name__c, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name,
		ECRM_Member_Name__r.Name,ECRM_Member_Team__c, ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Team__r.Name!= Null Limit 25];
		
        for(ECRM_Team_Membership__c mem : teamMembers)
		{
			//find the primary team
			if(mem.ECRM_Primary__c)
            	{
                    system.debug('check custom settings'+ checkCustomSettingsValue());
					if(!String.isBlank(checkCustomSettingsValue()))
        			{
                        userPrimaryCDTGroup.add(checkCustomSettingsValue());
                    	teamWrapper.primaryTeamName=checkCustomSettingsValue();
            			ECRM_PRIMARY_TEAM_NAME = checkCustomSettingsValue();
        		    }
        			else
        				{
                            ECRM_Huddle_Team__c team = ECRM_Huddle_Team__c.getValues('Last_Huddle_Team');
                            team.Huddle_Team_Name__c = mem.ECRM_Member_Team__r.Name;
                            upsert team;
                            userPrimaryCDTGroup.add(mem.ECRM_Member_Team__r.Name);
                    		teamWrapper.primaryTeamName=mem.ECRM_Member_Team__r.Name;
            				ECRM_PRIMARY_TEAM_NAME = mem.ECRM_Member_Team__r.Name;
                    		ECRM_PRIMARY_TEAM_ID =mem.ECRM_Member_Team__c;
       					}
                    
                    //set the custom settings
                    
            	}
			else
				userCDTGroup.add(mem.ECRM_Member_Team__r.Name);
		}
       	
        //Check whether the user has any primary or not?        
        if(userPrimaryCDTGroup.isEmpty())
        {
            NO_PRIMARY_SELCTED = true;
        }
		else if(!userCDTGroup.isEmpty())
		{
			for(String cdtGrps : userCDTGroup)
			{
				userPrimaryCDTGroup.add(cdtGrps);
			}
		}
        
        teamWrapper.noPrimaryTeam = NO_PRIMARY_SELCTED ;
        teamWrapper.userCDTTeams = userPrimaryCDTGroup;
		return teamWrapper;
	}
    
    @AuraEnabled
    public static CDTTeamWrapperClass getLoggedInUserCDTTeams()
	{
        CDTTeamWrapperClass teamWrapper = new CDTTeamWrapperClass();
        Boolean NO_PRIMARY_SELCTED =false;
		List<String> userCDTGroup = new List<String>();
		List<String> userPrimaryCDTGroup = new List<String>();
		List<ECRM_Team_Membership__c> teamMembers = new List<ECRM_Team_Membership__c>();
		
        //From Team members pull all the teams that the logged user is active
		teamMembers =[SELECT Id, Name, ECRM_Member_Name__c, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name,
		ECRM_Member_Name__r.Name,ECRM_Member_Team__c, ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId() and ECRM_Member_Team__r.Name!= Null Limit 25];
		
        for(ECRM_Team_Membership__c mem : teamMembers)
		{
			//find the primary team
			if(mem.ECRM_Primary__c)
            	{
					userPrimaryCDTGroup.add(mem.ECRM_Member_Team__r.Name);
                    teamWrapper.primaryTeamName=mem.ECRM_Member_Team__r.Name;
                    ECRM_PRIMARY_TEAM_NAME = mem.ECRM_Member_Team__r.Name;
                    ECRM_PRIMARY_TEAM_ID =mem.ECRM_Member_Team__c;
                    //set the custom settings
                    
            	}
			else
				userCDTGroup.add(mem.ECRM_Member_Team__r.Name);
		}
       	
        //Check whether the user has any primary or not?        
        if(userPrimaryCDTGroup.isEmpty())
        {
            NO_PRIMARY_SELCTED = true;
        }
		else if(!userCDTGroup.isEmpty())
		{
			for(String cdtGrps : userCDTGroup)
			{
				userPrimaryCDTGroup.add(cdtGrps);
			}
		}
        
        teamWrapper.noPrimaryTeam = NO_PRIMARY_SELCTED ;
        teamWrapper.userCDTTeams = userPrimaryCDTGroup;
		return teamWrapper;
	}
    
     /* This will have list of Huddle Type*/
    @AuraEnabled
    public static List<String> getPickListValuesForRichTextHuddleType(String selectionStr){
        //String selectionStr = 'Please Select';
       	/*List<String> pickListValuesList= new List<String>();
        pickListValuesList.add(selectionStr);
		Schema.DescribeFieldResult fieldResult = ECRM_Huddle_Board__c.ECRM_Huddle_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            //if(!pickListVal.getLabel().equalsIgnoreCase(NEWS))
            if((pickListVal.getLabel().equalsIgnoreCase('WILO'))||(pickListVal.getLabel().equalsIgnoreCase('Problem Solve')))
                continue;
            else
                pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;*/
        List<String> pickListValuesList= new List<String>();
        pickListValuesList.add(selectionStr);
        pickListValuesList.add('Market Intel');
        pickListValuesList.add('News');
        pickListValuesList.add('Parking Lot');
        pickListValuesList.add('Employee Survey');
        return pickListValuesList;
    }
    
     @AuraEnabled
    public static List<String> getPickListValuesForUploadHuddleType(String selectionStr){
        //String selectionStr = 'Please Select';
       	/*List<String> pickListValuesList= new List<String>();
        pickListValuesList.add(selectionStr);
		Schema.DescribeFieldResult fieldResult = ECRM_Huddle_Board__c.ECRM_Huddle_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            if((pickListVal.getLabel().equalsIgnoreCase('WILO'))||(pickListVal.getLabel().equalsIgnoreCase('Problem Solve')))
                pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;*/
        List<String> pickListValuesList= new List<String>();
        pickListValuesList.add(selectionStr);
        pickListValuesList.add('Morale');
        pickListValuesList.add('Customer Metrics');
        pickListValuesList.add('Problem Solving');
        pickListValuesList.add('WILO');
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static void saveRichTextHuddleContent(String teamName, String huddleType, String content)
    {
        //Find existing record for team name and huddle type
        Id huddleId = getHuddleId4Team(teamName,huddleType);//Get the Huddle Id
        //system.debug('huddleId' +huddleId);
        if(huddleId==null)//create new record with the given content
        	{
                String recType = getRecordTypeId(HUDDLE_OBJECT, HUDDLE_METRICS_REC_TYPE);
                ECRM_Huddle_Board__c newHuddleRec= createHuddleRec(huddleType,getTeamIdFromName(teamName));
                newHuddleRec.RecordTypeId = recType;
                newHuddleRec.ECRM_Rich_Tx__c = content;
                upsert newHuddleRec;
            }
            else //rewrite the content for the existing huddle  
            {
                ECRM_Huddle_Board__c updateHuddleRec = [select Id,ECRM_Rich_Tx__c from ECRM_Huddle_Board__c where Id =:huddleId ];
                updateHuddleRec.ECRM_Rich_Tx__c = content;
                update updateHuddleRec;               
            }        
    }
    
    public class CDTTeamWrapperClass{
        @AuraEnabled public Boolean noPrimaryTeam;
        @AuraEnabled public String primaryTeamName;
		@AuraEnabled public List<String> userCDTTeams;
        public CDTTeamWrapperClass()
        {
            userCDTTeams = new List<String>();
            noPrimaryTeam = false;
            primaryTeamName = '';
        }
    }
    //It is re-write component - so Limit is always one
    @AuraEnabled
    public static String getRichTextHuddleContents(String teamName, String huddleType)
    {
        system.debug('team Name' + teamName + 'huddleType' +huddleType);
        List<ECRM_Huddle_Board__c> huddleRichTextContents = new List<ECRM_Huddle_Board__c>();
        String returnRichTxt = '';
        huddleRichTextContents = [SELECT Id,ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Rich_Tx__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:teamName
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1]; 
        //system.debug('myhuddleContents' +huddleRichTextContents);
        if(!huddleRichTextContents.isEmpty())
        {
            for(ECRM_Huddle_Board__c huddle : huddleRichTextContents)
            {
                returnRichTxt =huddle.ECRM_Rich_Tx__c;
            }
            //system.debug('1st fotwValue' + fotwValue);
        }
        if(String.isBlank(returnRichTxt))
           returnRichTxt = 'No contents available';
        //system.debug('fotwValue' +fotwValue);
        return returnRichTxt;
    }
	
    @AuraEnabled
	public static List<ECRM_Huddle_Board__c> createAndGetHuddleContents(String teamName, String huddleType,String newContent) {
        String content = newContent.stripHtmlTags();
        ECRM_Huddle_Board__c huddleBoard = new ECRM_Huddle_Board__c();
        huddleBoard.ECRM_Huddle_Visible__c = REC_VISIBILITY;
        huddleBoard.ECRM_Huddle_Team__c = getTeamIdFromName(teamName);
        huddleBoard.ECRM_Huddle_Type__c = huddleType;
        huddleBoard.ECRM_Huddle_Content__c = content;        	
    	insert huddleBoard;
    	return getCRUDContentByTeamAndType(teamName,huddleType);           
	}
    
    @AuraEnabled
    public static List<ECRM_Huddle_Board__c> getCRUDContentByTeamAndType(String teamName, String huddleType)
    {
        List<ECRM_Huddle_Board__c> huddleContents = new List<ECRM_Huddle_Board__c>();
		huddleContents = [SELECT Id,ECRM_Huddle_Content__c, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Huddle_Visible__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Visible__c =:REC_VISIBILITY AND ECRM_Huddle_Team__r.Name =:teamName
               AND ECRM_Huddle_Type__c =:huddleType ORDER BY CreatedDate DESC LIMIT :NO_OF_RECORDS_ALLOWED ];
		return huddleContents;
    }
    
    @AuraEnabled
	public static List<ECRM_Huddle_Board__c> upsertCRUDContent(String teamName, String huddleType, ECRM_Huddle_Board__c contents) {
    upsert contents;
    return getCRUDContentByTeamAndType(teamName,huddleType);
	}
    
    public class FileUploadWrapperClass{
        @AuraEnabled public Attachment attachment;
        @AuraEnabled public String attachmentURL;
		
        public FileUploadWrapperClass()
        {
            attachment = new Attachment();
            attachmentURL = '';
        }
    }
    
    @AuraEnabled
    public static FileUploadWrapperClass getAttachment4PrimaryTeam(String huddleType)
    {
        getLoggedInUsersPrimaryCDTGroup();//Get the Team Name
        return getAttachment4Team(ECRM_PRIMARY_TEAM_NAME,huddleType);
    }
    
    @AuraEnabled
    public static FileUploadWrapperClass getAttachment4Team(String teamName, String huddleType)
    {
        FileUploadWrapperClass fileWrapper = new FileUploadWrapperClass();
        //First check if we have record in huddle object 
       Id huddleId = getHuddleId4Team(teamName,huddleType);                
       //system.debug('huddleId' +huddleId);
       Attachment attach = new Attachment();
       if(huddleId!=null)//If Huddle Id is not null, then find the attachment
        {
            attach = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:huddleId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif', 'image/jpg') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
        }
        //system.debug('attach'+attach);
        fileWrapper.attachment = attach;
        fileWrapper.attachmentURL = Url.getSalesforceBaseUrl().toExternalForm();
        return fileWrapper;        
    }
	
	 public static Id getHuddleId4Team(String teamNe, String huddleType)
    {
        Id hudID;
        List<ECRM_Huddle_Board__c> huddleId = new List<ECRM_Huddle_Board__c>();
        huddleId = [SELECT Id, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:teamNe
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1];
       	//system.debug('myhuddleContents' + huddleId);
        for(ECRM_Huddle_Board__c huddle : huddleId)
        {
            hudID = huddle.Id;
        }
        return hudID;
    }
    
    @AuraEnabled
    public static FileUploadWrapperClass uploadAttachments(String teamName,String huddleType,String fileName, String base64Data, String contentType)
    {
        FileUploadWrapperClass fileWrapper = new FileUploadWrapperClass();
        Attachment upsertedAtt = new Attachment();
        Id huddleId = getHuddleId4Team(teamName,huddleType);
        //system.debug('huddleId'+huddleId);
        if(huddleId==null) //Create Huddle Rec
        {
            ECRM_Huddle_Board__c newHuddleRec= createHuddleRec(huddleType,getTeamIdFromName(teamName));
        	upsertedAtt = saveAttachment(newHuddleRec.Id, fileName, base64Data, contentType);
        }
        else if(huddleId!=null)
        {
            upsertedAtt = saveAttachment(huddleId, fileName, base64Data, contentType);
        }
        fileWrapper.attachment = upsertedAtt;
        fileWrapper.attachmentURL = Url.getSalesforceBaseUrl().toExternalForm();
        return fileWrapper;        
    }
    //Get the picture from Attachment by using recordId as parent Id
    //check whether we have a record in Custom obj reg Problem Solve and if we have get the record Id
    //and pass this into attachment and get the attachment ID
    
    public static Attachment saveAttachment(Id parentId, String fileName, String base64Data, String contentType) {
        List<Attachment> myattachments = new List<Attachment>();
        //get the attachment Id by parent Id
        List<Attachment> attachment = [SELECT Id, parentId,body,name,contentType from Attachment where parentId=:parentId Limit 1];
        //system.debug('attachment'+attachment);
        for(Attachment attach : attachment)
        {
            //system.debug('Inside');
            myattachments.clear();
            attach.body = EncodingUtil.base64Decode(base64Data);
            attach.name = fileName;
            attach.contentType = contentType; 
            myattachments.add(attach);
        }
        if(!myattachments.isEmpty())
        {
            upsert myattachments;
            return myattachments.get(0);
        }
        else
        {
            Attachment newAttachment = new Attachment();
            newAttachment.parentId = parentId;
            newAttachment.body = EncodingUtil.base64Decode(base64Data);
            newAttachment.name = fileName;
            newAttachment.contentType = contentType;
            insert newAttachment;
            return newAttachment;
        }         
        
    }
    
   
    
    @AuraEnabled
    public static String saveFOTW(String teamName,String content, String huddleType)
    {
		 system.debug('inside the SAVEFOTW');
         system.debug('Content'+ content);
        String displayresult = '';
        if(huddleType.equalsIgnoreCase(FOCUS_OF_THE_WEEK))
        {
            //getLoggedInUsersPrimaryCDTGroup();//Get the Team Name
            Id huddleId = getHuddleId4Team(teamName,huddleType);//Get the Huddle Id
            system.debug('huddleId' +huddleId);
            if(huddleId==null)
        	{
                //Create a new Rec
                ECRM_Huddle_Board__c newHuddleRec= createHuddleRec(huddleType,getTeamIdFromName(teamName));
                newHuddleRec.ECRM_Rich_Tx__c = content;
                upsert newHuddleRec;
                system.debug('newHuddleRec' +newHuddleRec + 'cont'+newHuddleRec.ECRM_Rich_Tx__c);
                displayresult = content;
            }
            else //Record already existed, save the content
            {
                ECRM_Huddle_Board__c updateHuddleRec = [select Id,ECRM_Rich_Tx__c from ECRM_Huddle_Board__c where Id =:huddleId ];
                updateHuddleRec.ECRM_Rich_Tx__c = content;
                update updateHuddleRec;
                displayresult = content;
            }
        }
        else{
            system.debug('fix the error');
        }
         system.debug('displayresult' +displayresult);
		
        return displayresult;
            
    }
	
	 public class HuddleWrapperClass
	{
		@AuraEnabled public Attachment myAttachments;
        @AuraEnabled public String teamName;
		@AuraEnabled public String fotwText;
        @AuraEnabled public String hudId;
		@AuraEnabled public List<ECRM_Huddle_Board__c> huddleList;
		public HuddleWrapperClass()
		{
			huddleList = new List<ECRM_Huddle_Board__c>();
			myAttachments = new Attachment();
			teamName ='';
			fotwText ='';
            hudId = '';
		}
	}
	@AuraEnabled
    public static HuddleWrapperClass getFocusOfTheWeekHuddleContent(String huddleType)
    {
		HuddleWrapperClass fotwhuddle = new HuddleWrapperClass();
		fotwhuddle.teamName=ECRM_PRIMARY_TEAM_NAME;
		
        List<ECRM_Huddle_Board__c> myhuddleContents = new List<ECRM_Huddle_Board__c>();
        getLoggedInUsersPrimaryCDTGroup();
        String fotwValue = '';
myhuddleContents = [SELECT Id,ECRM_Huddle_Content__c, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Huddle_Visible__c,ECRM_Rich_Tx__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:ECRM_PRIMARY_TEAM_NAME
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1]; 
        system.debug('myhuddleContents' +myhuddleContents);
        if(!myhuddleContents.isEmpty())
        {
            for(ECRM_Huddle_Board__c huddle : myhuddleContents)
            {
                fotwValue =huddle.ECRM_Rich_Tx__c;
                fotwhuddle.hudId=huddle.Id;
            }
            //system.debug('1st fotwValue' + fotwValue);
        }
        //system.debug('2nd fotwValue' + fotwValue);
        /*if(String.isBlank(fotwValue))
           fotwValue = 'Please enter your FOTW here';*/
        //system.debug('fotwValue' +fotwValue);
		fotwhuddle.fotwText=fotwValue;
        return fotwhuddle;
    }
	
	@AuraEnabled
    public static HuddleWrapperClass getNewsHuddleContent(String huddleType)
    {
		HuddleWrapperClass wraCls = new HuddleWrapperClass();
        getLoggedInUsersPrimaryCDTGroup();
        wraCls.huddleList = [SELECT Id,ECRM_Huddle_Content__c, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Huddle_Visible__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Visible__c =:REC_VISIBILITY AND ECRM_Huddle_Team__r.Name =:ECRM_PRIMARY_TEAM_NAME
               AND ECRM_Huddle_Type__c =:huddleType ORDER BY CreatedDate DESC LIMIT :NO_OF_RECORDS_ALLOWED ];
		wraCls.teamName = ECRM_PRIMARY_TEAM_NAME;
		return wraCls;
    }
    
    @AuraEnabled
	public static List<ECRM_Huddle_Board__c> saveHuddleContents(String teamName,ECRM_Huddle_Board__c contents) {
    // Perform isUpdateable() check here
    upsert contents;
    return getNewsForTeam(teamName, contents.ECRM_Huddle_Type__c);
	}
    
    @AuraEnabled
	public static ECRM_Huddle_Board__c createHuddleContents4News(String teamName,String newContent) {
    // Perform isUpdateable() check here
   	//getLoggedInUsersPrimaryCDTGroup();
    ECRM_Huddle_Board__c huddleBoard = new ECRM_Huddle_Board__c();
        huddleBoard.ECRM_Huddle_Visible__c = REC_VISIBILITY;
        huddleBoard.ECRM_Huddle_Team__c = getTeamIdFromName(teamName);
        huddleBoard.ECRM_Huddle_Type__c = NEWS;
        huddleBoard.ECRM_Huddle_Content__c = newContent;        	
    	upsert huddleBoard;
    	return huddleBoard;
	}
    
    
    /*@AuraEnabled
    public static Id saveHuddleRec(String teamName,String huddleType,String fileName, String base64Data, String contentType)
    {
        system.debug('I am inside the huddle' + 'team name =' + teamName);
        String hudType = '';
        hudType = getImageType(huddleType);
        Id attachId;
        //getLoggedInUsersPrimaryCDTGroup();//Get the Team Name
		system.debug('before calling guddleID');
        Id huddleId = getHuddleId(hudType);
        system.debug('huddleId'+huddleId);
        if(huddleId==null)
        {
            ECRM_Huddle_Board__c newHuddleRec= createHuddleRec(hudType,getTeamIdFromName(teamName));
        	attachId = saveAttachment(newHuddleRec.Id, fileName, base64Data, contentType);
        }
        else if(huddleId!=null)
        {
            attachId = saveAttachment(huddleId, fileName, base64Data, contentType);
        }
        return attachId;
    }*/
	
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
    public static ECRM_Huddle_Board__c createHuddleRec(String huddleType, Id teamId)
    {
        ECRM_Huddle_Board__c huddle = new ECRM_Huddle_Board__c();
        huddle.ECRM_Huddle_Type__c=huddleType;
        huddle.ECRM_Huddle_Team__c=teamId;        
        insert huddle;
        return huddle;
    }
    public static String getImageType (String type)
    {
        String returnStr = '';
        if(type.equalsIgnoreCase('Problem Solve'))
            returnStr = PROBLEM_SOLVE;
        else if (type.equalsIgnoreCase('Priority'))
            returnStr = BAROMETER;
        system.debug('returnStr'+returnStr);
        return returnStr;
    }
   	
    @AuraEnabled
    public static HuddleWrapperClass getImageFromAttachments(String imageType)
    {
		HuddleWrapperClass huddleCls = new HuddleWrapperClass();
		String imgType = getImageType(imageType);
        Attachment attach = new Attachment();
        getLoggedInUsersPrimaryCDTGroup();//Get the Team Name
        system.debug('imgType' +imgType);
        Id huddleId = getHuddleId(imgType);
        system.debug('huddleId' +huddleId);
        if(huddleId!=null)
        {
            attach = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:huddleId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
        }
        system.debug('attach'+attach);
		huddleCls.myAttachments=attach;
		huddleCls.teamName=ECRM_PRIMARY_TEAM_NAME;
        return huddleCls;
        
    }
    
	/*@AuraEnabled
    public static Attachment getAttachment4Team(String teamName, String huddleType)
    {
        String imgType = getImageType(huddleType);
        Attachment attach = new Attachment();
        //getLoggedInUsersPrimaryCDTGroup();//Get the Team Name
        system.debug('imgType' +imgType);
        Id huddleId = getHuddleId4Team(teamName,imgType);
        system.debug('huddleId' +huddleId);
        if(huddleId!=null)
        {
            attach = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:huddleId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
        }
        system.debug('attach'+attach);
        return attach;
        
    }
	
	 public static Id getHuddleId4Team(String teamNe, String huddleType)
    {
        Id hudID;
        List<ECRM_Huddle_Board__c> huddleId = new List<ECRM_Huddle_Board__c>();
        huddleId = [SELECT Id, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:teamNe
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1];
       	//system.debug('myhuddleContents' + huddleId);
        for(ECRM_Huddle_Board__c huddle : huddleId)
        {
            hudID = huddle.Id;
        }
        return hudID;
    }*/
	
    public static Id getHuddleId(String huddleType)
    {
        Id hudID;
        List<ECRM_Huddle_Board__c> huddleId = new List<ECRM_Huddle_Board__c>();
        huddleId = [SELECT Id, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:ECRM_PRIMARY_TEAM_NAME
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1];
       	//system.debug('myhuddleContents' + huddleId);
        for(ECRM_Huddle_Board__c huddle : huddleId)
        {
            hudID = huddle.Id;
        }
        return hudID;
    }
    //Type = ? && Visible = true && Team = logged in User's primary team && created date desc && limit first 7 values
    
	
	@AuraEnabled
    public static HuddleWrapperClass getFocusOfTheWeekForTeam(String teamName, String huddleType)
    {
        HuddleWrapperClass fotwhuddle = new HuddleWrapperClass();
        List<ECRM_Huddle_Board__c> myhuddleContents = new List<ECRM_Huddle_Board__c>();
        String fotwValue = '';
myhuddleContents = [SELECT Id,ECRM_Huddle_Content__c, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Huddle_Visible__c,ECRM_Rich_Tx__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Team__r.Name =:teamName
               AND ECRM_Huddle_Type__c =:huddleType LIMIT 1]; 
        system.debug('myhuddleContents' +myhuddleContents);
        if(!myhuddleContents.isEmpty())
        {
            for(ECRM_Huddle_Board__c huddle : myhuddleContents)
            {
                fotwValue =huddle.ECRM_Rich_Tx__c;
                fotwhuddle.hudId=huddle.Id;
            }
            system.debug('1st fotwValue' + fotwValue);
        }
        system.debug('2nd fotwValue' + fotwValue);
        if(String.isBlank(fotwValue))
           fotwValue = 'Please enter your FOTW here';
        //system.debug('fotwValue' +fotwValue);
        //return fotwValue;
        fotwhuddle.fotwText=fotwValue;
        return fotwhuddle;
    }
    
    
    public static void getLoggedInUsersPrimaryCDTGroup()
    {
        List<ECRM_Team_Membership__c> userCDTGroup = new List<ECRM_Team_Membership__c>();
        
        userCDTGroup = [SELECT Id, Name, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name, 
            ECRM_Member_Name__r.Name,ECRM_Member_Team__c, ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId()
                AND ECRM_Primary__c = true];
        
       /* if(userCDTGroup.isEmpty())
        {
            ERROR_PRIMARY_GRP_NOT_SPECIFIED = true;
        }
        else if(userCDTGroup.size()>1)
        {
            IS_MORE_PRIMARY_GRP_SPECIFIED = true;
        }
        else if(userCDTGroup.size()==1)
        {*/
            for(ECRM_Team_Membership__c myCDT : userCDTGroup)
            {
                ECRM_PRIMARY_TEAM_NAME = myCDT.ECRM_Member_Team__r.Name;
                ECRM_PRIMARY_TEAM_ID = myCDT.ECRM_Member_Team__c;
                system.debug('team...nmae ' + ECRM_PRIMARY_TEAM_NAME);
            }       
    }
    
    
    
    
    
    @AuraEnabled
    public static List<String> getLoggedInUserCDTTeam()
	{
		List<String> userCDTGroup = new List<String>();
		List<String> userPrimaryCDTGroup = new List<String>();
		List<ECRM_Team_Membership__c> teamMembers = new List<ECRM_Team_Membership__c>();
		
        //From Team members pull all the teams that the logged user is active
		teamMembers =[SELECT Id, Name, ECRM_Member_Name__c, ECRM_Member_Team__r.ECRM_Chatter_GroupName__c, ECRM_Member_Team__r.Name,
		ECRM_Member_Name__r.Name,ECRM_Member_Team__c, ECRM_Primary__c FROM ECRM_Team_Membership__c where ECRM_Member_Name__c =:UserInfo.getUserId() and ECRM_Member_Team__r.Name!= Null Limit 25];
		
        for(ECRM_Team_Membership__c mem : teamMembers)
		{
			//find the primary team
			if(mem.ECRM_Primary__c)
				userPrimaryCDTGroup.add(mem.ECRM_Member_Team__r.Name);
			else
				userCDTGroup.add(mem.ECRM_Member_Team__r.Name);
		}
        
		if(!userCDTGroup.isEmpty())
		{
			for(String cdtGrps : userCDTGroup)
			{
				userPrimaryCDTGroup.add(cdtGrps);
			}
		}
		return userPrimaryCDTGroup;
	}
    
    @AuraEnabled
    public static List<ECRM_Huddle_Board__c> getNewsForTeam(String teamName, String huddleType)
    {
        return [SELECT Id,ECRM_Huddle_Content__c, ECRM_Huddle_Team__c,ECRM_Huddle_Team__r.Name,ECRM_Huddle_Type__c,ECRM_Huddle_Visible__c,CreatedDate
                from ECRM_Huddle_Board__c where ECRM_Huddle_Visible__c =:REC_VISIBILITY AND ECRM_Huddle_Team__r.Name =:teamName
               AND ECRM_Huddle_Type__c =:huddleType ORDER BY CreatedDate DESC LIMIT :NO_OF_RECORDS_ALLOWED ];
    }
    
}