global class RefereeStatus {

    @InvocableMethod
    public static List<String> getLimitedRefereeStatusList(List<String> excludeStatus) {
        List<String> statuspicklist = new List<String>();
		List<Schema.PicklistEntry> picklist = getContactStatusPL();
        for(Schema.PicklistEntry entry : picklist) {
            //System.debug('entry value = ' + entry.getValue());
            if(!entry.getValue().contains(excludeStatus[0])) {
                statuspicklist.add(entry.getValue());
            }           
        }
        return statuspicklist;    
    }

    private static List<Schema.PicklistEntry> getContactStatusPL() 
    { 
        return Contact.Referee_Status__c.getDescribe().getPicklistValues(); 
    }
    
}