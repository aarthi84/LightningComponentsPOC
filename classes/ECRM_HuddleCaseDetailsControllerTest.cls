/*
// Copyright © 2016 Fannie Mae. All rights reserved.
// This software contains confidential information and trade secrets of Fannie Mae. Use,   disclosure, or reproduction is prohibited without the prior written consent of Fannie Mae.
// Name - ECRM_HuddleCaseDetailsControllerTest
// Description: This test class is for ECRM_HuddleCaseDetailsController
// // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Author               Date            Description
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
// Fang Z -Acumen Solutions          12/14/2016      Created
// Aarthi                            12/15/2016      Modified based on the recent changes in the controller class 
*/

@isTest
private class ECRM_HuddleCaseDetailsControllerTest {
    /*private static List<String> acctIds;
    // Data Setup
    static void setup() {
        acctIds = new List<String>();
        // Create Account
        String newAccountId = '';
        newAccountId = ECMS_UtilTestData.createAccount('Test Account','024680135'); 
        acctIds.add(newAccountId);
        // Create Cases
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Kanban Case').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case newCase1 = new Case();
        newCase1 = ECMS_UtilTestData.createCase(newAccountId);
        newCase1.Status = 'Open';
        newCase1.RecordTypeId = caseRecordTypeId;
        caseList.add(newCase1);
        update caseList;
    }
	static testMethod void testBasic() {
        setup();
        Test.startTest();
            //ECRM_HuddleKanbanCaseDetailsController.getKanbanCaseRecTypeId();
            ECRM_HuddleKanbanCaseDetailsController controller = new ECRM_HuddleKanbanCaseDetailsController();
            ECRM_HuddleKanbanCaseDetailsController.displayDueThisWeekCases(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.displayDueTodayCases(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.displayLongTermCases(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.displayNewCases24Hr(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.displayPastDueCases(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.displayReqCompCases(acctIds);
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails('Others', '1');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '1');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '2');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '3');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '4');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '5');
            ECRM_HuddleKanbanCaseDetailsController.getCaseDetails(acctIds[0], '6');
        Test.stopTest();
        system.assertEquals(0, ECRM_HuddleKanbanCaseDetailsController.displayDueTodayCases(acctIds).size());
    }*/
}