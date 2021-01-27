public with sharing class DesignationController {

    @AuraEnabled 
    public static List<Designation__c> fetchContactDesignations(String pDesigneeId){

        /* THIS IS A FULL DATA PULL JOINING Designation__c and Contact
            select Name, designee__r.name, designee_user__c, designee__c,
            designee__r.referee_rank__c, 
            designee__r.referee_status__c, isdeleted,
            designation__c, Designation_Start_Date__c,
            Designation_End_Date__c
            from Designation__c
            where designee__c =: Designee
            order by designation_start_date__c desc
			
		   THIS IS THE TEST SELECT
			Contact ContactData = [select name, id from contact where referee_rank__c = 'Referee' and 
				id in (select designee__c from designation__c) limit 1];
        */

        System.debug(LoggingLevel.DEBUG, 'DesignationController.fetchContactDesignations pDesigneeId=' + pDesigneeId );

        List<Designation__c> designations = [select Id, 
            Name, 
            designee__c,
            designation__c, 
            Designation_Start_Date__c, 
            Designation_End_Date__c
            from Designation__c 
            where designee__c =: pDesigneeId
            and IsDeleted = false
            order by Designation_Start_Date__c desc, Name desc];
        
        System.debug(LoggingLevel.DEBUG, 'In DesignationController.fetchContactDesignations returning ' + designations.size() + ' records' );
        
        return designations;
    }
        
    @AuraEnabled 
    public static List<String> getDesignationsPicklist() {
        List<String> designationpicklist = new List<String>();
        Schema.DescribeFieldResult designationPL = Designation__c.Designation__c.getDescribe();
		List<Schema.PicklistEntry> picklist = designationPL.getPicklistValues();
        for(Schema.PicklistEntry entry : picklist) {
            System.debug(LoggingLevel.DEBUG, 'In DesignationController.fetchContactDesignations entry.getValue() = ' + entry.getValue());
            designationpicklist.add(entry.getValue());
        }
        return designationpicklist;    
    }
        
}