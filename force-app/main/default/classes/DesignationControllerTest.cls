@IsTest
public with sharing class DesignationControllerTest {

    @IsTest(SeeAllData=true) 
    public static void testFetchContactDesignations() {

        System.debug('testFetchContactDesignations Confirm appropriate list returned');
        Exception unexpectedException;
        try {

            Contact ContactData = [select name, id from contact where referee_rank__c = 'Referee' and 
				id in (select designee__c from designation__c) limit 1];
            
            System.debug('ContactId = ' + ContactData.Id);

            List<Designation__c> designations = DesignationController.fetchContactDesignations(ContactData.Id);
            
            System.assert( designations != null,'testFetchContactDesignations - A list was not returned');
            
            System.debug('fetchContactDesignations returned ' + designations.size() + ' rows ');

        } catch (Exception err) {
            System.debug('testFetchContactDesignations err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testFetchContactDesignations unexpected Exception');
        System.debug('testFetchContactDesignations completed');

    }
    

    @IsTest(SeeAllData=true) 
    public static void testFetchContactDesignationsWithExclusions() {

        System.debug('testFetchContactDesignations Confirm appropriate list returned');
        Exception unexpectedException;
        try {

            Contact ContactData = [select name, id from contact where referee_rank__c = 'Referee' and 
				id in (select designee__c from designation__c) limit 1];
            
            System.debug('ContactId ' + ContactData.Id);

            String pDesigneeId=ContactData.Id;
            String pExclusionList='(\'Chief Referee\',\'Emeritus\',\'FISA\',\'Clinician\',\'Mentor\',\'Referee College Faculty\',\'Referee Committee\',\'Regional Coordinator\',\'Staff\')';
            
            System.debug('Overloaded fetchContactDesignations follows');
            System.debug('pDesigneeId = ' + pDesigneeId);
            System.debug('pExclusionList = ' + pExclusionList);

            List<Designation__c> designations = DesignationController.fetchContactDesignations(pDesigneeId, pExclusionList);
            
            System.assert( designations != null,'testFetchContactDesignations - A list was not returned');
            
            System.debug('fetchContactDesignations returned ' + designations.size() + ' rows ');
            System.debug('designations ' + designations);

        } catch (Exception err) {
            System.debug('testFetchContactDesignations err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testFetchContactDesignations unexpected Exception');
        System.debug('testFetchContactDesignations completed');

    }


    @isTest(SeeAllData=true) 
    public static void testGetDesignationsList() {

        System.debug('Confirm appropriate list returned');
        Exception unexpectedException;
        try {
            
            List<String> picklist = DesignationController.getDesignationsPicklist();
            System.assert( picklist != null,'testGetLimitedRefereeStatusList - A list was not returned');

        } catch (Exception err) {
            System.debug('testGetLimitedRefereeStatusList err: ' + err);
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'testGetLimitedRefereeStatusList unexpected Exception');
        System.debug('testGetLimitedRefereeStatusList completed');
    }

    
    
}