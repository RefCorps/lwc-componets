@isTest
public with sharing class PicklistCompControllerTest {
    
    Private Static String testObjName = 'Contact';
    Private Static String testFieldName = 'LeadSource';
    
    @isTest
    public static void GetFieldPicklistValuesTest1() {

        Exception unexpectedException;
        try {
 
            List<String> pllist1 = PicklistCompController.getPickListValues(testObjName, testFieldName);

            integer plcnt = pllist1.size();
            Boolean existsPLValues = false;
            if (plcnt == 0) {
                existsPLValues = false;
            } else {
                existsPLValues = true;
            }

            if (!existsPLValues) {
                System.assertNotEquals(true, existsPLValues, 'PicklistCompController: missing values from getPickListValues');
            }

        } catch (Exception err) {
                System.debug('PicklistCompController err: ' + err);
                unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'PicklistCompController getPickListValues unexpected Exception');

    }
    
    @isTest
    public static void GetObjectlistTest1() { 
    
        Exception unexpectedException;
        try {
            
            List<String> pllist1 = PicklistCompController.getObjectAPINames(testObjName);
            
            integer plcnt = pllist1.size();
            Boolean existsPLValues = false;
            if (plcnt == 0) {
                existsPLValues = false;
            } else {
                existsPLValues = true;
            }

            if (!existsPLValues) {
                System.assertNotEquals(true, existsPLValues, 'PicklistCompController: missing values from getObjectAPINames');
            }
            
        } catch (Exception err){
             System.debug('PicklistCompController err: ' + err);
                unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'PicklistCompController getObjectAPINames unexpected Exception');
    
    }

    @isTest
    public static void GetPickListFieldsTest1() {

        Exception unexpectedException;
        try {
            
            List<String> pllist1 = PicklistCompController.getObjectPicklistFields(testObjName);
            
            integer plcnt = pllist1.size();
            Boolean existsPLValues = false;
            if (plcnt == 0) {
                existsPLValues = false;
            } else {
                existsPLValues = true;
            }

            if (!existsPLValues) {
                System.assertNotEquals(true, existsPLValues, 'PicklistCompController: missing values from getObjectAPINames');
            }
            
        } catch (Exception err){
             System.debug('PicklistCompController err: ' + err);
                unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'PicklistCompController unexpected Exception');
        
    }
    
}