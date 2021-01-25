public with sharing class DesignationController {

    public static Designation__c[] contactDesignations {get; set;}
    
     @AuraEnabled 
    public static List<Designation__c> fetchContactDesignations(String Designee){

        /* THIS IS A FULL DATA PULL JOINING Designation__c and Contact
            select Name, designee__r.name, designee_user__c, designee__c,
            designee__r.referee_rank__c, 
            designee__r.referee_status__c, isdeleted,
            designation__c, Designation_Start_Date__c,
            Designation_End_Date__c
            from Designation__c
            where designee__c =: Designee
            order by designation_start_date__c desc
        */

        List<Designation__c> designations = [select Name, designee__c,
            designation__c, Designation_Start_Date__c, Designation_End_Date__c
            from Designation__c 
            where designee__c =: Designee
            order by Designation_Start_Date__c desc];
        
        return designations;
    }
    
}